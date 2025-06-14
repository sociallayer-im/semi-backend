# -*- coding: UTF-8 -*-
require "digest"
require "json"
require "time"
require "openssl"
require "net/http"
require "uri"

module SendSms
    def self.send_sms(phone, code)
      puts "send_sms-----"
        secret_id=ENV['TENCENT_SMS_SECRET_ID']
        secret_key=ENV['TENCENT_SMS_SECRET_KEY']
        # token = ""

        service = "sms"
        host = "sms.tencentcloudapi.com"
        endpoint = "https://" + host
        region = "ap-guangzhou"
        action = "SendSms"
        version = "2021-01-11"
        algorithm = "TC3-HMAC-SHA256"
        timestamp = Time.now.to_i
        date = Time.at(timestamp).utc.strftime("%Y-%m-%d")

        http_request_method = "POST"
        canonical_uri = "/"
        canonical_querystring = ""
        canonical_headers = "content-type:application/json; charset=utf-8\nhost:#{host}\nx-tc-action:#{action.downcase}\n"
        signed_headers = "content-type;host;x-tc-action"
        payload = "{\"PhoneNumberSet\":[\"#{phone}\"],\"SmsSdkAppId\":\"1400989082\",\"TemplateId\":\"2431912\",\"SignName\":\"深圳市岑赫科技\",\"TemplateParamSet\":[\"#{code}\"]}"
        # payload = "{\"PhoneNumberSet\":[\"#{phone}\"],\"SmsSdkAppId\":\"1400989082\",\"TemplateId\":\"2431912\",\"SignName\":\"深圳市岑赫科技有限公司\",\"TemplateParamSet\":[\"#{code}\"]}"
        hashed_request_payload = Digest::SHA256.hexdigest(payload)
        canonical_request = [
                                http_request_method,
                                canonical_uri,
                                canonical_querystring,
                                canonical_headers,
                                signed_headers,
                                hashed_request_payload,
                            ].join("\n")

        puts canonical_request

        # ************* concat string *************
        credential_scope = date + "/" + service + "/" + "tc3_request"
        hashed_request_payload = Digest::SHA256.hexdigest(canonical_request)
        string_to_sign = [
                            algorithm,
                            timestamp.to_s,
                            credential_scope,
                            hashed_request_payload,
                        ].join("\n")
        puts string_to_sign

        # ************* get digest *************
        digest = OpenSSL::Digest.new("sha256")
        secret_date = OpenSSL::HMAC.digest(digest, "TC3" + secret_key, date)
        secret_service = OpenSSL::HMAC.digest(digest, secret_date, service)
        secret_signing = OpenSSL::HMAC.digest(digest, secret_service, "tc3_request")
        signature = OpenSSL::HMAC.hexdigest(digest, secret_signing, string_to_sign)
        puts signature

        # ************* authorization header *************
        authorization = "#{algorithm} Credential=#{secret_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
        puts authorization

        # ************* make request *************
        url = URI.parse(endpoint)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new("/")
        request.body = payload
        request["Authorization"] = authorization
        request["Content-Type"] = "application/json; charset=utf-8"
        request["Host"] = host
        request["X-TC-Action"] = action
        request["X-TC-Timestamp"] = timestamp
        request["X-TC-Version"] = version
        request["X-TC-Region"] = region
        # request["X-TC-Token"] = token
        response = http.request(request)
        puts response.body
    end

    def self.send_sms_aliyun(phone, code)
        client = RPCClient.new(
          access_key_id: ENV["ACCESS_KEY_ID"],
          access_key_secret: ENV["ACCESS_KEY_SECRET"],
          endpoint: "https://dysmsapi.aliyuncs.com",
          api_version: "2017-05-25"
        )

        response = client.request(
          action: "SendSms",
          params: {
            "SignName": ENV["ALIYUN_SMS_SIGN_NAME"],
            "TemplateCode": ENV["ALIYUN_SMS_TEMPLATE_CODE"],
            "PhoneNumbers": "#{phone}",
            "TemplateParam": "{\"code\":\"#{code}\"}"
          },
          opts: {
            method: "POST",
            format_params: true
          }
        )
    end
end
