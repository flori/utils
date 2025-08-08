module Utils
  require 'utils/version'
  require 'utils/md5'
  require 'utils/patterns'
  require 'utils/config_file'
  require 'utils/editor'
  require 'utils/finder'
  require 'utils/grepper'
  require 'utils/probe_server'
  require 'utils/ssh_tunnel_specification'
  require 'utils/line_blamer'
  require 'utils/config_dir'

  require 'utils/xt/source_location_extension'
  class ::Object
    include Utils::Xt::SourceLocationExtension
  end
end
