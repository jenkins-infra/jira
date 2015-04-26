# Upgrade Notes

## From 5.0.6 to 6.4.2
### InnoDB backend for cwd_membership & cwd_user_attributes
During upgrade, index creation failed on these tables with an error like the following:
```
SQL Exception while executing the following:
CREATE INDEX idx_mem_dir_parent_child ON cwd_membership (lower_parent_name, lower_child_name, membership_type, directory_id)
Error was: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Specified key was too long; max key length is 1000 bytes
2015-04-26 16:01:24,928 localhost-startStop-1 ERROR      [core.entity.jdbc.DatabaseUtil] Could not create missing indices for entity "UserAttribute"
```
This problem is described in [JRA-24124](https://jira.atlassian.com/browse/JRA-24124), which recommend changing storage engine to InnoDB. Thus the following maintenance commands are necessary:
```
ALTER TABLE cwd_membership ENGINE=InnoDB;
ALTER TABLE cwd_user_attributes ENGINE=InnoDB;
```

### Long processing on UpgradeTask_Build6040
It takes a long time during this process, which shows the following output in the log:
```
Performing Upgrade Task: Map existing usernames to userkeys for rename user.
```
This process can be monitored via `SELECT coount(*) FROM app_user;` on the server. The size of this table has to go up to 38000+ before this finishes.

### freedom sponsor plugin fails
Page rendering fails with the following NPE:
```
  Caused by: java.lang.NullPointerException
	  at org.freedomsponsors.plugins.jira.SponsorThis.getContextMap(SponsorThis.java:27)
	  at com.atlassian.jira.plugin.webfragment.contextproviders.AbstractJiraContextProvider.getContextMap(AbstractJiraContextProvider.java:32)
	  at com.atlassian.plugin.web.model.AbstractWebItem.getContextMap(AbstractWebItem.java:30)
	  at com.atlassian.plugin.web.model.DefaultWebLabel.getDisplayableLabel(DefaultWebLabel.java:55)
	  at com.atlassian.plugin.web.DefaultWebInterfaceManager$WebItemConverter.apply(DefaultWebInterfaceManager.java:306)
	  at com.atlassian.plugin.web.DefaultWebInterfaceManager$WebItemConverter.apply(DefaultWebInterfaceManager.java:290)
```
To correct this problem, I removed the freedom sponsor plugins from `$JIRA_HOME/plugins/installed-plugins`.
