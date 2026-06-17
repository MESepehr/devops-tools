FROM ubuntu:22.04 AS my_runner

# RUN sed -i 's/archive.ubuntu.com/linux-mirror.liara.ir\/repository/g' /etc/apt/sources.list
# RUN sed -i 's/security.ubuntu.com/linux-mirror.liara.ir\/repository/g' /etc/apt/sources.list

RUN apt update
RUN apt upgrade -y

RUN apt install -y curl docker.io

RUN curl https://codekit.s3.ir-thr-at1.arvanstorage.ir/gitlab-runner-linux-amd64 -o /usr/local/bin/gitlab-runner
RUN chmod +x /usr/local/bin/gitlab-runner
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
RUN apt install -y rsync
# Docker part
#RUN apt install -y fuse-overlayfs
RUN mkdir -p /etc/docker && \
  echo '{\n\
  "iptables": false,\n\
  "bridge": "none",\n\
  "insecure-registries": ["https://docker.arvancloud.ir"],\n\
  "registry-mirrors": ["https://docker.arvancloud.ir"]\n\
}' > /etc/docker/daemon.json
RUN usermod -aG docker gitlab-runner
#ENV DOCKER_BUILDKIT=0

RUN gitlab-runner start

CMD ["/bin/bash", "-c", "gitlab-runner start && dockerd"]
#CMD ["gitlab-runner", "run"]
#CMD ["/usr/bin/dockerd"]