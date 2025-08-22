# frozen_string_literal: true
module ::DiscourseShop
  module Payment
    class Gateway
      @providers = {}

      def self.register(name, klass)
        @providers[name.to_s] = klass
      end

      def self.for(name)
        @providers[name.to_s]
      end

      # A no-op gateway for development.
      class Noop
        def self.initiate(order:, return_url:, notify_url:, context: {})
          # Simulate an external payment URL that redirects back as success
          {
            ok: true,
            provider: "noop",
            redirect_url: "#{return_url}?order_id=#{order.id}&status=success"
          }
        end
      end
    end
  end
end

# Register the no-op gateway so flow works out-of-the-box
::DiscourseShop::Payment::Gateway.register("noop", ::DiscourseShop::Payment::Gateway::Noop)
