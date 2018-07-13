#!/bin/bash
# Copyright 2017 - 2018 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CCP_CLI=kubectl
CCP_NAMESPACE="default"

source common.sh
echo_info "Cleaning up.."

${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} --ignore-not-found statefulset rc2pgdb
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} --ignore-not-found sa rc2pgdb-sa
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} clusterrolebinding rc2pgdb-sa
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} pvc rc2pgdb-pgdata
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} pv rc2pgdb-pgdata
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} service rc2pgdb rc2pgdb-primary rc2pgdb-replica
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} pod rc2pgdb-0 rc2pgdb-1
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} configmap rc2pgdb-pgconf
${CCP_CLI?} delete --namespace=${CCP_NAMESPACE?} secret rc2pgdb-secret
