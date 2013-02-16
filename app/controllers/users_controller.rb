require 'uri'
require 'digest/md5'

class UsersController < ApplicationController
  def index

    params = {
      :response_type => 'code',
      :client_id => 'dj0zaiZpPWpNWG16d3BjUzFGdCZkPVlXazlWbVZLY2xJMU5uTW1jR285TUEtLSZzPWNvbnN1bWVyc2VjcmV0Jng9ZjE-',
      :redirect_uri =>  'http://localhost:3000/auth/callback',
      :scope => 'openid profile email address',
      :display =>  'touch',
      :state => Digest::MD5.hexdigest('state')
    }

    @loginUrl = 'https://auth.login.yahoo.co.jp/yconnect/v1/authorization?' + params.to_query

  end
end
