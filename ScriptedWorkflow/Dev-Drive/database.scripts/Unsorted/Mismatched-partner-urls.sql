USE LightningProxy

SELECT *
FROM dbo.ApiMapping AS am
WHERE am.PartnerNameMicro != 'FCSA'
AND am.TargetUrlTemplate LIKE '%fcsa.%'
ORDER BY am.ApiName, am.ApiVersion
