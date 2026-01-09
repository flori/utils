require 'pathname'
require 'fileutils'

# Module for handling XDG base directory specifications and application
# directory management.
#
# Provides constants and methods for working with XDG (Cross-Desktop Group)
# base directories including data home, configuration home, state home, and
# cache home directories.
#
# The module defines standard XDG directory paths and includes functionality
# for creating application-specific directories within these base locations.
#
# @example
#   Utils::XDG::XDG_DATA_HOME # => Pathname object for the data home directory
#   Utils::XDG::XDG_CONFIG_HOME # => Pathname object for the config home directory
#   Utils::XDG::XDG_STATE_HOME # => Pathname object for the state home directory
#   Utils::XDG::XDG_CACHE_HOME # => Pathname object for the cache home directory
module Utils::XDG
  # Module for handling XDG application directories.
  #
  # This module provides methods for creating and managing application-specific
  # directories within the XDG base directories.
  module AppDir
    # Converts a path string to a Pathname object and extends it with AppDir
    # functionality.
    #
    # @param path [String] The path to convert
    # @return [Pathname] A Pathname object extended with AppDir methods
    def self.pathify(path)
      Pathname.new(path).expand_path.extend(self)
    end

    # Creates an application directory within the current path.
    #
    # If the directory already exists, it verifies that it's actually a directory.
    # If it doesn't exist, it creates the directory structure.
    #
    # @param dirname [String] The name of the directory to create
    # @return [Pathname] The path to the created or existing directory
    # @raise [ArgumentError] If the path exists but is not a directory
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

    # Retrieves an environment variable value or returns a default.
    #
    # @param name [String] The name of the environment variable
    # @param default [String] The default value if the environment variable is not set
    # @return [String] The value of the environment variable or the default
    def env_for(name, default:)
      ENV.fetch(name, default)
    end
  end

  # XDG Data Home directory path.
  #
  # This is the base directory relative to which user-specific data files should be stored.
  # The default value is `~/.local/share`.
  #
  # @return [Pathname] The data home directory path
  XDG_DATA_HOME = AppDir.pathify(env_for('XDG_DATA_HOME', default: '~/.local/share'))

  # XDG Configuration Home directory path.
  #
  # This is the base directory relative to which user-specific configuration files should be stored.
  # The default value is `~/.config`.
  #
  # @return [Pathname] The configuration home directory path
  XDG_CONFIG_HOME = AppDir.pathify(env_for('XDG_CONFIG_HOME', default: '~/.config'))

  # XDG State Home directory path.
  #
  # This is the base directory relative to which user-specific state files should be stored.
  # The default value is `~/.local/state`.
  #
  # @return [Pathname] The state home directory path
  XDG_STATE_HOME  = AppDir.pathify(env_for('XDG_STATE_HOME', default: '~/.local/state'))

  # XDG Cache Home directory path.
  #
  # This is the base directory relative to which user-specific non-essential cache files should be stored.
  # The default value is `~/.cache`.
  #
  # @return [Pathname] The cache home directory path
  XDG_CACHE_HOME  = AppDir.pathify(env_for('XDG_CACHE_HOME', default: '~/.cache'))
end
