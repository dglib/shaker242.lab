FROM jenkins/jenkins
USER root
# Pre-update
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y software-properties-common ca-certificates curl sudo libltdl-dev apt-transport-https
# We will now add docker & kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
	&& echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
# Update and intall docker-ee and kubectl
RUN apt-get update \
	&& apt-get install -y kubectl \
	&& rm -rf /var/lib/apt/lists/*
# Give jenkins admin privs, this can come out after testing
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers