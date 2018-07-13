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

create `/etc/systemd/system/etcd.service`

```
[Unit]
Description=etcd

[Service]
Type=notify
ExecStart=/opt/etcd/etcd --name cloud1 \
  --data-dir /var/lib/etcd \
  --listen-client-urls "http://206.81.14.167:2379,http://localhost:2379" \
  --advertise-client-urls "http://206.81.14.167:2379" \
  --listen-peer-urls "http://206.81.14.167:2380" \
  --initial-cluster "cloud1=http://206.81.14.167:2380,cloud2=http://206.81.14.168:2380,cloud3=http://206.81.14.166:2380" \
  --initial-advertise-peer-urls "http://206.81.14.167:2380" \
  --heartbeat-interval 200 \
  --election-timeout 5000
Restart=always
RestartSec=5
TimeoutStartSec=0
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
```

## install kubernetes

	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
	deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main
	EOF
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
```

load the master config with `kubeadm init --config master-configuration.yml` 

that will echo a join command to run on other nodes

follow .kube instructions to config for self

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config	
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

install [Weave Net](https://github.com/weaveworks/weave) to create a virtual network between containers 
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


## install OpenEBS

on master: 

```
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
kubectl -n kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
helm install stable/openebs --name openebs --namespace openebs
git clone https://github.com/openebs/openebs
kubectl apply -f openebs/k8s/openebs-operator.yml
kubectl apply -f openebs/k8s/openebs-storageclasses.yml
```

## install postgres

```
cd openebs/k8s/demo/crunchy-postgres
# edit user/passwords in set.json
./run.sh
```

## create configmap and deployment for appserver

in the directory with config.json, run:

```
kubectl create configmap appserver-release --from-file=config.json=config.json
kubectl apply -f appserver.yml 
kubectl expose deployment appserver-deployment --port=80 --target-port=8088 --externalIPs='206.81.14.167'
```

this, combined with settings in appserver.yaml will mount the json file in the container. It will also create the deployment, and expose it to the world on the specified ip address (which should.be the master node).
