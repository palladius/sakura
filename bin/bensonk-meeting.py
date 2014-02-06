#!/usr/bin/env python

# Author: Benson K.

from datetime import datetime
import os
from os import path
import subprocess
import sys
import pystache

EDIT=True
VER='0.0.1'
TEMPLATE_FILE = path.join(path.expanduser('~'), 'templates', 'meeting.yml')
OUTPUT_DIR = path.expanduser('~/meetings')


def create_meeting(meeting_title):
  with open(TEMPLATE_FILE) as f:
    template = f.read()
  content = pystache.render(template, {
   'version': VER,
   'comment': 'Created with {} v{}'.format(sys.argv[0], VER),
   'meeting_title': meeting_title,
   'whoami': os.getlogin(),
   'now': datetime.now()})
  outfile = path.join(OUTPUT_DIR, '{}.yml'.format(meeting_title))
  with open(outfile, 'w') as f:
    f.write(content)
  print '# Created meeting: {}'.format(outfile)
  if EDIT and 'EDITOR' in os.environ:
    subprocess.check_call([os.environ['EDITOR'], outfile])


if __name__ == '__main__':
  if len(sys.argv) >= 1:
    meeting_title = ' '.join(sys.argv[1:])
    create_meeting(meeting_title)
  else:
    print 'usage: {} <meeting-title>'.format(sys.argv[0])

