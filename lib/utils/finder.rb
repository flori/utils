require 'term/ansicolor'
require 'tins/xt'
require 'tempfile'
require 'digest/md5'
require 'fileutils'

class ::File
  include Utils::FileXt
end

class Utils::Finder
  include Tins::Find
  include Utils::Patterns
  include Term::ANSIColor

  def initialize(opts = {})
    @args  = opts[:args] || {}
    @roots = discover_roots(opts[:roots])
    @config = opts[:config] || Utils::ConfigFile.new
    @binary = @args[?b]
    pattern_opts = opts.subhash(:pattern) | {
      :cset  => @args[?a],
      :icase => @args[?i] != ?n,
    }
    @pattern = choose(@args[?p], pattern_opts)
    @paths  = []
    @args[?r] and reset_index
  end

  attr_reader :paths

  attr_reader :output

  def ascii_file?(stat, path)
    stat.file? && (@binary || stat.size == 0 || File.ascii?(path))
  end

  def search_index
    paths = load_paths
    search_paths(paths)
  end

  alias search search_index

  def attempt_match?(path)
    stat = path.stat
    stat.symlink? and stat = path.lstat
    stat.directory? || ascii_file?(stat, path)
  rescue SystemCallError => e
    warn "Caught #{e.class}: #{e}"
    nil
  end

  def build_paths
    paths = []
    find(*@roots) do |filename|
      begin
        bn, s = filename.pathname.basename, filename.stat
        if !s || s.directory? && @config.discover.prune?(bn)
          @args[?v] and warn "Pruning #{filename.inspect}."
          prune
        end
        if s.file? && @config.discover.skip?(bn)
          @args[?v] and warn "Skipping #{filename.inspect}."
          next
        end
        s.directory? and filename << ?/
        paths << filename
      end
    end
    paths.uniq!
    paths.select! { |path| attempt_match?(path) }
    paths
  end

  def index_path
    roots = @roots.map { |r| File.expand_path(r) }.uniq.sort
    filename = "finder-paths-" +
      Digest::MD5.new.update(roots.inspect).hexdigest
    dirname = File.join(Dir.tmpdir, File.basename($0))
    FileUtils.mkdir_p dirname
    File.join(dirname, filename)
  end

  def create_paths
    paths = build_paths
    File.secure_write(index_path) do |output|
      output.puts paths
    end
    paths
  end

  def load_paths
    lines = File.readlines(index_path)
    @args[?v] and warn "Loaded index #{index_path.inspect}."
    lines.empty? and raise Errno::ENOENT
    @args[?d] or lines = lines.grep_v(%r{/$})
    lines.map(&:chomp!)
  rescue Errno::ENOENT
    return create_paths
  end

  def reset_index
    path = index_path
    @args[?v] and warn "Resetting index #{path.inspect}."
    FileUtils.rm_f path
  end

  def search_index
    search_paths load_paths
  end

  def search_directly
    search_paths build_paths
  end

  def search_paths(paths)
    suffixes = @args[?I].ask_and_send(:split, /[\s,]+/).to_a
    suffixes.full? do |s|
      paths.select! { |path| s.include?(File.extname(path)[1..-1]) }
    end
    paths = paths.map! do |path|
      if match = @pattern.match(path)
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
    self
  end

  private

  def discover_roots(roots)
    roots ||= []
    roots.inject([]) { |rs, r| rs.concat Dir[r] }
  end
end
