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
          out = File.expand_path @config["output"]
          FileUtils.mkdir_p File.dirname(out)
          open(out, "w") {|fp| fp.puts @buffer }
          puts "Write SSH config to #{out}"
        else
          puts @buffer
        end
      end

      def render(instance)
        return unless instance.public_interface
        @buffer << @template.result(binding)
      end

      def connection_name_for(name)
        ordinal_name_for name.downcase.strip.gsub(/[^a-z0-9_-]/, "-").squeeze("-").gsub(/\-*$/, "")
      end
    end
  end
end
