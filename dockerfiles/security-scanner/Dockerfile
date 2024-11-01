FROM ubuntu:jammy

RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        git-lfs \
        gnupg \
        jq \
        lsb-release \
        wget

COPY trivy /usr/local/bin/trivy
COPY trivy-cache /trivy-cache
