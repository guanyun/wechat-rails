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

  def code_consume(code, card_id)
    post 'card/code/consume', {code: code, card_id: card_id}.to_json, headers
  end

  def code_decrypt(encrypt_code)
    post 'card/code/decrypt', {encrypt_code: encrypt_code}.to_json, headers
  end

  def card_delete(card_id)
    post 'card/delete', {card_id: card_id}.to_json, headers
  end

  def code(code, card_id)
    post 'card/code/get', {code: code, card_id: card_id}.to_json, headers
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

  def js_add_card(card_ids)
    card_list = card_ids.map do |card_id|
                  params = { card_id: card_id, timestamp: Wechat::Utils.get_timestamp }
                  params[:signature] = Wechat::Utils.get_add_card_sign(params.merge(appsecret: @secret))
                  { cardId: card_id,  cardExt: params.to_json }
                end
    {cardList: card_list}.to_json
  end
end
