require 'tins/xt/full'
require 'tins/deep_const_get'
require 'fileutils'
require 'rbconfig'
require 'pstree'

module Utils
  class Editor
    FILE_LINENUMBER_REGEXP = /\A\s*([^:]+):(\d+)/
    CLASS_METHOD_REGEXP    = /\A([A-Z][\w:]+)([#.])([\w!?]+)/

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
      self.servername     = derive_server_name
      config              = Utils::Config::ConfigFile.new
      config.configure_from_paths
      self.config = config.edit
      yield self if block_given?
    end

    def derive_server_name
      name = ENV['VIM_SERVER'] || Dir.pwd
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ and name = "G_#{name}"
      name.upcase
    end
    private :derive_server_name

    attr_accessor :pause_duration

    attr_accessor :wait

    attr_accessor :servername

    attr_accessor :mkdir

    attr_accessor :config

    alias wait? wait

    def vim
      ([ config.vim_path ] + Array(config.vim_default_args))
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
      start
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
        edit_source_location(source_location) # || edit_file(expand_globs(source_location[0, 1]))
      elsif source_locations = filenames.map(&:source_location).compact.full?
        filenames = expand_globs(source_locations.map(&:first))
        edit_file(*filenames)
      end.tap do
        activate
      end
    end

    def make_dirs(*filenames)
      if mkdir
        for filename in filenames
          FileUtils.mkdir_p File.dirname(filename)
        end
      end
    end
    private :make_dirs

    def edit_file(*filenames)
      make_dirs(*filenames)
      edit_remote_file(*filenames)
    end

    def edit_file_linenumber(filename, linenumber)
      make_dirs filename
      if wait?
        edit_remote_wait("+#{linenumber}", filename)
      else
        edit_remote("+#{linenumber}", filename)
      end
    end

    def edit_source_location(source_location)
      edit_file_linenumber(source_location[0], source_location[1])
    end

    def start
      started? or cmd(*vim, '--servername', servername)
    end

    def stop
      started? and edit_remote_send('<ESC>:qa<CR>')
    end

    def activate
      if Array(config.vim_default_args).include?('-g')
        edit_remote("stupid_trick#{rand}")
        sleep pause_duration
        edit_remote_send('<ESC>:bw<CR>')
      else
        pstree = PSTree.new
        switch_to_index =
          `tmux list-panes -F '\#{pane_pid} \#{pane_index}'`.lines.find { |l|
            pid, index = l.split(' ')
            pid = pid.to_i
            if pstree.find { |ps| ps.pid != $$ && ps.ppid == pid && ps.cmd =~ %r(/edit( |$)) }
              break index.to_i
            end
          }
        switch_to_index and system "tmux select-pane -t #{switch_to_index}"
      end
    end

    def serverlist
      @serverlist ||= `#{vim.map(&:inspect) * ' '} --serverlist`.split
    end

    def started?(name = servername)
      serverlist.member?(name)
    end

    def edit_remote(*args)
      cmd(*vim, '--servername', servername, '--remote', *args)
    end

    def edit_remote_wait(*args)
      cmd(*vim, '--servername', servername, '--remote-wait', *args)
    end

    def edit_remote_send(*args)
      cmd(*vim, '--servername', servername, '--remote-send', *args)
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
