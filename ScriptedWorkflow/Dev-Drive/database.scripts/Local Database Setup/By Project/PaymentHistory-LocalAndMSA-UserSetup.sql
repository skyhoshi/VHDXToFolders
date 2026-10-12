USE [master]
GO

DECLARE @DatabaseName NVARCHAR(90) = 'PaymentHistory'
DECLARE @DatabaseRoleName NVARCHAR(90)=  @DatabaseName + '_Role'
DECLARE @UsernamePrefix NVARCHAR(90) = @DatabaseName;
DECLARE @ManagedServiceAccount NVARCHAR(90) = 'FCSAMERICA\PayHist_msa_O$'

/*CREATE the Server Login*/

DECLARE @sql nvarchar(max) = '';
SELECT @SQL = @Sql + 'USE ' + QUOTENAME('master') + ';' + char(13)
SELECT @SQL = @SQL + 'CREATE LOGIN ' + QUOTENAME(@UserNamePrefix + '_local') + ' WITH PASSWORD=N''password-for-local-dev-only'', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;' + char(13)
SELECT @SQL = @SQL + 'ALTER LOGIN ' + QUOTENAME(@UserNamePrefix + '_local') + ' ENABLE;' + char(13)
SELECT @SQL = @SQL + 'CREATE LOGIN ' + QUOTENAME(@ManagedServiceAccount) + ' FROM WINDOWS WITH DEFAULT_DATABASE=' + QUOTENAME(@DatabaseName) + ', DEFAULT_LANGUAGE=[us_english];' + char(13)
--PRINT @SQL
EXEC master.sys.sp_executesql @SQL
SELECT @SQL = ''

/*CREATE the Database Login*/
SELECT @SQL = @Sql + 'USE ' + QUOTENAME(@DatabaseName) + ';' + char(13)
SELECT @SQL = @Sql + 'CREATE USER ' + QUOTENAME(@UserNamePrefix + '_local') + ' FOR LOGIN ' + QUOTENAME(@UserNamePrefix + '_local') + ' WITH DEFAULT_SCHEMA=[dbo];' + char(13)
SELECT @SQL = @Sql + 'ALTER ROLE ' + QUOTENAME(@DatabaseRoleName) + ' ADD MEMBER ' + QUOTENAME(@UserNamePrefix + '_local')  + ';' + char(13)
SELECT @SQL = @Sql + 'CREATE USER ' + QUOTENAME(@ManagedServiceAccount) + ' FOR LOGIN ' + QUOTENAME(@ManagedServiceAccount) + ' WITH DEFAULT_SCHEMA=[dbo];' + char(13)
SELECT @SQL = @Sql + 'ALTER ROLE ' + QUOTENAME(@DatabaseRoleName) + ' ADD MEMBER ' + QUOTENAME(@ManagedServiceAccount) + ';' + char(13)
--PRINT @SQL
EXEC master.sys.sp_executesql @SQL
SELECT @SQL = ''

/*CLEAN UP*/
--Database Users
SELECT @SQL = 'USE ' + @DatabaseName + char(13)
SELECT @SQL = @SQL + 'DROP USER ' + QUOTENAME(@UserNamePrefix + '_local') + ';' + char(13)
SELECT @SQL = @SQL + 'DROP USER' + QUOTENAME(@ManagedServiceAccount) + ';' + char(13)
PRINT @SQL
--Server Logins
SELECT @SQL = 'USE master '+ char(13)
SELECT @SQL = @SQL + 'DROP LOGIN ' + QUOTENAME(@UserNamePrefix + '_local') + ';' + char(13)
SELECT @SQL = @SQL + 'DROP LOGIN' + QUOTENAME(@ManagedServiceAccount) + ';' + char(13)
PRINT @SQL
---------------- You want to copy these ones from the messages tab and run them manually. ------------------------------------------
