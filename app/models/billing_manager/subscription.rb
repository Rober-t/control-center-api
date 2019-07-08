require 'statesman'
require './app/models/billing_manager/subscription_state_machine'
require './app/models/billing_manager/subscription_transition'
require './app/models/organisation_manager/user'

class CardError < StandardError; end
class PaymentProcessingError < StandardError; end

class BillingManager
  class Subscription < ActiveRecord::Base
    include Statesman::Adapters::ActiveRecordQueries

    STATES = %w(inactive active past_due canceled)
    ACTIVE_STATES = %w(active past_due)
    PAID_PLANS = %w(pro enterprise)

    has_many :subscription_transitions, autosave: false, dependent: :destroy

    delegate :current_state, :allowed_transitions, :transition_to!, :can_transition_to?, to: :state_machine

    validates :user_id, :plan, :customer_id, :subscription_id, presence: true
    validates :current_period_start, :current_period_end, :default_card, presence: true
    validates :state, :inclusion => { :in => STATES }
    validates :user_id, :subscription_id, uniqueness: true
    validates :plan, :inclusion => { :in => PAID_PLANS }

    def state_machine
      @state_machine ||= BillingManager::SubscriptionStateMachine.new(
        self,
        transition_class: BillingManager::SubscriptionTransition
      )
    end

    def active?
      ACTIVE_STATES.include?(state)
    end

    def create_customer(email)
      customer = Stripe::Customer.create(email: email)
      self.customer_id = customer.id
      self.save(:validate => false)
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def update_customer_email(email)
      stripe_customer.email = email
      stripe_customer.save
      stripe_customer
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def save_card(card_token)
      card = stripe_customer.sources.create(card: card_token)
      stripe_customer.default_source = card_token
      stripe_customer.save
      self.default_card = card.fingerprint
      self.save(:validate => false)
    rescue Stripe::CardError => e
      raise CardError.new(e.message)
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def update_card(options = {})
      card = stripe_customer.sources.retrieve(default_source)
      attrs = [:name, :exp_month, :exp_year]

      attrs.each do |attr|
        card.send("#{attr}=".to_sym, options[attr]) if options[attr]
      end
      card.save
      card
    rescue Stripe::CardError => e
      raise CardError.new(e.message)
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def subscribe(plan, coupon = nil)
      subscription = stripe_customer.subscriptions.create(
        plan: plan,
        coupon: coupon
      )
      update!(
        coupon_code: coupon,
        plan: plan,
        current_period_start: subscription.current_period_start,
        current_period_end: subscription.current_period_end,
        subscription_id: subscription.id,
        state: subscription.status
      )
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def update_subscription(plan, coupon = nil)
      stripe_subscription.plan = plan
      stripe_subscription.coupon = coupon
      stripe_subscription.save(prorate: false)

      update(plan: plan, coupon_code: coupon)
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def cancel_subscription_at_period_end
      stripe_subscription.delete(at_period_end: true)
      update!(cancel_at_period_end: true)
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def cancel_subscription_now
      stripe_subscription.delete
      update!(
        current_period_end: Time.now.utc,
        state: 'canceled'
      )
    rescue Stripe::StripeError => e
      raise PaymentProcessingError.new(e.message)
    end

    def user
      OrganisationManager::User.find(user_id)
    end

    private

    def default_source
      stripe_customer.default_source
    end

    def stripe_customer
      Stripe::Customer.retrieve(customer_id.to_s)
    end

    def stripe_subscription
      stripe_customer.subscriptions.retrieve(subscription_id)
    end

    class Entity < Grape::Entity
      expose :id,
             :plan,
             :state
    end

  end
end
