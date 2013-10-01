require 'tins/xt'
require 'term/ansicolor'
class String
  include Term::ANSIColor
end

module Utils
  class ProbeServer
    class Job

      class << self
        attr_writer :colorize

        def colorize?
          !!@colorize
        end
      end
      self.colorize = false

      def initialize(probe_server, args)
        @id           = probe_server.next_job_id
        @args         = args
      end

      attr_reader :id

      attr_reader :args

      attr_writer :ok

      def ok
        case @ok
        when false then 'n'
        when true  then 'y'
        else            '-'
        end
      end

      def ok_colorize(string)
        return string unless self.class.colorize?
        case @ok
        when false then string.white.on_red
        when true  then string.black.on_green
        else            string.black.on_yellow
        end
      end

      def inspect
        ok_colorize(
          "#<#{self.class}: id=#{id} args=#{args.inspect} ok=#{ok}>"
        )
      end

      alias to_s inspect
    end

    def initialize
      @history    = [].freeze
      @jobs_queue = Queue.new
      @current_job_id = 0
      Thread.new { work_loop }
    end

    annotate :doc

    def docs
      annotations = self.class.doc_annotations.sort_by(&:first)
      max_size = annotations.map { |a| a.first.size }.max
      annotations.map { |n, v| "#{n.to_s.ljust(max_size + 1)}#{v}" }
    end

    doc 'Return the currently running job.'
    def job
      queue_synchronize do
        @job
      end
    end

    def next_job_id
      @current_job_id += 1
    end

    doc 'Enqueue a new job with the argument array <job_args>.'
    def job_enqueue(job_args)
      job = Job.new(self, job_args)
      output_message "#{job.inspect} enqueued."
      @jobs_queue.push job
    end
    alias enqueue job_enqueue

    doc 'Stop the process that is working on the current job, if any.'
    def job_stop
      @pid and Process.kill :STOP, @pid
    end

    doc 'Continue the process that is working on the current job, if any.'
    def job_continue
      @pid and Process.kill :CONT, @pid
    end

    doc 'Shutdown the server.'
    def server_shutdown
      output_message "Server was shutdown down – HARD!", :type => :warn
      exit! 23
    end

    doc 'List the currently pending jobs waiting to be run.'
    def jobs_list
      @jobs_queue.instance_variable_get(:@que).dup
    end

    doc 'Clear all pending jobs.'
    def jobs_clear
      queue_synchronize do
        unless @jobs_queue.empty?
          @jobs_queue.clear
          output_message "Cleared all queued jobs.", :type => :warn
          true
        else
          false
        end
      end
    end

    doc 'Repeat the job with <job_id>, it will be assigned a new id, though.'
    def job_repeat(job_id)
      if old_job = @history.find { |job| job.id == job_id }
        job_enqueue old_job.args
        true
      else
        false
      end
    end

    doc 'List the history of run jobs.'
    def history_list
      @history.dup
    end

    doc 'Clear the history of run jobs.'
    def history_clear
      @history = []
      true
    end

    doc "The environment of the server process, use env['a'] = 'b' and env['a']."
    def env
      ENV
    end

    private

    def queue_synchronize(&block)
      @jobs_queue.instance_variable_get(:@mutex).synchronize(&block)
    end

    def output_message(msg, opts = { :type => :info })
      msg =
        case opts[:type]
        when :success
          msg.on_green.black
        when :info, nil
          msg.on_color(118).black
        when :warn
          msg.on_color(166).black
        when :failure
          msg.on_red.blink.white
        end
      STDOUT.puts msg
      STDOUT.flush
    end

    def run_job(job)
      output_message "#{job.inspect} about to run now.", :type => :info
      @pid = fork { exec(*cmd(job.args)) }
      output_message "#{job.inspect} now running with pid #@pid.", :type => :info
      Process.wait @pid
      message = "#{job.inspect} was just run"
      if $?.success?
        job.ok = true
        message << " successfully."
        output_message message, :type => :success
      else
        job.ok = false
        message << " and failed with exit status #{$?.exitstatus}!"
        output_message message, :type => :failure
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
      output_message "Executing #{call.inspect} now.", :type => :info
      call
    end
  end
end
