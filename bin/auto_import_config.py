#!/usr/bin/env python

# TODO rename to `auto_import_config.py `
# TODO make it su0per NON verbose and when it is auto load it on every CD in the shell :)
# .. like direnv works.

import yaml
import os

def inject_all_configs(config_data):
    'Given a hash from YAML it creates one gcloud config per key'
    # injects config as per tree.
    for config_name, properties in config_data['configurations'].items():
        # Create configuration if it doesn't exist
        os.system(f"gcloud config configurations create {config_name}")

        for property_name, value in properties.items():
            os.system(f"gcloud config set {property_name} {value} --configuration {config_name}")

def parse_local_config(config_data):
    '''parses the autoconfig: optional stanza.'''
    if 'auto' in config_data['local_config'] and config_data['local_config']['auto'] == True:
            # The dictionary has two key children named `local_config` and `auto`, and the value of the `auto` key is equal to `True`.
            #if local_config is not None and local_config['auto'] == True:
        full_dir =  os.getcwd()
        local_dir = os.path.basename(full_dir)
        # Alternative:
        # last_part = current_dir.rsplit('/', 1)[1]
        print(f'Setting config with same name as local dir: {local_dir}')
        os.system(f"gcloud config configurations activate {local_dir}")
    else:
        print(f"local_config[auto] = '{ config_data['local_config']['auto'] }'")

def main():
    print("💛 Riccardo, the intent of this script is to AUTO-load on every `cd SOMEDIR`. This means this script should be SUPER silent and only produce output if something happens.")
    with open('.gcloudconfig.yaml', 'r') as file:
        config_data = yaml.safe_load(file)

    inject_all_configs(config_data)

    # for k, val in config_data['local_config'].items():
    #     print(f"{k} -> {val}")
    if 'local_config' in config_data:
        parse_local_config(config_data)
    else:
        print('no AUTOCONFIG defined') # todo deleteme.
    # Final

    os.system(f"gcloud config list")

main()
