module Utils
  class Editor
    FILE_LINENUMBER_REGEXP = /^\s*([^:]+):(\d+)/

    module SourceLocationExtension
      def source_location
        if respond_to?(:to_str)
          if (string = to_str) =~ FILE_LINENUMBER_REGEXP
            [ $1, $2.to_i ]
          else
            [ string, 1 ]
          end
        else
          [ to_s, 1 ]
        end
      end
    end

    class ::Object
      include SourceLocationExtension
    end

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
      @vim ||=
        case `uname -s`
        when /\Adarwin/i
          if File.directory?('/Applications')
            '/Applications/MacVim.app/Contents/MacOS/Vim'
          else
            'vim'
          end
        else
          'vim'
        end
    end

    def cmd(*parts)
      command = parts.compact.inject([]) do |a, p|
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
      system(*command.map(&:to_s))
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
      filename.match(FILE_LINENUMBER_REGEXP)
    end

    def expand_globs(filenames)
      filenames.map { |f| Dir[f] }.flatten.uniq.sort
    end

    def edit(*filenames)
      if filenames.size == 1 and
        source_location = filenames.first.source_location
      then
        edit_source_location(source_location) ||
          edit_file(expand_globs(source_location[0, 1]))
      else
        filenames =
          expand_globs(filenames.map(&:source_location).map(&:first))
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

    def edit_source_location(source_location)
      if File.exist?(source_location[0])
        edit_file_linenumber(source_location[0], source_location[1])
      else
        false
      end
    end

    def ensure_running
      started? ? activate : start
      self
    end

    def gui
      ENV['TERM'] =~ /xterm/ ? '-g' : nil
    end

    def start
      cmd(vim, gui, '--servername', servername)
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
      @serverlist ||= `#{vim} #{gui} --serverlist`.split
    end

    def started?(name = servername)
      serverlist.member?(name)
    end

    def edit_remote(*args)
      cmd(vim, gui, '--servername', servername, '--remote', *args)
    end

    def edit_remote_wait(*args)
      cmd(vim, gui, '--servername', servername, '--remote-wait', *args)
    end

    def edit_remote_send(*args)
      cmd(vim, gui, '--servername', servername, '--remote-send', *args)
    end

    def edit_remote_file(*filenames)
      if gui && wait?
        edit_remote_wait(*filenames)
      else
        edit_remote(*filenames)
      end
    end
  end
end
