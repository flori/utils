require 'fileutils'
require 'rbconfig'
require 'pstree'
require 'digest/md5'

module Utils
  # An editor interface for interacting with Vim server instances.
  #
  # This class provides functionality for managing Vim editor sessions through
  # server connections, enabling features like remote file editing, window
  # management, and server state monitoring. It handles communication with
  # running Vim instances and supports various configuration options for
  # customizing the editing experience.
  #
  # @example
  #   editor = Utils::Editor.new
  #   editor.edit('file.rb')
  #   editor.activate
  #   editor.stop
  class Editor
    # The initialize method sets up a new editor instance with default
    # configuration.
    #
    # This method configures the editor by initializing default values for wait
    # flag, pause duration, and server name. It also loads the configuration
    # file and assigns the edit configuration section to the instance.
    #
    # @yield |editor| optional block to be executed after initialization with
    # self as argument.
    #
    # @return [ Utils::Editor ] a new editor instance configured with default settings
    def initialize
      self.wait           = false
      self.pause_duration = 1
      self.servername     = derive_server_name
      config              = Utils::ConfigFile.new
      config.configure_from_paths
      self.config = config.edit
      yield self if block_given?
    end

    # The derive_server_name method constructs a server name based on
    # environment configuration.
    #
    # This method determines an appropriate server name by checking for a
    # VIM_SERVER environment variable, falling back to the current working
    # directory if not set. On Windows-like systems, it prefixes the name with
    # "G_" to ensure uniqueness. The resulting name is converted to uppercase
    # for consistent formatting.
    #
    # @return [ String ] the constructed server name based on environment and
    # system configuration
    private def derive_server_name
      name = ENV['VIM_SERVER'] || Dir.pwd
      prefix = File.basename(name)
      suffix = Digest::MD5.hexdigest(name)[0, 8]
      name = [ prefix, suffix ] * ?-
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ and name = "G_#{name}"
      name.upcase
    end

    # The pause_duration method provides access to the duration value used for
    # pausing operations.
    #
    # This method returns the current value of the pause duration attribute,
    # which controls how long certain operations should wait or pause between
    # actions.
    #
    # @return [ Integer, Float ] the current pause duration value in seconds
    attr_accessor :pause_duration

    # The wait method gets the wait status.
    #
    # @return [ TrueClass, FalseClass, nil ] the wait status value
    attr_accessor :wait

    alias wait? wait

    # The servername method provides access to the server name attribute.
    #
    # This method returns the value of the server name instance variable,
    # which represents the name of the server being used.
    #
    # @return [ String ] the server name value
    attr_accessor :servername

    # The mkdir method provides access to the directory creation flag.
    #
    # This method returns the current value of the mkdir flag, which determines
    # whether directory creation should be attempted when processing files.
    #
    # @return [ TrueClass, FalseClass ] the current state of the mkdir flag
    attr_accessor :mkdir

    # The config method provides access to the configuration object.
    #
    # This method returns the configuration instance variable that holds the
    # settings and options for the object's operation.
    #
    # @return [ Utils::ConfigFile ] the configuration object associated with this instance
    attr_accessor :config

    # The vim method constructs and returns the Vim command configuration.
    #
    # This method assembles the Vim command by combining the configured Vim
    # path with any default arguments specified in the configuration.
    #
    # @return [ Array<String> ] an array containing the Vim executable path and
    #         its default arguments for command execution
    def vim
      ([ config.vim_path ] + Array(config.vim_default_args))
    end

    # The cmd method constructs a command from parts and executes it.
    #
    # This method takes multiple arguments, processes them to build a command
    # array, and then executes the command using the system call.
    #
    # @param parts [ Array ] the parts to be included in the command
    #
    # @return [ Boolean ] true if the command was successful, false otherwise
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

    # The fullscreen= method sets the fullscreen state for the remote editor
    # session.
    #
    # This method configures the fullscreen mode of the remote editor by
    # sending appropriate commands through the edit_remote_send mechanism. It
    # ensures the editor session is started and paused briefly before applying
    # the fullscreen
    # setting, then activates the session to apply the changes.
    #
    # @param enabled [ TrueClass, FalseClass ] determines whether to enable or
    # disable fullscreen mode
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

    # The file_linenumber? method checks if a filename matches the file and
    # line number pattern.
    #
    # This method determines whether the provided filename string conforms to
    # the regular expression pattern used for identifying file paths
    # accompanied by line numbers.
    #
    # @param filename [ String ] the filename string to be checked
    #
    # @return [ MatchData, nil ] a match data object if the filename matches the pattern,
    #         or nil if it does not match
    def file_linenumber?(filename)
      filename.match(Utils::Xt::SourceLocationExtension::FILE_LINENUMBER_REGEXP)
    end

    # The expand_globs method processes an array of filename patterns by
    # expanding glob expressions and returning a sorted array of unique
    # filenames.
    #
    # @param filenames [ Array<String> ] an array of filename patterns that may
    # include glob expressions
    #
    # @return [ Array<String> ] a sorted array of unique filenames with glob
    # patterns expanded, or the original array if no glob patterns are present
    def expand_globs(filenames)
      filenames.map { |f| Dir[f] }.flatten.uniq.sort.full? || filenames
    end

    # The edit method processes filenames to determine their source location
    # and delegates to appropriate editing methods.
    #
    # If a single filename is provided and it has a source location, the method
    # checks whether the location includes filename and linenumber attributes.
    # If so, it calls edit_source_location with the source location; otherwise,
    # it calls edit_file_linenumber with the source location components.
    # If multiple filenames are provided and all have source locations, the
    # method expands any glob patterns in the filenames, then calls edit_file
    # with the expanded list of filenames.
    # Finally, it ensures the editor is activated after processing.
    #
    # @param filenames [ Array<String, Integer> ] an array of filenames that
    # may contain source location information
    def edit(*filenames)
      source_location = nil
      if filenames.size == 1 and
        source_location = filenames.first.source_location
      then
        if source_location.respond_to?(:filename) and source_location.respond_to?(:linenumber)
          edit_source_location(source_location)
        else
          edit_file_linenumber(*source_location)
        end
      elsif source_locations = filenames.map(&:source_location).compact.full?
        filenames = expand_globs(source_locations.map(&:first))
        edit_file(*filenames)
      end.tap do
        activate
      end
    end

    # The make_dirs method creates directory structures for the provided
    # filenames.
    #
    # This method checks if directory creation is enabled and, if so, ensures
    # that the parent directories for each filename exist by creating them
    # recursively.
    #
    # @param filenames [ Array<String> ] an array of filenames for which to
    # create directory structures
    private def make_dirs(*filenames)
      if mkdir
        for filename in filenames
          FileUtils.mkdir_p File.dirname(filename)
        end
      end
    end

    # The edit_file method processes a list of filenames by ensuring their
    # directories exist and then delegates to a remote file editing function.
    #
    # @param filenames [ Array<String> ] an array of filename strings to be processed
    def edit_file(*filenames)
      make_dirs(*filenames)
      edit_remote_file(*filenames)
    end

    # The edit_file_linenumber method opens a file at a specific line number
    # and optionally selects a range of lines in an editor.
    #
    # @param filename [ String ] the path to the file to be opened
    # @param linenumber [ Integer ] the line number where the file should be
    # opened
    # @param rangeend [ Integer, nil ] the ending line number for selection, or
    # nil if no range is specified
    def edit_file_linenumber(filename, linenumber, rangeend = nil)
      make_dirs filename
      if rangeend
        Thread.new do
          while !started?
            sleep 1
          end
          edit_remote_send("<ESC>:normal #{linenumber}GV#{rangeend}G<CR>")
        end
      end
      if wait?
        activate
        edit_remote_wait("+#{linenumber}", filename)
      else
        edit_remote("+#{linenumber}", filename)
      end
    end

    # The edit_source_location method processes a source location object to
    # open the corresponding file at the specified line number.
    #
    # This method takes a source location object and uses its filename, line
    # number, and optional range end to invoke the edit_file_linenumber method
    # for opening the file in an editor.
    #
    # @param source_location [ Array<String, Integer> ] the source location
    # containing filename and line number information
    def edit_source_location(source_location)
      edit_file_linenumber(
        source_location.filename,
        source_location.linenumber,
        source_location.rangeend
      )
    end

    # The rename_window method renames the current tmux window to match the
    # base name of the current script.
    #
    # This method checks if the application is running within a tmux session
    # and, if so, renames the current window to reflect the base name of the
    # script being executed. It only performs the renaming operation if a tmux
    # session is detected and the window has not already been started.
    private def rename_window
      return if started?
      ENV['TMUX'] and system "tmux rename-window #{File.basename($0)}"
    end

    # The start method initializes the Vim server connection if it is not
    # already running.
    #
    # This method first attempts to rename the terminal window to reflect the
    # server name, then checks if the Vim server has already been started. If
    # not, it executes the command to launch the Vim server with the specified
    # server name.
    def start
      rename_window
      started? or cmd(*vim, '--servername', servername)
    end

    # The stop method sends a quit command to the remote editor.
    #
    # This method checks if the editor is currently running and, if so, sends a
    # quit command to close all windows and terminate the editor session.
    def stop
      started? and edit_remote_send('<ESC>:qa<CR>')
    end

    # The activate method switches to the Vim editor window or opens a new one.
    #
    # This method checks if the Vim default arguments include the '-g' flag to determine
    # whether to open a new buffer in the current window or switch to an
    # existing Vim pane. When the '-g' flag is present, it creates a temporary
    # file and then closes it. Otherwise, it identifies the appropriate tmux
    # pane running an editor process and switches to it.
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

    # The serverlist method retrieves a list of available Vim server names.
    #
    # This method executes the Vim command to list all active servers and
    # returns the results as an array of server names.
    #
    # @return [ Array<String> ] an array of Vim server names currently available
    def serverlist
      `#{vim.map(&:inspect) * ' '} --serverlist`.split
    end

    # The started? method checks whether a server with the given name is
    # currently running.
    #
    # This method verifies the presence of a server in the list of active
    # servers by checking if the server name exists within the serverlist.
    #
    # @param name [ String ] the name of the server to check for
    #
    # @return [ TrueClass, FalseClass ] true if the server is running, false otherwise
    def started?(name = servername)
      serverlist.member?(name)
    end

    # The edit_remote method executes a remote Vim command with the specified
    # arguments.
    #
    # This method prepares a command to communicate with a running Vim server
    # instance, allowing for remote execution of Vim commands without directly
    # interacting with the terminal. It ensures the window is renamed before
    # sending the command and constructs the appropriate command line arguments
    # for the Vim server interface.
    #
    # @param args [ Array ] the arguments to be passed to the remote Vim command
    def edit_remote(*args)
      rename_window
      cmd(*vim, '--servername', servername, '--remote', *args)
    end

    # The edit_remote_wait method executes a command remotely and waits for its
    # completion.
    #
    # This method sends a command to a remote server using the specified vim
    # server connection, and blocks until the remote operation finishes
    # executing.
    #
    # @param args [ Array ] the arguments to be passed to the remote command
    def edit_remote_wait(*args)
      rename_window
      cmd(*vim, '--servername', servername, '--remote-wait', *args)
    end

    # The edit_remote_send method transmits a sequence of arguments to a remote
    # Vim server for execution.
    #
    # This method prepares and sends commands to an already running Vim
    # instance identified by its server name, allowing for remote control of
    # the editor session. It ensures the window is properly named before
    # sending the command, and uses the configured Vim executable along with
    # its remote communication flags.
    #
    # @param args [ Array<String> ] the arguments to be sent to the remote Vim server
    def edit_remote_send(*args)
      rename_window
      cmd(*vim, '--servername', servername, '--remote-send', *args)
    end

    # The edit_remote_file method delegates to either edit_remote_wait or
    # edit_remote based on the wait? condition.
    #
    # This method determines whether to execute file editing operations with
    # waiting for completion or without waiting, depending on the result of the
    # wait? check.
    #
    # @param filenames [ Array<String> ] an array of filenames to be processed
    def edit_remote_file(*filenames)
      if wait?
        edit_remote_wait(*filenames)
      else
        edit_remote(*filenames)
      end
    end
  end
end
