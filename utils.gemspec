# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "utils"
  s.version = "0.0.40"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = "2012-04-09"
  s.description = "This ruby gem provides some useful command line utilities"
  s.email = "flori@ping.de"
  s.executables = ["untest", "chroot-libs", "edit_wait", "chroot-exec", "number_files", "search", "strip_spaces", "path", "enum", "edit", "git-empty", "classify", "utils-install-config", "xmp", "discover", "sshscreen", "myex", "probe", "errf", "same_files", "utils-utilsrc", "unquarantine_apps", "vacuum_firefox_sqlite", "sedit"]
  s.extra_rdoc_files = ["README.rdoc", "lib/utils/config/config_file.rb", "lib/utils/finder.rb", "lib/utils/version.rb", "lib/utils/find.rb", "lib/utils/config.rb", "lib/utils/editor.rb", "lib/utils/grepper.rb", "lib/utils/file_xt.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils.rb"]
  s.files = [".gitignore", "COPYING", "Gemfile", "README.rdoc", "Rakefile", "TODO", "VERSION", "bin/chroot-exec", "bin/chroot-libs", "bin/classify", "bin/discover", "bin/edit", "bin/edit_wait", "bin/enum", "bin/errf", "bin/git-empty", "bin/myex", "bin/number_files", "bin/path", "bin/probe", "bin/same_files", "bin/search", "bin/sedit", "bin/sshscreen", "bin/strip_spaces", "bin/unquarantine_apps", "bin/untest", "bin/utils-install-config", "bin/utils-utilsrc", "bin/vacuum_firefox_sqlite", "bin/xmp", "lib/utils.rb", "lib/utils/config.rb", "lib/utils/config/config_file.rb", "lib/utils/config/gdb/asm", "lib/utils/config/gdb/ruby", "lib/utils/config/gdbinit", "lib/utils/config/irbrc", "lib/utils/config/rdebugrc", "lib/utils/config/rvmrc", "lib/utils/config/screenrc", "lib/utils/config/utilsrc", "lib/utils/config/vim/autoload/Align.vim", "lib/utils/config/vim/autoload/AlignMaps.vim", "lib/utils/config/vim/autoload/rails.vim", "lib/utils/config/vim/autoload/rubycomplete.vim", "lib/utils/config/vim/autoload/sqlcomplete.vim", "lib/utils/config/vim/autoload/vimball.vim", "lib/utils/config/vim/colors/flori.vim", "lib/utils/config/vim/compiler/eruby.vim", "lib/utils/config/vim/compiler/ruby.vim", "lib/utils/config/vim/compiler/rubyunit.vim", "lib/utils/config/vim/ftdetect/ragel.vim", "lib/utils/config/vim/ftdetect/ruby.vim", "lib/utils/config/vim/ftplugin/eruby.vim", "lib/utils/config/vim/ftplugin/ruby.vim", "lib/utils/config/vim/ftplugin/xml.vim", "lib/utils/config/vim/indent/IndentAnything_html.vim", "lib/utils/config/vim/indent/eruby.vim", "lib/utils/config/vim/indent/javascript.vim", "lib/utils/config/vim/indent/ruby.vim", "lib/utils/config/vim/plugin/AlignMapsPlugin.vim", "lib/utils/config/vim/plugin/AlignPlugin.vim", "lib/utils/config/vim/plugin/Decho.vim", "lib/utils/config/vim/plugin/IndentAnything.vim", "lib/utils/config/vim/plugin/bufexplorer.vim", "lib/utils/config/vim/plugin/cecutil.vim", "lib/utils/config/vim/plugin/fugitive.vim", "lib/utils/config/vim/plugin/lusty-explorer.vim", "lib/utils/config/vim/plugin/rails.vim", "lib/utils/config/vim/plugin/rubyextra.vim", "lib/utils/config/vim/plugin/surround.vim", "lib/utils/config/vim/plugin/taglist.vim", "lib/utils/config/vim/plugin/test/IndentAnything/test.js", "lib/utils/config/vim/plugin/vimballPlugin.vim", "lib/utils/config/vim/syntax/Decho.vim", "lib/utils/config/vim/syntax/eruby.vim", "lib/utils/config/vim/syntax/javascript.vim", "lib/utils/config/vim/syntax/ragel.vim", "lib/utils/config/vim/syntax/ruby.vim", "lib/utils/config/vimrc", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/find.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/version.rb", "utils.gemspec"]
  s.homepage = "http://github.com/flori/utils"
  s.rdoc_options = ["--title", "Utils - Some useful command line utilities", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.21"
  s.summary = "Some useful command line utilities"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.1.7"])
      s.add_runtime_dependency(%q<tins>, ["~> 0.3.12"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.0"])
      s.add_runtime_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_runtime_dependency(%q<pry-editline>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.1.7"])
      s.add_dependency(%q<tins>, ["~> 0.3.12"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.0"])
      s.add_dependency(%q<dslkit>, ["~> 0.2"])
      s.add_dependency(%q<pry-editline>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.1.7"])
    s.add_dependency(%q<tins>, ["~> 0.3.12"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.0"])
    s.add_dependency(%q<dslkit>, ["~> 0.2"])
    s.add_dependency(%q<pry-editline>, [">= 0"])
  end
end
