require 'pathname'

module Utils
  module Find
    class ConfigurableFinder
      module PathExtension
        attr_writer :finder

        def file
          tried = false
          begin
            file = @finder.get_file(self)
            if file
              file.closed? and file.reopen
            else
              file = File.new(self)
              @finder.add_file self, file
            end
            return file
          rescue Errno::EMFILE
            tried and raise
            @finder.close_files
            tried = true
            retry
          rescue Errno::ENOENT, Errno::EACCES
            return
          end
        end

        def pathname
          Pathname.new(self)
        end

        def suffix
          pathname.extname[1..-1]
        end

        def exist?
          !!file
        end

        def stat
          file and file.stat
        end

        def lstat
          file and file.lstat
        end
      end

      def initialize(opts = {})
        @files = {}
        opts[:suffix].full? { |s| @suffix = [*s] }
        @follow_symlinks = opts.fetch(:follow_symlinks, false)
      end

      def include_suffix?(suffix)
        @suffix.nil? || @suffix.include?(suffix)
      end

      def visit_file?(file)
        suffix = File.extname(file).full?(:[], 1..-1) || ''
        include_suffix?(suffix)
      end

      def prepare_file(file)
        path = file.dup.taint
        path.extend PathExtension
        path.finder = self
        path
      end

      def get_file(path)
        @files[path]
      end

      def add_file(path, file)
        @files[path] = file
        self
      end

      def close_files
        @files.each_value do |f|
          f.closed? or f.close
        end
        nil
      end

      def stat(file)
        @follow_symlinks ? file.stat : file.lstat
      end

      def find(*paths, &block)
        block_given? or return enum_for(__method__, *paths)

        paths.map! do |d|
          File.exist?(d) or raise Errno::ENOENT
          d.dup
        end

        while file = paths.shift
          catch(:prune) do
            file = prepare_file(file)
            visit_file?(file) and yield file
            begin
              s = stat(file) or next
            rescue Errno::ENOENT, Errno::EACCES, Errno::ENOTDIR, Errno::ELOOP, Errno::ENAMETOOLONG
              next
            end
            if s.directory? then
              begin
                tried = false
                fs = Dir.entries(file)
              rescue Errno::EMFILE
                tried and raise
                close_files
                tried = true
                retry
              rescue Errno::ENOENT, Errno::EACCES, Errno::ENOTDIR, Errno::ELOOP, Errno::ENAMETOOLONG
                next
              end
              fs.sort!
              fs.reverse_each do |f|
                next if f == "." or f == ".."
                f = File.join(file, f)
                paths.unshift f.untaint
              end
            end
          end
        end
      end
    end

    # Calls the associated block with the name of every file and directory
    # listed as arguments, then recursively on their subdirectories, and so on.
    #
    # See the +Find+ module documentation for an example.
    #
    def find(*paths, &block) # :yield: path
      paths, options = paths.extract_last_argument_options
      ConfigurableFinder.new(options).find(*paths, &block)
    end

    #
    # Skips the current file or directory, restarting the loop with the next
    # entry. If the current file is a directory, that directory will not be
    # recursively entered. Meaningful only within the block associated with
    # Find::find.
    #
    # See the +Find+ module documentation for an example.
    #
    def prune
      throw :prune
    end

    module_function :find, :prune
  end
end
