require 'tins'

# Configuration file manager for Utils library.
#
# This class provides functionality for loading, parsing, and managing
# configuration settings from multiple sources. It supports DSL-style
# configuration blocks and integrates with various utility components to
# provide centralized configuration management.
class Utils::ConfigFile
  class << self

    # The config_file_paths accessor method provides read and write access to
    # the config_file_paths instance variable.
    #
    # @return [ Array<String> ] the array of configuration file paths
    attr_accessor :config_file_paths
  end
  self.config_file_paths = [
    '/etc/utilsrc',
    '~/.utilsrc',
    './.utilsrc',
  ]

  include DSLKit::Interpreter

  # Error raised when configuration file parsing fails.
  #
  # This exception is specifically designed to be thrown when issues occur
  # during the parsing or processing of configuration files within the Utils
  # library. It inherits from StandardError, making it a standard Ruby
  # exception that can be caught and handled appropriately by calling code.
  class ConfigFileError < StandardError; end

  # The initialize method sets up a new instance of the class.
  #
  # This method is called when creating a new object and performs any necessary
  # initialization tasks for the instance variables and internal state.
  def initialize
  end

  # The configure_from_paths method initializes the configuration by parsing
  # configuration files from the specified paths.
  #
  # This method iterates through an array of configuration file paths and
  # processes each one to load the configuration settings. It is typically used
  # to set up the application's configuration from multiple sources.
  #
  # @param paths [ Array<String> ] an array of file paths pointing to configuration files
  def configure_from_paths(paths = self.class.config_file_paths)
    for config_file_path in paths
      parse_config_file config_file_path
    end
  end

  # The parse_config_file method reads and processes a configuration file.
  #
  # This method opens the specified configuration file, reads its contents,
  # and parses the configuration data. It handles file path expansion and
  # includes error handling for system call errors during file operations.
  #
  # @param config_file_path [ String ] the path to the configuration file to be parsed
  #
  # @return [ Utils::ConfigFile ] returns self after parsing the configuration file
  #
  # @raise [ SystemCallError ] if there is an issue reading the configuration file
  #
  # @note The method will output a warning message to standard error if it fails
  #       to read the configuration file and return nil.
  def parse_config_file(config_file_path)
    config_file_path = File.expand_path(config_file_path)
    File.open(config_file_path) do |cf|
      parse cf.read
    end
    self
  rescue SystemCallError => e
    $DEBUG and warn "Couldn't read config file "\
      "#{config_file_path.inspect}: #{e.class} #{e}"
    return nil
  end

  # The parse method processes the provided source code by interpreting it
  # within the given binding context.
  #
  # This method takes a source code string and evaluates it in the context of
  # the specified binding, allowing for dynamic execution of code with access
  # to the current variable scope.
  #
  # @param source [ String ] the source code to be interpreted and executed
  #
  # @return [ Object ] returns self after processing the source code
  def parse(source)
    interpret_with_binding source, binding
    self
  end

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

  # A configuration class for test execution settings.
  #
  # This class manages the configuration options related to running tests,
  # specifically supporting different test frameworks and defining which
  # directories should be included in test discovery and execution.
  class Probe < BlockConfig
    # The config method sets up a configuration option for the test framework.
    #
    # This method defines a configuration parameter that specifies which test
    # framework should be used, allowing for flexible test execution
    # environments.
    #
    # @param name [ Symbol ] the name of the configuration option
    # @param value [ Object ] the value to set for the configuration option
    config :test_framework, :'test-unit'

    # The include_dirs method configures the directories to be included in the
    # search.
    #
    # @param dirs [ Array<String> ] the array of directory names to include
    config :include_dirs, %w[lib test tests ext spec]

    # The include_dirs_argument method constructs a colon-separated string from
    # include directories.
    #
    # This method takes the include directories configuration and converts it
    # into a single colon-delimited string suitable for use in command-line
    # arguments or environment variables.
    #
    # @return [ String ] a colon-separated string of include directory paths
    def include_dirs_argument
      Array(include_dirs) * ':'
    end

    # The initialize method sets up the configuration by validating the test
    # framework.
    #
    # This method initializes the configuration object and ensures that the
    # specified test framework is one of the allowed values. It raises an error
    # if the test framework is not supported.
    #
    # @param block [ Proc ] a block to be passed to the superclass initializer
    def initialize(&block)
      super
      test_frameworks_allowed = [ :'test-unit', :rspec ]
      test_frameworks_allowed.include?(test_framework) or
        raise ConfigFileError,
          "test_framework has to be in #{test_frameworks_allowed.inspect}"
    end
  end

  # The probe method initializes and returns a Probe object.
  #
  # This method creates a new Probe instance either from the provided block or
  # with default settings, storing it for later use. It ensures that only one
  # Probe instance is created per object, returning the existing instance
  # on subsequent calls.
  #
  # @param block [ Proc ] optional block to configure the Probe instance
  #
  # @return [ Utils::Probe ] a Probe instance configured either by the block
  #         or with default settings
  def probe(&block)
    if block
      @probe = Probe.new(&block)
    end
    @probe ||= Probe.new
  end

  # A configuration class for file system operations.
  #
  # This class manages the configuration settings for searching and discovering
  # files and directories while filtering out unwanted entries based on
  # configured patterns. It provides functionality to define which directories
  # should be pruned and which files should be skipped during file system
  # operations.
  class FileFinder < BlockConfig
    # The prune? method checks if a basename matches any of the configured
    # prune directories.
    #
    # This method determines whether a given filename or directory name should
    # be excluded based on the prune directories configuration. It iterates
    # through the list of prune patterns and returns true if any pattern
    # matches the provided basename.
    #
    # @param basename [ String, Object ] the basename to check against prune patterns
    #
    # @return [ TrueClass, FalseClass ] true if the basename matches any prune pattern,
    #         false otherwise
    def prune?(basename)
      Array(prune_dirs).any? { |pd| pd.match(basename.to_s) }
    end

    # The skip? method determines whether a file should be skipped based on
    # configured patterns.
    #
    # This method checks if the provided basename matches any of the configured
    # skip patterns. It converts the basename to a string and tests it against
    # all defined skip files.
    #
    # @param basename [ Object] the file or directory name to check
    #
    # @return [ TrueClass, FalseClass ] true if the basename matches any skip
    # pattern, false otherwise
    def skip?(basename)
      Array(skip_files).any? { |sf| sf.match(basename.to_s) }
    end
  end

  # A configuration class for search operations.
  #
  # This class manages the configuration settings for searching files and
  # directories while filtering out unwanted entries based on configured
  # patterns. It inherits from FileFinder and provides functionality to define
  # which directories should be pruned and which files should be skipped during
  # search processes.
  class Search < FileFinder
    # The prune_dirs method configures the pattern for identifying directories
    # to be pruned during file system operations.
    #
    # This method sets up a regular expression pattern that matches directory
    # names which should be excluded from processing. The default pattern
    # excludes version control directories (.svn, .git, CVS) and temporary
    # directories (tmp).
    #
    # @param first [ Regexp ] the regular expression pattern for matching
    # directories to prune
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\z/

    # The skip_files configuration method sets up a regular expression pattern
    # for filtering out files based on their names.
    #
    # This method configures a pattern that matches filenames which should be
    # skipped during file processing operations.
    # It uses a regular expression to identify files that start with a dot, end
    # with common temporary file extensions, or match other patterns typically
    # associated with backup, swap, log, or temporary files.
    #
    # @param pattern [ Regexp ] the regular expression pattern used to identify
    # files to skip
    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
  end

  # The search method initializes and returns a Search object.
  #
  # This method creates a Search instance either from a provided block or with
  # default settings.
  # It maintains a cached instance of the Search object, returning the same
  # instance on subsequent calls.
  #
  # @param block [ Proc ] optional block to configure the Search object
  #
  # @return [ Utils::Search ] a Search object configured either by the provided
  # block or with default settings
  def search(&block)
    if block
      @search = Search.new(&block)
    end
    @search ||= Search.new
  end

  # A configuration class for file discovery operations.
  #
  # This class manages the configuration settings for discovering files and directories
  # while filtering out unwanted entries based on configured patterns. It inherits from
  # FileFinder and provides functionality to define which directories should be pruned
  # and which files should be skipped during discovery processes.
  class Discover < FileFinder
    # The prune_dirs method configures the pattern for identifying directories
    # to be pruned during file system operations.
    #
    # This method sets up a regular expression pattern that matches directory
    # names which should be excluded from processing.
    # The default pattern excludes version control directories (.svn, .git,
    # CVS) and temporary directories (tmp).
    #
    # @param first [ Regexp ] the regular expression pattern for matching
    # directories to prune
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\z/

    # The skip_files configuration method sets up a regular expression pattern
    # for filtering out files based on their names.
    #
    # This method configures a pattern that matches filenames which should be
    # skipped during file processing operations. It uses a regular expression
    # to identify files that start with a dot, end with common temporary file
    # extensions, or match other patterns typically associated with backup,
    # swap, log, or temporary files.
    #
    # @param pattern [ Regexp ] the regular expression pattern used to identify
    # files to skip
    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/

    # The config method sets up a configuration option with a default value.
    #
    # @param name [ Symbol ] the name of the configuration option
    # @param default [ Object ] the default value for the configuration option
    config :max_matches, 10

    # The index_expire_after method configures the expiration time for index
    # files.
    #
    # This method sets up the duration after which index files should be
    # considered expired and potentially refreshed or regenerated by the
    # system.
    #
    # @param value [ Integer, nil ] the number of seconds after which indexes expire,
    #                               or nil to disable automatic expiration
    config :index_expire_after
  end

  # The discover method initializes and returns a Discover object.
  #
  # This method sets up a Discover instance, either using a provided block for
  # configuration or creating a default instance. It ensures that only one
  # Discover object is created per instance by storing it in an instance
  # variable.
  #
  # @param block [ Proc ] optional block to configure the Discover object
  #
  # @return [ Utils::Discover ] a Discover object configured either with the
  # provided block or with default settings
  def discover(&block)
    if block
      @discover = Discover.new(&block)
    end
    @discover ||= Discover.new
  end

  # A configuration class for code indexing operations.
  #
  # This class manages the configuration settings for generating code indexes
  # like ctags and cscope. It provides functionality to define which paths
  # should be indexed and what file formats should be generated for each
  # indexing tool.
  #
  # @example
  #   indexer = Utils::ConfigFile.new.code_indexer do |config|
  #     config.paths = %w[ lib spec ]
  #     config.formats = { 'ctags' => 'tags', 'cscope' => 'cscope.out' }
  #   end
  #
  # The paths config configures the directories to be included in the index
  # generation process.
  #
  # The formats config configures the output file formats for different indexing
  # tools and the output filenames.
  class CodeIndexer < BlockConfig
    config :verbose, false

    lazy_config :paths do
      %w[ bin lib spec tests ]
    end

    config :formats, {
      'ctags'  => 'tags',
      'cscope' => 'cscope.out',
    }
  end

  # The code_indexer method manages and returns a CodeIndexer configuration
  # instance.
  #
  # This method provides access to a CodeIndexer object that handles configuration
  # for generating code indexes such as ctags and cscope files. It ensures that only
  # one CodeIndexer instance is created per object by storing it in an instance variable.
  # When a block is provided, it initializes the CodeIndexer with custom settings;
  # otherwise, it returns a default CodeIndexer instance.
  #
  # @param block [ Proc ] optional block to configure the CodeIndexer object
  #
  # @return [ Utils::ConfigFile::CodeIndexer ] a CodeIndexer configuration instance
  #         configured either by the block or with default settings
  def code_indexer(&block)
    if block
      @code_indexer = CodeIndexer.new(&block)
    end
    @code_indexer ||= CodeIndexer.new
  end

  # A configuration class for whitespace handling operations.
  #
  # This class manages the configuration options related to removing or modifying
  # trailing whitespace in files. It provides functionality to define patterns for
  # pruning directories and skipping specific files during whitespace processing,
  # ensuring that only relevant files are affected by space-stripping operations.
  class StripSpaces < FileFinder
    # The prune_dirs method configures the pattern for directory names that
    # should be pruned.
    #
    # This method sets up a regular expression pattern that identifies
    # directories which should be excluded or removed during file system
    # operations.
    #
    # @param pattern [ Regexp ] the regular expression pattern to match
    # directory names
    config :prune_dirs, /\A(\..*|CVS)\z/

    # The skip_files configuration method sets up a regular expression pattern
    # for filtering out files based on their names.
    #
    # This method configures a pattern that matches filenames which should be
    # skipped during file processing operations.
    # It uses a regular expression to identify files that start with a dot, end
    # with common temporary file extensions, or match other patterns typically
    # associated with backup, swap, log, or temporary files.
    #
    # @param pattern [ Regexp ] the regular expression pattern used to identify
    # files to skip
    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
  end

  # The strip_spaces method configures and returns a StripSpaces object for
  # processing whitespace.
  #
  # This method initializes a StripSpaces processor that can be used to remove
  # or modify whitespace in strings. When a block is provided, it sets up the
  # processor with custom behavior defined by the block. Otherwise, it returns
  # a default StripSpaces instance.
  #
  # @param block [ Proc ] optional block to customize the strip spaces behavior
  #
  # @return [ Utils::StripSpaces ] a configured StripSpaces processor instance
  def strip_spaces(&block)
    if block
      @strip_spaces = StripSpaces.new(&block)
    end
    @strip_spaces ||= StripSpaces.new
  end

  # SSH tunnel configuration manager
  #
  # Provides functionality for configuring and managing SSH tunnels with support for
  # different terminal multiplexers like tmux and screen. Allows setting up tunnel
  # specifications with local and remote address/port combinations, handling
  # environment variables, and managing copy/paste functionality for tunnel sessions.
  class SshTunnel < BlockConfig
    # The terminal_multiplexer method configures the terminal multiplexer
    # setting.
    #
    # This method sets up the terminal multiplexer that will be used for
    # managing multiple terminal sessions within the application environment.
    #
    # @param value [ String ] the name of the terminal multiplexer to use
    config :terminal_multiplexer, 'tmux'

    # The env method configures the environment variables for the session.
    #
    # @param value [ Hash ] environment variable hash
    config :env, {}

    # The login_session method configures the login session settings.
    #
    # @param block [ Proc ] a block containing the login session configuration
    config :login_session do
      ENV.fetch('HOME',  'session')
    end

    # The initialize method sets up the instance by calling the superclass
    # constructor and assigning the terminal multiplexer configuration.
    def initialize
      super
      self.terminal_multiplexer = terminal_multiplexer
    end

    # The terminal_multiplexer= method sets the terminal multiplexer type for
    # the editor.
    #
    # This method assigns the specified terminal multiplexer to the editor
    # configuration, validating that it is either 'screen' or 'tmux'. It
    # converts the input to a string and ensures it matches one of the
    # supported multiplexer types.
    #
    # @param terminal_multiplexer [ Symbol ] the terminal multiplexer type to
    # be configured
    def terminal_multiplexer=(terminal_multiplexer)
      @multiplexer = terminal_multiplexer.to_s
      @multiplexer =~ /\A(screen|tmux)\z/ or
        fail "invalid terminal_multiplexer #{terminal_multiplexer.inspect} was configured"
    end

    # The multiplexer_list method returns the appropriate command string for
    # listing sessions based on the current multiplexer type.
    #
    # @return [ String, nil ] the command string to list sessions for the configured
    #         multiplexer ('screen -ls' or 'tmux ls'), or nil if no multiplexer is set
    def multiplexer_list
      case @multiplexer
      when 'screen'
        'screen -ls'
      when 'tmux'
        'tmux ls'
      end
    end

    # The multiplexer_new method generates a command string for creating a new
    # session in the specified terminal multiplexer.
    #
    # @param session [ String ] the name of the session to be created
    #
    # @return [ String, nil ] a command string for creating a new session in screen
    #         or tmux, or nil if the multiplexer type is not supported
    def multiplexer_new(session)
      case @multiplexer
      when 'screen'
        'false'
      when 'tmux'
        'tmux -u new -s "%s"' % session
      end
    end

    # The multiplexer_attach method generates a command string for attaching to
    # a session using either screen or tmux multiplexer.
    #
    # @param session [ String ] the name or identifier of the session to attach to
    #
    # @return [ String ] a formatted command string ready for execution
    def multiplexer_attach(session)
      case @multiplexer
      when 'screen'
        'screen -DUR "%s"' % session
      when 'tmux'
        'tmux -u attach -d -t "%s"' % session
      end
    end

    # Manages the copy/paste functionality configuration for SSH tunnels.
    #
    # This class handles the setup and configuration of copy/paste capabilities
    # within SSH tunnel sessions, allowing users to define network addresses,
    # ports, and other parameters needed for establishing and managing
    # copy/paste connections through SSH tunnels.
    class CopyPaste < BlockConfig
      # The bind_address method configures the network address to which the
      # server will bind for incoming connections.
      #
      # @param value [ String ] the IP address or hostname to bind the server to
      config :bind_address, 'localhost'

      # The port method configures the port number for the SSH tunnel
      # specification.
      #
      # This method sets up the port component of an SSH tunnel configuration,
      # allowing for the specification of a network port to be used in the
      # tunnel.
      #
      # @param name [ String ] the name of the port configuration
      # @param default [ Integer ] the default port number to use if none is specified
      config :port, 6166

      # The host method configures the hostname for the SSH tunnel specification.
      #
      # This method sets up the host parameter that will be used in the SSH tunnel
      # configuration, allowing connections to be established through the specified
      # host address.
      #
      # @param value [ String ] the hostname or IP address to use for the SSH tunnel
      config :host, 'localhost'

      # The host_port method configures the host port setting for the
      # application.
      #
      # @param value [ Integer ] the port number to be used for host communication
      config :host_port, 6166

      # The to_s method returns a colon-separated string representation of the
      # SSH tunnel specification.
      #
      # This method combines the bind address, port, host, and host port components
      # into a single string format using colons as separators.
      #
      # @return [ String ] a colon-separated string containing the tunnel specification
      #         in the format "bind_address:port:host:host_port"
      def to_s
        [ bind_address, port, host, host_port ] * ':'
      end
    end

    # The copy_paste method manages the copy-paste functionality by returning
    # an existing instance or creating a new one.
    #
    # This method checks if a copy-paste instance already exists and returns it
    # if available. If no instance exists, it creates a new one based on
    # whether a block is provided or
    # the enable flag is set to true.
    #
    # @param enable [ TrueClass, FalseClass ] flag to enable copy-paste functionality
    #
    # @yield [ block ] optional block to initialize the copy-paste instance
    #
    # @return [ CopyPaste, nil ] the existing or newly created copy-paste
    # instance, or nil if not enabled
    def copy_paste(enable = false, &block)
      if @copy_paste
        @copy_paste
      else
        if block
          @copy_paste = CopyPaste.new(&block)
        elsif enable
          @copy_paste = CopyPaste.new {}
        end
      end
    end
    self.config_settings << :copy_paste
  end

  # The ssh_tunnel method provides access to an SSH tunnel configuration instance.
  #
  # This method returns the existing SSH tunnel configuration object if one has
  # already been created, or initializes and returns a new SSH tunnel
  # configuration instance if no instance exists. If a block is provided, it
  # will be passed to the SSH tunnel configuration constructor when creating a
  # new instance.
  #
  # @param block [ Proc ] optional block to configure the SSH tunnel object
  #
  # @return [ Utils::ConfigFile::SshTunnel ] an SSH tunnel configuration instance
  def ssh_tunnel(&block)
    if block
      @ssh_tunnel = SshTunnel.new(&block)
    end
    @ssh_tunnel ||= SshTunnel.new
  end

  # A configuration class for editor settings.
  #
  # This class manages the configuration options related to editing operations,
  # specifically focusing on Vim editor integration. It provides functionality
  # to configure the path to the Vim executable and default arguments used when
  # invoking the editor.
  class Edit < BlockConfig
    # The vim_path method determines the path to the vim executable.
    #
    # This method executes the which command to locate the vim executable in
    # the system's PATH and returns the resulting path after stripping any
    # trailing whitespace.
    #
    # @return [ String ] the full path to the vim executable as determined by the which command
    config :vim_path do `which vim`.chomp end

    config :vim_default_args, nil
  end

  # The edit method initializes and returns an Edit object.
  #
  # This method creates an Edit instance either from a provided block or with
  # default settings. It stores the Edit object as an instance variable and
  # returns it on subsequent calls.
  #
  # @param block [ Proc ] optional block to configure the Edit object
  #
  # @return [ Edit ] an Edit object configured either by the block or with default settings
  def edit(&block)
    if block
      @edit = Edit.new(&block)
    end
    @edit ||= Edit.new
  end

  # A configuration class for file classification settings.
  #
  # This class manages the configuration options related to classifying files
  # by type or category. It provides functionality to define path shifting
  # behavior and prefix handling for determining how file paths should be
  # categorized during classification operations.
  class Classify < BlockConfig
    # The shift_path_by_default method configuration accessor
    #
    # This method provides access to the shift_path_by_default configuration
    # setting which determines the default path shifting value used in various
    # operations.
    #
    # @return [ Integer ] the default path shifting value configured for the system
    config :shift_path_by_default, 0

    # The shift_path_for_prefix method configures path shifting behavior for
    # prefix handling.
    #
    # This method sets up the configuration for how paths should be shifted
    # when dealing with prefix-based operations, typically used in file system
    # or directory navigation contexts.
    #
    # @param config [ Array ] the configuration array for shift path settings
    config :shift_path_for_prefix, []
  end

  # The classify method initializes and returns a Classify object.
  #
  # This method creates a Classify instance either from the provided block or
  # with default settings if no block is given. It ensures that only one
  # Classify object is created per instance by storing it in an instance variable.
  #
  # @param block [ Proc ] optional block to configure the Classify object
  #
  # @return [ Classify ] a Classify object configured either by the block or with defaults
  def classify(&block)
    if block
      @classify = Classify.new(&block)
    end
    @classify ||= Classify.new
  end

  # A configuration class for directory synchronization settings.
  #
  # This class manages the configuration options related to synchronizing
  # directories using rsync. It provides functionality to define patterns for
  # skipping certain paths during synchronization operations, making it easy to
  # exclude temporary, cache, or version control files from being synced.
  class SyncDir < BlockConfig
    # The skip_path method configures a regular expression pattern for skipping
    # paths.
    #
    # This method sets up a configuration option that defines a regular
    # expression used to identify and skip certain paths during processing
    # operations.
    #
    # @param pattern [ Regexp ] the regular expression pattern used to match
    # paths to be skipped
    config :skip_path, %r((\A|/)\.\w)

    # The skip? method determines whether a given path should be skipped based
    # on the skip_path pattern.
    #
    # This method checks if the provided path matches the internal skip_path
    # regular expression, returning true if the path should be excluded from
    # processing, or false otherwise.
    #
    # @param path [ String ] the path to check against the skip pattern
    #
    # @return [ TrueClass, FalseClass ] true if the path matches the skip
    # pattern, false otherwise
    def skip?(path)
      path =~ skip_path
    end
  end

  # The sync_dir method provides access to a SyncDir instance.
  #
  # This method returns the existing SyncDir instance if one has already been
  # created, or initializes and returns a new SyncDir instance if no instance
  # exists. If a block is provided, it will be passed to the SyncDir constructor
  # when creating a new instance.
  #
  # @return [ SyncDir ] the SyncDir instance associated with this object
  def sync_dir(&block)
    if block
      @sync_dir = SyncDir.new(&block)
    end
    @sync_dir ||= SyncDir.new
  end

  # A configuration class for code comment settings.
  #
  # This class manages the configuration options related to generating YARD
  # documentation for Ruby source code. It provides access to glob patterns
  # that define which files should be considered when generating code comments.
  class CodeComment < BlockConfig
    dsl_accessor :code_globs, 'lib/**/*.rb', 'spec/**/*.rb', 'tests/**/*rb'
  end

  # The code_comment method provides access to a CodeComment configuration
  # instance.
  #
  # This method returns the existing CodeComment instance if one has already
  # been created, or initializes and returns a new CodeComment instance if no
  # instance exists. If a block is provided, it will be passed to the
  # CodeComment constructor when creating a new instance.
  #
  # @param block [ Proc ] optional block to configure the CodeComment object
  #
  # @return [ Utils::ConfigFile::CodeComment ] a CodeComment configuration instance
  def code_comment(&block)
    if block
      @code_comment = CodeComment.new(&block)
    end
    @code_comment ||= CodeComment.new
  end

  # The to_ruby method generates a Ruby configuration string by collecting
  # configuration data from various components and combining them into a
  # single formatted output.
  #
  # @return [ String ] a Ruby formatted string containing configuration
  #         settings from search, discover, strip_spaces, probe, ssh_tunnel,
  #         edit, and classify components
  def to_ruby
    result = "# vim: set ft=ruby:\n"
    for bc in %w[search discover strip_spaces probe ssh_tunnel edit classify]
      result << "\n" << __send__(bc).to_ruby
    end
    result
  end
end
