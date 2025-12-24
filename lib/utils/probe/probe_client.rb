module Utils::Probe
  # A client for interacting with the probe server through Unix domain sockets.
  #
  # This class provides an interface for enqueueing process jobs and managing
  # environment variables on a remote probe server. It uses Unix domain sockets
  # to communicate with the server, enabling distributed task execution and
  # configuration management.
  class ProbeClient
    include ServerHandling

    # A proxy class for managing environment variables through a probe server communication channel.
    #
    # This class provides a wrapper around the ENV object that allows setting and retrieving
    # environment variables while logging these operations through the probe server.
    # It intercepts assignments and lookups to provide visibility into environment modifications
    # during probe server operations.
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
    def initialize(server_type: :unix, port: 6666)
      @server = create_server(server_type, port)
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
end
