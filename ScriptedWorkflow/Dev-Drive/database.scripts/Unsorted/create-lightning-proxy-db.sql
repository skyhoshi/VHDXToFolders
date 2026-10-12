USE master;

CREATE DATABASE LightningProxy
ON PRIMARY
( NAME = LightningProxy_dat,
  FILENAME = '/var/opt/mssql/data/LightningProxy.mdf',
  SIZE = 2MB,
  MAXSIZE = 5MB,
  FILEGROWTH = 1MB );
GO

