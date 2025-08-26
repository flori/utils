require 'pathname'
require 'stringio'

module Utils
  # A configuration directory manager that handles path resolution and file
  # operations within a specified directory structure.
  #
  # This class provides functionality for managing configuration directories by
  # deriving paths based on a root directory and name, and offering methods to
  # read files with optional default values and block handling. It supports
  # environment variable-based root path resolution and uses Pathname for
  # robust path manipulation.
  #
  # @example
  #   config_dir = Utils::ConfigDir.new('myapp')
  #   config_dir.to_s # => returns the string representation of the configuration directory path
  #   config_dir.join('config.txt') # => returns a Pathname object for the joined path
  #   config_dir.read('settings.rb') # => reads and returns the content of 'settings.rb' or nil if not found
  #   config_dir.read('missing.txt', default: 'default content') # => returns 'default content' if file is missing
  class ConfigDir
    # Initializes a new ConfigDir instance with the specified name and optional
    # root path or environment variable.
    #
    # @param name [ String ] the name of the directory to be used
    # @param root_path [ String, nil ] the root path to use; if nil, the
    #                                  default root path is used
    # @param env_var [ String, nil ] the name of the environment variable to
    #                                check for the root path
    def initialize(name, root_path: nil, env_var: nil)
      root_path ||= env_var_path(env_var)
      @directory_path = derive_directory_path(name, root_path)
    end

    # Memoizes the foobar method's return value and returns the result of the computation.
    # Initializes a new ConfigDir instance with the specified name and optional
    # root path or environment variable.
    #
    # @param name [ String ] the name of the directory to be used
    # @param root_path [ String, nil ] the root path to use; if nil, the
    #                                  default root path is used
    # @param env_var [ String, nil ] the name of the environment variable to
    #                                check for the root path
    def initialize(name, root_path: nil, env_var: nil)
      root_path ||= env_var_path(env_var)
      @directory_path = derive_directory_path(name, root_path)
    end

    # Returns the string representation of the configuration directory path.
    #
    # @return [ String ] the path of the configuration directory as a string
    def to_s
      @directory_path.to_s
    end

    # Joins the directory path with the given path and returns the combined
    # result.
    #
    # @param path [ String ] the path to be joined with the directory path
    #
    # @return [ Pathname ] the combined path as a Pathname object
    def join(path)
      @directory_path + path
    end
    alias + join

    # Reads the content of a file at the given path within the configuration
    # directory.
    #
    # If the file exists, it returns the file's content as a string encoded in
    # UTF-8. If a block is given and the file exists, it opens the file and
    # yields to the block.
    # If the file does not exist and a default value is provided, it returns
    # the default. If a block is given and the file does not exist, it yields a
    # StringIO object containing
    # the default value to the block.
    #
    # @param path [ String ] the path to the file relative to the configuration
    # directory
    # @param default [ String, nil ] the default value to return if the file
    # does not exist
    #
    # @yield [ io ]
    #
    # @return [ String, nil ] the content of the file or the default value if
    # the file does not exist
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

    private

    # Derives the full directory path by combining the root path and the given
    # name.
    #
    # @param name [ String ] the name of the directory to be appended to the root path
    # @param root_path [ String, nil ] the root path to use; if nil, the default root path is used
    #
    # @return [ Pathname ] the combined directory path as a Pathname object
    def derive_directory_path(name, root_path)
      root = if path = root_path
               Pathname.new(path)
             else
               Pathname.new(default_root_path)
             end
      root + name
    end

    # Returns the environment variable path if it is set and not empty.
    #
    # @param env_var [ String ] the name of the environment variable to check
    # @return [ String, nil ] the value of the environment variable if it
    # exists and is not empty, otherwise nil
    def env_var_path(env_var)
      env_var.full? { ENV[it].full? }
    end

    # Returns the default configuration directory path based on the HOME
    # environment variable.
    #
    # This method constructs and returns a Pathname object pointing to the
    # standard configuration directory location, which is typically
    # $HOME/.config.
    #
    # @return [ Pathname ] the default configuration directory path
    def default_root_path
      Pathname.new(ENV.fetch('HOME') + '.config')
    end
  end
end
