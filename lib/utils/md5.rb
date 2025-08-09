require 'digest/md5'

module Utils
  module MD5
    class << self
      # The buffer_size accessor method provides read and write access to the
      # buffer_size instance variable.
      #
      # @return [ Integer ] the current buffer size value
      attr_accessor :buffer_size
    end
    self.buffer_size = 2 ** 20 - 1

    module_function

    # Computes the MD5 hash digest for a given file.
    #
    # This method reads the entire contents of the specified file in binary
    # mode and calculates its MD5 hash value. It uses a configurable buffer
    # size for reading the file in chunks to optimize memory usage during the
    # hashing process.
    #
    # @param filename [ String ] the path to the file for which to compute the MD5 hash
    #
    # @return [ String ] the hexadecimal representation of the MD5 hash digest
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
