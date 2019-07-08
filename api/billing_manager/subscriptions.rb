require 'grape'

module API
  module BillingManager
    class Subscriptions < Grape::API
      resource :subscriptions do

        desc 'Get subscription'
        get do
          subscription = current_user.subscription
          present :data, subscription
        end

        desc 'Create subscription'
        params do
          requires :data, type: Hash do
            requires :card_token, type: String
            requires :plan, type: String
            optional :coupon, type: String
          end
        end
        post do
          if current_user.can_do?(:all)
            subscription = service(:create_subscription, declared_params[:data], :billing_manager)
            present :data, subscription
          else
            raise Errors::Forbidden
          end
        end

        desc 'Update subscription'
        params do
          requires :id, type: String
          requires :data, type: Hash do
            requires :plan, type: String
            optional :coupon, type: String
          end
        end
        put ':id' do
          if current_user.can_do?(:all)
            subscription = service(:update_subscription, declared_params[:data], :billing_manager)
            present :data, subscription
          else
            raise Errors::Forbidden
          end
        end

        desc 'Cancel subscription'
        params do
          requires :id, type: String
        end
        delete ':id' do
          if current_user.can_do?(:all)
            service(:cancel_subscription, declared_params, :billing_manager)
            present data: { success: true }
          else
            raise Errors::Forbidden
          end
        end

        route_param :id do
          namespace :actions do

            desc 'Update credit card'
            params do
              requires :id, type: String
              requires :data, type: Hash do
                requires :card_attributes, type: Hash
              end
            end
            post '/update_credit_card' do
              if current_user.can_do?(:all)
                service(:update_credit_card, declared_params[:data].merge!(declared_params.slice(:id)), :billing_manager)
                present data: { success: true }
              else
                raise Errors::Forbidden
              end
            end

            desc 'Update credit card owner'
            params do
              requires :id, type: String
              requires :data, type: Hash do
                requires :email, type: String
              end
            end
            post '/update_credit_card_owner' do
              if current_user.can_do?(:all)
                service(:update_credit_card_owner, declared_params[:data].merge!(declared_params.slice(:id)), :billing_manager)
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
