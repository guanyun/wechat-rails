require 'wechat/api'

module Wechat
  class MpApi < Wechat::Api
    WXA_BASE = 'https://api.weixin.qq.com/wxa/'

    def getphonenumber(payload = {})
      post 'business/getuserphonenumber', payload.to_json, base: WXA_BASE
    end
  end
end
