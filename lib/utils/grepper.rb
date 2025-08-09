require 'term/ansicolor'

class Utils::Grepper
  include Tins::Find
  include Utils::Patterns
  include Term::ANSIColor

  class Queue
    # The initialize method sets up a new instance with the specified maximum
    # size and empty data array.
    #
    # @param max_size [ Integer ] the maximum size limit for the data storage
    def initialize(max_size)
      @max_size, @data = max_size, []
    end

    # The max_size reader method provides access to the maximum size value.
    #
    # @return [ Integer ] the maximum size value stored in the instance
    attr_reader :max_size

    # The data method returns a duplicate of the internal data array.
    #
    # This method provides access to the internal @data instance variable by
    # returning a shallow copy of the array, ensuring that external
    # modifications do not affect the original data structure.
    #
    # @return [ Array ] a duplicate of the internal data array
    def data
      @data.dup
    end

    # The push method adds an element to the queue and removes the oldest
    # element if the maximum size is exceeded.
    #
    # @param x [ Object ] the element to be added to the queue
    #
    # @return [ Queue ] returns self to allow for method chaining
    def push(x)
      @data.shift if @data.size > @max_size
      @data << x
      self
    end
    alias << push
  end

  # The initialize method sets up the grepper instance with the provided
  # options.
  #
  # This method configures the grepper by processing the input options, setting up
  # the root directories for searching, initializing the configuration, and
  # preparing pattern matchers for filename and skip patterns. It also handles
  # queue initialization for buffering output when specified.
  #
  # @param opts [ Hash ] the options hash containing configuration settings
  # @option opts [ Hash ] :args the command-line arguments
  # @option opts [ Array ] :roots the root directories to search
  # @option opts [ Utils::ConfigFile ] :config the configuration file object
  # @option opts [ Hash ] :pattern the pattern-related options
  #
  # @return [ Utils::Grepper ] a new grepper instance configured with the
  # provided options
  def initialize(opts = {})
    @args  = opts[:args] || {}
    @roots = discover_roots(opts[:roots])
    @config = opts[:config] || Utils::ConfigFile.new
    if n = @args.values_at(*%w[A B C]).compact.first
      if n.to_s =~ /\A\d+\Z/ and (n = n.to_i) >= 1
        @queue = Queue.new n
      else
        raise ArgumentError, "needs to be an integer number >= 1"
      end
    end
    @paths  = []
    pattern_opts = opts.subhash(:pattern) | {
      :cset  => @args[?a],
      :icase => @args[?i] != ?n,
    }
    @pattern = choose(@args[?p], pattern_opts, default: ?r)
    @name_pattern =
      if name_pattern = @args[?N]
        RegexpPattern.new(:pattern => name_pattern)
      elsif name_pattern = @args[?n]
        FuzzyPattern.new(:pattern => name_pattern)
      end
    @skip_pattern =
      if skip_pattern = @args[?S]
        RegexpPattern.new(:pattern => skip_pattern)
      elsif skip_pattern = @args[?s]
        FuzzyPattern.new(:pattern => skip_pattern)
      end
  end

  # The paths reader method provides access to the paths instance variable.
  #
  # @return [ Array ] the array of paths stored in the instance variable
  attr_reader :paths

  # The pattern reader method provides access to the pattern matcher object.
  #
  # This method returns the internal pattern matcher that was initialized
  # during object creation, allowing external code to interact with the pattern
  # matching functionality directly.
  #
  # @return [ Utils::Patterns::Pattern ] the pattern matcher object used for
  # matching operations
  attr_reader :pattern

  # The match method processes a file to find matching content based on
  # configured patterns.
  # It handles directory pruning, file skipping, and various output formats
  # depending on the configuration.
  # The method opens files for reading, applies pattern matching, and manages
  # output through different code paths.
  # It supports features like line-based searching, git blame integration, and
  # multiple output modes.
  # The method returns the instance itself to allow for method chaining.
  #
  # @return [ Utils::Grepper ] returns self to allow for method chaining
  def match(filename)
    @filename = filename
    @output = []
    bn, s = File.basename(filename), File.stat(filename)
    if !s || s.directory? && @config.search.prune?(bn)
      @args[?v] and warn "Pruning #{filename.inspect}."
      prune
    end
    if s.file? && !@config.search.skip?(bn) &&
      (!@name_pattern || @name_pattern.match(bn))
    then
      File.open(filename, 'rb', encoding: Encoding::UTF_8) do |file|
        @args[?v] and warn "Matching #{filename.inspect}."
        if @args[?f]
          @output << filename
        else
          match_lines file
        end
      end
    else
      @args[?v] and warn "Skipping #{filename.inspect}."
    end
    unless @output.empty?
      case
      when @args[?g]
        @output.uniq!
        @output.each do |l|
          blamer = LineBlamer.for_line(l)
          if blame = blamer.perform
            author = nil
            blame.sub!(/^[0-9a-f^]+/) { Term::ANSIColor.yellow($&) }
            blame.sub!(/\(([^)]+)\)/) { author = $1; "(#{Term::ANSIColor.red($1)})" }
            if !@args[?G] || author&.downcase&.match?(@args[?G].downcase)
              puts "#{blame.chomp} #{Term::ANSIColor.blue(l)}"
            end
          end
        end
      when @args[?l], @args[?e], @args[?E], @args[?r]
        @output.uniq!
        @paths.concat @output
      else
        STDOUT.puts @output
      end
      @output.clear
    end
    self
  end

  # The match_lines method processes each line from a file using pattern
  # matching.
  #
  # This method iterates through lines in the provided file, applying pattern
  # matching to identify relevant content. It handles various output options
  # based on command-line arguments and manages queuing of lines for context
  # display.
  #
  # @param file [IO] the file object to be processed line by line
  def match_lines(file)
    for line in file
      if m = @pattern.match(line)
        @skip_pattern and @skip_pattern =~ line and next
        line[m.begin(0)...m.end(0)] = black on_white m[0]
        @queue and @queue << line
        case
        when @args[?l]
          @output << @filename
        when @args[?L], @args[?r], @args[?g]
          @output << "#{@filename}:#{file.lineno}"
        when @args[?e], @args[?E]
          @output << "#{@filename}:#{file.lineno}"
          break
        else
          @output << red("#{@filename}:#{file.lineno}")
          if @args[?B] or @args[?C]
            @output.concat @queue.data
          else
            @output << line
          end
          if @args[?A] or @args[?C]
            where = file.tell
            lineno = file.lineno
            @queue.max_size.times do
              file.eof? and break
              line = file.readline
              @queue << line
              @output << line
            end
            file.seek where
            file.lineno = lineno
          end
        end
      else
        @queue and @queue << line
      end
    end
  end

  # The search method performs a file search operation within specified roots,
  # filtering results based on various criteria including file extensions,
  # pruning directories, and skipping specific files.
  #
  # It utilizes a visit lambda to determine whether each file or directory
  # should be processed or skipped based on configuration settings and
  # command-line arguments. The method employs the find utility to traverse
  # the filesystem, executing match operations on qualifying files.
  #
  # @return [ Utils::Grepper ] returns self to allow for method chaining
  def search
    suffixes = Array(@args[?I])
    visit = -> filename {
      s  = filename.lstat
      bn = filename.pathname.basename
      if !s ||
          s.directory? && @config.search.prune?(bn) ||
          (s.file? || s.symlink?) && @config.search.skip?(bn) ||
          @args[?F] && s.symlink?
      then
        @args[?v] and warn "Pruning #{filename.inspect}."
        prune
      elsif suffixes.empty?
        true
      else
        suffixes.include?(filename.suffix)
      end
    }
    find(*@roots, visit: visit) do |filename|
      match(filename)
    end
    @paths = @paths.sort_by(&:source_location)
    self
  end

  private

  # The discover_roots method processes an array of root patterns and expands
  # them into actual directory paths.
  #
  # This method takes an array of root patterns, which may include glob
  # patterns, and uses Dir[r] to expand each pattern into matching directory
  # paths.
  # It handles the case where the input roots array is nil by defaulting to an
  # empty array. The expanded paths are then concatenated into a single result
  # array.
  #
  # @param roots [ Array<String>, nil ] an array of root patterns or nil
  #
  # @return [ Array<String> ] an array of expanded directory paths matching the input patterns
  def discover_roots(roots)
    roots ||= []
    roots.inject([]) { |rs, r| rs.concat Dir[r] }
  end
end
