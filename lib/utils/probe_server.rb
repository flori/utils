require 'unix_socks'
require 'tins/xt'
require 'term/ansicolor'

module Utils
  class ProcessJob
    include Term::ANSIColor

    # Initializes a new ProcessJob instance with the specified arguments and
    # optional probe server.
    #
    # This method creates a process job object that can be enqueued for
    # execution by a probe server. It assigns a unique job ID from the probe
    # server if provided and stores the command arguments as an array.
    #
    # @param args [ Array ] the command arguments to be executed by the job
    # @param probe_server [ Utils::ProbeServer, nil ] the probe server instance
    # to use for generating job IDs
    #
    # @return [ Utils::ProcessJob ] a new ProcessJob instance configured with
    # the provided arguments and server reference
    def initialize(args:, probe_server: nil)
      @id   = probe_server&.next_job_id
      @args = Array(args)
    end

    # Returns the unique identifier of the process job.
    #
    # @return [ Integer ] the job ID
    attr_reader :id

    # The args reader method provides access to the arguments stored in the
    # instance.
    #
    # @return [ Array ] the array of arguments
    attr_reader :args

    # The ok method sets the success status of the process job.
    #
    # @param value [ TrueClass, FalseClass, nil ] the success status to set
    attr_writer :ok

    # Returns the type identifier for the process job.
    #
    # This method provides a constant string value that identifies the object
    # as a process job within the probe server system, facilitating type-based
    # dispatch and handling.
    #
    # @return [ String ] the string 'process_job' indicating the object's type
    def type
      'process_job'
    end

    # The ok method returns a character representation of the job's success
    # status.
    #
    # This method provides a visual indicator of whether a process job has
    # succeeded, failed, or is still in progress. It returns 'y' for successful
    # jobs, 'n' for failed jobs, and '…' for jobs that are currently running or
    # pending.
    #
    # @return [ String ] 'y' if the job succeeded, 'n' if it failed, or '…' if
    # the status is unknown
    def ok
      case @ok
      when false then 'n'
      when true  then 'y'
      else            '…'
      end
    end

    # The ok_colorize method applies color formatting to a string based on the
    # success status.
    #
    # This method returns the input string wrapped with color codes to indicate
    # whether the associated process job succeeded, failed, or is in progress.
    # Successful jobs are highlighted in green, failed jobs in red, and pending
    # jobs are returned without any color formatting.
    #
    # @param string [ String ] the string to be colorized
    #
    # @return [ String ] the colorized string or the original string if status is unknown
    def ok_colorize(string)
      case @ok
      when false then white { on_red { string } }
      when true  then black { on_green { string } }
      else            string
      end
    end

    # The inspect method generates a colorized string representation of the
    # process job.
    #
    # This method creates a formatted string that includes the job's unique
    # identifier and its command arguments, with the status indicator
    # color-coded based on whether the job succeeded, failed, or is pending.
    #
    # @return [ String ] a formatted string representation of the process job
    #         including its ID, arguments, and color-coded status indicator
    def inspect
      ok_colorize("#{id} #{args.map { |a| a.include?(' ') ? a.inspect : a } * ' '}")
    end

    alias to_s inspect

    # The as_json method converts the process job object into a
    # JSON-serializable hash.
    #
    # This method creates and returns a hash representation of the process job,
    # containing its type, unique identifier, and command arguments.
    #
    # @return [ Hash ] a hash containing the type, id, and args of the process job
    def as_json(*)
      { type:, id:, args:, }
    end

    # The to_json method converts the object to a JSON string representation.
    #
    # This method delegates to the as_json method to generate a hash representation
    # of the object, then converts that hash to a JSON string using the
    # standard JSON library's to_json method.
    #
    # @return [ String ] a JSON string representation of the object
    def to_json(*)
      as_json.to_json(*)
    end
  end

  class ProbeClient
    class EnvProxy
      # The initialize method sets up a new instance with the provided server
      # object.
      #
      # @param server [ UnixSocks::Server ] the server object to be assigned
      # to the instance variable
      def initialize(server)
        @server = server
      end

      # The []= method sets an environment variable value through the probe server.
      #
      # This method transmits a request to the probe server to set the specified
      # environment variable key to the given value, then returns the updated
      # environment value from the server's response.
      #
      # @param key [ String ] the environment variable key to set
      # @param value [ String ] the value to assign to the environment variable
      #
      # @return [ String ] the updated environment variable value returned by the server
      def []=(key, value)
        response = @server.transmit_with_response(type: 'set_env', key:, value:)
        response.env
      end

      # The [] method retrieves the value of an environment variable from the probe server.
      #
      # This method sends a request to the probe server to fetch the current value of the specified
      # environment variable key and returns the corresponding value.
      #
      # @param key [ String ] the environment variable key to retrieve
      #
      # @return [ String ] the value of the specified environment variable
      def [](key)
        response = @server.transmit_with_response(type: 'get_env', key:)
        response.env
      end

      attr_reader :env
    end

    # The initialize method sets up a new probe server instance.
    #
    # This method creates and configures a Unix domain socket server for
    # handling probe jobs and communication. It initializes the server with a
    # specific socket name and runtime directory, preparing it to listen for
    # incoming connections and process jobs.
    #
    # @return [ Utils::ProbeServer ] a new probe server instance configured with
    #         the specified socket name and runtime directory
    def initialize
      @server = UnixSocks::Server.new(socket_name: 'probe.sock', runtime_dir: Dir.pwd)
    end

    # The env method provides access to environment variable management through
    # a proxy object.
    #
    # This method returns an EnvProxy instance that allows for setting and
    # retrieving environment variables via the probe server communication
    # channel.
    #
    # @return [ Utils::ProbeServer::EnvProxy ] a proxy object for environment
    # variable operations
    def env
      EnvProxy.new(@server)
    end

    # The enqueue method submits a new process job to the probe server for
    # execution.
    #
    # This method transmits a process job request to the underlying Unix domain
    # socket server, which then adds the job to the processing queue. The job
    # includes the specified command arguments that will be executed by the
    # probe server.
    #
    # @param args [ Array ] the command arguments to be executed by the process
    # job
    def enqueue(args)
      @server.transmit({ type: 'process_job', args: })
    end
  end

  class ProbeServer
    include Term::ANSIColor

    # The initialize method sets up a new probe server instance.
    #
    # This method creates and configures the core components of the probe
    # server, including initializing the Unix domain socket server for
    # communication, setting up the job queue for processing tasks, and
    # preparing the history tracking for completed jobs.
    #
    # @return [ Utils::ProbeServer ] a new probe server instance configured
    # with the specified socket name and runtime directory
    def initialize
      @server         = UnixSocks::Server.new(socket_name: 'probe.sock', runtime_dir: Dir.pwd)
      @history        = [].freeze
      @jobs_queue     = Queue.new
      @current_job_id = 0
    end

    # The start method initializes and begins operation of the probe server.
    #
    # This method sets up the probe server by starting a thread to process jobs
    # from the queue and entering a receive loop to handle incoming requests.
    # It also manages interrupt signals to enter interactive mode when needed.
    def start
      output_message "Starting probe server listening to #{@server.server_socket_path}.", type: :info
      Thread.new do
        loop do
          job = @jobs_queue.pop
          run_job job
        end
      end
      begin
        receive_loop.join
      rescue Interrupt
        ARGV.clear << '-f'
        output_message %{\nEntering interactive mode.}, type: :info
        help
        begin
          old, $VERBOSE = $VERBOSE, nil
          examine(self)
        ensure
          $VERBOSE = old
        end
        @server.remove_socket_path
        output_message "Quitting interactive mode, but still listening to #{@server.server_socket_path}.", type: :info
        retry
      end
    end

    # The inspect method returns a string representation of the probe server
    # instance.
    #
    # This method provides a concise overview of the probe server's state by
    # displaying its type and the current size of the job queue, making it
    # useful for debugging and monitoring purposes.
    #
    # @return [ String ] a formatted string containing the probe server identifier
    #         and the number of jobs currently in the queue
    def inspect
      "#<Probe #queue=#{@jobs_queue.size}>"
    end
    alias to_s inspect

    annotate :doc

    annotate :shortcut

    # The help method displays a formatted list of available commands and their
    # descriptions.
    #
    # This method organizes and presents the documented commands along with their
    # shortcuts and descriptions in a formatted table layout for easy reference.
    doc 'Display this help.'
    shortcut :h
    def help
      docs      = doc_annotations.sort_by(&:first)
      docs_size = docs.map { |a| a.first.size }.max
      format = "%-#{docs_size}s %-3s %s"
      output_message [
        on_color(20) { white { format % %w[ command sho description ] } }
      ] << docs.map { |cmd, doc|
        shortcut = shortcut_of(cmd) and shortcut = "(#{shortcut})"
        format % [ cmd, shortcut, doc ]
      }
    end

    # The job_enqueue method adds a new process job to the execution queue.
    #
    # This method creates a process job instance with the provided arguments
    # and enqueues it for execution by the probe server. It provides feedback
    # about the enqueued job through output messaging.
    #
    # @param args [ Array ] the command arguments to be executed by the process job
    doc 'Enqueue a new job with the argument array <args>.'
    shortcut :e
    def job_enqueue(args)
      job = ProcessJob.new(args:, probe_server: self)
      output_message " → #{job.inspect} enqueued.", type: :info
      @jobs_queue.push job
    end
    alias enqueue job_enqueue

    # The shutdown method terminates the probe server process immediately.
    #
    # This method outputs a warning message indicating that the server is being
    # shut down forcefully and then exits the program with status code 23.
    doc 'Quit the server.'
    shortcut :q
    def shutdown
      output_message "Server was shutdown down manually!", type: :info
      exit 23
    end

    # The job_repeat method re-executes a previously run job from the history.
    #
    # This method takes a job identifier and attempts to find the corresponding
    # job in the server's execution history. If found, it enqueues a new
    # instance of that job for execution with the same arguments as the
    # original.
    #
    # @param job_id [ Integer, Utils::ProcessJob ] the identifier of the job to repeat
    #        or the job object itself
    #
    # @return [ TrueClass, FalseClass ] true if the job was found and re-enqueued,
    #         false otherwise
    doc 'Repeat the job with <job_id> or the last, it will be assigned a new id, though.'
    shortcut :r
    def job_repeat(job_id = @history.last)
      ProcessJob === job_id and job_id = job_id.id
      if old_job = @history.find { |job| job.id == job_id }
        job_enqueue old_job.args
        true
      else
        false
      end
    end

    # The history_list method displays the list of previously executed jobs
    # from the server's history.
    #
    # This method outputs all completed jobs that have been processed by the probe server,
    # showing their identifiers and command arguments for review.
    #
    # @return [ void ]
    doc 'List the history of run jobs.'
    shortcut :l
    def history_list
      output_message @history
    end

    # The history_clear method clears all entries from the server's execution
    # history.
    #
    # This method resets the internal history array to an empty state,
    # effectively removing all records of previously executed jobs from the
    # probe server.
    #
    # @return [ TrueClass ] always returns true after clearing the history
    doc 'Clear the history of run jobs.'
    def history_clear
      @history = []
      true
    end

    class LogWrapper < BasicObject
      # The initialize method sets up a new instance with the provided server
      # object and object.
      #
      # This method creates and configures a LogWrapper instance by storing
      # references to the specified server and object parameters. It prepares
      # the wrapper for use in logging environment variable operations while
      # maintaining access to both the server for messaging and the underlying
      # object for attribute access.
      #
      # @param server [ Utils::ProbeServer ] the probe server instance to be assigned
      # @param object [ ENV ] the environment object to be wrapped
      def initialize(server, object)
        @server, @object = server, object
      end

      # The []= method sets an environment variable value through the probe
      # server.
      #
      # This method transmits a request to the probe server to set the
      # specified environment variable key to the given value, then returns the
      # updated environment value from the server's response.
      #
      # @param name [ String ] the environment variable key to set
      # @param value [ String ] the value to assign to the environment variable
      #
      # @return [ String ] the updated environment variable value returned by
      # the server
      def []=(name, value)
        name, value = name.to_s, value.to_s
        @server.output_message("Setting #{name}=#{value.inspect}.", type: :info)
        @object[name] = value
      end

      # The method_missing method delegates calls to the wrapped object's
      # methods.
      #
      # This method acts as a fallback handler that forwards undefined method
      # calls to the internal object instance, enabling dynamic method dispatch
      # while maintaining access to all available methods through the wrapper
      # interface.
      #
      # @param a [ Array ] the arguments passed to the missing method
      # @param b [ Proc ] the block passed to the missing method
      #
      # @return [ Object ] the result of the delegated method call on the
      # wrapped object
      def method_missing(*a, &b)
        @object.__send__(*a, &b)
      end
    end

    doc "The environment of the server process, use env['a'] = 'b' and env['a']."
    # The env method provides access to the server's environment variables
    # through a wrapped interface.
    #
    # This method returns a LogWrapper instance that allows for setting and
    # retrieving environment variables while logging the operations. The
    # wrapper maintains access to both the probe server for messaging and the
    # underlying ENV object for attribute access.
    #
    # @return [ Utils::ProbeServer::LogWrapper ] a wrapped environment object
    # for variable management
    memoize_method def env
      LogWrapper.new(self, ENV)
    end

    doc "Clear the terminal screen"
    shortcut :c
    # The clear method clears the terminal screen by executing the clear
    # command.
    #
    # @return [ void ]
    def clear
      system "clear"
    end

    for (method_name, shortcut) in shortcut_annotations
      alias_method shortcut, method_name
    end

    # The next_job_id method increments and returns the current job identifier.
    #
    # This method maintains a sequential counter for job identification within
    # the probe server, providing unique IDs for newly enqueued process jobs.
    #
    # @return [ Integer ] the next available job identifier in the sequence
    def next_job_id
      @current_job_id += 1
    end

    # The output_message method displays a formatted message to standard output
    # with optional styling based on the message type.
    #
    # This method takes a message and an optional type parameter to determine
    # the formatting style for the output. It handles both string and array
    # messages, converting arrays into multi-line strings. Different message
    # types are styled using color codes and formatting attributes to provide
    # visual distinction.
    #
    # @param msg [ String, Array ] the message to be displayed
    # @param type [ Symbol ] the type of message for styling (success, info, warn, failure)
    #
    # @return [ Utils::ProbeServer ] returns self to allow for method chaining
    def output_message(msg, type: nil)
      msg.respond_to?(:to_a) and msg = msg.to_a * "\n"
      msg =
        case type
        when :success
          on_color(22) { white { msg } }
        when :info
          on_color(20) { white { msg } }
        when :warn
          on_color(94) { white { msg } }
        when :failure
          on_color(124) { blink { white { msg } } }
        else
          msg
        end
      STDOUT.puts msg
      STDOUT.flush
      self
    end

    private

    # The run_job method executes a process job and updates the server's
    # history with the result.
    #
    # This method takes a process job, outputs a message indicating it is
    # running, executes the job using the system command, and then updates the
    # job's success status. It also logs the outcome of the job execution and
    # adds the completed job to the server's history for future reference.
    #
    # @param job [ Utils::ProcessJob ] the process job to be executed
    def run_job(job)
      output_message " → #{job.inspect} now running.", type: :info
      system(*cmd(job.args))
      message = " → #{job.inspect} was just run"
      if $?.success?
        job.ok = true
        message << " successfully."
        output_message message, type: :success
      else
        job.ok = false
        message << " and failed with exit status #{$?.exitstatus}!"
        output_message message, type: :failure
      end
      @history += [ job.freeze ]
      @history.freeze
      nil
    end

    # The receive_loop method sets up and starts processing incoming jobs from
    # the server.
    #
    # This method configures a background receiver on the probe server to handle
    # incoming job requests. It processes different job types by delegating to
    # appropriate handler methods, including enqueuing process jobs and managing
    # environment variable operations through response handling.
    #
    # @return [ void ]
    def receive_loop
      @server.receive_in_background do |job|
        case job.type
        when 'process_job'
          enqueue job.args
        when 'set_env'
          env[job.key] = job.value
          job.respond(env: env[job.key])
        when 'get_env'
          job.respond(env: env[job.key])
        end
      end
    end

    # The cmd method constructs and returns a command array for execution.
    #
    # This method builds a command array by first checking for the presence of
    # a BUNDLE_GEMFILE environment variable. If found, it appends the bundle
    # exec command to the call array.
    # It then adds the current script name ($0) followed by the provided job
    # arguments to complete the command. The method also outputs an
    # informational message about the command being executed.
    #
    # @param job [ Array ] the job arguments to be included in the command
    #
    # @return [ Array<String> ] the constructed command array ready for execution
    def cmd(job)
      call = []
      if ENV.key?('BUNDLE_GEMFILE') and bundle = `which bundle`.full?(:chomp)
        call << bundle << 'exec'
      end
      call.push($0, *job)
      output_message "Executing #{call.inspect} now.", type: :info
      call
    end
  end
end
