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
	sudo docker run --name mariadb -d -p 3306:3306 \
		-e MYSQL_ROOT_PASSWORD=s3cr3t \
		-e MYSQL_USER=jira \
		-e MYSQL_PASSWORD=raji \
		-e MYSQL_DATABASE=jiradb \
		mariadb
    
restoredb:
	# restore dump from DB
	gunzip -c backup.db.gz | sudo docker exec -i mariadb mysql --user=jira --password=raji jiradb
	# tweak database for test
	cat tweak.sql | sudo docker exec -i mariadb mysql --user=jira --password=raji jiradb

build/ldap.cid: build
	@sudo docker rm ldap || true
	sudo docker run \
			--cidfile=$@ \
			--name ldap \
            -e LDAP_DOMAIN=jenkins-ci.org \
            -e LDAP_ORGANISATION="Jenkins" \
            -e LDAP_ROOTPASS=s3cr3t \
            -p 9389:389 jenkinsinfra/ldap

restoreldap: build/ldap.cid
	cat ldap/data.ldif | sudo docker exec -i `cat build/ldap.cid` ldapadd -H ldap://localhost -x -D cn=admin,dc=jenkins-ci,dc=org -w s3cr3t

stopjira:
	(sudo docker kill jira; sudo docker rm jira) || true
	sudo rm build/jira.cid || true

build/jira.cid: build/jira.docker
	# start JIRA
	@sudo docker rm jira || true
	sudo docker run --name jira --cidfile=$@ \
		--link mariadb:db \
		--link ldap:cucumber.jenkins-ci.org \
		-v `pwd`/data:/srv/jira/home \
		-p 8080:8080 -e DATABASE_URL=mysql://jira:raji@db/jiradb jenkinsinfra/jira


build/jira.docker: Dockerfile launch.bash build
	sudo docker build -t jenkinsinfra/jira .
	touch $@

build/ldap.docker: ldap/Dockerfile
	sudo docker build -t jenkinsinfra/ldap ldap
	touch $@

data:
	# extract dataset
	mkdir data
	cd data && tar xvzf ../backup.fs.gz