#!/usr/bin/python
"""

Sample usage:

   $ python get-machinetypes-for-region.py --project-id=YOUR_PROJECT_ID --regions us-central1,europe-west2 --min-ram-mb 999000

This scripts provides all the machine types within ALL zones within regions provided.
It calls two APIs, which are for 'normal' and 'accellerated' machine types.

Bugs:
- Zones are tried lexigographically, like manually a-f. Sorry about that.
- RAM filter only works for normal machines. accellerated MT are not filtered by "--min-ram-mb"
- Unfortunately the APIs don't provide support for custom APIs.

BEFORE RUNNING:
---------------
1. If not already done, enable the Compute Engine API
   and check the quota for your project_id at
   https://console.developers.google.com/apis/api/compute
2. This sample uses Application Default Credentials for authentication.
   If not already done, install the gcloud CLI from
   https://cloud.google.com/sdk and run
   `gcloud beta auth application-default login`.
   For more information, see
   https://developers.google.com/identity/protocols/application-default-credentials
3. Install the Python client library for Google APIs by running
   `pip install --upgrade google-api-python-client`
"""
import re

from pprint import pprint
from optparse import OptionParser

from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from googleapiclient.errors import HttpError

DEFAULT_REGIONS = "europe-west1,us-central1,asia-east1"
DEFAULT_MIN_RAM_MB = 1024
VERSION = "1.0_20181006"

"""
{u'creationTimestamp': u'1969-12-31T16:00:00.000-08:00',
 u'description': u'96 vCPUs, 1.4 TB RAM',
 u'guestCpus': 96,
 u'id': u'9096',
 u'imageSpaceGb': 0,
 u'isSharedCpu': False,
 u'kind': u'compute#machineType',
 u'maximumPersistentDisks': 128,
 u'maximumPersistentDisksSizeGb': u'65536',
 u'memoryMb': 1468006,
 u'name': u'n1-megamem-96',
 u'selfLink': u'https://www.googleapis.com/compute/v1/projects/ric-cccwiki/zones/europe-west1-b/machineTypes/n1-megamem-96',
 u'zone': u'europe-west1-b'}
"""


def print_accellerators_per_zone(prepend, project_id, zone):
  #machine_type_count = 0
  credentials = GoogleCredentials.get_application_default()
  service = discovery.build('compute', 'v1', credentials=credentials) # , access_type=None)
  try:
    request = service.acceleratorTypes().list(project=project_id, zone=zone)
    while request is not None:
        response = request.execute()
        print "{} {}:".format(prepend, zone) 
        for machine_type in response['items']:
            #pprint(machine_type)
            #if machine_type_count==0:
            #  print "B0 {}:".format(zone)         
            print "- {0:20} # [{1}] {2}".format(machine_type['name'], prepend, machine_type['description'])
            #machine_type_count += 1
        request = service.acceleratorTypes().list_next(previous_request=request, previous_response=response)
  except KeyError:
    print "- GPU EMPTY SEARCH (might have smaller machines)"
  except HttpError as e:
    #pprint(e)
    match_unknown_zone = re.search('Unknown zone.', "{}".format(e))
    if match_unknown_zone:
      print "# GPU Unknown zone: {}".format(zone)
    else:
      print "- GPU HttpError: {}".format((e)) # .error_details is empty, so _get_reason
  except Exception as e:
    print('- GPU Zone {} exception ({}): {}'.format(zone, type(e), e))


def print_machineTypes_per_zone(prepend, project_id, zone, min_ram_megabytes):
  credentials = GoogleCredentials.get_application_default()
  service = discovery.build('compute', 'v1', credentials=credentials) # , access_type=None)
  try:
    request = service.machineTypes().list(project=project_id, zone=zone, filter="memoryMb>{}".format(min_ram_megabytes))
    while request is not None:
        response = request.execute()
        print "{} {}:".format(prepend, zone) 
        for machine_type in response['items']:  
            print "- {0:20} # [{1}] {2}".format(machine_type['name'], prepend, machine_type['description'])
        request = service.machineTypes().list_next(previous_request=request, previous_response=response)
  except KeyError as e:
    print "- {} EMPTY SEARCH # KeyError (might have smaller machines): {}".format(prepend, e)
  except HttpError as e:
    match_unknown_zone = re.search('Unknown zone.', "{}".format(e))
    if match_unknown_zone:
      print "# {} Unknown zone: {}".format(prepend, zone)
    else:
      print "- {} HttpError: {}".format(prepend, e) # .error_details is empty, so _get_reason
  except Exception as e:
    print('- {} Zone {} exception ({}): {}'.format(prepend, zone, type(e), e))

def zones_by_region(region):
  return { "{}-{}".format(region,z) for z in list('abcdefghijklmnopqrstuvwxyz')[:6] }

def print_machinetypes_and_gpus_per_region(project_id, region, min_ram_megabytes):
  #zones = ['europe-west1-b','europe-west1-d','europe-west1-e']
  zones = zones_by_region(region) # approximate.
  #zones = ['europe-west1-b']
  #credentials = GoogleCredentials.get_application_default()
  print "#######################################################################################"
  print "# MachineTypes in '{reg}' with at least {mbmin}MB in YAML (project '{prj}')".format(reg=region, mbmin=min_ram_megabytes, prj=project_id)
  print "#######################################################################################"
  for zone in zones:
    print_machineTypes_per_zone("NORM", project_id, zone, min_ram_megabytes)
  print "#######################################################################################"
  print "# GPUs in '{reg}' of any kind in YAML (project '{prj}')".format(reg=region, prj=project_id)
  print "#######################################################################################"
  for zone in zones:
    print_accellerators_per_zone("GPU", project_id, zone)
  print

def main():
  parser = OptionParser()
  parser.add_option("-m", "--min-ram-mb", dest="min_ram_megabytes",
                    default=DEFAULT_MIN_RAM_MB, type="int",
                    help="minimum RAM (MB)")
  parser.add_option("-r", "--regions", dest="regions",
                    default=DEFAULT_REGIONS,
                    help="comma-separated regions list")
  parser.add_option("-q", "--quiet",
                    action="store_false", dest="verbose", default=True,
                    help="don't print status messages to stdout")
  parser.add_option("-p", "--project-id", dest="project_id",
                    #required=True, type="string", # action="store", 
                    default=None,
                    help="project id (string)")
  (options, args) = parser.parse_args()
  if options.verbose:
    print "[VERBOSE] Verbose is ACTIVE.."
    print "[VERBOSE] Options: ", options
    print "[VERBOSE] Args: ", args
    print "[VERBOSE] ProjectId: ", options.project_id
    print "[VERBOSE] Regions: ", options.regions
  min_ram_megabytes = options.min_ram_megabytes
  project_id = options.project_id
  if project_id == None:
    print "Error: ProjectId should not be empty: ", project_id
    parser.print_help()
    exit(1)
  if options.regions==None:
    print "Error: Regions should not empty: ", project_id
    parser.print_help()
    exit(2)
  regions = options.regions.split(',')
  for region in regions:
    print_machinetypes_and_gpus_per_region(project_id, region, min_ram_megabytes)

main()