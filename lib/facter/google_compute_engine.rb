
# Riccardo Carlesso
# So far, iot checks this one: /usr/share/google/safe_format_and_mount

Facter.add("is_google_vm") do
  setcode do
    File.exists? '/usr/share/google/safe_format_and_mount'
  end
end

