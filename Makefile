IMAGENAME=jenkinsciinfra/jira
TAG=$(shell date '+%Y%m%d_%H%M%S')

image: build/jira.docker

tag: image
	docker tag ${IMAGENAME} ${IMAGENAME}:${TAG}

push :
	docker push ${IMAGENAME}

clean:
	rm -rf build

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

startldap:
	@sudo docker rm ldap || true
	sudo docker run -d --name ldap \
            -p 9389:389 jenkinsciinfra/mock-ldap

run: build/jira.docker
	# start JIRA
	@sudo docker rm jira || true
	sudo docker run -t -i --name jira \
		--link mariadb:db \
		--link ldap:cucumber.jenkins-ci.org \
		-e PROXY_NAME=localhost \
		-e PROXY_PORT=8080 \
		-e PROXY_SCHEME=http \
		-v `pwd`/data:/srv/jira/home \
		-p 8080:8080 -e DATABASE_URL=mysql://jira:raji@db/jiradb ${IMAGENAME}


build/jira.docker: jira/Dockerfile jira/launch.bash $(shell find jira/site/ -type f)
	@mkdir build || true
	sudo docker build -t ${IMAGENAME} jira
	touch $@

data:
	# extract dataset
	mkdir data
	cd data && tar xvzf ../backup.fs.gz
