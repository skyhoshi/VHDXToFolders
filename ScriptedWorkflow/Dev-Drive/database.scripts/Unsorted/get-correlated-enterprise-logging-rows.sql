DECLARE @ApplicationId INT

SELECT @ApplicationId = a.ApplicationID
FROM dbo.Application AS a
WHERE a.Name = 'LightningProxy.WebApi.External'

SELECT * 
FROM 
(
        SELECT  'Info' AS 'type', InformationLogID, SessionID, MessageTag, MachineName, UserName, DatabaseTimestamp, ServiceExecutedTimestamp, [Message], EventID, Category, 
                UserID, CustomerID, EmployeeID, DealerID , ServiceCalledTimestamp, RequestID
            FROM dbo.InformationLog el WITH (READUNCOMMITTED) 
            WHERE 
                ApplicationID = @ApplicationId
                AND el.DatabaseTimestamp > GETDATE() - .5

            UNION 

        SELECT  'Error' AS 'type', ExceptionLogID, SessionID, MessageTag, MachineName, UserName, DatabaseTimestamp, ServiceExecutedTimestamp, [Message], EventID, Category, 
                UserID, CustomerID, EmployeeID, DealerID , ServiceCalledTimestamp, RequestID
            FROM dbo.ExceptionLog el WITH (READUNCOMMITTED) 
            WHERE 
                ApplicationID = @ApplicationId
                AND el.DatabaseTimestamp > GETDATE() - .5

            UNION ALL

        SELECT  'Verbose', TraceLogID, SessionID, MessageTag, MachineName, UserName, DatabaseTimestamp, ServiceExecutedTimestamp, [Message], EventID, Category, 
                UserID, CustomerID, EmployeeID, DealerID , ServiceCalledTimestamp, RequestID
            FROM dbo.TraceLog el WITH (READUNCOMMITTED) 
            WHERE 
                ApplicationID = @ApplicationId
                AND el.DatabaseTimestamp > GETDATE() - .5

            UNION ALL

        SELECT  'Warning', WarningLogID, SessionID, MessageTag, MachineName, UserName, DatabaseTimestamp, ServiceExecutedTimestamp, [Message], EventID, Category, 
                UserID, CustomerID, EmployeeID, DealerID , ServiceCalledTimestamp, RequestID
            FROM dbo.WarningLog el WITH (READUNCOMMITTED) 
            WHERE 
                ApplicationID = @ApplicationId
                AND el.DatabaseTimestamp > GETDATE() - .5

            UNION ALL

        SELECT  'Feature', FeatureLogID, SessionID, MessageTag, MachineName, UserName, DatabaseTimestamp, ServiceExecutedTimestamp, [Message], EventID, Category, 
                UserID, CustomerID, EmployeeID, DealerID , ServiceCalledTimestamp, RequestID
            FROM dbo.FeatureLog el WITH (READUNCOMMITTED) 
            WHERE 
                ApplicationID = @ApplicationId
                AND el.DatabaseTimestamp > GETDATE() - .5
                ) ROWS
                
                --WHERE ROWS.MessageTag = 'b5866519-745a-4574-adc0-735b513e7eeb' -- externally cancelled
                --WHERE ROWS.MessageTag = '39b705d9-a882-40b0-9e9e-78328d5819e2' -- lightning proxy cancelled
                WHERE ROWS.MessageTag = 'a6757542-6e2a-446b-8f2e-d589d694b185' -- cancelled in postman

ORDER BY ROWS.ServiceExecutedTimestamp, ROWS.InformationLogID 
        