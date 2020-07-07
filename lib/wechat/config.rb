require 'anyway'

module Wechat
  class Config < Anyway::Config
    config_name :wechat
    attr_config :appid,
                :secret,
                :key,
                :mchid,
                :token,
                :access_token,
                :api_client_cert,
                :notify_url,
                :weapp_appid,
                :sandbox_mode
  end
end