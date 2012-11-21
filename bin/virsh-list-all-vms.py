#!/usr/bin/python

"""Gives you a list of all VMs (provided you installed virt-manager)."""

# TODO(ricc) sudo apt-get install virt-manager virtualbox
# import pprint
# import ipdb
import libvirt

# MAIN()
print "*" * 80
print "Listing active servers (you better off with sudo virsh list --all):"
print "*" * 80
for url in ["qemu:///system", "vbox:///session"]:
  print "== %s ==" % url
  conn = libvirt.open(url)
  if conn:
    for my_id in conn.listDomainsID():
      dom = conn.lookupByID(my_id)
      # infos = libvirt.virDomainGetInfo(dom)
      print my_id, dom.name()
