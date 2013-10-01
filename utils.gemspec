# -*- encoding: utf-8 -*-
# stub: utils 0.0.96 ruby lib

Gem::Specification.new do |s|
  s.name = "utils"
  s.version = "0.0.96"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = "2013-10-01"
  s.description = "This ruby gem provides some useful command line utilities"
  s.email = "flori@ping.de"
  s.executables = ["brakeman2err", "chroot-exec", "chroot-libs", "classify", "create_tags", "discover", "edit", "edit_wait", "enum", "errf", "git-empty", "irb_connect", "myex", "number_files", "on_change", "path", "probe", "remote_copy", "same_files", "search", "sedit", "ssh-tunnel", "strip_spaces", "unquarantine_apps", "untest", "utils-install-config", "utils-utilsrc", "vacuum_firefox_sqlite", "xmp"]
  s.extra_rdoc_files = ["README.rdoc", "lib/utils.rb", "lib/utils/config.rb", "lib/utils/config/config_file.rb", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/probe_server.rb", "lib/utils/version.rb"]
  s.files = [".gitignore", "COPYING", "Gemfile", "README.rdoc", "Rakefile", "TODO", "VERSION", "bin/brakeman2err", "bin/chroot-exec", "bin/chroot-libs", "bin/classify", "bin/create_tags", "bin/discover", "bin/edit", "bin/edit_wait", "bin/enum", "bin/errf", "bin/git-empty", "bin/irb_connect", "bin/myex", "bin/number_files", "bin/on_change", "bin/path", "bin/probe", "bin/remote_copy", "bin/same_files", "bin/search", "bin/sedit", "bin/ssh-tunnel", "bin/strip_spaces", "bin/unquarantine_apps", "bin/untest", "bin/utils-install-config", "bin/utils-utilsrc", "bin/vacuum_firefox_sqlite", "bin/xmp", "lib/utils.rb", "lib/utils/config.rb", "lib/utils/config/config_file.rb", "lib/utils/config/gdb/asm", "lib/utils/config/gdb/ruby", "lib/utils/config/gdbinit", "lib/utils/config/irbrc", "lib/utils/config/rdebugrc", "lib/utils/config/rvmrc", "lib/utils/config/screenrc", "lib/utils/config/utilsrc", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/probe_server.rb", "lib/utils/version.rb", "utils.gemspec"]
  s.homepage = "http://github.com/flori/utils"
  s.rdoc_options = ["--title", "Utils - Some useful command line utilities", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.5"
  s.summary = "Some useful command line utilities"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_runtime_dependency(%q<tins>, [">= 0.8.3", "~> 0.8"])
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.2.2", "~> 1.2"])
      s.add_runtime_dependency(%q<dslkit>, ["~> 0.2.10"])
      s.add_runtime_dependency(%q<pstree>, [">= 0"])
      s.add_runtime_dependency(%q<pry-editline>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_dependency(%q<tins>, [">= 0.8.3", "~> 0.8"])
      s.add_dependency(%q<term-ansicolor>, [">= 1.2.2", "~> 1.2"])
      s.add_dependency(%q<dslkit>, ["~> 0.2.10"])
      s.add_dependency(%q<pstree>, [">= 0"])
      s.add_dependency(%q<pry-editline>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
    s.add_dependency(%q<tins>, [">= 0.8.3", "~> 0.8"])
    s.add_dependency(%q<term-ansicolor>, [">= 1.2.2", "~> 1.2"])
    s.add_dependency(%q<dslkit>, ["~> 0.2.10"])
    s.add_dependency(%q<pstree>, [">= 0"])
    s.add_dependency(%q<pry-editline>, [">= 0"])
  end
end
