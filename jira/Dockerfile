# Basics
#
FROM durdn/atlassian-base
MAINTAINER Jenkins Infra team <infra@lists.jenkins-ci.org>

# Install Jira

ENV JIRA_VERSION 5.0.6
RUN /usr/sbin/useradd --create-home --home-dir /srv/jira --groups atlassian --shell /bin/bash jira
RUN mkdir -p /srv/jira/base /srv/jira/home
RUN curl -Lks http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz; tar zxf /root/jira.tar.gz --strip=1 -C /srv/jira/base; rm /root/jira.tar.gz
RUN echo "jira.home = /srv/jira/home" > /srv/jira/base/atlassian-jira/WEB-INF/classes/jira-application.properties
RUN chown -R jira:jira /srv/jira
RUN mv /srv/jira/base/conf/server.xml /srv/jira/base/conf/server-backup.xml

ENV CONTEXT_PATH ROOT
ADD launch.bash /launch

# Install Java. According to https://confluence.atlassian.com/display/JIRA050/Supported+Platforms
# JIRA 5.0.6 only runs on Java6 and not Java7
RUN \
  echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java6-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk6-installer

# Launching Jira

WORKDIR /srv/jira
VOLUME ["/srv/jira/home"]
EXPOSE 8080
USER jira
CMD ["/launch"]
