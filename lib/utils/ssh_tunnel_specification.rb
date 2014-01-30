module Utils
  class SshTunnelSpecification
    def initialize(spec_string)
      interpret_spec(spec_string)
    end

    attr_reader :local_addr

    attr_reader :local_port

    attr_reader :remote_addr

    attr_reader :remote_port

    def to_a
      [ local_addr, local_port, remote_addr, remote_port ]
    end

    def valid?
      if to_a.all?
        to_s
      end
    end

    def to_s
      to_a * ':'
    end

    private

    def interpret_spec(spec_string)
      @local_addr, @local_port, @remote_addr, @remote_port =
        case spec_string
        when /\A(\d+)\z/
          [ 'localhost', $1.to_i, 'localhost', $1.to_i ]
        when /\A(\[[^\]]+\]|[^:]+):(\d+)\z/
          [ 'localhost', $2.to_i, $1, $2.to_i ]
        when /\A(\d+):(\[[^\]]+\]|[^:]+):(\d+)\z/
          [ 'localhost', $1.to_i, $2, $3.to_i ]
        when /\A(\[[^\]]+\]|[^:]+):(\[[^\]]+\]|[^:]+):(\d+)\z/
          [ $1, $3.to_i, $2, $3.to_i ]
        when /\A(\[[^\]]+\]|[^:]+):(\d+):(\[[^\]]+\]|[^:]+):(\d+)\z/
          [ $1, $2.to_i, $3, $4.to_i ]
        end
    end
  end
end
