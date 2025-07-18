#!/usr/bin/env python3

"""Not too shabs this python doc thingy.

This code allows you to:

1. Define a per-folder `gcloud configuration` (been my dream for pst 10 years - Im done waiting).
2. You can have multiple versions: 'default', 'personal', 'work', 'demo', ..
3. If your folder is called 'bar', it will automatically load that folder. Caveat: folders starting with digit wont work


TODO(ricc): make it super NON verbose and when it is auto load it on every CD in the shell :)
            like direnv works. But first lets make it work :)

If you want the shell artifact to work with `direnv`, use this snippet of code
(courtesy of https://github.com/direnv/direnv/issues/70) Add this to ~/.direnvrc:

```bash
layout_ricc_gcloud() {
  echo "💛 [ENVRC] Layout Riccardo operational!"
  if [ -f "_env_gaic.sh" ]; then
    . _env_gaic.sh
  fi
}
```
Now add to your local .envrc:

```bash
# this is .envrc (see https://direnv.net/ for more)
layout ricc_gcloud

export MY_OTHER_VAR='FooBar'
```

Works like a charm! It's so automagic I need to add a yellow heart emoji to notice!

"""

from datetime import datetime
from collections import defaultdict

# pip install pyyaml
import yaml
import os
import subprocess
import sys

ProgVersion = '1.3'
ConfigFileName = '.gcloudconfig.yaml'
# set True in while loop in dev mode ;)
DryRun = False
ProgName = os.path.basename(sys.argv[0])
Now = datetime.now().strftime('%Y:%m:%d %H:%M')
Separator = ('#' * 80)
SampleConfig  = '''
########################################################
# This is a sample from {ProgName} v{ProgVersion}
# Code: https://github.com/palladius/sakura/blob/master/bin/auto_import_config.py
########################################################
# Once done you can do: gcloud config configurations activate YOUR_VAVORITE_CONFIG
local_config:
  auto: true
configurations:
  # You probably DONT WANT TO USE default unless you started on GCP yesterday
  #default:
  #  gcloud:
  #    project: my-default-personal-project
  #    compute/region: us-central1
  #    compute/zone: us-central1-b
  #    account: your.personal.email@gmail.com
  # Note: gcloud wont accept this config name if it starts with a number (#btdt)
  {this_folder}:
    gcloud:
      project: my-local-work-project
      compute/region: us-central1
      compute/zone: us-central1-b
      account: your.work.email@my-job.example.com
    env:
      # No need! It's auto imported for you. You're welcome
      #PROJECT_ID: this is autopopulated from above
      #GCP_REGION: this is autopopulated from above
      VERTEX_TRAINING_JOB_NAME: 'train-test-123'
      REPO_NAME: 'my-awesome-app'
      # These work! Just make sure you do it in ORDER. (God bless python dicts naivity)
      BUCKET: "gs://my-unique-${PROJECT_ID}-bucket"
      IMAGE_URI: "${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/my_vertex_image:latest"
'''
# python is ugly: https://stackoverflow.com/questions/17215400/format-string-unused-named-arguments doesnt help.



# Have I said I hate python? :)
class SafeDict(dict):
    def __missing__(self, key):
        return '{' + key + '}'

def local_dirname():
    '''Returns the latest folder of `pwd`.'''
    full_dir =  os.getcwd()
    local_dir = os.path.basename(full_dir)
    return local_dir

def execute(command):
    '''Execute code but... with a cactch.'''
    if DryRun:
        print(f"[DRYRUN] 🔞 {command}")
    else:
        # executing for real.. no excuses!
        #print(f"💻 Executing for real: {command}")
        os.system(command)

# def get_project_number_from_wrong(project_id):
#     '''Im so happy. This is usually an inefficient computation but I can automate it!'''
#     ret = os.system(f"gcloud projects describe {project_id} --format='value(projectNumber)'")
#     return f"{ret}" #  "4242"

def get_project_number_from(project_id):
    process = subprocess.Popen(
        [#"echo",
         "gcloud", "projects", "describe", project_id, "--format", "value(projectNumber)"],
        stdout=subprocess.PIPE
    )
    output, err = process.communicate()

    if process.returncode != 0:
        #raise Exception
        print(f"gcloud command failed; ret_value={process.returncode}") # err.decode()
        return None # "SOME_ERROR_42_SORRY"
        #return output.decode('utf-8').strip()

    return output.decode('utf-8').strip()

# generate_env_files
def setup_env_stubs(config_name, env_properties):
    '''Given config X and an array of properties, creates a few stub files.

    Inputs:
    * config_name: eg "default"
    * env_properties: eg {}

    '''
    #print(f"config_name: {config_name}")
    #print(f"env_properties: {env_properties}")
    banner = f"\n{Separator}\n# Generated by {ProgName} v{ProgVersion} on {Now}\n# Do NOT edit or it might get overwritten. Please edit the .gcloudconfig.yaml (and if needed relaunch the script)!\n{Separator}\n\n"
    config = env_properties

    # TODO(ricc): move to a lambda which accepts the logic per language and refactor so the OPEN can be caught with if exists...
    # Note: os.path.expandvars epamnds with LOCAL env which is wrong.
    # This should be current-ENV-independent!

    def expand_vars(value):
        if isinstance(value, str):
            for key, val in config.items():
                value = value.replace(f'${{{key}}}', val)
        return value

    for key, value in config.items():
        config[key] = expand_vars(value)

    # BASH stub
    with open('_env_gaic.sh', 'w') as f:
        f.write(banner)
        f.write("# [BASH]   source '_env_gaic.sh' \n") # TESTED
        f.write("# [DIRENV] layout ricc_gcloud\n") # TESTED

        for key, value in config.items():
            f.write(f'export {key}="{os.path.expandvars(value)}"\n')

    # Python stub
    with open('_env_gaic.py', 'w') as f:
        f.write(banner)
        f.write("# from _env_gaic import *\n") # TESTED
        for key, value in config.items():
            f.write(f'{key} = "{os.path.expandvars(value)}"\n')
        #f.write("# prova 2 \n")
        #for key, value in config.items():
        #    f.write(f'{key} = "{expand_vars(value)}"\n')

    # Ruby stub
    with open('_env_gaic.rb', 'w') as f:
        f.write(banner)
        f.write("# require_relative './_env_gaic.rb' \n")
        for key, value in config.items():
            f.write(f'ENV["{key}"] = "{os.path.expandvars(value)}"\n')

    print("🍉 Wow, what a ride! I've just dumped your special envs into 3 sh/py/rb stubs!")


def inject_all_configs(config_data):
    'Given a hash from YAML it creates one gcloud config per key'
        # injects config as per tree.
    for config_name, properties in config_data['configurations'].items():
        # First verifies if it exists.
        ret = execute(f"gcloud config configurations describe {config_name} >/dev/null")
        #print(f"ret = {ret}")
        if ret == 0:
            print(f"🦘 Config '{config_name}' found: skipping")
            # TODO: configurable FORCE: true
            continue
        print(f"➕ Config '{config_name}' NOT found: creating")

        # Create configuration if it doesn't exist
        # If it exists ignoring error
        execute(f"gcloud config configurations create {config_name} 2>/dev/null")

        opinionated_properties = {}

        # gcloud config ('gcloud' stanza)
        for property_name, value in properties['gcloud'].items():
            execute(f"gcloud config set {property_name} {value} --configuration {config_name}")
            if property_name == 'project':
                opinionated_properties['PROJECT_ID'] = value
                pn = get_project_number_from(value)
                if pn: # could be None if we get an error
                    opinionated_properties['PROJECT_NUMBER'] = pn
                #opinionated_properties['GOOGLE_PROJECT'] = value # Pulumi supports: GOOGLE_PROJECT, GOOGLE_CLOUD_PROJECT, GCLOUD_PROJECT, CLOUDSDK_CORE_PROJECT https://www.pulumi.com/registry/packages/gcp/installation-configuration/
            if property_name == 'compute/region':
                opinionated_properties['GCP_REGION'] = value
                #opinionated_properties['GOOGLE_REGION'] = value # Pulumi https://www.pulumi.com/registry/packages/gcp/installation-configuration/
            if property_name == 'compute/zone':
                opinionated_properties['GCP_ZONE'] = value
                #opinionated_properties['GOOGLE_ZONE'] = value # Pulumi https://www.pulumi.com/registry/packages/gcp/installation-configuration/
            if property_name == 'account':
                opinionated_properties['GCP_ACCOUNT'] = value

        # env config ('gcloud' stanza)
        # Injecting additional values if present in gcloud stanza..
        #opinionated_properties['REMOVEME'] = 'blah'
        opinionated_properties.update(properties['env'])
        setup_env_stubs(config_name, opinionated_properties)





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
        execute(f"gcloud config configurations activate {local_dir}")
    else:
        print(f"local_config[auto] = '{ config_data['local_config']['auto'] }'")

def create_sample_config_name():
    '''Create a reasonable sample filename for me.'''
    local_pwd = local_dirname()

    # from string import Template
    # tpl = Template(SampleConfig)
    # action = tpl.safe_substitute({'version': 'ProgVersion'})
    # print(action)
    ground_config = SampleConfig.format_map(SafeDict(
        bond='bond',
        ProgVersion=ProgVersion,
        ProgName=ProgName,
        this_folder=local_pwd))
    #.format_map(SafeDict(bond='bond'))
    # ground_config = SampleConfig.format(
    #     version=ProgVersion,
    #     prog_name=ProgName,
    #     this_folder=local_pwd)


    print (f"sample_config. Try something like: \n$ cat > {ConfigFileName}\n{ground_config}\n# ... Now its time to CRL-D\n")

def main():
    print("💛 Riccardo, the intent of this script is to AUTO-load on every `cd SOMEDIR`. This means this script should be SUPER silent and only produce output if something happens.")
    # check if file ConfigFileName exists..
    config_data = {}
    if os.path.isfile(ConfigFileName):
        #print("[DEB] ConfigFileName found: {ConfigFileName}")
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

    #execute(f"gcloud config list")
    execute(f"gcloud config configurations list | grep True")

    print("🪄 Magic show is now over. Check via `gcloud config configurations list`")


main()
