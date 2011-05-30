begin
  require 'rake/gempackagetask'
rescue LoadError
end
require 'rake/clean'
require 'rbconfig'
include Config

PKG_NAME    = 'utils'
PKG_VERSION = File.read('VERSION').chomp
PKG_FILES   = Dir['**/*']#FileList['**/*'].exclude(/(CVS|\.svn|pkg|.git*)/)
PKG_FILES.reject! { |f| f =~ /\Apkg/ }

if defined? Gem
  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = "Some useful command line utilities"
    s.description = "This ruby gem provides some useful command line utilities"

    s.files = PKG_FILES

    s.require_path = 'lib'

    s.bindir = "bin"
    s.executables.concat Dir['bin/*'].map { |f| File.basename(f) }
    s.add_dependency 'spruz'
    s.add_dependency 'term-ansicolor'

    s.author = "Florian Frank"
    s.email = "flori@ping.de"
    s.homepage = "http://flori.github.com/utils"
  end

  task :gemspec do
    File.open('utils.gemspec', 'w') do |output|
      output.write spec.to_ruby
    end
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
    pkg.package_files += PKG_FILES
  end
end

desc m = "Writing version information for #{PKG_VERSION}"
task :version do
  puts m
  File.open(File.join('lib', PKG_NAME, 'version.rb'), 'w') do |v|
    v.puts <<EOT
module Utils
  # Utils version
  VERSION         = '#{PKG_VERSION}'
  VERSION_ARRAY   = VERSION.split(/\\./).map { |x| x.to_i } # :nodoc:
  VERSION_MAJOR   = VERSION_ARRAY[0] # :nodoc:
  VERSION_MINOR   = VERSION_ARRAY[1] # :nodoc:
  VERSION_BUILD   = VERSION_ARRAY[2] # :nodoc:
end
EOT
  end
end

desc "Default task: write version and test"
task :default => [ :version, :test ]

desc "Prepare a release"
task :release => [ :clean, :version, :gemspec, :package ]
