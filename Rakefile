# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'utils'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "http://github.com/flori/#{name}"
  summary     'Some useful command line utilities'
  description 'This ruby gem provides some useful command line utilities'
  bindir      'bin'
  executables Dir['bin/*'].map(&File.method(:basename))
  test_dir    'tests'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', '.AppleDouble', 'tags', '.bundle'
  readme      'README.md'

  dependency  'tins',           '~>1.0'
  dependency  'term-ansicolor', '~>1.3'
  dependency  'pstree',         '~>0.1'
  dependency  'pry-editline'

  install_library do
    libdir = CONFIG["sitelibdir"]
    cd 'lib' do
      for file in Dir['**/*.rb']
        dest = File.join(libdir, File.dirname(file))
        mkdir_p dest
        install(file, dest)
      end
    end
    bindir = CONFIG["bindir"]
    cd 'bin' do
      for file in executables
        found_first_in_path = `which #{file}`.chomp
        found_first_in_path.empty? or rm found_first_in_path
        install(file, bindir, :mode => 0755)
      end
    end
    ENV['NO_GEMS'].to_i == 1 or sh 'gem install tins term-ansicolor pstree pry-editline'
  end
end
