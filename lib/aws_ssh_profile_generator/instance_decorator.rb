module AWSProfileGenerator
  class InstanceDecorator
    def initialize(generator, instance)
      @i = instance
      @gen = generator
    end

    def name
      tag("Name", @i.instance_id)
    end

    def tag(name, default = nil)
      result = (@i.tags.detect {|t| (t[:key] || "").downcase == name.downcase } || {})[:value]
      return default.to_s if !result or result.empty?
      result.to_s
    end

    def port
      22
    end

    def username
      @gen.user_for @i.image_id
    end

    def identity
      @gen.config["keys"].fetch(@i.key_name, "~/.ssh/#{@i.key_name}")
    end

    def method_missing(method, *args)
      @i.send method, *args
    end
  end
end