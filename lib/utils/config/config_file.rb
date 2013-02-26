require 'dslkit/polite'
require 'tins/xt/string'

class Utils::Config::ConfigFile
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
        self.dsl_attributes ||= []
        dsl_attributes << name.to_sym
        dsl_accessor name, *r, &block
        self
      end

      attr_accessor :dsl_attributes
    end

    def initialize(&block)
      block and instance_eval(&block)
    end

    def to_ruby
      result = ''
      result << "#{self.class.name[/::([^:]+)\z/, 1].underscore} do\n"
      for da in self.class.dsl_attributes
        result << "  #{da} #{Array(__send__(da)).map(&:inspect) * ', '}\n"
      end
      result << "end\n"
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
  end

  def discover(&block)
    if block
      @discover = Discover.new(&block)
    end
    @discover ||= Discover.new
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
    config :terminal_multiplexer, 'sshscreen'

    def initialize
      super
      @multiplexer =
        case terminal_multiplexer.to_s
        when 'sshscreen'
          @multiplexer_list   = 'screen -ls'
          @multiplexer_attach = 'screen -DUR'
        when 'tmux'
          @multiplexer_list   = 'tmux ls'
          @multiplexer_attach = 'tmux attach'
        else
          fail "invalid terminal_multiplexer #{terminal_multiplexer.inspect} was configured"
        end
    end

    attr_reader :multiplexer_list

    attr_reader :multiplexer_attach
  end

  def ssh_tunnel(&block)
    if block
      @ssh_tunnel = SshTunnel.new(&block)
    end
    @ssh_tunnel ||= SshTunnel.new
  end

  def to_ruby
    result = "# vim: set ft=ruby:\n"
    for bc in %w[search discover strip_spaces probe ssh_tunnel]
      result << "\n" << __send__(bc).to_ruby
    end
    result
  end
end
