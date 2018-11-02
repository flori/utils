require 'term/ansicolor'
class Utils::InteractiveSearch
  include Term::ANSIColor

  def initialize(query:, found:, output: STDOUT, prompt: 'Search? %s')
    @query  = query
    @found  = found
    @output = output
    @prompt = prompt
    @answer = ''
  end

  def start
    @output.print clear_screen
    loop do
      @output.print move_home(@prompt % @answer)
      case getc
      when true
        @output.print clear_screen move_home reset
        return !!@found.(@answer)
      when false
        return false
      end
      result = @query.(@answer)
      @output.print clear_screen
      unless @answer.empty?
        @output.print clear_screen move_to_line(2, result)
      end
    end
  end

  private

  def getc
    system 'stty raw -echo'
    c = STDIN.getc
    system 'stty cooked echo'
    case c
    when "\x03", "\e"
      false
    when ?\r
      true
    when "\x7f"
      @answer.chop!
      nil
    when "\v"
      @answer.clear
    when /\A[\x00-\x1f]\z/
      nil
    else
      @answer << c
      nil
    end
  end
end
