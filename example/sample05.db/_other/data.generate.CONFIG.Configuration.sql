-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts data into table [CONFIG].[Configuration]
-- --------------------------------------------------------------------------------

TRUNCATE TABLE [CONFIG].[Configuration];

INSERT INTO [CONFIG].[Configuration] ([Group], [Code], [Value], [Description]) VALUES ('CheckBotCode', 'DateCreated Period' ,   60, 'Period in seconds for the identififcation of potential attacks by the columns ''DateCreated''. The process looks for half of the period into the past and the future and counts the number of records. ');
INSERT INTO [CONFIG].[Configuration] ([Group], [Code], [Value], [Description]) VALUES ('CheckBotCode', 'DateModified Period',   60, 'Period in seconds for the identififcation of potential attacks by the columns ''DateModified''. The process looks for half of the period into the past and the future and counts the number of records.');
INSERT INTO [CONFIG].[Configuration] ([Group], [Code], [Value], [Description]) VALUES ('CheckBotCode', 'MaxRows'            , 1200, 'Maximum number of records, that is regarded as potentially plausible.                                                                                                                                  ');

-- Sample Code

--DECLARE @config_MappedToContact_Threshold_W AS int;
--DECLARE @config_MappedToContact_Threshold_E AS int;
--DECLARE @config_IPv4Address_Threshold_W     AS int;
--DECLARE @config_IPv4Address_Threshold_E     AS int;
--DECLARE @config_DateCreated_Period          AS int;
--DECLARE @config_DateCreated_Threshold_W     AS int;
--DECLARE @config_DateCreated_Threshold_E     AS int;
--DECLARE @config_DateModified_Period         AS int;
--DECLARE @config_DateModified_Threshold_W    AS int;
--DECLARE @config_DateModified_Threshold_E    AS int;
--DECLARE @config_Keyword_Threshold_W         AS int;
--DECLARE @config_Keyword_Threshold_E         AS int;

--SELECT @config_MappedToContact_Threshold_W = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'MappedToContact Threshold W') AS int);
--SELECT @config_MappedToContact_Threshold_E = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'MappedToContact Threshold E') AS int);
--SELECT @config_IPv4Address_Threshold_W     = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'IPv4Address Threshold W'    ) AS int);
--SELECT @config_IPv4Address_Threshold_E     = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'IPv4Address Threshold E'    ) AS int);
--SELECT @config_DateCreated_Period          = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateCreated Period'         ) AS int);
--SELECT @config_DateCreated_Threshold_W     = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateCreated Threshold W'    ) AS int);
--SELECT @config_DateCreated_Threshold_E     = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateCreated Threshold E'    ) AS int);
--SELECT @config_DateModified_Period         = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateModified Period'        ) AS int);
--SELECT @config_DateModified_Threshold_W    = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateModified Threshold W'   ) AS int);
--SELECT @config_DateModified_Threshold_E    = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'DateModified Threshold E'   ) AS int);
--SELECT @config_Keyword_Threshold_W         = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'Keyword Threshold W'        ) AS int);
--SELECT @config_Keyword_Threshold_E         = CAST([CONFIG].[fnFetchConfigValue]('CheckBotAttack', 'Keyword Threshold E'        ) AS int);

--      SELECT @config_MappedToContact_Threshold_W AS [Value], 'CheckBotAttack' AS [Group], 'MappedToContact Threshold W' AS [Code]
--UNION SELECT @config_MappedToContact_Threshold_E           , 'CheckBotAttack'           , 'MappedToContact Threshold E'
--UNION SELECT @config_IPv4Address_Threshold_W               , 'CheckBotAttack'           , 'IPv4Address Threshold W'    
--UNION SELECT @config_IPv4Address_Threshold_E               , 'CheckBotAttack'           , 'IPv4Address Threshold E'    
--UNION SELECT @config_DateCreated_Period                    , 'CheckBotAttack'           , 'DateCreated Period'         
--UNION SELECT @config_DateCreated_Threshold_W               , 'CheckBotAttack'           , 'DateCreated Threshold W'    
--UNION SELECT @config_DateCreated_Threshold_E               , 'CheckBotAttack'           , 'DateCreated Threshold E'    
--UNION SELECT @config_DateModified_Period                   , 'CheckBotAttack'           , 'DateModified Period'        
--UNION SELECT @config_DateModified_Threshold_W              , 'CheckBotAttack'           , 'DateModified Threshold W'   
--UNION SELECT @config_DateModified_Threshold_E              , 'CheckBotAttack'           , 'DateModified Threshold E'   
--UNION SELECT @config_Keyword_Threshold_W                   , 'CheckBotAttack'           , 'Keyword Threshold W'        
--UNION SELECT @config_Keyword_Threshold_E                   , 'CheckBotAttack'           , 'Keyword Threshold E'        
--ORDER BY [Group], [Code];
