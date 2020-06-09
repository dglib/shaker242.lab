FROM jenkins/jenkins:centos
USER root
RUN dnf makecache \
    && dnf -y update \
#    && dnf -y install @container-tools \
    && dnf -y install wget sudo ca-certificates
RUN dnf clean all
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
COPY ca.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust extract
USER jenkins