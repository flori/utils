require 'logger'
require 'fileutils'

# A class that provides server functionality for interactive Ruby (IRB)
# sessions.
#
# This class manages an IRB server instance that can receive and process code
# snippets for evaluation. It handles communication through Unix domain
# sockets, allowing external clients to send code for execution and receive the
# results back.
#
# @example
#   server = Utils::IRB::IRBServer.new(url: 'unix:///tmp/irb.sock')
#   server.start
#   #
#   client = Utils::IRB::IRBServer.new(url: 'unix:///tmp/irb.sock')
#   client.store_snippet('puts "Hello World"')
#   result = server.eval_snippet('2 + 2')
class Utils::IRB::IRBServer
  # The initialize method sets up a new IRBServer instance with the specified
  # URL.
  #
  # This method configures the IRB server by initializing a logger for error
  # reporting and storing the provided URL for server communication.
  #
  # @param url [ String ] the URL to be used for the IRB server communication
  def initialize(url:, log_out: nil)
    @url     = url
    @log_out = log_out
  end

  # The url reader method provides access to the URL instance variable.
  #
  # @return [ String ] the URL value stored in the instance variable
  attr_reader :url

  # The snippet reader method provides access to the snippet instance variable.
  #
  # @return [ Object ] the snippet value stored in the instance variable
  attr_reader :snippet

  # The start method initializes and begins operation of the IRB server.
  #
  # This method sets up the server by building the underlying socket connection,
  # logging the start event, and configuring a background receiver to handle
  # incoming messages. It processes different message actions such as storing
  # code snippets or evaluating code, and responds appropriately to each
  # message type.
  #
  # @return [ Utils::IRB::IRBServer ] returns self to allow for method chaining
  def start
    @server = build_server
    @logger.info "Starting #{self.class.name} server on #{@url}."
    @server.receive_in_background do |message|
      case message.action
      when 'store'
        @snippet = message.snippet
        @logger.info "Stored #{message.to_json}."
      when 'execute'
        time_eval { eval(message.snippet) }
        @logger.info "Execution of #{message.to_json} took %.2fs" % @eval_duration
      when 'eval'
        result = time_eval { eval(message.snippet) }
        @logger.info "Evaluation of #{message.to_json} took %.2fs" % @eval_duration
        message.respond(result: result.to_s, type: message.action)
      when 'stop'
        @logger.info "Stopping #{self.class.name} server on #{@url}."
        Thread.current.exit
      else
        @logger.warn("Message for action #{message.action.inspect} not supported.")
      end
    rescue => e
      @logger.error("#{self.class.name} caught #{e.class}: #{e} for #{message.to_json}.")
    end
    self
  end

  # The store_snippet method transmits a code snippet to the client for storage.
  #
  # This method prepares a transmission request containing the specified code
  # snippet and sends it to the client using the build_client mechanism. It is
  # designed to facilitate the storage of code snippets within the system's
  # communication protocol.
  #
  # @param code [ String ] the code snippet to be stored
  #
  # @return [ Utils::IRB::IRBServer ] returns self to allow for method chaining
  def store_snippet(code)
    build_client.transmit({ action: 'store', snippet: code })
    self
  end

  # The execute_snippet method sends a code snippet to the IRB server for
  # execution and waits for the response.
  #
  # This method transmits an execute command along with the provided code
  # snippet to the IRB server, allowing the server to evaluate the code and
  # return the result.
  #
  # @param code [ String ] the code snippet to be executed
  #
  # @return [ Utils::IRB::IRBServer ] returns self to allow for method chaining
  def execute_snippet(code)
    build_client.transmit({ action: 'execute', snippet: code })
    self
  end

  # The eval_snippet method sends a code snippet to the IRB server for
  # evaluation and returns the result.
  #
  # This method transmits the provided code snippet to the IRB server for
  # execution, waits for the server's response, and extracts the evaluation
  # result from the response.
  #
  # @param code [ String ] the code snippet to be evaluated
  #
  # @return [ String ] the result of the code snippet evaluation as a string
  def eval_snippet(code)
    message = build_client.transmit_with_response({ action: 'eval', snippet: code })
    message.result
  end

  # The stop_server method sends a stop command to the IRB server.
  #
  # This method communicates with the IRB server to request a graceful shutdown
  # of the server process by transmitting a stop action.
  #
  # @return [ nil ] always returns nil after sending the stop command
  def stop_server
    build_client.transmit({ action: 'stop' })
    nil
  end

  private

  # The setup_logger method configures the log output destination for the IRB
  # server.
  #
  # This method determines whether a log output path has been provided, and if
  # not, constructs a default log path using the XDG state home directory or a
  # fallback to the user's local state directory. It ensures the log directory
  # exists and creates a new log file for writing.
  #
  # @return [ String ] the path to the log file that will be used for logging
  def setup_logger
    unless @log_out
      xdg_dir  = File.expand_path(ENV.fetch('XDG_STATE_HOME', '~/.local/state'))
      log_path = Pathname.new(xdg_dir) + 'utils'
      FileUtils.mkdir_p log_path
      log_path += 'irb-server.log'
      @log_out = File.new(log_path, ?a)
    end
    @log_out.sync = true
    @logger = Logger.new(@log_out)
  end

  # The build_server method creates and returns a Unix domain socket server
  # instance based on the URL configuration
  #
  # This method initializes a socket server by delegating to the
  # UnixSocks.from_url factory method, which constructs an appropriate server
  # type (TCP or domain socket) based on the URL scheme and configuration
  # parameters
  #
  # @return [ UnixSocks::TCPSocketServer, UnixSocks::DomainSocketServer ] a new
  #   socket server instance configured according to the URL specification
  def build_server
    setup_logger
    UnixSocks.from_url(url)
  end

  alias build_client build_server

  # The time_eval method measures the execution duration of a block.
  #
  # This method records the start time before yielding to the provided block,
  # then calculates the elapsed time after the block completes, storing the
  # duration in an instance variable for later access.
  #
  # @param block [ Proc ] the block of code to measure execution time for
  #
  # @return [ Object ] the result of the block execution
  #
  # @api private
  def time_eval(&block)
    s = Time.now
    block.()
  ensure
    @eval_duration = Time.now - s
  end
end
