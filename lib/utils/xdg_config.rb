module Utils::XDGConfig
  def xdg_config(name)
    @config and return @config
    @config = if xdg = ENV['XDG_CONFIG_HOME'].full?
                File.join(xdg, name)
              else
                File.join(ENV.fetch('HOME'), '.config', name)
              end
  end
end
