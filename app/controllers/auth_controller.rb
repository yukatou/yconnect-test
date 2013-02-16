require 'net/http'
require 'net/https'
require 'json'
require 'base64'

class AuthController < ApplicationController
  def callback
    code = params[:code]
    state = params[:state]

    q = {
      :grant_type => 'authorization_code',
      :code => code,
      :redirect_uri => 'http://localhost:3000/auth/callback'
    }

    client_id = 'dj0zaiZpPWpNWG16d3BjUzFGdCZkPVlXazlWbVZLY2xJMU5uTW1jR285TUEtLSZzPWNvbnN1bWVyc2VjcmV0Jng9ZjE-'
    client_secret = 'c0463a75d42ca8809374010bc71f4154e22a9c94'

    uri = URI.parse('https://auth.login.yahoo.co.jp/yconnect/v1/token')

    request = Net::HTTP::Post.new(
      uri.request_uri,
      {'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8',
       'Authorization' => 'Basic ' + Base64::strict_encode64(client_id + ':' + client_secret) }
    )
    request.body = q.to_query

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.set_debug_output $stderr
    response = http.request(request)

    @authInfo = JSON.parse(response.body)

    @access_token = @authInfo['access_token']
 
    uri = URI.parse('https://userinfo.yahooapis.jp/yconnect/v1/attribute?' + {:schema => 'openid'}.to_query)

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = 'Bearer ' + @access_token
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.set_debug_output $stderr
    response = http.request(request)

    @userInfo = JSON.parse(response.body)
 
  end
end
