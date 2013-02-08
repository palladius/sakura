
Welcome to MiniCook
-------------------

Welcoem to MiniCook, a small/agile version of Chef/Puppet-like Config Management systems.


Ideas
=====

A recipe should give you a way to install code, and test the code.
As simple as that. It should have prerequisites, and post-requisites (test for correct installation).
It should also have a means to uninstall it CLEANLY. swho better than the installer knows how to uninstall?

Install
=======

This requires facter

 $ sudo gem install facter
 $ git clone https://github.com/palladius/sakura/
 $ sakura/bin/minicook list
 $ sakura/bin/minicook apply puppet3

TODO
----

Implement the system which USES these recipes :)

