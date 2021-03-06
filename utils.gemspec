# -*- encoding: utf-8 -*-
# stub: utils 0.23.3 ruby lib

Gem::Specification.new do |s|
  s.name = "utils".freeze
  s.version = "0.23.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2020-10-03"
  s.description = "This ruby gem provides some useful command line utilities".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["discover".freeze, "classify".freeze, "sedit".freeze, "irb_connect".freeze, "ascii7".freeze, "path".freeze, "enum".freeze, "ssh-tunnel".freeze, "search".freeze, "edit".freeze, "json_check".freeze, "edit_wait".freeze, "untest".freeze, "blameline".freeze, "git-empty".freeze, "create_cstags".freeze, "git-versions".freeze, "strip_spaces".freeze, "fix-brew".freeze, "number_files".freeze, "serve".freeze, "vcf2alias".freeze, "on_change".freeze, "utils-utilsrc".freeze, "myex".freeze, "long_lines".freeze, "probe".freeze, "create_tags".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/irb/service.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze]
  s.files = [".gitignore".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "bin/ascii7".freeze, "bin/blameline".freeze, "bin/classify".freeze, "bin/create_cstags".freeze, "bin/create_tags".freeze, "bin/discover".freeze, "bin/edit".freeze, "bin/edit_wait".freeze, "bin/enum".freeze, "bin/fix-brew".freeze, "bin/git-empty".freeze, "bin/git-versions".freeze, "bin/irb_connect".freeze, "bin/json_check".freeze, "bin/long_lines".freeze, "bin/myex".freeze, "bin/number_files".freeze, "bin/on_change".freeze, "bin/path".freeze, "bin/probe".freeze, "bin/search".freeze, "bin/sedit".freeze, "bin/serve".freeze, "bin/ssh-tunnel".freeze, "bin/strip_spaces".freeze, "bin/untest".freeze, "bin/utils-utilsrc".freeze, "bin/vcf2alias".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/irb/service.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze, "utils.gemspec".freeze]
  s.homepage = "http://github.com/flori/utils".freeze
  s.rdoc_options = ["--title".freeze, "Utils - Some useful command line utilities".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Some useful command line utilities".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.14"])
    s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_runtime_dependency(%q<pstree>.freeze, ["~> 0.3"])
    s.add_runtime_dependency(%q<infobar>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<mize>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<search_ui>.freeze, [">= 0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.11.0"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.14"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.3"])
    s.add_dependency(%q<pstree>.freeze, ["~> 0.3"])
    s.add_dependency(%q<infobar>.freeze, [">= 0"])
    s.add_dependency(%q<mize>.freeze, [">= 0"])
    s.add_dependency(%q<search_ui>.freeze, [">= 0"])
  end
end
