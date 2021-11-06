require 'wechat/api'
require 'wechat/card_api'
require 'wechat/gift_card_api'
require 'wechat/market_code_api'
require 'wechat/payment'
require 'wechat/cash_coupon'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Response, 'wechat/response'

  class AccessTokenExpiredError < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end

  module_function

  def config
    @config ||=
      begin
        require 'wechat/config'
        Config.new
      end
  end

  def api
    @api ||= Wechat::Api.new(config.appid, config.secret)
  end

  def payment
    @payment ||=
      Wechat::Payment.new(
        config.appid,
        config.secret,
        config.mchid,
        config.key,
        config.notify_url,
      )
  end

  def card
    @card ||= Wechat::CardApi.new(config.appid, config.secret)
  end

  def gift_card
    @gift_card ||= Wechat::GiftCardApi.new(config.appid, config.secret)
  end

  def cash_coupon
    @cash_coupon ||=
      Wechat::CashCoupon.new(config.appid, config.mchid, config.key)
  end

  def market_code
    @market_code ||= Wechat::MarketCodeApi.new(config.appid, config.secret)
  end

  def api_client_cert
    @api_client_cert ||=
      OpenSSL::PKCS12.new(File.read(config.api_client_cert), config.mchid)
  end
end

if defined?(ActionController::Base)
  class ActionController::Base
    def self.wechat_responder(opts = {})
      self.send(:include, Wechat::Responder)
      if (opts.empty?)
        self.wechat = Wechat.api
        self.token = Wechat.config.token
      else
        self.wechat =
          Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token])
        self.token = opts[:token]
      end
    end
  end
end
