require 'digest/md5'

module Utils
  module_function

  module MD5
    class << self
      attr_accessor :buffer_size
    end
    self.buffer_size = 2 ** 20 - 1

    def md5(filename)
      digest = Digest::MD5.new
      digest.reset
      File.open(filename, 'rb') do |f|
        until f.eof?
          digest << f.read(MD5.buffer_size)
        end
      end
      digest.hexdigest
    end
  end
end
