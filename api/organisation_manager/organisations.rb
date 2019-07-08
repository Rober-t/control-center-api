require 'grape'

module API
  module OrganisationManager
    class Organisations < Grape::API
      resource :organisations do

        desc 'Create organisation'
        params do
          requires :data, type: Hash do
            requires :name, type: String
            requires :admin, type: Hash do
              requires :email, type: String
            end
          end
        end
        post do
          account = service(:create_account, declared_params[:data], :organisation_manager)
          present data: { organisation: account[:organisation], admin: account[:user] }
        end

        desc 'Update organisation'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            requires :name, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_org) && current_organisation.id == params['id'].to_i
            organisation = service(:update_organisation, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
            present :data, organisation
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete organisation'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all) && current_organisation.id == params['id'].to_i
            service(:delete_organisation, current_organisation.id, :organisation_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

      end
    end
  end
end
