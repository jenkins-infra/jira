# JIRA Container for jenkins-ci.org
[![Build Status](http://ci.jenkins-ci.org/buildStatus/icon?job=infra_jira)](http://ci.jenkins-ci.org/view/Infrastructure/job/infra_jira/)

This container defines JIRA behind issues.jenkins-ci.org.
The container consists of three main pieces:

* `/srv/jira/base`: Upstream JIRA image. Ideally we don't want to touch this at all, unless we absolutely have to.
* `/srv/jira/site`: Container local customizations to JIRA image. This also acts as `$CATALINA_BASE`
* `/srv/jira/home`: Persisted portion of the JIRA data, such as attachments

The `site` portion includes our site-local customizations to JIRA, such as:

* Adjustment to JVM memory size
* Different templates for email notifications
* Customized Tomcat configurations

## How to develop this container
You can start this container with mock LDAP and DB.

At the beginning of the development session, you do the following:

* `make startldap` to start a mock LDAP container in the background
* `make startdb` to start local mariadb container in the background.

At this point, if you have access to the backup of JIRA database and home, do the following optional steps.
Note that the backup database contains sensitive information, such as the password to access production LDAP,
security vulnerabilities, and so on. So it shouldn't be passed around casually:

* retrieve database dump as `backup.db.gz`
* `make restoredb` to fill DB with a copy of production data
* retrieve JIRA_HOME dump as `backup.fs.gz`
* `make restorefs` to fill ./data with a copy of production data

If you omit the above steps, the JIRA container will start empty.

Finally, run `make run` to build and start JIRA container in the foreground.

When its initialization sequence is all done, point the browser to `http://localhost:8080/`.

Two valid users exist in mock LDAP container. 'kohsuke' and 'alice'.
'kohsuke' is a super user, 'alice' is a regular user. Password is both 'password'

To make changes to the JIRA container, press Ctrl+C to kill JIRA container,
make edits, and run `make run` again.

## TODO
* Javamelody integration (?) mainly in dbconfig.xml
* oom_adj
