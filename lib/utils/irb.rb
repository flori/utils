require 'tins/xt'
require 'irb/completion'
require 'enumerator'
require 'pp'
require_maybe 'ap'
if Readline.respond_to?(:point) && Readline.respond_to?(:line_buffer)
  require 'pry-editline'
end
require 'utils'
$editor = Utils::Editor.new
$pager = ENV['PAGER'] || 'less -r'

if IRB.conf[:PROMPT]
  IRB.conf[:PROMPT][:CUSTOM] = {
    :PROMPT_I =>  ">> ",
    :PROMPT_N =>  ">> ",
    :PROMPT_S =>  "%l> ",
    :PROMPT_C =>  "+> ",
    :RETURN   =>  " # => %s\n"
  }
  IRB.conf[:PROMPT_MODE] = :CUSTOM
end

module Utils
  module IRB

    module Shell
      require 'fileutils'
      include FileUtils
      require 'utils/find'
      include Utils::Find

      # Start _ri_ for +pattern+. If +pattern+ is not string like, call it with
      # pattern.class.name as argument.
      def ri(*patterns)
        patterns.map! { |p| p.respond_to?(:to_str) ? p.to_str : p.class.name }
        system "ri #{patterns.map { |p| "'#{p}'" } * ' '} | #{$pager}"
      end

      # Restart this irb.
      def irb_restart
        exec $0
      end

      # Return all instance methods of obj's class.
      def irb_all_class_instance_methods(obj)
        methods = obj.class.instance_methods
        irb_wrap_methods obj, methods
      end

      # Return instance methods of obj's class without the inherited/mixed in
      # methods.
      def irb_class_instance_methods(obj)
        methods = obj.class.instance_methods(false)
        irb_wrap_methods obj, methods
      end

      # Return all instance methods defined in module modul.
      def irb_all_instance_methods(modul)
        methods = modul.instance_methods
        irb_wrap_methods modul, methods, true
      end

      # Return instance methods defined in module modul without the inherited/mixed
      # in methods.
      def irb_instance_methods(modul)
        methods = modul.instance_methods(false)
        irb_wrap_methods modul, methods, true
      end

      # Return all methods of obj (including obj's eigenmethods.)
      def irb_all_methods(obj)
        methods = obj.methods
        irb_wrap_methods obj, methods
      end

      # Return instance methods of obj's class without the inherited/mixed in
      # methods, but including obj's eigenmethods.
      def irb_methods(obj)
        methods = obj.class.ancestors[1..-1].inject(obj.methods) do |all, a|
          all -= a.instance_methods
        end
        irb_wrap_methods obj, methods
      end

      # Return all eigen methods of obj.
      def irb_eigen_methods(obj)
        irb_wrap_methods obj, obj.methods(false)
      end

      def irb_wrap_methods(obj, methods, modul = false)
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

        alias to_str name

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
          if modul
            @arity = obj.instance_method(name).arity
          else
            @arity = obj.method(name).arity
          end
          @description = "#@name(#@arity)"
        end

        attr_reader :arity
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
      def irb_constants(modul)
        modul.constants.map { |c| ConstantWrapper.new(modul.const_get(c), c) }.sort
      end

      # Return all the subclasses of +klass+. TODO implement subclasses w/out rails
      def irb_subclasses(klass)
        klass.subclasses.map { |c| ConstantWrapper.new(eval(c), c) }.sort
      end

      unless Object.const_defined?(:Infinity)
        Infinity = 1.0 / 0 # I like to define the infinite.
      end

      # Output all kinds of information about +obj+. If detailed is given output
      # details about the methods (+ arity) in inheritance chain of +obj+ as well.
      # * detailed as 0 output instance methods only of part 0 (the first) of the
      #   chain.
      # * detailed as 1..2 output instance methods of +obj+ inherited from parts 1
      #   and 2 of the the chain.
      def irb_info(obj, detailed = nil)
        if Module === obj
          modul = obj
          klassp = Class === modul
          if klassp
            begin
              allocated = modul.allocate
            rescue TypeError
            else
              obj = allocated
            end
          end
        else
          modul = obj.class
        end
        inspected = obj.inspect
        puts "obj = #{inspected.size > 40 ? inspected[0, 40] + '...' : inspected} is of class #{obj.class}."
        am = irb_all_methods(obj).size
        ms = irb_methods(obj).size
        ems = irb_eigen_methods(obj).size
        puts "obj: #{am} methods, #{ms} only local#{ems > 0 ? " (#{ems} eigenmethods),": ','} #{am - ms} inherited/mixed in."
        acim = irb_all_class_instance_methods(obj).size
        cim = irb_class_instance_methods(obj).size
        puts "obj: #{acim} instance methods, #{cim} local, #{acim - cim} only inherited/mixed in."
        if klassp
          s = modul.superclass
          puts "Superclass of #{modul}: #{s}"
        end
        a = []
        ec = true
        begin
          a << (class << obj; self; end)
        rescue TypeError
          ec = false
        end
        a.concat modul.ancestors
        if ec
          puts "Ancestors of #{modul}: (#{a[0]},) #{a[1..-1].map { |k| "#{k}#{k == s ? '*' : ''}" } * ', '}"
        else
          puts "Ancestors of #{modul}: #{a[0..-1].map { |k| "#{k}#{k == s ? '*' : ''}" } * ', '}"
        end
        if Class === modul and detailed
          if detailed.respond_to? :to_int
            detailed = detailed..detailed
          end
          detailed.each do |i|
            break if i >= a.size
            k = a[i]
            puts "#{k}:"
            puts irb_wrap_methods(obj, k.instance_methods(false)).sort
          end
        end
        nil
      end

      # Output *all* the irb_info about +obj+. You may need to buy a bigger screen for
      # this or use:
      #  less { irb_fullinfo object }
      def irb_fullinfo(obj)
        irb_info obj, 0..Infinity
      end

      def capture_output(with_stderr = false)
        return "missing block" unless block_given?
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

      def irb_write(filename, text = nil)
        File.secure_write filename, text, 'wb'
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

    module Module
      # Start +ri+ for +module#pattern+, trying to find a method matching +pattern+
      # for all modules in the ancestors chain of this module.
      def ri(pattern = nil)
        if pattern
          pattern = pattern.to_sym.to_s if pattern.respond_to? :to_sym
          ancestors.each do |a|
            if method = a.instance_methods(false).find { |m| pattern === m }
              a = Object if a == Kernel # ri seems to be confused
              system "ri #{a}##{method} | #{$pager}"
            end
          end
        else
          system "ri #{self} | #{$pager}"
        end
        return
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

    module Relation
      def explain
        connection.select_all("EXPLAIN #{to_sql}")
      end
    end
  end
end

module IRB
  class Context
    def init_save_history
      unless (class<<@io;self;end).include?(HistorySavingAbility)
        @io.extend(HistorySavingAbility)
      end
    end

    def save_history
      IRB.conf[:SAVE_HISTORY]
    end

    def save_history=(val)
      IRB.conf[:SAVE_HISTORY] = val
      if val
        main_context = IRB.conf[:MAIN_CONTEXT]
        main_context = self unless main_context
        main_context.init_save_history
      end
    end

    def history_file
      IRB.conf[:HISTORY_FILE]
    end

    def history_file=(hist)
      IRB.conf[:HISTORY_FILE] = hist
    end
  end

  module HistorySavingAbility
    include Readline

    def HistorySavingAbility.create_finalizer
      at_exit do
        if num = IRB.conf[:SAVE_HISTORY] and (num = num.to_i) > 0
          if hf = IRB.conf[:HISTORY_FILE]
            file = File.expand_path(hf)
          end
          file = IRB.rc_file("_history") unless file
          open(file, 'w' ) do |f|
            hist = HISTORY.to_a
            f.puts(hist[-num..-1] || hist)
          end
        end
      end
    end

    def HistorySavingAbility.extended(obj)
      HistorySavingAbility.create_finalizer
      obj.load_history
      obj
    end

    def load_history
      hist = IRB.conf[:HISTORY_FILE]
      hist = IRB.rc_file("_history") unless hist
      if File.exist?(hist)
        open(hist) do |f|
          f.each {|l| HISTORY << l.chomp}
        end
      end
    end
  end
end
IRB.conf[:SAVE_HISTORY] = 1000

if defined?(ActiveRecord::Relation)
  class ActiveRecord::Relation
    include Utils::IRB::Relation
  end
end

class String
  include Utils::IRB::String
end

class Object
  include Utils::IRB::Shell
end

class Module
  include Utils::IRB::Module
end

class Regexp
  include Utils::IRB::Regexp
end