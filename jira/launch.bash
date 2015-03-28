#!/bin/bash
set -o errexit

. /usr/local/share/atlassian/common.bash

sudo own-volume
rm -f /srv/jira/home/.jira-home.lock

if [ -n "$DATABASE_URL" ]; then
  extract_database_url "$DATABASE_URL" DB /srv/jira/base/lib
  DB_JDBC_URL="$(xmlstarlet esc "$DB_JDBC_URL")"
  SCHEMA=''
  if [ "$DB_TYPE" != "mysql" ]; then
    SCHEMA='<schema-name>public</schema-name>'
  fi

  cat <<END > /srv/jira/home/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>$DB_TYPE</database-type>
  $SCHEMA
  <jdbc-datasource>
    <url>$DB_JDBC_URL</url>
    <driver-class>$DB_JDBC_DRIVER</driver-class>
    <username>$DB_USER</username>
    <password>$DB_PASSWORD</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
  </jdbc-datasource>
</jira-database-config>
END
fi

# replace front-end reverse proxy setting in server.xml
cat /srv/jira/site/conf/server.xml | sed -e "s,@@PROXY_NAME@@,$PROXY_NAME," -e "s,@@PROXY_PORT@@,$PROXY_PORT," -e "s,@@PROXY_SCHEME@@,$PROXY_SCHEME," > /tmp/server.xml
cp /tmp/server.xml /srv/jira/site/conf/server.xml

export CATALINA_BASE=/srv/jira/site
/srv/jira/base/bin/start-jira.sh -fg
