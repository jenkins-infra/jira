# Basics
#
FROM durdn/atlassian-base
MAINTAINER Jenkins Infra team <infra@lists.jenkins-ci.org>

# Install Jira

ENV JIRA_VERSION 5.0.6
RUN curl -Lks http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz
RUN /usr/sbin/useradd --create-home --home-dir /srv/jira --groups atlassian --shell /bin/bash jira
RUN mkdir -p /srv/jira/base tar zxf /root/jira.tar.gz --strip=1 -C /srv/jira/base
RUN echo "jira.home = /srv/jira/home" > /srv/jira/base/atlassian-jira/WEB-INF/classes/jira-application.properties
RUN chown -R jira:jira /srv/jira
RUN mv /srv/jira/conf/server.xml /srv/jira/conf/server-backup.xml

ENV CONTEXT_PATH ROOT
ADD launch.bash /launch

# Launching Jira

WORKDIR /srv/jira
VOLUME ["/srv/jira/home"]
EXPOSE 8080
USER jira
CMD ["/launch"]
