class Utils::LinesFile
  def self.for_filename(filename, linenumber = nil)
    new(File.new(filename, 'r'), linenumber)
  end
  
  def initialize(file, linenumber)
    @file = file
    @linenumber = (linenumber || 1).to_i
  end
  
  attr_accessor :linenumber

  def line
    index = @linenumber.to_i - 1
    @file.rewind
    @file.each_with_index do |line, i|
      index == i and return line
    end
    nil
  end

  def match_backward(regexp)
    @linenumber = @linenumber.to_i
    while @linenumber > 0
      line =~ regexp and return $~.captures
      @linenumber -= 1
    end
  end
end
