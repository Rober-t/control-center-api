require 'grape'

module API
  module OrganisationManager
    class Confirmations < Grape::API
      resource :confirmations do

        desc 'Confirm user'
        params do
          requires :data, type: Hash do
            requires :token, type: String
            requires :password, type: String
            requires :name, type: String
          end
        end
        post do
          service(:confirm_user, declared_params[:data], :organisation_manager)
          present data: { success: true }
        end

        namespace :actions do

          desc 'Re-send confirmation email'
          params do
            requires :data, type: Hash do
              requires :email, type: String
            end
          end
          post '/resend' do
            if current_user.can_do?(:manage_org)
              service(:send_confirmation_email, declared_params[:data], :organisation_manager)
              present data: { success: true }
            else
              raise Errors::Forbidden
            end
          end

        end

      end
    end
  end
end

