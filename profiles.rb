require 'bundler/setup'
require 'aws-sdk'
require 'awesome_print'
require 'set'
require 'yaml'
require 'erb'
require 'fileutils'
require 'uri'

module AWSProfileGenerator
  class Generator
    attr_reader :config, :images
    def initialize(config)
      @config = YAML.load open("config.yml", "r").read
      @renderers = @config["renderers"].map do |name, config|
        Renderers.const_get(name).new(self, config)
      end.select(&:enabled?)
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
      @renderers.each {|r| r.render Instance.new(self, instance) }
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

  class Instance
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

  module Renderers
    class Base
      def initialize(gen, config)
        @gen = gen
        @config = config
        @used_names = Set.new
      end

      def setup; end
      def finish; end
      def render(instance); end
      def enabled?
        @config.fetch("enable", true)
      end

      def ordinal_name_for(name)
        orig_name = name
        ord = 0
        while @used_names.include?(name)
          ord += 1
          name = "#{orig_name}-#{ord}"
        end
        @used_names.add name
        name
      end
    end

    class SSHConfig < Base
      def setup
        @buffer = ""
        @template = ERB.new open(@config["template"]).read
      end

      def finish
        if @config.key?("output")
          open(@config["output"], "w") {|fp| fp.puts @buffer }
          puts "Write SSH config to #{@config["output"]}"
        else
          puts @buffer
        end
      end

      def render(instance)
        @buffer << @template.result(binding)
      end

      def connection_name_for(name)
        ordinal_name_for name.downcase.strip.gsub(/[^a-z0-9_-]/, "-").squeeze("-")
      end
    end

    class KiTTY < Base
      def setup
        @structure = ["_root"] + @config.fetch("structure", "").split(/[\\\/:]/)
        @basepath = File.expand_path @config["directory"]
        FileUtils.mkdir_p @basepath
        @template = ERB.new open(@config["template"]).read
      end

      def finish
      end

      def encode(str)
        URI.encode(str).gsub(/[\/:]/, "-")
      end

      def render(instance)
        result = @template.result(binding)
        files_for instance do |f|
          open(f, "w") {|fp| fp.puts result }
          puts "Wrote to #{f}"
        end
      end

      def files_for(instance)
        permute instance, @structure, true do |f|
          f.shift
          dir = File.join(@basepath, *f)
          FileUtils.mkdir_p(dir)
          yield ordinal_name_for File.join(dir, encode(instance.name))
        end
      end

      def permute(instance, keys, top = false)
        return nil if keys.empty?
        keys = keys.dup
        key = keys.shift
        vals = if key.match(/^\$(.*)/)
          key = key.gsub(/^\$/, "")
          (instance.tag(key) || (instance.respond_to?(key) ? instance.send(key) : "")).split(",").map(&:strip)
        else
          [key]
        end

        vals.map do |val|
          result = [val, permute(instance, keys)]
          yield result.flatten.compact if top
          result
        end
      end
    end
  end
end

AWSProfileGenerator::Generator.new("config.yml").run!