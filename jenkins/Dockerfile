FROM jenkins/jenkins:lts-jdk17

COPY --from=docker:27-cli /usr/local/bin/docker /usr/local/bin/docker

USER root

RUN chmod +x /usr/local/bin/docker

USER jenkins
