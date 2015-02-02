require 'wechat/utils'

class Wechat::Payment
  API_MCH_BASE = "https://api.mch.weixin.qq.com/pay/"
  attr_reader :client, :appid, :secret, :mch_id, :key, :notify_url

  def initialize(appid, secret, mch_id, key, notify_url)
    @client = Wechat::Client.new(API_MCH_BASE)
    @appid = appid
    @secret = secret
    @mch_id = mch_id
    @key = key
    @notify_url = notify_url
  end

  #response
  # {
  #   "return_code"=>"SUCCESS",
  #   "return_msg"=>"OK",
  #   "appid"=>"wxb74ad11807f36263",
  #   "mch_id"=>"10024328",
  #   "nonce_str"=>"P4OwClH9w8JCJ7e0",
  #   "sign"=>"12A22ADF3BA1EE6F2FBD48B7B1243909",
  #   "result_code"=>"SUCCESS",
  #   "prepay_id"=>"wx20141108154348ed4994cf2d0999736714",
  #   "trade_type"=>"NATIVE",
  #   "code_url"=>"weixin://wxpay/bizpayurl?sr=n9lWgQE"
  # }

  def unified_order(params)
    Wechat::Utils.required_check(params, [:body, :out_trade_no, :total_fee, :spbill_create_ip, :trade_type])
    params.reverse_merge! appid: appid,
                          mch_id: mch_id,
                          notify_url: notify_url,
                          nonce_str: Wechat::Utils.get_nonce_str
    params[:sign] = Wechat::Utils.get_sign(params, key)
    xml_data = Wechat::Utils.hash_to_xml(params)
    @client.post("unifiedorder", xml_data, as: :xml)
  end

  def get_native_dynamic_qrcode(params)
    result = unified_order(params.merge(trade_type: 'NATIVE'))
    result[:code_url]
  end

  def get_js_api_params(params)
    result = unified_order(params.merge(trade_type: 'JSAPI'))
    params = {
      appId: appid,
      timeStamp: Wechat::Utils.get_timestamp,
      nonceStr: Wechat::Utils.get_nonce_str,
      package: "prepay_id=#{result[:prepay_id]}",
      signType: "MD5"
    }
    params[:paySign] = Wechat::Utils.get_sign(params, key)
    # 支付签名时间戳，注意微信jssdk中的所有使用timestamp字段均为小写。
    # 但最新版的支付后台生成签名使用的timeStamp字段名需大写其中的S字符
    params[:timestamp] = params.delete :timeStamp
    params
  end

  def verify?(params)
    Wechat::Utils.get_sign(params, key) == params[:sign]
  end

  def order_query(out_trade_no)
    params = {
      appId: appid,
      mch_id: mch_id,
      out_trade_no: out_trade_no,
      nonce_str: Wechat::Utils.get_nonce_str,
    }
    params[:sign] = Wechat::Utils.get_sign(params, key)
    xml_data = Wechat::Utils.hash_to_xml(params)
    @client.post("orderquery", xml_data, as: :xml)
  end

  def close_order(out_trade_no)
    params = {
      appId: appid,
      mch_id: mch_id,
      out_trade_no: out_trade_no,
      nonce_str: Wechat::Utils.get_nonce_str,
    }
    params[:sign] = Wechat::Utils.get_sign(params, key)
    xml_data = Wechat::Utils.hash_to_xml(params)
    @client.post("closeorder", xml_data, as: :xml)
  end
end
