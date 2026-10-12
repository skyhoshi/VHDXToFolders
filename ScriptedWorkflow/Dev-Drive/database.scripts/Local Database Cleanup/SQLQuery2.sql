USE [master]
GO
--EXEC master.dbo.sp_detach_db @dbname = N'CustomerBenchmark'
GO
SELECT * FROM master.sys.databases
Where database_id > 4 
AND state = 0

