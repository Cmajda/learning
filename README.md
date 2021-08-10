# 1. Content

<!-- TOC -->
- [1. Content](#1-content)
- [2. On Windows 10 WSL2](#2-on-windows-10-wsl2)
    - [2.1. Install WSL2 Win10](#21-install-wsl2-win10)
    - [2.2. How to install docker WSL2](#22-how-to-install-docker-wsl2)
    - [2.3. How to install k3d WSL2](#23-how-to-install-k3d-wsl2)
    - [2.4. Install K9s](#24-install-k9s)
- [3. Help links](#3-help-links)
<!-- /TOC -->

# 2. On Windows 10 WSL2
How to install and enable WSL2
## 2.1. Install WSL2 Win10
- [Microsoft doc](https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-1---enable-the-windows-subsystem-for-linux)

## 2.2. How to install docker WSL2
- [Docker doc](https://docs.docker.com/docker-for-windows/wsl/#install)  

## 2.3. How to install k3d WSL2
- [K3D doc](https://k3d.io/#install-script)

## 2.4. Install K9s
- [GitHub doc](https://gist.github.com/bplasmeijer/a4845a4858f1c0b0a22848984475322d)
```
curl -L https://github.com/derailed/k9s/releases/download/v0.21.4/k9s_Linux_x86_64.tar.gz -o k9s
tar -xf k9s
chmod +x k9s
sudo mv ./k9s /usr/local/bin/k9s
k9s
``` 

# 3. Help links
- [Steram Docker](https://web.microsoftstream.com/video/b0255f53-d784-4787-89f2-e7a359dba90b)
- [Stream Docker a Kubernetes](https://web.microsoftstream.com/video/aa13e911-351a-43c7-982a-6bd43f0ffd2e)
- [Stream kubernetes I](https://web.microsoftstream.com/video/383405c2-0098-4e19-b4a8-fec2183a7aa1)
- [Stream kubernetes II](https://web.microsoftstream.com/video/320963bd-c2c8-4701-933e-49e326c92f5e)
- [Cesta bojovníka](https://confluence.trask.cz/display/IABLACKOPSKUBE/Basic+levels)
- [Kubernetes web GUI](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Create simple user for GUI](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)