module Utils
  class Editor
    def initialize
      self.wait           = false
      self.pause_duration = 1
      self.servername     = "G#{ENV['USER'].upcase}"
      yield self if block_given?
    end

    attr_accessor :pause_duration

    attr_accessor :wait

    attr_accessor :servername

    alias wait? wait

    def vim
      @vim ||= case `uname -s`
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
      system *command
    end

    def fullscreen=(enabled)
      started? or start
      sleep pause_duration
      if enabled
        edit_remote_send '<ESC>:set fullscreen<CR>'
      else
        edit_remote_send '<ESC>:set nofullscreen<CR>'
      end
      activate
    end

    def file_linenumber?(filename)
      filename.match(/^\s*([^:]+):(\d+)/)
    end

    def edit(*filenames)
      if filenames.size == 1
        filename = filenames.first
        if m = file_linenumber?(filename)
          edit_file_linenumber(*m.captures)
        else
          edit_file(filename)
        end
      else
        edit_file(*filenames)
      end
    end

    def edit_file(*filenames)
      edit_remote_file(*filenames)
    end

    def edit_file_linenumber(filename, linenumber)
      if wait?
        edit_remote(filename)
        sleep pause_duration
        edit_remote_send("<ESC>:#{linenumber}<CR>")
        edit_remote_wait(filename)
      else
        edit_remote(filename)
        sleep pause_duration
        edit_remote_send("<ESC>:#{linenumber}<CR>")
      end
    end

    def ensure_running
      started? ? activate : start
      self
    end

    def start
      cmd(vim, '-g', '--servername', servername)
    end

    def stop
      started? and edit_remote_send('<ESC>:qa<CR>')
    end

    def activate
      edit_remote("stupid_trick#{rand}")
      sleep pause_duration
      edit_remote_send('<ESC>:bw<CR>')
    end

    def serverlist
      @serverlist ||= `#{vim} -g --serverlist`.split
    end

    def started?(name = servername)
      serverlist.member?(name)
    end

    def edit_remote(*args)
      cmd(vim, '-g', '--servername', servername, '--remote', *args)
    end

    def edit_remote_wait(*args)
      cmd(vim, '-g', '--servername', servername, '--remote-wait', *args)
    end

    def edit_remote_send(*args)
      cmd(vim, '-g', '--servername', servername, '--remote-send', *args)
    end

    def edit_remote_file(*filenames)
      if wait?
        edit_remote_wait(*filenames)
      else
        edit_remote(*filenames)
      end
    end
  end
end
