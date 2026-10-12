USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [lightningproxy_local]    Script Date: 12/12/2023 9:34:42 AM ******/
CREATE LOGIN [lightningproxy_local] WITH PASSWORD=N'password-for-local-dev-only', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO


ALTER LOGIN [lightningproxy_local] ENABLE
GO


USE LightningProxy
GO

/****** Object:  User [lightningproxy_local]    Script Date: 12/12/2023 9:34:58 AM ******/
CREATE USER [lightningproxy_local] FOR LOGIN [lightningproxy_local] WITH DEFAULT_SCHEMA=[dbo]
GO

ALTER ROLE [LightningProxy_Role] ADD MEMBER [lightningproxy_local]
GO
