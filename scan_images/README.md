### Script require single parameter - namespace name or "all" for all namespaces
## Example:
```
root@controlplane:~$ ./scan_images.sh default
Image  Pod     Namespace  Vulnerabilities
nginx  nginx1  default    6
       nginx2  default    6
```
## Deploy trivy
```
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
```
### Desired improvements:
- Exclude system namespaces - "kube-system", etc. from the scan when "all" is specified
- Check only services exposed to the internet
- send report to slack (Jenkins pipeline, periodic nightly scans?)
- verify if all prerequisites installed
- check if images are properly tagged - filter by no tag or "latest"
- check if images deployed from external repositories

### Full output example
```
$ ./scan_images.sh all
Scanning pod nginx1
- Image: nginx
Scanning pod nginx2
- Image: nginx:latest
Scanning pod calico-kube-controllers-7bb4b4d4d-crdwk
- Image: docker.io/calico/kube-controllers:v3.24.1
Scanning pod canal-4rtm5
- Image: docker.io/calico/node:v3.24.1
- Image: quay.io/coreos/flannel:v0.15.1
Scanning pod canal-x84st
- Image: docker.io/calico/node:v3.24.1
- Image: quay.io/coreos/flannel:v0.15.1
Scanning pod coredns-76bb9b6fb5-l75b6
- Image: registry.k8s.io/coredns/coredns:v1.12.1
Scanning pod coredns-76bb9b6fb5-vq26m
- Image: registry.k8s.io/coredns/coredns:v1.12.1
Scanning pod etcd-controlplane
- Image: registry.k8s.io/etcd:3.6.5-0
Scanning pod kube-apiserver-controlplane
- Image: registry.k8s.io/kube-apiserver:v1.34.3
Scanning pod kube-controller-manager-controlplane
- Image: registry.k8s.io/kube-controller-manager:v1.34.3
Scanning pod kube-proxy-wrxgl
- Image: registry.k8s.io/kube-proxy:v1.34.3
Scanning pod kube-proxy-xllrj
- Image: registry.k8s.io/kube-proxy:v1.34.3
Scanning pod kube-scheduler-controlplane
- Image: registry.k8s.io/kube-scheduler:v1.34.3
Scanning pod local-path-provisioner-76f88ddd78-jch9f
- Image: rancher/local-path-provisioner:master-head
------------------- Scan completed ----------------------
Image                                            Pod                                      Namespace           Vulnerabilities
docker.io/calico/kube-controllers:v3.24.1        calico-kube-controllers-7bb4b4d4d-crdwk  kube-system         102
docker.io/calico/node:v3.24.1                    canal-4rtm5                              kube-system         121
                                                 canal-x84st                              kube-system         121
nginx                                            nginx1                                   default             6
nginx:latest                                     nginx2                                   default             6
quay.io/coreos/flannel:v0.15.1                   canal-4rtm5                              kube-system         86
                                                 canal-x84st                              kube-system         86
rancher/local-path-provisioner:master-head       local-path-provisioner-76f88ddd78-jch9f  local-path-storage  1
registry.k8s.io/coredns/coredns:v1.12.1          coredns-76bb9b6fb5-l75b6                 kube-system         13
                                                 coredns-76bb9b6fb5-vq26m                 kube-system         13
registry.k8s.io/etcd:3.6.5-0                     etcd-controlplane                        kube-system         16
registry.k8s.io/kube-apiserver:v1.34.3           kube-apiserver-controlplane              kube-system         8
registry.k8s.io/kube-controller-manager:v1.34.3  kube-controller-manager-controlplane     kube-system         8
registry.k8s.io/kube-proxy:v1.34.3               kube-proxy-wrxgl                         kube-system         11
                                                 kube-proxy-xllrj                         kube-system         11
registry.k8s.io/kube-scheduler:v1.34.3           kube-scheduler-controlplane              kube-system         7
```

