require 'grape'
require './lib/shared_params'

module API
  module OrganisationManager
    class Users < Grape::API
      helpers SharedParams

      resource :users do

        desc 'Get users'
        params do
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            users = current_organisation.users
            users = Kaminari.paginate_array(users).page(params[:page]).per(params[:per_page])
            header['X-Total-Count'] = users.total_count.to_s
            present :data, users
          else
            raise Errors::Forbidden
          end
        end

        desc 'Get user'
        params do
          requires :id, type: String
        end
        get ':id' do
          if current_user.can_do?(:read)
            user = current_organisation.users.find(declared_params[:id])
            present :data, user
          else
            raise Errors::Forbidden
          end
        end

        desc 'Create user'
        params do
          requires :data, type: Hash do
            requires :email, type: String
          end
        end
        post do
          if current_user.can_do?(:invite)
            user = service(:invite_user, declared_params[:data], :organisation_manager)
            present :data, user
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update user'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            optional :name, type: String
            optional :email, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_org) || current_user.id == declared_params[:id]
            user = service(:update_user, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
            present :data, user
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete user'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all) || current_user.id == declared_params[:id]
            user = service(:delete_user, declared_params, :organisation_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

      end
    end
  end
end
