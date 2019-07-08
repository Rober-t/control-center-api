require 'grape'

module API
  module AuthManager
    class Authentications < Grape::API
      resource :authentications do

        desc 'Authenticate user'
        params do
          requires :data, type: Hash do
            requires :email, type: String
            requires :password, type: String
          end
        end
        post do
          credentials = service(:authenticate_user, declared_params[:data], :auth_manager)
          present data: credentials
        end

        desc 'Revoke a token'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all) || current_user.id == params[:id]
            service(:revoke_token, declared_params, :auth_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

      end
    end
  end
end
