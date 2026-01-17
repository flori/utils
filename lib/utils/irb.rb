require 'irb/completion'
require 'enumerator'
require 'tempfile'
require 'pp'
require 'shellwords'
require 'utils'
require 'fileutils'
require 'amatch'
require 'search_ui'
require 'logger'
require_maybe 'ap'

$editor = Utils::Editor.new
$pager = ENV['PAGER'] || 'less -r'

module Utils
  # A module that extends Ruby's core classes with additional utility methods
  # for interactive development.
  #
  # Provides enhanced functionality for IRB sessions through method extensions
  # on Object, String, and Regexp classes. Includes features like improved
  # pattern matching, shell command integration, file I/O operations,
  # performance measurement tools, and developer productivity enhancements.
  module IRB
    # The configure method sets up IRB configuration options.
    #
    # This method configures the IRB environment by setting the history save
    # limit and customizing the prompt display when IRB is running in
    # interactive mode.
    def self.configure
      ::IRB.conf[:SAVE_HISTORY] = 1000
      if ::IRB.conf[:PROMPT]
        ::IRB.conf[:PROMPT][:CUSTOM] = {
          :PROMPT_I =>  ">> ",
          :PROMPT_N =>  ">> ",
          :PROMPT_S =>  "%l> ",
          :PROMPT_C =>  "+> ",
          :RETURN   =>  " # => %s\n"
        }
        ::IRB.conf[:PROMPT_MODE] = :CUSTOM
      end
    end
  end
end

require 'utils/irb/shell'
require 'utils/irb/regexp'
require 'utils/irb/string'
require 'utils/irb/irb_server'

Utils::IRB.configure

class String
  include Utils::IRB::String
end

class Object
  include Utils::IRB::Shell
end

class Regexp
  include Utils::IRB::Regexp
end
