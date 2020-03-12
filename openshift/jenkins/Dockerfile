# FROM  jenkins/jenkins:centos
# USER root
# # Patch/ Update/ Prepare
# RUN yum update -y \
# 	&& yum upgrade -y \
# 	&& yum install -y nfs-utils ca-certificates curl sudo yum-utils \
# 	&& dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# COPY ca.shaker242.crt /etc/pki/ca-trust/source/anchors/ 
# COPY kubernetes.repo /etc/yum.repos.d/

# # Intall docker and kubectl
# RUN yum update -y \
# 	&& dnf install -y docker-ce docker-ce-cli containerd.io kubectl --nobest \
# 	&& yum clean all

# # Give jenkins admin privs, this can come out after testing
# RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers \
# 	&& update-ca-trust