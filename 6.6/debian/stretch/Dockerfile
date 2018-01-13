FROM nicoherbigio/debian:stretch

LABEL vendor="Nico Herbig <nico@nicoherbig.io>"


# Install Oracle Java Development Kit (JDK)

ARG JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.tar.gz

ARG JAVA_INSTALL_DIR=/usr/lib/jvm

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && mkdir -p ${JAVA_INSTALL_DIR} \
    && curl -fSL -H "Cookie: oraclelicense=accept-securebackup-cookie" ${JAVA_DOWNLOAD_URL} | tar -xz --no-same-owner --strip-components=1 -C ${JAVA_INSTALL_DIR} \
    && update-alternatives --install /usr/bin/java java ${JAVA_INSTALL_DIR}/bin/java 1 \
    && update-alternatives --install /usr/bin/javac javac ${JAVA_INSTALL_DIR}/bin/javac 1 \
    && update-alternatives --install /usr/bin/jar jar ${JAVA_INSTALL_DIR}/bin/jar 1 \
    && apt-get remove -y curl ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=${JAVA_INSTALL_DIR}


# Install additional required software packages

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates curl git openssh-server openssl perl procps ttf-dejavu wget \
    && rm -rf /var/lib/apt/lists/*


# Install Tini

ARG TINI_VERSION=0.16.1
ARG TINI_DOWNLOAD_URL=https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini

RUN set -ex \
    && curl -fSL ${TINI_DOWNLOAD_URL} -o /sbin/tini \
    && chmod +x /sbin/tini


# Add Atlassian Confluence Server user and group to ensure that the IDs (UID and GID)
# are consistently assigned regardless of which additional dependencies are added.

ENV RUN_USER_ID=901 RUN_USER=confluence
ENV RUN_GROUP_ID=901 RUN_GROUP=confluence

RUN groupadd -r -g ${RUN_GROUP_ID} ${RUN_GROUP} && useradd -r -g ${RUN_GROUP} -u ${RUN_USER_ID} ${RUN_USER}


# Install Atlassian Confluence Server inclusive MySQL Connector

ARG CONFLUENCE_VERSION=6.6.0
ARG CONFLUENCE_DOWNLOAD_URL=https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz

ARG MYSQL_CONNECTOR_VERSION=5.1.45
ARG MYSQL_CONNECTOR_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz

ENV CONFLUENCE_INSTALL_DIR=/opt/atlassian/confluence
ENV CONFLUENCE_HOME=/var/atlassian/confluence

# Actions to perform:
#   - Create installation directory
#   - Create home directory
#   - Download and unpack Atlassian Confluence Server
#   - Create lib directory inside the installation directory
#   - Download and unpack MySQL Connector
#   - Set permissions for the Confluence installation directory
#   - Set permissions for the Confluence home directory
RUN set -ex \
    && mkdir -p ${CONFLUENCE_INSTALL_DIR} \
    && mkdir -p ${CONFLUENCE_HOME} \
    && curl -fSL ${CONFLUENCE_DOWNLOAD_URL} | tar -xz --no-same-owner --strip-components=1 -C ${CONFLUENCE_INSTALL_DIR} \
    && mkdir -p ${CONFLUENCE_INSTALL_DIR}/lib \
    && curl -fSL ${MYSQL_CONNECTOR_DOWNLOAD_URL} | tar -xz --no-same-owner --strip-components=1 -C ${CONFLUENCE_INSTALL_DIR}/lib "mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar" \
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
