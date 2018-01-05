#!/bin/bash
#
# Copyright 2018 Cisco Systems Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

mkdir -p /var/run/openvswitch

if [ -d "/etc/openvswitch" ]; then
	if [ -f "/etc/openvswitch/conf.db" ]; then
		echo "INFO: The Open vSwitch database exists"
	else
		echo "INFO: The Open vSwitch database doesn't exist"
		echo "INFO: Creating the Open vSwitch database..."
		ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
	fi
else
	echo "CRITICAL: Open vSwitch is not mounted from host"
	exit 1
fi

echo "INFO: updating OVS database schema if needed"
ovsdb-tool convert /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema

echo "INFO: Starting ovsdb-server..."
exec ovsdb-server --remote=punix:/var/run/openvswitch/db.sock \
	--remote=db:Open_vSwitch,Open_vSwitch,manager_options \
	--private-key=db:Open_vSwitch,SSL,private_key \
	--certificate=db:Open_vSwitch,SSL,certificate \
	--bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert
