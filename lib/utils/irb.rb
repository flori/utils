require 'irb/completion'
require 'enumerator'
require 'tempfile'
require 'pp'
require 'utils'
require_maybe 'ap'

$editor = Utils::Editor.new
$pager = ENV['PAGER'] || 'less -r'

module Utils
  module IRB
    module Shell
      require 'fileutils'
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
          @method = modul ? obj.instance_method(name) : obj.method(name)
          @description = @method.description(style: :namespace)
        end

        # The method reader returns the method object associated with the
        # instance.
        attr_reader :method

        # The owner method retrieves the owner of the method object.
        #
        # This method checks if the wrapped method object responds to the owner
        # message and returns the owner if available, otherwise it returns nil.
        #
        # @return [ Object, nil ] the owner of the method or nil if not applicable
        def owner
          method.respond_to?(:owner) ? method.owner : nil
        end

        # The arity method returns the number of parameters expected by the method.
        #
        # @return [ Integer ] the number of required parameters for the method
        def arity
          method.arity
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
          method.source_location
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
        require 'tempfile'
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
      # environment.
      #
      # This method takes one or more file names and attempts to locate and
      # load the corresponding Ruby files from the current directory and its
      # subdirectories. It ensures that each file is loaded only once by
      # tracking loaded files using their MD5 checksums. The method outputs
      # messages to standard error indicating which files have been
      # successfully loaded.
      #
      # @param files [ Array<String> ] the names of the Ruby files to be loaded
      #
      # @return [ nil ] always returns nil after processing all specified files
      def irb_load!(*files)
        files = files.map { |f| f.gsub(/(\.rb)?\Z/, '.rb') }
        loaded = {}
        for file in files
          catch :found do
            Find.find('.') do |f|
              File.directory?(f) and next
              md5_f = Utils::MD5.md5(f)
              if f.end_with?(file) and !loaded[md5_f]
                Kernel.load f
                loaded[md5_f] = true
                STDERR.puts "Loaded '#{f}'."
              end
            end
          end
        end
        nil
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
          require 'logger'
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

    module Regexp
      # The show_match method evaluates a string against the receiver pattern
      # and highlights matching portions.
      #
      # This method tests whether the provided string matches the pattern
      # represented by the receiver. When a match is found, it applies the
      # success proc to highlight the matched portion of the string. If no
      # match is found, it applies the failure proc to indicate that no match
      # was found.
      #
      # @param string [ String ] the string to be tested against the pattern
      # @param success [ Proc ] a proc that processes the matched portion of the string
      # @param failure [ Proc ] a proc that processes the "no match" indication
      #
      # @return [ String ] the formatted string with matched portions highlighted or a no match message
      def show_match(
        string,
        success: -> s { Term::ANSIColor.green { s } },
        failure: -> s { Term::ANSIColor.red { s } }
      )
        string =~ self ? "#{$`}#{success.($&)}#{$'}" : failure.("no match")
      end
    end

    module String
      # The | method executes a shell command and returns its output.
      #
      # This method takes a command string, pipes the current string to it via
      # stdin, captures the command's stdout, and returns the resulting output
      # as a string.
      #
      # @param cmd [ String ] the shell command to execute
      #
      # @return [ String ] the output of the executed command
      def |(cmd)
        IO.popen(cmd, 'w+') do |f|
          f.write self
          f.close_write
          return f.read
        end
      end

      # The >> method writes the string content to a file securely.
      #
      # This method takes a filename and uses File.secure_write to write the
      # string's content to that file, ensuring secure file handling practices
      # are followed.
      #
      # @param filename [ String ] the path to the file where the string content will be written
      #
      # @return [ Integer ] the number of bytes written to the file
      def >>(filename)
        File.secure_write(filename, self)
      end
    end

    # The configure method sets up IRB configuration options.
    #
    # This method configures the IRB environment by setting the history save
    # limit and customizing the prompt display when IRB is running in
    # interactive mode.
    def self.configure
      ::IRB.conf[:SAVE_HISTORY] = 1000
      if ::IRB.conf[:PROMPT]
        ::IRB.conf[:PROMPT][:CUSTOM] = {
          :PROMPT_I =>  ">> ",
          :PROMPT_N =>  ">> ",
          :PROMPT_S =>  "%l> ",
          :PROMPT_C =>  "+> ",
          :RETURN   =>  " # => %s\n"
        }
        ::IRB.conf[:PROMPT_MODE] = :CUSTOM
      end
    end
  end
end

Utils::IRB.configure

class String
  include Utils::IRB::String
end

class Object
  include Utils::IRB::Shell
end

class Regexp
  include Utils::IRB::Regexp
end
