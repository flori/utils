require 'tins/terminal'
require 'term/ansicolor'

begin
  require 'rspec/core'
  require 'rspec/core/formatters/base_text_formatter'
rescue LoadError => e
  if $DEBUG
    warn "Caught: #{e.class}: #{e}"
  end
else
  module Utils
    class LineFormatter < RSpec::Core::Formatters::BaseTextFormatter
      def start(example_count)
        super
        filename = 'errors.lst'
        output.puts "Storing error list in #{filename.inspect}: "
        @errors_lst = File.new(filename, 'w')
        @errors_lst.sync = true
      end

      def close
        super
        @errors_lst.puts "\n#{?= * 75}\nFinished in #{format_duration(duration)}\n"
        @errors_lst.puts summary_line(example_count, failure_count, pending_count)
        @errors_lst.close
      end

      def example_passed(example)
        super
        output.puts format_line(example)
      end

      def example_pending(example)
        super
        output.puts format_line(example)
      end

      def example_failed(example)
        super
        dump_line_to_error_file(example)
        output.puts format_line(example)
        dump_failure_info(example)
      end

      def dump_failures
      end

      def dump_pending
      end

      def dump_commands_to_rerun_failed_examples
      end

      private

      def dump_failure_for_error_file(example)
        result = ''
        exception = example.execution_result[:exception]
        exception_class_name = exception_class_name_for(exception)
        result << "#{long_padding}Failure/Error: #{read_failed_line(exception, example).strip}\n"
        result << "#{long_padding}#{exception_class_name}:\n" unless exception_class_name =~ /RSpec/
        exception.message.to_s.split("\n").each { |line| result << "#{long_padding}  #{line}\n" } if exception.message
        result
      end

      def dump_line_to_error_file(example)
        @errors_lst.flock File::LOCK_EX
        @errors_lst.puts "%s\n%3.3fs %s\n%s\n%s" % [
          location(example), run_time(example), example.full_description,
          Term::ANSIColor.uncolored(dump_failure_for_error_file(example)),
          (%w[ {{{ ] +
           format_backtrace(example.execution_result[:exception].backtrace, example) +
           %w[ }}} ]) * ?\n
        ]
      ensure
        @errors_lst.flock File::LOCK_UN
      end

      def run_time(example)
        example.execution_result[:run_time]
      end

      def format_line(example)
        description =
          if ENV['VERBOSE'].to_i == 1
            example.full_description
          else
            example.description
          end
        args = [ location(example), run_time(example), description ]
        uncolored = "%s # S %3.3fs %s" % args
        uncolored = uncolored[0, Tins::Terminal.columns]
        case example.execution_result[:status]
        when 'passed'
          success_color(uncolored)
        when 'failed'
          failure_color(uncolored)
        when 'pending'
          pending_color(uncolored)
        else
          uncolored % args
        end
      end

      def location(example)
        RSpec::Core::Metadata::relative_path(example.location)
      end
    end
  end
end
