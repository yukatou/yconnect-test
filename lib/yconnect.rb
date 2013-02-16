#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module YConnect
  module_function

  def config
    @config ||= {
      client_id:              'dj0zaiZpPVpmRGlVcWptaU0zRiZkPVlXazlPR2wwZG1aMU56UW1jR285TUEtLSZzPWNvbnN1bWVyc2VjcmV0Jng9NWY-',
      issuer:                 'https://auth.login.yahoo.co.jp',
      authorization_endpoint: 'https://auth.login.yahoo.co.jp/yconnect/v1/authorization',
      check_token_endpoint:   'https://auth.login.yahoo.co.jp/yconnect/v1/checktoken',
      user_info_endpoint:     'https://userinfo.yahooapis.jp/yconnect/v1/attribute',
      redirect_uri:           'yj-connect://',
      response_type:          [:token, :id_token],
      scope:                  [:openid, :email, :profile, :address]
    }
  end

  def nonce(refresh = false)
    App::Persistence[:nonce] = nil if refresh
    App::Persistence[:nonce] ||= NSUUID.UUID.UUIDString
    App::Persistence[:nonce]
  end

  def require_authorization!
    App.open_url build_endpoint(
      :authorization_endpoint,
      client_id:     config[:client_id],
      response_type: config[:response_type],
      redirect_uri:  config[:redirect_uri],
      scope:         config[:scope],
      nonce:         nonce(:refresh),
      display:       :touch,
      prompt:        :consent
    )
  end

  def verify_id_token!(jwt_string, &block)
    BW::HTTP.get build_endpoint(
      :check_token_endpoint,
      id_token: jwt_string
    ) do |res|
      if res.ok?
        id_token = BW::JSON.parse(res.body)
        if valid_id_token?(id_token) 
          block.call(
            user_id: id_token['user_id']
          )
        else
          App.alert 'Invalid ID Token'
        end
      else
        App.alert 'ID Token Verification Failed!'
      end
    end
  end

  def valid_id_token?(id_token)
    (
      id_token['iss']   == config[:issuer] &&
      id_token['nonce'] == nonce &&
      id_token['aud']   == config[:client_id] &&
      Time.at(id_token['exp'].to_i) > Time.now &&
      Time.at(id_token['iat'].to_i) < Time.now
    )
  ensure
    nonce :refresh
  end

  def fetch_user_info!(access_token, &block)
    BW::HTTP.get build_endpoint(
      :user_info_endpoint,
      schema: :openid,
      access_token: access_token
    ) do |res|
      if res.ok?
        user_info = BW::JSON.parse(res.body)
        block.call user_info
      else
        App.alert 'UserInfo Access Failed!'
      end
    end
  end

  def build_endpoint(location, params = {})
    [
      config[location],
      params.to_query
    ].join('?')
  end
end

