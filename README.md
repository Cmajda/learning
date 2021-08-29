# 1. Content
<!-- TOC -->
- [1. Content](#1-content)
- [2. Prerequisites](#2-prerequisites)
	- [2.1. Install WSL2 Win10](#21-install-wsl2-win10)
	- [2.2. Install docker](#22-install-docker)
	- [2.3. Install k3d WSL2](#23-install-k3d-wsl2)
	- [2.4. Install K9s](#24-install-k9s)
	- [2.5. Install Kubectl](#25-install-kubectl)
- [3. Help links](#3-help-links)
- [4. Docker](#4-docker)
	- [4.1. documentation](#41-documentation)
	- [4.2. examples](#42-examples)
		- [4.2.1. docker simple](#421-docker-simple)
- [5. Kubernetes](#5-kubernetes)
	- [5.1. documentation](#51-documentation)
	- [5.2. Task](#52-task)
- [6. Linux](#6-linux)
	- [6.1. documentation](#61-documentation)
<!-- /TOC -->

# 2. Prerequisites
- Windows Subsystem for Linux (WSL2) 
- Docker
- K3d
- K9s 
- kubectl

## 2.1. Install WSL2 Win10
- [Microsoft doc](https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-1---enable-the-windows-subsystem-for-linux)

## 2.2. Install docker
- [Docker doc UBUNTU](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)  

Update the apt package index and install packages to allow apt to use a repository over HTTPS:
```
sudo apt-get update

sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release
```
Add Docker’s official GPG key:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below. Learn about nightly and test channels.
```
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version:

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
- [Docker doc WSL2](https://docs.docker.com/docker-for-windows/wsl/#install)  

## 2.3. Install k3d WSL2
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

## 2.5. Install Kubectl

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

```

# 3. Help links
- [Steram Docker](https://web.microsoftstream.com/video/b0255f53-d784-4787-89f2-e7a359dba90b)
- [Stream Docker a Kubernetes](https://web.microsoftstream.com/video/aa13e911-351a-43c7-982a-6bd43f0ffd2e)
- [Stream Kubernetes I](https://web.microsoftstream.com/video/383405c2-0098-4e19-b4a8-fec2183a7aa1)
- [Stream Kubernetes II](https://web.microsoftstream.com/video/320963bd-c2c8-4701-933e-49e326c92f5e)
- [Cesta bojovníka](https://confluence.trask.cz/display/IABLACKOPSKUBE/Basic+levels)
- [Kubernetes web GUI](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Create a simple user for GUI](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
- [Git prezentace](https://github.com/amoravek/k8s)
- [Git emoji](https://gist.github.com/roachhd/1f029bd4b50b8a524f3c)
- [Git emoji 2](https://gist.github.com/rxaviers/7360908)

# 4. Docker

## 4.1. documentation
- [docker command](docker/docs/docker-command.md)

## 4.2. examples

### 4.2.1. docker simple
- [Sources](docker/examples/docker-simple/)
- [Doc](docker/examples#docker-simple)

# 5. Kubernetes

## 5.1. documentation

## 5.2. Task
[Task - 0 ](k8s/Tasks/level_0#readme)
[Task - 1 ](k8s/Tasks/level_1#readme)
[Task - 2 ](k8s/Tasks/level_2#readme)
[Task - 3 ](k8s/Tasks/level_3#readme)

# 6. Linux

## 6.1. documentation