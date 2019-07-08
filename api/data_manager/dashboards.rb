require 'grape'
require './lib/shared_params'

module API
  module DataManager
    class Dashboards < Grape::API
      helpers SharedParams

      resource :dashboards do

        desc 'Get dashboards'
        params do
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            dashboards = Kaminari.paginate_array(scoped_dashboards).page(params[:page]).per(params[:per_page])
            header['X-Total-Count'] = dashboards.total_count.to_s
            present :data, dashboards
          else
            raise Errors::Forbidden
          end
        end

        desc 'Get dashboard'
        params do
          requires :id, type: String
        end
        get ':id' do
          if current_user.can_do?(:read)
            dashboard = scoped_dashboards.find(declared_params[:id])
            present :data, dashboard
          else
            raise Errors::Forbidden
          end
        end

        desc 'Create dashboard'
        params do
          requires :data, type: Hash do
            requires :name, type: String
            requires :tree, type: String
          end
        end
        post do
          if current_user.can_do?(:manage_dashboards)
            dashboard = service(:create_dashboard, declared_params[:data], :data_manager)
            present :data, dashboard
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update dashboard'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            optional :name, type: String
            optional :tree, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_dashboards)
            dashboard = service(:update_dashboard, declared_params[:data].merge!(id: declared_params[:id]), :data_manager)
            present :data, dashboard
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete dashboard'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all)
            scoped_dashboards.find(declared_params[:id]).destroy!
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

        # route_param :id do
        #   namespace :users do

        #     desc 'Add user to dashboard'
        #     params do
        #       requires :data, type: Hash do
        #         requires :user_id, type: Integer
        #       end
        #     end
        #     post do
        #       if current_user.can_do?(:manage_dashboards)
        #         service(:add_user_to_dashboard, sanatized_params(:id, :data), :data_manager)
        #         present data: { success: true }
        #       else
        #         raise Errors::Forbidden
        #       end
        #     end

        #     desc 'Delete user from dashboard'
        #     delete ':user_id' do
        #       if current_user.can_do?(:manage_org) || current_user.id == params[:user_id].to_i
        #         service(:delete_user_from_dashboard, sanatized_params(:id, :user_id), :data_manager)
        #         present data: { success: true }
        #       else
        #         raise Errors::Forbidden
        #       end
        #     end

        #   end
        # end

      end
    end
  end
end
