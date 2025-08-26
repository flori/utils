module Utils
  # A class for analyzing and retrieving git blame information for specific
  # lines of code.
  #
  # This class provides functionality to initialize with a file path and line
  # number, and then perform git blame operations to obtain information about
  # when and by whom that specific line was last modified. It serves as a
  # utility for developers to quickly access historical context for individual
  # lines of code within their projects.
  class LineBlamer
    # Initializes a new LineBlamer instance to analyze source code line
    # information.
    #
    # @param file [ String ] the path to the file containing the line of code
    # @param lineno [ Integer ] the line number within the file (defaults to 1)
    def initialize(file, lineno = 1)
      @file, @lineno = file, lineno
    end

    # Finds the source location of a line and creates a new LineBlamer instance.
    #
    # This method extracts the file path and line number from the given line
    # object using its source_location method. If a valid location is found, it
    # initializes and returns a new LineBlamer instance with the extracted file
    # path and line number.
    #
    # @param line [ Object ] the line object to analyze for source location
    # information
    #
    # @return [ Utils::LineBlamer, nil ] a new LineBlamer instance if the line
    # has a valid source location, otherwise nil
    def self.for_line(line)
      location = line.source_location and new(*location)
    end

    # Performs git blame on a specific line of code and returns the result.
    #
    # This method executes a git blame command to analyze the specified file
    # and line number, retrieving information about when and by whom the line
    # was last modified. It handles potential errors from git by suppressing
    # stderr output and returns nil if git is not available or the operation
    # fails.
    #
    # @param options [ String ] additional options to pass to the git blame command
    #
    # @return [ String, nil ] the output of the git blame command if successful, otherwise nil
    def perform(options = '')
      `git 2>/dev/null blame #{options} -L #@lineno,+1 "#@file"`.full?
    end
  end
end
