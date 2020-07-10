#!/usr/bin/python

# thanks to this genius: https://github.com/kanjih-ciandt/jupyter-gcp

import subprocess
import sys
import logging
import threading
import pprint

logger = logging.Logger('catch_all')

def execute_bash(parameters):
    try:
        return subprocess.check_output(parameters)
    except Exception as e: 
       logger.error(e) 
       logger.error('ERROR: Looking in jupyter console for more information')

def scan_gce(project, results_scan):
    print('Scanning project: "{}"'.format(project))
    ex = execute_bash(['gcloud','compute', 'instances', 'list', '--project', project, '--format=value(name,zone, status)'])
    list_result_vms = []
    if ex:
        list_vms = ex.decode("utf-8").split('\n')
        for vm in list_vms:
            if vm:
                vm_info = vm.split('\t')
                print('Scanning Instance: "{}" in project "{}"'.format(vm_info[0], project))
                results_bytes = execute_bash(['gcloud', 'compute', '--project',project, 
                                        'ssh', '--zone', vm_info[1],  vm_info[0], 
                                        '--command', 'cat /etc/*-release'  ])
                if results_bytes:
                    results = results_bytes.decode("utf-8").split('\n')
                    list_result_vms.append({'instance_name': vm_info[0],'result':results})


    results_scan.append({'project':project, 'vms':list_result_vms})


print "This might take a while. Go get a coffee bro... and consider pipeing into a file\n"
list_projects = execute_bash(['gcloud','projects', 'list', '--format=value(projectId)']).decode("utf-8").split('\n')
threads_project = []
results_scan = []
for project in list_projects :
    t = threading.Thread(target=scan_gce, args=(project, results_scan))
    threads_project.append(t)
    t.start()

for t in threads_project:
    t.join()

for result in results_scan:
    pprint.pprint(result)

