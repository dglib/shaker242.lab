## docker sidecar

# FROM centos
# USER root
# RUN yum update -y \
# 	&& yum upgrade -y \
# 	&& yum install -y yum-utils sudo\
# 	&& yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
# RUN yum update -y \
# 	&& yum install -y docker-ce docker-ce-cli containerd.io --nobest \
# 	&& yum clean all
# RUN useradd jenkins 
# #RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers 
# RUN echo "jenkins ALL= NOPASSWD: /usr/bin/dockerd" >> /etc/sudoers
# # This still fails, need to setup itables access; or better yet, run dockerd on a k8s node.
# USER jenkins
# CMD sudo /usr/bin/dockerd

## jenkins-agent
FROM quay.io/openshift/origin-jenkins-agent-maven:latest
USER root
RUN curl https://copr.fedorainfracloud.org/coprs/alsadi/dumb-init/repo/epel-7/alsadi-dumb-init-epel-7.repo -o /etc/yum.repos.d/alsadi-dumb-init-epel-7.repo \
	&& curl https://raw.githubusercontent.com/cloudrouter/centos-repo/master/CentOS-Base.repo -o /etc/yum.repos.d/CentOS-Base.repo \
	&& curl http://mirror.centos.org/centos-7/7/os/x86_64/RPM-GPG-KEY-CentOS-7 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
	&& DISABLES="--disablerepo=rhel-server-extras --disablerepo=rhel-fast-datapath-beta --disablerepo=rhel-server --disablerepo=rhel-fast-datapath --disablerepo=rhel-server-optional --disablerepo=rhel-server-ose --disablerepo=rhel-server-rhscl" \
	&& yum $DISABLES -y --setopt=tsflags=nodocs install skopeo && yum clean all
USER 1001