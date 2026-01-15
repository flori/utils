# A module that provides file system traversal and path management
# functionality for the Utils library.
#
# This module includes methods for discovering root directories, generating
# unique index paths, creating and loading file path caches, and resetting
# indexes based on configuration settings.
module Utils::Finder::Files
  include Utils::XDG
  include Tins::Find

  # The current_paths method retrieves the cached file paths from the index.
  #
  # This method loads and returns the file paths that have been previously
  # indexed and stored in the cache, providing quick access to the collection
  # of paths without reprocessing the file system.
  #
  # @return [ Array<String> ] an array of file path strings that were
  #   previously indexed and cached
  def current_paths
    load_paths
  end
  memoize method: :current_paths

  private

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
    roots = Array(roots)
    roots.inject([]) { |rs, r| rs.concat Dir[r] }
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
    filename = "finder-paths-" + Digest::MD5.new.update(roots.inspect).hexdigest
    XDG_CACHE_HOME.sub_dir_path('utils') + filename
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
  def load_paths
    if @files
      return @files
    end
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
    @files and return
    path = index_path
    if @args[?r] || index_expired?(path)
      @args[?v] and warn "Resetting index #{path.inspect}."
      FileUtils.rm_f path
      mize_cache_clear
    end
    self
  end

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
    @files and return false
    if duration = @config.discover.index_expire_after
      Time.now - duration >= File.mtime(path)
    else
      false
    end
  rescue Errno::ENOENT
    false
  end

  # The each_path_from_roots method iterates through root directories and
  # processes each file or directory while applying filtering logic based on
  # configuration settings.
  #
  # This method sets up a visit lambda that checks whether each file or
  # directory should be pruned or skipped based on the discover configuration's
  # prune and skip patterns. It uses the find utility to traverse the
  # filesystem starting from the configured root directories, applying the
  # visit logic to determine which entries to process and which to ignore. When
  # a directory is encountered, it appends a trailing slash to the filename for
  # distinction. The method yields each qualifying filename to the provided
  # block for further processing.
  #
  # @param block [ Proc ] the block to be executed for each qualifying filename
  #
  # @yield [ filename ] yields the filename to the provided block
  # @yieldparam filename [ String ] the path to the file or directory being processed
  def each_path_from_roots(&block)
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

    find(*@roots, visit:) do |filename|
      filename.directory? and filename << ?/
      yield filename
    end
  end

  # The each_path_from_files method iterates through a collection of file paths
  # and processes each one according to configured filtering rules
  #
  # This method takes an array of file paths and applies filtering logic based
  # on the discover configuration's skip patterns to determine whether each
  # file should be processed or skipped. It extends each filename with path
  # extension functionality and handles both regular files and directories
  # differently, appending a trailing slash to directory entries
  # before yielding them to the provided block for further processing
  #
  # @param block [ Proc ] the block to be executed for each qualifying filename
  #
  # @yield [ filename ] yields the filename to the provided block
  # @yieldparam filename [ String ] the path to the file or directory being processed
  def each_path_from_files(&block)
    @files.each do |filename|
      filename.extend(::Tins::Find::Finder::PathExtension)
      if filename.file?
        @config.discover.skip?(filename.pathname.basename) and next
      elsif filename.directory?
        filename << ?/
      end
      block.(filename)
    end
  end

  # The each_path method iterates through file paths based on configured roots
  # or pre-loaded files
  #
  # This method determines whether to process file paths from configured root
  # directories or from a pre-loaded collection of files, delegating to the
  # appropriate internal method based on the presence of root directories
  #
  # @param block [ Proc ] the block to be executed for each qualifying filename
  #
  # @yield [ filename ] yields the filename to the provided block
  # @yieldparam filename [ String ] the path to the file or directory being
  #   processed
  def each_path(&block)
    if @roots
      each_path_from_roots(&block)
    else
      each_path_from_files(&block)
    end
  end
end
