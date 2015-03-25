startjira: stopjira build/jira.cid
buildjira: build/jira.docker

build:
	mkdir build
	
startdb:
	# start a database instance
	sudo docker run --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=s3cr3t -e MYSQL_USER=jira -e MYSQL_PASSWORD=raji -e MYSQL_DATABASE=jiradb -d mariadb
    
restoredb:
	# restore dump from DB
	gunzip -c backup.db.gz | sudo docker exec -i mariadb mysql --user=jira --password=raji jiradb

stopjira:
	rm build/jira.docker

build/jira.cid: build/jira.docker
	# start JIRA
	sudo docker rm jira || true
	sudo docker run --name jira --cidfile=$@ --link mariadb:db -p 8080:8080 -e DATABASE_URL=mysql://jira:raji@192.168.1.95/jiradb jenkinsinfra/jira


build/jira.docker: Dockerfile launch.bash
	sudo docker build -t jenkinsinfra/jira .
	touch $@
