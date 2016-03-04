module AwsSshProfileGenerator
  module Renderers
    require_relative "./base"

    class SSHConfig < Base
      def setup
        @buffer = ""
        @template = ERB.new open(@config["template"]).read
      end

      def finish
        if @config.key?("output")
          FileUtils.mkdir_p File.dirname(@config["output"])
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
  end
end