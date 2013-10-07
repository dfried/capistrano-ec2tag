require 'aws-sdk'
# require 'capistrano/ext/multistage'
unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ec2tag requires Capistrano >= 2'
end 

module Capistrano
  class Configuration
    module Tags
      def tag(rolename, *args)
        @ec2 ||= AWS::EC2.new({access_key_id: fetch(:aws_access_key_id), secret_access_key: fetch(:aws_secret_access_key)}.merge! fetch(:aws_params, {}))
        instances = @ec2.instances
        if stage
          instances = instances.filter('tag-key', 'environment').filter('tag-value', "#{stage}")
        end
        if fetch(:rolename_tag)
          instances = instances.filter('tag-key', fetch(:rolename_tag)).filter('tag-value', rolename)
        end
        instances.each do |instance|
          role(rolename, instance.dns_name || instance.ip_address, *args) if instance.status == :running
        end
      end
    end
    include Tags
  end
end
