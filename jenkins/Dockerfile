FROM  jenkins/jenkins:centos
USER root
RUN yum update -y \
	&& yum upgrade -y \
	&& yum install -y nfs-utils ca-certificates curl sudo yum-utils \
	&& yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
RUN yum update -y \
	&& yum install -y docker-ce docker-ce-cli containerd.io --nobest \
	&& yum clean all
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers 
USER jenkins