# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{utils}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Florian Frank}]
  s.date = %q{2011-07-17}
  s.description = %q{This ruby gem provides some useful command line utilities}
  s.email = %q{flori@ping.de}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{lib/utils/version.rb}, %q{lib/utils/find.rb}, %q{lib/utils/config.rb}, %q{lib/utils/edit.rb}, %q{lib/utils/file_xt.rb}, %q{lib/utils/md5.rb}, %q{lib/utils/patterns.rb}, %q{lib/utils.rb}]
  s.files = [%q{.gitignore}, %q{COPYING}, %q{Gemfile}, %q{README.rdoc}, %q{Rakefile}, %q{VERSION}, %q{bin/chroot-exec}, %q{bin/chroot-libs}, %q{bin/classify}, %q{bin/discover}, %q{bin/edit}, %q{bin/edit_wait}, %q{bin/errf}, %q{bin/git-empty}, %q{bin/myex}, %q{bin/number_files}, %q{bin/path}, %q{bin/same_files}, %q{bin/search}, %q{bin/sedit}, %q{bin/sshscreen}, %q{bin/unquarantine_apps}, %q{bin/untest}, %q{bin/utils-install-config}, %q{bin/vacuum_firefox_sqlite}, %q{bin/xmp}, %q{lib/utils.rb}, %q{lib/utils/config.rb}, %q{lib/utils/config/gdb/asm}, %q{lib/utils/config/gdb/ruby}, %q{lib/utils/config/gdbinit}, %q{lib/utils/config/irbrc}, %q{lib/utils/config/rdebugrc}, %q{lib/utils/config/screenrc}, %q{lib/utils/config/vim/autoload/Align.vim}, %q{lib/utils/config/vim/autoload/AlignMaps.vim}, %q{lib/utils/config/vim/autoload/rails.vim}, %q{lib/utils/config/vim/autoload/rubycomplete.vim}, %q{lib/utils/config/vim/autoload/sqlcomplete.vim}, %q{lib/utils/config/vim/autoload/vimball.vim}, %q{lib/utils/config/vim/colors/flori.vim}, %q{lib/utils/config/vim/compiler/eruby.vim}, %q{lib/utils/config/vim/compiler/ruby.vim}, %q{lib/utils/config/vim/compiler/rubyunit.vim}, %q{lib/utils/config/vim/ftdetect/ragel.vim}, %q{lib/utils/config/vim/ftdetect/ruby.vim}, %q{lib/utils/config/vim/ftplugin/eruby.vim}, %q{lib/utils/config/vim/ftplugin/ruby.vim}, %q{lib/utils/config/vim/ftplugin/xml.vim}, %q{lib/utils/config/vim/indent/IndentAnything_html.vim}, %q{lib/utils/config/vim/indent/eruby.vim}, %q{lib/utils/config/vim/indent/javascript.vim}, %q{lib/utils/config/vim/indent/ruby.vim}, %q{lib/utils/config/vim/plugin/AlignMapsPlugin.vim}, %q{lib/utils/config/vim/plugin/AlignPlugin.vim}, %q{lib/utils/config/vim/plugin/Decho.vim}, %q{lib/utils/config/vim/plugin/IndentAnything.vim}, %q{lib/utils/config/vim/plugin/bufexplorer.vim}, %q{lib/utils/config/vim/plugin/cecutil.vim}, %q{lib/utils/config/vim/plugin/fugitive.vim}, %q{lib/utils/config/vim/plugin/lusty-explorer.vim}, %q{lib/utils/config/vim/plugin/rails.vim}, %q{lib/utils/config/vim/plugin/rubyextra.vim}, %q{lib/utils/config/vim/plugin/surround.vim}, %q{lib/utils/config/vim/plugin/taglist.vim}, %q{lib/utils/config/vim/plugin/test/IndentAnything/test.js}, %q{lib/utils/config/vim/plugin/vimballPlugin.vim}, %q{lib/utils/config/vim/syntax/Decho.vim}, %q{lib/utils/config/vim/syntax/eruby.vim}, %q{lib/utils/config/vim/syntax/javascript.vim}, %q{lib/utils/config/vim/syntax/ragel.vim}, %q{lib/utils/config/vim/syntax/ruby.vim}, %q{lib/utils/config/vimrc}, %q{lib/utils/edit.rb}, %q{lib/utils/file_xt.rb}, %q{lib/utils/find.rb}, %q{lib/utils/md5.rb}, %q{lib/utils/patterns.rb}, %q{lib/utils/version.rb}, %q{utils.gemspec}]
  s.homepage = %q{http://github.com/flori/utils}
  s.rdoc_options = [%q{--title}, %q{Utils - Some useful command line utilities}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Some useful command line utilities}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.0.5"])
      s.add_runtime_dependency(%q<spruz>, ["~> 0.2.10"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["= 1.0.5"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.0.5"])
      s.add_dependency(%q<spruz>, ["~> 0.2.10"])
      s.add_dependency(%q<term-ansicolor>, ["= 1.0.5"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.0.5"])
    s.add_dependency(%q<spruz>, ["~> 0.2.10"])
    s.add_dependency(%q<term-ansicolor>, ["= 1.0.5"])
  end
end
