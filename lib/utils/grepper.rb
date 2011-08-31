require 'term/ansicolor'
require 'spruz/xt'

class ::File
  include Utils::FileXt
end

class Utils::Grepper
  include Utils::Patterns
  include Term::ANSIColor

  class Queue
    def initialize(max_size)
      @max_size, @data = max_size, []
    end

    attr_reader :max_size

    def data
      @data.dup
    end

    def push(x)
      @data.shift if @data.size > @max_size
      @data << x
      self
    end
    alias << push
  end

  def initialize(opts = {})
    @args  = opts[:args] || {}
    @roots = opts[:roots] || []
    @config = opts[:config] || Utils::Config::ConfigFile.new
    if n = @args.values_at(*%w[A B C]).compact.first
      if n.to_s =~ /\A\d+\Z/ and (n = n.to_i) >= 1
        @queue = Queue.new n
      else
        raise ArgumentError, "needs to be an integer number >= 1"
      end
    end
    @pathes  = []
    pattern_opts = opts.subhash(:pattern) | {
      :cset  => @args['a'],
      :icase => @args['i'],
    }
    @pattern = @args['R'] ?
      FuzzyPattern.new(pattern_opts) :
      RegexpPattern.new(pattern_opts)
    @name_pattern =
      if name_pattern = @args['N']
        RegexpPattern.new(:pattern => name_pattern)
      elsif name_pattern = @args['n']
        FuzzyPattern.new(:pattern => name_pattern)
      end
    @skip_pattern =
      if skip_pattern = @args['S']
        RegexpPattern.new(:pattern => skip_pattern)
      elsif skip_pattern = @args['s']
        FuzzyPattern.new(:pattern => skip_pattern)
      end
  end

  attr_reader :pathes

  def match(filename)
    @filename = filename
    @output = []
    bn, s = File.basename(filename), File.stat(filename)
    if s.directory? && @config.search.prune?(bn)
      $DEBUG and warn "Pruning #{filename.inspect}."
      Utils::Find.prune
    end
    if s.file? && !@config.search.skip?(bn) && (!@name_pattern || @name_pattern.match(bn))
      File.open(filename, 'rb') do |file|
        if file.binary? != true
          $DEBUG and warn "Matching #{filename.inspect}."
          match_lines file
        else
          $DEBUG and warn "Skipping binary file #{filename.inspect}."
        end
      end
    else
      $DEBUG and warn "Skipping #{filename.inspect}."
    end
    unless @output.empty?
      case
      when @args['l'], @args['e']
        @output.uniq!
        @pathes.concat @output
      else
        STDOUT.puts @output
      end
      @output.clear
    end
    self
  rescue SystemCallError => e
    warn "Caught #{e.class}: #{e}"
    nil
  end

  def match_lines(file)
    for line in file
      if m = @pattern.match(line)
        @skip_pattern and @skip_pattern =~ line and next
        line[m.begin(0)...m.end(0)] = black on_white m[0]
        @queue and @queue << line
        if @args['l']
          @output << @filename
        elsif @args['L']
          @output << "#{@filename}:#{file.lineno}"
        elsif @args['e']
          @output << "#{@filename}:#{file.lineno}"
          break
        else
          @output << red("#{@filename}:#{file.lineno}")
          if @args['B'] or @args['C']
            @output.concat @queue.data
          else
            @output << line
          end
          if @args['A'] or @args['C']
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

  def search
    @suffix = @args['I']
    for dir in @roots
      Utils::Find.find(dir) do |filename|
        if !@suffix || @suffix == File.extname(filename)[1..-1]
          match(filename)
        end
      end
    end
    if @args['L'] or @args['e']
      @pathes = @pathes.sort_by do |path|
        pair = path.split(':')
        pair[1] = pair[1].to_i
        pair
      end
    else
      @pathes.sort!
    end
    self
  end
end
