require 'tins/xt/full'
require 'tins/deep_const_get'

module Utils
  class Editor
    FILE_LINENUMBER_REGEXP = /\A\s*([^:]+):(\d+)/
    CLASS_METHOD_REGEXP    = /\A([A-Z][\w:]+)([#.])(\S+)/

    module SourceLocationExtension
      include Tins::DeepConstGet

      def source_location
        filename   = nil
        linenumber = nil
        if respond_to?(:to_str)
          string = to_str
          case
          when string =~ FILE_LINENUMBER_REGEXP && File.exist?($1)
            filename = $1
            linenumber = $2.to_i
          when string =~ CLASS_METHOD_REGEXP && !File.exist?(string)
            klassname   = $1
            method_kind = $2 == '#' ? :instance_method : :method
            methodname  = $3
            filename, linenumber =
              deep_const_get(klassname).__send__(method_kind, methodname).source_location
          else
            filename = string
          end
        else
          filename = to_s
        end
        array = linenumber ? [ filename, linenumber ] : [ filename, 1 ]
        array_singleton_class = class << array; self; end
        array_singleton_class.instance_eval do
          define_method(:filename) { filename }
          define_method(:linenumber) { linenumber }
          define_method(:to_s) { [ filename, linenumber ].compact * ':' }
        end
        array
      end
    end

    class ::Object
      include SourceLocationExtension
    end

    def initialize
      self.wait           = false
      self.pause_duration = 1
      self.servername     = ENV['VIM_SERVER'] || "G#{ENV['USER'].upcase}"
      yield self if block_given?
    end

    attr_accessor :pause_duration

    attr_accessor :wait

    attr_accessor :servername

    alias wait? wait

    def vim
      vim_in_path = [`which gvim`, `which vim`].map(&:chomp).find(&:full?)
      @vim ||=
        case `uname -s`
        when /\Adarwin/i
          if File.directory?(path = File.expand_path('~/Applications/MacVim.app')) or
            File.directory?(path = File.expand_path('/Applications/MacVim.app'))
          then
            File.join(path, 'Contents/MacOS/Vim')
          else
            vim_in_path
          end
        else
          vim_in_path
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
      filenames.map { |f| Dir[f] }.flatten.uniq.sort.full? || filenames
    end

    def edit(*filenames)
      if filenames.size == 1 and
        source_location = filenames.first.source_location
      then
        edit_source_location(source_location) ||
          edit_file(expand_globs(source_location[0, 1]))
      elsif source_locations = filenames.map(&:source_location).compact.full?
        filenames = expand_globs(source_locations.map(&:first))
        edit_file(*filenames)
      end
    end

    def edit_file(*filenames)
      if gui
        edit_remote_file(*filenames)
      else
        cmd(vim, *filenames)
      end
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
      edit_file_linenumber(source_location[0], source_location[1])
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
      gui and cmd(vim, gui, '--servername', servername, '--remote', *args)
    end

    def edit_remote_wait(*args)
      gui and cmd(vim, gui, '--servername', servername, '--remote-wait', *args)
    end

    def edit_remote_send(*args)
      gui and cmd(vim, gui, '--servername', servername, '--remote-send', *args)
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
