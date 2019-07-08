require 'spec_helper'

describe "Authentications" do

  describe "POST authentications", autodoc: true do
    context "with valid credentials" do

      before do
        current_user.update!(confirmed_at: Date.today, password: "Password1234")
      end

      it "authenticates request" do
        post 'authentications', { data: { email: current_user.email, password: current_user.password } }

        expect(last_response.status).to eq 201
        expect(last_response.header).to be_valid_json
        expect(last_response.body).to match_response_schema("authentication")
      end
    end

    context "with invalid credentials" do

      it "does not authenticate request" do
        post 'authentications', { data: { email: current_user.email, password: "invalid_password" } }

        expect(last_response.status).to eq 401
        expect(last_response.header).to be_valid_json
        expect(last_response.body).to match_response_schema("error")
      end

    end
  end

  describe "DELETE authentications/:id", autodoc: true do

    context "with valid credentials" do

      before(:each) do
        set_auth_header current_user
      end

      it "revokes the current token" do
        expect(current_user.jti).not_to eq nil

        delete "authentications/#{current_user.id}"

        expect(last_response.status).to eq 200
        expect(last_response.header).to be_valid_json
        expect(last_response.body).to match_response_schema("success")
        expect(current_user.reload.jti).to eq nil
      end
    end

  end
end
