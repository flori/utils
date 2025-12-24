# A module that provides probe server functionality for managing and executing
# process jobs through Unix domain sockets.
#
# This module encapsulates the core components for creating and interacting
# with probe servers that can enqueue and run process jobs in a distributed
# manner.
#
# The module includes classes for handling server communication, managing
# process jobs, and providing client interfaces for interacting with probe
# servers.
#
# It supports both TCP and Unix domain socket configurations for server
# communication and provides mechanisms for environment variable management and
# job execution tracking.
module Utils::Probe
end

require 'unix_socks'
require 'term/ansicolor'
require 'utils/probe/server_handling'
require 'utils/probe/process_job'
require 'utils/probe/probe_server'
require 'utils/probe/probe_client'
