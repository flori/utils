require 'term/ansicolor'

class Utils::SearchUI
  include Term::ANSIColor

  def initialize(query:, found:, output: STDOUT, prompt: 'Search? %s')
    @selector = 0
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
        if result = @found.(@answer, @selector)
          return result
        else
          return nil
        end
      when false
        return nil
      end
      result = @query.(@answer, @selector)
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
    when "\x03"
      false
    when "\e"
      STDIN.getc == ?[ or return nil
      STDIN.getc =~ /\A([AB])\z/ or return nil
      if $1 == ?A
        @selector -= 1
      else
        @selector += 1
      end
      @selector = [ @selector, 0 ].max
      nil
    when ?\r
      true
    when "\x7f"
      @selector = 0
      @answer.chop!
      nil
    when "\v"
      @selector = 0
      @answer.clear
      nil
    when /\A[\x00-\x1f]\z/
      nil
    else
      @selector = 0
      @answer << c
      nil
    end
  end
end
