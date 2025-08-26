module Utils
  # Extension module for adding source location functionality to objects.
  #
  # This module provides enhanced source location capabilities by extending
  # objects with methods that can determine file paths and line numbers
  # associated with method definitions, class references, or file-based
  # locations. It supports parsing of various input formats including file:line
  # syntax, class.method patterns, and provides convenient accessors for
  # filename, line number, and range information through the source_location
  # method.
  module Xt
    # Extension module for adding source location functionality to objects.
    #
    # This module provides enhanced source location capabilities by extending
    # objects with methods that can determine file paths and line numbers
    # associated with method definitions, class references, or file-based
    # locations. It supports parsing of various input formats including
    # file:line syntax, class.method patterns, and provides convenient
    # accessors for filename, line number, and range information through the
    # source_location method.
    module SourceLocationExtension
      # Regular expression to match Ruby class method signatures
      # Matches patterns like "ClassName#method" or "ClassName.method"
      CLASS_METHOD_REGEXP    = /\A([A-Z][\w:]+)([#.])([\w!?]+)/

      # Regular expression to parse file path and line number information
      # Matches patterns like "file.rb:123" or "file.rb:123-125"
      FILE_LINENUMBER_REGEXP = /\A\s*([^:]+):(\d+)-?(\d+)?/

      # The source_location method determines the file path and line number
      # information for an object.
      #
      # This method analyzes the object to extract source location details,
      # handling different cases including string representations that contain
      # file paths with line numbers, class method references, or simple file
      # names. It returns an array containing the filename and line number,
      # along with additional methods attached to the array for convenient
      # access to location information.
      #
      # @return [ Array<String, Integer> ] an array containing the filename and line number,
      #         with additional methods attached for accessing filename, linenumber, and range properties
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
            filename, linenumber = ::Object.const_get(klassname).
              __send__(method_kind, methodname).source_location
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
