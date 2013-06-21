# encoding: utf-8

require 'tins/xt'
require 'term/ansicolor'
class String
  include Term::ANSIColor
end

module Utils
  class ProbeServer
    def initialize
      @jobs    = Queue.new
      Thread.new { work_loop }
    end

    def enqueue(job)
      output_message "Job #{job.inspect} enqueued.".black.on_yellow
      @jobs.push job
    end
    alias run enqueue

    def shutdown
      output_message "Server was shutdown down – HARD!".white.on_red.blink
      exit! 23
    end

    private

    def output_message(msg)
      STDOUT.puts msg
      STDOUT.flush
    end

    def run_job(job)
      message = "Job #{job.inspect} about to run now:".black
      message = message.ask_and_send(:on_color, 166) || message.on_yellow
      output_message message
      fork do
        exec(*cmd(job))
      end
      Process.wait
      message = "Job #{job.inspect} was just run"
      if $?.success?
        message << " successfully."
        message = message.black.on_green
      else
        message << " and failed with exit status #{$?.exitstatus}!"
        message = message.white.on_red.blink
      end
      output_message message
    end

    def work_loop
      loop do
        job = @jobs.shift
        run_job job
      end
    end

    def cmd(job)
      [ $0, *job ]
    end
  end
end
