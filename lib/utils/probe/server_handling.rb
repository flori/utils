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
    # based on the specified server URL configuration
    #
    # This method acts as a factory for creating socket server objects,
    # delegating to the UnixSocks.from_url method to construct either a TCP
    # socket server or a domain socket server depending on the URL scheme
    # provided
    #
    # @param server_url [ String ] the URL specifying the socket server
    #   configuration
    #
    # @return [ UnixSocks::TCPSocketServer, UnixSocks::DomainSocketServer ] a
    #   new socket server instance configured according to the URL specification
    def create_server(server_url)
      UnixSocks.from_url(server_url)
    end
  end
end
