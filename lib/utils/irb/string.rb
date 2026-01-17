# A module that extends String with additional utility methods for shell
# command piping and file writing operations.
#
# Provides convenient methods for executing shell commands on string
# content and securely writing strings to files.
module Utils::IRB::String
  # The | method executes a shell command and returns its output.
  #
  # This method takes a command string, pipes the current string to it via
  # stdin, captures the command's stdout, and returns the resulting output
  # as a string.
  #
  # @param cmd [ String ] the shell command to execute
  #
  # @return [ String ] the output of the executed command
  def |(cmd)
    IO.popen(cmd, 'w+') do |f|
      f.write self
      f.close_write
      return f.read
    end
  end

  # The >> method writes the string content to a file securely.
  #
  # This method takes a filename and uses File.secure_write to write the
  # string's content to that file, ensuring secure file handling practices
  # are followed.
  #
  # @param filename [ String ] the path to the file where the string content will be written
  #
  # @return [ Integer ] the number of bytes written to the file
  def >>(filename)
    File.secure_write(filename, self)
  end
end
