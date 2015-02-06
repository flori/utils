module Utils
  class LineBlamer
    def initialize(file, lineno = 1)
      @file, @lineno = file, lineno
    end

    def self.for_line(line)
      location = line.source_location and new *location
    end

    def perform(options = '')
      `git blame #{options} -L #@lineno,+1 "#@file"`
    end
  end
end
