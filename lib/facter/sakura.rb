# Author: Riccardo Carlesso

Facter.add("sakura") do
  setcode do
    'esiste, esiste!'
  end
end

# We should be 2 paths down from root
Facter.add("sakura_ver") do
  setcode do
    `cat ../../VERSION`
  end
end

# Experimental
Facter.add("sakura_dir") do
  setcode do
    `cd ../../ ; pwd`
  end
end
