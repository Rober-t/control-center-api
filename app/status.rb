require './app/base'

module App
  class Status < Grape::API
    include App::Base

    desc "API status"
    get '/status' do
      { status: 'ok' }
    end

  end
end

