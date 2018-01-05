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

if ! lsmod | cut -d" " -f1 | grep -q openvswitch; then
	echo "INFO: Loading kernel module: openvswitch"
	modprobe openvswitch
	sleep 2
fi

echo "INFO: waiting for ovsdb"
retry=0
while ! ovsdb-client list-dbs | grep -q Open_vSwitch; do
	if [[ ${retry} -eq 15 ]]; then
		echo "CRITICAL: Failed to reach ovsdb server in 15 seconds"
		exit 1
	else
		echo "INFO: Waiting for ovsdb to start..."
		sleep 1
		((retry += 1))
	fi
done

echo "INFO: Starting ovs-vswitchd"
ovs-vswitchd -v --pidfile &
VSWITCHD_PID=$!

sleep 2

echo "INFO: Setting OVS manager (tcp)..."
ovs-vsctl set-manager tcp:127.0.0.1:6640

echo "INFO: Setting OVS manager (ptcp)..."
ovs-vsctl set-manager ptcp:6640

wait $VSWITCHD_PID
exit 1
