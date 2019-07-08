require 'spec_helper'
require './app/status'

describe App::Status do

  it 'status' do
    get '/status'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("{\n  \"status\": \"ok\"\n}")
  end

  context 'content type' do
    it 'returns json' do
      get '/status'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(last_response.body).to eq("{\n  \"status\": \"ok\"\n}")
    end

    it 'does not return xml' do
      get '/status.xml'
      expect(last_response.status).to eq(404)
      expect(last_response.headers['Content-Type']).not_to eq('application/xml')
    end

    it 'does not return text' do
      get '/status.txt'
      expect(last_response.status).to eq(404)
      expect(last_response.headers['Content-Type']).not_to eq('text/plain')
    end
  end

end
