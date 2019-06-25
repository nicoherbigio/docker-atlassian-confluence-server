FROM nicoherbigio/adoptopenjdk-openjdk:8u212

LABEL maintainer="Nico Herbig <nico@nicoherbig.io>"


# Install additional required software packages

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl fontconfig openssl perl procps wget \
    && rm -rf /var/lib/apt/lists/*


# Install Tini

ARG TINI_VERSION=0.18.0
ARG TINI_DOWNLOAD_URL=https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini

RUN set -ex \
    && curl -fSL ${TINI_DOWNLOAD_URL} -o /sbin/tini \
    && chmod +x /sbin/tini


# Add Atlassian Confluence Server user and group to ensure that the IDs (UID and GID)
# are consistently assigned regardless of which additional dependencies are added.

ENV RUN_USER_ID=901 RUN_USER=confluence
ENV RUN_GROUP_ID=901 RUN_GROUP=confluence

RUN groupadd -r -g ${RUN_GROUP_ID} ${RUN_GROUP} && useradd -r -g ${RUN_GROUP} -u ${RUN_USER_ID} ${RUN_USER}


# Install Atlassian Confluence Server

ARG CONFLUENCE_VERSION=6.15.6
ARG CONFLUENCE_DOWNLOAD_URL=https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz

ENV CONFLUENCE_INSTALL_DIR=/opt/atlassian/confluence
ENV CONFLUENCE_HOME=/var/atlassian/confluence

# Actions to perform:
#   - Create installation directory
#   - Create home directory
#   - Download and unpack Atlassian Confluence Server
#   - Set permissions for the Confluence installation directory
#   - Set permissions for the Confluence home directory
RUN set -ex \
    && mkdir -p ${CONFLUENCE_INSTALL_DIR} \
    && mkdir -p ${CONFLUENCE_HOME} \
    && curl -fSL ${CONFLUENCE_DOWNLOAD_URL} | tar -xz --no-same-owner --strip-components=1 -C ${CONFLUENCE_INSTALL_DIR} \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dconfluence.home=\${CONFLUENCE_HOME}/g' ${CONFLUENCE_INSTALL_DIR}/bin/setenv.sh \
    && sed -i -e 's/port="8090"/port="8090" secure="${catalinaConnectorSecure}" scheme="${catalinaConnectorScheme}" proxyName="${catalinaConnectorProxyName}" proxyPort="${catalinaConnectorProxyPort}"/' ${CONFLUENCE_INSTALL_DIR}/conf/server.xml \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_INSTALL_DIR} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${CONFLUENCE_HOME}


# Configure Atlassian Confluence Server

VOLUME ${CONFLUENCE_HOME}

COPY assets/docker-entrypoint.sh /usr/local/bin/

RUN set -ex \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh /

EXPOSE 8090
EXPOSE 8091

WORKDIR ${CONFLUENCE_HOME}

CMD ["/docker-entrypoint.sh", "-fg"]
ENTRYPOINT ["/sbin/tini", "--"]
