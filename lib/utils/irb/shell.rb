# A module that extends Regexp functionality with additional pattern
# matching and display capabilities.
#
# Provides enhanced regexp operations including match highlighting and
# shell command integration.
module Utils::IRB::Shell
  include SearchUI
  include FileUtils
  include Tins::Find

  # The receiver_unless_main method retrieves the receiver name of a method
  # unless it is the main object, optionally executing a block with the
  # receiver name.
  #
  # @param method [ Method ] the method object to inspect
  # @param block [ Proc ] an optional block to execute with the receiver name
  #
  # @return [ String, nil ] the receiver name if it is not 'main', otherwise nil
  def receiver_unless_main(method, &block)
    receiver_name = method.receiver.to_s
    if receiver_name != 'main'
      if block
        block.(receiver_name)
      else
        receiver_name
      end
    end
  end
  private :receiver_unless_main

  # The ri method invokes the ri documentation tool to display help
  # information for the specified patterns. It automatically determines the
  # pattern to search for when none are provided.
  # The method handles different types of patterns including modules,
  # objects that respond to to_str, and other objects. Documentation is
  # displayed through the system's ri command with output piped to the
  # pager.
  #
  # @param patterns [ Array ] the patterns to search for in the documentation
  # @param doc [ String ] the documentation command to execute (defaults to 'ri')
  def ri(*patterns, doc: 'ri')
    patterns.empty? and
      receiver_unless_main(method(__method__)) do |pattern|
        return ri(pattern, doc: doc)
      end
    patterns.map! { |p|
      case
      when Module === p
        p.name
      when p.respond_to?(:to_str)
        p.to_str
      else
        p.class.name
      end
    }
    system "#{doc} #{patterns.map { |p| "'#{p}'" } * ' ' } | #$pager"
  end

  # The yri method invokes the ri documentation tool with yri as the
  # documenter to display help information for the specified patterns.
  #
  # @param patterns [ Array<String> ] the patterns to look up documentation for
  def yri(*patterns)
    ri(*patterns, doc: 'yri')
  end

  # The ai method interacts with an Ollama chat service to process queries
  # and optionally return responses.
  #
  # This method constructs command-line arguments for the ollama_chat_send
  # utility based on the provided options, executes the command with the
  # query as input, and returns the response if requested.
  #
  # @param query [ String ] the input query to send to the Ollama chat
  #   service
  # @param command [ TrueClass, FalseClass ] whether to treat the query as
  #   a command
  # @param respond [ TrueClass, FalseClass ] whether to capture and return
  #   the response from the service
  # @param parse [ TrueClass, FalseClass ] whether to parse the response
  # @param dir [ String ] the directory to use for the operation
  #
  # @return [ String, nil ] the response from the Ollama chat service if
  #   respond is true, otherwise nil
  def ai(query, command: false, respond: false, parse: false, dir: ?.)
    dir = File.expand_path(dir)
    args = {
      ?r => respond,
      ?t => command,
      ?p => parse,
      ?d => dir,
    }
    args = args.map { |k, v|
      v == false and next
      v == true ? "-#{k}" : [ "-#{k}", v.to_s ]
    }.flatten.compact
    args.unshift 'ollama_chat_send'
    response = nil
    IO.popen(Shellwords.join(args), 'r+') do |io|
      io.write query
      io.close_write
      if respond
        response = io.read
      end
    end
    response
  end

  # The irb_open method opens a URL or executes a block to capture output
  # and open it.
  #
  # This method provides a way to open URLs or capture the output of a
  # block and open it in the default application. If a URL is provided, it
  # directly opens the URL. If a block is given, it captures the output of
  # the block, writes it to a temporary file, and opens that file. If
  # neither is provided, it raises an error.
  #
  # @param url [ String, nil ] the URL to open
  # @param block [ Proc, nil ] the block to capture output from
  def irb_open(url = nil, &block)
    case
    when url
      system 'open', url
    when block
      Tempfile.open('wb') do |t|
        t.write capture_output(&block)
        t.rewind
        system 'open', t.path
      end
    when url = receiver_unless_main(method(__method__))
      irb_open url
    else
      raise ArgumentError, 'need an url or block'
    end
  end

  # This method obtains the complete list of instance methods available for
  # the specified object's class, then processes them through the
  # irb_wrap_methods helper to prepare them for interactive use in IRB.
  #
  # @param obj [ Object ] the object whose class instance methods are to be retrieved
  #
  # @return [ Array ] an array of wrapped method objects suitable for IRB interaction
  def irb_all_class_instance_methods(obj = self)
    methods = obj.class.instance_methods
    irb_wrap_methods obj, methods
  end

  # The irb_class_instance_methods method retrieves instance methods
  # defined directly in the class of the given object, excluding inherited
  # methods, and wraps them for enhanced interactive exploration in IRB
  # environment.
  #
  # @param obj [ Object ] the object whose class instance methods are to be retrieved
  #
  # @return [ Array ] an array of wrapped method objects suitable for IRB interaction
  def irb_class_instance_methods(obj = self)
    methods = obj.class.instance_methods(false)
    irb_wrap_methods obj, methods
  end

  # The irb_all_instance_methods method retrieves all instance methods
  # defined on a module.
  #
  # This method collects the instance methods from the specified module and
  # wraps them for enhanced interactive exploration in IRB. It is designed
  # to provide a more user-friendly interface for examining module methods
  # within the interactive Ruby environment.
  #
  # @param modul [ Object ] the module from which to retrieve instance methods
  #
  # @return [ Array ] an array of wrapped method objects suitable for IRB interaction
  def irb_all_instance_methods(modul = self)
    methods = modul.instance_methods
    irb_wrap_methods modul, methods, true
  end

  # Return instance methods defined in module modul without the inherited/mixed
  # in methods.
  # The irb_instance_methods method retrieves instance methods defined directly in a module.
  #
  # This method fetches all instance methods that are explicitly defined within the specified module,
  # excluding inherited methods. It then wraps these methods for enhanced interactive exploration
  # within the IRB environment.
  #
  # @param modul [ Object ] the module from which to retrieve instance methods
  #
  # @return [ Array ] an array of wrapped method objects suitable for IRB interaction
  def irb_instance_methods(modul = self)
    methods = modul.instance_methods(false)
    irb_wrap_methods modul, methods, true
  end

  # The irb_all_methods method retrieves all methods available on an
  # object.
  #
  # This method collects all methods associated with the given object
  # (including its singleton methods) and wraps them for enhanced
  # interactive exploration in IRB. It provides a comprehensive list
  # of methods that can be used to understand the object's capabilities and
  # interface.
  #
  # @param obj [ Object ] the object whose methods are to be retrieved
  #
  # @return [ Array ] an array of wrapped method objects for interactive use
  def irb_all_methods(obj = self)
    methods = obj.methods
    irb_wrap_methods obj, methods
  end

  # The irb_methods method retrieves instance methods defined in the class
  # hierarchy excluding those inherited from ancestor classes.
  #
  # This method computes a list of instance methods that are directly
  # defined in the class of the given object, excluding any methods that
  # are inherited from its superclass or modules. It then wraps these
  # methods for enhanced display in IRB.
  #
  # @param obj [ Object ] the object whose class methods are to be examined
  #
  # @return [ Array ] an array of wrapped method objects for display in IRB
  def irb_methods(obj = self)
    methods = obj.class.ancestors[1..-1].inject(obj.methods) do |all, a|
      all -= a.instance_methods
    end
    irb_wrap_methods obj, methods
  end

  # The irb_singleton_methods method retrieves singleton methods associated
  # with an object.
  #
  # This method collects all singleton methods defined on the specified object,
  # excluding inherited methods, and prepares them for display in an interactive
  # Ruby environment.
  #
  # @param obj [ Object ] the object whose singleton methods are to be retrieved
  #
  # @return [ Array ] an array of singleton method names associated with the object
  def irb_singleton_methods(obj = self)
    irb_wrap_methods obj, obj.methods(false)
  end

  # The irb_wrap_methods method creates wrapped method objects for introspection.
  #
  # This method takes a set of method names and wraps them in a way that allows
  # for easier inspection and display within an IRB session. It handles
  # potential errors during the wrapping process by rescuing exceptions and
  # filtering out invalid entries.
  #
  # @param obj [ Object ] the object whose methods are being wrapped
  # @param methods [ Array ] the array of method names to wrap
  # @param modul [ TrueClass, FalseClass ] flag indicating if the methods are module methods
  #
  # @return [ Array ] an array of wrapped method objects sorted in ascending order
  def irb_wrap_methods(obj = self, methods = methods(), modul = false)
    methods.map do |name|
      MethodWrapper.new(obj, name, modul) rescue nil
    end.compact.sort!
  end

  # Base class for wrapping objects with descriptive metadata.
  #
  # This class provides a foundation for creating wrapper objects that
  # associate descriptive information with underlying objects. It handles
  # name conversion and provides common methods for accessing and comparing
  # wrapped objects.
  class WrapperBase
    include Comparable

    # The initialize method sets up the instance name by converting the
    # input to a string representation.
    #
    # This method handles different input types by converting them to a
    # string, prioritizing to_str over to_sym and falling back to to_s if
    # neither is available.
    #
    # @param name [ Object ] the input name to be converted to a string
    def initialize(name)
      @name =
        case
        when name.respond_to?(:to_str)
          name.to_str
        when name.respond_to?(:to_sym)
          name.to_sym.to_s
        else
          name.to_s
        end
    end

    # The name reader method returns the value of the name instance
    # variable.
    #
    # @return [ String] the value stored in the name instance variable
    attr_reader :name

    # The description reader method provides access to the description
    # attribute.
    #
    # @return [ String, nil ] the description value or nil if not set
    attr_reader :description

    alias to_str description

    alias inspect description

    alias to_s description

    # The == method assigns a new name value to the instance variable.
    #
    # @param name [ Object ] the name value to be assigned
    #
    # @return [ Object ] returns the assigned name value
    def ==(name)
      @name = name
    end

    alias eql? ==

    # The hash method returns the hash value of the name attribute.
    #
    # @return [ Integer ] the hash value used for object identification
    def hash
      @name.hash
    end

    # The <=> method compares the names of two objects for sorting purposes.
    #
    # @param other [ Object ] the other object to compare against
    #
    # @return [ Integer ] -1 if this object's name is less than the other's,
    #         0 if they are equal, or 1 if this object's name is greater than the other's
    def <=>(other)
      @name <=> other.name
    end
  end

  # A wrapper class for Ruby method objects that provides enhanced
  # introspection and display capabilities.
  #
  # This class extends WrapperBase to create specialized wrappers for Ruby
  # method objects, offering detailed information about methods including
  # their source location, arity, and owner. It facilitates interactive
  # exploration of Ruby methods in environments like IRB by providing
  # structured access to method metadata and enabling sorting and
  # comparison operations based on method descriptions.
  class MethodWrapper < WrapperBase
    # The initialize method sets up a new instance with the specified
    # object, method name, and module flag.
    #
    # This method creates and configures a new instance by storing the
    # method object and its description, handling both instance methods and
    # regular methods based on the module flag parameter.
    #
    # @param obj [ Object ] the object from which to retrieve the method
    # @param name [ String ] the name of the method to retrieve
    # @param modul [ TrueClass, FalseClass ] flag indicating whether to retrieve an instance method
    def initialize(obj, name, modul)
      super(name)
      @wrapped_method = modul ? obj.instance_method(name) : obj.method(name)
      @description = @wrapped_method.description(style: :namespace)
    end

    # The method reader returns the method object associated with the
    # instance.
    attr_reader :wrapped_method

    # The owner method retrieves the owner of the method object.
    #
    # This method checks if the wrapped method object responds to the owner
    # message and returns the owner if available, otherwise it returns nil.
    #
    # @return [ Object, nil ] the owner of the method or nil if not applicable
    def owner
      @wrapped_method.respond_to?(:owner) ? @wrapped_method.owner : nil
    end

    # The arity method returns the number of parameters expected by the method.
    #
    # @return [ Integer ] the number of required parameters for the method
    def arity
      @wrapped_method.arity
    end

    # The source_location method retrieves the file path and line number
    # where the method is defined.
    #
    # This method accesses the underlying source location information for
    # the method object, returning an array that contains the filename and
    # line number of the method's definition.
    #
    # @return [ Array<String, Integer> ] an array containing the filename and line number
    #         where the method is defined, or nil if the location cannot be determined
    def source_location
      @wrapped_method.source_location
    end

    # The <=> method compares the descriptions of two objects for ordering
    # purposes.
    #
    # @param other [ Object ] the other object to compare against
    #
    # @return [ Integer ] -1 if this object's description is less than the other's,
    #         0 if they are equal, or 1 if this object's description is greater than the other's
    def <=>(other)
      @description <=> other.description
    end
  end

  # A wrapper class for Ruby constant objects that provides enhanced
  # introspection and display capabilities.
  #
  # This class extends WrapperBase to create specialized wrappers for Ruby
  # constant objects, offering detailed information about constants
  # including their names and associated classes. It facilitates
  # interactive exploration of Ruby constants in environments like IRB by
  # providing structured access to constant metadata and enabling sorting
  # and comparison operations based on constant descriptions.
  class ConstantWrapper < WrapperBase
    # The initialize method sets up a new instance with the provided object
    # and name.
    #
    # This method configures the instance by storing a reference to the
    # object's class and creating a description string that combines the
    # name with the class name.
    #
    # @param obj [ Object ] the object whose class will be referenced
    # @param name [ String ] the name to be used in the description
    #
    # @return [ Utils::Patterns::Pattern ] a new pattern instance configured with the provided arguments
    def initialize(obj, name)
      super(name)
      @klass = obj.class
      @description = "#@name:#@klass"
    end

    # The klass reader method provides access to the class value stored in the instance.
    #
    # @return [ Object ] the class value
    attr_reader :klass
  end

  # The irb_constants method retrieves and wraps all constants from a given
  # module.
  #
  # This method collects all constants defined in the specified module,
  # creates ConstantWrapper instances for each constant, and returns them
  # sorted in ascending order.
  #
  # @param modul [ Object ] the module from which to retrieve constants
  #
  # @return [ Array<ConstantWrapper> ] an array of ConstantWrapper objects
  #         representing the constants in the module, sorted alphabetically
  def irb_constants(modul = self)
    modul.constants.map { |c| ConstantWrapper.new(modul.const_get(c), c) }.sort
  end

  # The irb_subclasses method retrieves and wraps subclass information for
  # a given class.
  #
  # This method fetches the subclasses of the specified class and creates
  # ConstantWrapper instances for each subclass, allowing them to be sorted
  # and displayed in a structured format.
  #
  # @param klass [ Object ] the class object to retrieve subclasses from
  #
  # @return [ Array<ConstantWrapper> ] an array of ConstantWrapper objects
  # representing the subclasses
  def irb_subclasses(klass = self)
    klass.subclasses.map { |c| ConstantWrapper.new(eval(c), c) }.sort
  end

  unless Object.const_defined?(:Infinity)
    Infinity = 1.0 / 0 # I like to define the infinite.
  end

  # The capture_output method captures stdout and optionally stderr output
  # during code execution.
  #
  # This method temporarily redirects standard output (and optionally
  # standard error) to a temporary file, executes the provided block, and
  # then returns the captured output as a string.
  #
  # @param with_stderr [ TrueClass, FalseClass ] whether to also capture standard error output
  #
  # @yield [ void ] the block of code to execute while capturing output
  #
  # @return [ String ] the captured output as a string
  def capture_output(with_stderr = false)
    begin
      old_stdout, $stdout = $stdout, Tempfile.new('irb')
      if with_stderr
        old_stderr, $stderr = $stderr, $stdout
      end
      yield
    ensure
      $stdout, temp = old_stdout, $stdout
      with_stderr and $stderr = old_stderr
    end
    temp.rewind
    temp.read
  end

  # Use pager on the output of the commands given in the block. The less
  # method executes a block and outputs its result through the pager.
  #
  # This method runs the provided block in a controlled environment,
  # captures its output, and streams that output through the system's
  # configured pager for display.
  #
  # @param with_stderr [ TrueClass, FalseClass ] whether to include standard error in the capture
  #
  # @yield [ void ]
  def less(with_stderr = false, &block)
    IO.popen($pager, 'w') do |f|
      f.write capture_output(with_stderr, &block)
      f.close_write
    end
    nil
  end

  # The irb_time method measures the execution time of a block and outputs
  # the duration to standard error.
  #
  # @param n [ Integer ] the number of times to execute the block, defaults
  # to 1
  #
  # @yield [ block ] the block to be executed and timed
  def irb_time(n = 1, &block)
    s = Time.now
    n.times(&block)
    d = Time.now - s
  ensure
    d ||= Time.now - s
    if n == 1
      warn "Took %.3fs seconds." % d
    else
      warn "Took %.3fs seconds, %.3fs per call (avg)." % [ d, d / n ]
    end
  end

  # The irb_time_result method executes a block n times while measuring
  # execution time and returns the result of the last execution.
  #
  # @param n [ Integer ] the number of times to execute the block
  #
  # @yield [ i ]
  #
  # @return [ Object ] the result of the last block execution
  def irb_time_result(n = 1)
    r = nil
    irb_time(n) { |i| r = yield(i) }
    r
  end

  # The irb_time_watch method monitors and reports performance metrics over
  # time.
  #
  # This method continuously measures the output of a provided block,
  # calculating differences and rates of change between successive
  # measurements. It tracks these metrics and displays them with timing
  # information, useful for observing how values evolve during execution.
  #
  # @param duration [ Integer ] the time interval in seconds between
  # measurements
  #
  # @yield [ i ] the block to be measured, receiving the iteration count as an argument
  def irb_time_watch(duration = 1)
    start = Time.now
    pre = nil
    avg = Hash.new
    i = 0
    fetch_next = -> cur do
      pre = cur.map(&:to_f)
      i += 1
      sleep duration
    end
    loop do
      cur = [ yield(i) ].flatten
      unless pre
        fetch_next.(cur)
        redo
      end
      expired = Time.now - start
      diffs = cur.zip(pre).map { |c, p| c - p }
      rates = diffs.map { |d| d / duration }
      durs = cur.zip(rates).each_with_index.map { |(c, r), i|
        if r < 0
          x = c.to_f / -r
          a = avg[i].to_f
          a -= a / 2
          a += x / 2
          d = Tins::Duration.new(a)
          ds = d.to_s
          ds.singleton_class { define_method(:to_f) { d.to_f } }
          avg[i] = ds
        end
        avg[i]
      }
      warn "#{expired} #{cur.zip(diffs, rates, durs) * ' '} 𝝙 / per sec."
      fetch_next.(cur)
      sleep duration
    end
  end

  # The irb_write method writes text to a file or executes a block to
  # generate content for writing.
  #
  # This method provides a convenient way to write content to a file,
  # either by passing the text directly or by executing a block that
  # generates the content. It uses secure file writing to ensure safety.
  #
  # @param filename [ String ] the path to the file where content will be
  # written
  # @param text [ String, nil ] the text content to write to the file, or
  # nil if using a block
  #
  # @yield [ ] a block that generates content to be written to the file
  def irb_write(filename, text = nil, &block)
    if text.nil? && block
      File.secure_write filename, nil, 'wb', &block
    else
      File.secure_write filename, text, 'wb'
    end
  end

  # The irb_read method reads the contents of a file either entirely or in
  # chunks. When a block is provided, it reads the file in chunks of the
  # specified size and yields each chunk to the block.
  # If no block is given, it reads the entire file content at once and
  # returns it as a string.
  #
  # @param filename [ String ] the path to the file to be read
  # @param chunk_size [ Integer ] the size of each chunk to read when a
  # block is provided
  #
  # @yield [ chunk ] yields each chunk of the file to the block
  # @yieldparam chunk [ String ] a portion of the file content
  #
  # @return [ String, nil ] the entire file content if no block is given,
  # otherwise nil
  def irb_read(filename, chunk_size = 8_192)
    if block_given?
      File.open(filename) do |file|
        until file.eof?
          yield file.read(chunk_size)
        end
      end
      nil
    else
      File.read filename
    end
  end

# The irb_load! method loads Ruby files by their names into the current
# environment through an interactive selection interface.
#
# This method takes a glob pattern and finds matching Ruby files, then
# presents an interactive search interface for selecting which file to load.
# It ensures that each file is loaded only once by tracking loaded files
# using their paths. The method outputs messages to standard error
# indicating which file has been successfully loaded.
#
# @param glob [String] the glob pattern to search for Ruby files (defaults to
#   ENV['UTILS_IRB_LOAD_GLOB'] or 'lib/**/*.rb')
#
# @return [Boolean] true if a file was successfully loaded, false if no file
#   was selected or loaded
#
# @example
#   # Load a file interactively with default glob pattern
#   irb_load!
#
#   # Load files matching a custom pattern
#   irb_load!('app/models/**/*.rb')
#
#   # Set environment variable for default pattern
#   ENV['UTILS_IRB_LOAD_GLOB'] = 'lib/**/*.rb'
#   irb_load!
#
# @note This method uses fuzzy matching to help find files when typing
#   partial names. It respects the terminal height to limit the number of
#   displayed results.
#
# @see SearchUI for the interactive search interface implementation
# @see Amatch::PairDistance for the fuzzy matching algorithm
  def irb_load!(glob = ENV.fetch('UTILS_IRB_LOAD_GLOB', 'lib/**/*.rb'))
    files = Dir.glob(glob)
    found = Search.new(
      match: -> answer {
        matcher = Amatch::PairDistance.new(answer.downcase)
        matches = files.map { |n| [ n, -matcher.similar(n.downcase) ] }.
          sort.select { _2 < 0 }.sort_by(&:last).map(&:first)
        matches.empty? and matches = files
        matches.first(Tins::Terminal.lines - 1)
      },
      query: -> _answer, matches, selector {
        matches.each_with_index.
        map { |m, i| i == selector ? "→ " + Search.on_blue(m) : "  " + m } * ?\n
      },
      found: -> _answer, matches, selector {
        matches[selector]
      },
      output: STDOUT
    ).start
    found or return false
    load found
  end

  # The irb_server method provides access to an IRB server instance for
  # interactive Ruby sessions.
  #
  # This method ensures that a single IRB server instance is created and
  # started for the current process, loading the configuration from
  # standard paths and using the configured server URL.
  #
  # @return [ Utils::IRB::IRBServer ] the IRB server instance, initialized
  #   and started if not already running
  def irb_server
    unless @irb_server
      config = Utils::ConfigFile.new.tap(&:configure_from_paths)
      @irb_server = Utils::IRB::IRBServer.new(url: config.irb_server_url).start
    end
    @irb_server
  end

  # The irb_current_snippet method retrieves the current code snippet
  # stored in the IRB server.
  #
  # This method accesses the IRB server instance and returns the snippet
  # that has been stored for execution, or nil if no snippet is currently
  # stored or if the server is not available.
  #
  # @return [ String, nil ] the current code snippet stored in the IRB
  #   server, or nil if not available
  def irb_current_snippet
    irb_server&.snippet
  end

  # The irb_server_stop method sends a stop command to the IRB server
  # client.
  #
  # This method accesses the IRB client instance and invokes the
  # stop_server method on it, which gracefully shuts down the IRB server
  # process.
  #
  # @return [ nil ] always returns nil after sending the stop command to
  #   the server
  def irb_server_stop
    irb_client.stop_server
  end

  # The irb_client method provides access to an IRB server client instance.
  #
  # This method creates and returns a new IRB server client by first
  # loading the configuration from standard paths and then using the
  # configured server URL
  # to initialize the client.
  #
  # @return [ Utils::IRB::IRBServer ] a new IRB server client instance configured
  #         with the URL from the application's configuration
  def irb_client
    config = Utils::ConfigFile.new.tap(&:configure_from_paths)
    Utils::IRB::IRBServer.new(url: config.irb_server_url)
  end

  # The ed method opens files for editing using the system editor.
  #
  # This method provides a convenient way to edit files by invoking the
  # configured editor. When called without arguments, it edits the current
  # object's representation. When called with file arguments, it edits those
  # specific files.
  #
  # @param files [ Array ] an array of file paths to be edited
  def ed(*files)
    if files.empty?
      $editor.full?(:edit, self)
    else
      $editor.full?(:edit, *files)
    end
  end

  if defined?(ActiveRecord::Base)
    $logger = Logger.new(STDERR)
    # The irb_toggle_logging method toggles the logging configuration for
    # ActiveRecord.
    #
    # This method manages the logger setting for ActiveRecord by switching
    # between a custom logger and the previously configured logger. It
    # returns true when switching to the custom logger, and false when
    # reverting to the original logger.
    #
    # @return [ TrueClass, FalseClass ] true if the logger was switched to
    # the custom logger, false if it was reverted to the original logger
    def irb_toggle_logging
      if ActiveRecord::Base.logger != $logger
        $old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = $logger
        true
      else
        ActiveRecord::Base.logger = $old_logger
        false
      end
    end
  end
end
