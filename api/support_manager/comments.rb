require 'grape'
require './lib/shared_params'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module API
  module SupportManager
    class Comments < Grape::API
      helpers SharedParams

      resource :comments do

        desc 'Get comments'
        params do          
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            comments = Kaminari.paginate_array(scoped_comments).page(params[:page]).per(params[:per_page])
            header['X-Total-Count'] = comments.total_count.to_s
            present :data, comments
          else
            raise Errors::Forbidden
          end
        end

        desc 'Get comment'
        params do
          requires :id, type: String
        end
        get ':id' do
          if current_user.can_do?(:read)
            comment = scoped_comments.find(declared_params[:id])
            present :data, comment
          else
            raise Errors::Forbidden
          end
        end

        desc 'Create comment'
        params do
          requires :data, type: Hash do
            requires :ticket_id, type: Integer
            requires :body, type: String
          end
        end
        post do
          if current_user.can_do?(:manage_comments)
            comment = service(:create_comment, declared_params[:data], :support_manager)
            present :data, comment
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update comment'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            optional :ticket_id, type: Integer
            optional :body, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_comments)
            comment = service(:update_comment, declared_params[:data].merge!(declared_params.slice(:id)), :support_manager)
            present :data, comment
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete comment'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:moderate)
            service(:delete_comment, declared_params, :support_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

      end
    end
  end
end
