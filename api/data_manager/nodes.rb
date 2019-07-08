require 'grape'
require './lib/shared_params'

module API
  module DataManager
    class Nodes < Grape::API
      helpers SharedParams

      resource :nodes do

        desc 'Get nodes'
        params do
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            nodes = Kaminari.paginate_array(scoped_nodes).page(params[:page]).per(params[:per_page])
            header['X-Total-Count'] = nodes.total_count.to_s
            present :data, nodes
          else
            raise Errors::Forbidden
          end
        end

        desc 'Get node'
        params do
          requires :id, type: String
        end
        get ':id' do
          if current_user.can_do?(:read)
            node = scoped_nodes.find(declared_params[:id])
            present :data, node
          else
            raise Errors::Forbidden
          end
        end

        desc 'Create node'
        params do
          requires :data, type: Hash do
            requires :name, type: String
            requires :url, type: String
          end
        end
        post do
          if current_user.can_do?(:manage_nodes)
            node = service(:create_node, declared_params[:data], :data_manager)
            present :data, node
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update node'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            optional :name, type: String
            optional :url, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_nodes)
            node = service(:update_node, declared_params[:data].merge!(declared_params.slice(:id)), :data_manager)
            present :data, node
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete node'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all)
            scoped_nodes.find(declared_params[:id]).destroy!
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

        # route_param :id do
        #   namespace :users do

        #     desc 'Add user to node'
        #     params do
        #       requires :id, type: String
        #       requires :data, type: Hash do
        #         requires :user_id, type: Integer
        #       end
        #     end
        #     post do
        #       if current_user.can_do?(:manage_nodes)
        #         service(:add_user_to_node, declared_params[:data].merge!(declared_params.slice(:id)), :data_manager)
        #         present data: { success: true }
        #       else
        #         raise Errors::Forbidden
        #       end
        #     end

        #     desc 'Delete user from node'
        #     params do
        #       requires :id, type: String
        #       requires :user_id, type: String
        #     end
        #     delete ':user_id' do
        #       if current_user.can_do?(:manage_org) || current_user.id == params[:user_id].to_i
        #         service(:delete_user_from_node, declared_params, :data_manager)
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
