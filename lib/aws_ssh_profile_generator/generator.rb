require_relative "./instance_decorator"

module AwsSshProfileGenerator
  class Generator
    attr_reader :config, :images
    def initialize(config)
      @config = YAML.load open("config.yml", "r").read
      @renderers = @config["renderers"].map do |name, config|
        if Renderers.const_defined?(name)
          Renderers.const_get(name).new(self, config)
        else
          nil
        end
      end.compact.select(&:enabled?)
    end

    def run!
      @renderers.each(&:setup)
      @config["regions"].each {|r| get_region r }
      @renderers.each(&:finish)
    end

    def get_region(region)
      ec2 = Aws::EC2::Client.new(region: region)
      instances = ec2.describe_instances(filters: @config["query_filters"])
      all_instances = instances.reservations.flat_map(&:instances)
      @all_images = ec2.describe_images image_ids: all_instances.map(&:image_id).uniq
      @images = @all_images[:images].each_with_object({}) {|i, o| o[i.image_id] = i }
      all_instances.each {|i| parse i }
    end

    def parse(instance)
      @renderers.each {|r| r.render InstanceDecorator.new(self, instance) }
    end

    def user_for(image_id)
      @config["users"].each do |user|
        if @images[image_id] && @images[image_id].name.match(user["match"])
          return user["user"]
        end
      end
      "ec2-user"
    end
  end
end