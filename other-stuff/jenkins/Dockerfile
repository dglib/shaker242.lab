FROM jenkins/jenkins:lts
USER root
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y ca-certificates sudo libltdl-dev ldap-client
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
COPY ca-redcloud.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates