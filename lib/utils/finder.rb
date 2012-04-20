require 'term/ansicolor'
require 'tins/xt'

class ::File
  include Utils::FileXt
end

class Utils::Finder
  include Utils::Find
  include Utils::Patterns
  include Term::ANSIColor

  def initialize(opts = {})
    @args    = opts[:args] || {}
    @roots   = opts[:roots] || []
    @config = opts[:config] || Utils::Config::ConfigFile.new
    pattern_opts = opts.subhash(:pattern) | {
      :cset  => @args['a'],
      :icase => @args['i'],
    }
    @binary = @args['b']
    @pattern = @args['r'] ?
      RegexpPattern.new(pattern_opts) :
      FuzzyPattern.new(pattern_opts)
    @directory = @args['d']
    @only_directory = @args['D']
    @pathes  = []
  end

  attr_reader :pathes

  attr_reader :output

  def ascii_file?(stat, path)
    stat.file? && (@binary || stat.size == 0 || File.ascii?(path))
  end

  def attempt_match?(path)
    stat = path.stat
    stat.symlink? and stat = path.lstat
    if @only_directory
      stat.directory?
    elsif @directory
      stat.directory? || ascii_file?(stat, path)
    else
      ascii_file?(stat, path)
    end
  rescue SystemCallError => e
    warn "Caught #{e.class}: #{e}"
    nil
  end

  def search
    pathes = []
    suffixes = @args['I'].ask_and_send(:split, /[\s,]+/).to_a
    find(*@roots, :suffix => suffixes) do |filename|
      begin
        bn, s = filename.pathname.basename, filename.stat
        if s.directory? && @config.discover.prune?(bn)
          $DEBUG and warn "Pruning #{filename.inspect}."
          prune
        end
        if s.file? && @config.discover.skip?(bn)
          $DEBUG and warn "Skipping #{filename.inspect}."
          next
        end
        pathes << filename
      rescue SystemCallError => e
        warn "Caught #{e.class}: #{e}"
      end
    end
    pathes.uniq!
    pathes.map! { |p| a = File.split(p) ; a.unshift(p) ; a }
    pathes = pathes.map! do |path, dir, file|
      if do_match = attempt_match?(path) and $DEBUG
        warn "Attempt match of #{path.inspect}"
      end
      if do_match and match = @pattern.match(file)
        if FuzzyPattern === @pattern
          current = 0
          marked_file = ''
          score, e = 0, 0
          for i in 1...(match.size)
            match[i] or next
            b = match.begin(i)
            marked_file << file[current...b]
            marked_file << red(file[b, 1])
            score += (b - e)
            e = match.end(i)
            current = b + 1
          end
          marked_file << match.post_match
          [ score, file.size, path, File.join(dir, marked_file) ]
        else
          marked_file = file[0...match.begin(0)] <<
            red(file[match.begin(0)...match.end(0)]) <<
            file[match.end(0)..-1]
          [ 0, file.size, path, File.join(dir, marked_file) ]
        end
      end
    end
    pathes.compact!
    @pathes, @output = pathes.sort.transpose.values_at(-2, -1)
    if !@args['e'] && @output && !@output.empty?
      yield @output if block_given?
    end
    self
  end
end
