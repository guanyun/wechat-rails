module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret

    def initialize(client, appid, secret)
      @appid = appid
      @secret = secret
      @client = client
    end

    def token
      read_token || refresh
    end

    def refresh
      data =
        client.get(
          'token',
          params: {
            grant_type: 'client_credential',
            appid: appid,
            secret: secret
          }
        )
      write_token(data)
      data['access_token']
    end

    protected

    def read_token
      puts "You should implement this `read_token` method on your own"
    end

    def write_token(data) # rubocop:disable Lint/UnusedMethodArgument
      puts "You should implement this `write_token` method on your own"
    end

    private

    def access_token_key
      "#{appid}_access_token"
    end
  end
end
