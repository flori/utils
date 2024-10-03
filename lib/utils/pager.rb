require 'tins'

module Utils
  module Pager
    module_function

    def pager(command: nil, lines: nil, &block)
      if block
        if my_pager = pager(command:, lines:)
          IO.popen(my_pager, 'w') do |output|
            output.sync = true
            yield output
            output.close
          end
        else
          yield STDOUT
        end
      else
        return unless STDOUT.tty?
        if lines
          if lines >= Tins::Terminal.lines
            pager(command:)
          end
        else
          command
        end
      end
    end
  end
end
