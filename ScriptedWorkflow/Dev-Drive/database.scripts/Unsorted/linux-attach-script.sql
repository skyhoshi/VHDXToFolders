USE [master];
GO
IF(EXISTS (SELECT * FROM sys.databases WHERE name='LightningProxy'))BEGIN
    PRINT 'FOUND';
END;
ELSE BEGIN
    PRINT 'Not Found';
    CREATE DATABASE [LightningProxy]
    ON  (FILENAME=N'/var/opt/mssql/data/LightningProxy.mdf'),
        (FILENAME=N'/var/opt/mssql/data/LightningProxy_log.ldf')
    FOR ATTACH;
END;
GO
USE [master];
GO

/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [lightningproxy_local]
WITH PASSWORD=N'password-for-local-dev-only', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO
ALTER LOGIN [lightningproxy_local] ENABLE;
GO
USE LightningProxy;
GO
CREATE USER [lightningproxy_local] FOR LOGIN [lightningproxy_local]
WITH DEFAULT_SCHEMA=[dbo];
GO
ALTER ROLE [LightningProxy_Role] ADD MEMBER [lightningproxy_local];
GO