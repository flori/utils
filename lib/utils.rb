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
  require 'utils/xdg'
  require 'utils/config_file'
  require 'utils/editor'
  require 'utils/finder'
  require 'utils/grepper'
  require 'utils/probe'
  require 'utils/ssh_tunnel_specification'
  require 'utils/line_blamer'

  require 'utils/xt/source_location_extension'
  # Extend all existing modules that define source_location with our
  # enhancements.
  # This ensures compatibility with existing code that may have overridden
  # source_location while avoiding conflicts with Ruby's core classes. The
  # ObjectSpace iteration discovers all modules that already have
  # source_location methods, and we prepend our extension to them. We rescue
  # TypeError to handle cases where prepending isn't possible (e.g., certain
  # core classes or frozen modules). Finally, we also prepend to ::Object
  # itself to ensure the extension is applied to the root class.
  # This approach maintains backward compatibility while ensuring comprehensive
  # coverage of all classes that might need source location enhancement.
  ObjectSpace.each_object(Module).
    select { it.method_defined?(:source_location) }.
    reject { it <= Utils::Xt::SourceLocationExtension }.
    each do
      it.prepend(Utils::Xt::SourceLocationExtension)
    rescue TypeError
    end
  class ::Object
    prepend Utils::Xt::SourceLocationExtension
  end
end
