require 'net/http'
module CrunchLogerRailsClient
	class LogSubscriber < ActiveSupport::LogSubscriber
    def process_action event
    	binding.pry
      payload = event.payload
      param_method = payload[:params]['_method']
      method = param_method ? param_method.upcase : payload[:method]
      status = compute_status(payload)
      path = payload[:path]
      params = payload[:params]#.except(*INTERNAL_PARAMS)

      message = "%-6s #{status} #{path}" % method
      message << " parameters=#{params}" unless params.empty?
      uri = URI.parse("http://localhost:3001/logger_test")
      Net::HTTP.post_form(uri, {:api_key => "asdqwetgzvasd", :type => "rails_log", :event => event})
    end

    def compute_status payload
      status = payload[:status]
      if status.nil? && payload[:exception].present?
        exception_class_name = payload[:exception].first
        status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
      end
      status
    end

    def custom_log log
    	uri = URI.parse("http://localhost:3001/logger_test")
      Net::HTTP.post_form(uri, {:api_key => "asdqwetgzvasd", :type => "custom_log", :log => log})
    end
  end
end

CrunchLogerRailsClient::LogSubscriber.attach_to :action_controller