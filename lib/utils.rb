require 'tins/xt'

# The main Utils module serves as the primary namespace for the developer
# productivity command-line utilities gem.

# This module provides the core functionality and organization for the Utils
# library, which delivers a curated collection of command-line tools designed
# to streamline software development workflows and automate repetitive tasks.
module Utils
  require 'utils/version'
  require 'utils/md5'
  require 'utils/patterns'
  require 'utils/config_file'
  require 'utils/editor'
  require 'utils/finder'
  require 'utils/grepper'
  require 'utils/probe'
  require 'utils/ssh_tunnel_specification'
  require 'utils/line_blamer'
  require 'utils/config_dir'

  require 'utils/xt/source_location_extension'
  class ::Object
    include Utils::Xt::SourceLocationExtension
  end
end
