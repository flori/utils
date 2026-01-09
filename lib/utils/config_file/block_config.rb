class Utils::ConfigFile
  # Base class for defining configuration blocks with DSL accessors.
  #
  # This class provides a foundation for creating configuration classes that
  # support dynamic attribute definition through DSL-style accessor methods. It
  # includes functionality for registering configuration settings and
  # generating Ruby code representations of the configuration state.
  class BlockConfig
    class << self
      # The inherited method extends the module with DSL accessor functionality
      # and calls the superclass implementation.
      #
      # @param modul [ Module ] the module that inherited this class
      def inherited(modul)
        modul.extend DSLKit::DSLAccessor
        super
      end

      # The config method sets up a configuration accessor with the specified
      # name and options.
      #
      # This method registers a new configuration setting by adding it to the
      # list of configuration settings and then creates an accessor for it
      # using the dsl_accessor method, allowing for easy retrieval and
      # assignment of configuration values.
      #
      # @param name [ Object ] the name of the configuration setting
      # @param r [ Array ] additional arguments passed to the dsl_accessor method
      #
      # @yield [ block ] optional block to be passed to the dsl_accessor method
      #
      # @return [ Object ] returns self to allow for method chaining
      def config(name, *r, &block)
        self.config_settings ||= []
        config_settings << name.to_sym
        dsl_accessor name, *r, &block
        self
      end

      # The lazy_config method configures a lazy-loaded configuration option
      # with a default value.
      #
      # This method registers a new configuration setting that will be
      # initialized lazily, meaning the default value or the set value is only
      # computed when the configuration is actually accessed. It adds the
      # setting to the list of configuration settings and creates a lazy
      # accessor for it.
      #
      # @param name [ Object ] the name of the configuration setting to define
      # @yield [ default ] optional block that provides the default value for
      # the configuration
      #
      # @return [ Object ] returns self to allow for method chaining
      def lazy_config(name, &default)
        self.config_settings ||= []
        config_settings << name.to_sym
        dsl_lazy_accessor(name, &default)
        self
      end

      # The config_settings method provides access to the configuration
      # settings.
      #
      # This method returns the configuration settings stored in the instance
      # variable, allowing for reading and modification of the object's
      # configuration state.
      #
      # @return [ Object ] the current configuration settings stored in the
      # instance variable
      attr_accessor :config_settings
    end

    # The initialize method sets up the instance by evaluating the provided
    # block in the instance's context.
    #
    # This method allows for dynamic configuration of the object by executing
    # the given block within the instance's scope, enabling flexible
    # initialization patterns.
    #
    # @param block [ Proc ] the block to be evaluated for instance setup
    def initialize(&block)
      block and instance_eval(&block)
    end

    # The to_ruby method generates a Ruby configuration block representation by
    # recursively processing the object's configuration settings and their
    # values.
    # It creates a nested structure with proper indentation and formatting
    # suitable for configuration files.
    #
    # @param depth [ Integer ] the current nesting depth for indentation purposes
    #
    # @return [ String ] a formatted Ruby string representing the configuration block
    def to_ruby(depth = 0)
      result = ''
      result << ' ' * 2 * depth <<
        "#{self.class.name[/::([^:]+)\z/, 1].underscore} do\n"
      for name in self.class.config_settings
        value = __send__(name)
        if value.respond_to?(:to_ruby)
          result << ' ' * 2 * (depth + 1) << value.to_ruby(depth + 1)
        else
          result << ' ' * 2 * (depth + 1) <<
            "#{name} #{Array(value).map(&:inspect) * ', '}\n"
        end
      end
      result << ' ' * 2 * depth << "end\n"
    end
  end
end
