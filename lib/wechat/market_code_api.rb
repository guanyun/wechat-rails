require 'wechat/api'

# api doc  https://developers.weixin.qq.com/doc/offiaccount/Unique_Item_Code/Unique_Item_Code_API_Documentation.html
class Wechat::MarketCodeApi < Wechat::Api
  API_MARKET_CODE_BASE = 'https://api.weixin.qq.com/intp/marketcode/'

  def headers
    { base: API_MARKET_CODE_BASE, content_type: :json }
  end

  %w[
    apply_code
    apply_code_query
    _apply_code_download
    code_active
    code_active_query
    ticket_to_code
  ].each do |method_name|
    define_method method_name do |options|
      post method_name.gsub('_', ''), options.to_json, headers
    end
  end

  def apply_code_download(options = {})
    text = _apply_code_download(options)['buffer']
    text = Base64.decode64(text)
    aes = OpenSSL::Cipher.new('AES-128-CBC')
    aes.decrypt
    aes.key = Wechat.config.market_code_key
    aes.iv = Wechat.config.market_code_key
    aes.update(text) + aes.final
  end
end
