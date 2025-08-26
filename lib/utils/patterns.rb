module Utils
  # A module that provides pattern matching functionality for file searching
  # and text processing.
  #
  # It includes classes for different types of pattern matching including fuzzy
  # matching and regular expression matching.
  module Patterns

    # Base class for pattern matching implementations.
    #
    # This class serves as the foundation for various pattern matching
    # strategies, providing common functionality for initializing patterns with
    # character set filtering and case sensitivity options. It handles the core
    # configuration and delegates specific matching behavior to subclasses.
    #
    # @abstract
    class Pattern
      # Initializes a new Pattern instance with the specified options.
      #
      # This method sets up the pattern configuration by storing the character
      # set, case sensitivity flag, and pattern string. It validates that a
      # pattern is provided and optionally filters the pattern characters based
      # on the specified character set.
      #
      # @param opts [ Hash ] a hash containing the pattern configuration options
      # @option opts [ String ] :cset the character set to filter pattern characters against
      # @option opts [ TrueClass, FalseClass ] :icase whether the pattern matching should be case sensitive
      # @option opts [ String ] :pattern the pattern string to be used for matching
      #
      # @raise [ ArgumentError ] if the pattern option is not provided
      def initialize(opts = {})
        @cset    = opts[:cset]
        @icase   = opts[:icase]
        @pattern = opts[:pattern] or
          raise ArgumentError, "pattern option required"
        @pattern = @pattern.gsub(/[^#{@cset}]/, '') if @cset
      end

      # Returns the matcher object used for pattern matching.
      #
      # @return [ Object ] the matcher object that handles pattern matching operations
      attr_reader :matcher

      # The method_missing method delegates calls to the matcher object while
      # handling UTF-8 encoding errors.
      #
      # This method acts as a fallback handler for undefined method calls,
      # forwarding them to the internal matcher object. It specifically catches
      # ArgumentError exceptions related to invalid byte sequences in UTF-8 and
      # re-raises them unless they match the expected error pattern.
      #
      # @param a [ Array ] the arguments passed to the missing method
      # @param b [ Proc ] the block passed to the missing method
      #
      # @return [ Object ] the result of the delegated method call on the matcher
      def method_missing(*a, &b)
        @matcher.__send__(*a, &b)
      rescue ArgumentError => e
        raise e unless e.message.include?('invalid byte sequence in UTF-8')
      end
    end

    # A fuzzy pattern matcher that performs partial string matching while
    # preserving character order.
    #
    # This class implements a pattern matching strategy that allows for
    # flexible matching of strings where the characters of the search pattern
    # appear in sequence within the target string, but not necessarily
    # consecutively. It is particularly useful for finding text patterns with
    # potential typos or
    # when only partial information about the target is available.
    #
    # @example
    #   fuzzy_pattern = FuzzyPattern.new(pattern: 'abc')
    #   fuzzy_pattern.match('a1b2c3') # => matches because 'a', 'b', and 'c' appear in order
    class FuzzyPattern < Pattern
      # Initializes a fuzzy pattern matcher by processing the pattern string
      # and compiling it into a regular expression.
      #
      # This method takes the configured pattern string and converts it into a
      # regular expression that can match strings in a fuzzy manner, allowing
      # for partial matches while preserving the order of characters. It
      # handles case sensitivity based on the configuration.
      #
      # @param opts [ Hash ] a hash containing the pattern configuration options
      # @option opts [ String ] :cset the character set to filter pattern characters against
      # @option opts [ TrueClass, FalseClass ] :icase whether the pattern matching should be case sensitive
      # @option opts [ String ] :pattern the pattern string to be used for matching
      def initialize(opts = {})
        super
        r = @pattern.split(//).grep(/[[:print:]]/).map { |x|
          "(#{Regexp.quote(x)})"
        } * '.*?'
        @matcher = Regexp.new(
          "\\A(?:.*/.*?#{r}|.*#{r})", @icase ? Regexp::IGNORECASE : 0
        )
      end
    end

    # A regular expression pattern matcher that performs exact string matching
    # with optional case sensitivity.
    #
    # This class extends the base Pattern class to provide functionality for
    # creating and using regular expression patterns. It compiles the provided
    # pattern into a Regexp object that can be used for matching operations
    # throughout the application. The pattern matching behavior is influenced
    # by the case sensitivity configuration inherited from the parent class.
    #
    # @example
    #   regexp_pattern = RegexpPattern.new(pattern: 'foo', icase: true)
    #   regexp_pattern.match('FOO') # => matches because case insensitive
    class RegexpPattern < Pattern
      # Initializes a regular expression pattern matcher with the specified
      # options.
      #
      # This method sets up a regular expression object based on the pattern
      # string and case sensitivity configuration that was previously
      # initialized in the parent class. It compiles the pattern into a Regexp
      # object that can be used for matching operations throughout the pattern
      # matching process.
      #
      # @param opts [ Hash ] a hash containing the pattern configuration options
      # @option opts [ String ] :cset the character set to filter pattern characters against
      # @option opts [ TrueClass, FalseClass ] :icase whether the pattern matching should be case sensitive
      # @option opts [ String ] :pattern the pattern string to be used for matching
      #
      # @return [ Regexp ] a compiled regular expression object ready for pattern matching operations
      def initialize(opts = {})
        super
        @matcher = Regexp.new(
          @pattern, @icase ? Regexp::IGNORECASE : 0
        )
      end
    end

    # Chooses and initializes a pattern matcher based on the provided argument
    # and options.
    #
    # This method selects between a regular expression pattern matcher and a
    # fuzzy pattern matcher depending on the value of the argument parameter
    # and the default configuration.
    # It validates that the argument is either 'r' (regexp) or 'f' (fuzzy) and
    # raises an error if an invalid value is provided.
    #
    # @param argument [ String ] the argument string that determines the pattern type
    # @param pattern_opts [ Hash ] the options to be passed to the pattern matcher constructor
    # @param default [ String ] the default pattern type to use when argument is nil or empty
    #
    # @return [ Utils::Patterns::Pattern ] a new instance of either RegexpPattern or FuzzyPattern
    #
    # @raise [ ArgumentError ] if the argument does not match 'r' or 'f' patterns and is not nil
    # @raise [ ArgumentError ] if the pattern option is not provided to the pattern matcher constructor
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
