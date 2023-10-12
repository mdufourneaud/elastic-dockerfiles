FROM cgr.dev/chainguard/wolfi-base as build

RUN apk add --no-cache curl && \
    curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-8.10.3-linux-aarch64.tar.gz | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-8.10.3 /usr/share/logstash

FROM cgr.dev/elastic.co/jdk:openjdk-17-dev as runtime

ARG USER=1000
ARG UID=1000
ARG GID=1000

USER root

RUN addgroup -g $GID $USER && \
    adduser -u $UID -G $USER \
    --disabled-password \
    --gecos "" \
    --home "/usr/share/logstash" \
    --shell "/sbin/nologin" \
    --no-create-home \
    logstash && \
    mkdir -p /usr/share/logstash && \
    mkdir -p /usr/share/logstash/data && \
    mkdir -p /licenses/  && \
    mkdir -p /opt/logstash

COPY --from=build /usr/share/logstash/LICENSE.txt /licenses/LICENSE.txt

COPY --from=build /usr/share/logstash/CONTRIBUTORS /usr/share/logstash/CONTRIBUTORS
COPY --from=build /usr/share/logstash//Gemfile /usr/share/logstash//Gemfile
COPY --from=build /usr/share/logstash//Gemfile.lock /usr/share/logstash//Gemfile.lock
COPY --from=build /usr/share/logstash/bin /usr/share/logstash/bin
COPY --from=build /usr/share/logstash/config /usr/share/logstash/config
COPY --from=build /usr/share/logstash/lib /usr/share/logstash/lib
COPY --from=build /usr/share/logstash/logstash-core /usr/share/logstash/logstash-core
COPY --from=build /usr/share/logstash/logstash-core-plugin-api /usr/share/logstash/logstash-core-plugin-api
COPY --from=build /usr/share/logstash/modules /usr/share/logstash/modules
COPY --from=build /usr/share/logstash/tools /usr/share/logstash/tools
COPY --from=build /usr/share/logstash/vendor /usr/share/logstash/vendor

## NOT added (not needed or part of the base image)
## COPY --from=build /usr/share/logstash/jdk
COPY --from=build /usr/share/logstash/x-pack /usr/share/logstash/x-pack
## COPY --from=build /usr/share/logstash/NOTICE.TXT /usr/share/logstash/NOTICE.TXT


# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
COPY config/pipelines.yml /usr/share/logstash/config/pipelines.yml
COPY config/logstash-full.yml /usr/share/logstash/config/logstash.yml
COPY config/log4j2.properties /usr/share/logstash/config/
COPY config/log4j2.file.properties /usr/share/logstash/config/
COPY pipeline/default.conf /usr/share/logstash/pipeline/logstash.conf

# Ensure Logstash gets the correct locale by default.
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
COPY env2yaml/env2yaml /usr/local/bin/
# Place the startup wrapper script.
COPY bin/docker-entrypoint /usr/local/bin/

RUN chown --recursive $GID:$UID /usr/share/logstash/ && \
    chown -R $GID:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    chmod 0755 /usr/local/bin/docker-entrypoint && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash

USER logstash

WORKDIR /usr/share/logstash
ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH
ENV LS_JAVA_HOME=/usr/lib/jvm/default-jvm
EXPOSE 9600 5044

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]



