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

      # The initialize method sets up the error logging system by creating a
      # file handle for writing error messages and ensuring the output is
      # synchronized.
      #
      # @param output [ IO ] the output stream to be used for logging errors
      def initialize(output)
        @output = output
        @output.sync = true
        filename = 'errors.lst'
        @errors_lst = File.new(filename, 'w')
        @errors_lst.sync = true
      end

      # The output reader method provides access to the output storage.
      #
      # @return [ Array ] the array containing the collected output items
      attr_reader :output

      # The start method initializes the error logging output.
      #
      # This method writes a header message to the output indicating where the
      # error list will be stored, followed by a separator line made of dashes
      # that spans the width of the terminal.
      #
      # @param _ignore [ Object ] this parameter is ignored and exists for
      # interface compatibility
      def start(_ignore)
        output.puts "Storing error list in #{@errors_lst.path.inspect}: "
        output.puts ?━ * Tins::Terminal.columns
      end

      # The close method closes the error log file handle.
      #
      # This method is responsible for properly closing the file handle
      # associated with the error log file, ensuring that all buffered data is
      # written and system resources are released.
      #
      # @param _ignore [ Object ] ignored parameter, present for interface
      # compatibility
      def close(_ignore)
        @errors_lst.close
      end

      # The dump_summary method outputs a formatted summary line to both the
      # errors log and the standard output.
      #
      # This method generates a summary line using the summary_line method,
      # then writes it to both the error log file and the standard output, with
      # decorative lines of equals signs for visual separation in each output
      # stream.
      #
      # @param summary [ Object ] the summary object to be processed and displayed
      def dump_summary(summary)
        line = summary_line(summary)
        @errors_lst.puts ?═ * 80, line
        output.puts ?═ * Tins::Terminal.columns, line
      end

      # The example_passed method outputs a formatted line for a passed test
      # example.
      #
      # This method takes a test example and formats it using the internal format_line method,
      # then writes the formatted output to the designated output stream.
      #
      # @param example [ Object ] the test example that has passed
      def example_passed(example)
        output.puts format_line(example)
      end

      # The example_pending method outputs a formatted line for a pending test
      # example.
      #
      # This method takes a test example that is pending and formats it using
      # the internal format_line method before outputting it to the console.
      #
      # @param example [ Object ] the test example that is pending
      def example_pending(example)
        output.puts format_line(example)
      end

      # The example_failed method handles the processing of failed test
      # examples.
      #
      # This method manages the logging and output of failed test results by
      # first writing the failure details to an error file, then formatting and
      # displaying the failure information to the output stream, and finally
      # dumping the full failure details.
      #
      # @param example [ Object ] the test example that failed
      def example_failed(example)
        dump_failure_to_error_file(example)
        output.puts format_line(example)
        dump_failure(example)
      end

      private

      # The summary_line method formats a summary string containing test
      # execution statistics.
      #
      # This method takes a summary object and generates a formatted string
      # that includes the number of failed tests, total tests, failure
      # percentage, pending tests, pending percentage, and the total execution
      # duration.
      #
      # @param summary [ Object ] an object containing test execution statistics
      #
      # @return [ String ] a formatted summary string with test statistics and
      # timing information
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

      # The dump_failure method outputs detailed information about a test
      # failure.
      #
      # This method displays the description of the failing example along with
      # the specific failure details for debugging purposes.
      #
      # @param example [ Object ] the test example that failed
      def dump_failure(example)
        output.puts(
          description(example, full: true),
          dump_failure_for_example(example)
        )
      end

      # The read_failed_line method returns an empty string after stripping
      # whitespace.
      #
      # This method is intended to provide a placeholder implementation for
      # retrieving the failed line information from a test example, currently
      # returning an empty stripped string regardless of the input.
      #
      # @param example [ Object ] the test example object
      #
      # @return [ String ] an empty string with whitespace stripped
      def read_failed_line(example)
        ''.strip
      end

      # The dump_failure_for_example method constructs a formatted failure
      # message for a test example.
      #
      # This method generates a detailed error report that includes the failing
      # line of code, the exception class name, and the exception message. It
      # processes the execution result
      # of a test example to extract relevant information about why the test failed.
      #
      # @param example [ Object ] the test example object containing execution results
      #
      # @return [ String ] a formatted string containing the failure details including
      #         the failing line, exception class, and exception message
      def dump_failure_for_example(example)
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

      # The format_backtrace method processes and formats the backtrace
      # information for an example.
      #
      # This method extracts the backtrace from the exception associated with
      # an example, applies optional filtering based on a limit, and formats
      # each line using relative paths. It can optionally wrap the formatted
      # backtrace with folding markers when requested.
      #
      # @param example [ Object ] the example object containing the exception with backtrace
      # @param folding [ TrueClass, FalseClass ] whether to wrap the backtrace with folding markers
      # @param limit [ Integer, nil ] the maximum number of backtrace lines to include
      #
      # @return [ String ] the formatted backtrace as a string with lines separated by newlines
      def format_backtrace(example, folding: false, limit: nil)
        backtrace = execution_result(example).exception.backtrace
        backtrace.nil? and return ''
        if limit
          backtrace = backtrace[0, limit]
        end
        result = []
        folding and result << '{{{'
        for line in backtrace
          result << RSpec::Core::Metadata::relative_path(line)
        end
        folding and result << '}}}'
        result * ?\n
      end

      # The dump_failure_to_error_file method writes failure information to an
      # error log file.
      #
      # This method records detailed information about a failed test example,
      # including the location, runtime, description, failure details, and
      # backtrace. It uses file locking to ensure thread-safe writing to the
      # error log file.
      #
      # @param example [ Object ] the test example that failed
      def dump_failure_to_error_file(example)
        @errors_lst.flock File::LOCK_EX
        @errors_lst.puts "%s\n%3.3fs %s\n%s\n%s" % [
          location(example), run_time(example), description(example, full: true),
          dump_failure_for_example(example), format_backtrace(example, folding: true)
        ]
      ensure
        @errors_lst.flock File::LOCK_UN
      end

      # The execution_result method retrieves the execution result metadata
      # from an example.
      #
      # This method accesses the metadata hash associated with the example's
      # underlying test case to extract the execution result information that
      # was stored during test execution.
      #
      # @param example [ Object ] the example object containing test metadata
      #
      # @return [ Object ] the execution result metadata stored in the example's metadata hash
      def execution_result(example)
        example.example.metadata[:execution_result]
      end

      # The description method retrieves either the full or abbreviated
      # description of an example.
      #
      # @param example [ Object ] the example object containing description
      # information
      # @param full [ TrueClass, FalseClass ] determines whether to return the
      # full description or abbreviated version
      #
      # @return [ String ] the appropriate description based on the full parameter value
      def description(example, full: ENV['VERBOSE'].to_i == 1)
        if full
          example.example.full_description
        else
          example.example.description
        end
      end

      # The run_time method retrieves the execution time of a test example.
      #
      # This method accesses the execution result of a given test example and
      # returns the run time associated with that execution.
      #
      # @param example [ Object ] the test example object to get run time for
      #
      # @return [ Float, nil ] the execution time of the example or nil if not available
      def run_time(example)
        execution_result(example).run_time
      end

      # The format_line method formats and colors test execution results for
      # display.
      #
      # This method takes a test example and creates a formatted string that
      # includes the location, run time, and description of the test. It
      # applies color coding based on the test result status and ensures the
      # output fits within the terminal width.
      #
      # @param example [ Object ] the test example to format
      #
      # @return [ String ] the formatted and colorized test result string
      def format_line(example)
        status = execution_result(example).status
        status_emoji = Hash.new { ?❔ }.merge(
          passed: ?✅,
          failed: ?❌,
          pending: ?⏩
        )
        args = [ status_emoji[status], location(example), run_time(example), description(example) ]
        uncolored = "%s %s # %3.3fs %s" % args
        uncolored = uncolored[0, Tins::Terminal.columns]
        case status
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

      # The success_color method applies green color formatting to the provided
      # text.
      #
      # This method wraps the input text with ANSI color codes to display it in
      # green, which is typically used to indicate successful or positive
      # outcomes in terminal output.
      #
      # @param text [ String ] the text to be formatted with green color
      #
      # @return [ String ] the input text wrapped with green color ANSI escape codes
      def success_color(text)
        Term::ANSIColor.green(text)
      end

      # The failure_color method applies red color formatting to the provided
      # text.
      #
      # This method wraps the input text with red color codes using the
      # Term::ANSIColor library, making the text appear in red when displayed
      # in compatible terminals.
      #
      # @param text [ String ] the text to be colorized in red
      #
      # @return [ String ] the colorized text wrapped with red formatting codes
      def failure_color(text)
        Term::ANSIColor.red(text)
      end

      # The pending_color method applies yellow color formatting to the
      # provided text.
      #
      # This method wraps the input text with yellow color codes using the
      # Term::ANSIColor library, making the text appear in yellow when
      # displayed in compatible terminals.
      #
      # @param text [ String ] the text to be colorized
      #
      # @return [ String ] the colorized text with yellow formatting applied
      def pending_color(text)
        Term::ANSIColor.yellow(text)
      end

      # The location method extracts and formats the file path and line number
      # for an RSpec example.
      #
      # This method retrieves the location information from the example's
      # metadata, handling cases where the location might be nested within the
      # example group. It then processes the location to return a relative path
      # using RSpec's metadata helper.
      #
      # @param example [ Object ] the RSpec example object containing metadata
      #
      # @return [ String ] the relative file path and line number for the example
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
