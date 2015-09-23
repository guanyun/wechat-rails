require 'wechat/utils'

class Wechat::CashCoupon
  API_MCH_BASE = "https://api.mch.weixin.qq.com/mmpaymkttransfers/"
  attr_reader :client, :mch_id, :key, :wxappid

  def initialize(wxappid, mch_id, key)
    @client = Wechat::Client.new(API_MCH_BASE)
    @mch_id = mch_id
    @key = key
    @wxappid = wxappid
  end

  # https://pay.weixin.qq.com/wiki/doc/api/cash_coupon.php?chapter=13_5
  def sendredpack(params)
    Wechat::Utils.required_check(params, [:send_name, :re_openid, :total_amount, :wishing, :client_ip, :act_name, :remark])

    params.merge!({
      mch_id: mch_id,
      wxappid: wxappid,
      mch_billno: mch_billno,
      total_num: 1,
      nonce_str: Wechat::Utils.get_nonce_str})
    params[:sign] = Wechat::Utils.get_sign(params, key)
    xml_data = Wechat::Utils.hash_to_xml(params)
    client.ssl_post("sendredpack", xml_data, as: :xml)
  end

  def sendgroupredpack(params)
    Wechat::Utils.required_check(params, [:send_name, :re_openid, :total_amount, :total_num, :amt_type, :wishing, :act_name, :remark])

    params.merge!({
      mch_id: mch_id,
      wxappid: wxappid,
      mch_billno: mch_billno,
      amt_type: 'ALL_RAND',
      nonce_str: Wechat::Utils.get_nonce_str})
    params[:sign] = Wechat::Utils.get_sign(params, key)
    xml_data = Wechat::Utils.hash_to_xml(params)
    client.ssl_post("sendgroupredpack", xml_data, as: :xml)
  end

  def gethbinfo(mch_billno, bill_type='MCHT')
    params = {
      mch_billno: mch_billno,
      bill_type: bill_type,
      nonce_str: Wechat::Utils.get_nonce_str,
      mch_id: mch_id,
      appid: wxappid
    }
    params[:sign] = Wechat::Utils.get_sign(params)
    xml_data = Wechat::Utils.hash_to_xml(params)
    client.ssl_post("gethbinfo", xml_data, as: :xml)
  end

  private
  def mch_billno
    date = Time.now.strftime('%Y%m%d')
    ten_rand_num = 10.times.map{rand(10)}.join
    "#{mch_id}#{date}#{ten_rand_num}"
  end
end
