require 'term/ansicolor'
require 'tins/xt'

class ::File
  include Utils::FileXt
end

class Utils::Grepper
  include Tins::Find
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

  attr_reader :paths

  attr_reader :pattern

  def match(filename)
    @filename = filename
    @output = []
    bn, s = File.basename(filename), File.stat(filename)
    if !s || s.directory? && @config.search.prune?(bn)
      @args['v'] and warn "Pruning #{filename.inspect}."
      prune
    end
    if s.file? && !@config.search.skip?(bn) &&
      (!@name_pattern || @name_pattern.match(bn))
    then
      File.open(filename, 'rb') do |file|
        if file.binary? != true
          @args['v'] and warn "Matching #{filename.inspect}."
          if @args['f']
            @output << filename
          else
            match_lines file
          end
        else
          @args['v'] and warn "Skipping binary file #{filename.inspect}."
        end
      end
    else
      @args['v'] and warn "Skipping #{filename.inspect}."
    end
    unless @output.empty?
      case
      when @args['b']
        @output.uniq!
        @output.each do |l|
          blamer = LineBlamer.for_line(l)
          if blame = blamer.perform
            blame.sub!(/^[0-9a-f]+/) { Term::ANSIColor.yellow($&) }
            blame.sub!(/\(([^)]+)\)/) { "(#{Term::ANSIColor.red($1)})" }
            puts blame
          end
        end
      when @args['l'], @args['e'], @args['E'], @args['r']
        @output.uniq!
        @paths.concat @output
      else
        STDOUT.puts @output
      end
      @output.clear
    end
    self
  end

  def match_lines(file)
    for line in file
      if m = @pattern.match(line)
        @skip_pattern and @skip_pattern =~ line and next
        line[m.begin(0)...m.end(0)] = black on_white m[0]
        @queue and @queue << line
        case
        when @args['l']
          @output << @filename
        when @args['L'], @args['r'], @args['b']
          @output << "#{@filename}:#{file.lineno}"
        when @args['e'], @args['E']
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
    suffixes = @args['I'].ask_and_send(:split, /[\s,]+/).to_a
    find(*(@roots + [ { :suffix => suffixes } ])) do |filename|
      match(filename)
    end
    @paths = @paths.sort_by(&:source_location)
    self
  end

  private

  def discover_roots(roots)
    roots ||= []
    roots.inject([]) { |rs, r| rs.concat Dir[r] }
  end
end
