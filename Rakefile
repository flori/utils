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
  executables = Dir['bin/*'].map(&File.method(:basename))
  test_dir    'tests'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock'
  readme      'README.rdoc'
  executables  << 'bs_compare'

  dependency  'spruz', '~>0.2.10'
  dependency  'term-ansicolor', '1.0.5'

  install_library do
    libdir = CONFIG["sitelibdir"]
    install('lib/bullshit.rb', libdir, :mode => 0644)
    mkdir_p subdir = File.join(libdir, 'bullshit')
    for f in Dir['lib/bullshit/*.rb']
      install(f, subdir)
    end
    bindir = CONFIG["bindir"]
    install('bin/bs_compare', bindir, :mode => 0755)
  end
end
