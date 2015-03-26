-- edit JIRA DB to connect to test LDAP
UPDATE cwd_directory_attribute SET attribute_value = 's3cr3t' WHERE attribute_name='ldap.password'