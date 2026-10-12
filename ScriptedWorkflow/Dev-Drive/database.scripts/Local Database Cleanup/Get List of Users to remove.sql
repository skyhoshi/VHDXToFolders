Use [master]
GO
DECLARE @YourUsername NVARCHAR(90) = 'FCSAMERICA\kernm'
DECLARE @UserNamesToRemove TABLE ( loginName NVARCHAR(128))

INSERT INTO @UserNamesToRemove
SELECT name FROM Sys.syslogins Where name not in ('',@YourUsername, 'FCSAMERICA\SQLDevAdmin_O', 'FCSAMERICA\TesterM') and name like 'FCSAMERICA\%'

SELECT * from @UserNamesToRemove;

DECLARE @SqlStatement nvarchar(max) = '';
DECLARE @loginname VARCHAR(50);

Select @SqlStatement = @SqlStatement + 'DROP LOGIN ' + QUOTENAME(loginName) + ';' FROM @UserNamesToRemove
--SELECT @SqlStatement;
--EXEC master.sys.sp_executesql @SqlStatement

