:CONNECT dev-sql-enterpriseconfigurationstore

USE EnterpriseConfigurationStore

/*
SELECT c.ConfigurationValue, 
CHARINDEX('esb', c.ConfigurationValue),
SUBSTRING(c.ConfigurationValue, 0, CHARINDEX('esb', c.ConfigurationValue)) + 'lightningproxy' + SUBSTRING(c.ConfigurationValue, CHARINDEX('esb', c.ConfigurationValue) + 3, 8000) ,
*
FROM dbo.Configuration AS c
INNER JOIN CodesDynamic.Application AS a ON a.Application_ID = c.Application_ID
WHERE --c.ConfigurationValue LIKE '%central%' AND 
c.ConfigurationValue LIKE '%esb%'
and c.partner_id != 6
order by c.configurationvalue
*/

BEGIN TRAN

DECLARE @updated TABLE 
(
    Configuration_ID int,
    ConfigurationKey VARCHAR(MAX),
    ConfigurationValue_Before VARCHAR(MAX),
    ConfigurationValue_After VARCHAR(MAX)
)

UPDATE dbo.Configuration
SET 
    ConfigurationValue = SUBSTRING(ConfigurationValue, 0, CHARINDEX('esb', ConfigurationValue)) + 'lightningproxy' + SUBSTRING(ConfigurationValue, CHARINDEX('esb', ConfigurationValue) + 3, 8000),
    UpdatedBy = 'jeremy.novak@fcsamerica.com',
    UpdatedOn = GETDATE() 
OUTPUT 
    Inserted.Configuration_ID,
    inserted.ConfigurationKey,
    Deleted.ConfigurationValue,
    Inserted.ConfigurationValue
INTO 
    @updated
WHERE --c.ConfigurationValue LIKE '%central%' AND 
ConfigurationValue LIKE '%esb%'
and partner_id != 6

SELECT * 
FROM @updated AS u
ORDER BY u.ConfigurationValue_After

--SELECT TOP 100 *
--FROM dbo.Configuration AS c
--ORDER BY c.UpdatedOn DESC 

rollback tran
--commit tran




--SELECT *
--FROM dbo.Configuration AS c
--ORDER BY c.CreatedOn DESC 

--UPDATE dbo.Configuration
--SET Deleted = 0
--WHERE Configuration_ID IN (9908, 9907, 9906)