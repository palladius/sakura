
#import pip
import os
import time
import pkg_resources, os, time

import pkg_resources, os, time

for package in pkg_resources.working_set:
    print("%s: %s" % (package, time.ctime(os.path.getctime(package.location))))
