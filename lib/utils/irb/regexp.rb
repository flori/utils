# A module that extends Regexp functionality with additional pattern
# matching and display capabilities.
#
# Provides enhanced regexp operations including match highlighting and
# shell command integration.
#
# @example
#   /pattern/ # => regular expression object
#   /pattern/.show_match("text") # => highlighted text match
module Utils::IRB::Regexp
  # The show_match method evaluates a string against the receiver pattern
  # and highlights matching portions.
  #
  # This method tests whether the provided string matches the pattern
  # represented by the receiver. When a match is found, it applies the
  # success proc to highlight the matched portion of the string. If no
  # match is found, it applies the failure proc to indicate that no match
  # was found.
  #
  # @param string [ String ] the string to be tested against the pattern
  # @param success [ Proc ] a proc that processes the matched portion of the string
  # @param failure [ Proc ] a proc that processes the "no match" indication
  #
  # @return [ String ] the formatted string with matched portions highlighted or a no match message
  def show_match(
    string,
    success: -> s { Term::ANSIColor.green { s } },
    failure: -> s { Term::ANSIColor.red { s } }
  )
    string =~ self ? "#{$`}#{success.($&)}#{$'}" : failure.("no match")
  end
end
