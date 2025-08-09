require 'term/ansicolor'
require 'tempfile'
require 'digest/md5'
require 'fileutils'
require 'mize'

class Utils::Finder
  include Tins::Find
  include Utils::Patterns
  include Term::ANSIColor

  # The initialize method sets up the finder instance with the provided options.
  #
  # This method configures the finder by processing the input options,
  # including arguments, root directories, and pattern settings. It initializes
  # the pattern matcher based on the specified options and prepares the index
  # for searching.
  #
  # @param opts [ Hash ] the options hash containing configuration settings
  # @option opts [ Hash ] :args the argument options for the finder
  # @option opts [ Array ] :roots the root directories to search in
  # @option opts [ Utils::ConfigFile ] :config the configuration file object
  def initialize(opts = {})
    @args  = opts[:args] || {}
    @roots = discover_roots(opts[:roots])
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
  # @return [ Array ] an array of file system path strings, with directories
  # marked by a trailing slash
  def build_paths
    paths = []

    visit = -> filename {
      s  = filename.stat
      bn = filename.pathname.basename
      if !s ||
          s.directory? && @config.discover.prune?(bn) ||
          s.file? && @config.discover.skip?(bn)
      then
        @args[?v] and warn "Pruning #{filename.inspect}."
        prune
      end
      true
    }
    find(*@roots, visit: visit) do |filename|
      filename.stat.directory? and filename << ?/
      paths << filename
    end
    paths.uniq!
    paths
  end

  # The index_path method generates a unique file path for storing finder
  # results.
  #
  # This method creates a standardized location in the temporary directory for
  # caching finder path data based on the root directories being processed.
  # It ensures uniqueness by hashing the sorted root paths and uses the current
  # script name as part of the directory structure.
  #
  # @return [ String ] the full file path where finder results should be stored
  def index_path
    roots = @roots.map { |r| File.expand_path(r) }.uniq.sort
    filename = "finder-paths-" +
      Digest::MD5.new.update(roots.inspect).hexdigest
    dirname = File.join(Dir.tmpdir, File.basename($0))
    FileUtils.mkdir_p dirname
    File.join(dirname, filename)
  end

  # The create_paths method generates and stores path information by building a
  # list of paths, writing them to a secure file, and then returning the list
  # of paths.
  #
  # @return [ Array ] an array containing the paths that were built and written
  # to the index file
  def create_paths
    paths = build_paths
    File.secure_write(index_path) do |output|
      output.puts paths
    end
    paths
  end

  # The load_paths method reads and processes indexed file paths from disk.
  #
  # This method loads lines from the index file path, removes trailing
  # whitespace, and filters out directory entries if the debug flag is not set.
  # It returns create_paths if the index file is empty or missing,
  # otherwise it returns the processed list of file paths.
  #
  # @return [ Array<String> ] an array of file paths loaded from the index
  memoize method:
  def load_paths
    lines = File.readlines(index_path)
    @args[?v] and warn "Loaded index #{index_path.inspect}."
    lines.empty? and raise Errno::ENOENT
    @args[?d] or lines = lines.grep_v(%r{/$})
    lines.map(&:chomp!)
  rescue Errno::ENOENT
    return create_paths
  end

  # The reset_index method resets the index file by removing it if the reset
  # flag is set or if the index has expired.
  #
  # This method checks whether the reset argument flag is set or if the index
  # file has expired based on its modification time.
  # If either condition is true, it removes the index file from the filesystem
  # and clears the mize cache. The method then returns the instance itself to
  # allow for method chaining.
  #
  # @return [ Utils::Finder ] returns self to allow for method chaining
  def reset_index
    path = index_path
    if @args[?r] || index_expired?(path)
      @args[?v] and warn "Resetting index #{path.inspect}."
      FileUtils.rm_f path
      mize_cache_clear
    end
    self
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
    paths = paths.map! do |path|
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

  # The search_directly method performs a direct search by building paths and
  # then searching through them.
  #
  # This method first constructs the list of paths to be searched and then
  # executes the search operation on those paths, returning the results of the
  # search.
  #
  # @return [ Object ] the result of the search operation performed on the built paths
  def search_directly
    search_paths build_paths
  end

  # The search_index method performs a pattern search across previously loaded
  # paths.
  #
  # This method utilizes the loaded paths from the internal storage to execute
  # a search operation, applying the configured pattern matching criteria to
  # filter and return relevant results based on the current search
  # configuration.
  def search_index
    search_paths load_paths
  end

  alias search search_index

  private

  # The index_expired? method checks whether the index file has exceeded its
  # expiration duration.
  #
  # This method determines if the specified index file is considered expired
  # based on the configured discovery index expiration time. It compares the
  # current time with the modification time of the file to make this
  # determination.
  #
  # @param path [ String ] the filesystem path to the index file being checked
  #
  # @return [ TrueClass, FalseClass ] true if the index file has expired, false otherwise
  def index_expired?(path)
    if duration = @config.discover.index_expire_after
      Time.now - duration >= File.mtime(path)
    else
      false
    end
  rescue Errno::ENOENT
    false
  end

  # The discover_roots method processes an array of root patterns and expands
  # them into actual directory paths.
  #
  # This method takes an array of root patterns, which may include glob patterns,
  # and uses Dir[r] to expand each pattern into matching directory paths.
  # It handles the case where the input roots array is nil by defaulting to an
  # empty array.
  #
  # @param roots [ Array<String>, nil ] an array of root patterns or nil
  #
  # @return [ Array<String> ] an array of expanded directory paths that match
  # the input patterns
  def discover_roots(roots)
    roots ||= []
    roots.inject([]) { |rs, r| rs.concat Dir[r] }
  end
end
