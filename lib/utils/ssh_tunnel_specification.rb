module Utils
  # A class that represents an SSH tunnel specification for configuring network
  # connections.
  #
  # This class parses and stores the configuration details for SSH tunnels,
  # including local and remote address/port combinations. It provides methods
  # to validate the specification, convert it to string or array
  # representations, and access individual components of the tunnel
  # configuration.
  #
  # @example
  #   spec = Utils::SshTunnelSpecification.new('localhost:8080:remote.host:22')
  #   spec.local_addr  # => 'localhost'
  #   spec.local_port  # => 8080
  #   spec.remote_addr # => 'remote.host'
  #   spec.remote_port # => 22
  class SshTunnelSpecification
    # Initializes a new SshTunnelSpecification instance by parsing the provided
    # specification string.
    #
    # This method takes a specification string and extracts local and remote
    # address/port combinations to configure the SSH tunnel parameters. The
    # specification can take various formats including port-only
    # specifications, localhost mappings, and full address:port combinations.
    #
    # @param spec_string [ String ] the specification string defining the SSH
    # tunnel configuration
    def initialize(spec_string)
      interpret_spec(spec_string)
    end

    # Returns the local address component of the SSH tunnel specification.
    #
    # @return [ String, nil ] the local address used for the SSH tunnel connection
    attr_reader :local_addr

    # Returns the local port component of the SSH tunnel specification.
    #
    # @return [ Integer, nil ] the local port number used for the SSH tunnel connection
    attr_reader :local_port

    # Returns the remote address component of the SSH tunnel specification.
    #
    # @return [ String, nil ] the remote address used for the SSH tunnel connection
    attr_reader :remote_addr

    # Returns the remote port component of the SSH tunnel specification.
    #
    # @return [ Integer, nil ] the remote port number used for the SSH tunnel connection
    attr_reader :remote_port

    # Returns an array representation of the SSH tunnel specification.
    #
    # This method combines the local and remote address/port components into a
    # four-element array in the order: [local_addr, local_port, remote_addr, remote_port].
    #
    # @return [ Array<String, Integer, String, Integer> ] an array containing the
    #         local address, local port, remote address, and remote port values
    def to_a
      [ local_addr, local_port, remote_addr, remote_port ]
    end

    # Checks if all components of the SSH tunnel specification are present and
    # valid.
    #
    # This method verifies that all address and port components of the tunnel
    # configuration have been set. If all components are present, it returns
    # the string representation of the specification; otherwise, it returns
    # nil.
    #
    # @return [ String, nil ] the string representation of the specification if all
    #         components are present, otherwise nil
    def valid?
      if to_a.all?
        to_s
      end
    end

    # Returns a string representation of the SSH tunnel specification.
    #
    # This method combines the local address, local port, remote address, and
    # remote port components into a single colon-separated string format.
    #
    # @return [ String ] a colon-separated string containing the tunnel specification
    #         in the format "local_addr:local_port:remote_addr:remote_port"
    def to_s
      to_a * ':'
    end

    private

    # Parses a specification string to extract local and remote address/port
    # components for SSH tunnel configuration.
    #
    # This method processes a given specification string and extracts the
    # necessary components to configure an SSH tunnel, handling various format
    # patterns including port-only specifications, localhost mappings, and full
    # address:port combinations.
    #
    # @param spec_string [ String ] the specification string defining the SSH tunnel configuration
    #
    # @return [ Array<String, Integer, String, Integer> ] an array containing the local address,
    #         local port, remote address, and remote port values extracted from the specification
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
