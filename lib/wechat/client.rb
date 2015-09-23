require 'rest_client'

module Wechat
  class Client

    attr_reader :base

    def initialize(base)
      @base = base
    end

    def get path, header={}
      request(path, header) do |url, header|
        RestClient.get(url, header)
      end
    end

    def post path, payload, header = {}
      request(path, header) do |url, header|
        RestClient.post(url, payload, header)
      end
    end

    def ssl_post path, payload, header = {}
      request(path, header) do |url, header|
        RestClient::Request.execute({
          method: :post,
          url: url,
          payload: payload,
          headers: header,
          ssl_client_cert: Wechat.api_client_cert.certificate,
          ssl_client_key: Wechat.api_client_cert.key,
          verify_ssl: OpenSSL::SSL::VERIFY_NONE})
      end
    end

    def request path, header={}, &block
      url = "#{header.delete(:base) || self.base}#{path}"
      as = header.delete(:as)
      header.merge!(:accept => :json) if as == :json
      response = yield(url, header)

      raise "Request not OK, response code #{response.code}" if response.code != 200
      parse_response(response, as || :json) do |parse_as, data|
        break data unless (parse_as == :json && data["errcode"].present? && data["errcode"] != 0)

        case data["errcode"]
        when 0 # for request didn't expect results
          url =~ /card/ ? data : true  # card api return 0 when successful
        #42001: access_token超时, 40014:不合法的access_token, 48001: api unauthorized
        when 40001, 42001, 40014, 48001
          raise AccessTokenExpiredError

        else
          raise ResponseError.new(data['errcode'], data['errmsg'])
        end
      end
    end

    private
    def parse_response response, as
      content_type = response.headers[:content_type]
      parse_as = {
        /^application\/json/ => :json,
        /^image\/.*/ => :file
      }.inject([]){|memo, match| memo<<match[1] if content_type =~ match[0]; memo}.first || as || :text
      data =  case parse_as
              when :file
                if (content_disposition = response.headers[:content_disposition])
                  extname = content_disposition[/.*(\..*)\"/, 1]
                  file = Tempfile.new(["wx-", extname])
                  file.binmode
                  file.write(response.body)
                  file.close
                  file
                end
              when :json
                HashWithIndifferentAccess.new_from_hash_copying_default(JSON.parse(response.body))
              when :xml
                xml = Hash.from_xml(response.body).fetch('xml', {})
                HashWithIndifferentAccess.new_from_hash_copying_default(xml)
              else
                response.body
              end
      yield(parse_as, data)
    end

  end
end
