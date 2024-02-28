#!/usr/bin/env python

# This code allows you to:
# 1. Define a per-folder .gcloud config (been my dream for pst 10 years - Im done waiting).
# 2. You can have multiple versions: 'default',. 'foo', 'bar'.
# 3. If your folder is called 'bar', it will automatically load that folder.


# TODO make it super NON verbose and when it is auto load it on every CD in the shell :)
# .. like direnv works. But first lets make it work :)

import yaml
import os

ProgVersion = '1.1'
ConfigFileName = '.gcloudconfig.yaml'
SampleConfig  = '''\
########################################################
# This is a sample from auto_import_config.py v{version}
# Code: https://github.com/palladius/sakura/blob/master/bin/auto_import_config.py
########################################################
# Once done you can do: gcloud config configurations activate YOUR_VAVORITE_CONFIG
local_config:
  auto: true
configurations:
  default:
    project: my-default-personal-project
    compute/region: us-central1
    compute/zone: us-central1-b
    account: your.personal.email@gmail.com
  # Note: gcloud wont accept this config name if it starts with a number (#btdt)
  {this_folder}:
    project: my-local-work-project
    compute/region: us-central1
    compute/zone: us-central1-b
    account: your.work.email@my-job.example.com
'''
def inject_all_configs(config_data):
    'Given a hash from YAML it creates one gcloud config per key'
        # injects config as per tree.
    for config_name, properties in config_data['configurations'].items():
        # First verifies if it exists.
        ret = os.system(f"gcloud config configurations describe {config_name} >/dev/null")
        #print(f"ret = {ret}")
        if ret == 0:
            print(f"🦘 Config '{config_name}' found: skipping")
            # TODO: configurable FORCE: true
            #break
            #next
            continue
        print(f"➕ Config '{config_name}' NOT found: creating")

        # Create configuration if it doesn't exist===
        os.system(f"gcloud config configurations create {config_name}")

        for property_name, value in properties.items():
            os.system(f"gcloud config set {property_name} {value} --configuration {config_name}")

def local_dirname():
    '''Returns the latest folder of `pwd`.'''
    full_dir =  os.getcwd()
    local_dir = os.path.basename(full_dir)
    return local_dir

def parse_local_config(config_data):
    '''parses the autoconfig: optional stanza.'''
    if 'auto' in config_data['local_config'] and config_data['local_config']['auto'] == True:
            # The dictionary has two key children named `local_config` and `auto`, and the value of the `auto` key is equal to `True`.
            #if local_config is not None and local_config['auto'] == True:
        full_dir =  os.getcwd()
        local_dir = local_dirname() # os.path.basename(full_dir)
        # Alternative:
        # last_part = current_dir.rsplit('/', 1)[1]
        print(f'Setting config with same name as local dir: {local_dir}')
        os.system(f"gcloud config configurations activate {local_dir}")
    else:
        print(f"local_config[auto] = '{ config_data['local_config']['auto'] }'")

def create_sample_config_name():
    '''Create a reasonable sample filename for me.'''
    local_pwd = local_dirname()
    ground_config = SampleConfig.format(version=ProgVersion, this_folder=local_pwd)
    print (f"sample_config. Try something like: \n$ cat > {ConfigFileName}\n{ground_config}\n# ... Now its time to CRL-D\n")

def main():
    print("💛 Riccardo, the intent of this script is to AUTO-load on every `cd SOMEDIR`. This means this script should be SUPER silent and only produce output if something happens.")
    # check if file ConfigFileName exists..
    config_data = {}
    if os.path.isfile(ConfigFileName):
        with open(ConfigFileName, 'r') as file:
            config_data = yaml.safe_load(file)
    else:
        #except FileNotFoundError:
        print(f"{ConfigFileName} not found. Would you like me to create one for you?")
        create_sample_config_name()
        exit(0)

    # with open(ConfigFileName, 'r') as file:
    #     config_data = yaml.safe_load(file)

    inject_all_configs(config_data)

    # for k, val in config_data['local_config'].items():
    #     print(f"{k} -> {val}")
    if 'local_config' in config_data:
        parse_local_config(config_data)
    else:
        print('no AUTOCONFIG defined') # todo deleteme.
    # Final

    #os.system(f"gcloud config list")
    os.system(f"gcloud config configurations list | grep True")


main()
