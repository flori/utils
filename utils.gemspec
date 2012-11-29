# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "utils"
  s.version = "0.0.65"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = "2012-11-29"
  s.description = "This ruby gem provides some useful command line utilities"
  s.email = "flori@ping.de"
  s.executables = ["chroot-exec", "chroot-libs", "classify", "create_tags", "discover", "edit", "edit_wait", "enum", "errf", "git-empty", "myex", "number_files", "on_change", "path", "probe", "same_files", "search", "sedit", "sshscreen", "strip_spaces", "unquarantine_apps", "untest", "utils-install-config", "utils-utilsrc", "vacuum_firefox_sqlite", "xmp"]
  s.extra_rdoc_files = ["README.rdoc", "lib/utils.rb", "lib/utils/config.rb", "lib/utils/config/config_file.rb", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/version.rb"]
  s.files = [".gitignore", "COPYING", "Gemfile", "README.rdoc", "Rakefile", "TODO", "VERSION", "bin/chroot-exec", "bin/chroot-libs", "bin/classify", "bin/create_tags", "bin/discover", "bin/edit", "bin/edit_wait", "bin/enum", "bin/errf", "bin/git-empty", "bin/myex", "bin/number_files", "bin/on_change", "bin/path", "bin/probe", "bin/same_files", "bin/search", "bin/sedit", "bin/sshscreen", "bin/strip_spaces", "bin/unquarantine_apps", "bin/untest", "bin/utils-install-config", "bin/utils-utilsrc", "bin/vacuum_firefox_sqlite", "bin/xmp", "lib/utils.rb", "lib/utils/config.rb", "lib/utils/config/config_file.rb", "lib/utils/config/gdb/asm", "lib/utils/config/gdb/ruby", "lib/utils/config/gdbinit", "lib/utils/config/irbrc", "lib/utils/config/rdebugrc", "lib/utils/config/rvmrc", "lib/utils/config/screenrc", "lib/utils/config/utilsrc", "lib/utils/config/vim/after/syntax/haml.vim", "lib/utils/config/vim/after/syntax/html.vim", "lib/utils/config/vim/autoload/Align.vim", "lib/utils/config/vim/autoload/AlignMaps.vim", "lib/utils/config/vim/autoload/ctrlp.vim", "lib/utils/config/vim/autoload/ctrlp/bookmarkdir.vim", "lib/utils/config/vim/autoload/ctrlp/buffertag.vim", "lib/utils/config/vim/autoload/ctrlp/changes.vim", "lib/utils/config/vim/autoload/ctrlp/dir.vim", "lib/utils/config/vim/autoload/ctrlp/line.vim", "lib/utils/config/vim/autoload/ctrlp/mixed.vim", "lib/utils/config/vim/autoload/ctrlp/mrufiles.vim", "lib/utils/config/vim/autoload/ctrlp/quickfix.vim", "lib/utils/config/vim/autoload/ctrlp/rtscript.vim", "lib/utils/config/vim/autoload/ctrlp/tag.vim", "lib/utils/config/vim/autoload/ctrlp/undo.vim", "lib/utils/config/vim/autoload/ctrlp/utils.vim", "lib/utils/config/vim/autoload/rails.vim", "lib/utils/config/vim/autoload/rubycomplete.vim", "lib/utils/config/vim/autoload/sqlcomplete.vim", "lib/utils/config/vim/autoload/vimball.vim", "lib/utils/config/vim/colors/flori.vim", "lib/utils/config/vim/compiler/coffee.vim", "lib/utils/config/vim/compiler/eruby.vim", "lib/utils/config/vim/compiler/ruby.vim", "lib/utils/config/vim/compiler/rubyunit.vim", "lib/utils/config/vim/doc/Decho.txt", "lib/utils/config/vim/doc/coffee-script.txt", "lib/utils/config/vim/doc/ctrlp.txt", "lib/utils/config/vim/doc/fugitive.txt", "lib/utils/config/vim/doc/rails.txt", "lib/utils/config/vim/doc/xml-plugin.txt", "lib/utils/config/vim/ftdetect/coffee.vim", "lib/utils/config/vim/ftdetect/eco.vim", "lib/utils/config/vim/ftdetect/ragel.vim", "lib/utils/config/vim/ftdetect/ruby.vim", "lib/utils/config/vim/ftdetect/slim.vim", "lib/utils/config/vim/ftplugin/coffee.vim", "lib/utils/config/vim/ftplugin/eruby.vim", "lib/utils/config/vim/ftplugin/ruby.vim", "lib/utils/config/vim/ftplugin/xml.vim", "lib/utils/config/vim/indent/IndentAnything_html.vim", "lib/utils/config/vim/indent/coffee.vim", "lib/utils/config/vim/indent/eruby.vim", "lib/utils/config/vim/indent/javascript.vim", "lib/utils/config/vim/indent/ruby.vim", "lib/utils/config/vim/indent/slim.vim", "lib/utils/config/vim/plugin/AlignMapsPlugin.vim", "lib/utils/config/vim/plugin/AlignPlugin.vim", "lib/utils/config/vim/plugin/Decho.vim", "lib/utils/config/vim/plugin/IndentAnything.vim", "lib/utils/config/vim/plugin/bufexplorer.vim", "lib/utils/config/vim/plugin/cecutil.vim", "lib/utils/config/vim/plugin/ctrlp.vim", "lib/utils/config/vim/plugin/fugitive.vim", "lib/utils/config/vim/plugin/lusty-explorer.vim", "lib/utils/config/vim/plugin/rails.vim", "lib/utils/config/vim/plugin/rubyextra.vim", "lib/utils/config/vim/plugin/surround.vim", "lib/utils/config/vim/plugin/taglist.vim", "lib/utils/config/vim/plugin/test/IndentAnything/test.js", "lib/utils/config/vim/plugin/vimballPlugin.vim", "lib/utils/config/vim/syntax/Decho.vim", "lib/utils/config/vim/syntax/coffee.vim", "lib/utils/config/vim/syntax/eco.vim", "lib/utils/config/vim/syntax/eruby.vim", "lib/utils/config/vim/syntax/javascript.vim", "lib/utils/config/vim/syntax/ragel.vim", "lib/utils/config/vim/syntax/ruby.vim", "lib/utils/config/vim/syntax/slim.vim", "lib/utils/config/vimrc", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/version.rb", "utils.gemspec"]
  s.homepage = "http://github.com/flori/utils"
  s.rdoc_options = ["--title", "Utils - Some useful command line utilities", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Some useful command line utilities"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_runtime_dependency(%q<tins>, ["~> 0.6"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.0"])
      s.add_runtime_dependency(%q<dslkit>, ["~> 0.2.10"])
      s.add_runtime_dependency(%q<pry-editline>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_dependency(%q<tins>, ["~> 0.6"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.0"])
      s.add_dependency(%q<dslkit>, ["~> 0.2.10"])
      s.add_dependency(%q<pry-editline>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
    s.add_dependency(%q<tins>, ["~> 0.6"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.0"])
    s.add_dependency(%q<dslkit>, ["~> 0.2.10"])
    s.add_dependency(%q<pry-editline>, [">= 0"])
  end
end
