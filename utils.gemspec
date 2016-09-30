# -*- encoding: utf-8 -*-
# stub: utils 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "utils"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Florian Frank"]
  s.date = "2016-09-30"
  s.description = "This ruby gem provides some useful command line utilities"
  s.email = "flori@ping.de"
  s.executables = ["blameline", "brakeman2err", "chroot-exec", "chroot-libs", "classify", "create_tags", "dialog-pick", "discover", "edit", "edit_wait", "enum", "errf", "git-empty", "irb_connect", "json_check", "long_lines", "myex", "number_files", "on_change", "path", "probe", "remote_copy", "rssr", "same_files", "search", "sedit", "serve", "ssh-tunnel", "strip_spaces", "unquarantine_apps", "untest", "utils-utilsrc", "vacuum_firefox_sqlite", "xmp"]
  s.extra_rdoc_files = ["README.md", "lib/utils.rb", "lib/utils/config_file.rb", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/irb/service.rb", "lib/utils/line_blamer.rb", "lib/utils/line_formatter.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/probe_server.rb", "lib/utils/ssh_tunnel_specification.rb", "lib/utils/version.rb", "lib/utils/xt/source_location_extension.rb"]
  s.files = [".gitignore", "COPYING", "Gemfile", "README.md", "Rakefile", "VERSION", "bin/blameline", "bin/brakeman2err", "bin/chroot-exec", "bin/chroot-libs", "bin/classify", "bin/create_tags", "bin/dialog-pick", "bin/discover", "bin/edit", "bin/edit_wait", "bin/enum", "bin/errf", "bin/git-empty", "bin/irb_connect", "bin/json_check", "bin/long_lines", "bin/myex", "bin/number_files", "bin/on_change", "bin/path", "bin/probe", "bin/remote_copy", "bin/rssr", "bin/same_files", "bin/search", "bin/sedit", "bin/serve", "bin/ssh-tunnel", "bin/strip_spaces", "bin/unquarantine_apps", "bin/untest", "bin/utils-utilsrc", "bin/vacuum_firefox_sqlite", "bin/xmp", "lib/utils.rb", "lib/utils/config_file.rb", "lib/utils/editor.rb", "lib/utils/file_xt.rb", "lib/utils/finder.rb", "lib/utils/grepper.rb", "lib/utils/irb.rb", "lib/utils/irb/service.rb", "lib/utils/line_blamer.rb", "lib/utils/line_formatter.rb", "lib/utils/md5.rb", "lib/utils/patterns.rb", "lib/utils/probe_server.rb", "lib/utils/ssh_tunnel_specification.rb", "lib/utils/version.rb", "lib/utils/xt/source_location_extension.rb", "utils.gemspec", "utils.gemspec "]
  s.homepage = "http://github.com/flori/utils"
  s.rdoc_options = ["--title", "Utils - Some useful command line utilities", "--main", "README.md"]
  s.rubygems_version = "2.5.1"
  s.summary = "Some useful command line utilities"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 1.8.0"])
      s.add_runtime_dependency(%q<tins>, ["~> 1.8"])
      s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.3"])
      s.add_runtime_dependency(%q<pstree>, ["~> 0.1"])
      s.add_runtime_dependency(%q<pry-editline>, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 1.8.0"])
      s.add_dependency(%q<tins>, ["~> 1.8"])
      s.add_dependency(%q<term-ansicolor>, ["~> 1.3"])
      s.add_dependency(%q<pstree>, ["~> 0.1"])
      s.add_dependency(%q<pry-editline>, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 1.8.0"])
    s.add_dependency(%q<tins>, ["~> 1.8"])
    s.add_dependency(%q<term-ansicolor>, ["~> 1.3"])
    s.add_dependency(%q<pstree>, ["~> 0.1"])
    s.add_dependency(%q<pry-editline>, [">= 0"])
  end
end
