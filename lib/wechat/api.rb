require 'wechat/client'
require 'wechat/access_token'

class Wechat::Api
  attr_reader :access_token, :client, :appid, :secret

  API_BASE = "https://api.weixin.qq.com/cgi-bin/"
  FILE_BASE = "http://file.api.weixin.qq.com/cgi-bin/"

  def initialize appid, secret
    @appid = appid
    @secret = secret
    @client = Wechat::Client.new(API_BASE)
    @access_token = Wechat::AccessToken.new(@client, appid, secret)
  end

  def users
    get("user/get")
  end

  def user openid
    get("user/info", params:{openid: openid})
  end

  def menu
    get("menu/get")
  end

  def menu_delete
    get("menu/delete")
  end

  def menu_create menu
    # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
    post("menu/create", JSON.generate(menu))
  end

  def media media_id
    response = get "media/get", params:{media_id: media_id}, base: FILE_BASE, as: :file
  end

  def media_create type, file
    post "media/upload", {upload:{media: file}}, params:{type: type}, base: FILE_BASE
  end

  def custom_message_send message
    post "message/custom/send", JSON.generate(message), content_type: :json
  end

  def message_preview message
    post "message/mass/preview", JON.generate(message), content_type: :json
  end

  def qrcode_create_scene(scene_id, expire_seconds = 604800)
    post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                        action_name: 'QR_SCENE',
                                        action_info: { scene: { scene_id: scene_id } })
  end

  def qrcode_create_limit_scene(scene_id_or_str)
    case scene_id_or_str
    when Fixnum
      post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_SCENE',
                                          action_info: { scene: { scene_id: scene_id_or_str } })
    else
      post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_STR_SCENE',
                                          action_info: { scene: { scene_str: scene_id_or_str } })
    end
  end

  def template_message_send message
    post "message/template/send", JSON.generate(message), content_type: :json
  end

  def batchget_material(options = {})
    post "material/batchget_material", JSON.generate(options), content_type: :json
  end

  def get_material(media_id)
    post "material/get_material", JSON.generate({ media_id: media_id }), content_type: :json
  end

  def shorturl(long_url)
    post "shorturl", JSON.generate({ action: 'long2short', long_url: long_url }), content_type: :json
  end

  def jsapi_ticket
    if ticket = Redis.current.get(:jsapi_ticket)
      ticket
    else
      data = get("ticket/getticket", { params: { type: 'jsapi' } })
      Redis.current.setex :jsapi_ticket, data["expires_in"] - 5, data["ticket"]
      data["ticket"]
    end
  end

  protected
  def get path, headers={}
    with_access_token(headers[:params]){|params| client.get path, headers.merge(params: params)}
  end

  def post path, payload, headers = {}
    with_access_token(headers[:params]){|params| client.post path, payload, headers.merge(params: params)}
  end

  def with_access_token params={}, tries=2
    begin
      params ||= {}
      yield(params.merge(access_token: access_token.token))
    rescue Wechat::AccessTokenExpiredError => ex
      access_token.refresh
      retry unless (tries -= 1).zero?
    end
  end

end
