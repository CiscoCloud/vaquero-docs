FROM debian:stable

RUN apt-get update && apt-get -y install \
    curl \
    pandoc \
    git

RUN apt-get clean
