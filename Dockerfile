# Fitnesse
#
#

FROM openjdk:jre-alpine
MAINTAINER Dmitry Trefilov <the-alien@live.ru>

RUN mkdir -p /opt/fitnesse
RUN chown 1000:1000 /opt/fitnesse

RUN addgroup -S -g 1000 fitnesse \
  && adduser -h /opt/fitnesse -s /bin/bash -S -G fitnesse -u 1000 fitnesse

RUN apk --no-cache add curl

ENV GOSU_VERSION 1.9
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

ENV FITNESSE_RELEASE 20161106

RUN mkdir -p /opt/fitnesse/FitNesseRoot \
  && wget -O /opt/fitnesse/fitnesse-standalone.jar "http://www.fitnesse.org/fitnesse-standalone.jar?responder=releaseDownload&release=$FITNESSE_RELEASE" \
  && chown -R fitnesse.fitnesse /opt/fitnesse

COPY docker-entrypoint.sh /bin/
RUN chmod +x /bin/docker-entrypoint.sh

VOLUME /opt/fitnesse/FitNesseRoot
EXPOSE 9090

WORKDIR /opt/fitnesse

ENTRYPOINT ["/bin/docker-entrypoint.sh"]
