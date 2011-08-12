class Utils::LinesFile
  module LineExtension
    attr_reader :line_number

    def filename
      lines_file.filename.dup
    end
  end

  include Enumerable

  def self.for_filename(filename, line_number = nil)
    obj = new(File.readlines(filename), line_number)
    obj.filename = filename
    obj
  end

  def self.for_file(file, line_number)
    obj = new(file.readlines, line_number)
    obj.filename = filename
    obj
  end

  def self.for_lines(lines, line_number = nil)
    new(lines, line_number)
  end

  def initialize(lines, line_number = nil)
    @lines = lines
    @lines.each_with_index do |line, i|
      line.extend LineExtension
      line.instance_variable_set :@line_number, i + 1
      line.instance_variable_set :@lines_file, self
    end
    self.line_number = line_number || (@lines.empty? ? 0 : 1)
  end

  attr_accessor :filename

  attr_reader :line_number

  def rewind
    self.line_number = 1
    self
  end

  def next!
    self.line_number += 1
    self
  end

  def previous!
    self.line_number -= 1
    self
  end

  def line_number=(number)
    number = number.to_i
    if number > 0 && number <= last_line_number
      @line_number = number
    end
  end

  def last_line_number
    @lines.size
  end

  def empty?
    @lines.empty?
  end

  def each(&block)
    @lines.empty? and return
    old_line_number = line_number
    1.upto(last_line_number) do |number|
      self.line_number = number
      block.call(line)
    end
    self
  ensure
    self.line_number = old_line_number
  end

  def line
    index = line_number - 1
    @lines[index] if index >= 0
  end

  def file_linenumber
    "#{filename}:#{line_number}"
  end

  def match_backward(regexp, previous_after_match = false)
    empty? and return
    while line_number >= 1
      if line =~ regexp
        previous_after_match and previous!
        return $~.captures
      end
      previous!
    end
  end

  def match_forward(regexp, next_after_match = false)
    empty? and return
    begin
      if line =~ regexp
        next_after_match and next!
        return $~.captures
      end
      next!
    end while line_number < last_line_number
  end

  def to_s
    "#{line_number} #{line.chomp}"
  end

  def inspect
    "#<#{self.class}: #{to_s.inspect}>"
  end
end
