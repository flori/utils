module Utils::Probe
  # A module that provides server handling functionality for creating and
  # managing socket servers.
  #
  # This module encapsulates the logic for initializing different types of
  # socket servers based on the specified server type, supporting both TCP and
  # domain socket configurations. It provides a centralized approach to server
  # creation and management within the Utils library.
  module ServerHandling
    # The create_server method initializes and returns a socket server instance
    # based on the specified server type.
    #
    # This method creates either a TCP socket server or a domain socket server
    # depending on the server type parameter. It configures the server with the
    # appropriate parameters including port number for TCP servers or socket
    # name and runtime directory for domain sockets.
    #
    # @param server_type [ Symbol ] the type of socket server to create, either :tcp or another value for domain socket
    # @param port [ Integer ] the port number to use for TCP socket server creation
    #
    # @return [ UnixSocks::TCPSocketServer, UnixSocks::DomainSocketServer ] a
    #   new socket server instance of the specified type
    def create_server(server_type, port)
      case server_type
      when :tcp
        UnixSocks::TCPSocketServer.new(port:)
      else
        UnixSocks::DomainSocketServer.new(socket_name: 'probe.sock', runtime_dir: Dir.pwd)
      end
    end
  end
end
