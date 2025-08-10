# 📦 Utils - Developer Productivity Command-Line Utilities

## 📝 Description

This Ruby gem delivers a curated collection of command-line utilities designed
to streamline software development workflows and automate repetitive tasks. The
toolkit spans multiple domains including code analysis, testing automation,
file manipulation, and system administration.

### Key Features

- **Ruby-Centric Approach**: Built leveraging Ruby's expressive syntax,
  metaprogramming capabilities, and dynamic nature
- **Multi-Functional Tools**: From simple CLI interfaces to sophisticated
  automation workflows
- **Modern Integration**: Seamlessly integrates with popular development
  frameworks, external services (including LLMs via Ollama), and system tools
- **Modular Architecture**: Lightweight design allowing selective tool usage
  without heavy dependencies
- **Composability**: Tools designed to work together or independently

### Technical Approach

The utilities embrace Ruby's strengths through:
- Dynamic method dispatch and metaprogramming techniques
- Expressive DSLs for configuration and tool definition
- Seamless integration with Git, vim, SSH, and terminal multiplexers
- Performance-conscious design with pattern matching for pruning operations

## 🛠️ Installation

Add this gem to your Gemfile:

```ruby
gem 'utils'
```

And install it using Bundler:

```bash
bundle install
```

Or install the gem directly:

```bash
gem install utils
```

## 🧰 Utilities

### 🔍 Searching

- **`blameline`** - Show git blame line for a file and line number
- **`create_cstags`** - Create cscope tags file for current directory
- **`create_tags`** - Create ctags tags file for current directory  
- **`discover`** - Find files with specific content patterns
- **`git-versions`** - Show git versions of files and directories
- **`long_lines`** - Finds long lines with author attribution
- **`search`** - Search for text in files recursively

### ✍️ Editing

- **`classify`** - Classify files by type using file command
- **`edit_wait`** - Edit a file and wait for changes to be saved
- **`edit`** - Edit a file using default editor
- **`print_method`** - Extracts complete method definitions from Ruby source
  files
- **`sedit`** - Edit a file with sed commands
- **`strip_spaces`** - Removes trailing whitespace with tab conversion options
- **`sync_dir`** - Sync directories with rsync
- **`untest`** - Remove test files from current directory

### 🧪 Testing

- **`json_check`** - Validate JSON syntax in files
- **`on_change`** - Monitors files for changes and executes commands
- **`probe`** - Test runner supporting RSpec, Test::Unit, Cucumber with
  server/client functionality
- **`yaml_check`** - Validate YAML syntax in files

### 📚 Documenting

- **`changes`** - Generate changelogs using Git history and LLM summaries
- **`code_comment`** - Generates YARD documentation using LLM assistance
- **`commit_message`** - Generate commit messages via LLM from git diff
- **`rd2md`** - Convert RDoc to Markdown

### ⚙️ Configuring

- **`git-empty`** - Create empty git repository with default files
- **`myex`** - Processes MySQL dump files (list, create, truncate, insert,
  search)
- **`path`** - Show or modify PATH environment variable
- **`utils-utilsrc`** - Manages `~/.utilsrc` configuration file with
  show/diff/edit capabilities
- **`vcf2alias`** - Converts VCard contacts to Mutt email aliases

### 🌐 Networking

- **`serve`** - Simple HTTP server launcher
- **`ssh-tunnel`** - Create SSH tunnel to remote host

### 🎨 Slacking

- **`ascii7`** - Generate ASCII art from text
- **`enum`** - Enumerate files and directories with line counts
- **`rainbow`** - Display rainbow-colored banner text

## ⚙️ Configuration

The `~/.utilsrc` configuration file uses Ruby syntax to define settings for
various utility components. This file allows you to customize the behavior of
different utilities without modifying their source code.

Each configuration block corresponds to a specific utility or category of
utilities. The settings within each block control how those utilities behave
during execution. The configuration system supports:

- **Pattern matching**: Regular expressions for including/excluding files and
  directories
- **Performance optimization**: Caching mechanisms and pruning rules to avoid
  unnecessary processing
- **Integration capabilities**: Settings for connecting with external tools
  like SSH, vim, and terminal multiplexers
- **Environment customization**: Ability to set environment variables and
  default paths

The configuration is loaded at runtime and can be modified without requiring a
restart of the utilities. Changes take effect immediately for subsequent
operations.

⚠️ **Important Note**: Since this is Ruby syntax, you have access to full Ruby
capabilities within the configuration blocks. You can use variables, methods,
conditional logic, and other Ruby features to create dynamic configurations
when needed.

```ruby
# vim: set ft=ruby:

# ~/.utilsrc - Utility configuration file
# This file contains configuration settings for various utility components

## Search Configuration
search do
  # Directories to prune during search operations
  # These are excluded from the search scope to improve performance
  prune_dirs /\A(\.svn|\.git|\.terraform|CVS|tmp|coverage|corpus|pkg|\.yardoc)\z/
  
  # Files to skip during search operations
  # Excludes temporary files, log files, and system files
  skip_files /(\A\.|\.sw[pon]\z|\.(log|fnm|jpg|jpeg|png|pdf|svg)\z|\Atags\z|~\z)/i
end

## Discovery Configuration
discover do
  # Directories to prune during discovery operations
  # Excludes version control systems, temporary directories, and build artifacts
  prune_dirs /\A(\.svn|\.git|\.terraform|\.yardoc|CVS|tmp|coverage|corpus|pkg|\.yardoc)\z/
  
  # Files to skip during discovery operations
  # Excludes hidden files, swap files, and log files
  skip_files /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
  
  # Cache index expiration time in seconds (1 hour = 3600 seconds)
  index_expire_after 3_600

  # Maximum number of matches to return (0 = no limit)
  # Prevents overwhelming output when many files match the search criteria
  max_matches 10
end

## Space Stripping Configuration
strip_spaces do
  # Directories to prune during space stripping operations
  # Excludes hidden directories and system directories
  prune_dirs /\A(\..*|CVS|pkg|\.yardoc)\z/
  
  # Files to skip during space stripping operations
  # Excludes hidden files, swap files, and log files
  skip_files /(\A\.|\.sw[pon]\z|\.log\z|~\z)/
end

## Probe Configuration
probe do
  # Test framework to use for probing
  test_framework :'test-unit'
  
  # Directories to include in probe operations
  # Specifies where to look for test files and source code
  include_dirs %w[lib test tests ext spec]
end

## SSH Tunnel Configuration
ssh_tunnel do
  # Terminal multiplexer to use (supports :tmux or other terminal managers)
  terminal_multiplexer :tmux
  
  # Login session path for SSH connections
  login_session "/home/#{ENV['USER']}"
  
  # Environment variables to set for the tunnel
  env(
    FOO: 'test'  # Example environment variable - adjust as needed
  )
  
  # Enable or disable copy/paste functionality
  copy_paste true do
    # Bind address for the tunnel
    bind_address 'localhost'
    
    # Port number for the tunnel
    port 6166
    
    # Host for the tunnel
    host 'localhost'
    
    # Host port for the tunnel
    host_port 6166
  end
end

## Classification Configuration
classify do
  # Default path shifting value (1 = shift by one directory level)
  shift_path_by_default 1
  
  # Path prefixes to check in order for classification
  # Used to determine how paths should be shifted or categorized
  shift_path_for_prefix [ # prefixes checked in order
    'a/b',
    'c/d/e',
  ]
end

## Sync Directory Configuration
sync_dir do
  # Paths to skip during sync operations
  # Uses regex pattern to exclude certain directory patterns
  skip_path %r((\A|/)\.\w)
end

## Edit Configuration
edit do
  # Path to vim executable
  # Uses shell command to find vim in PATH
  vim_path `which vim`.chomp
  
  # Default arguments for vim (nil = no default args)
  vim_default_args nil
end
```

## 👨‍💻 Author

[Florian Frank](mailto:flori@ping.de)

## 📄 License

GPLv2 [LICENSE](./LICENSE)
