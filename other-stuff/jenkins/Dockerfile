FROM jenkins/jenkins:lts
USER root
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y apt-utils \
	&& apt-get install -y ca-certificates sudo libltdl-dev ldap-client 
RUN sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/testing/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:testing.list" ] \
	&& curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/testing/xUbuntu_18.04/Release.key | sudo apt-key add - \
	&& apt-get update -qq \
	&& apt-get -qq -y install podman buildah skopeo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
COPY ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

