require 'term/ansicolor'

class Utils::SearchUI
  include Term::ANSIColor

  def initialize(query:, found:, output: STDOUT, prompt: 'Search? %s')
    @query  = query
    @found  = found
    @output = output
    @prompt = prompt
    @answer = ''
  end

  def start
    @output.print clear_screen, move_home, reset
    loop do
      @output.print move_home { @prompt % @answer }
      case getc
      when true
        @output.print clear_screen, move_home, reset
        if result = @found.(@answer)
          return result
        else
          return nil
        end
      when false
        return nil
      end
      result = @query.(@answer)
      @output.print clear_screen
      unless @answer.empty?
        @output.print move_home { ?\n + result }
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
      nil
    when /\A[\x00-\x1f]\z/
      nil
    else
      @answer << c
      nil
    end
  end
end
