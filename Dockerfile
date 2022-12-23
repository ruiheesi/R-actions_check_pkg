# Container image that runs the code
FROM ubuntu:latest

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

COPY renv.lock /renv.lock

ENV DEBIAN_FRONTEND=noninteractive

ENV RENV_VERSION 0.16.0

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
