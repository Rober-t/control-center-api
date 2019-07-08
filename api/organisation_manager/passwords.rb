require 'grape'

module API
  module OrganisationManager
    class Passwords < Grape::API
      resource :passwords do

        desc 'Reset password'
        params do
          requires :data, type: Hash do
            requires :token, type: String
            requires :password, type: String
          end
        end
        post do
          service(:reset_password, declared_params[:data], :organisation_manager)
          present data: { success: true }
        end

        namespace :actions do

          desc 'Send re-set password email'
          params do
            requires :data, type: Hash do
              requires :email, type: String
            end
          end
          post '/reset' do
            service(:send_reset_password_email, declared_params[:data], :organisation_manager)
            present data: { success: true }
          end

        end

      end
    end
  end
end
