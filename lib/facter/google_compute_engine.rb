
# Riccardo Carlesso
# So far, it checks this one: /usr/share/google/safe_format_and_mount
# Methods to catch that:
# 1. Existence of some fils.
# 2. /etc/resolv.,conf should match this:
#    domain c.$PROJECTNAME.google.com.internal.
#    nameserver 169.254.169.254
#

Facter.add("is_google_vm") do
  setcode do
    File.exists? '/usr/share/google/safe_format_and_mount'
    # File.exists? '/usr/share/google/safe_format_and_mount' and `cat /etc/resolv.conf`.split("\n").include?('nameserver 169.254.169.254')
  end
end

# if the first line contains this:
# """domain c.discoproject.google.com.internal."""
Facter.add("project_name") do
  setcode do
    `cat /etc/resolv.conf`.split("\n")[0].split('.')[1]
  end
end

Facter.add("project_id") do
  setcode do
    `curl 'http://metadata/0.1/meta-data/project-id'`
  end
end

Facter.add("project_number") do
  setcode do
    `curl 'http://metadata/0.1/meta-data/numeric-project-id'`
  end
end

