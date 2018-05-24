require 'wechat/api'
# api doc  https://mp.weixin.qq.com/wiki?t=resource/res_main&id=215143440770UT7Y
class Wechat::GiftCardApi < Wechat::Api
  API_CARD_BASE = "https://api.weixin.qq.com/card/giftcard/"

  def headers
    {base: API_CARD_BASE, content_type: :json}
  end

  def page_add(payload = {})
    post 'page/add', payload.to_json, headers
  end

  def page_get(page_id)
    post 'page/get', {page_id: page_id}.to_json, headers
  end

  def page_update(payload = {})
    post 'page/update', payload.to_json, headers
  end

  def page_batchget(payload = {})
    post 'page/update', payload.to_json, headers
  end

  def maintain(payload = {})
    post 'maintain/set', payload.to_json, headers
  end

  def submach_bind(payload = {})
    post 'pay/submach/bind', payload.to_json, headers
  end

  def wxa_set(payload = {})
    post 'wxa/set', payload.to_json, headers
  end

  def order_get(order_id)
    post 'order/get', {order_id: order_id}.to_json, headers
  end

  def order_batchget(payload = {})
    post 'order/batchget', payload.to_json, headers
  end

  def order_refund(order_id)
    post 'order/refund', {order_id: order_id}.to_json, headers
  end
end
