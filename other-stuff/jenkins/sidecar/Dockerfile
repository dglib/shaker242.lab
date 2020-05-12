FROM centos
RUN yum -y update; yum -y upgrade
RUN dnf -y module disable container-tools \
	&& dnf -y install 'dnf-command(copr)' \
	&& dnf -y copr enable rhcontainerbot/container-selinux \
	&& curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo \
	&& dnf -y install podman buildah skopeo
