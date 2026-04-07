FROM jenkins/jenkins:lts-jdk17

COPY --from=docker:27-cli /usr/local/bin/docker /usr/local/bin/docker

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

ARG KUBECTL_VERSION=v1.34.3
RUN curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/arm64/kubectl" \
	&& chmod +x /usr/local/bin/kubectl \
	&& chmod +x /usr/local/bin/docker

USER jenkins
