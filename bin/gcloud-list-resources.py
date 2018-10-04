#!/usr/bin/python

import os,sys
from optparse import OptionParser
from subprocess import call
import subprocess


gcloud_list_commands = [
  "compute instances list",
  "sql instances list",
  "deployment-manager deployments list",
  "container clusters list",
  "dataflow jobs list",
  "dataproc clusters list",
  "dns managed-zones list",
  "functions list",
  "services list",
  "pubsub topics list",
  "spanner instances list",
  #"alpha billing accounts list",
]

projects = None
verbose = None

def print_gcloud_list_for(projects, commands):
	"""Given an array of projects calls a number of commands."""

	for p in projects:
		opt = "gcloud --project={} ".format(p)
		for cmd in commands:
#			print "{}|\t{}".format(p, call("echo ciao da me".split(" ")))			
			#print "{}|\t{}".format(p, opt+cmd)
			#print "{}|\t{}".format(p, call("echo {} {}".format(opt, cmd).split(" ")))			
			#print "{}|\t{}".format(p, os.system("echo some_command with args"))			
			#output = subprocess.Popen("echo Hello World", shell=True, stdout=subprocess.PIPE).stdout.read() # it works
			output = subprocess.Popen("{} {} ; echo ".format(opt, cmd), shell=True, stdout=subprocess.PIPE).stdout.read()
			print "----------- {} --------------------\n".format(cmd)
			print "{}|\t{}".format(p, output)
			print "-------------------------------\n"


def main():
	parser = OptionParser()
	parser.add_option("-p", "--projects", dest="projects",
	                  help="comma-separated project list")
	parser.add_option("-q", "--quiet",
	                  action="store_false", dest="verbose", default=True,
	                  help="don't print status messages to stdout")
	parser.add_option("-c", "--commands",
	                  #dest="commands", 
	                  default=gcloud_list_commands,
	                  help="comma-sep list of commands")


	(options, args) = parser.parse_args()

	if options.verbose:
		print "Options: ", options
		print "Options[commands]: ", options.commands
		print "Args: ", args
		print "Projects: ", options.projects
	if options.projects:
		print_gcloud_list_for(options.projects.split(','), options.commands)
	else:
		parser.print_help()


if __name__ == "__main__":
	main()