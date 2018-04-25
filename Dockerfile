FROM arm32v7/debian:stretch-slim

LABEL maintainer "Clay Shekleton <clay@clayshekleton.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y ddclient libio-socket-ssl-perl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY ddclient.conf /etc/ddclient.conf
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
