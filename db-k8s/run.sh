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

CCP_NAMESPACE="default"
CCP_CLI=kubectl

source common.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR}/cleanup.sh

#create_storage "statefulset"
#if [[ $? -ne 0 ]]
#then
#    echo_err "Failed to create storage, exiting.."
#    exit 1
#fi

# As of Kube 1.6, it is necessary to allow the service account to perform
# a label command. For this example, we open up wide permissions
# for all serviceaccounts. This is NOT for production!

${CCP_CLI?} create --namespace=${CCP_NAMESPACE?} clusterrolebinding rc2pgdb-sa \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts \
  --namespace=$CCP_NAMESPACE

${CCP_CLI?} create --namespace=${CCP_NAMESPACE?} configmap rc2pgdb-pgconf \
    --from-file ${DIR?}/configs/pg_hba.conf \
    --from-file ${DIR?}/configs/pgbackrest.conf \
    --from-file ${DIR?}/configs/postgresql.conf \
    --from-file ${DIR?}/configs/setup.sql \
    --from-file ${DIR?}/configs/pre-start-hook.sh \
    --from-file ${DIR?}/configs/post-start-hook.sh

${CCP_CLI?} create --namespace=${CCP_NAMESPACE?} -f $DIR/secrets.json
${CCP_CLI?} create --namespace=${CCP_NAMESPACE?} -f $DIR/deployment.json
