module AWSProfileGenerator
  module Renderers
    require_relative "./base"

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