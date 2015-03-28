# JIRA Container for issues.jenkins-ci.org

Still very much a work in progress.

## Start JIRA
* `make startdb` to start local mariadb instance.
* retrieve database dump as `backup.db.gz`
* `make restoredb` to fill DB with a copy of production data
* `make startldap` to start a local LDAP instance
* `make restoreldap` to fill LDAP with a test data
* `make startjira` to start JIRA

Note that the database dump contains sensitive information, such as the password to access LDAP, security
vulnerabilities, and so on. So it shouldn't be passed around casually.

When it's all done, point the browser to `http://localhost:8080/`. Login as username 'kohsuke' password 'password',
then go to `http://localhost:8080/secure/admin/IndexAdmin.jspa` to perform re-index.

At this point your JIRA is up & running, and you should be able to navigate around.

## The way JIRA VM is put together
The VM consists of three main pieces:

* `/srv/jira/base`: Upstream JIRA image. Ideally we don't want to touch this at all, unless we absolutely have to.
* `/srv/jira/site`: Container local customizations to JIRA image. This also acts as `$CATALINA_BASE`
* `/srv/jira/home`: Persisted portion of the JIRA data, such as attachments

## TODO
* Define the way to tweak JVM configuration, such as heap size
* Javamelody integration (?) mainly in dbconfig.xml
* oom_adj