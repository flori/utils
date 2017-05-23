require 'tins/deep_const_get'

module Utils
  module Xt
    module SourceLocationExtension
      include Tins::DeepConstGet

      CLASS_METHOD_REGEXP    = /\A([A-Z][\w:]+)([#.])([\w!?]+)/

      FILE_LINENUMBER_REGEXP = /\A\s*([^:]+):(\d+)-?(\d+)?/

      def source_location
        filename   = nil
        linenumber = nil
        rangeend   = nil
        if respond_to?(:to_str)
          string = to_str
          case
          when string =~ FILE_LINENUMBER_REGEXP && File.exist?($1)
            filename   = $1
            linenumber = $2.to_i
            rangeend   = $3&.to_i
          when string =~ CLASS_METHOD_REGEXP && !File.exist?(string)
            klassname   = $1
            method_kind = $2 == '#' ? :instance_method : :method
            methodname  = $3
            filename, linenumber =
              deep_const_get(klassname).__send__(method_kind, methodname).source_location
          else
            filename = string
          end
        else
          filename = to_s
        end
        array = linenumber ? [ filename, linenumber ] : [ filename, 1 ]
        array_singleton_class = class << array; self; end
        array_singleton_class.instance_eval do
          define_method(:filename) { filename }
          define_method(:linenumber) { linenumber }
          define_method(:rangeend) { rangeend }
          define_method(:to_s) { [ filename, linenumber ].compact * ':' }
          define_method(:range) { rangeend ? "#{to_s}-#{rangeend}" : "#{to_s}" }
        end
        array
      end
    end
  end
end
