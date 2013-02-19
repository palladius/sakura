#!/usr/bin/python2.7 

from gcelib import gce
from gcelib import gce_util
from gcelib import shortcuts

# for python inspect()
from pprint import pprint 

# Inspired from:
#  https://developers.google.com/compute/docs/gcelib/using

def getMetadata(project,key):
  ret = '_UNKNOWN_'
  for x in project.commonInstanceMetadata.items:
    v,k = x.value, x.key
    if k == 'sshKeys':
      ret = v
  return ret

def main():
  '''Uses gcelib (now deprecated) to get instance names and quotas for your project
  '''
  # Performs oauth2 authentication. You must be authenticated
  # before you can access and modify your resurces.
  # get_credentials() does all the hard work.
  credentials = gce_util.get_credentials()

  # Constructs a new GoogleComputeEngine object with the
  # given defaults (in this case, the object corresponds
  # to the latest version of the API).
  api = gce.get_api(
      credentials,
			default_project='google.com:sakura',  # Change this to your project's name.
      default_zone='us-central1-a',  # Or some other zone.
      default_image='projects/google/images/gcel-12-04-v20121106',
      default_machine_type='n1-standard-1')

  # Place future code here to follow along with the examples.
  p = api.get_project()
  #my_new_instance = api.insert_instance(my_instance, name='my-new-instance-with-network', networkInterfaces=shortcuts.network())

  print "= Project: '{}' =".format(p.name)
  print "Description: '''{}'''".format(p.description)
  print "Id: {} # Not the project_id unfortunately!".format(p.id)
  print "Ext IPs: [{}]".format(','.join(p.externalIpAddresses))
  ssh_keys = getMetadata(p,'sshKeys')
  print "SSH Keys: {}".format(ssh_keys.splitlines().__len__())

  #pprint(p, depth=2)

  print "Instances: "
  for instance in api.all_instances():
    print " - {}\t# {}".format(instance.name,instance.description)

  print 'Usage/quotas:'
  for q in p.quotas:
    print " {}:\t{}/{}".format(q.metric,q.usage,q.limit)
    #pprint(q, depth=2)

if __name__ == '__main__':
  main()

