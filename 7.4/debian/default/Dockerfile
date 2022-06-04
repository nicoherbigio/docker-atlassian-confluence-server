FROM atlassian/confluence:7.4.17-ubuntu-18.04-adoptopenjdk11

LABEL maintainer="Nico Herbig <nico@nicoherbig.io>"


# Set time zone to "Europe/Berlin".

ENV TZ=Europe/Berlin

RUN set -ex \
    && ln -fns /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone


# Set locale to "en_US.UTF-8".

RUN set -ex \
    && if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
            # If this file exists, we are likely in "debian:xxx-slim" and locales are thus being excluded
            # so we need to remove that exclusion (since we need locales).
            grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
            sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
            ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
       fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends locales \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8 \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en
