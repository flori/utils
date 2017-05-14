# -*- encoding: utf-8 -*-
# stub: utils 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "utils".freeze
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2017-05-14"
  s.description = "This ruby gem provides some useful command line utilities".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["ascii7".freeze, "blameline".freeze, "brakeman2err".freeze, "chroot-exec".freeze, "chroot-libs".freeze, "classify".freeze, "create_tags".freeze, "dialog-pick".freeze, "discover".freeze, "edit".freeze, "edit_wait".freeze, "enum".freeze, "errf".freeze, "git-empty".freeze, "git-versions".freeze, "irb_connect".freeze, "json_check".freeze, "long_lines".freeze, "myex".freeze, "number_files".freeze, "on_change".freeze, "path".freeze, "probe".freeze, "remote_copy".freeze, "rssr".freeze, "same_files".freeze, "search".freeze, "sedit".freeze, "serve".freeze, "ssh-tunnel".freeze, "strip_spaces".freeze, "unquarantine_apps".freeze, "untest".freeze, "utils-utilsrc".freeze, "vacuum_firefox_sqlite".freeze, "xmp".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/irb/service.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze]
  s.files = [".gitignore".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/ascii7".freeze, "bin/blameline".freeze, "bin/brakeman2err".freeze, "bin/chroot-exec".freeze, "bin/chroot-libs".freeze, "bin/classify".freeze, "bin/create_tags".freeze, "bin/dialog-pick".freeze, "bin/discover".freeze, "bin/edit".freeze, "bin/edit_wait".freeze, "bin/enum".freeze, "bin/errf".freeze, "bin/git-empty".freeze, "bin/git-versions".freeze, "bin/irb_connect".freeze, "bin/json_check".freeze, "bin/long_lines".freeze, "bin/myex".freeze, "bin/number_files".freeze, "bin/on_change".freeze, "bin/path".freeze, "bin/probe".freeze, "bin/remote_copy".freeze, "bin/rssr".freeze, "bin/same_files".freeze, "bin/search".freeze, "bin/sedit".freeze, "bin/serve".freeze, "bin/ssh-tunnel".freeze, "bin/strip_spaces".freeze, "bin/unquarantine_apps".freeze, "bin/untest".freeze, "bin/utils-utilsrc".freeze, "bin/vacuum_firefox_sqlite".freeze, "bin/xmp".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/irb/service.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze, "utils.gemspec".freeze]
  s.homepage = "http://github.com/flori/utils".freeze
  s.rdoc_options = ["--title".freeze, "Utils - Some useful command line utilities".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Some useful command line utilities".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.8"])
      s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
      s.add_runtime_dependency(%q<pstree>.freeze, ["~> 0.1"])
      s.add_runtime_dependency(%q<pry-editline>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<infobar>.freeze, [">= 0"])
    else
      s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
      s.add_dependency(%q<tins>.freeze, ["~> 1.8"])
      s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
      s.add_dependency(%q<pstree>.freeze, ["~> 0.1"])
      s.add_dependency(%q<pry-editline>.freeze, [">= 0"])
      s.add_dependency(%q<infobar>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.8"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_dependency(%q<pstree>.freeze, ["~> 0.1"])
    s.add_dependency(%q<pry-editline>.freeze, [">= 0"])
    s.add_dependency(%q<infobar>.freeze, [">= 0"])
  end
end
