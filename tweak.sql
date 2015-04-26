-- edit JIRA DB to connect to test LDAP
UPDATE cwd_directory_attribute SET attribute_value = 's3cr3t' WHERE attribute_name='ldap.password';
UPDATE cwd_directory_attribute SET attribute_value = 'ldap://ldap.jenkins-ci.org' WHERE attribute_name='ldap.url';

-- JIRA should be running at http://localhost:8080/
UPDATE propertyentry e INNER JOIN propertystring s ON e.id=s.id AND e.PROPERTY_KEY='jira.baseurl'
    SET s.propertyvalue='http://localhost:8080';
