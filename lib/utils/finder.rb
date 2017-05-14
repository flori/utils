require 'term/ansicolor'
require 'tins/xt'

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
      :icase => @args.fetch('i', true),
    }
    @pattern = choose(@args[?p], pattern_opts)
    p @pattern
    @paths  = []
  end

  attr_reader :paths

  attr_reader :output

  def ascii_file?(stat, path)
    stat.file? && (@binary || stat.size == 0 || File.ascii?(path))
  end

  def attempt_match?(path)
    stat = path.stat
    stat.symlink? and stat = path.lstat
    stat.directory? || ascii_file?(stat, path)
  rescue SystemCallError => e
    warn "Caught #{e.class}: #{e}"
    nil
  end

  def search
    paths = []
    suffixes = @args[?I].ask_and_send(:split, /[\s,]+/).to_a
    find(*(@roots + [ { :suffix => suffixes } ])) do |filename|
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
        paths << filename
      end
    end
    paths.uniq!
    paths.map! { |p| a = File.split(p) ; a.unshift(p) ; a }
    paths = paths.map! do |path, dir, file|
      if do_match = attempt_match?(path) and @args[?v]
        warn "Attempt match of #{path.inspect}"
      end
      if do_match and match = @pattern.match(path)
        if FuzzyPattern === @pattern
          current = 0
          marked_file = ''
          score, e = 0, 0
          for i in 1...(match.size)
            match[i] or next
            b = match.begin(i)
            marked_file << path[current...b]
            marked_file << red(path[b, 1])
            score += (b - e)
            e = match.end(i)
            current = b + 1
          end
          marked_file << match.post_match
          [ score, file.size, path, File.join(dir, marked_file) ]
        else
          marked_file = path[0...match.begin(0)] <<
            red(path[match.begin(0)...match.end(0)]) <<
            path[match.end(0)..-1]
          [ 0, file.size, path, File.join(dir, marked_file) ]
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
