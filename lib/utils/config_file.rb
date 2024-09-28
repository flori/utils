require 'tins'
require 'tins/xt/string'

class Utils::ConfigFile
  class << self
    attr_accessor :config_file_paths
  end
  self.config_file_paths = [
    '/etc/utilsrc',
    '~/.utilsrc',
    './.utilsrc',
  ]

  include DSLKit::Interpreter

  class ConfigFileError < StandardError; end

  def initialize
  end

  def configure_from_paths(paths = self.class.config_file_paths)
    for config_file_path in paths
      parse_config_file config_file_path
    end
  end

  def parse_config_file(config_file_path)
    config_file_path = File.expand_path(config_file_path)
    File.open(config_file_path) do |cf|
      parse cf.read
    end
    self
  rescue SystemCallError => e
    $DEBUG and warn "Couldn't read config file "\
      "#{config_file_path.inspect}: #{e.class} #{e}"
    return nil
  end

  def parse(source)
    interpret_with_binding source, binding
    self
  end

  class BlockConfig
    class << self
      def inherited(modul)
        modul.extend DSLKit::DSLAccessor
        super
      end

      def config(name, *r, &block)
        self.config_settings ||= []
        config_settings << name.to_sym
        dsl_accessor name, *r, &block
        self
      end

      attr_accessor :config_settings
    end

    def initialize(&block)
      block and instance_eval(&block)
    end

    def to_ruby(depth = 0)
      result = ''
      result << ' ' * 2 * depth <<
        "#{self.class.name[/::([^:]+)\z/, 1].underscore} do\n"
      for name in self.class.config_settings
        value = __send__(name)
        if value.respond_to?(:to_ruby)
          result << ' ' * 2 * (depth + 1) << value.to_ruby(depth + 1)
        else
          result << ' ' * 2 * (depth + 1) <<
            "#{name} #{Array(value).map(&:inspect) * ', '}\n"
        end
      end
      result << ' ' * 2 * depth << "end\n"
    end
  end

  class Probe < BlockConfig
    config :test_framework, :'test-unit'

    config :include_dirs, %w[lib test tests ext spec]

    def include_dirs_argument
      Array(include_dirs) * ':'
    end

    def initialize(&block)
      super
      test_frameworks_allowed = [ :'test-unit', :rspec ]
      test_frameworks_allowed.include?(test_framework) or
        raise ConfigFileError,
          "test_framework has to be in #{test_frameworks_allowed.inspect}"
    end
  end

  def probe(&block)
    if block
      @probe = Probe.new(&block)
    end
    @probe ||= Probe.new
  end

  class FileFinder < BlockConfig
    def prune?(basename)
      Array(prune_dirs).any? { |pd| pd.match(basename.to_s) }
    end

    def skip?(basename)
      Array(skip_files).any? { |sf| sf.match(basename.to_s) }
    end
  end

  class Search < FileFinder
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\z/

    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
  end

  def search(&block)
    if block
      @search = Search.new(&block)
    end
    @search ||= Search.new
  end

  class Discover < FileFinder
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\z/

    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/

    config :binary, false

    config :max_matches, 10

    config :index_expire_after
  end

  def discover(&block)
    if block
      @discover = Discover.new(&block)
    end
    @discover ||= Discover.new
  end

  class Scope < FileFinder
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\z/

    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/

    config :binary, false
  end

  def scope(&block)
    if block
      @scope = Scope.new(&block)
    end
    @scope ||= Scope.new
  end

  class StripSpaces < FileFinder
    config :prune_dirs, /\A(\..*|CVS)\z/

    config :skip_files, /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
  end

  def strip_spaces(&block)
    if block
      @strip_spaces = StripSpaces.new(&block)
    end
    @strip_spaces ||= StripSpaces.new
  end

  class SshTunnel < BlockConfig
    config :terminal_multiplexer, 'tmux'

    config :env, {}

    config :login_session do
      ENV.fetch('HOME',  'session')
    end

    def initialize
      super
      self.terminal_multiplexer = terminal_multiplexer
    end

    def terminal_multiplexer=(terminal_multiplexer)
      @multiplexer = terminal_multiplexer.to_s
      @multiplexer =~ /\A(screen|tmux)\z/ or
        fail "invalid terminal_multiplexer #{terminal_multiplexer.inspect} was configured"
    end

    def multiplexer_list
      case @multiplexer
      when 'screen'
        'screen -ls'
      when 'tmux'
        'tmux ls'
      end
    end

    def multiplexer_new(session)
      case @multiplexer
      when 'screen'
        'false'
      when 'tmux'
        'tmux -u new -s "%s"' % session
      end
    end

    def multiplexer_attach(session)
      case @multiplexer
      when 'screen'
        'screen -DUR "%s"' % session
      when 'tmux'
        'tmux -u attach -d -t "%s"' % session
      end
    end

    class CopyPaste < BlockConfig
      config :bind_address, 'localhost'

      config :port, 6166

      config :host, 'localhost'

      config :host_port, 6166

      def to_s
        [ bind_address, port, host, host_port ] * ':'
      end
    end

    def copy_paste(enable = false, &block)
      if @copy_paste
        @copy_paste
      else
        if block
          @copy_paste = CopyPaste.new(&block)
        elsif enable
          @copy_paste = CopyPaste.new {}
        end
      end
    end
    self.config_settings << :copy_paste
  end

  def ssh_tunnel(&block)
    if block
      @ssh_tunnel = SshTunnel.new(&block)
    end
    @ssh_tunnel ||= SshTunnel.new
  end

  class Edit < BlockConfig
    config :vim_path do `which vim`.chomp end

    config :vim_default_args, nil
  end

  def edit(&block)
    if block
      @edit = Edit.new(&block)
    end
    @edit ||= Edit.new
  end

  class Classify < BlockConfig
    config :shift_path_by_default, 0

    config :shift_path_for_prefix, []
  end

  def classify(&block)
    if block
      @classify = Classify.new(&block)
    end
    @classify ||= Classify.new
  end

  class SyncDir < BlockConfig
    config :skip_path, %r((\A|/)\.\w)

    def skip?(path)
      path =~ skip_path
    end
  end

  def sync_dir(&block)
    if block
      @sync_dir = SyncDir.new(&block)
    end
    @sync_dir ||= SyncDir.new
  end

  def to_ruby
    result = "# vim: set ft=ruby:\n"
    for bc in %w[search discover strip_spaces probe ssh_tunnel edit classify]
      result << "\n" << __send__(bc).to_ruby
    end
    result
  end
end
