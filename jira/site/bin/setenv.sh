# sourced by catalina.sh upon start

# read the one shipped by Atlassian first
. /srv/jira/base/bin/setenv.sh

# tweak JVM heap settings to our liking. Remove what JIRA set, and insert our own
export JAVA_OPTS="$(echo $JAVA_OPTS | sed -e 's/-Xms[^ ]*//' -e 's/-Xmx[^ ]*//' -e 's/-XX:MaxPermSize=[^ ]*//')"
export JAVA_OPTS="-XX:MaxPermSize=256m -Xms1536m -Xmx3072m $JAVA_OPTS"
# Version 7.4 Add Garbage collection logging on Jira Startup
export JAVA_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=20M -Xloggc:/srv/jira/home/logs/atlassian-jira-gc-`date +%F_%H-%M-%S`.log $JAVA_OPTS"
