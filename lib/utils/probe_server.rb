require 'tins/xt'
require 'term/ansicolor'
class String
  include Term::ANSIColor
end

module Utils
  class ProbeServer
    class Job
      def initialize(probe_server, args)
        @id           = probe_server.next_job_id
        @args         = Array(args)
      end

      attr_reader :id

      attr_reader :args

      attr_writer :ok

      def ok
        case @ok
        when false then 'n'
        when true  then 'y'
        else            '…'
        end
      end

      def ok_colorize(string)
        case @ok
        when false then string.white.on_red
        when true  then string.black.on_green
        else            string
        end
      end

      def inspect
        ok_colorize("#{id} #{args.map { |a| a.include?(' ') ? a.inspect : a } * ' '}")
      end

      alias to_s inspect
    end

    def initialize(uri)
      @uri        = uri
      @history    = [].freeze
      @jobs_queue = Queue.new
      @current_job_id = 0
      Thread.new { work_loop }
    end

    def print(*msg)
      if msg.first !~ /^irb: warn: can't alias / # shut your god d*mn wh*re mouth
        super
      end
    end

    def start
      output_message "Starting probe server listening to #{@uri.inspect}.", type: :info
      DRb.start_service(@uri, self)
      begin
        DRb.thread.join
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
        output_message "Quitting interactive mode, but still listening to #{@uri.inspect}.", type: :info
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
      format = '%-20s %-3s %s'
      output_message [
          (format % %w[ command sho description ]).on_color(20).white
        ] << docs.map { |cmd, doc|
          shortcut = shortcut_of(cmd) and shortcut = "(#{shortcut})"
          format % [ cmd, shortcut, doc ]
        }
    end

    doc 'Enqueue a new job with the argument array <job_args>.'
    shortcut :e
    def job_enqueue(job_args)
      job = Job.new(self, job_args)
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
      Job === job_id and job_id = job_id.id
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
          msg.on_color(22).white
        when :info
          msg.on_color(20).white
        when :warn
          msg.on_color(94).white
        when :failure
          msg.on_color(124).blink.white
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
      system *cmd(job.args)
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
      @history += [ @job.freeze ]
      @history.freeze
      @job = nil
    end

    def work_loop
      loop do
        @job = @jobs_queue.shift
        run_job @job
      end
    end

    def cmd(job)
      call = []
      if ENV.key?('BUNDLE_GEMFILE') and bundle = `which bundle`.full?(:chomp)
        call << bundle << 'exec'
      end
      call.push($0, *job)
      #output_message "Executing #{call.inspect} now.", type: :info
      call
    end
  end
end
