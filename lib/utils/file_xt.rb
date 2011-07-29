module Utils
  module FileXt
    include File::Constants

    SEEK_SET = File::SEEK_SET

    ZERO   = "\x00"
    BINARY = "\x01-\x1f\x7f-\xff"

    if defined?(::Encoding)
      ZERO.force_encoding(Encoding::ASCII_8BIT)
      BINARY.force_encoding(Encoding::ASCII_8BIT)
    end

    def binary?
      old_pos = tell
      seek 0, SEEK_SET
      data = read 2 ** 13
      !data or data.empty? and return nil
      data.count(ZERO) > 0 and return true
      data.count(BINARY).to_f / data.size > 0.3
    ensure
      seek old_pos, SEEK_SET
    end

    def ascii?
      case binary?
      when true   then false
      when false  then true
      end
    end

    def self.included(modul)
      modul.instance_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def binary?(name)
        File.open(name, 'rb') { |f| f.binary? }
      end

      def ascii?(name)
        File.open(name, 'rb') { |f| f.ascii? }
      end
    end
  end
end
