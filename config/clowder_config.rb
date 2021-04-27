require 'clowder-common-ruby'
require 'singleton'

class ClowderConfig
  include Singleton

  def self.instance
    @instance ||= {}.tap do |options|
      if ClowderCommonRuby::Config.clowder_enabled?
        config = ClowderCommonRuby::Config.load
      
        options["kafkaBrokers"] = [].tap do |brokers|
          config.kafka.brokers.each do |broker|
            brokers << "#{broker.hostname}:#{broker.port}"
          end
        end
     
        options["kafkaTopics"] = {}.tap do |topics|
          config.kafka.topics.each do |topic|
            topics[topic.requestedName] = topic.name
          end
        end
        Rails.logger.info("Kafka topics in cdappconfig: #{options["kafkaTopics"]}")

        options["endpoints"] = {}.tap do |endpoints|
          config.endpoints.each do |endpoint|
            endpoints["#{endpoint.app}-#{endpoint.name}"] = "http://#{endpoint.hostname}:#{endpoint.port}"
          end
        end
        Rails.logger.info("Endpoints in cdappconfig: #{options["endpoints"]}")
      else
        options["kafkaBrokers"] = ["#{ENV['QUEUE_HOST']}:#{ENV['QUEUE_PORT']}"]
        options["kafkaTopics"] = {}
      end

      ENV['RBAC_URL'] = options["endpoints"]["rbac-service"] if options["endpoints"]["rbac-service"].present?
      ENV['APPROVAL_URL'] = options["endpoints"]["approval-api"] if options["endpoints"]["approval-api"].present?
      ENV['SOURCES_URL'] = option["endpoints"]["sources-api-svc"] if options["endpoints"]["sources-api-svc"].present?
      ENV['CATALOG_INVENTORY_URL'] = options["endpoints"]["catalog-inventory-api"] if options["endpoints"]["catalog-inventory-api"].present?
    end
  end

  def self.queue_host
    instance["kafkaBrokers"].first.split(":").first || "localhost"
  end

  def self.queue_port
    instance["kafkaBrokers"].first.split(":").last || "9092"
  end
end

# ManageIQ Message Client depends on these variables
ENV["QUEUE_HOST"] = ClowderConfig.queue_host
ENV["QUEUE_PORT"] = ClowderConfig.queue_port
