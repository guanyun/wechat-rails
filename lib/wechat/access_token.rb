module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret

    def initialize(client, appid, secret)
      @appid = appid
      @secret = secret
      @client = client
    end

    def token
      Redis.current.get(:access_token) || refresh
    end

    def refresh
      data = client.get("token", params:{grant_type: "client_credential", appid: appid, secret: secret})
      Redis.current.setex(:access_token, data["expires_in"] - 5, data["access_token"])
      data["access_token"]
    end
  end
end
