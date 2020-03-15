# docker sidecar

FROM centos
USER root
RUN yum update -y \
	&& yum upgrade -y \
	&& yum install -y yum-utils \
	&& yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
RUN yum update -y \
	&& yum install -y docker-ce docker-ce-cli containerd.io --nobest \
	&& yum clean all
RUN useradd jenkins
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers 
USER jenkins
ENTRYPOINT dockerd
