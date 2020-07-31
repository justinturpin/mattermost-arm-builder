ARG MM_VERSION=5.25.2

# Builder Image
FROM golang

ARG MM_VERSION
ENV MM_VERSION=${MM_VERSION}

WORKDIR /opt

RUN apt-get update && apt-get install unzip -y

RUN wget https://github.com/mattermost/mattermost-server/archive/v${MM_VERSION}.zip -O /opt/server.zip && \
    unzip /opt/server.zip && \
    mv mattermost-server* mattermost-server

WORKDIR /opt/mattermost-server

RUN mkdir build/linux

RUN go build -o build/linux --trimpath ./...

# Runner Image
FROM alpine:3.10

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ARG MM_VERSION
ENV MM_VERSION=${MM_VERSION}

# Install some needed packages
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    libc6-compat \
    libffi-dev \
    libcap \
    linux-headers \
    mailcap \
    netcat-openbsd \
    xmlsec-dev \
    tzdata \
    && rm -rf /tmp/*

# Get Mattermost
RUN mkdir -p /mattermost/data /mattermost/bin /mattermost/plugins /mattermost/client/plugins

ARG edition=team
ARG PUID=2000
ARG PGID=2000

ENV MM_VERSION=5.25.0

RUN curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz?src=docker-app | tar -xvz

RUN cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json \
    && addgroup -g ${PGID} mattermost \
    && adduser -D -u ${PUID} -G mattermost -h /mattermost -D mattermost \
    && chown -R mattermost:mattermost /mattermost /config.json.save /mattermost/plugins /mattermost/client/plugins

RUN rm -rf /mattermost/bin/*

COPY --from=0 /opt/mattermost-server/build/linux /mattermost/bin

RUN setcap cap_net_bind_service=+ep /mattermost/bin/mattermost && \
    ls -lah /mattermost/bin

HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# Configure entrypoint and command
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
