# Basics
#
FROM adoptopenjdk:8-jre-hotspot
LABEL \
  maintainer="Jenkins Infra team <infra@lists.jenkins-ci.org>"

#
# When using a different version of JIRA, also be sure to tweak server.xml.
# To do a proper merge,
#   1. switch to the 'import' branch
#   2. overwrite jira/server.xml by the prestine master from JIRA distribution
#   3. commit the change to the 'import' branch
#   4. switch to the 'master' branch and merge the 'import' branch, while resolving the conflict if any.
#
ENV JIRA_VERSION 8.3.3

RUN \
  apt-get update -y && \
  apt-get install -y \
    software-properties-common \
    curl \
    xmlstarlet \
    sudo && \
  rm -rf /var/lib/apt/lists/*

RUN \
  /usr/sbin/groupadd --gid 1000 atlassian;\
  /usr/sbin/groupadd --gid 2001 jira;\
  /usr/sbin/useradd \
    --create-home \
    --home-dir /srv/jira \
    --groups atlassian \
    --uid 2001 \
    --gid jira \
    --shell /bin/bash \
    jira

RUN \
  mkdir -p /srv/jira/base /srv/jira/site /srv/jira/home \
  mkdir -p /usr/local/share/atlassian

RUN \
  curl -Lks https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz; \
  tar zxf /root/jira.tar.gz \
    --strip=1 \
    -C /srv/jira/base; \
  rm /root/jira.tar.gz

RUN echo "jira.home = /srv/jira/home" > /srv/jira/base/atlassian-jira/WEB-INF/classes/jira-application.properties

# Allow the user to start cron
RUN echo "jira  ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

ADD launch.bash /launch
ADD site /srv/jira/site
COPY common.bash /usr/local/share/atlassian/common.bash

RUN \
  chown -R jira:jira /srv/jira && \
  chown root:atlassian /usr/local/share/atlassian/common.bash

# The compartmentalized URL that JIRA is going to be referenced as.
ENV PROXY_SCHEME https
ENV PROXY_NAME issues.jenkins-ci.org
ENV PROXY_PORT 443

WORKDIR /srv/jira
VOLUME ["/srv/jira/home"]
EXPOSE 8080
USER jira
CMD ["/launch"]
