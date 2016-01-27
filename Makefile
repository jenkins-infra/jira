IMAGENAME=jenkinsciinfra/jira
TAG=$(shell date '+%Y%m%d_%H%M%S')

image: build/jira.docker

tag: image
	docker tag ${IMAGENAME} ${IMAGENAME}:${TAG}

clean:
	rm -rf build

startdb:
	# start a database instance
	docker run --name mariadb -d -p 3306:3306 \
		-e MYSQL_ROOT_PASSWORD=s3cr3t \
		-e MYSQL_USER=jira \
		-e MYSQL_PASSWORD=raji \
		-e MYSQL_DATABASE=jiradb \
		mariadb
	#echo "Waiting for MariaDB to come up"
	sleep 15
	echo "SET GLOBAL binlog_format = 'ROW';" | docker exec -i mariadb mysql --user=root --password=s3cr3t jiradb

restoredb:
	# restore dump from DB
	gunzip -c backup.db.gz | docker exec -i mariadb mysql --user=jira --password=raji jiradb
	# tweak database for test
	cat tweak.sql | docker exec -i mariadb mysql --user=jira --password=raji jiradb

restorefs:
	[ ! -d data ] || sudo rm -rf data
	mkdir data
	cd data; tar xvzf ../backup.fs.gz
	sudo chown -R 2001:2001 data

startldap:
	@docker rm ldap || true
	docker run -d --name ldap \
            -p 9389:389 jenkinsciinfra/mock-ldap

run: build/jira.docker
	# start JIRA
	@docker rm jira > /dev/null 2>&1 || true
	docker run -t -i --name jira \
		--link mariadb:db \
		--link ldap:ldap.jenkins-ci.org \
		-e PROXY_NAME=localhost \
		-e PROXY_PORT=8080 \
		-e PROXY_SCHEME=http \
		-e JAVA_OPTS="-Xmx261m -Xms250m" \
		-v `pwd`/data:/srv/jira/home \
		-p 8080:8080 -e DATABASE_URL=mysql://jira:raji@db/jiradb ${IMAGENAME}


build/jira.docker: jira/Dockerfile jira/launch.bash $(shell find jira/site/ -type f)
	@mkdir build || true
	docker build -t ${IMAGENAME} jira
	touch $@

data:
	# extract dataset
	mkdir data
	cd data && tar xvzf ../backup.fs.gz
