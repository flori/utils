module Utils
  module Patterns
    class Pattern
      def initialize(opts = {})
        @cset    = opts[:cset]
        @icase   = opts[:icase]
        @pattern = opts[:pattern] or
          raise ArgumentError, "pattern option required"
        @pattern = @pattern.gsub(/[^#{@cset}]/, '') if @cset
      end

      def method_missing(*a, &b)
        @matcher.__send__(*a, &b)
      end
    end

    class FuzzyPattern < Pattern
      def initialize(opts ={})
        super
        r        = @pattern.split(//).map { |x| "(#{Regexp.quote(x)})" } * '.*?'
        @matcher = Regexp.new(
          "\\A(?:.*/.*?#{r}|.*#{r})",
          @icase ? Regexp::IGNORECASE : 0)
      end
    end

    class RegexpPattern < Pattern
      def initialize(opts = {})
        super
        @matcher = Regexp.new(@pattern, @icase ? Regexp::IGNORECASE : 0)
      end
    end
  end
end
