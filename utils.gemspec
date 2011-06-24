# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{utils}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Florian Frank}]
  s.date = %q{2011-06-24}
  s.description = %q{This ruby gem provides some useful command line utilities}
  s.email = %q{flori@ping.de}
  s.executables = [%q{untest}, %q{chroot-libs}, %q{chroot-exec}, %q{number_files}, %q{search}, %q{edit}, %q{git-empty}, %q{classify}, %q{utils-install-config}, %q{xmp}, %q{discover}, %q{sshscreen}, %q{myex}, %q{errf}, %q{same_files}, %q{unquarantine_apps}, %q{vacuum_firefox_sqlite}, %q{sedit}]
  s.files = [%q{utils.gemspec}, %q{Rakefile}, %q{lib}, %q{lib/utils}, %q{lib/utils/config}, %q{lib/utils/config/screenrc}, %q{lib/utils/config/irbrc}, %q{lib/utils/config/rdebugrc}, %q{lib/utils/config/gdb}, %q{lib/utils/config/gdb/asm}, %q{lib/utils/config/gdb/ruby}, %q{lib/utils/config/vimrc}, %q{lib/utils/config/gdbinit}, %q{lib/utils/config/vim}, %q{lib/utils/config/vim/compiler}, %q{lib/utils/config/vim/compiler/rubyunit.vim}, %q{lib/utils/config/vim/compiler/ruby.vim}, %q{lib/utils/config/vim/compiler/eruby.vim}, %q{lib/utils/config/vim/syntax}, %q{lib/utils/config/vim/syntax/Decho.vim}, %q{lib/utils/config/vim/syntax/ruby.vim}, %q{lib/utils/config/vim/syntax/ragel.vim}, %q{lib/utils/config/vim/syntax/javascript.vim}, %q{lib/utils/config/vim/syntax/eruby.vim}, %q{lib/utils/config/vim/ftdetect}, %q{lib/utils/config/vim/ftdetect/ruby.vim}, %q{lib/utils/config/vim/ftdetect/ragel.vim}, %q{lib/utils/config/vim/autoload}, %q{lib/utils/config/vim/autoload/AlignMaps.vim}, %q{lib/utils/config/vim/autoload/rubycomplete.vim}, %q{lib/utils/config/vim/autoload/sqlcomplete.vim}, %q{lib/utils/config/vim/autoload/vimball.vim}, %q{lib/utils/config/vim/autoload/Align.vim}, %q{lib/utils/config/vim/autoload/rails.vim}, %q{lib/utils/config/vim/indent}, %q{lib/utils/config/vim/indent/IndentAnything_html.vim}, %q{lib/utils/config/vim/indent/ruby.vim}, %q{lib/utils/config/vim/indent/javascript.vim}, %q{lib/utils/config/vim/indent/eruby.vim}, %q{lib/utils/config/vim/colors}, %q{lib/utils/config/vim/colors/flori.vim}, %q{lib/utils/config/vim/plugin}, %q{lib/utils/config/vim/plugin/bufexplorer.vim}, %q{lib/utils/config/vim/plugin/AlignMapsPlugin.vim}, %q{lib/utils/config/vim/plugin/AlignPlugin.vim}, %q{lib/utils/config/vim/plugin/cecutil.vim}, %q{lib/utils/config/vim/plugin/taglist.vim}, %q{lib/utils/config/vim/plugin/Decho.vim}, %q{lib/utils/config/vim/plugin/IndentAnything.vim}, %q{lib/utils/config/vim/plugin/fugitive.vim}, %q{lib/utils/config/vim/plugin/test}, %q{lib/utils/config/vim/plugin/test/IndentAnything}, %q{lib/utils/config/vim/plugin/test/IndentAnything/test.js}, %q{lib/utils/config/vim/plugin/surround.vim}, %q{lib/utils/config/vim/plugin/lusty-explorer.vim}, %q{lib/utils/config/vim/plugin/vimballPlugin.vim}, %q{lib/utils/config/vim/plugin/rubyextra.vim}, %q{lib/utils/config/vim/plugin/rails.vim}, %q{lib/utils/config/vim/ftplugin}, %q{lib/utils/config/vim/ftplugin/ruby.vim}, %q{lib/utils/config/vim/ftplugin/xml.vim}, %q{lib/utils/config/vim/ftplugin/eruby.vim}, %q{lib/utils/version.rb}, %q{lib/utils/find.rb}, %q{lib/utils/config.rb}, %q{lib/utils/file_xt.rb}, %q{lib/utils/md5.rb}, %q{lib/utils/patterns.rb}, %q{lib/utils.rb}, %q{bin}, %q{bin/untest}, %q{bin/chroot-libs}, %q{bin/chroot-exec}, %q{bin/number_files}, %q{bin/search}, %q{bin/edit}, %q{bin/git-empty}, %q{bin/classify}, %q{bin/utils-install-config}, %q{bin/xmp}, %q{bin/discover}, %q{bin/sshscreen}, %q{bin/myex}, %q{bin/errf}, %q{bin/same_files}, %q{bin/unquarantine_apps}, %q{bin/vacuum_firefox_sqlite}, %q{bin/sedit}, %q{VERSION}]
  s.homepage = %q{http://flori.github.com/utils}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Some useful command line utilities}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spruz>, [">= 0"])
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 0"])
    else
      s.add_dependency(%q<spruz>, [">= 0"])
      s.add_dependency(%q<term-ansicolor>, [">= 0"])
    end
  else
    s.add_dependency(%q<spruz>, [">= 0"])
    s.add_dependency(%q<term-ansicolor>, [">= 0"])
  end
end
