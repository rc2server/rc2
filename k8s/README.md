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

1. edit secrets.yaml with appropriate values
2. ./run.sh
3. create a user with `kubectl exec rc2pgdb-0 -it -- psql -U rc2 -c "select rc2createuser('login', 'FirstName', 'LastName', 'email@domain', 'password');" rc2`
4. run the same command with `rc2dev` at the end to do the same for the test database.

to connect via psql, on master run `kubectl exec rc2pgdb-0 -it -- bash`

until the appserver supports registration, need to connect to database and create a user:

```
select rc2createuser('mlilback', 'Mark', 'Lilback', 'mark@lilback.com', '<unencrypted password>');
```

## create configmap and deployment for appserver

run:

```
kubectl create configmap appserver-release --from-file=config.json=appserver-config.json
kubectl apply -f appserver.yaml 
kubectl create configmap appserver-dev --from-file=config.json=dev-config.json
kubectl apply -f devserver.yaml 
```

this, combined with settings in appserver.yaml will mount the json file in the container. It will also create the deployment, and expose it to the world on the specified ip address (which should.be the master node).

to restart the dev version and pull the latest docker image, use `kubectl patch deployment appserver-dev -p \
  "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"`

that will update a metadata label with the current/time, which will force the pods to reload.

## ingress

to install run `helm install --name rc2-ingress stable/nginx-ingress --set controller.service.type=NodePort --set controller.service.externalIPs={159.203.191.162}` replacing the ip address with the appropriate external address.


## install ssl cert
place the key in tls.key, the cert (with intermediate after our key) in tls.crt, then run `kubectl create secret tls api-rc2-io-tls --key tls.key --cert tls.crt `

apply appserver-ingress.yaml

## docker registry

run the following to start and keep running a registry. Change the paths as appropriate.

```
docker run -d -p 443:443 --name registry --restart=always -v /var/lib/registry:/var/lib/registry -v /root/docker-certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/tls.crt -e REGISTRY_HTTP_TLS_KEY=/certs/tls.key registry:2
```

### creating authentication

```
docker run --entrypoint htpasswd registry:2 -Bbn <userid> <password> >> htpasswd
```

Run that in the directory used by the registry (/root/docker-certs in the example) to add a user.

### storing reg for k8s

run the following to create a regcred secret
```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

Then add to the spec for the template (at the same level as containers) ```"imagePullSecrets": { "name": "regcred" }```

### Azure setup

Follow [this](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)

to login from command line: `az login -u <username> -p <password> --allow-no-subscriptions`

https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli

### GKE

Install gcloud

gcloud login

\# enable docker to gke container
gcloud container clusters get-credentials rc2-live
