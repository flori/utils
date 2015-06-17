require 'tins/terminal'
require 'term/ansicolor'

begin
  require 'rspec/core'
  require 'rspec/core/formatters'
rescue LoadError => e
  $DEBUG and warn "Caught #{e.class}: #{e}"
else
  module Utils
    class LineFormatter
        ::RSpec::Core::Formatters.register self, :start, :close,
          :example_passed, :example_pending, :example_failed, :dump_summary

        def initialize(output)
          @output = output
          filename = 'errors.lst'
          @errors_lst = File.new(filename, 'w')
          @errors_lst.sync = true
        end

        attr_reader :output

        def start(_ignore)
          output.puts "Storing error list in #{@errors_lst.path.inspect}: "
          output.puts ?- * Tins::Terminal.columns
        end

        def close(_ignore)
          @errors_lst.close
        end

        def dump_summary(summary)
          line = summary_line(summary)
          @errors_lst.puts ?= * 80, line
          output.puts ?= * Tins::Terminal.columns, line
        end

        def example_passed(example)
          output.puts format_line(example)
        end

        def example_pending(example)
          output.puts format_line(example)
        end

        def example_failed(example)
          dump_failure_to_error_file(example)
          output.puts format_line(example)
        end

        private

        def summary_line(summary)
          failure_percentage = 100 * summary.failure_count.to_f / summary.example_count
          failure_percentage.nan? and failure_percentage = 0.0
          pending_percentage = 100 * summary.pending_count.to_f / summary.example_count
          pending_percentage.nan? and pending_percentage = 0.0
          "%u of %u (%.2f %%) failed, %u pending (%.2f %%) in %.3f seconds" % [
            summary.failure_count,
            summary.example_count,
            failure_percentage,
            summary.pending_count,
            pending_percentage,
            summary.duration,
          ]
        end

        def read_failed_line(example)
          ''.strip
        end

        def dump_failure_for_error_file(example)
          result = ''
          exception = execution_result(example).exception
          exception_class_name = exception.class.name
          result << "Failure/Error: #{read_failed_line(example)}\n"
          result << "#{exception_class_name}:\n" unless exception_class_name =~ /RSpec/
          if m = exception.message
            m.to_s.split("\n").each { |line| result << "  #{line}\n" }
          end
          result
        end

        def format_backtrace(example)
          backtrace = execution_result(example).exception.backtrace
          result = %w[ {{{ ]
          for line in backtrace
            result << RSpec::Core::Metadata::relative_path(line)
          end
          result += %w[ }}} ]
          result * ?\n
        end

        def dump_failure_to_error_file(example)
          @errors_lst.flock File::LOCK_EX
          @errors_lst.puts "%s\n%3.3fs %s\n%s\n%s" % [
            location(example), run_time(example), description(example, full: true),
            dump_failure_for_error_file(example), format_backtrace(example)
          ]
        ensure
          @errors_lst.flock File::LOCK_UN
        end

        def execution_result(example)
          example.example.metadata[:execution_result]
        end

        def description(example, full: ENV['VERBOSE'].to_i == 1)
          if full
            example.example.full_description
          else
            example.example.description
          end
        end

        def run_time(example)
          execution_result(example).run_time
        end

        def format_line(example)
          args = [ location(example), run_time(example), description(example) ]
          uncolored = "%s # S %3.3fs %s" % args
          uncolored = uncolored[0, Tins::Terminal.columns]
          case execution_result(example).status
          when :passed
            success_color(uncolored)
          when :failed
            failure_color(uncolored)
          when :pending
            pending_color(uncolored)
          else
            uncolored % args
          end
        end

        def success_color(text)
          Term::ANSIColor.green(text)
        end

        def failure_color(text)
          Term::ANSIColor.red(text)
        end

        def pending_color(text)
          Term::ANSIColor.yellow(text)
        end

        def location(example)
          location = example.example.metadata[:location]
          unless location.include?(?/)
            location = example.example.metadata[:example_group][:location]
          end
          RSpec::Core::Metadata::relative_path(location)
        end
    end
  end
end
