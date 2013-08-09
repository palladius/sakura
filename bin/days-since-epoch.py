#!/usr/bin/python

import datetime
epoch = datetime.datetime.utcfromtimestamp(0)
print "Epoch: ", epoch
#1970-01-01 00:00:00
today = datetime.datetime.today()
d = today - epoch
print "Today: ", d
#13196 days, 9:50:44.266200
print "Delta: ", d.days # timedelta object
#13196

