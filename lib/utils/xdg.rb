require 'pathname'
require 'fileutils'

module Utils::XDG
  module AppDir
    def self.pathify(path)
      Pathname.new(path).expand_path.extend(self)
    end

    def app_dir(dirname)
      app_dir_path = self + dirname
      if app_dir_path.exist?
        app_dir_path.directory? or raise ArgumentError,
          "path #{app_dir_path.to_s.inspect} exists and is not a directory"
      else
        FileUtils.mkdir_p app_dir_path
      end
      app_dir_path
    end
  end

  class << self
    private

    def env_for(name, default:)
      ENV.fetch(name, default)
    end
  end

  XDG_DATA_HOME = AppDir.pathify(env_for('XDG_DATA_HOME', default: '~/.local/share'))

  XDG_CONFIG_HOME = AppDir.pathify(env_for('XDG_CONFIG_HOME', default: '~/.config'))

  XDG_STATE_HOME  = AppDir.pathify(env_for('XDG_STATE_HOME', default: '~/.local/state'))

  XDG_CACHE_HOME  = AppDir.pathify(env_for('XDG_CACHE_HOME', default: '~/.cache'))
end
