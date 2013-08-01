module Roadworker
  class HealthCheck

    class << self
      def health_checks(route53)
        self.new(route53).health_checks
      end

      def config_to_hash(config)
        ipaddr = config[:ip_address]
        port   = config[:port]
        type   = config[:type].downcase
        path   = config[:resource_path]
        fqdn   = config[:fully_qualified_domain_name].downcase

        url = "#{type}://#{ipaddr}:#{port}"
        url << path if path && path != '/'

        {:url => url, :host_name => fqdn}
      end
    end # of class method

    def initialize(route53)
      @route53 = route53
    end

    def health_checks
      check_list = {}

      is_truncated = true
      next_marker = nil

      while is_truncated
        options = next_marker ? {:marker => next_marker} : {}
        response = @route53.client.list_health_checks(options)

        response[:health_checks].each do |check|
          check_list[check[:id]] = check[:health_check_config]
        end

        is_truncated = response[:is_truncated]
        next_marker = [:next_marker]
      end

      return check_list
    end

  end # HealthCheck
end # Roadworker
