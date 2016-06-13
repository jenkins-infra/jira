# Basics
#
FROM jenkinsciinfra/atlassian-base:build2
MAINTAINER Jenkins Infra team <infra@lists.jenkins-ci.org>


#
# When using a different version of JIRA, also be sure to tweak server.xml.
# To do a proper merge,
#   1. switch to the 'import' branch
#   2. overwrite jira/server.xml by the prestine master from JIRA distribution
#   3. commit the change to the 'import' branch
#   4. switch to the 'master' branch and merge the 'import' branch, while resolving the conflict if any.
#
ENV JIRA_VERSION 7.1.7

# Install Java. According to https://confluence.atlassian.com/display/JIRA/Supported+Platforms
# Java7 & Java8 are supported, except 8u25 and 8u31
RUN \
  echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

RUN /usr/sbin/groupadd --gid 2001 jira; /usr/sbin/useradd --create-home --home-dir /srv/jira --groups atlassian --uid 2001 --gid jira --shell /bin/bash jira
RUN mkdir -p /srv/jira/base /srv/jira/site /srv/jira/home
RUN curl -Lks https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz; tar zxf /root/jira.tar.gz --strip=1 -C /srv/jira/base; rm /root/jira.tar.gz
RUN echo "jira.home = /srv/jira/home" > /srv/jira/base/atlassian-jira/WEB-INF/classes/jira-application.properties

# Allow the user to start cron
RUN echo "jira  ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

ADD launch.bash /launch
ADD site /srv/jira/site

RUN chown -R jira:jira /srv/jira


# The compartmentalized URL that JIRA is going to be referenced as.
ENV PROXY_SCHEME https
ENV PROXY_NAME issues.jenkins-ci.org
ENV PROXY_PORT 443

WORKDIR /srv/jira
VOLUME ["/srv/jira/home"]
EXPOSE 8080
USER jira
CMD ["/launch"]
