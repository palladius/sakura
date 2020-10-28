#!/usr/bin/python

import glob
import os
import sys
import subprocess
from optparse import OptionParser

version = '1.3'
DEFAULT_DIR = "$HOME/git/"	
default_git_basedir = os.path.expandvars(DEFAULT_DIR)
debug = False
valid_commands = [ 'list', 'dump', 'pull-all', 'push-all', 'help' ]


def deb(*args):
  if (debug):
    print "#DEB", ' '.join(arg.__str__() for arg in args)

def repos_foreach_execute(mybasedir,dump_basedir,cmd):
    """ForEach REPO, do: 
            run(cmd)
    
    For the moment i only support git pull
    """
    print "repos_foreach_execute(..,..,{})".format(cmd)
    #print "Repos: ", gitrepos(mybasedir)
    for ix, repo in enumerate(gitrepos(mybasedir)):
      #cmd2run = "echo git pull {repo}".format(repo=repo)
      # This works: git --git-dir $GIC/.git pull
      cmdArr = ['git', '--git-dir', "{}/.git/".format(repo) , 'pull' ]
      try:
          retLong = subprocess.check_output(cmdArr) # , shell=True
          ret = "[OK] " + repo 
      except subprocess.CalledProcessError as e:
          ret = "[ERR] {}: {}".format(repo, e)
          retLong = "[ERR] Non zero return for: {}: {}".format(repo, e)
      print "ret: {}".format(ret)
      #print retLong

def parse_python_26():
	'''There's a better parser with python2.7 but that's what I have in 2.6..'''
	parser = OptionParser(usage = """Usage: %prog v{version} [Options] <COMMAND>
COMMAND: {valid_commands}

Examples:
  %prog list --gitdir ~/Desktop/myrepos/                  # lists all git repos (shortened)
  %prog list -l false                                     # lists full path
  %prog dump --dumpdir ~/Dropbox/dump/of/my/repos/        # dumps a command to clone those repos all at once!
  %prog dump --dumpdir ~/Dropbox/tmp/myreposbackups/ | sh # executes it ;)

Default Dir: {DEFAULT_DIR}

""".format(valid_commands=valid_commands,version=version,DEFAULT_DIR=DEFAULT_DIR))
	parser.add_option("-d", "--dumpdir", dest="dumpdir", default=default_git_basedir,
	  help="alternate dump dir (default: '{}')".format(default_git_basedir), metavar="DIR")
	parser.add_option("-g", "--gitdir", dest="gitdir", default=default_git_basedir,
	  help="changes git basedir (default: '{}')".format(default_git_basedir), metavar="DIR")
	parser.add_option("-q", "--quiet",
		  action="store_false", dest="verbose", default=True,
		  help="don't print status messages to stdout")
	parser.add_option("-l", "--long", dest="long", default=False,
		  help="longer output (default 'False')")
	parser.add_option("-v", "--version",
		  help="prints version (which peraltro is '{}')".format(version))
	(options, args) = parser.parse_args()
	if len(args) != 1:
	   parser.error("wrong number of arguments: I want one (for hour). Valid_commands={}".format(valid_commands))
	if(args[0] not in valid_commands):
		parser.error("Wrong command: '{}'. Available are: {}".format(
                     args[0],
                     valid_commands 
                     ))
        #exit(9)
	return (parser,options,args)

def dumprepos(mybasedir,dump_basedir):
	'''Prints adump of all your repo in such a way that you can reconstruct them: cool!'''
	
	from subprocess import Popen,PIPE
	deb( "Dumping to STDOUT your local Git Repos within {0} (dumpdir='{1}'):".format(mybasedir,dump_basedir))
	dump = ''
	for repo in gitrepos(mybasedir):
		url_cmd = 'git config --get remote.origin.url'
		p = Popen([url_cmd], cwd = repo, stdout=PIPE,shell=True, env = {'PATH': '/usr/local/bin/'}) # .wait() #stdout.read()
		out,err=p.communicate()
		url = out.strip() # trailing CRLF
		if err or len(url) < 10:
			sys.stderr.write( "Skipping '{0}': ERR={1} URL='{2}'\n".format(repo,err,url) )
		else:
			desturl= repo
			dump += "git clone '{0}' '{1}'\n".format(url,desturl.replace(mybasedir,dump_basedir))
	return dump

def remove_prefix(text, prefix):
    if text.startswith(prefix):
        return text[len(prefix):]
    return text

def print_list_repos(git_dir, is_long):
	deb( "Listing your local Git Repos:")
	for repo in gitrepos(git_dir):
		if is_long:
			print repo
		else:
			# strip git_dir from repo
			shortened_repo = remove_prefix(repo, git_dir).rstrip('/')
			deb("{} {}\t{}".format(git_dir, repo, shortened_repo))
			print "{}".format(shortened_repo)

def main():
	(parser,opts, args) = parse_python_26()
	if args[0] == 'list':
		print_list_repos(opts.gitdir, opts.long)
	elif args[0] == 'dump':
		print dumprepos(opts.gitdir,opts.dumpdir)
	elif args[0] == 'pull-all':
		repos_foreach_execute(opts.gitdir,opts.dumpdir,"git pull")
	elif args[0] == 'push-all':
		repos_foreach_execute(opts.gitdir,opts.dumpdir,"git push")
	elif args[0] == 'help':
		#print dir(parser)
		print parser.format_help()
		#parser.print_usage()
	else:
		print "Unrecognized command: {}".format(args[0])
		exit(1)
	exit(0)

def isGitRepo(dir):
	'''Dice se la sottodir ha un ./.git/ e magari altre cose..'''
	return os.path.isdir("{}/.git/".format(dir))

def gitrepos(basedir):
	'''Dice i repo che sono sotto ~/git/DIR o  ~/git/DIR1/DIR2. Li riconosce dalla dir .git'''
	repos = []
	GITGLOB = '.git/'
	os.chdir(basedir)
	for files in glob.glob('*/{}'.format(GITGLOB)) + glob.glob("*/*/{}".format(GITGLOB)):
		repodir = (basedir + files.__str__())[:-len(GITGLOB)] #  removes "/.git/"
		if isGitRepo(repodir):
			repos.append(repodir)
	return repos

if __name__ == '__main__':
  main()
else:
    print 'Bella Ric! Prova ad usare: gitrepos(), o main()!'
