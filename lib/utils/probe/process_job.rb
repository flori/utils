module Utils::Probe
  # A process job representation for execution within the probe server system.
  #
  # This class encapsulates the information and behavior associated with a
  # single executable task that can be enqueued and processed by a ProbeServer.
  # It holds command arguments, manages execution status, and provides
  # mechanisms for serialization and display of job information.
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
end
