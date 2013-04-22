require 'aws-sdk'
# require 'capistrano/ext/multistage'
unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ec2tag requires Capistrano >= 2'
end

module Capistrano
  class Configuration
    module Tags

      def tag(environment, server_type, *args)
        @ec2 ||= AWS::EC2.new({access_key_id: fetch(:aws_access_key_id), secret_access_key: fetch(:aws_secret_access_key)}.merge! fetch(:aws_params, {}))
        @ec2.instances.filter('tag-key', 'environment').filter('tag-value', environment).filter('tag-key', 'server_type').filter('tag-value', server_type).each do |instance|
          server instance.dns_name || instance.ip_address, *args if instance.status == :running
        end
      end

    end

    include Tags
  end
end
