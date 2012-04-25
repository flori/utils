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
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', '.AppleDouble'
  readme      'README.rdoc'

  dependency  'tins',           '~>0.3.13'
  dependency  'term-ansicolor', '~>1.0'
  dependency  'dslkit',         '~>0.2.10'
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
        install(file, bindir, :mode => 0755)
      end
    end
  end
end
