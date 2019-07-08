require 'segment/analytics'

module Analytics

  Analytics = Segment::Analytics.new({
    write_key: Figaro.env.segment_write_key,
    on_error: Proc.new { |status, msg| print msg }
  })

  class UserData

    def initialize(user)
      @user = user
    end

    def track_event(event, event_properties = {}, user_properties = {})
      identify(user_properties)
      track(
        {
          user_id: @user.email,
          event: event,
          properties: event_properties
        }
      )
    end

    private

    def identify(user_properties)
      user_params = identify_params(user_properties)
      Analytics.identify(user_params)
    end

    def identify_params(user_properties)
      {
        user_id: @user.email,
        traits: user_traits.merge!(user_properties)
      }
    end

    def user_traits
      {
        name: @user.name,
        organisation: @user.organisation.name,
        role: @user.membership.role,
        organisation_plan: @user.plan,
        organisation_state: @user.state,
      }.reject { |key, value| value.nil? }
    end

    def track(options)
      Analytics.track(options)
    end

  end
end
