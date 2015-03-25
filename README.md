# JIRA Container for issues.jenkins-ci.org

Still very much a work in progress.

## Start JIRA
* `make startdb` to start local mariadb instance.
* retrieve database dump as `backup.db.gz`
* `make restoredb` to fill DB with a copy of production data
* `make startjira` to start JIRA

Note that the database dump contains sensitive information, such as the password to access LDAP

## TODO
* Need to run a copy of LDAP to be able to login
* JIRA needs to be told that it's running at `http://localhost:8080/` and not `https://issues.jenkins-ci.org/`

