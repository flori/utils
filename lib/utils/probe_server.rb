require 'unix_socks'
require 'tins/xt'
require 'term/ansicolor'

module Utils
  class ProcessJob
    include Term::ANSIColor

    def initialize(args:, probe_server: nil)
      @id           = probe_server&.next_job_id
      @args         = Array(args)
    end

    attr_reader :id

    attr_reader :args

    attr_writer :ok

    def type
      'process_job'
    end

    def ok
      case @ok
      when false then 'n'
      when true  then 'y'
      else            '…'
      end
    end

    def ok_colorize(string)
      case @ok
      when false then white { on_red { string } }
      when true  then black { on_green { string }}
      else            string
      end
    end

    def inspect
      ok_colorize("#{id} #{args.map { |a| a.include?(' ') ? a.inspect : a } * ' '}")
    end

    alias to_s inspect

    def as_json(*)
      { type:, id:, args:, }
    end

    def to_json(*)
      as_json.to_json(*)
    end
  end

  class ProbeClient
    class EnvProxy
      def initialize(server)
        @server = server
      end

      def []=(key, value)
        response = @server.transmit_with_response(type: 'set_env', key:, value:)
        response.env
      end

      def [](key)
        response = @server.transmit_with_response(type: 'get_env', key:)
        response.env
      end

      attr_reader :env
    end

    def initialize
      @server = UnixSocks::Server.new(socket_name: 'probe.sock', runtime_dir: Dir.pwd)
    end

    def env
      EnvProxy.new(@server)
    end

    def enqueue(args)
      @server.transmit({ type: 'process_job', args: })
    end
  end

  class ProbeServer
    include Term::ANSIColor

    def initialize
      @server         = UnixSocks::Server.new(socket_name: 'probe.sock', runtime_dir: Dir.pwd)
      @history        = [].freeze
      @jobs_queue     = Queue.new
      @current_job_id = 0
    end

    def print(*msg)
      if msg.first !~ /^irb: warn: can't alias / # shut your god d*mn wh*re mouth
        super
      end
    end

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

    def inspect
      "#<Probe #queue=#{@jobs_queue.size}>"
    end
    alias to_s inspect

    annotate :doc

    annotate :shortcut

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

    doc 'Enqueue a new job with the argument array <args>.'
    shortcut :e
    def job_enqueue(args)
      job = ProcessJob.new(args:, probe_server: self)
      output_message " → #{job.inspect} enqueued.", type: :info
      @jobs_queue.push job
    end
    alias enqueue job_enqueue

    doc 'Send the <signal> to the process that is working on the current job, if any.'
    doc 'Quit the server.'
    shortcut :q
    def shutdown
      output_message "Server was shutdown down – HARD!", type: :warn
      exit 23
    end

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

    doc 'List the history of run jobs.'
    shortcut :l
    def history_list
      output_message @history
    end

    doc 'Clear the history of run jobs.'
    def history_clear
      @history = []
      true
    end

    class LogWrapper < BasicObject
      def initialize(server, object)
        @server, @object = server, object
      end

      def []=(name, value)
        name, value = name.to_s, value.to_s
        @server.output_message("Setting #{name}=#{value.inspect}.", type: :info)
        @object[name] = value
      end

      def method_missing(*a, &b)
        @object.__send__(*a, &b)
      end
    end

    doc "The environment of the server process, use env['a'] = 'b' and env['a']."
    memoize_method def env
      LogWrapper.new(self, ENV)
    end

    doc "Clear the terminal screen"
    shortcut :c
    def clear
      system "clear"
    end

    for (method_name, shortcut) in shortcut_annotations
      alias_method shortcut, method_name
    end

    def next_job_id
      @current_job_id += 1
    end

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
    end

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
