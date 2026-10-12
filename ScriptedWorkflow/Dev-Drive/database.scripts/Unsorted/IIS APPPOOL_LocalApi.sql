:connect localhost

USE LightningProxy;

IF NOT EXISTS ( SELECT  *
                FROM    master.dbo.syslogins
                WHERE   loginname = N'IIS APPPOOL\LocalApi' )
    CREATE LOGIN [IIS APPPOOL\LocalApi] FROM WINDOWS;

IF NOT EXISTS ( SELECT  name
            FROM    sys.sysusers
            WHERE   name = 'IIS APPPOOL\LocalApi' )
    CREATE USER [IIS APPPOOL\LocalApi] FOR LOGIN [IIS APPPOOL\LocalApi];

EXEC sp_addrolemember N'LightningProxy_Role', N'IIS APPPOOL\LocalApi';
GO

