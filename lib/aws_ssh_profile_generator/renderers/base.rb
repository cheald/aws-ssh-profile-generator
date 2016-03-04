module AwsSshProfileGenerator
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
  end
end