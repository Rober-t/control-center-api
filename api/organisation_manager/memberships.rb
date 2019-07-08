require 'grape'
require './lib/shared_params'

module API
  module OrganisationManager
    class Memberships < Grape::API
      helpers SharedParams

      resource :memberships do

        desc 'Get memberships'
        params do
          use :pagination
        end
        get do
          if current_user.can_do?(:read)
            memberships = current_organisation.memberships
            present :data, Kaminari.paginate_array(memberships).page(params[:page]).per(params[:per_page])
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update membership'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            requires :role, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:manage_org)
            membership = service(:update_membership, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
            present :data, membership
          else
            raise Errors::Forbidden
          end
        end

        desc 'Delete membership'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all)
            current_organisation.memberships.find(declared_params[:id]).destroy!
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

        route_param :id do
          namespace :actions do

            desc 'Get pending organisation transfer requests'
            params do
              requires :id, type: String
            end
            get '/pending_transfers' do
              if current_user.can_do?(:all)
                memberships = current_organisation.memberships.where.not(transfer_token: nil)
                present :data, memberships
              else
                raise Errors::Forbidden
              end
            end

            desc 'Request organisation ownership transfer'
            params do
              requires :id, type: String
              requires :data, type: Hash do
                requires :email, type: String
              end
            end
            post '/request_transfer' do
              if current_user.can_do?(:all)
                membership = service(:request_ownership_transfer, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
                present :data, membership
              else
                raise Errors::Forbidden
              end
            end

            desc 'Accept organisation ownership'
            params do
              requires :id, type: String
              requires :data, type: Hash do
                requires :transfer_token, type: String
              end
            end
            post '/accept_transfer' do
              membership = service(:accept_ownership_transfer, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
              present :data, membership
            end

            desc 'Revoke organisation transfer'
            params do
              requires :id, type: String
              requires :data, type: Hash do
                requires :email, type: String
              end
            end
            post '/revoke_transfer' do
              if current_user.can_do?(:all)
                service(:revoke_ownership_transfer, declared_params[:data].merge!(declared_params.slice(:id)), :organisation_manager)
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
end
