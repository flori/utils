# Changes

## 2026-11-24 v0.104.0

### Features
- Add `CHANGES.md` documenting the complete project history from **v0.0.0** to
  **v0.103.1**.

### Improvements
- Clear the infobar progress display after `full` and `add` loops in
  `bin/changes` to prevent the progress bar from lingering on the terminal.

### Build & CI
- Add `CHANGES.md` to the gem's file list in `utils.gemspec`.
- Add `changelog` configuration to `Rakefile` to recognize `CHANGES.md`.

## 2026-11-23 v0.103.1

### Improvements
- Route infobar output to `STDERR` in `bin/changes` to prevent
  progress indicators from interfering with piped output.

## 2026-11-23 v0.103.0

### Features
- Add infobar progress display to `full` and `add` commands in `bin/changes`.
- Add `-m` flag to `bin/changes` to override context length for LLM prompts.
- Implement context-length-aware log truncation to handle large diffs.

### Fixes
- Handle binary bytes in `git log -p` output to prevent encoding errors.
- Ensure version tags carry a `v` prefix in generated changelog headers.

### Build & CI
- Bump `gem_hadar` development dependency to **2.27.1**.

## 2026-11-21 v0.102.0

### Features

- Added a `-p` flag to the `changes` script to include full diff
  hunks in the LLM prompt.
- Hoisted option parsing to a shared `opts` variable so all
  subcommands can access the `-p` flag.
- Forwarded the `patch:` keyword argument to all `compute_change`
  call sites.

### Improvements

- Removed a redundant `$?.success?` check in `compute_change` that
  was dead code after the `x` helper execution.

### Build & CI

- Updated `rubygems_version` to **4.1.0** in `utils.gemspec`.
- Updated the `gem_hadar` development dependency requirement to
  `>= 2.26.1`.

## 2026-11-19 v0.101.0

### Build & CI
- Updated `context_spook` to `~> 1.8`, `unix_socks` to `~> 0.5`, and
  `kramdown-ansi` to `>= 0.10` to support `json` version `>= 2.0`,
  `< 4`.
- Raised the minimum required version for `gem_hadar` to `>= 2.24.1`.
- Removed obsolete Vim modelines from `Gemfile` and `Rakefile`.

## 2026-10-23 v0.100.0

### Improvements
- Replaced manual URL construction in `bin/changes` and `bin/code_comment`
  with the `Ollama.base_url()` helper to consolidate URL normalization.

### Build & CI
- Updated the `ollama-ruby` runtime dependency requirement to `~> 1.26`.
- Updated the `gem_hadar` development dependency requirement to
  `>= 2.21.0`.

## 2026-10-01 v0.99.0

### Improvements
- Add `--sort=no` flag to the `ctags` command in `bin/code_indexer` to disable sorting.

### Documentation
- Correct the example character name from `rightarrow` to `rightwarrow` in
  the `bin/charpick` usage comments and search hint.
- Remove the redundant `@return` documentation line from the `download`
  method in `bin/charpick`.

## 2026-09-16 v0.98.0

### Improvements
- Replace `client.json` and `options.json` files with `OLLAMA_CLIENT`
  and `OLLAMA_MODEL_OPTIONS` environment variables in `changes`,
  `code_comment`, and `commit_message`.
- Remove `-c` and `-M` flags from the `ollama_cli` invocation in
  `commit_message` to rely on native environment variable support.
- Update `charpick` to pass `?-` as the second argument to
  `matcher.similar` to improve matching accuracy.
- Change `bin/charpick` permissions to be executable.

### Build & CI
- Update `rubygems_version` in `utils.gemspec` from **4.0.17** to
  **4.0.20**.

### Documentation
- Document `charpick` and `irb_client` in the `README.md` utility
  listings.
- Add usage header comments to `bin/irb_client` explaining server
  setup and snippet execution.

## 2026-08-29 v0.97.0

### Features
- Add `bin/charpick` script for interactive fuzzy search over `UnicodeData.txt` with clipboard copy via `pbcopy`, `wl-copy`, `xclip`, or `xsel`.
- Integrate `charpick` into gemspec `executables` and `files`.

### Improvements
- Bump `search_ui` dependency to **0.2.0** in `Rakefile` and `utils.gemspec`.

### Build & CI
- Update `rubygems_version` to **4.0.17** in `utils.gemspec`.
- Bump `gem_hadar` development dependency to `>= 2.18.0` in `utils.gemspec`.

## 2026-07-03 v0.96.0

### Features
- Add `-r` flag to the `pending` command in `bin/changes` to
  specify a future version tag for the changelog header.
- Implement `future_tag` keyword argument in `compute_change` method.
- Integrate `tins/go` for flexible CLI argument parsing.

### Documentation
- Add comprehensive YARD documentation to `compute_change`.
- Update usage header and help menu in `bin/changes` to document
  the new `-r` flag.

## 2026-04-08 v0.95.1

### Improvements
- Remove unused `require 'pathname'` statements from `bin/discover`,
  `bin/sync_dir`, and `lib/utils/xdg.rb`.

### Build & CI
- Update `s.rubygems_version` in `utils.gemspec` to **4.0.10**.

## 2026-03-09 v0.95.0

### Features
- `on_change` now supports monitoring multiple files using `-i`
  glob patterns, replacing the previous single-file limit.
- Added `-d` option to `on_change` to configure the sleep interval
  between checks, clamped to a minimum of one second.
- `code_indexer` accepts an optional argument to restrict indexing to
  a specific format (e.g., `ctags` or `cscope`).
- `code_indexer` uses native `ctags` for the `ctags` format instead of
  relying solely on `starscope`.

### Improvements
- Replaced `create_cstags` and `create_tags` utilities with a
  unified `code_indexer` command in the documentation and
  implementation.
- `on_change` now uses `Shellwords` to safely join command arguments
  before execution.
- Enhanced error handling in `on_change` to preserve file timestamps
  even when a file temporarily disappears.

### Build & CI
- Updated `rubygems_version` to **4.0.4** and adjusted `gem_hadar`
  development dependency to `~> 2.8`.

## 2026-02-06 v0.94.0

### Breaking
- Replaced the `-n` option with `-m` in `bin/discover` to limit the
  maximum number of matches returned.

### Features
- Added `-m` option to `bin/search` to limit the maximum number of files
  returned by search results.
- Implemented early termination in `Utils::Grepper` to improve performance
  when the `-m` limit is reached.

### Fixes
- Corrected a typo in the error list storage message in `Utils::LineFormatter`
  from "error list" to "errors list".

## 2026-01-29 v0.93.0

### Features
- Add `-P` flag to `bin/discover` and `bin/search` for pruning directories
  using custom regular expression patterns.
- Extend `Utils::ConfigFile::FileFinder#prune?` to accept an
  `additional_dirs` parameter for dynamic directory filtering.

### Improvements
- Add `.contexts/lib.rb` for structured library and gem file discovery.
- Update `line_formatter.rb` to use bright ANSI colors for improved
  terminal output readability.

## 2026-01-26 v0.92.0

### Breaking
- Renamed `Utils::IRB::Shell#ai` to `ocs` to avoid collision
  with the `ai` method from the `awesome_print` gem.

### Features
- The RSpec formatter now automatically adapts description length
  to the terminal width.
- If the full description exceeds the terminal width, the
  formatter now truncates it to the abbreviated description.
- The `Utils::LineFormatter#description` method now defaults to
  the full description instead of relying on the `VERBOSE`
  environment variable.

## 2026-01-20 v0.91.1

### Features
- Add a new `-g` flag to the usage help text in `bin/discover`,
  enabling file discovery via `git ls-files` instead of the cache.

### Improvements
- Bump the `all_images` dependency requirement from `~> 0.5.0` to
  `>= 0.12`.
- Bump the `kramdown-ansi` dependency requirement from `~> 0.1` to
  `>= 0.4`.

### Build & CI
- Remove duplicate runtime dependency entries for `unix_socks` and
  `ollama-ruby` in the `Rakefile` and `utils.gemspec`.

## 2026-01-20 v0.91.0

### Features
- Added `irb_current_snippet` method to retrieve the current code
  snippet from the IRB server.
- Added emoji indicators for test status in formatted line output.

### Fixes
- Improved error handling in the IRB server to explicitly catch
  `SyntaxError` alongside `StandardError`.

### Improvements
- Modularized `Utils::IRB` by splitting the `Shell`, `Regexp`, and
  `String` modules into dedicated files.
- Moved IRB wrapper classes to a new `wrappers` file for better
  organization.
- Enhanced input validation in `irb_time_watch` to safely convert values
  to floats.
- Reordered columns in the line formatter output to display status emojis
  before location information.
- Extended the source location extension to prepend to all modules
  defining `source_location` and refactor internal decoration logic.
- Moved `logger` and `tempfile` requires to the top of their respective
  files.

## 2026-01-16 v0.90.0

### Improvements

- Refactored `bin/probe` to construct the argument list for
  `probe_client.enqueue` by concatenating `$opts`, `$args`, and
  `$testrunner_args` only when the latter is non-empty.
- Replaced the local `testrunner_args` variable with the global
  `$testrunner_args`, initialized with `[]`.
- Froze `$args`, `$testrunner_args`, and `$opts` after parsing to
  prevent accidental mutation.

## 2026-01-15 v0.89.1

### Build & CI
- Updated the minimum `gem_hadar` development dependency version
  from **2.16.3** to **2.17.0**.

## 2026-01-15 v0.89.0

- No user-visible changes.

## 2026-01-15 v0.88.0

### Features
- Added `-g` flag to `bin/discover` to search only git-tracked files
  using `git ls-files` output.
- Introduced `Utils::Finder::Files` module to handle file system traversal
  and path caching logic.
- Updated `Utils::Finder` to accept a `:files` option, allowing it to
  operate on a specific list of files instead of root directories.

### Improvements
- Refactored `Utils::Finder` to replace `search_index` and
  `search_directly` with a unified `search` method.
- Consolidated path building logic into `Utils::Finder::Files` to simplify
  the main finder class interface.

### Documentation
- Added comprehensive RDoc documentation and usage examples for
  `Utils::Finder` and `Utils::Finder::Files`.

## 2026-01-12 v0.87.0

### Fixes
- Fixed `Utils::Grepper` to follow symlinks when the `-F` flag is
  provided, and skip them otherwise.
- Resolved an LSP violation in `Utils::XDG::XDGPathname` by overriding
  `join`, `+`, `dirname`, `basename`, `realpath`, `expand_path`,
  `cleanpath`, and `relative_path_from` to ensure type consistency.
- Fixed an infinite recursion issue in `XDGPathname` by replacing the
  `File.join` workaround with `super` delegation in `join` and `+`.
- Corrected a typo in the `-L` option help text in `bin/discover`.

## 2026-01-09 v0.86.0

### Breaking
- Removed the `Utils::ConfigDir` class and replaced it with the
  `Utils::XDG::XDGPathname` subclass for directory management.
- Updated the `Utils::Finder#index_path` method to return a `Pathname`
  object instead of a `String`.

### Features
- Introduced the `Utils::XDG` module with constants for standard
  XDG base directories.
- Added the `Utils::XDG::XDGPathname` class to extend `Pathname` with
  `sub_dir_path` and `read` methods.
- Moved the `Utils::ConfigFile::BlockConfig` class to a separate file
  `lib/utils/config_file/block_config.rb`.

### Improvements
- Refactored command-line utilities to use the `XDG_CONFIG_HOME`
  constant for configuration paths.
- Updated `Utils::Finder` and `Utils::IRB::IRBServer` to store cache
  and state files in XDG-compliant locations.
- Simplified method call syntax in `Utils::Finder` by using shorthand
  hash arguments.

### Documentation
- Added YARD documentation to the `Utils::XDG` module, including
  details for `AppDir` methods and directory constants.

## 2026-01-06 v0.85.0

### Breaking
- Replaced the `server_type` and `tcp_server_port` configuration options
  with a single `server_url` DSL accessor in `Utils::ConfigFile`.
- Removed the default TCP port **59999**, now defaulting to a Unix socket
  in the current directory.

### Features
- Added support for `tcp://` and `unix://` URL schemes in probe
  communication via `UnixSocks.from_url`.
- Introduced a new `-s SERVER_URL` command-line option in `bin/probe` to
  specify the probe server connection.

## 2026-01-04 v0.84.0

### Features

- Enhanced `irb_load!` with interactive file selection, fuzzy
  matching, and configurable glob patterns.

### Fixes

- `irb_load!` now explicitly returns `false` when no file is
  selected, improving error handling consistency.

### Improvements

- Replaced `Tins::Find` with `Dir.glob` for efficient file
  discovery in `irb_load!`.

- Updated duplicate prevention from MD5 checksums to path-based
  tracking.

### Build & CI

- Added `amatch` (~> **0.6**) and updated `search_ui` (>=
  **0.0.9**) as runtime dependencies.

### Documentation

- Updated `irb_load!` YARD documentation with comprehensive
  examples, parameter descriptions, and notes.

## 2026-01-02 v0.83.1

### Fixes
- Fixed `type` error in `[]=` and `[]` by using explicit hash literals
  for `transmit_with_response` in `probe_client`.

## 2026-01-01 v0.83.0

### Features
- Implement the `Utils::IRB::IRBServer` class to manage
  interactive Ruby sessions via Unix domain sockets.
- Add the `irb_client` executable for storing, retrieving,
  executing, and evaluating code snippets via a remote IRB
  server.
- Introduce `retrieve_current_snippet` and `execute_current_
  snippet` actions to manage and run previously stored
  snippets.
- Add `eval_lines` support to evaluate multiple code lines in
  sequence with a configurable result prefix.
- Add `dsl_accessor :irb_server_url` to `Utils::ConfigFile`
  to configure the IRB server endpoint.
- Add `irb_server`, `irb_server_stop`, and `irb_client`
  methods to the `Utils::IRB` module for server lifecycle
  management.
- Update file exclusion patterns to skip `cscope.out` and
  `tags` files during search and discovery.

### Build & CI
- Add `irb_client` and `lib/utils/irb/irb_server.rb` to the
  gemspec file lists.

### Improvements
- Add YARD documentation for the new `Utils::IRB::IRBServer`
  class and related methods.

### Documentation
- Update `irb_client` usage documentation with comprehensive
  examples for the stored snippet workflow.

## 2025-12-24 v0.82.0

### Breaking
- Moved `ProbeServer`, `ProbeClient`, `ProcessJob`, and
  `ServerHandling` from the `Utils` module to the new
  `Utils::Probe` module.

### Features
- Added the `ai` method to the `Utils` module to interact
  with the Ollama chat service for query processing and
  response handling.

### Improvements
- Updated the `code_comment` script to use consistent
  indentation.

## 2025-12-24 v0.81.0

### Features

- Enable TCP server support for the probe via `server_type` and `tcp_server_port` configuration options.
- Centralize socket creation in a new `ServerHandling` module to support both UNIX domain and TCP sockets.
- Update the probe server status message to display the URL via `to_url` instead of the socket path.

### Fixes

- Remove a duplicate `initialize` method definition from the `ConfigDir` class.
- Correct a typo in the `.utilsrc` configuration referencing the `gem_hadar` package.

### Improvements

- Update the `unix_socks` runtime dependency from **0.2** to **0.3**.
- Update the `gem_hadar` development dependency to **2.16.2**.

## 2025-12-20 v0.80.0

- No user-visible changes.

## 2025-12-20 v0.79.0

### Fixes
- In `sync_dir`, automatically skip to the next file after `vimdiff` if
  the files are now identical, preventing redundant prompts.

### Improvements
- In `Utils::Editor#sanitize_name`, removed unused `rbconfig` dependency
  and Windows-specific naming logic.

### Build & CI
- Updated `tins` runtime dependency from `~> 1.44` to `~> 1.51`.
- Added `webrick` to runtime dependencies.
- Fixed malformed `unix_socks` dependency specification in gemspec.
- Updated `gem_hadar` development dependency to `~> 2.10`.

### Documentation
- Updated help text for the `-r` option in `discover` to clarify
  "reset the search index by force".

## 2025-11-19 v0.78.4

### Improvements
- Updated `derive_server_name` in `lib/utils/editor.rb` to use
  `Digest::MD5` for generating unique server names, replacing the
  previous character substitution logic to handle long paths.

## 2025-11-15 v0.78.3

### Fixes
- Updated `vim_default_args` to default to `%w[ --clientserver
  socket ]` instead of `nil`.
- Modified `derive_server_name` to replace `/` with `_` before
  uppercasing the Vim server name.

### Build & CI
- Updated `s.rubygems_version` from **3.6.9** to **3.7.2**.
- Updated `gem_hadar` development dependency from ~> 2.6 to ~> 2.8.

## 2025-09-15 v0.78.2

### Fixes
- Resolved a potential name conflict in `probe_server.rb` by updating
  the `examine` call to explicitly reference `IRB.examine`.

### Build & CI
- Removed `.github` and `.utilsrc` from the package files list in
  `utils.gemspec` and updated `Rakefile` to ignore them during
  packaging.

## 2025-09-13 v0.78.1

### Improvements
- Updated the `find` method call in the `strip_spaces` script to
  pass the `suffix` parameter as a keyword argument.

## 2025-09-12 v0.78.0

### Build & CI
- Updated the `tins` dependency constraint from `~> 1.43` to `~>
  1.44` in the `Rakefile` and `utils.gemspec`.

## 2025-09-12 v0.77.0

### Improvements
- Refactored `irb.rb` to rename the `@method` instance variable
  to `@wrapped_method` and updated the corresponding `attr_reader`
  from `:method` to `:wrapped_method` to avoid conflicts.
- Updated the `code_indexer` configuration in `.utilsrc` to include
  resolved paths for bundled gems alongside the `lib` directory using
  `bundle show`.
- Improved the `long_lines` script to use a default maximum line
  length of **80**, display the default in help output, and provide
  a fallback author value with stripped whitespace when regex
  extraction fails.

### Build & CI
- Bumped the `gem_hadar` development dependency requirement from
  `~> 2.2` to `~> 2.5`.

## 2025-09-05 v0.76.0

### Features
- Added `lazy_config` method to `Utils::ConfigFile` to support lazy-loaded
  configuration options.
- Added `config_file_paths` accessor with documentation to
  `Utils::ConfigFile`.

### Improvements
- Updated `tins` runtime dependency from **1.14** to **1.43**.
- Changed `CodeIndexer` `paths` configuration to use `lazy_config` with a
  default value.
- Updated `.utilsrc` to specify the `lib` directory for code indexing.

## 2025-09-04 v0.75.0

### Features
- Added `code_indexer` executable and `Utils::ConfigFile::CodeIndexer`
  class to generate ctags and cscope indexes using `starscope`.
- Added `-b` option to `serve` command to specify a custom bind address,
  defaulting to `127.0.0.1`.

### Breaking
- Removed `create_cstags` and `create_tags` executables, which have been
  replaced by `code_indexer`.
- Replaced `Utils::ConfigFile::Scope` with
  `Utils::ConfigFile::CodeIndexer`.

### Improvements
- Updated prompt formatting for `code_comment` to enforce consistent
  capitalization and prevent blank lines between logical comment sections.

### Build & CI
- Added `starscope` as a runtime dependency in `utils.gemspec` and
  `Rakefile`.
- Updated `gem_hadar` development dependency from **2.1** to **2.2**.
- Added `.starscope.db` and `cscope.out` to `.gitignore`.
- Added `doc` directory to prune patterns in `.utilsrc` search and
  discover configurations.

## 2025-08-26 v0.74.0

### Improvements
- Updated the `code_comment` prompt to explicitly require single hash
  comments and prevent the inclusion of executable Ruby code.
- Replaced hardcoded file discovery directories with configurable
  `code_globs` from the `Utils::ConfigFile::CodeComment` configuration.
- Refactored `bin/code_comment` to separate configuration handling into
  `$config` for file settings and `$config_dir` for prompt and option
  storage.

### Fixes
- Added `require 'yaml'` to `bin/yaml_check` to resolve loading issues.
- Fixed a typo in the `ProbeServer` shutdown message changing "shutdown
  down" to "shutdown".
- Corrected the `test/` directory reference to `tests/` in code comments.
- Fixed a glob pattern typo in `Utils::ConfigFile::CodeComment` changing
  `tests/**/*rb` to `tests/**/*.rb`.

### Build & CI
- Added `.yardoc` and `doc` directories to `.gitignore` and excluded them
  from gem packaging in the `Rakefile`.
- Updated the `gem_hadar` development dependency from **2.0** to **2.1**.

### Documentation
- Added comprehensive class and method documentation across multiple
  `Utils` modules including `ConfigDir`, `Finder`, `Grepper`, `IRB`,
  `MD5`, `Patterns`, `ProbeServer`, `ProbeClient`, `ProcessJob`,
  `SshTunnelSpecification`, `SourceLocationExtension`, `LineBlamer`,
  `Editor`, and `ConfigFile`.

## 2025-08-18 v0.73.1

### Features
- Added support for `ollama-ruby` version **1.6** by updating the
  dependency specification.

## 2025-08-18 v0.73.0

### Features
- Added a **-S** flag to `bin/classify` to strip `_spec` and
  `Spec` suffixes from input strings in both normal and declassify
  modes.
- Modified `camelize` in `bin/classify` to strip the `Spec` suffix
  from camel-case inputs when the **-S** flag is used.
- Modified `underscore` in `bin/classify` to strip the `_spec`
  suffix from file path inputs when the **-S** flag is used.
- Updated usage examples in `bin/classify` to demonstrate the new
  **-S** flag behavior.
- Added a call to `chomp` on the input string in `bin/classify` to
  handle trailing newlines before processing.

## 2025-08-17 v0.72.1

### Build & CI
- Updated the `kramdown-ansi` dependency constraint from `~> 0.0.1`
  to `~> 0.1` in the `Rakefile` and `utils.gemspec`.

## 2025-08-14 v0.72.0

### Features
- Added support for a custom context file path via the
  `CODE_COMMENT_CONTEXT_FILENAME` environment variable.
- Added diagnostic output to `STDERR` indicating which context
  file is being used.

### Improvements
- Moved the default context generation logic to a dedicated
  `default_context` variable to improve code structure.
- Changed the default context file location from
  `contexts/code_comment.rb` to `.contexts/code_comment.rb`.

## 2025-08-13 v0.71.0

### Features
- Integrated the `context_spook` gem (version **0.2**) as a runtime dependency
  to enhance project context generation.
- Updated the `code_comment` binary to utilize `ContextSpook` for building
  prompts, replacing raw file contents with structured context.
- Implemented automatic discovery of Ruby files in `lib`, `spec`, and `test`
  directories when no explicit context file is present.

### Improvements
- Refactored `build_prompt`, `build_method_prompt`, and
  `build_class_module_prompt` to accept a `context` parameter instead of
  `file_contents` for more accurate documentation generation.

## 2025-08-13 v0.70.0

### Breaking
- Renamed the internal method `fetch_method` to `fetch_construct`,
  which now returns a tuple containing the source code and the
  construct type instead of just the source code string.

### Features
- Added support for documenting class and module definitions,
  including dynamic class and module creation patterns like `Foo =
  Class.new`.
- Added new `build_class_module_prompt` and `build_method_prompt`
  functions to generate tailored prompts for different code construct
  types.
- Implemented a central `build_prompt` dispatcher that selects the
  appropriate prompt builder based on the detected construct type.
- Enabled loading of custom prompt templates from `method-prompt.txt`
  and `class-module-prompt.txt` configuration files with built-in
  default fallbacks.

### Improvements
- Refactored the documentation system prompt to provide specific
  guidelines for documenting both methods and classes/modules,
  improving the quality of generated YARD comments.
- Renamed local variables `method` and `method_indent` to
  `construct` and `construct_indent` to accurately reflect the
  expanded scope of supported code constructs.
- Converted the configuration object to a global `$config` variable
  to simplify access across the updated prompt building functions.

## 2025-08-10 v0.69.0

### Improvements
- Removed the obsolete `number_files` script.
- Added interactive confirmation to `git-empty` before resetting the repository.
- Added a dependency check for `figlet` in the `rainbow` script to provide
  clearer error messages.
- Refactored `probe_server.rb` to use explicit `Term::ANSIColor` inclusion
  instead of extending `String`.
- Consolidated `tins/xt` requires into `lib/utils.rb` and removed redundant
  imports from binary scripts.
- Replaced `Tins::DeepConstGet` with `Object.const_get` in
  `source_location_extension.rb` to remove the Tins dependency.
- Added `config` as a recognized method pattern in the `code_comment` regex.
- Implemented `ConfigDir` class to replace the deprecated `XDGConfig` module
  for standardized configuration path handling in `changes`, `code_comment`,
  and `commit_message`.
- Improved method detection regex in `print_method` and `code_comment` to
  handle complex DSL patterns.
- Added support for negative number arguments in the `enum` command.
- Refactored `enum` command execution to support limited processing via
  `$limited.process` block.
- Renamed `COPYING` file to `LICENSE` to standardize license file naming.
- Updated `utils.gemspec` to include the new `LICENSE` file and
  `lib/utils/config_dir.rb` in the file list.
- Added detailed usage documentation and method comments to numerous
  utilities including `search`, `discover`, `myex`, `commit_message`,
  `sync_dir`, `untest`, `on_change`, `create_cstags`, `strip_spaces`,
  `ssh-tunnel`, `edit`, `code_comment`, `edit_wait`, `changes`, `blameline`,
  `json_check`, `yaml_check`, `git-versions`, `enum`, `path`, `serve`,
  `utils-utilsrc`, `rd2md`, `vcf2alias`, `probe`, `sedit`, `long_lines`,
  `create_tags`, and `rainbow`.
- Added comprehensive RDoc documentation to `lib/utils/irb.rb`,
  `lib/utils/line_formatter.rb`, `lib/utils/probe_server.rb`,
  `lib/utils/editor.rb`, `lib/utils/config_file.rb`, `lib/utils/grepper.rb`,
  `lib/utils/finder.rb`, `lib/utils/patterns.rb`, `lib/utils/md5.rb`,
  `lib/utils/ssh_tunnel_specification.rb`, and
  `lib/utils/source_location_extension.rb`.
- Updated `utils-utilsrc` to support custom config file paths and use `diff`
  with color output instead of `cdiff`.
- Modified `bin/edit` to chomp input lines from stdin.
- Fixed `classify` script to properly handle camelCase input through
  `path_shifter` in the default case.
- Refactored `irb_time` in `lib/utils/irb.rb` to use `ensure` for reliable
  timing calculation.
- Removed duplicate `buffer_size` method definition in `lib/utils/md5.rb`.
- Updated `README.md` with comprehensive description, installation
  instructions, categorized utilities list, and configuration documentation.

### Fixes
- Enhanced error handling in `json_check` to output detailed error messages to
  stderr.
- Corrected default behavior in `classify` to properly apply `-n` parameter
  before conversion.

## 2025-08-08 v0.68.0

### Features
- Added the `bin/rainbow` executable for generating colorful
  ASCII art using the `figlet` gem.

### Build & CI
- Added the `figlet` gem as a runtime dependency.
- Updated the `gem_hadar` development dependency to
  **1.27**.

## 2025-08-06 v0.67.0

### Features
- Added support for an `env` block in `ssh_tunnel`
  configuration, allowing environment variables to be
  passed to the SSH command.

### Fixes
- Modified `bin/code_comment` to pass `think: false` to
  `ollama.generate`, disabling the thinking process for
  response generation.

## 2025-07-21 v0.66.0

### Improvements
- Updated `bin/commit_message` to use client
  configuration from `client.json` for `ollama_cli`
  execution.

### Build & CI
- Bumped `ollama-ruby` dependency to **1.5.0**.

## 2025-07-20 v0.65.0

### Features
- Added `Utils::XDGConfig` module to provide an `xdg_config` method that resolves configuration paths based on the `XDG_CONFIG_HOME` environment variable or the user's home directory.

### Improvements
- Updated `code_comment`, `changes`, and `commit_message` utilities to load system prompts, model options, and client settings from XDG configuration files instead of hardcoded values.
- Changed the default model for `code_comment` from `llama3.2` to `llama3.1`.

### Build & CI
- Updated the `ollama-ruby` runtime dependency to **1.4.0**.
- Removed the obsolete `.utilsrc` file.

## 2025-07-01 v0.64.0

### Features
- Replaced the `drb` dependency with `unix_socks` for
  communication between the probe server and client.
- Introduced `Utils::ProbeClient` to replace direct `DRb` object
  interactions.
- Renamed `ProbeServer::Job` to `ProcessJob` and added JSON
  serialization support.
- Added a `.utilsrc` file to configure utility behavior.

### Improvements
- Switched probe server and client communication to use structured
  JSON messages instead of plain text.
- Updated the `code_comment` prompt to better describe the
  documentation task.

### Build & CI
- Added `test-unit` as a development dependency.

### Testing
- Added initial `test-unit` test suite structure in `tests/`.

## 2025-01-23 v0.63.0

### Build & CI
- Updated the `term-ansicolor` dependency requirement from
  `~> 1.3` to `~> 1.11`.

## 2025-01-10 v0.62.0

### Breaking
- Removed the `-b` option from the `search` and `discover` command line tools.
- Removed binary file detection and handling logic from `Grepper` and configuration.

## 2024-12-14 v0.61.0

### Features
- `code_comment` now generates YARD comments that include detailed
  descriptions, parameters, raised exceptions, and return values
  using an updated prompt.

### Improvements
- `code_comment` now identifies methods following `private` and
  `protected` visibility keywords when extracting method source
  code.
- `code_comment` indents the generated comment to match the
  indentation level of the target method.

## 2024-12-13 v0.60.2

### Breaking
- Removed the `Utils::FileXt` module and its file extension
  capabilities, requiring code to use `tins/xt/file_binary` instead.

### Improvements
- Updated `git-versions` to pass all command-line arguments directly
  to `git log`, removing the dedicated `-v` verbose flag.

## 2024-10-31 v0.60.1

### Build & CI
- Constrained the `kramdown-ansi` dependency to **0.0.1**.

## 2024-10-31 v0.60.0

### Breaking
- Removed the `md` and `git-md` executables.
- Removed the `utils/markdown` and `utils/pager` files and their
  associated modules from the library.

### Build & CI
- Added `kramdown-ansi` as a runtime dependency.

## 2024-10-27 v0.59.2

### Fixes
- Correct line number calculation in `long_lines` to accurately identify
  reported issues.

### Improvements
- Increase the context size (`num_ctx`) for `Ollama` requests in the `changes`
  and `code_comment` utilities.

## 2024-10-18 v0.59.1

### Improvements
- Added options to the `changes` script to exclude version
  information and skip version bump entries.

## 2024-10-17 v0.59.0

- No user-visible changes.

## 2024-10-04 v0.58.0

### Features
- Added support for displaying clickable hyperlinks to commit URLs in the
  `git-md` output, supporting `https` and `git@` remote origins.
- Highlighted commit hash lines in yellow in the `git-md` output using the
  `yellow` method from `Term::ANSIColor`.

## 2024-10-03 v0.57.1

### Improvements
- Updated the `changes` script to replace tabs with two spaces in the generated output.

## 2024-10-03 v0.57.0

### Features

- Add `Utils::Markdown` module to encapsulate markdown parsing logic.
- Add new `bin/md` executable for rendering markdown from standard input.
- Integrate `Utils::Pager` into `bin/git-md` and `bin/md` to handle output pagination.

## 2024-09-30 v0.56.1

### Fixes
- Corrected a typo in `bin/changes` by changing `tags.map(&:verion).max`
  to `tags.map(&:version).max` within `find_highest_version_tag`.

## 2024-09-30 v0.56.0

### Improvements
- Relaxed the version constraint for the `ollama-ruby` dependency
  from `~> 0.5.0` to `>= 0` in the `Rakefile` and
  `utils.gemspec`.
- Added a space around the assignment operator in
  `bin/commit_message` for improved code readability.

## 2024-09-28 v0.55.0

### Features
- Add `login_session` config option to `config_file.rb`, defaulting
  to the `$HOME` environment variable.
- Update `ssh-tunnel` script to use the new `login_session` config
  value for the `-n` option instead of hardcoded logic.

### Improvements
- Remove unused `env_user` variable assignment in `ssh-tunnel`.

## 2024-09-27 v0.54.1

### Build & CI
- Updated `ollama-ruby` dependency to **0.5.0**.
- Updated `VERSION` to **0.54.1** and synced `utils.gemspec`.

## 2024-09-26 v0.54.0

### Features
- `commit_message` now includes the current git branch name via
  the `branch` parameter when invoking `ollama_cli`.

### Fixes
- Corrected a typo in the `changes` script, changing the call to
  `verion` to `version` when mapping git tags.

### Build & CI
- Updated the `tins` runtime dependency to `~> 1.14` and the
  `gem_hadar` development dependency to `~> 1.18.0`.
- Changed the `tins` require statement to `tins/xt` in the
  `changes` executable.

### Improvements
- Simplified version string parsing in the `changes` executable
  by replacing `Tins::StringVersion::Version.new` with the
  `.version` method.

## 2024-09-23 v0.53.1

### Features
- Added a horizontal rule between log messages in the
  `git-md` output for better separation.

## 2024-09-23 v0.53.0

### Features
- Add `git-md` executable to display git log messages with
  markdown formatting.

### Build & CI
- Update dependency `ollama-ruby` to **0.4.0**.

## 2024-09-23 v0.52.1

### Fixes
- Treat `-l` and `-L` flags identically for binary
  mode and maximum matches configuration in `bin/discover` and
  `Utils::Finder`.

## 2024-09-22 v0.52.0

### Features
- Added `-l` and `-L` options to the `discover` script to list cached
  paths relative to the current directory or as absolute paths, respectively.

## 2024-09-22 v0.51.1

### Fixes

- Updated `bin/discover` to use `finder().search_index.paths` instead
  of `finder().search_index.output`.

## 2024-09-22 v0.51.0

### Features
- Added `-l` option to `discover` binary to print the
  search index output.

### Improvements
- Promoted `debug` gem from a development dependency to
  a runtime dependency.

## 2024-09-15 v0.50.0

### Features
- Added a `pending` command to display changes since the last
  released version.
- Added a `current` command to output the changes for the current
  release range.

### Fixes
- Fixed the condition in `compute_change` to correctly handle the
  `HEAD` value when passed as a string.
- Added error handling to fail gracefully if required version tags are
  missing for `pending` or `current` commands.

### Improvements
- Updated the prompt string to include guidelines for marking
  variables and version numbers in markdown.

## 2024-09-13 v0.49.1

### Breaking
- The `probe` executable now always executes commands with `bundle exec`
  and no longer checks for the presence of the `BUNDLE_GEMFILE` environment
  variable.

## 2024-09-09 v0.49.0

### Breaking
- Renamed the `check-yaml` executable to `yaml_check`.
- Added `webrick` as a required runtime dependency in the gemspec
  and Rakefile.

### Features
- Added a `-b` option to `classify` to return only the rightmost module
  namespace.
- Implemented a usage help message for `classify` triggered by the `-h`
  option.

### Fixes
- Modified `classify` to append the `.rb` suffix only if the string does
  not already end with it.
- Added a nil guard in `long_lines` to skip lines where the line blamer
  result is nil.
- Updated `probe` to use `Shellwords.join` for proper quoting of command
  arguments.

### Improvements
- Standardized usage message formatting across multiple scripts to use
  squiggly heredocs (`<<~`) for consistent indentation and readability.
- Updated `create_tags` and `create_cstags` to use `braille7` frames for
  the busy indicator.
- Refactored `blameline` to use the `Utils::LineBlamer.for_line` method
  instead of `blame`.
- Removed obsolete `# encoding: UTF-8` comments from `on_change`,
  `probe`, and `search` scripts.

## 2024-09-09 v0.48.0

### Features
- Added a new `changes` command to generate changelog entries
  from Git logs using an Ollama LLM model.
- Added a new `code_comment` command to generate YARD
  documentation comments for Ruby methods using Ollama.
- Added a new `commit_message` command to delegate commit message
  generation to the `ollama_cli` tool.
- Added the `le` method to `Utils::IRB` for executing blocks with a
  pager, allowing for simplified interactive use.

### Breaking
- Removed support for Spring and the `rspec` formatter in the
  `probe` command.
- Removed the `-c` flag and `-f` option from the `probe` command,
  simplifying its interface for running tests.
- Removed the `fix-brew` utility script.

### Build & CI
- Added a runtime dependency on the `ollama-ruby` gem.
- Updated the Rakefile to filter executables based on Ruby shebangs,
  preventing non-Ruby scripts from being listed as executables.
- Updated dependency versions and constraints, including `infobar`,
  `mize`, `search_ui`, and `all_images`.

## 2024-09-06 v0.47.0

### Features
- Added `changes` script to generate markdown change logs using
  Ollama.
- Added `code_comment` script to generate YARD comments for Ruby
  methods via Ollama.
- Added `commit_message` script to generate git commit messages using
  Ollama configuration.

### Improvements
- Added `le` method to `Utils::Irb` as an alias for `less`.
- Toned dependency constraints for `infobar`, `mize`, `search_ui`,
  and `all_images` to use pessimistic operator.
- Modified Rakefile executable detection to only include Ruby
  scripts.

### Build & CI
- Added `ollama-ruby` as a runtime dependency.
- Removed `fix-brew` executable from the gem package.

### Documentation
- Removed trailing whitespace in `sync_dir` script.

## 2024-08-21 v0.46.0

### Features
- Added the `print_method` executable, which reads filenames and
  line numbers from `STDIN` or `ARGV` to print corresponding method
  definitions.
- Added the `le` method to `Utils::IRB` to execute blocks via the
  `less` pager.

### Build & CI
- Updated the `gem_hadar` development dependency to `~> 1.16.1`.
- Added `bin/print_method` to the gem's `s.executables` and `s.files`
  lists.

## 2024-07-09 v0.45.0

### Breaking
- Removed the `irb_connect` executable and the `Utils::IRB::Service`
  module, which provided remote IRB functionality via DRb.
- Removed the `irb_server` and `irb_connect` methods from
  `Utils::IRB::Shell`.

### Improvements
- Removed code that was broken by newer Ruby versions to ensure
  compatibility with the current runtime environment.

### Build & CI
- Updated the gem metadata to remove references to the deleted
  `bin/irb_connect` executable and `lib/utils/irb/service.rb`
  file.

## 2024-07-03 v0.44.0

### Features
- Added a `quit` option to the interactive prompt in `sync_dir` to
  exit the script immediately.
- Added a `quit` option to the interactive prompt for differing files
  in `sync_dir` to exit the script immediately.

### Improvements
- Refactored the interactive prompt for differing files in `sync_dir`
  to use a consistent case statement structure.
- Configured `create_tags` to exclude the `pkg` directory from tag
  generation.

## 2024-06-05 v0.43.0

### Improvements
- Added `--exclude=pkg` to the `ctags` command in `bin/create_tags`
  to prevent scanning package directories when generating tags.

## 2024-04-24 v0.42.0

### Features
- Added `-G AUTHOR` flag to `search` and `blameline` to filter
  results by git author.

### Improvements
- Removed `Utils::LineBlamer.blame` in favor of calling `perform`
  directly on instances.
- Fixed `probe` help alignment to accommodate longer command names
  by using `docs_size`.
- Removed redundant `path` variable assignment in `discover` and
  unused `JSON::ParserError` catch variable.
- Standardized method invocation syntax to use parentheses across
  `bin/create_tags`, `bin/discover`, `bin/search`,
  `lib/utils/irb.rb`, and `lib/utils/probe_server.rb`.
- Removed unused `'a'` option from `search` replace prompt.

## 2024-04-17 v0.41.0

### Build & CI
- Added `drb` as a runtime dependency in the `Rakefile` and `utils.gemspec` to support Ruby **3.4**.

## 2024-03-22 v0.40.0

### Improvements
- `sync_dir`: Added orange highlighting for file contents in
  "only in files" diff output.
- `sync_dir`: Removed unused local variable in the `ask?` method
  to clean up the implementation.
- `sync_dir`: Added a `redo` loop to re-process the current item
  after a `vimdiff` session.

### Build & CI
- Updated development dependency `gem_hadar` to version **1.15.0**.

## 2023-11-22 v0.39.0

### Improvements
- Display file content in orange within `sync_dir` output using
  `Term::ANSIColor`.

## 2023-10-23 v0.38.0

### Features
- Add a `sync_dir` configuration section to allow skipping specific
  paths during directory synchronization.
- Add a `list` action to the `path` script to expand and print all
  paths in `$PATH`.

## 2023-08-18 v0.37.1

### Fixes
- Ensure original files are properly truncated when
  rewriting content via `replace_line` in `bin/search`

## 2023-08-11 v0.37.0

### Features
- Add `sync_dir` executable to interactively copy, edit,
  or delete files when synchronizing directories.

## 2023-06-09 v0.36.0

### Features
- Added a `q` option to the replace prompt in `search` to allow
  quitting the operation early.

### Improvements
- Refactored the `replace_line` method in `search` to use `Tempfile`
  and read/write file operations, ensuring the original file content is
  fully preserved after the edit.

## 2023-03-02 v0.35.0

### Features
- Default to interactive search when no pattern is provided in `discover`.

## 2023-01-05 v0.34.0

### Improvements
- Consolidated `irb_edit`, `edit`, and `ls` into a single `ed`
  method with variable argument support.
- Moved the conditional require for `utils/line_formatter` from
  `lib/utils.rb` to `bin/probe` to improve loading logic.
- Fixed code formatting in `lib/utils/line_formatter.rb` to align
  with standard indentation practices.

## 2022-12-17 v0.33.1

### Improvements
- Replaced `IO.read` with `File.read` for file reading in
  `lib/utils/irb.rb`.

### Build & CI
- Removed `byebug` and added `debug` as a development dependency.
- Added `.github/dependabot.yml` to enable weekly Bundler
  dependency updates.

## 2022-12-05 v0.33.0

### Features
- The `probe` tool now supports the `-f` option to remotely
  configure the RSpec formatter.

### Improvements
- The `probe_server` now logs the executed command line when
  processing jobs.

## 2022-11-04 v0.32.0

### Features
- `irb_time_watch` now estimates and displays an average remaining time when a rate becomes negative.

### Fixes
- `check-yaml` now uses `YAML.unsafe_load_file` and `YAML.unsafe_load` to prevent security warnings for local files.

## 2022-08-04 v0.31.1

### Improvements
- Replaced `YAML.load_file` and `YAML.load` with their
  `YAML.unsafe_load_file` and `YAML.unsafe_load` counterparts
  in `bin/check-yaml`.

## 2022-07-15 v0.31.0

### Features
- Add an optional iteration count parameter to `irb_time` and
  `irb_time_tap` for repeated benchmarking, reporting average time
  per call.

## 2022-07-11 v0.30.2

### Improvements
- Increased the minimum required version of the `all_images`
  dependency to **0.0.2** in `Rakefile` and `utils.gemspec`.
- Updated debug output in `lib/utils/irb.rb` to use the U+1D6D9
  glyph for the rate unit instead of `#`.

## 2022-07-07 v0.30.1

### Documentation
- Fixed the `irb` utility warning to correctly align diffs with
  rates and replaced the comment with a proper symbol.

## 2022-06-16 v0.30.0

### Features
- Added `-F` option to `search` to consider only real files when searching.

## 2022-05-19 v0.29.0

### Features
- Added `check-yaml` executable to validate YAML syntax from a file or
  standard input.

## 2022-05-15 v0.28.0

### Build & CI
- Added `all_images` as a runtime dependency to ensure the extracted gem is available.

## 2022-05-14 v0.27.0

### Features
- Added the `rd2md` command to convert RDoc markup to Markdown
  using `RDoc::Markup::ToMarkdown`.

### Build & CI
- Updated the `gem_hadar` development dependency to **~> 1.12.0**.

## 2022-05-06 v0.26.1

### Build & CI
- Added `GPL-2.0` license metadata to the gemspec and `Rakefile`.
- Integrated CodeQL static analysis into GitHub Actions workflows.

## 2022-04-27 v0.26.0

### Features
- Add a configurable `prefix` for Docker image tags in the
  `all_images` utility, defaulting to the base name of the
  current directory.

### Improvements
- Update the Docker image build process in `all_images` to
  include `gem update --system` in the recommended
  `dockerfile` configuration.

## 2022-05-06 v0.25.1

### Build & CI
- Declared `GPL-2.0` as the gem's license in the gemspec metadata.

## 2022-02-24 v0.25.0

### Features
- Added `ssl_cert_info` utility to display OpenSSL certificate information.

### Improvements
- Updated `all_images` configuration example to display output in bold.

## 2021-12-27 v0.24.2

### Improvements
- Add the `--pull` flag to the `docker build` command in
  `bin/all_images` to force pulling the base image.

## 2021-12-27 v0.24.1

- No user-visible changes.

## 2021-12-27 v0.24.0

### Features
- Add the `all_images` executable to run a script across a
  configured list of Docker images using a YAML definition file.

## 2020-10-03 v0.23.3

### Improvements
- Switched the `bin/fix-brew` script's shebang to
  `#!/usr/bin/env bash`.

## 2020-10-03 v0.23.1

### Features
- Add `fix-brew` script to repair Homebrew prefix permissions by
  changing group ownership and granting group write access.

## 2020-09-25 v0.23.0

### Fixes
- Fixed a bug in `bin/path` where the global variable `$opt` was
  incorrectly referenced instead of `$opts` when checking for the
  export flag.

### Improvements
- Removed obsolete command-line utilities from `bin/`, including
  `brakeman2err`, `chroot-exec`, `chroot-libs`, `dialog-pick`,
  `errf`, `remote_copy`, `rssr`, `same_files`, `tmproc`,
  `unquarantine_apps`, `vacuum_firefox_sqlite`, and `xmp`.
- Updated `bin/irb_connect` to accept a `-u` URL option instead of
  separate `-r` host and `-p` port options, simplifying the
  connection logic via `Utils::IRB::Service.connect`.
- Updated the gemspec to reflect the removal of the obsolete
  executables and the new version.

## 2020-02-11 v0.22.1

### Fixes
- Renamed the `edit_remote` method in `lib/utils/editor.rb` to `edit_remote_wait` to accurately reflect its behavior of executing `--remote-wait` and fixing potential naming inconsistencies.

## 2020-02-11 v0.22.0

### Improvements
- Replaced the internal `Utils::SearchUI` implementation with the `search_ui`
  gem, removing `lib/utils/search_ui.rb` and adding `search_ui` as a
  dependency.
- Updated the `discover` search interface to limit result display to the
  terminal's line height.

## 2020-02-06 v0.21.2

### Improvements
- Moved the `tmux` window rename logic into a private
  `rename_window` method within `Editor`.
- Ensure the window is only renamed if the server has not already
  started, avoiding duplicate rename calls.
- Renamed the `edit_remote_wait` method to `edit_remote`.

## 2020-02-05 v0.21.1

### Features
- Rename the active tmux window to `edit` when `bin/edit` is
  run inside a tmux session.

## 2020-02-03 v0.21.0

### Improvements
- The `discover` command now defaults the `-a` option to match word
  characters (`\w`).

## 2020-01-15 v0.20.0

### Breaking
- Remove the runtime dependency on `pry-editline`.
- Remove the custom IRB history saving functionality previously
  implemented in `IRB::Context` and `IRB::HistorySavingAbility`.

### Improvements
- Grant executable permissions to `bin/discover`.
- Fix indentation in `Utils::IRB#ri` for the `receiver_unless_main`
  block.

## 2019-12-02 v0.19.0

### Features
- Add selector for result list

## 2019-12-02 v0.18.1

### Fixes
- Changed `bin/discover` execute permissions from executable
  to non-executable.

## 2019-12-02 v0.18.0

### Features
- Replace the `efi` bootdisk utility with a new `efi` tool that
  supports mounting, unmounting, and restoring EFI volumes.
- Add `backup` and `restore` commands to the `efi` utility for
  cloning EFI partitions between volumes.

### Breaking
- Rename the `Utils::InteractiveSearch` class to
  `Utils::SearchUI` and update all internal references.
- Modify `Utils::SearchUI` to return the query result directly
  instead of a boolean value.

### Improvements
- Update terminal control sequences in `Utils::SearchUI` to
  improve screen clearing and cursor positioning behavior.

## 2019-11-20 v0.17.0

### Features
- Added a new `bootdisk` executable to query EFI boot disk details.
- Updated `dialog-pick` to use the `bash` shell instead of `sh`.

### Build & CI
- Updated `gem_hadar` development dependency to **1.11.0**.

## 2019-05-08 v0.16.0

### Features
- Added a new `index_expire_after` configuration option to allow
  the finder index to automatically expire after a specified
  duration.
- Modified `Utils::Finder#reset_index` to now trigger on index
  expiration, not only when the `-r` flag is explicitly provided.

## 2019-04-25 v0.15.1

### Fixes
- Added cache reset in `bin/discover` to ensure the
  `Finder` object clears its state when the `-r` flag is
  used without a pattern.

## 2019-04-15 v0.15.0

### Improvements
- Updated the minimum required version for the `pstree` gem dependency
  from `~> 0.1` to `~> 0.3` in the `Rakefile` and `utils.gemspec`.

## 2019-04-09 v0.14.0

### Features
- Added a new `create_cstags` executable for generating cscope
  tags files.
- Added a `-D` option to the `discover` command to list all
  search leaf directories.
- Introduced a `Scope` class and `scope` method in
  `Utils::ConfigFile` to facilitate cscope tag generation.

### Improvements
- Updated the executable list in the gemspec to include the
  new `create_cstags` command.

## 2019-04-05 v0.13.0

### Features

- Add a `-D` option to the `discover` utility to list all searched
  leaf directories.

## 2019-03-04 v0.12.0

### Features
- Added interactive pattern search to the `discover` tool via the
  new `-s` flag.
- Introduced `Utils::InteractiveSearch` to handle real-time input
  and result filtering.

### Fixes
- Corrected `Finder` logic to safely handle empty result sets when
  applying match limits.

### Improvements
- Added `mize` dependency to enable memoized path loading for
  improved performance.
- Fixed spelling errors in the `myex` command documentation.
- Updated `discover` usage text to accurately reflect that `PATTERN`
  is optional.

### Build & CI
- Bumped the `rubygems_version` in the gemspec to **3.0.2**.

## 2018-10-31 v0.11.0

### Features
- Removed the dependency on the `testrb` binary by invoking the `ruby` command
  directly for test-unit execution and adding directory expansion logic for
  test file arguments.

## 2018-10-17 v0.10.1

### Improvements
- Default the `discover` utility to a maximum of 10 matches by
  adding a `max_matches` configuration option.

## 2018-01-24 v0.10.0

### Features
- Add `tmproc` executable to create a standard tmux environment from
  a `Procfile`.
- Add `vcf2alias` executable to generate mutt aliases from VCF contact
  files.
- Add a `search` command to `myex` for matching and displaying context
  from backup insert statements.
- Support linenumber ranges in files for the `edit` command and
  `Utils::Editor` class.
- Add an index cache to the `discover` command to store and load file
  paths, with a new `-r` option to reset the index.
- Add a `-n` option to `discover` to limit the number of returned
  matches.
- Add a `-l` option to the `edit` command to list current vim servers.
- Add a busybar to `brakeman2err` and `create_tags` to provide visual
  feedback during long-running computations.

### Breaking
- Remove support for the `-b` option in `discover` and `search`.
- Replace the `-R` option in `search` and `-r` in `discover` with a
  `-p` option that accepts `f` for fuzzy or `r` for regexp pattern
  types.

### Fixes
- Fix `Utils::Editor` to handle `source_location` objects that do not
  respond to `filename` and `linenumber`.
- Fix `probe` to use `bundle exec` when `BUNDLE_GEMFILE` is set and
  remove deprecated zeus support.
- Fix `brakeman2err` to correctly handle the `Infobar` object.
- Fix `vcf2alias` to handle symlinked alias files and support German
  umlauts in shortcuts.
- Fix `create_tags` to correctly display the number of tags created.

### Improvements
- Improve file discovery scoring in `Utils::Finder` to weight matches at
  the end of paths more heavily.
- Use `tins` efficient visiting API in `Utils::Finder` and
  `Utils::Grepper`.
- Allow multiple `-I` options in `strip_spaces`, `search`, and
  `discover` for specifying multiple suffixes.
- Update `tins` dependency from `~>1.8` to `~>1.14`.
- Move busybar functionality into the `infobar` gem and remove the
  internal `Utils::Busybar` class.

## 2017-02-07 v0.9.0

### Features
- Add new `git-versions` command to list git tags and display
  log output between versions, with optional support for
  custom tag name patterns.
- Add new `ascii7` command to display a table of the first
  32 ASCII characters mapped to their common mnemonics.
- Add `-g` option to `search` to use git blame to identify the
  author of matching lines.
- Add `-t` option to `strip_spaces` to replace tab characters
  with a specified number of spaces.

### Fixes
- Ignore invalid UTF-8 byte sequence errors in `Utils::Patterns`
  matchers to prevent crashes on non-UTF-8 files.

### Improvements
- Update `Utils::LineBlamer` with a new `blame` class method
  that encapsulates the logic for performing blame and applying
  color formatting.
- Refactor `search` and related commands to use symbol-based
  option keys for improved code consistency.
- Change the default terminal multiplexer in `ssh-tunnel`
  configuration from `screen` to `tmux`.
- Shorten job description output in `Utils::ProbeServer` by
  removing the `Job#` prefix.

### Build & CI
- Add `ascii7` and `git-versions` to the list of executables
  in the gem specification.
- Bump `gem_hadar` development dependency to version **1.9.1**.

## 2016-09-30 v0.8.0

### Breaking
- Removed the `utils-install-config` command and the `Utils::Config` module.
- Renamed `Utils::Config::ConfigFile` to `Utils::ConfigFile` and removed the
  bundled configuration template files from `lib/utils/config`.
- Removed the `-d` and `-D` options from the `discover` command.

### Features
- Added the `dialog-pick` command to select an item from a list using
  `dialog`.
- Added the `serve` command to serve a directory using `WEBrick::HTTPServer`.
- Added a `-b` option to the `search` command to display git blame
  information for matches.
- Added a `-p` option to the `classify` command to parameterize strings
  using a custom separator.
- Added support for prefix-based path shifting in the `classify` command via
  the `shift_path_for_prefix` configuration.

### Improvements
- Changed `discover` to match directories and files by default, and set
  case-insensitive matching to `true` by default.
- Updated `FuzzyPattern` to ignore non-alphanumeric characters in patterns.
- Simplified the `classify` command to use `Term::ANSIColor.uncolor` for
  input handling.

### Fixes
- Updated regular expressions in `blameline` and `search` to handle `^`
  characters in git SHA-1 hashes.
- Fixed `search` to display the full matched line alongside blame
  information.
- Fixed `blameline` to skip lines where the blame lookup fails.
- Reverted the default `shift_path_by_default` configuration value to `0`.

## 2016-05-18 v0.7.0

### Features
- Added `bin/rssr`, a script that parses and displays RSS feeds using
  `RSS::Parser` with terminal-colored output.
- Enabled `**` style glob patterns for root paths in `Utils::Finder` and
  `Utils::Grepper` by expanding roots with `Dir`.
- Added `classify` configuration block support, including
  `shift_path_by_default` for default path shifting in `bin/classify`.

### Fixes
- Changed `path_shifter` in `bin/classify` to accept `n: nil` and apply
  default shift path width from configuration if `n` is not provided.

## 2016-04-11 v0.6.4

### Features
- Add search and replace facility to `search` with the `-r` option.
- Support Spring in `probe` to run tests via `bin/spring rspec`.
- Overhaul the `probe_server` command interface with shortcuts and
  improved `Job` inspection.
- Support setting and getting environment variables on the probe
  server via the `-C` option in `probe`.
- Add more git file status options to the `edit` command, including
  `-g` for modified, cached, deleted, other, and next commit files.
- Add object-oriented call syntax support for `ri` and `irb_open` in
  `Utils::IRB`.

### Fixes
- Handle `Errno::ENOENT` in `probe` when checking if Spring is running.
- Return an empty string from `format_backtrace` in
  `Utils::LineFormatter` if the exception backtrace is nil.
- Allow `edit` to work outside of a git repository when using
  git-specific arguments.
- Unify `ri` and `yri` methods in `Utils::IRB` to use a single
  implementation.

### Improvements
- Remove the `Module` include for `Utils::IRB::Module` in
  `lib/utils/irb.rb`.
- Log environment variable changes in `probe_server` via a
  `LogWrapper` class.
- Bump the `tins` dependency requirement to `~> 1.8`.
- Bump the `gem_hadar` development dependency to `~> 1.7.0`.

### Build & CI
- Update the `tins` runtime dependency in the gemspec to `~> 1.8`.
- Update the `gem_hadar` development dependency in the gemspec to
  `~> 1.7.0`.

## 2015-09-15 v0.6.2

### Fixes
- Instantiate `Utils::Editor` in the `discover` script to ensure
  the `editor` method is available.

### Improvements
- Replace block-based output handling with direct printing of
  `finder.paths` in the `discover` script.
- Remove unused block yield logic from `Utils::Finder#search`.

## 2015-09-10 v0.6.1

### Features
- The `edit` command now opens locally modified files
  tracked by Git by default when executed without
  arguments in a TTY environment.

### Fixes
- Corrected the instantiation of `Utils::Editor` within
  the `discover` executable to ensure the `new` method
  is called explicitly.

## 2015-08-18 v0.6.0

- No user-visible changes.

## 2015-08-18 v0.5.1

### Improvements
- Skip the `Pick?` prompt in `bin/discover` and `bin/search` when
  only a single path is available.

## 2015-08-17 v0.5.0

### Features
- Added `-E` flag to `search` and `discover` to pick one file to edit.
- Added `irb_open` method to open a URL or capture block output.
- Added `edit` method to open the current object in the editor.

### Improvements
- Updated `tins` dependency from `~>1.0` to `~>1.6`.
- Refactored `edit_files` in `search` and `discover` to support pick mode.
- Updated `Utils::Finder` and `Utils::Grepper` to handle the new `E` option.

### Build & CI
- Updated `utils.gemspec` and `Rakefile` to reflect new `tins` version.
- Bumped gem version from **0.3.0** to **0.4.0**.

## 2015-06-26 v0.4.0

### Breaking
- Changed `irb_server` and `irb_connect` methods to accept a `uri`
  argument instead of separate `hostname` and `port` arguments.
- Removed `irb_info` and `irb_fullinfo` methods from the IRB shell
  utilities.
- Removed the `Utils::IRB::Relation` module and its extension of
  `ActiveRecord::Relation`.

### Improvements
- Added default arguments to several IRB method listing helpers, such
  as `irb_all_methods`, `irb_methods`, and `irb_eigen_methods`, allowing
  them to operate on the current context without explicit arguments.
- Moved `Utils::IRB::Service` to a separate file and updated it to
  handle URI strings for starting and connecting to DRb services.
- Updated the `gem_hadar` development dependency requirement to
  **~> 1.3.1**.

## 2015-06-26 v0.3.0

### Breaking
- The `-p` port option for `bin/probe` was replaced by a `-u`
  URI option, and the default connection target changed from a
  local TCP port to a Unix socket.

### Features
- Added a `long_lines` command to identify and blame source lines
  that exceed a specified maximum length.
- Added a `blameline` command to perform git blame operations on
  source locations provided via standard input or file paths.
- Generalized the `classify` command with an `-n` option to allow
  path component shifting for class name derivation.
- Added `Utils::LineBlamer` class to encapsulate git blame logic.
- Added `Utils::Xt::SourceLocationExtension` module to provide
  source location parsing capabilities independently of the
  editor.
- `myex` now disables foreign key checks during truncate and insert
  operations to prevent constraint violations.
- `probe` now passes the `-rutils` flag to rspec to ensure the
  library is loaded correctly.

### Fixes
- Fixed `Utils::LineFormatter` to handle missing RSpec
  dependencies gracefully without crashing.
- Corrected the loading of `rspec/core` and
  `rspec/core/formatters/base_text_formatter` to prevent
  `LoadError` exceptions.
- Refactored `Utils::LineFormatter` to use the modern RSpec
  formatter interface rather than inheriting from
  `BaseTextFormatter`.
- Restored console output of failure details in
  `Utils::LineFormatter`.
- Fixed Rakefile installation to use `rm_f` instead of `rm` to
  avoid errors when removing existing executables.
- Removed the `.ruby-version` file to allow flexibility in the
  Ruby interpreter used for development.

### Improvements
- Improved `Utils::LineFormatter` summary output to use terminal
  column width for separators and include duration in the summary
  line.
- Enhanced `Utils::LineFormatter` failure reporting with improved
  backtrace formatting and optional folding.
- Updated IRB method descriptions to use the `description` method
  with namespace styling for better clarity.
- Simplified `Utils::LineFormatter` error handling by rescuing
  specific `NameError` exceptions.

## 2014-07-26 v0.2.1

- No user-visible changes.

## 2014-06-05 v0.2.0

### Features
- Added `zeus` support to the `probe` binary with a new `-z`
  flag and configuration option.
- Added an `irb_clipboard` method to handle clipboard
  integration on `darwin` platforms.
- Added a `job_kill` method to the probe server for sending
  arbitrary signals to the current job process.

### Fixes
- Updated `require` statements to use the `tins` namespace
  instead of `dslkit` for compatibility.

### Build & CI
- Updated the `Rakefile` to manually install `tins`, `term-ansicolor`,
  `pstree`, and `pry-editline` gems during the installation
  process.

## 2014-03-14 v0.1.1

### Features
- Added the `json_check` executable to validate JSON
  input from `ARGF`.

## 2014-02-06 v0.1.0

### Improvements
- Added a version display line to the `ssh-tunnel` help output.

### Build & CI
- Dropped the `dslkit` dependency.
- Upgraded the `tins` dependency to version `~> 1.0`.
- Upgraded the `term-ansicolor` dependency to version `~> 1.3`.
- Updated the `pstree` dependency constraint to `~> 0.1`.

## 2014-01-31 v0.0.100

### Features
- Added support for multiple SSH tunnels via `-t` flags.
- Enabled binding of SSH tunnels to specific local addresses.
- Added support for IPv6 addresses in SSH tunnel specifications.
- Introduced the `-T` option to list current SSH tunnels with ANSI
  colors.
- Added the `-d` option to enable debugging output for the `ssh-tunnel`
  command.
- Added the `-e VARIABLE=VALUE` option to pass environment variables
  to the SSH login shell.
- Added the `Utils::SshTunnelSpecification` class to parse and validate
  SSH tunnel specification strings.

### Fixes
- Improved error handling in `chroot-libs` to gracefully skip missing
  library files.
- Replaced the deprecated `debugger` gem with `byebug` for Ruby 1.9
  and later.

### Improvements
- Updated `chroot-libs` to use `lines` instead of `split` for
  compatibility with Ruby 1.9.
- Added `.bundle` to `.gitignore` and Rakefile ignore patterns.

## 2013-10-09 v0.0.99

### Features
- Support reading from `STDIN` and stripping trailing whitespace
  when no arguments are provided to `strip_spaces`.

## 2013-10-01 v0.0.98

### Features
- Added support for colorized output in the probe server console, using
  ANSI colors to highlight job status as successful, failed, or pending.
- Introduced job history tracking in the probe server, enabling users to
  list, clear, and repeat previously executed jobs via `history_list`,
  `history_clear`, and `job_repeat`.
- Added a `docs` method to the probe server that lists available
  commands and their descriptions for in-console help.
- Renamed probe server methods to a consistent `job_` or `jobs_`
  prefix (e.g., `enqueue` to `job_enqueue`, `list_jobs` to `jobs_list`),
  while preserving the old method names as aliases for backward
  compatibility.
- Added a `colorize` class attribute to `Utils::ProbeServer::Job` to
  control whether terminal output is colorized, defaulting to `false` and
  enabled by default in the `bin/probe` client.

### Fixes
- Updated `job_repeat` to accept both a `Job` instance and a job ID,
  normalizing the input to use the job ID for history lookups.
- Ensured the probe server's history and job queue return copies of
  internal arrays to prevent accidental modification of server state.

## 2013-10-01 v0.0.97

### Breaking
- Rename `Utils::ProbeServer` methods for job and history management,
  including `job_enqueue`, `job_stop`, `job_continue`,
  `server_shutdown`, `jobs_list`, `jobs_clear`, `job_repeat`,
  `history_list`, and `history_clear`.

### Features
- Add support for colorized console output in the probe server.
- Implement a job history feature to list and clear executed jobs.
- Add the ability to repeat a previous job using `job_repeat`.
- Enable control of the remote server's environment variables via the
  `env` method.
- Add a `docs` method to retrieve documentation annotations.

## 2013-10-01 v0.0.96

### Fixes
- Refactored `bin/probe` argument parsing to correctly pass multiple values
  for a single option as a flat array.
- Updated `bin/probe` dispatch logic to prevent `connect_server` from
  executing when the list (`-l`) option is used.
- Modified `Utils::ProbeServer#cmd` to prepend `bundle exec` to the
  command invocation when a `BUNDLE_GEMFILE` environment variable is
  present.
- Added informational logging in `Utils::ProbeServer#cmd` to display the
  exact command being executed.

## 2013-09-30 v0.0.95

### Features
- Added `--console` option to `probe` to launch an interactive
  console session.
- Added `--command` and `--visual` options to `edit` to send
  ex and visual commands to the running editor.
- Added `--url-safe-methods` support to `brakeman2err` by passing
  the flag to the `brakeman` command.

### Improvements
- Refactored `probe` server and client startup logic into dedicated
  `start_server` and `connect_server` methods.
- Refactored `Utils::ProbeServer` to support job tracking with
  unique IDs, process control, and improved output formatting.

### Build & CI
- Updated `term-ansicolor` dependency requirement to `~>1.2`,
  `>=1.2.2`.

## 2013-08-16 v0.0.94

### Improvements
- Removed the `--separate-models` flag from the `brakeman`
  invocation in `brakeman2err` to stop using separate model
  analysis.

## 2013-08-16 v0.0.93

- No user-visible changes.

## 2013-08-16 v0.0.92

## 2013-08-16 v0.0.91

### Improvements
- `brakeman2err` now includes the `brakeman_ignore` file and
  separate models option to reduce false positives, and displays a
  link for each warning.

## 2013-08-06 v0.0.90

### Improvements
- Added summary output reporting error and warning counts before detailed findings in `bin/brakeman2err`.

## 2013-08-05 v0.0.89

### Fixes
- Modified `brakeman2err` to display analysis results regardless of
  the `c` flag.

## 2013-08-02 v0.0.88

### Features
- Added `brakeman2err` to convert Brakeman output into a Vim
  error file.

### Fixes
- Fixed `chroot-libs` to work with Ruby 1.9 by using `lines` instead
  of `gsub`.
- Fixed `myex` to avoid encoding conversion errors by using
  `ascii-8bit`.

### Improvements
- Updated `probe` to support Cucumber as a test framework.
- Documented `probe` options for client, server, and port modes.
- Updated `tins` dependency to **0.8.3**.

### Documentation
- Corrected a typo in the `irb_connect` documentation.

## 2013-06-21 v0.0.87

### Features
- The `probe` server now attempts to shutdown a previously
  running instance via `DRbObject` on startup.
- Extracted the `ProbeServer` class from `bin/probe` into
  `lib/utils/probe_server.rb` and added a `shutdown` method
  that forces the process to exit.

### Improvements
- The `cmd` method in `bin/probe` now exits with the exit
  status of the executed command if it fails.
- Job execution output in `ProbeServer` now displays distinct
  success and failure messages with appropriate colors.

## 2013-06-20 v0.0.86

## 2013-06-20 v0.0.85

### Features
- Added ANSI color support to `bin/probe` using the `term/ansicolor` gem to display job lifecycle messages.

## 2013-06-19 v0.0.84

### Features
- Added support for running Cucumber tests via the `probe` utility,
  allowing line number specification and file path mapping.

### Fixes
- Fixed option passing in `bin/probe` by flattening the options array
  to ensure correct serialization over `DRb`.

### Improvements
- Removed the `-S` flag from the `testrb` command invocation within
  `bin/probe` for `test-unit` execution.

## 2013-05-15 v0.0.83

## 2013-05-15 v0.0.82

### Build & CI
- Added `pstree` as a runtime dependency.

### Improvements
- Replaced `ps` command with the `pstree` library for more
  robust process detection in `lib/utils/editor.rb`.

## 2013-05-14 v0.0.81

### Fixes
- Filter out `grep` process entries to prevent false matches
  in `tmux` pane identification.

## 2013-05-14 v0.0.80

### Fixes
- Adjusted regex to match `/edit` at end of string in pane detection.

## 2013-05-14 v0.0.79

### Fixes
- Exclude the current process PID from `tmux` pane
  detection in the editor utility.

## 2013-05-14 v0.0.78

### Improvements
- In `Utils::Editor`, replaced the `ensure_running` method with
  deferred `activate` logic within the `edit` method.
- Updated the `edit` method to detect the active editor process and
  use `tmux` to switch to the corresponding pane.

## 2013-05-14 v0.0.77

### Fixes
- Add an `ensure_running` check to the `edit` method in
  `lib/utils/editor.rb` to verify the editor session is active
  before proceeding with editing logic.
- Replace a placeholder `TODO` comment in the `edit` method with
  logic to locate and select the correct `tmux` pane using `tmux
  list-panes` and `ps`, enabling seamless switching to the editor
  pane after a remote edit operation.

### Improvements
- Bump version to **0.0.77** in `VERSION`,
  `lib/utils/version.rb`, and `utils.gemspec`.

## 2013-05-13 v0.0.76

### Fixes
- Corrected `derive_server_name` in `Utils` to use the
  current directory (`Dir.pwd`) instead of the parent
  directory when `VIM_SERVER` is not set.

## 2013-05-10 v0.0.75

### Features
- Derive the default server name for `Utils::Editor` from the current
  directory path.

### Fixes
- Start the editor instance when no file arguments are provided in the
  `edit` command.
- Detach the client session when attaching to a tmux session.

## 2013-03-12 v0.0.74

### Features
- Added configurable vim path and default arguments via a new `Edit` class in `Utils::Config::ConfigFile`.
- Added `remote_copy` executable to the list of installed gems in `utils.gemspec`.

### Fixes
- Changed `bin/edit` to use a config file for editor settings and removed automatic server startup.
- Replaced hard-coded vim detection logic with configurable settings from `Utils::Config::ConfigFile`.
- Simplified remote editor commands to remove conditional `gui` flag handling.
- Updated `activate` method to only execute remote send tricks when `-g` is present in default args.

### Improvements
- Refactored `bin/edit` to load configuration from file and simplify `Editor` initialization.
- Updated `edit_file_linenumber` to use `edit_remote_wait` or `edit_remote` directly with line numbers.
- Changed `fullscreen=` method to always call `start` instead of checking if already started.

## 2013-03-08 v0.0.73

### Features
- Added a new `remote_copy` binary for handling remote clipboard
  synchronization.
- Introduced a `copy_paste` configuration option within the `ssh_tunnel`
  settings.
- Added a `-m` command-line option to `ssh-tunnel` for selecting the
  terminal multiplexer.

### Fixes
- Corrected the `ssh-tunnel` execution logic to ensure the tunneling code
  path is properly handled.
- Fixed the default terminal multiplexer configuration to use `screen`
  instead of `sshscreen`.

## 2013-02-28 v0.0.72

### Improvements
- Enable UTF-8 support for `tmux` commands by adding the `-u` flag to the `tmux -u new` and `tmux -u attach` commands in `Utils::Config::ConfigFile`.

## 2013-02-28 v0.0.71

### Features
- Support for creating new remote sessions in tmux.

### Fixes
- Fallback to a default session name if `ENV['USER']` is not
  set.

## 2013-02-26 v0.0.70

### Breaking

- Renamed the `sshscreen` executable to `ssh-tunnel`.

### Features

- Added a new `SshTunnel` configuration block to `Utils::Config::ConfigFile`.
- Introduced support for configurable terminal multiplexers (`sshscreen` or `tmux`) via the `terminal_multiplexer` setting.
- Added a `-C` option to the `ssh-tunnel` command to output SSH or RC configuration files.

### Fixes

- Updated the Gemfile to use `https://rubygems.org` as the source.
- Clarified the `-C` option in the `ssh-tunnel` usage text to specify valid values.

### Build & CI

- Loosened the `tins` dependency version constraint from `~>0.5.3` to `~>0.5`.

## 2012-12-14 v0.0.69

### Fixes
- In `Utils::make_dirs`, replaced `FileUtils.mkdir` with
  `FileUtils.mkdir_p` to ensure all intermediate directories are
  created when a file path contains multiple levels.

## 2012-12-14 v0.0.68

### Features
- Added `mkdir` functionality.

### Improvements
- Removed the bundled Vim configuration, which has been moved to a separate repository.

## 2012-12-05 v0.0.67

### Fixes
- Changed `irb_load` to `load` within the `Utils` module to
  correctly handle file loading in the IRB context.

## 2012-12-05 v0.0.66

### Features

- Added `irb_server` and `irb_connect` methods to `Utils::IRB`.
- Added a new executable, `irb_connect`, for connecting to remote IRB
  sessions.

### Fixes

- Updated the condition for including `Utils::IRB::Relation` to check if
  `examine` is defined on `ActiveRecord::Relation`, preventing potential
  method conflicts.

### Improvements

- Improved job status messages in `probe` to use `inspect` for better
  readability and added a confirmation message after job execution.
- Changed the require statement for `DRb` from `drb/drb` to `drb` in
  `probe` and `lib/utils/irb.rb` for consistency.

## 2012-11-29 v0.0.65

### Fixes
- Renamed the `loop` method to `work_loop` to avoid
  overriding the Kernel method and causing an infinite
  recursion.
- Corrected the `exec` call in `run_job` to use
  `cmd(job)` directly, ensuring the command array is
  executed properly without passing the script name
  redundantly.
- Introduced `Thread.abort_on_exception` configuration
  based on the `$DEBUG` flag to improve error handling.

### Improvements
- Added the `output_message` helper method to standardize
  job status logging and ensure immediate `STDOUT`
  flushing.
- Renamed `enqueue` as an alias for `run` to clarify the
  intent of job submission while maintaining backward
  compatibility.
- Refactored `cmd` to centralize command construction
  logic for job execution.

## 2012-11-29 v0.0.64

### Features

- Implemented a job queue in `ProbeServer` that processes incoming jobs
  sequentially on a dedicated background thread.
- Added support for multiple concurrent `run` invocations by enqueueing
  jobs before executing them via `fork` and `Process.wait`.

## 2012-11-29 v0.0.63

### Fixes
- Add `exit` after `DRbObject#run` in `bin/probe` to prevent
  subsequent local test execution.

## 2012-11-29 v0.0.62

### Features
- Added client-server support to `probe` using `DRb`, allowing
  remote execution of test processes via new `-l` and `-c` options.

## 2012-11-22 v0.0.61

### Fixes
- `sshscreen`: Fixed tunnel configuration logic so that `lport` defaults
  to `tport` when `-l` is not specified.
- `sshscreen`: Replaced `File.exist?` checks before `rm_f` calls to
  improve robustness.
- `sshscreen`: Updated usage help text to clarify `-t` and `-l` option
  semantics.
- `Utils::Editor`: Fixed string parsing logic to prioritize existing
  file paths over class-method patterns in the `to_str` method.

### Improvements
- `sshscreen`: Reformatted usage output for better alignment and
  readability.
- `sshscreen`: Simplified variable assignment for `tunnel` and `tport`
  initialization.

### Documentation
- Added `lib/utils/config/vim/doc/xml-plugin.txt` to provide help
  documentation for the XML/SGML filetype plugin.

### Build & CI
- Updated `utils.gemspec` to include the new `xml-plugin.txt`
  documentation file and refresh the file list.
- Removed the empty `s:ExtractConcern` function from the `rails.vim`
  plugin.
- Removed a `Decho` debug statement from the `rails.vim` plugin.

## 2012-10-19 v0.0.60

### Features
- Added `%f` placeholder support in `bin/on_change` commands to
  dynamically insert the monitored filename.

### Fixes
- Duplicated `ARGV` in `bin/on_change` to prevent unintended mutation
  of the original arguments array.
- Disabled `inccsearch` in the Vim configuration.
- Removed the `-i` flag from `grep` calls in `Cgrep` to enforce
  case-sensitive searches.
- Restored `incsearch` behavior via `noincsearch` setting.

### Improvements
- Added key mappings for `<leader>f` to copy the current file path
  to the system clipboard using `pbcopy`.
- Added key mapping for `<leader>n` to open the file under the cursor
  in a new buffer.

## 2012-10-17 v0.0.59

## 2012-10-17 v0.0.58

### Features
- Added the `on_change` executable to monitor a file for changes and
  execute a specified command in response.
- Integrated the `ctrlp` plugin to provide fuzzy file, buffer, and
  tag finding capabilities.
- Updated the `rails.vim` plugin to version **1.4.0** or later,
  introducing support for Rails 3.1 features, syntax improvements, and
  new navigation mappings.

### Improvements
- Updated the `tins` dependency requirement from `~>0.5` to `~>0.6` in
  the Rakefile and gemspec.
- Refactored the `probe` utility to extract command lookup logic into
  the `find_cmd` method, simplifying test framework detection.
- Updated the `cecutil` Vim plugin to version **18b**, improving
  window position saving and restoring with local option handling.
- Modified the `rails.vim` plugin to remove deprecation warnings for
  navigation commands and update syntax highlighting groups.
- Added documentation files for the `Decho` and `ctrlp` Vim plugins.
- Adjusted the `rails.vim` plugin to detect Rails projects more
  accurately by ignoring non-standard directories during root path
  resolution.

### Fixes
- Fixed a bug in the `Csymbolhash` Vim function where the regular
  expression did not properly exclude the `=` character in symbol
  detection.
- Resolved an issue in the Ruby syntax highlighting where symbols in
  hash literals (e.g., `{ foo: true }`) were incorrectly matching
  constant names.
- Fixed a conflict between sourcing the Vim configuration and the
  `bufexplorer` plugin by replacing `command` definitions with
  `command!` and enabling incremental search.
- Removed the use of `resolve()` in the `rails.vim` buffer name
  resolution to prevent issues with symbolic links.

### Build & CI
- Added `on_change` to the list of executables in the gemspec.
- Included new `ctrlp` and updated `rails.vim` files in the gemspec
  file list.

## 2012-10-02 v0.0.57

### Improvements
- Loosened the `tins` dependency to allow for broader version
  compatibility.

## 2012-09-28 v0.0.56

### Features
- Added a `-v` verbose flag to `discover` and `search` to display
  diagnostic information during file traversal.
- Implemented `Csymbolhash` function and `Symbolhash` command to
  convert `key: 'value'` to `key: value` format in Vim.
- Upgraded the bundled Vim plugin `fugitive` to version **1.2**.

### Improvements
- Refactored `Utils::Finder` and `Utils::Grepper` to use the verbose
  argument instead of the global `$DEBUG` flag for status output.
- Updated Vim configuration to use `execute` for better portability
  and modernized Vim command definitions.
- Added `Gwq` and `Gvdiff` commands and improved diff handling in
  `fugitive` for merge conflicts.
- Added `fugitive.txt` documentation file for the Vim plugin.

## 2012-09-24 v0.0.55

### Features
- Added a new `create_tags` executable script that generates `ctags` tags
  for Ruby and C source code.
- Added a `-v` verbose flag to the `discover` and `search` commands to
  output debugging information to `STDERR`.

### Improvements
- Modified configuration loading to support a series of default config file
  paths (`/etc/utilsrc`, `~/.utilsrc`, `./.utilsrc`).
- Changed verbose debugging output in `Utils::Finder` and `Utils::Grepper` to
  be controlled by the `-v` command line argument instead of the `$DEBUG`
  global variable.
- Updated `Utils::Irb::MethodWrapper` to display the method owner in the
  description and added support for `arity`, `source_location`, and
  `Comparable` behavior.
- Fixed a bug in `Utils::Irb::WrapperBase` where `to_str` returned the name
  instead of the description.
- Updated the `Ccreatetags` Vim function to execute the new `create_tags`
  script.
- Updated regular expressions in `Utils::Config::ConfigFile` to use `\z`
  instead of `\Z` for end-of-string anchors.

### Build & CI
- Added `create_tags` to the executable list and files list in the gemspec.
- Updated the gemspec file list to include new Vim configuration files.

## 2012-08-28 v0.0.54

### Features
- Added Vim plugin support for CoffeeScript, including syntax
  highlighting, indentation, and a compiler.
- Added Vim syntax highlighting and filetype detection for the Eco
  templating language.
- Added Vim syntax highlighting for CoffeeScript within Haml and
  HTML templates.
- Added documentation for the CoffeeScript Vim plugin.

## 2012-08-27 v0.0.53

### Features
- Support for shortcut syntax `ClassName#method_name` or `ClassName.method_name` when using `edit`, which now resolves to the correct source location using `deep_const_get`.

### Improvements
- Improved `FILE_LINENUMBER_REGEXP` by anchoring it to the start of the string (`\A`).

### Build & CI
- Update `tins` dependency to `~>0.5.3` to support `Tins::DeepConstGet`.

## 2012-08-10 v0.0.52

### Features
- Added Vim configuration for the Slim template language, including
  `ftdetect`, `indent`, and `syntax` files.

## 2012-08-09 v0.0.51

### Build & CI
- Added `.gitignore` to the gemspec `s.files` list.

## 2012-08-09 v0.0.50

### Features
- Add `Createtags` command to `vimrc` to generate Ctags
  for Ruby and C files using `ctags` and `bundle list --paths`.

### Fixes
- Update `probe` to resolve `rspec` or `spec` paths via
  `which` and execute them with `ruby` for compatibility with
  older Ruby versions and RSpec installations.
- Update `probe` to resolve `testrb` via `which` and execute it
  with `ruby` to ensure compatibility with older environments.
- Correct `strip_spaces` to pass the `:suffix` option as a hash
  within the array to `find` for compatibility with older
  Ruby versions.

## 2012-07-12 v0.0.49

### Breaking
- Removed `Utils::Find` module and deleted `lib/utils/find.rb` in favor of the
  external `Tins::Find` dependency.
- Renamed the `pathes` attribute to `paths` in `Utils::Finder` and
  `Utils::Grepper`.

### Improvements
- Standardized directory traversal across `bin/` utilities to use
  `Tins::Find.find`.
- Updated `tins` dependency to `~>0.5.0` in the Rakefile and gemspec.
- Refactored `bin/strip_spaces` and `bin/same_files` to rely on `Tins::Find`
  instead of local utilities.
- Improved robustness in `Utils::Finder` and `Utils::Grepper` by checking
  for `nil` stats before accessing file attributes.
- Removed redundant `rescue SystemCallError` blocks in `Utils::Finder` and
  `Utils::Grepper`.
- Corrected documentation typos, changing "pathes" to "paths" in usage
  messages.

### Build & CI
- Updated the `utils.gemspec` file list to remove references to the deleted
  `lib/utils/find.rb`.
- Bumped the gem version to **0.0.49**.

## 2012-07-05 v0.0.48

### Fixes
- Prevent an infinite retry loop in the file-finding
  utility when the `Errno::EMFILE` error occurs a
  second time.

## 2012-07-05 v0.0.47

### Fixes
- Fix `Errno::EMFILE` errors by consolidating file
  handling logic into `Finder#open_file`.
- Ensure `Finder#open_file` retries opening files after
  closing existing handles if the system limit is reached.
- Remove redundant `EMFILE` retry logic from `File#file`
  and `Dir.entries` blocks.
- Add `Finder#current_open_files` method to track active
  file handles.

### Improvements
- Move file opening and retry logic from `File#file` to
  `Finder#open_file` for better encapsulation.

## 2012-06-05 v0.0.46

### Improvements
- Fixed a typo in the local variable `array_singletion_class` by
  renaming it to `array_singleton_class`.
- Avoided relying on the `Object#singleton_class` method by
  explicitly assigning the singleton class to a local variable.

### Build & CI
- Relaxed the runtime dependency on the `tins` gem by removing the
  specific version constraint.

## 2012-04-27 v0.0.45

### Build & CI
- Updated the `tins` dependency requirement to **~>0.3.14**.
- Updated the `rubygems_version` in the gemspec to **1.8.23**.

## 2012-04-27 v0.0.44

### Fixes
- Fixed argument unpacking for `find` in `Utils::Finder` and
`Utils::Grepper` by concatenating roots and options arrays
before splatting, ensuring correct method invocation.

## 2012-04-25 v0.0.43

### Build & CI
- Updated the minimum `tins` dependency version to `~> 0.3.13`.

## 2012-04-25 v0.0.42

### Fixes
- Changed the `find` invocation in `Utils::Finder#search`
  and `Utils::Grepper#search` to use array splat syntax to
  ensure correct argument passing, resolving a `NoMethodError`
  on Ruby 1.8.

### Improvements
- Added a fallback to the console editor when `TERM` is not
  `xterm` by wrapping GUI-specific remote editing commands in
  `Utils::Editor` with a `gui` check.

## 2012-04-20 v0.0.41

### Features
- Add support for the `:suffix` option to `find` calls in
  `Utils::Finder` and `Utils::Grepper` to filter files by
  extension during search.
- Update `strip_spaces` to accept and pass a list of suffixes via
  the `-I` option for file filtering.

### Fixes
- Correct file handling in `Utils::Find` to explicitly open files in
  binary read mode (`'rb'`) during reopening and initialization.
- Ensure `probe` correctly processes file arguments by extracting
  line numbers before passing them to the command runner.

### Improvements
- Refactor code in `Utils::Finder` and `Utils::Grepper` to use
  hash rocket syntax for keyword arguments to improve Ruby 1.8.x
  compatibility.

## 2012-04-16 v0.0.40

### Features
- Added `-f` option to `search` to list file paths without
  displaying matches.
- Implemented `Utils::Finder::PathExtension#suffix` to
  retrieve the file extension.
- Refactored `Utils::Find` to use a new
  `Utils::Find::ConfigurableFinder` class for file traversal.
- Moved IRB shell enhancements to `lib/utils/irb.rb` and
  required them from `lib/utils/config/irbrc`.
- Added `Utils::FileXt::Concern` to the `Utils::FileXt`
  module.
- Updated `Utils::Editor#source_location` to return an array
  with `filename` and `linenumber` accessors.
- Supported multiple suffixes for `search` and `discover` by
  splitting the `-I` argument on spaces and commas.
- Added Vim abbreviations `I_CLASS`, `I_MODULE`, and
  `I_ENCODE` to the default Vim configuration.

### Fixes
- Updated `chroot-libs` to copy the executable itself into
  the target directory.
- Resolved an issue in `Utils::Editor#vim` where the correct
  Vim binary in the PATH was not always identified.
- Adjusted `probe` to accept multiple file arguments and use
  `system` instead of `exec` for test execution.
- Ensured `Utils::Grepper` and `Utils::Finder` use
  `Utils::Find` methods directly for pruning and finding.
- Updated `search` to convert Ruby regular expressions to
  Vim-flavored patterns for remote editing.
- Improved error messaging in `Utils::Config::ConfigFile` to
  include exception class and message.
- Updated `Utils::Config::ConfigFile#prune?` and `#skip?` to
  cast the basename to a string before matching.

### Improvements
- Updated `Utils::Grepper` to handle file paths using the new
  `suffix` method.
- Changed `Utils::Finder` and `Utils::Grepper` to use
  `path.stat` and `path.lstat` from the `PathExtension`.
- Updated `Utils::IRB::Shell#irb_wrap_methods` to handle
  exceptions during method wrapping.
- Updated `Utils::IRB::Shell#irb_info` to rescue `TypeError`
  when allocating objects.
- Updated `Utils::IRB::Shell#irb_write` to use
  `File.secure_write`.
- Updated `Utils::IRB::String#>>` to use `File.secure_write`.
- Updated `Utils::IRB::Shell#irb_edit` to use
  `$editor.full?`.
- Added `require 'tins/xt'` to `lib/utils/irb.rb`.
- Updated `probe` usage message to reflect multiple file
  support.
- Added `set t_Co=256` to the default Vim configuration.
- Updated `ExtraWhitespace` highlight color in Vim
  configuration.
- Removed trailing spaces from Vim abbreviations in
  `rails.vim`.

### Build & CI
- Updated dependency `dslkit` to require **~>0.2.10**.
- Updated dependency `tins` to require **~>0.3.12**.

### Documentation
- Updated the `TODO` list with new items and removed
  completed tasks.

## 2012-03-01 v0.0.38

### Features
- Added support for opening files in new vim servers via the `-S` flag and
  the `VIM_SERVER` environment variable.
- Added the `slim` view type to the `rails.vim` plugin.
- Added support for hash rocket syntax in `rails.vim` route and render
  detection.
- Added schema file navigation and completion in the `rails.vim` plugin.

### Fixes
- Updated `expand_globs` in `Utils::Editor` to handle opening new files
  that do not yet exist on disk.
- Updated `edit_source_location` in `Utils::Editor` to remove the file
  existence check, allowing new files to be opened.
- Added `~/Applications` to the list of search paths for MacVim on macOS.

### Improvements
- Updated `rails.vim` plugin to version **4.4**.
- Removed deprecated `Rfind` and related commands from `rails.vim`.
- Removed statusline integration from `rails.vim`.
- Added `bundle exec rake` support in `rails.vim` when `bundler_root` is
  defined.
- Added `exctags` support in `rails.vim`.
- Added SCSS and Sass syntax highlighting in `rails.vim`.
- Updated `rails.vim` to use `resolve` for buffer file paths.
- Added support for `app/assets` paths in `rails.vim` style and javascript
  detection.
- Added `rename_index` support in `rails.vim` migration inversion.
- Added `attr_readonly` to `rails.vim` syntax highlighting.
- Added `oracle` adapter support in `rails.vim` dbext settings.

### Build & CI
- Sorted executables and extra_rdoc_files in the gemspec.

## 2012-02-14 v0.0.37

### Fixes
- Guard `colorcolumn` assignment in `vimrc` with an
  `exists` check to support older Vim versions.

## 2012-02-11 v0.0.36

### Fixes
- Only use the GUI editor if a GUI is available
  and waiting is required.

## 2012-02-11 v0.0.35

## 2012-02-11 v0.0.34

### Features
- Implement a general `source_location` for `Utils::Editor` to support
  `file:line` and `method(:foo)` objects in the `edit` command.
- Add a `-h` option to `strip_spaces` to display usage information.

### Fixes
- Guard the `pry-editline` require in `irbrc` to prevent crashing with
  Ruby Enterprise Edition.

## 2012-02-10 v0.0.33

### Improvements
- Added terminal color support to the `flori` colorscheme by including `cterm` and
  `ctermbg` attributes and removing the GUI-only `background` setting.
- Moved the `flori` colorscheme configuration in the `vimrc` so it applies to
  both GUI and terminal environments.
- Added `.AppleDouble` to the `.gitignore` and `Rakefile` ignore patterns to
  exclude macOS metadata files from version control and packaging.

### Fixes
- Prevented the `edit` method in `lib/utils/editor.rb` from expanding
  `file:linenumber` strings when searching for files, ensuring they are passed
  directly to the editor.

## 2012-02-09 v0.0.32

### Features

- Added support for `pry-editline` to enhance IRB input handling and added
  a new `rvmrc` configuration file for RVM defaults.
- Renamed `irb_load_each` to `irb_load!` and improved its logic to skip
  already-loaded files using MD5 checksums.
- Added a `gui` method to `Utils::Editor` to conditionally enable the GUI
  flag based on the `TERM` environment variable.
- Implemented support for Unicode key mappings in Vim for Alt-based
  navigation commands.
- Added `colorcolumn` and `tildeop` settings to the Vim configuration and
  enabled the `darkblue` colorscheme for non-GUI terminals.

### Improvements

- Updated `Utils::Editor` to use `vim` instead of `gvim` on macOS systems
  where the application is not installed, and to compact command arguments
  to handle `nil` values gracefully.
- Modified `Utils::Editor#edit` to expand filename globs before processing.
- Reorganized `module_function` placement within `Utils::MD5` for clarity.
- Removed redundant `set hlsearch` command from the `Cfind` Vim function as
  the setting is now applied globally.

### Build & CI

- Added `pry-editline` as a runtime dependency in the gemspec and Rakefile.
- Updated the `gem_hadar` development dependency to version **~> 0.1.4**.

## 2011-12-19 v0.0.31

### Features
- Added a `classify` command option to toggle between camelcase and
  underscore naming conventions.
- Added a Vim leader command to invoke the new name toggle functionality.

### Improvements
- Reworked `classify` command logic to support new options and better
  handle naming conversions.
- Refactored Vim window and buffer switching shortcuts from `Ctrl` to
  `Alt` combinations.
- Updated Vim command-line navigation key mappings to use lowercase
  control keys.
- Modified `Cdeclassify` to utilize the updated `classify` command
  syntax.
- Bumped `gem_hadar` development dependency to **0.1.4**.

## 2011-12-18 v0.0.30

### Fixes
- Changed the `FileTest` call in `bin/strip_spaces` to correctly
  test the `s` object instead of the `filename` variable.

## 2011-12-18 v0.0.29

### Features
- Add `explain` method to `ActiveRecord::Relation` to
  output the query plan.
- Update `irb_toggle_logging` to use `ActiveRecord::Base.logger`
  for toggling.

### Fixes
- Ensure `strip_spaces` only processes regular files.

### Improvements
- Reorder `executables` and `extra_rdoc_files` in `utils.gemspec`.

### Build & CI
- Relax `gem_hadar` development dependency to **0.1.1**.

## 2011-12-09 v0.0.28

### Fixes
- `strip_spaces` now skips symbolic links to prevent processing
  errors.
- `utils-install-config` uses the fully qualified
  `Utils::Config.install_config` to avoid name conflicts with Ruby's
  built-in `Config` constant.

## 2011-12-05 v0.0.27

### Fixes
- Prevented `NameError` by renaming the local variable
  `user` to `env_user` to avoid overwriting the remote username
  parameter in `bin/sshscreen`.

## 2011-12-05 v0.0.26

### Features
- Added a Vim mapping (`<leader>K`) to convert hash
  rocket syntax (`:foo => bar`) to symbol
  syntax (`foo: bar`) in Ruby files.
- Updated the `sshscreen` command so the session name
  (`-n` option) defaults to the `$USER` environment
  variable if not specified.

### Fixes
- Updated Vim `cnoremap` entries to use uppercase
  control key combinations (e.g., `<C-H>`) to prevent
  conflicts with digraph mode.
- Disabled digraphs in the default Vim configuration to
  prevent interference with typing.

### Improvements
- Added `spec/**` to the default `path` for Ruby files in
  Vim configuration.
- Updated the `sshscreen` help text to document the new
  default behavior for the session name.

## 2011-11-07 v0.0.25

### Features
- Add `-b` flag to `discover` to match binary files.
- Add `default` command to `utils-utilsrc` to output config.
- Add `binary` option to `Utils::Config::ConfigFile`.

### Improvements
- Extract binary file check into `ascii_file?` method.
- Refactor `attempt_match?` to use `ascii_file?` for file checks.
- Remove `.rvmrc` from version control and Rakefile ignore list.
- Update `gem_hadar` development dependency to `~>0.1.1`.

## 2011-10-27 v0.0.24

### Features
- Added a new `utils-utilsrc` command to view, diff, and edit
  `~/.utilsrc`.
- Registered the new `utils-utilsrc` script in the gemspec.

## 2011-10-08 v0.0.23

### Features
- The `probe` executable now supports `rspec` in addition to `test-unit`.
- A new `probe` configuration block is available in `Utils::Config::ConfigFile`, allowing customization of the test framework and include directories.
- The `probe` executable accepts a new `-t` option to select the test framework.

### Fixes
- The `irb_toggle_logging` method now correctly disables logging for Ruby 1.9+ and newer Rails versions by using `Tins::NULL`.
- The `irb_toggle_logging` method is now limited to Ruby versions below 1.9.

### Improvements
- The `vimrc` configuration now uses lowercase keys (`<C-h>`, `<C-l>`, `<C-k>`, `<C-j>`) for command-line navigation mappings.

## 2011-09-25 v0.0.22

## 2011-09-25 v0.0.21

### Breaking
- Replaced the `spruz` gem dependency with `tins`, updating
  corresponding `require` statements and module references
  across `bin` and `lib` directories.

### Features
- Added `enum`, a new utility for generating Cartesian products of
  value ranges and executing commands or printing formatted tuples.
- Added `-i` option to `myex` to force the use of `INSERT IGNORE`
  syntax when processing `INSERT` statements.
- Exposed `pattern` as a reader in `Utils::Grepper` to allow
  accessing the search pattern after execution.

### Fixes
- Updated `bin/search` to use the actual search pattern from
  `Grepper` instead of the raw command-line argument when invoking
  the editor.
- Configured Vimrc to check for `persistent_undo` support before
  setting `undofile` and related options, ensuring compatibility
  with Vim builds lacking this feature.

### Build & CI
- Updated `gem_hadar` development dependency to **~> 0.1.0**.

## 2011-08-31 v0.0.20

### Fixes
- In the `search` command, use `pattern.source` instead of `pattern` when
  sending the remote search command to the editor, ensuring regex metacharacters
  are handled correctly.
- Fix a potential error in `Utils::Editor#edit` by checking that `filenames` is
  not empty before attempting to open files.

### Improvements
- When using the `-e` option with `Utils::Grepper`, break after finding the
  first match in a file to limit output to a single location per file.

## 2011-08-29 v0.0.19

### Features
- Added support for a user-defined configuration file (`~/.utilsrc`) to
  customize file searching, discovery, and trailing space stripping
  behavior.
- Added `dslkit` dependency to enable the configuration file parser.
- Integrated the new configuration file support into the `search`,
  `discover`, and `strip_spaces` commands.
- Added a `-h` flag to `probe` to display usage information and version.
- Added version information to the help output of `search`, `discover`,
  and `edit`.

### Improvements
- Refactored `Finder` and `Grepper` to use `Term::ANSIColor` methods
  directly instead of monkey-patching the `String` class.
- Updated the bundled Vim configuration to enable persistent undo and
  set temporary directories for swap and undo files.
- Added a `TODO` file to track future development tasks.
- Updated gemspec metadata formatting and dependencies.

### Fixes
- Made the `edit` command exit cleanly when receiving an `INT` signal
  instead of raising an unhandled exception.

## 2011-08-26 v0.0.18

### Fixes
- Correctly sort file and line number pairs when using `-L` or `-e`
  options in `Utils::Grepper`.

### Improvements
- Automatically start `vim` in fullscreen mode and remove scrollbars via
  updated `.vimrc` configuration.
- Enhance the `search` utility to automatically execute a search for the
  original pattern in `vim` after opening the target files.
- Provide more verbose feedback for the `Cfind` and `Cgrep` vim functions
  by displaying the actual search arguments.

## 2011-08-17 v0.0.17

### Features
- Add a `probe` command to run specific tests or all
  tests within a file.
- Enhance the `LinesFile` class to support forward matching
  and improved line navigation logic.

### Fixes
- Use `File.secure_write` instead of `File.write` to prevent
  permission errors when creating temporary files.
- Use `File.secure_write` in the `untest` command to ensure
  atomic file replacements.
- Modify the `probe` command to use `exec` instead of
  `system` to properly replace the process.
- Fix `LinesFile` navigation methods to return `nil` when
  moving out of bounds.

### Improvements
- Remove the local `LinesFile` implementation and use the
  `Spruz::LinesFile` class from the `spruz` gem.
- Update `strip_spaces` to expand file paths before processing.
- Enable line numbers in the default Vim configuration.

## 2011-08-10 v0.0.16

### Features
- Add `LinesFile` class to handle line navigation and
  matching in text files.
- Add `probe` script to run specific Ruby tests based on
  filename and line number.

### Fixes
- Fix `strip_spaces` to resolve relative paths to absolute
  paths before processing.

### Improvements
- Update Vim configuration to enable line numbering.

## 2011-08-08 v0.0.15

### Fixes
- `bin/search` now calls `editor.edit` to open files correctly, replacing the previous `editor.edit_linenumber` logic that parsed paths into separate file and line components.

## 2011-08-08 v0.0.14

### Fixes
- Changed `Utils::Edit::Editor` to `Utils::Editor` in `bin/discover` and
`bin/search` to resolve namespace errors.

### Improvements
- Enhanced Vim integration to provide feedback and highlighting during
`Cfind` and `Cgrep` operations.
- Updated `lib/utils/config/vimrc` to manage `grepformat` locally within
`Cfind` and `Cgrep` functions instead of globally.

## 2011-08-08 v0.0.13

## 2011-08-08 v0.0.12

### Breaking
- Renamed the `Editor` class from the `Utils::Edit` module to the top-level
  `Utils::Editor` class, moving the file from `lib/utils/edit.rb` to
  `lib/utils/editor.rb`.
- Refactored the `Utils::Finder#search` method to yield the output to a
  block instead of printing directly to `STDOUT`.

### Features
- Added `-s` option to `bin/edit` to read files and file:linenumbers from
  `STDIN` and open them.
- Added `-h` option to `bin/edit` to display usage information.
- Added a `-p DURATION` option to `bin/edit` to configure the pause duration
  for waiting on Vim's reaction.
- Added a new `bin/foo` executable providing an RBcurses splitpane demo and
  file discovery integration.
- Extended `bin/strip_spaces` to recursively process directories when
  arguments are provided or when executed without arguments, filtering for
  ASCII files.
- Added `irb_edit` functionality to the IRB configuration using the `Editor`
  class directly.

### Fixes
- Corrected line number tracking in `Utils::Grepper` to preserve
  `file.lineno` state when seeking forward for context lines.

### Improvements
- Refactored `bin/edit`, `bin/search`, and `bin/discover` to utilize the
  shared `Utils` library classes, removing duplicated inline logic.
- Updated `Utils::Finder` to support yielding search output and exposed an
  `output` reader attribute.
- Changed match highlighting in `bin/discover` and `Utils::Finder` from
  bold to red text for improved visibility.
- Relaxed `term-ansicolor` dependency from **1.0.5** to `~> 1.0` in the
  `Rakefile` and gemspec.

## 2011-08-01 v0.0.11

## 2011-08-01 v0.0.10

### Fixes
- Sorted the `executables` and `extra_rdoc_files` lists in the
  `utils.gemspec`.

## 2011-07-31 v0.0.9

### Features
- Add `-I SUFFIX` option to `discover` and `search` commands to
  filter files by suffix.

### Fixes
- Fix `ActiveRecord::Base` logging configuration for Rails **3**.

### Improvements
- Replace non-ASCII character in `discover` usage text.

## 2011-07-26 v0.0.8

### Features
- Added a new `strip_spaces` executable that removes trailing
  spaces and tabs from the end of each line in files.

### Fixes
- Corrected a bug in the Rakefile where `executables` was assigned
  to a local variable instead of being passed to the gem, ensuring
  all commands in `bin/` are correctly registered as executables.

### Build & CI
- Updated the `gem_hadar` dependency requirement to `~> **0.0.8**`.
- Updated the `.gitignore` file to exclude `.*.sw[pon]`,
  `Gemfile.lock`, and `pkg`.

## 2011-07-19 v0.0.7

### Fixes
- Corrected the gem installation process to install all Ruby library
  files and executables from the `bin` directory.

### Improvements
- Migrated the build system from `Rake::PackageTask` to `gem_hadar` for
  simplified gemspec generation and packaging.
- Updated the development dependency on `gem_hadar` to `~> 0.0.6`.
- Pinned the runtime dependency on `term-ansicolor` to version `1.0.5`.

### Build & CI
- Added a `Gemfile` to support bundler workflows.
- Added a `COPYING` file containing the GNU General Public License
  version 2 text.

### Documentation
- Added a `README.rdoc` file with project description and licensing
  information.

## 2011-07-17 v0.0.6

### Features
- Ported shell scripts to Ruby, including `chroot-exec`, `git-empty`,
  `sedit`, `unquarantine_apps`, and `vacuum_firefox_sqlite`.
- Added the `path` command to manage `PATH` entries via prefix, postfix,
  and edit modes.
- Added the `edit_wait` command to invoke `edit` in wait mode.
- Added a `Gemfile` and migrated build tasks to `gem_hadar`.

### Fixes
- Corrected the `edit` command to locate the Vim binary properly.
- Fixed the `path` edit subcommand to avoid overwriting the path variable.
- Corrected the required file in `lib/utils.rb` to `utils/file_xt`.

### Improvements
- Updated `classify` to use `camelize` and `underscore` from `spruz`.
- Added GPL v2 license file and updated `README.rdoc`.
- Refined `Rakefile` to use `gem_hadar` for gem packaging.

### Build & CI
- Updated `term-ansicolor` dependency to `1.0.5`.
- Updated `spruz` dependency to `~> 0.2.10`.
- Added `gem_hadar` as a development dependency.
- Updated `.gitignore` to exclude `Gemfile.lock`.

## 2011-05-30 v0.0.0

  * Start
