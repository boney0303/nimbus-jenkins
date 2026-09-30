#!/usr/bin/env python3

# Description: this script gets latest list of plugins from update_center, ignores values in 'ignored-update-plugins'
# and compares latest with 'current_plugins', and writes the updates to the attributes/plugins.rb file.

# this is meant to be ran before releasing each version of this cookbook.

import requests
import json
import re

update_site_result = requests.get('https://updates.jenkins.io/update-center.json?version=2.277').text
update_site_result = re.sub(r'updateCenter\.post\(\n', '', update_site_result)
update_site_result = re.sub(r'\n\);', '', update_site_result)
update_site_plugins = json.loads(update_site_result)['plugins']

# read in list of plugins to ignore
with open('files/default/install-plugins/ignored-update-plugins', 'r') as f:
    ignored_plugins = f.read().split('\n')

# read in list of plugins to install
with open('plugins.txt', 'r') as f:
    current_plugins = f.read().split('\n')

# update plugin attributes
with open('attributes/plugins.rb', 'w') as f:
    f.write("default['nimbus-jenkins']['plugins'] = [\n")
    for p in current_plugins:
        if p:
            (plugin_id, current_version) = p.split(':')
            latest = {k:v for k,v in update_site_plugins.items() if v['name'] == plugin_id}

            if plugin_id not in ignored_plugins:
                version = latest.get(plugin_id).get('version', current_version)
                f.write("  '%s:%s',\n" % (plugin_id, version))
    f.write("]\n")
