# sourced by catalina.sh upon start

# read the one shipped by Atlassian first
. /srv/jira/base/bin/setenv.sh

# tweak JVM heap settings to our liking. Remove what JIRA set, and insert our own
export JAVA_OPTS="$(echo $JAVA_OPTS | sed -e 's/-Xms[^ ]*//' -e 's/-Xmx[^ ]*//' -e 's/-XX:MaxPermSize=[^ ]*//')"
export JAVA_OPTS="-XX:MaxPermSize=256m -Xms512m -Xmx768m $JAVA_OPTS"
