---
layout: post
title: Playing with minikube kubenetes
image: /assets/img/
readtime: 5 minutes
---

`brew install minikube`

```
13:56:52 › minikube start
😄  minikube v1.5.2 on Darwin 10.13.6
✨  Automatically selected the 'hyperkit' driver
💾  Downloading driver docker-machine-driver-hyperkit:
    > docker-machine-driver-hyperkit.sha256: 65 B / 65 B [---] 100.00% ? p/s 0s
    > docker-machine-driver-hyperkit: 10.79 MiB / 10.79 MiB  100.00% 1.84 MiB p
🔑  The 'hyperkit' driver requires elevated permissions. The following commands will be executed:

    $ sudo chown root:wheel /Users/craiggoddenpayne/.minikube/bin/docker-machine-driver-hyperkit
    $ sudo chmod u+s /Users/craiggoddenpayne/.minikube/bin/docker-machine-driver-hyperkit

Password:
💿  Downloading VM boot image ...
    > minikube-v1.5.1.iso.sha256: 65 B / 65 B [--------------] 100.00% ? p/s 0s
    > minikube-v1.5.1.iso: 143.76 MiB / 143.76 MiB [-] 100.00% 6.50 MiB p/s 22s
🔥  Creating hyperkit VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.16.2 on Docker '18.09.9' ...
💾  Downloading kubeadm v1.16.2
💾  Downloading kubelet v1.16.2
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Waiting for: apiserver
🏄  Done! kubectl is now configured to use "minikube"
```


```
14:04:05 › minikube kubectl cluster-info
Kubernetes master is running at https://192.168.64.2:8443
KubeDNS is running at https://192.168.64.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```
14:05:34 › minikube kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   5m57s   v1.16.2
```

Once the application instances are created, a Kubernetes Deployment Controller continuously monitors those instances. If the Node hosting an instance goes down or is deleted, the Deployment controller replaces the instance with an instance on another Node in the cluster. This provides a self-healing mechanism to address machine failure or maintenance.

```
14:14:04 › kubectl create deployment my-app --image=my-app
deployment.apps/my-app created
```


```
14:16:00 › kubectl get deployments
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
my-app   0/1     1            0           4s
```

