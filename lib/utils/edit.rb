module Utils
  module Edit
    module_function

    def locate_vim_binary
      case `uname -s`
      when /\Adarwin/i
        if File.directory?('/Applications')
          '/Applications/MacVim.app/Contents/MacOS/Vim'
        else
          'gvim'
        end
      else
        'gvim'
      end
    end

    def cmd(*parts)
      command = parts.inject([]) do |a, p|
        case
        when p == nil, p == []
          a
        when p.respond_to?(:to_ary)
          a.concat p.to_ary
        else
          a << p.to_s
        end
      end
      $DEBUG and warn command * ' '
      command
    end
  end
end
