# initial machine setup
	apt-get update
	apt-get install docker.io
	systemctl restart docker

## etc setup
get version number from https://github.com/coreos/etcd/releases

	export ETCD_VERSION="v3.3.5"
	mkdir -p /opt/etcd
	curl -L https://storage.googleapis.com/etcd/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
	  -o /opt/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
	tar xzvf /opt/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C /opt/etcd --strip-components=1

create `/etc/systemd/system/etcd.service`. Paste contents from running etcd-compute.pl with the basename and ip addresses.


on each machine, run
systemctl enable etcd
systemctl start etcd

## install kubernetes

	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubelet kubeadm kubectl kubernetes-cni

## configure master configuration on cloud1

create `master-configuration.yml`

```
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: 206.81.14.167
etcd:
  endpoints:
  - http://206.81.14.167:2379
  - http://206.81.14.168:2379
  - http://206.81.14.166:2379
apiServerCertSANs:
  - 206.81.14.167
  - localhost
  - c1.rc2.io
```

load the master config with `kubeadm init --config master-configuration.yml` 

that will echo a join command to run on other nodes

<b>Note: this seems to not be required.</b> leaving for a bit.
edit /etc/systemd/system/kubelet.service.d/10-kubeadm.conf and comment out the line setting $KUBELET_NETWORK_ARGS

follow .kube instructions to config for self

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config	
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

install [Weave Net](https://github.com/weaveworks/weave) on master to create a virtual network between containers 
`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`

## firewall setup

on all machines:
```
ufw allow ssh 
ufw allow from 206.81.14.166
ufw allow from 206.81.14.167
ufw allow from 206.81.14.168
ufw enable
```

on master: (the ip address is the current one for protos office)
```
ufw allow from 71.236.124.189
ufw allow from http
ufw allow from https
```

## enable control from a mac

	brew install kubectl
	mkdir ~/.kube
	scp cloud1:/root/.kube/config ~/.kube/config
	brew install kubernetes-helm

## install helm

helm is the kubernetes eqivilent of apt/homebrew

on mac:  `helm init`

[on linux](https://docs.helm.sh/using_helm/#installing-helm)

	1. download desired version
	2. untar
	3. cp helm binary to /usr/local/bin
	4. helm init

## install OpenEBS

on master: 

```
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
kubectl -n kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
helm install stable/openebs --name openebs --namespace openebs
git clone https://github.com/openebs/openebs
kubectl apply -f openebs/k8s/openebs-operator.yaml
kubectl apply -f openebs/k8s/openebs-storageclasses.yaml
```

## install postgres

```
cd openebs/k8s/demo/crunchy-postgres
# edit user/passwords/dbname in set.json
./run.sh
```

note that user/passwords are specified in deployment.json and setup.sql

edits to make:

	1. spec:containers:image - add `-gis` to image name
	2. set PG_PRIMARY_PASSWORD
	3. set PG_USER to rc2
	4. set PG_PASSWORD to rc2
	5. set PG_DATABASE to rc2
	6. set PG_ROOT_PASSWORD

to connect via terminal:

	1. `docker ps` on each node until find one whose name starts with "k8s_pgset_pgset-0"
	2.  Get the host ip address via `kubectl get svc | grep pgset-primary`
	3. `psql -U rc2 -h <IP ADDRESS> rc2`

## create configmap and deployment for appserver

run:

```
kubectl create configmap appserver-release --from-file=config.json=appserver-config.json
kubectl apply -f appserver.yaml 
```

this, combined with settings in appserver.yaml will mount the json file in the container. It will also create the deployment, and expose it to the world on the specified ip address (which should.be the master node).

## ingress

to install run `helm install --name rc2-ingress stable/nginx-ingress --set controller.service.type=NodePort --set controller.service.externalIPs={159.203.191.162}` replacing the ip address with the appropriate external address.

place the key in tls.key, the cert (with intermediate after our key) in tls.crt, then run `kubectl create secret tls api-rc2-io-tls --key tls.key --cert tls.crt `

apply appserver-ingress.yaml
