# -*- encoding: utf-8 -*-
# stub: utils 0.45.0 ruby lib

Gem::Specification.new do |s|
  s.name = "utils".freeze
  s.version = "0.45.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2024-07-08"
  s.description = "This ruby gem provides some useful command line utilities".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["ascii7".freeze, "blameline".freeze, "check-yaml".freeze, "classify".freeze, "create_cstags".freeze, "create_tags".freeze, "discover".freeze, "edit".freeze, "edit_wait".freeze, "enum".freeze, "fix-brew".freeze, "git-empty".freeze, "git-versions".freeze, "json_check".freeze, "long_lines".freeze, "myex".freeze, "number_files".freeze, "on_change".freeze, "path".freeze, "probe".freeze, "rd2md".freeze, "search".freeze, "sedit".freeze, "serve".freeze, "ssh-tunnel".freeze, "strip_spaces".freeze, "sync_dir".freeze, "untest".freeze, "utils-utilsrc".freeze, "vcf2alias".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze]
  s.files = [".github/dependabot.yml".freeze, ".github/workflows/codeql-analysis.yml".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "bin/ascii7".freeze, "bin/blameline".freeze, "bin/check-yaml".freeze, "bin/classify".freeze, "bin/create_cstags".freeze, "bin/create_tags".freeze, "bin/discover".freeze, "bin/edit".freeze, "bin/edit_wait".freeze, "bin/enum".freeze, "bin/fix-brew".freeze, "bin/git-empty".freeze, "bin/git-versions".freeze, "bin/json_check".freeze, "bin/long_lines".freeze, "bin/myex".freeze, "bin/number_files".freeze, "bin/on_change".freeze, "bin/path".freeze, "bin/probe".freeze, "bin/rd2md".freeze, "bin/search".freeze, "bin/sedit".freeze, "bin/serve".freeze, "bin/ssh-tunnel".freeze, "bin/strip_spaces".freeze, "bin/sync_dir".freeze, "bin/untest".freeze, "bin/utils-utilsrc".freeze, "bin/vcf2alias".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/file_xt.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze, "utils.gemspec".freeze]
  s.homepage = "http://github.com/flori/utils".freeze
  s.licenses = ["GPL-2.0".freeze]
  s.rdoc_options = ["--title".freeze, "Utils - Some useful command line utilities".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.5.14".freeze
  s.summary = "Some useful command line utilities".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.15.0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.14".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.3".freeze])
  s.add_runtime_dependency(%q<pstree>.freeze, ["~> 0.3".freeze])
  s.add_runtime_dependency(%q<infobar>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<mize>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<search_ui>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<drb>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<all_images>.freeze, [">= 0.0.2".freeze])
end
