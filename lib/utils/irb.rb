require 'tins/xt'
require 'irb/completion'
require 'enumerator'
require 'tempfile'
require 'pp'
require_maybe 'ap'
require 'utils'

$editor = Utils::Editor.new
$pager = ENV['PAGER'] || 'less -r'

module Utils
  module IRB
    require 'utils/irb/service'

    module Shell
      require 'fileutils'
      include FileUtils
      include Tins::Find

      def receiver_unless_main(method, &block)
        receiver_name = method.receiver.to_s
        if receiver_name != 'main'
          if block
            block.(receiver_name)
          else
            receiver_name
          end
        end
      end
      private :receiver_unless_main

      # Start _ri_ for +pattern+. If +pattern+ is not string like, call it with
      # pattern.class.name as argument.
      def ri(*patterns, doc: 'ri')
        patterns.empty? and
          receiver_unless_main(method(__method__)) do |pattern|
            return ri(pattern, doc: doc)
          end
        patterns.map! { |p|
          case
          when Module === p
            p.name
          when p.respond_to?(:to_str)
            p.to_str
          else
            p.class.name
          end
        }
        system "#{doc} #{patterns.map { |p| "'#{p}'" } * ' ' } | #$pager"
      end

      def yri(*patterns)
        ri *patterns, doc: 'yri'
      end

      def irb_open(url = nil, &block)
        case
        when url
          system 'open', url
        when block
          Tempfile.open('wb') do |t|
            t.write capture_output(&block)
            t.rewind
            system 'open', t.path
          end
        when url = receiver_unless_main(method(__method__))
          irb_open url
        else
          raise ArgumentError, 'need an url or block'
        end
      end

      # Start an irb server.
      def irb_server(uri = nil)
        Utils::IRB::Service.start(uri) {}
      end

      # Connect to an irb server.
      def irb_connect(uri = nil)
        Utils::IRB::Service.connect(uri)
      end

      # TODO: change the API of this stuff

      # Return all instance methods of obj's class.
      def irb_all_class_instance_methods(obj = self)
        methods = obj.class.instance_methods
        irb_wrap_methods obj, methods
      end

      # Return instance methods of obj's class without the inherited/mixed in
      # methods.
      def irb_class_instance_methods(obj = self)
        methods = obj.class.instance_methods(false)
        irb_wrap_methods obj, methods
      end

      # Return all instance methods defined in module modul.
      def irb_all_instance_methods(modul = self)
        methods = modul.instance_methods
        irb_wrap_methods modul, methods, true
      end

      # Return instance methods defined in module modul without the inherited/mixed
      # in methods.
      def irb_instance_methods(modul = self)
        methods = modul.instance_methods(false)
        irb_wrap_methods modul, methods, true
      end

      # Return all methods of obj (including obj's eigenmethods.)
      def irb_all_methods(obj = self)
        methods = obj.methods
        irb_wrap_methods obj, methods
      end

      # Return instance methods of obj's class without the inherited/mixed in
      # methods, but including obj's eigenmethods.
      def irb_methods(obj = self)
        methods = obj.class.ancestors[1..-1].inject(obj.methods) do |all, a|
          all -= a.instance_methods
        end
        irb_wrap_methods obj, methods
      end

      # Return all eigen methods of obj.
      def irb_eigen_methods(obj = self)
        irb_wrap_methods obj, obj.methods(false)
      end

      def irb_wrap_methods(obj = self, methods = methods(), modul = false)
        methods.map do |name|
          MethodWrapper.new(obj, name, modul) rescue nil
        end.compact.sort!
      end

      class WrapperBase
        include Comparable

        def initialize(name)
          @name =
            case
            when name.respond_to?(:to_str)
              name.to_str
            when name.respond_to?(:to_sym)
              name.to_sym.to_s
            else
              name.to_s
            end
        end

        attr_reader :name

        attr_reader :description

        alias to_str description

        alias inspect description

        alias to_s description

        def ==(name)
          @name = name
        end

        alias eql? ==

        def hash
          @name.hash
        end

        def <=>(other)
          @name <=> other.name
        end
      end

      class MethodWrapper < WrapperBase
        def initialize(obj, name, modul)
          super(name)
          @method = modul ? obj.instance_method(name) : obj.method(name)
          @description = @method.description(style: :namespace)
        end

        attr_reader :method

        def owner
          method.respond_to?(:owner) ? method.owner : nil
        end

        def arity
          method.arity
        end

        def source_location
          method.source_location
        end

        def <=>(other)
          @description <=> other.description
        end
      end

      class ConstantWrapper < WrapperBase
        def initialize(obj, name)
          super(name)
          @klass = obj.class
          @description = "#@name:#@klass"
        end

        attr_reader :klass
      end

      # Return all the constants defined in +modul+.
      def irb_constants(modul = self)
        modul.constants.map { |c| ConstantWrapper.new(modul.const_get(c), c) }.sort
      end

      # Return all the subclasses of +klass+. TODO implement subclasses w/out rails
      def irb_subclasses(klass = self)
        klass.subclasses.map { |c| ConstantWrapper.new(eval(c), c) }.sort
      end

      unless Object.const_defined?(:Infinity)
        Infinity = 1.0 / 0 # I like to define the infinite.
      end

      def capture_output(with_stderr = false)
        require 'tempfile'
        begin
          old_stdout, $stdout = $stdout, Tempfile.new('irb')
          if with_stderr
            old_stderr, $stderr = $stderr, $stdout
          end
          yield
        ensure
          $stdout, temp = old_stdout, $stdout
          with_stderr and $stderr = old_stderr
        end
        temp.rewind
        temp.read
      end

      # Use pager on the output of the commands given in the block.
      def less(with_stderr = false, &block)
        IO.popen($pager, 'w') do |f|
          f.write capture_output(with_stderr, &block)
          f.close_write
        end
        nil
      end

      def irb_time
        s = Time.now
        yield
        d = Time.now - s
        warn "Took %.3fs seconds." % d
        d
      end

      def irb_time_tap
        r = nil
        irb_time { r = yield }
        r
      end

      def irb_time_watch(duration = 1)
        start = Time.now
        pre = nil
        loop do
          cur = [ yield ].flatten
          unless pre
            pre = cur.map(&:to_f)
            cur = [ yield ].flatten
          end
          expired = Time.now - start
          diffs = cur.zip(pre).map { |c, p| c - p }
          rates = diffs.map { |d| d / duration }
          warn "#{expired} #{cur.zip(rates, diffs).map(&:inspect) * ' '} # / per sec."
          pre = cur.map(&:to_f)
          sleep duration
        end
      end

      def irb_write(filename, text = nil, &block)
        if text.nil? && block
          File.secure_write filename, nil, 'wb', &block
        else
          File.secure_write filename, text, 'wb'
        end
      end

      def irb_read(filename, chunk_size = 8_192)
        if block_given?
          File.open(filename) do |file|
            until file.eof?
              yield file.read(chunk_size)
            end
          end
        else
          IO.read filename
        end
      end

      def irb_load!(*files)
        files = files.map { |f| f.gsub(/(\.rb)?\Z/, '.rb') }
        loaded = {}
        for file in files
          catch :found do
            Find.find('.') do |f|
              File.directory?(f) and next
              md5_f = Utils::MD5.md5(f)
              if f.end_with?(file) and !loaded[md5_f]
                Kernel.load f
                loaded[md5_f] = true
                STDERR.puts "Loaded '#{f}'."
              end
            end
            Find.find('.') do |f|
              File.directory?(f) and next
              md5_f = Utils::MD5.md5(f)
              if f.end_with?(file) and !loaded[md5_f]
                Kernel.load f
                loaded[md5_f] = true
                STDERR.puts "Loaded '#{f}'."
              end
            end
          end
        end
        nil
      end

      def irb_edit(*files)
        $editor.full?(:edit, *files)
      end

      def edit
        $editor.full?(:edit, self)
      end

      # List contents of directory
      def ls(*args)
        puts `ls #{args.map { |x| "'#{x}'" } * ' '}`
      end

      if defined?(ActiveRecord::Base)
        $logger = Logger.new(STDERR)
        def irb_toggle_logging
          require 'logger'
          if ActiveRecord::Base.logger != $logger
            $old_logger = ActiveRecord::Base.logger
            ActiveRecord::Base.logger = $logger
            true
          else
            ActiveRecord::Base.logger = $old_logger
            false
          end
        end
      end
    end

    module Regexp
      # Show the match of this Regexp on the +string+.
      def show_match(string)
        string =~ self ? "#{$`}<<#{$&}>>#{$'}" : "no match"
      end
    end

    module String
      # Pipe this string into +cmd+.
      def |(cmd)
        IO.popen(cmd, 'w+') do |f|
          f.write self
          f.close_write
          return f.read
        end
      end

      # Write this string into file +filename+.
      def >>(filename)
        File.secure_write(filename, self)
      end
    end

    def self.configure
      ::IRB.conf[:SAVE_HISTORY] = 1000
      if ::IRB.conf[:PROMPT]
        ::IRB.conf[:PROMPT][:CUSTOM] = {
          :PROMPT_I =>  ">> ",
          :PROMPT_N =>  ">> ",
          :PROMPT_S =>  "%l> ",
          :PROMPT_C =>  "+> ",
          :RETURN   =>  " # => %s\n"
        }
        ::IRB.conf[:PROMPT_MODE] = :CUSTOM
      end
    end
  end
end

Utils::IRB.configure

class String
  include Utils::IRB::String
end

class Object
  include Utils::IRB::Shell
end

class Regexp
  include Utils::IRB::Regexp
end
