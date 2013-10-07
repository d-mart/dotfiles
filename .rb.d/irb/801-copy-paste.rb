if RUBY_PLATFORM.include? "darwin"
  # Copy to OS X clipboard
  def copy(str)
    IO.popen('pbcopy', 'w') { |f| f << str.to_s }
    $?.exited?
  end

  # Paste from OS X clipboard
  def paste
    `pbpaste`
  end
end
