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
  executables Dir['bin/*'].select { |e| File.new(e).readline =~ /ruby/ }.
    map(&File.method(:basename))
  test_dir    'tests'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', '.AppleDouble',
    'tags', '.bundle', '.DS_Store', '.byebug_history'
  package_ignore '.gitignore', 'VERSION'
  readme      'README.md'
  licenses << 'GPL-2.0'

  dependency 'unix_socks'
  dependency 'webrick'
  dependency 'tins',           '~> 1.14'
  dependency 'term-ansicolor', '~> 1.11'
  dependency 'pstree',         '~> 0.3'
  dependency 'infobar',        '~> 0.8'
  dependency 'mize',           '~> 0.6'
  dependency 'search_ui',      '~> 0.0'
  dependency 'all_images',     '~> 0.5.0'
  dependency 'ollama-ruby'
  dependency 'kramdown-ansi',  '~> 0.0.1'
  dependency 'simplecov'
  dependency 'debug'
  development_dependency 'test-unit'

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
        found_first_in_path.empty? or rm_f found_first_in_path
        install(file, bindir, :mode => 0755)
      end
    end
    ENV['NO_GEMS'].to_i == 1 or sh 'gem install tins term-ansicolor pstree infobar mize'
  end
end
