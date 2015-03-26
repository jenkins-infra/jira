startjira: stopjira build/jira.cid
buildjira: build/jira.docker
buildldap: build/ldap.docker
startldap: build/ldap.cid

clean:
	rm -rf build

build:
	mkdir build
	
startdb:
	# start a database instance
	sudo docker run --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=s3cr3t -e MYSQL_USER=jira -e MYSQL_PASSWORD=raji -e MYSQL_DATABASE=jiradb -d mariadb
    
restoredb:
	# restore dump from DB
	gunzip -c backup.db.gz | sudo docker exec -i mariadb mysql --user=jira --password=raji jiradb

build/ldap.cid: build
	sudo docker run \
			--cidfile=$@ \
			--name ldap \
            -e LDAP_DOMAIN=jenkins-ci.org \
            -e LDAP_ORGANISATION="Jenkins" \
            -e LDAP_ROOTPASS=s3cr3t \
            -p 9389:389 jenkinsinfra/ldap

restoreldap: build/ldap.cid
	sudo docker exec $(cat build/ldap.cid) slapadd \
		-h localhost -p 389 -c -x -D cn=admin,dc=mycorp,dc=com -W -f

stopjira:
	(sudo docker kill jira; sudo docker rm jira) || true
	sudo rm build/jira.cid || true

build/jira.cid: build/jira.docker
	# start JIRA
	sudo docker rm jira || true
	sudo docker run --name jira --cidfile=$@ --link mariadb:db -p 8080:8080 -e DATABASE_URL=mysql://jira:raji@db/jiradb jenkinsinfra/jira


build/jira.docker: Dockerfile launch.bash build
	sudo docker build -t jenkinsinfra/jira .
	touch $@

build/ldap.docker: ldap/Dockerfile
	sudo docker build -t jenkinsinfra/ldap ldap
	touch $@