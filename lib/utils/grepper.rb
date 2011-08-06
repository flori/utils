require 'term/ansicolor'
require 'spruz/xt'

class ::String
  include Term::ANSIColor
end

class ::File
  include Utils::FileXt
end

class Utils::Grepper
  PRUNE = /\A(\.svn|\.git|CVS|tmp)\Z/
  SKIP  = /(\A\.|\.sw[pon]\Z|~\Z)/

  include Utils::Patterns

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
    bn = File.basename(filename)
    @output = []
    s = File.stat(filename)
    if s.directory? && bn =~ PRUNE
      $DEBUG and warn "Pruning '#{filename}'."
      Utils::Find.prune
    end
    if s.file? && bn !~ SKIP && (!@name_pattern || @name_pattern.match(bn))
      File.open(filename, 'rb') do |file|
        if file.binary? != true
          $DEBUG and warn "Matching '#{filename}'."
          match_lines file
        else
          $DEBUG and warn "Skipping binary file '#{filename}'."
        end
      end
    else
      $DEBUG and warn "Skipping '#{filename}'."
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
        line[m.begin(0)...m.end(0)] = m[0].black.on_white
        @queue and @queue << line
        if @args['l']
          @output << @filename
        elsif @args['L'] or @args['e']
          @output << "#{@filename}:#{file.lineno}"
        else
          @output << "#{@filename}:#{file.lineno}".red
          if @args['B'] or @args['C']
            @output.concat @queue.data
          else
            @output << line
          end
          if @args['A'] or @args['C']
            where = file.tell
            @queue.max_size.times do
              file.eof? and break
              line = file.readline
              @queue << line
              @output << line
            end
            file.seek where
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
    @pathes.sort!
    self
  end
end
