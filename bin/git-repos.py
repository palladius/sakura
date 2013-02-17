#!/usr/bin/python

import glob
import os
import sys
import subprocess
default_git_basedir = os.path.expandvars("$HOME/git/")

valid_commands = [ 'list', 'dump','help']
debug = False
version = '1.1'

def deb(*args):
	if (debug):
		print "#DEB", ' '.join(arg.__str__() for arg in args)

def parse_python_26():
	from optparse import OptionParser
	parser = OptionParser(usage = """Usage: %prog v{1} [Options] <COMMAND>
COMMAND: {0}

Examples:
  %prog list --gitdir ~/Desktop/myrepos/                  # lists all git repos in it
  %prog dump --dumpdir ~/Dropbox/dump/of/my/repos/        # dumps a command to clone those repos all at once!
  %prog dump --dumpdir ~/Dropbox/tmp/myreposbackups/ | sh # executes it ;)

""".format(valid_commands,version))
	parser.add_option("-d", "--dumpdir", dest="dumpdir", default=default_git_basedir,
	  help="alternate dump dir (default: '{0}')".format(default_git_basedir), metavar="DIR")
	parser.add_option("-g", "--gitdir", dest="gitdir", default=default_git_basedir,
	  help="changes git basedir (default: '{0}')".format(default_git_basedir), metavar="DIR")
	parser.add_option("-q", "--quiet",
		  action="store_false", dest="verbose", default=True,
		  help="don't print status messages to stdout")
	parser.add_option("-v", "--version",
		  help="prints version (which peraltro is '{0}')".format(version))
	(options, args) = parser.parse_args()
	if len(args) != 1:
	   parser.error("wrong number of arguments: valid_commands={0}".format(valid_commands))
	if(args[0] not in valid_commands):
		parser.error("wrong command: {0}. available:{ 1}".format(args[1], valid_commands))
	return (parser,options,args)

def dumprepos(mybasedir,dump_basedir):
	'''Prints adump of all your repo in such a way that you can reconstruct them: cool!'''
	deb( "Dumping to STDOUT your local Git Repos within {0} (dumpdir='{1}'):".format(mybasedir,dump_basedir))
	dump = ''
	from subprocess import Popen,PIPE
	for repo in gitrepos(mybasedir):
		url_cmd = 'git config --get remote.origin.url'
		p = Popen([url_cmd], cwd = repo, stdout=PIPE,shell=True, env = {'PATH': '/usr/local/bin/'}) # .wait() #stdout.read()
		out,err=p.communicate()
		url = out.strip() # trailing CRLF
		if err or len(url) < 10:
			sys.stderr.write( "Skipping '{0}': ERR={1} URL='{2}'\n".format(repo,err,url) )
		else:
			desturl= repo
			#dump += "git clone '{0}' '{1}'\n".format(url,desturl)
			#dump += "git clone '{0}' '{1}'\n".format(url,mybasedir)
			#dump += "git clone '{0}' '{1}'\n".format(url,dump_basedir)
			dump += "git clone '{0}' '{1}'\n".format(url,desturl.replace(mybasedir,dump_basedir))
	return dump

def main():
	(parser,opts, args) = parse_python_26()
	if args[0] == 'list':
	  deb( "Listing your local Git Repos:")
	  for repo in gitrepos(opts.gitdir):
	    print repo
	elif args[0] == 'dump':
		print dumprepos(opts.gitdir,opts.dumpdir)
	elif args[0] == 'help':
		#print dir(parser)
		print parser.format_help()
		#parser.print_usage()
	else:
		print "Unrecognized command: {0}".format(args[0])
		exit(1)
	exit(0)

def isGitRepo(dir):
	'''Dice se la sottodir ha un ./.git/ e magari altre cose..'''
	return os.path.isdir("{0}/.git/".format(dir))

def gitrepos(basedir):
	'''Dice i repo che sono sotto ~/git/DIR o  ~/git/DIR1/DIR2. Li riconosce dalla dir .git'''
	repos = []
	GITGLOB = '.git/'
	os.chdir(basedir)
	for files in glob.glob('*/{0}'.format(GITGLOB)) + glob.glob("*/*/{0}".format(GITGLOB)):
		repodir = (basedir + files.__str__())[:-len(GITGLOB)] #  removes "/.git/"
		if isGitRepo(repodir):
			repos.append(repodir)
	return repos

if __name__ == '__main__':
  main()
else:
    print 'Bella Ric! Prova ad usare: gitrepos(), o main()!'
