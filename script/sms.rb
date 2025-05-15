phone = ""
code = "123456"

client = RPCClient.new(
  access_key_id: ENV["ACCESS_KEY_ID"],
  access_key_secret: ENV["ACCESS_KEY_SECRET"],
  endpoint: "https://dysmsapi.aliyuncs.com",
  api_version: "2017-05-25"
)

response = client.request(
  action: "SendSms",
  params: {
    "SignName": "小海星平台",
    "TemplateCode": "SMS_262555238",
    "PhoneNumbers": "#{phone}",
    "TemplateParam": "{\"code\":\"#{code}\"}"
  },
  opts: {
    method: "POST",
    format_params: true
  }
)

p response
