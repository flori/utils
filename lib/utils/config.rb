require 'fileutils'

module Utils
  module Config
    extend FileUtils::Verbose

    CONFIG_DIR = File.expand_path(__FILE__).sub(/#{Regexp.quote(File.extname(__FILE__))}\Z/, '')

    def self.install_config
      srcs = Dir[File.join(CONFIG_DIR, '*')]
      dst_prefix = ENV['HOME'] or fail 'environment variable $HOME is required'
      for src in srcs
        dst = File.join(dst_prefix, ".#{File.basename(src)}")
        if File.exist?(dst)
          rm_rf "#{dst}.bak"
          mv dst, "#{dst}.bak/", :force => true
        end
        cp_r src, dst
      end
      self
    end
  end
end
