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
  # A Pathname subclass that provides additional XDG directory functionality
  #
  # This class extends the standard Pathname class to include methods for
  # working with XDG (Cross-Desktop Group) base directory specifications. It
  # adds capabilities for creating subdirectories, reading files, and handling
  # path operations within the context of XDG-compliant directory structures.
  #
  # @example
  #   pathname = XDGPathname.new('/home/user')
  #   sub_dir = pathname.sub_dir_path('documents')
  #   content = pathname.read('config.txt')
  class XDGPathname < ::Pathname
    # The sub_dir_path method creates a subdirectory path and ensures it exists
    #
    # This method takes a directory name, combines it with the current path to
    # form a subdirectory path, and then checks if the path already exists. If
    # the path exists but is not a directory, it raises an ArgumentError. If
    # the path does not exist, it creates the directory structure using
    # FileUtils.
    #
    # @param dirname [ String ] the name of the subdirectory to create or access
    #
    # @return [ Pathname ] the Pathname object representing the subdirectory path
    #
    # @raise [ ArgumentError ] if the path exists but is not a directory
    def sub_dir_path(dirname)
      path = self + dirname
      if path.exist?
        path.directory? or raise ArgumentError,
          "path #{path.to_s.inspect} exists and is not a directory"
      else
        FileUtils.mkdir_p path
      end
      path
    end

    # The read method reads file contents or yields to a block for processing.
    #
    # This method attempts to read a file at the specified path, returning the
    # file's contents as a string.
    # If a block is provided, it opens the file and yields to the block with a
    # File object.
    # If the file does not exist and a default value is provided, it returns
    # the default value.
    # When a default value is provided along with a block, the block is invoked
    # with a StringIO object containing the default value.
    #
    # @param path [ String ] the path to the file to read
    # @param default [ String, nil ] the default value to return if the file
    #   does not exist
    #
    # @yield [ file ] optional block to process the file
    # @yieldparam file [ File ] the file object for processing
    #
    # @return [ String, nil ] the file contents if no block is given, the
    #   result of the block if given, or the default value if the file does not
    #   exist
    def read(path, default: nil, &block)
      full_path = join(path)
      if File.exist?(full_path)
        if block
          File.new(full_path, &block)
        else
          File.read(full_path, encoding: 'UTF-8')
        end
      else
        if default && block
          block.(StringIO.new(default))
        else
          default
        end
      end
    end

    # The join method creates a new path by combining the current path with a
    # given path component.
    #
    # This method takes a path string and appends it to the current path,
    # returning a new Pathname object that represents the combined path.
    #
    # @param path [ String ] the path component to append to the current path
    #
    # @return [ Pathname ] a new Pathname object representing the joined path
    def join(path)
      self.class.new(super)
    end

    # The + method creates a new instance by combining the current path with
    # the provided path component.
    #
    # This method takes a path component and uses the superclass's + method to
    # combine it with the current path, then wraps the result in a new instance
    # of the same class as the current object.
    #
    # @param path [ String, Pathname ] the path component to be added to the current path
    #
    # @return [ self.class ] a new instance of the same class with the combined path
    def +(path)
      self.class.new(super)
    end

    alias to_str to_s
  end

  # Module for handling XDG application directories.
  #
  # This module provides methods for creating and managing application-specific
  # directories within the XDG base directories.
  module AppDir
    # Converts a path string to a XDGPathname object with expanded path
    #
    # @param path [String] The path to convert
    # @return [XDGPathname] A path as XDGPathname
    def self.pathify(path)
      XDGPathname.new(path).expand_path
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
