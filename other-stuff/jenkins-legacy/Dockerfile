FROM  jenkins/jenkins:centos
USER root
RUN dnf -y update ; dnf -y install wget snapd podman buildah sudo ca-certificates \
  && snap install skopeo --edge 
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
COPY ca.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust extract
USER jenkins
