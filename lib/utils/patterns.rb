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

      attr_reader :matcher

      def method_missing(*a, &b)
        @matcher.__send__(*a, &b)
      rescue ArgumentError => e
        raise e unless e.message.include?('invalid byte sequence in UTF-8')
      end
    end

    class FuzzyPattern < Pattern
      def initialize(opts = {})
        super
        r = @pattern.split(//).grep(/[[:print:]]/).map { |x|
          "(#{Regexp.quote(x)})"
        } * '.*?'
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

    def choose(argument, pattern_opts, default: ?f)
      case argument
      when /^r/, (default == ?r ? nil : :not)
        RegexpPattern.new(pattern_opts)
      when /^f/, (default == ?f ? nil : :not)
        FuzzyPattern.new(pattern_opts)
      else
        raise ArgumentError, 'argument -p has to be f=fuzzy or r=regexp'
      end
    end
  end
end
