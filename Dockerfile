FROM debian:stable

RUN apt-get -qq update

RUN apt-get -qq -y install curl \
    pandoc \
    git \
