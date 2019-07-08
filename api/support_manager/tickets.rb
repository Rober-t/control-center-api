require 'grape'
require './lib/shared_params'

module API
  module SupportManager
    class Tickets < Grape::API
      helpers SharedParams

      resource :tickets do

        desc 'Get tickets'
        params do          
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            if params[:node_id]
              tickets = scoped_tickets.where(node_id: params[:node_id])
            else
              tickets = scoped_tickets
            end
            tickets = Kaminari.paginate_array(tickets).page(params[:page]).per(params[:per_page])
            header['X-Total-Count'] = tickets.total_count.to_s
            present :data, tickets
          else
            raise Errors::Forbidden
          end
        end

        desc 'Get ticket'
        params do
          requires :id, type: String
        end
        get ':id' do
          if current_user.can_do?(:read)
            ticket = scoped_tickets.find(declared_params[:id])
            present :data, ticket
          else
            raise Errors::Forbidden
          end
        end

        desc 'Create ticket'
        params do
          requires :data, type: Hash do
            requires :subject, type: String
            requires :description, type: String
            optional :node_id, type: Integer
          end
        end
        post do
          if current_user.can_do?(:manage_tickets)
            ticket = service(:create_ticket, declared_params[:data], :support_manager)
            present data: ticket
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update ticket'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            optional :subject, type: String
            optional :status, type: String
            optional :description, type: String
            optional :node_id, type: Integer
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_tickets)
            ticket = service(:update_ticket, declared_params[:data].merge!(declared_params.slice(:id)), :support_manager)
            present :data, ticket
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete ticket'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:manage_tickets)
            service(:delete_ticket, declared_params, :support_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

      end
    end
  end
end
