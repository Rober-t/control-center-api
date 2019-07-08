class BillingManager
  class SubscriptionStateMachine
    include Statesman::Machine

    SHARED_STATES = [
      :updated_subscription,
      :canceled_subscription,
      :updated_customer_email,
      :updated_card,
      :updated_customer_via_webhook,
      :updated_subscription_via_webhook,
      :deleted_subscription_via_webhook,
      :expired_subscription,
      :deleted_subscription
    ]

    # States
    state :inactive, initial: true
    state :saved_card
    state :subscribed
    state :updated_subscription
    state :canceled_subscription
    state :deleted_subscription
    state :expired_subscription
    state :updated_customer_email
    state :updated_card
    state :updated_customer_via_webhook
    state :updated_subscription_via_webhook
    state :deleted_subscription_via_webhook

    # Transition Rules
    transition from: :inactive, to: [:subscribed, :saved_card, :deleted_subscription, :updated_subscription, :updated_customer_via_webhook, :updated_subscription_via_webhook, :deleted_subscription_via_webhook, :expired_subscription, :canceled_subscription, :updated_card, :updated_customer_email]
    transition from: :saved_card, to: :subscribed
    transition from: :subscribed, to: SHARED_STATES
    transition from: :updated_subscription, to: SHARED_STATES
    transition from: :canceled_subscription, to: :subscribed
    transition from: :updated_customer_email, to: SHARED_STATES
    transition from: :updated_card, to: SHARED_STATES
    transition from: :updated_customer_via_webhook, to: SHARED_STATES
    transition from: :updated_subscription_via_webhook, to: SHARED_STATES
    transition from: :deleted_subscription_via_webhook, to: :subscribed
    transition from: :expired_subscription, to: :subscribed

    # Callbacks
    before_transition(from: :inactive, to: :subscribed) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.create_customer(data[:email]) &&
      subscription.save_card(data[:card_token]) &&
      subscription.subscribe(data[:plan], data[:coupon])
    end

    before_transition(to: :saved_card) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.create_customer(data[:email]) &&
      subscription.save_card(data[:card_token])
    end

    before_transition(from: :saved_card, to: :subscribed) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.subscribe(data[:plan])
    end

    before_transition(to: :updated_subscription) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update_subscription(data[:plan], data[:coupon])
    end

    before_transition(to: :canceled_subscription) do |subscription, transition|
      subscription.cancel_subscription_at_period_end
    end

    before_transition(to: :deleted_subscription) do |subscription, transition|
      subscription.cancel_subscription_now
    end

    before_transition(to: :expired_subscription) do |subscription, transition|
      subscription.cancel_subscription_now
    end

    before_transition(from: :expired_subscription, to: :subscribed) do |subscription, transition|
      data = transition.metadata.symbolize_keys

      if data[:card_token]
        subscription.save_card(data[:card_token]) &&
        subscription.subscribe(data[:plan], data[:coupon])
      else
        subscription.subscribe(data[:plan], data[:coupon])
      end
    end

    before_transition(from: :canceled_subscription, to: :subscribed) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      if data[:card_token]
        subscription.save_card(data[:card_token]) &&
        subscription.subscribe(data[:plan], data[:coupon])
        subscription.update!(cancel_at_period_end: false)
      else
        subscription.subscribe(data[:plan], data[:coupon])
        subscription.update!(cancel_at_period_end: false)
      end
    end

    before_transition(to: :updated_customer_email) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update_customer_email(data[:email])
    end

    before_transition(to: :updated_card) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update_card(data[:card_attributes])
    end

    before_transition(to: :updated_customer_via_webhook) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update!(default_card: data[:default_card])
    end

    before_transition(to: :updated_subscription_via_webhook) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update!(
        plan: data[:payload][:plan][:id],
        current_period_start: data[:payload][:current_period_start],
        current_period_end: data[:payload][:current_period_start],
        cancel_at_period_end: data[:payload][:cancel_at_period_end],
        state: data[:payload][:status]
      )
    end

    before_transition(to: :deleted_subscription_via_webhook) do |subscription, transition|
      data = transition.metadata.symbolize_keys
      subscription.update!(
        plan: data[:payload][:plan][:id],
        current_period_start: data[:payload][:current_period_start],
        current_period_end: data[:payload][:current_period_start],
        cancel_at_period_end: data[:payload][:cancel_at_period_end],
        state: data[:payload][:status]
      )
    end

  end
end
