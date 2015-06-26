require 'drb'

module Utils::IRB::Service
  class << self
    attr_accessor :hostname

    attr_accessor :port

    def start(uri = nil, &block)
      uri ||= "druby://localhost:6642"
      block    ||= proc {}
      puts "Starting IRB server listening to #{uri.inspect}."
      DRb.start_service(uri, eval('irb_current_working_binding', block.binding))
    end

    def connect(uri = nil)
      uri ||= "druby://localhost:6642"
      irb = DRbObject.new_with_uri(uri)
      Proxy.new(irb)
    end
  end

  class Proxy
    def initialize(irb)
      @irb = irb
    end

    def eval(code)
      @irb.conf.workspace.evaluate nil, code
    end

    def load(filename)
      unless filename.start_with?('/')
        filename = File.expand_path filename
      end
      @irb.load filename
    end
  end
end
