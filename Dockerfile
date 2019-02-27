FROM maven:3.6-jdk-11 as builder
COPY VERSION /VERSION

RUN git clone https://github.com/prometheus/jmx_exporter.git \
    && cd jmx_exporter \
    && VERSION=$(cat /VERSION) \
    && git checkout parent-$VERSION \
    && mvn package \
    && cp /jmx_exporter/jmx_prometheus_httpserver/target/jmx_prometheus_httpserver-${VERSION}-jar-with-dependencies.jar /jmx_prometheus_httpserver.jar

RUN apt-get update \
    && apt-get install -y make musl-tools \
    && git clone https://github.com/Yelp/dumb-init.git \
    && cd dumb-init \
    && git checkout v1.2.1 \
    && CC=musl-gcc make

FROM openjdk:8-alpine

RUN apk update && apk upgrade && apk --update add curl && rm -rf /tmp/* /var/cache/apk/*

ENV JAR jmx_prometheus_httpserver.jar

COPY --from=builder /dumb-init/dumb-init /usr/local/bin/dumb-init

RUN chmod +x /usr/local/bin/dumb-init
RUN mkdir -p /opt/jmx_exporter

COPY --from=builder /$JAR /opt/jmx_exporter/$JAR
COPY start.sh /opt/jmx_exporter/
COPY config.yml /opt/jmx_exporter/

CMD ["usr/local/bin/dumb-init", "/opt/jmx_exporter/start.sh"]
