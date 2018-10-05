"""

Sample usage:

   $ python get-machinetypes-for-region.py --project-id=YOUR_PROJECT_ID --regions us-central1,europe-west2 --min-ram-mb 999000

BEFORE RUNNING:
---------------
1. If not already done, enable the Compute Engine API
   and check the quota for your project at
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


def print_accellerators_per_zone(project_id, zone):
  #machine_type_count = 0
  credentials = GoogleCredentials.get_application_default()
  service = discovery.build('compute', 'v1', credentials=credentials) # , access_type=None)
  try:
    request = service.acceleratorTypes().list(project=project_id, zone=zone)
    while request is not None:
        response = request.execute()
        print "{}:".format(zone) 
        for machine_type in response['items']:
            #pprint(machine_type)
            #if machine_type_count==0:
            #  print "B0 {}:".format(zone)         
            print "- {0:20} # [GPU] {1}".format(machine_type['name'], machine_type['description'])
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


def print_machineTypes_per_zone(project_id, zone, min_ram_megabytes):
  #machine_type_count = 0
  credentials = GoogleCredentials.get_application_default()
  service = discovery.build('compute', 'v1', credentials=credentials) # , access_type=None)
  try:
    request = service.machineTypes().list(project=project_id, zone=zone, filter="memoryMb>{}".format(min_ram_megabytes))
    while request is not None:
        response = request.execute()
        print "{}:".format(zone) 
        for machine_type in response['items']:
            #pprint(machine_type)
            #if machine_type_count==0:
            #  print "B0 {}:".format(zone)         
            print "- {0:20} # [NRM] {1}".format(machine_type['name'], machine_type['description'])
            #machine_type_count += 1
        request = service.machineTypes().list_next(previous_request=request, previous_response=response)
  except KeyError:
    print "- MT EMPTY SEARCH (might have smaller machines)"
  except HttpError as e:
    #pprint(e)
    match_unknown_zone = re.search('Unknown zone.', "{}".format(e))
    if match_unknown_zone:
      print "# MT Unknown zone: {}".format(zone)
    else:
      print "- MT HttpError: {}".format((e)) # .error_details is empty, so _get_reason
  except Exception as e:
    print('- Zone {} exception ({}): {}'.format(zone, type(e), e))

def zones_by_region(region):
  return { "{}-{}".format(region,z) for z in list('abcdefghijklmnopqrstuvwxyz')[:6] }

def print_machinetypes_per_region(project_id, region, min_ram_megabytes):
  #zones = ['europe-west1-b','europe-west1-d','europe-west1-e']
  zones = zones_by_region(region) # approximate.
  #zones = ['europe-west1-b']
  #credentials = GoogleCredentials.get_application_default()
  print "#######################################################################################"
  print "# MachineTypes in '{reg}' with at least {mbmin}MB in YAML (project '{prj}')".format(reg=region, mbmin=min_ram_megabytes, prj=project_id)
  print "#######################################################################################"
  for zone in zones:
    print_machineTypes_per_zone(project_id, zone, min_ram_megabytes)
  print "#######################################################################################"
  print "# GPUs in '{reg}' of any kind in YAML (project '{prj}')".format(reg=region, prj=project_id)
  print "#######################################################################################"
  for zone in zones:
    print_accellerators_per_zone(project_id, zone)
  print

def main():
  parser = OptionParser()
  parser.add_option("-m", "--min-ram-mb", dest="min_ram_megabytes",
                    default=1024, type="int",
                    help="minimum RAM (MB)")
  parser.add_option("-r", "--regions", dest="regions",
                    help="comma-separated regions list")
  parser.add_option("-q", "--quiet",
                    action="store_false", dest="verbose", default=True,
                    help="don't print status messages to stdout")
  parser.add_option("-p", "--project-id", dest="project_id",
                    #required=True, action="store", type="string",
                    default=None,
                    help="project id (string)")
  (options, args) = parser.parse_args()
  if options.verbose:
    print "Verbose is ACTIVE.."
    print "Options: ", options
    print "Args: ", args
    print "ProjectId: ", options.project_id
    print "Regions: ", options.regions
  regions = options.regions.split(',')
  min_ram_megabytes = options.min_ram_megabytes
  project_id = options.project_id
  if project_id == None:
    parser.print_help()
    exit(1)
  else:
    print "ProjectId not empty: ", project_id
  for region in regions:
    print_machinetypes_per_region(project_id, region, min_ram_megabytes)
  #print_machinetypes_per_region("europe-west3")

main()