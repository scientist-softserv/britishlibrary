module IrusAnalytics
  module Controller
    module AnalyticsBehaviour

      def remote_ip
        ENV['LOAD_BALANCER_IP'] || request.remote_ip
      end
    end
  end
end
