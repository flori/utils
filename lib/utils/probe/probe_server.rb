module Utils::Probe
  # A probe server for managing and executing process jobs through Unix domain
  # sockets.
  #
  # This class provides a mechanism for enqueueing and running process jobs in
  # a distributed manner, using Unix domain sockets for communication. It
  # maintains a queue of jobs, tracks their execution status, and provides an
  # interactive interface for managing the server.
  class ProbeServer
    include Utils::Probe::ServerHandling
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
    def initialize(server_type: :unix, port: 6666)
      @server         = create_server(server_type, port)
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
      output_message "Starting probe server listening to #{@server.to_url}", type: :info
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
          IRB.examine(self)
        ensure
          $VERBOSE = old
        end
        @server.remove_socket_path
        output_message "Quitting interactive mode, but still listening to #{@server.to_url}", type: :info
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

    doc 'Display this help.'
    shortcut :h
    # The help method displays a formatted list of available commands and their
    # descriptions.
    #
    # This method organizes and presents the documented commands along with their
    # shortcuts and descriptions in a formatted table layout for easy reference.
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

    doc 'Enqueue a new job with the argument array <args>.'
    shortcut :e
    # The job_enqueue method adds a new process job to the execution queue.
    #
    # This method creates a process job instance with the provided arguments
    # and enqueues it for execution by the probe server. It provides feedback
    # about the enqueued job through output messaging.
    #
    # @param args [ Array ] the command arguments to be executed by the process job
    def job_enqueue(args)
      job = ProcessJob.new(args:, probe_server: self)
      output_message " → #{job.inspect} enqueued.", type: :info
      @jobs_queue.push job
    end
    alias enqueue job_enqueue

    doc 'Quit the server.'
    shortcut :q
    # The shutdown method terminates the probe server process immediately.
    #
    # This method outputs a warning message indicating that the server is being
    # shut down forcefully and then exits the program with status code 23.
    def shutdown
      output_message "Server was shutdown down manually!", type: :info
      exit 23
    end

    doc 'Repeat the job with <job_id> or the last, it will be assigned a new id, though.'
    shortcut :r
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
    def job_repeat(job_id = @history.last)
      ProcessJob === job_id and job_id = job_id.id
      if old_job = @history.find { |job| job.id == job_id }
        job_enqueue old_job.args
        true
      else
        false
      end
    end

    doc 'List the history of run jobs.'
    shortcut :l
    # The history_list method displays the list of previously executed jobs
    # from the server's history.
    #
    # This method outputs all completed jobs that have been processed by the probe server,
    # showing their identifiers and command arguments for review.
    def history_list
      output_message @history
    end

    doc 'Clear the history of run jobs.'
    # The history_clear method clears all entries from the server's execution
    # history.
    #
    # This method resets the internal history array to an empty state,
    # effectively removing all records of previously executed jobs from the
    # probe server.
    #
    # @return [ TrueClass ] always returns true after clearing the history
    def history_clear
      @history = []
      true
    end

    # A wrapper class for environment variable management that logs operations.
    #
    # This class provides a transparent interface for accessing and modifying
    # environment variables while recording these interactions. It delegates all
    # method calls to an underlying object (typically ENV) but intercepts assignments
    # to log the changes, enabling tracking of environment modifications during
    # probe server operations.
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
    memoize method:
    def env
      LogWrapper.new(self, ENV)
    end

    doc "Clear the terminal screen"
    shortcut :c
    # The clear method clears the terminal screen by executing the clear
    # command.
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
