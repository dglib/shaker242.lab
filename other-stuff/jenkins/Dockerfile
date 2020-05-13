FROM  jenkins/jenkins:centos
USER root
RUN yum update -y ; yum upgrade -y ; yum -y install podman buildah skopeo sudo ca-certificates
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
COPY ca.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust extract

