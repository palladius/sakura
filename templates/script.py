#!/usr/bin/python2.7

import os, getopt, sys
from stat import *

SCRIPT_TEMPLATE_VER = 0.3

VER = 0.1
dryrun = Debug = Verbose = False
myfile = None
ExpectedArgs = [ '<FOO>', '<BAR>' ]

USAGE_SCRIPT = """Usage: {script} [-dhnv] [-f file] <FOO> <BAR>
  -d|--debug:   enable debug (default: FALSE)
  -f|--file:    define file for script (default: None)
  -h|--help:    print help msg and exits
  -n|--dryrun:  enable dryrun (default: FALSE)
"""

def usage():
  print(USAGE_SCRIPT.format(
    script=sys.argv[0],
    ))


def myinit(args):
  '''Process ARGV.

  Copied from https://docs.python.org/3.1/library/getopt.html
  '''
  global Verbose, Dryrun, Debug, myfile, ExpectedArgs
  options, remainder = getopt.getopt(sys.argv[1:], 
    'dhf:n:v', [
      'debug',
      'dryrun',
      'dry-run',
      'file=',
      'output=', 
      #'verbose',
      'version=',
    ])
  for o, a in options:
        if o in ("-v", "--verbose"):          
            Verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit(0)
        elif o in ("-d", "--debug"):
            Debug = True
        elif o in ("-n", "--dryrun", "--dry-run"):
            dryrun = True
        elif o in ("-f", "--file"):
            myfile = a
            deb("MyFile: {}".format(myfile))
        else:
            assert False, "Unrecognized option ('{option}')".format(option=o)
  deb("INIT Options: ", options)
  deb("INIT Remainder: ", remainder)
  deb("INIT verbose: ", Verbose)
  deb('lets see if manuel is', 'right')
  print "Number of non-option args: {argz}".format(argz=len(remainder))
  # testing args equals len(ExpectedArgs)
  if len(remainder) <> len(ExpectedArgs):
    print "Sorry, the args you gave me ({yourargs}) doesnt match the expected args ({expectedargs}).".format(
      yourargs=len(remainder),
      expectedargs=len(ExpectedArgs))
    print "+ Provided args: {}".format(remainder)
    print "+ Expected args: {}".format(ExpectedArgs)
    exit (11)

def deb(*args):
  '''if debug is True, then calls print. Otherwise its mute.'''
  global Debug
  if Debug:
    print("[DeB]", args)
  

def myprogram(args):
    '''recursively descend the directory tree rooted at top,
       calling the callback function for each regular file.
    '''
    myinit(args)
    print("Welcome to this test program.")
    print("Please add me with: 'git add {thisfile}'".format(thisfile=sys.argv[0]))
    print("\nFiles in current dir: '{}'".format(os.getcwd()))
    for f in os.listdir('.'):
      print "-", f


def the_program(foo,bar):
  '''This is my foo application, called by main.'''
  meeting_title = ' :: '.join(foo,bar)
  print("Meeting title: {}".format(meeting_title))


if __name__ == '__main__':
   deb("ARGV: %d" % len(sys.argv))
   if Verbose:
      print "ARGV: ", sys.argv
   myprogram(sys.argv)

   #if len(sys.argv) > 1:
   #  the_program(foo,bar)
   #else:
   #  print 'Usage: {} <foo> <bar>'.format(sys.argv[0])
else:
  print '''You are calling program '{}' without main. Maybe you are importing it,
  furbetto? ;)

  PS argv[0] here is null because, well, you didnt call it normally.'''.format(sys.argv[0])
