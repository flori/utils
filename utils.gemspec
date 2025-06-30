# -*- encoding: utf-8 -*-
# stub: utils 0.63.0 ruby lib

Gem::Specification.new do |s|
  s.name = "utils".freeze
  s.version = "0.63.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "This ruby gem provides some useful command line utilities".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["ascii7".freeze, "blameline".freeze, "changes".freeze, "classify".freeze, "code_comment".freeze, "commit_message".freeze, "create_cstags".freeze, "create_tags".freeze, "discover".freeze, "edit".freeze, "edit_wait".freeze, "enum".freeze, "git-empty".freeze, "git-versions".freeze, "json_check".freeze, "long_lines".freeze, "myex".freeze, "number_files".freeze, "on_change".freeze, "path".freeze, "print_method".freeze, "probe".freeze, "rd2md".freeze, "search".freeze, "sedit".freeze, "serve".freeze, "ssh-tunnel".freeze, "strip_spaces".freeze, "sync_dir".freeze, "untest".freeze, "utils-utilsrc".freeze, "vcf2alias".freeze, "yaml_check".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze]
  s.files = [".github/dependabot.yml".freeze, ".github/workflows/codeql-analysis.yml".freeze, ".utilsrc".freeze, "COPYING".freeze, "Gemfile".freeze, "README.md".freeze, "Rakefile".freeze, "bin/ascii7".freeze, "bin/blameline".freeze, "bin/changes".freeze, "bin/classify".freeze, "bin/code_comment".freeze, "bin/commit_message".freeze, "bin/create_cstags".freeze, "bin/create_tags".freeze, "bin/discover".freeze, "bin/edit".freeze, "bin/edit_wait".freeze, "bin/enum".freeze, "bin/git-empty".freeze, "bin/git-versions".freeze, "bin/json_check".freeze, "bin/long_lines".freeze, "bin/myex".freeze, "bin/number_files".freeze, "bin/on_change".freeze, "bin/path".freeze, "bin/print_method".freeze, "bin/probe".freeze, "bin/rd2md".freeze, "bin/search".freeze, "bin/sedit".freeze, "bin/serve".freeze, "bin/ssh-tunnel".freeze, "bin/strip_spaces".freeze, "bin/sync_dir".freeze, "bin/untest".freeze, "bin/utils-utilsrc".freeze, "bin/vcf2alias".freeze, "bin/yaml_check".freeze, "lib/utils.rb".freeze, "lib/utils/config_file.rb".freeze, "lib/utils/editor.rb".freeze, "lib/utils/finder.rb".freeze, "lib/utils/grepper.rb".freeze, "lib/utils/irb.rb".freeze, "lib/utils/line_blamer.rb".freeze, "lib/utils/line_formatter.rb".freeze, "lib/utils/md5.rb".freeze, "lib/utils/patterns.rb".freeze, "lib/utils/probe_server.rb".freeze, "lib/utils/ssh_tunnel_specification.rb".freeze, "lib/utils/version.rb".freeze, "lib/utils/xt/source_location_extension.rb".freeze, "tests/test_helper.rb".freeze, "tests/utils_test.rb".freeze, "utils.gemspec".freeze]
  s.homepage = "http://github.com/flori/utils".freeze
  s.licenses = ["GPL-2.0".freeze]
  s.rdoc_options = ["--title".freeze, "Utils - Some useful command line utilities".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Some useful command line utilities".freeze
  s.test_files = ["tests/test_helper.rb".freeze, "tests/utils_test.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.20".freeze])
  s.add_development_dependency(%q<test-unit>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<unix_socks>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<webrick>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.14".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.11".freeze])
  s.add_runtime_dependency(%q<pstree>.freeze, ["~> 0.3".freeze])
  s.add_runtime_dependency(%q<infobar>.freeze, ["~> 0.8".freeze])
  s.add_runtime_dependency(%q<mize>.freeze, ["~> 0.6".freeze])
  s.add_runtime_dependency(%q<search_ui>.freeze, ["~> 0.0".freeze])
  s.add_runtime_dependency(%q<all_images>.freeze, ["~> 0.5.0".freeze])
  s.add_runtime_dependency(%q<ollama-ruby>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<kramdown-ansi>.freeze, ["~> 0.0.1".freeze])
  s.add_runtime_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<debug>.freeze, [">= 0".freeze])
end
