require 'dslkit/polite'
require 'tins/xt/string'

class Utils::Config::ConfigFile
  include DSLKit::Interpreter

  def initialize
  end

  def parse_config_file(config_file_name)
    File.open(config_file_name) do |cf|
      parse cf.read
    end
    self
  rescue SystemCallError => e
    $DEBUG and warn "Couldn't read config file #{config_file_name.inspect}."
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
      result << "#{self.class.name[/::([^:]+)\Z/, 1].underscore} do\n"
      for da in self.class.dsl_attributes
        result << "  #{da} #{Array(__send__(da)).map(&:inspect) * ', '}\n"
      end
      result << "end\n"
    end
  end

  class FileFinder < BlockConfig
    def prune?(basename)
      Array(prune_dirs).any? { |pd| pd.match(basename) }
    end

    def skip?(basename)
      Array(skip_files).any? { |sf| sf.match(basename) }
    end
  end

  class Search < FileFinder
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\Z/

    config :skip_files, /(\A\.|\.sw[pon]\Z|\.log\Z|~\Z)/
  end

  def search(&block)
    if block
      @search = Search.new(&block)
    end
    @search ||= Search.new
  end

  class Discover < FileFinder
    config :prune_dirs, /\A(\.svn|\.git|CVS|tmp)\Z/

    config :skip_files, /(\A\.|\.sw[pon]\Z|\.log\Z|~\Z)/
  end

  def discover(&block)
    if block
      @discover = Discover.new(&block)
    end
    @discover ||= Discover.new
  end

  class StripSpaces < FileFinder
    config :prune_dirs, /\A(\..*|CVS)\Z/

    config :skip_files, /(\A\.|\.sw[pon]\Z|\.log\Z|~\Z)/
  end

  def strip_spaces(&block)
    if block
      @strip_spaces = StripSpaces.new(&block)
    end
    @strip_spaces ||= StripSpaces.new
  end

  def to_ruby
    result = "# vim: set ft=ruby:\n"
    for bc in %w[search discover]
      result << "\n" << __send__(bc).to_ruby
    end
    result
  end
end
