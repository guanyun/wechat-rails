require 'wechat/api'

class Wechat::CardApi < Wechat::Api
  API_CARD_BASE = "https://api.weixin.qq.com/"

  def headers
    {base: API_CARD_BASE, content_type: :json}
  end

  def card_create(payload = {})
    post 'card/create', payload.to_json, headers
  end

  def location_batchadd(payload = {})
    post 'card/location/batchadd', payload.to_json, headers
  end

  def locations(offset = 0, count = 10)
    post 'card/location/batchget', {offset: offset, count: count}.to_json, headers
  end

  def colors
    get 'card/getcolors', base: API_CARD_BASE
  end

  def qrcode_create(payload = {})
    post 'card/qrcode/create', payload.to_json, headers
  end

  def code_mark(code, card_id, openid, is_mark = true)
    payload = { code: code, card_id: card_id, openid: openid, is_mark: is_mark }
    post 'card/code/mark', payload.to_json, headers
  end

  def code_consume(code, options = {})
    payload = { code: code }
    payload.merge!(options) unless options.empty?
    post 'card/code/consume', payload.to_json, headers
  end

  def code_decrypt(encrypt_code)
    post 'card/code/decrypt', {encrypt_code: encrypt_code}.to_json, headers
  end

  def card_delete(card_id)
    post 'card/delete', {card_id: card_id}.to_json, headers
  end

  def code(code, card_id = nil)
    payload = { code: code }
    payload[:card_id] = card_id unless card_id.nil?
    post 'card/code/get', payload.to_json, headers
  end

  def cards(offset = 0, count = 10)
    post 'card/batchget', {offset: offset, count: count}.to_json, headers
  end

  def card(card_id)
    post 'card/get', {card_id: card_id}.to_json, headers
  end

  def code_update(code, card_id, new_code)
    post 'card/code/update', {code: code, card_id: card_id, new_code: new_code}.to_json, headers
  end

  def code_unavail(code, card_id)
    post 'card/code/unavailable', {code: code, card_id: card_id}.to_json, headers
  end

  def card_update(payload = {})
    post 'card/update', payload.to_json, headers
  end

  def card_modify_stock(card_id, increase_value, reduce_value)
    post 'card/modifystock', {card_id: card_id, increase_stock_value: increase_value, reduce_stock_value: reduce_value}, headers
  end

  def whitelist_set(payload = {})
    post 'card/testwhitelist/set', payload.to_json, headers
  end

  # wx.addCard({
  #     cardList: [{
  #         cardId: '',
  #         cardExt: ''
  #     }], // 需要添加的卡券列表
  #     success: function (res) {
  #         var cardList = res.cardList; // 添加的卡券列表信息
  #     }
  # });
  def js_add_card(params)
    default_sign_params = {
      timestamp: Wechat::Utils.get_timestamp,
      nonce_str: Wechat::Utils.get_nonce_str,
      api_ticket: api_ticket
    }
    card_list = params.map do |sign_params|
                  sign_params.reverse_merge! default_sign_params
                  sign_params[:signature] = Wechat::Utils.get_card_sign(sign_params)
                  sign_params.delete :api_ticket
                  { cardId: sign_params.delete(:card_id),  cardExt: sign_params.to_json }
                end
    {cardList: card_list}
  end

  def js_add_card(params)
    default_sign_params = {
      timestamp: Wechat::Utils.get_timestamp,
      nonce_str: Wechat::Utils.get_nonce_str,
      api_ticket: api_ticket
    }
    card_list = params.map do |sign_params|
                  sign_params.reverse_merge! default_sign_params
                  sign_params[:signature] = Wechat::Utils.get_card_sign(sign_params)
                  sign_params.delete :api_ticket
                  { cardId: sign_params.delete(:card_id),  cardExt: sign_params.to_json }
                end
    {cardList: card_list}
  end

  def to_wxcard_msg(touser, card_id)
    sign_params = {
      api_ticket: api_ticket,
      timestamp: Wechat::Utils.get_timestamp,
      nonce_str: Wechat::Utils.get_nonce_str,
      card_id: card_id,
    }
    sign_params[:signature] = Wechat::Utils.get_card_sign(sign_params)
    {
      touser: touser,
      msgtype: 'wxcard',
      wxcard: {
        card_id: card_id,
        card_ext: sign_params.slice(:timestamp, :nonce_str, :signature).to_json
      }
    }
  end

  # wx.chooseCard({
  #   shopId: '', // 门店Id
  #   cardType: '', // 卡券类型
  #   cardId: '', // 卡券Id
  #   timestamp: 0, // 卡券签名时间戳
  #   nonceStr: '', // 卡券签名随机串
  #   signType: '', // 签名方式，默认'SHA1'
  #   cardSign: '', // 卡券签名，详见附录4
  #   success: function (res) {
  #       var cardList= res.cardList; // 用户选中的卡券列表信息
  #   }
  # });
  def js_choose_card(params = Hash.new(''))
    sign_params = {
      app_id: appid,
      time_stamp: Wechat::Utils.get_timestamp,
      appsecret: secret,
      nonce_str: Wechat::Utils.get_nonce_str,
      card_id: params[:card_id],
      card_type: params[:card_type]
    }

    card_sign = Wechat::Utils.get_card_sign(sign_params)

    {
      cardType: sign_params[:card_type],
      cardId: sign_params[:card_id],
      timestamp: sign_params[:time_stamp],
      nonceStr: sign_params[:nonce_str],
      signType: 'SHA1',
      cardSign: card_sign
    }
  end

  def api_ticket
    if ticket = Redis.current.get(:api_ticket)
      ticket
    else
      data = get("ticket/getticket", { params: { type: 'wx_card' } })
      Redis.current.setex :api_ticket, data["expires_in"] - 5, data["ticket"]
      data["ticket"]
    end
  end
end
