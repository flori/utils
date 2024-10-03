require 'ollama'

module Utils
  module Markdown
    module_function

    def markdown(message)
      Ollama::Utils::ANSIMarkdown.parse(message)
    end
  end
end
