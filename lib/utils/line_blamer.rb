module Utils
  class LineBlamer
    def initialize(file, lineno = 1)
      @file, @lineno = file, lineno
    end

    def self.for_line(line)
      location = line.source_location and new *location
    end

    def self.blame(line)
      blamer = for_line(line)
      if blame = blamer.perform
        blame.sub!(/^[0-9a-f^]+/) { Term::ANSIColor.yellow($&) }
        blame.sub!(/\(([^)]+)\)/) { "(#{Term::ANSIColor.red($1)})" }
      end
    end

    def perform(options = '')
      `git 2>/dev/null blame #{options} -L #@lineno,+1 "#@file"`.full?
    end
  end
end
