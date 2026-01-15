require 'term/ansicolor'
require 'tempfile'
require 'digest/md5'
require 'fileutils'
require 'mize'
class Utils::Finder
end
require 'utils/finder/files'

# A class for finding and searching files with configurable patterns and
# filters.
#
# This class provides functionality for traversing file systems to locate files
# based on various criteria including file extensions, directory pruning, and
# pattern matching. It supports both indexed and direct search approaches to
# optimize performance when dealing with large codebases or frequently accessed
# file sets.
#
# @example
#   finder = Utils::Finder.new(args: { l: true }, roots: ['.'])
#   finder.search
class Utils::Finder
  include Term::ANSIColor
  include Utils::Patterns
  include Utils::Finder::Files


  # Initializes a new Finder instance with the specified options.
  #
  # Configures the finder to search either specific files or directories based on
  # the provided arguments. Handles command-line argument parsing and pattern
  # configuration for search operations.
  #
  # @example Basic usage with root directories
  #   finder = Utils::Finder.new(args: { l: true }, roots: ['.'])
  #
  # @example Usage with specific files
  #   finder = Utils::Finder.new(args: { l: true }, files: ['file1.rb', 'file2.rb'])
  #
  # @param opts [Hash] configuration options
  # @option opts [Hash] :args Command-line arguments hash
  # @option opts [Array<String>] :roots Root directories to search
  # @option opts [Array<String>] :files Specific files to process
  # @option opts [Utils::ConfigFile] :config (Utils::ConfigFile.new) Configuration object
  # @option opts [Hash] :pattern Pattern-related options
  # @option opts [String] :pattern :cset Character set for pattern matching
  # @option opts [Boolean] :pattern :icase Case insensitive matching
  #
  # @raise [ArgumentError] When both :roots and :files are specified
  #
  # @return [Utils::Finder] A configured finder instance ready for search operations
  def initialize(opts = {})
    @args  = opts[:args] || {}
    if opts[:files]
      opts[:roots] and raise ArgumentError, "Require :roots xor :files argument"
      @files = opts[:files]
    else
      @roots = discover_roots(opts[:roots])
    end
    @config = opts[:config] || Utils::ConfigFile.new
    if @args[?l] || @args[?L]
      @pattern = nil
    else
      pattern_opts = opts.subhash(:pattern) | {
        :cset  => @args[?a],
        :icase => @args[?i] != ?n,
      }
      @pattern = choose(@args[?p], pattern_opts)
    end
    @paths  = []
    reset_index
  end

  # The paths reader method provides access to the array of file paths that
  # have been processed or collected.
  #
  # This method returns the internal array containing the file paths, allowing
  # external code to read the current set of paths without modifying the
  # original collection.
  #
  # @return [ Array<String> ] an array of file path strings that have been processed or collected
  attr_reader :paths

  # The output reader method provides access to the output value.
  #
  # @return [ Object ] the output value that was set previously
  attr_reader :output

  # The build_paths method constructs a list of file system paths by traversing
  # the configured root directories.
  #
  # This method iterates through the specified root directories and collects
  # all file system entries, applying filtering logic to exclude certain
  # directories and files based on configuration settings.
  # It handles both regular files and directories, ensuring that directory
  # entries are properly marked with a trailing slash for distinction. The
  # resulting paths are deduplicated before being returned.
  #
  # @return [ Array<String> ] an array of file system path strings, with directories
  # marked by a trailing slash
  def build_paths
    paths = Set[]
    each_path { |path| paths << path }
    paths.sort
  end

  # The search_paths method processes and filters a collection of file paths
  # based on specified criteria.
  #
  # This method takes an array of paths and applies filtering based on file
  # extensions and patterns. It handles both fuzzy and regular expression
  # pattern matching, and returns formatted results with optional sorting and
  # limiting of results.
  #
  # @param paths [ Array<String> ] the collection of file paths to be processed
  #
  # @return [ Utils::Finder ] returns self to allow for method chaining
  def search_paths(paths)
    suffixes = Array(@args[?I])
    suffixes.full? do |s|
      paths.select! { |path| s.include?(File.extname(path)[1..-1]) }
    end
    paths = paths.map do |path|
      if @pattern.nil?
        [ [ path.count(?/), path ], path, path ]
      elsif match = @pattern.match(path)
        if FuzzyPattern === @pattern
          current = 0
          marked_path = ''
          score, e = path.size, nil
          for i in 1...match.size
            match[i] or next
            b = match.begin(i)
            e ||= b
            marked_path << path[current...b]
            marked_path << red(path[b, 1])
            score += (b - e) * (path.size - b)
            e = match.end(i)
            current = b + 1
          end
          marked_path << match.post_match
          [ score, path, marked_path ]
        else
          marked_path = path[0...match.begin(0)] <<
            red(path[match.begin(0)...match.end(0)]) <<
            path[match.end(0)..-1]
          [ 0, path, marked_path ]
        end
      end
    end
    paths.compact!
    @paths, @output = paths.sort.transpose.values_at(-2, -1)
    if n = @args[?n]&.to_i
      @paths = @paths&.first(n) || []
      @output = @output&.first(n) || []
    end
    self
  end

  # The search method executes a file search operation using pre-loaded paths
  # and configured patterns
  #
  # This method leverages previously loaded file paths and applies the
  # configured search patterns to filter and process the files. It serves as
  # the main entry point for performing search operations within the configured
  # file system scope.
  #
  # @return [ Utils::Finder ] returns self to allow for method chaining
  def search
    search_paths current_paths
  end
end
