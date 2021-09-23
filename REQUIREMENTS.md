<!-- TOC -->

- [Requirements](#requirements)
  - [General Packages](#general-packages)
- [Docker](#docker)
- [Helm](#helm)
- [Kind](#kind)
- [Kubectl](#kubectl)
- [Plugins for Kubectl](#plugins-for-kubectl)
  - [kubectx e kubens](#kubectx-e-kubens)
  - [Other Kubetools](#other-kubetools)
- [Lens](#lens)
- [Linkerd](#linkerd)
- [Script of customized prompt](#script-of-customized-prompt)

<!-- TOC -->

# Requirements

## General Packages

Install the follow packages.

Debian/Ubuntu:

```bash
sudo apt-get install -y vim traceroute telnet git tcpdump elinks curl wget openssl netcat net-tools python3 python3-pip python3-venv jq
```

CentOS:

```bash
sudo yum install -y vim traceroute telnet git tcpdump elinks curl wget openssl netcat net-tools jq
```

Install Python 3 in CentOS: https://linuxize.com/post/how-to-install-python-3-on-centos-7

# Docker

Install Docker CE (Community Edition) following the instructions of the pages below, according to your GNU/Linux distribution.

* CentOS: https://docs.docker.com/install/linux/docker-ce/centos/
* Debian: https://docs.docker.com/install/linux/docker-ce/debian/
* Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/

Start the ``docker`` service, configure Docker to boot up with the OS and add your user to the ``docker`` group.

```bash
# Start the Docker service
sudo systemctl start docker

# Configure Docker to boot up with the OS
sudo systemctl enable docker

# Add your user to the Docker group
sudo usermod -aG docker $USER
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

Reference: https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot

For more information about Docker Compose visit:

* https://docs.docker.com
* http://blog.aeciopires.com/primeiros-passos-com-docker

# Helm

Install Helm 3 with the follow commands.

```bash
sudo su

HELM_TAR_FILE=helm-v3.7.0-linux-amd64.tar.gz
HELM_URL=https://get.helm.sh
HELM_BIN=helm3

function install_helm3 {

if [ -z $(which $HELM_BIN) ]; then
    wget ${HELM_URL}/${HELM_TAR_FILE}
    tar -xvzf ${HELM_TAR_FILE}
    chmod +x linux-amd64/helm
    sudo cp linux-amd64/helm /usr/local/bin/$HELM_BIN
    sudo ln -sfn /usr/local/bin/$HELM_BIN /usr/local/bin/helm
    rm -rf ${HELM_TAR_FILE} linux-amd64
    echo -e "\nwhich ${HELM_BIN}"
    which ${HELM_BIN}
else
    echo "Helm 3 is most likely installed"
fi
}

install_helm3
which $HELM_BIN
$HELM_BIN version

exit
```

For more information about Helm visit:

* https://helm.sh/docs/

# Kind

Run the following commands to install ``kind``.

```bash
VERSION=v0.11.0
cd /tmp
curl -Lo ./kind https://kind.sigs.k8s.io/dl/$VERSION/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

More information about ``kind``: 

* https://kind.sigs.k8s.io
* https://kind.sigs.k8s.io/docs/user/quick-start/
* https://github.com/kubernetes-sigs/kind/releases
* https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/#kind-kubernetes-made-easy-in-a-container
* 

# Kubectl

Run the following commands to install ``kubectl``.

```bash
sudo su

VERSION=v1.22.2
KUBECTL_BIN=kubectl

function install_kubectl {
if [ -z $(which $KUBECTL_BIN) ]; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/$KUBECTL_BIN
    chmod +x ${KUBECTL_BIN}
    sudo mv ${KUBECTL_BIN} /usr/local/bin/${KUBECTL_BIN}
    sudo ln -sf /usr/local/bin/${KUBECTL_BIN} /usr/bin/${KUBECTL_BIN}
else
    echo "Kubectl is most likely installed"
fi
}

install_kubectl

which kubectl

kubectl version --client

exit
```

More information about ``kubectl``: https://kubernetes.io/docs/reference/kubectl/overview/

Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Plugins for Kubectl

## kubectx e kubens

Documentation: https://github.com/ahmetb/kubectx#installation

```bash
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
COMPDIR=$(sudo pkg-config --variable=completionsdir bash-completion)
sudo ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
cat << EOF >> ~/.bashrc

#kubectx and kubens
export PATH=~/.kubectx:\$PATH
EOF
source ~/.bashrc
```

## Other Kubetools

* http://dockerlabs.collabnix.com/kubernetes/kubetools/
* https://caylent.com/50-useful-kubernetes-tools
* https://caylent.com/50+-useful-kubernetes-tools-list-part-2
* https://developer.sh/posts/kubernetes-client-tools-overview
* https://github.com/kubernetes-sigs/kind
* https://github.com/rancher/k3d
* https://microk8s.io/
* https://argoproj.github.io/argo-cd/

# Lens

Lens is an IDE for controlling your Kubernetes clusters. It is open source and free.

```bash
sudo snap install kontena-lens --classic
```

Documentation:

* https://k8slens.dev/
* https://snapcraft.io/kontena-lens

# Linkerd

```bash
curl -sL run.linkerd.io/install | sh
export PATH=$PATH:/home/$USER/.linkerd2/bin
linkerd version
cat << EOF >> ~/.bashrc

#linkerd
export PATH=\$PATH:/home/\$USER/.linkerd2/bin
EOF
source ~/.bashrc
```

# Script of customized prompt

To show the branch name, current directory, authenticated k8s cluster and namespace in use, there are several open source projects that provide this and you can choose the one that suits you best.

For zsh:

* https://ohmyz.sh/
* https://www.2vcps.io/2020/07/02/oh-my-zsh-fix-my-command-prompt/

For bash:

* https://github.com/ohmybash/oh-my-bash
* https://github.com/jonmosco/kube-ps1

bash_prompt:

```bash
curl -o ~/.bash_prompt https://gist.githubusercontent.com/aeciopires/6738c602e2d6832555d32df78aa3b9bb/raw/c43ed73a523a203220091d35d1e5ae2bec9877b2/.bash_prompt
chmod +x ~/.bash_prompt
echo "source ~/.bash_prompt" >> ~/.bashrc 
source ~/.bashrc
exec bash
```
