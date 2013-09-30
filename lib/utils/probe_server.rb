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
        @args         = args
      end

      attr_reader :id

      attr_reader :args

      def inspect
        "#<#{self.class}: id=#{id} args=#{args.inspect}>"
      end
    end

    def initialize
      @jobs_queue = Queue.new
      @current_job_id = 0
      Thread.new { work_loop }
    end

    def next_job_id
      @current_job_id += 1
    end

    def enqueue(job_args)
      job = Job.new(self, job_args)
      output_message "#{job.inspect} enqueued."
      @jobs_queue.push job
    end
    alias run enqueue

    def stop
      @pid and Process.kill :STOP, @pid
    end

    def continue
      @pid and Process.kill :CONT, @pid
    end

    def shutdown
      output_message "Server was shutdown down – HARD!", :type => :warn
      exit! 23
    end

    def list_jobs
      @jobs_queue.instance_variable_get(:@que)
    end

    def clear_jobs
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
        message << " successfully."
        output_message message, :type => :success
      else
        message << " and failed with exit status #{$?.exitstatus}!"
        output_message message, :type => :failure
      end
    end

    def work_loop
      loop do
        job = @jobs_queue.shift
        run_job job
      end
    end

    def cmd(job)
      [ $0, *job ]
    end
  end
end
