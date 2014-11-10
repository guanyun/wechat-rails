require 'digest/sha1'
require 'digest/md5'
require 'securerandom'

module Wechat
  module Utils
    module_function

    def required_check(params = {}, requires = [])
      requires.each do |required|
        unless params.include? required
          raise "Wechat payment Error, params required hash symbol :#{require}"
        end
      end
      params
    end

    def get_nonce_str
      SecureRandom.hex 16
    end

    def get_timestamp
      Time.now.to_i.to_s
    end

    def get_sign(params, key)
      params = params.clone
      params.delete(:sign)
      string_sign_temp = "#{to_query(params)}&key=#{key}"
      md5(string_sign_temp).upcase
    end

    def to_query(params = {})
      params.stringify_keys.sort.map { |key, value| "#{key}=#{value}" }.join('&')
    end

    def md5(sign_string)
      Digest::MD5.hexdigest(sign_string)
    end

    def sha1(sign_string)
      Digest::SHA1.hexdigest(sign_string)
    end

    def hash_to_xml(hash)
      hash.to_xml(root: "xml", skip_instruct: true, skip_types: true, dasherize: false)
    end
  end
end
