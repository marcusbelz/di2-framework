-- --------------------------------------------------------------------------------
-- Author     : Narayana Vyas Kondreddi//Marcus Belz
-- Create date: 01.01.2018
-- Description: This procedure is based on a procedure written by Narayana Vyas 
--              Kondreddi. This procedure was revised to meet naming conventions 
--              and a format stlye guide.
-- Acknowledgment: 
--              This procedure is based on a procedure written by Narayana Vyas 
--              Kondreddi. This procedure was revised to meet naming conventions 
--              and a format stlye guide.
-- --------------------------------------------------------------------------------
-- Parameters : 
--    @p_sourceTableName       AS varchar(523)
--       The table/view for which the INSERT statements will be generated using the 
--       existing data
--    @p_destinationTableName  AS varchar(553) = NULL
--       Use this parameter to specify a different table name into which the data 
--       will be inserted
--    @p_includeColumnList     AS bit          = 1
--       Use this parameter to include/ommit column list in the generated INSERT 
--       statement
--    @p_from                  AS varchar(800) = NULL
--       If not NULL, then this statement woill be used instead of the FROM cLause 
--       in conjunction with @p_sourceTableName
--    @p_includeTimestamp      AS bit = 0
--       Specify 1 for this parameter, if you want to include the 
--       TIMESTAMP/ROWVERSION column's data in the INSERT statement
--    @p_debugMode             AS bit = 0
--       If @p_debugMode is set to 1, the SQL statements constructed by this 
--       procedure will be printed for later examination.
--    @p_schema                AS varchar(64) = NULL   
--       Use this parameter if you are not the owner of the table
--    @p_ommitImages           AS bit = 0
--       Use this parameter to generate INSERT statements by omitting the 
--       'image' columns
--    @p_ommitIdentity         AS bit = 0              
--       Use this parameter to ommit the identity columns
--    @p_rowLimit              AS int = NULL
--       Use this parameter to generate INSERT statements only for the TOP n rows
--    @p_columnsToInclude      AS varchar(8000) = NULL
--       List of columns to be included in the INSERT statement
--    @p_columnsToExclude      AS varchar(8000) = NULL
--       List of columns to be included in the INSERT statement
--    @p_disableConstraints    AS bit = 0
--       When 1, disables foreign key constraints and enables them after the INSERT 
--       statements.
--    @p_ommitComputedColumns  AS bit = 0
--       When 1, computed columns will not be included in the INSERT statement
-- --------------------------------------------------------------------------------
-- Return Value
--    > 0 error
--      0 = success
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20010117 Narayana Vyas Kondreddi http://vyaskn.tripod.com
--          Created
-- 20020501 Narayana Vyas Kondreddi http://vyaskn.tripod.com
--          Modified
-- 20180101 Marcus Belz https://sql.marcus-belz.de
--          Reformatted
--          Include datetime2
-- --------------------------------------------------------------------------------
CREATE PROC [dbo].[spGenerateInsertStatements]
(
    @p_sourceTableName       AS varchar(523)
   ,@p_destinationTableName  AS varchar(553) = NULL
   ,@p_includeColumnList     AS bit          = 1
   ,@p_from                  AS varchar(800) = NULL
   ,@p_includeTimestamp      AS bit = 0
   ,@p_debugMode             AS bit = 0
   ,@p_schema                AS varchar(64)
   ,@p_ommitImages           AS bit = 0
   ,@p_ommitIdentity         AS bit = 0
   ,@p_rowLimit              AS int = NULL
   ,@p_columnsToInclude      AS varchar(8000) = NULL
   ,@p_columnsToExclude      AS varchar(8000) = NULL
   ,@p_disableConstraints    AS bit = 0
   ,@p_ommitComputedColumns  AS bit = 0
)
AS
BEGIN
   SET NOCOUNT ON

   -- --------------------------------------------------------------------------------
   -- Variable declarations
   -- --------------------------------------------------------------------------------
   DECLARE @columnID        int;
   DECLARE @sql             varchar(8000);
   DECLARE @columnList      varchar(8000);
   DECLARE @columnName      varchar(128); 
   DECLARE @startInsert     varchar(786); 
   DECLARE @dataType        varchar(128); 
   DECLARE @actualValues    varchar(8000);   -- This is the string that will be finally executed to generate INSERT statements
   DECLARE @identityColumn  varchar(128);    -- Will contain the IDENTITY column's name in the table

   -- --------------------------------------------------------------------------------
   -- Variable Initialization
   -- --------------------------------------------------------------------------------
   SET @sql            = '';
   SET @identityColumn = '';
   SET @columnID       = 0;
   SET @columnName     = '';
   SET @columnList     = '';
   SET @actualValues   = '';

   -- --------------------------------------------------------------------------------
   -- Check parameters
   -- --------------------------------------------------------------------------------
   -- --------------------------------------------------------------------------------
   -- Making sure the user only uses either @p_columnsToInclude or @p_columnsToExclude
   -- --------------------------------------------------------------------------------
   IF ((@p_columnsToInclude IS NOT NULL) AND (@p_columnsToExclude IS NOT NULL))
      BEGIN
         RAISERROR ('Use either @p_columnsToInclude or @p_columnsToExclude. Do not use both the parameters at once', 16, 1);
         RETURN -1;
      END;

   -- --------------------------------------------------------------------------------
   -- Making sure the @p_columnsToInclude and @p_columnsToExclude parameters are receiving values in proper format
   -- --------------------------------------------------------------------------------
   IF ((@p_columnsToInclude IS NOT NULL) AND (PATINDEX('''%''',@p_columnsToInclude) = 0))
      BEGIN
         RAISERROR ('Invalid use of @p_columnsToInclude property', 16, 1);
         PRINT 'Specify column names surrounded by single quotes and separated by commas (eg: EXEC sp_generate_inserts titles, @p_columnsToInclude = "''title_id'',''title''")';
         RETURN -1 ;
      END;
   IF ((@p_columnsToExclude IS NOT NULL) AND (PATINDEX('''%''',@p_columnsToExclude) = 0))
      BEGIN
         RAISERROR('Invalid use of @p_columnsToExclude property', 16, 1);
         PRINT 'Specify column names surrounded by single quotes and separated by commas (Eg: EXEC sp_generate_inserts titles, @p_columnsToExclude = "''title_id'',''title''")';
         RETURN -1;
      END;

   -- --------------------------------------------------------------------------------
   -- Checking to see if the database name is specified along wih the table name
   -- Your database context should be local to the table for which you want to generate INSERT statements
   -- specifying the database name is not allowed
   -- --------------------------------------------------------------------------------
   IF (PARSENAME(@p_sourceTableName, 3)) IS NOT NULL
      BEGIN
         RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.', 16, 1)
         RETURN -1;
      END;

   -- --------------------------------------------------------------------------------
   -- Checking whether in @p_sourceTableName there is either a user table name or a 
   -- viewname. This procedure is not written to work on system tables.
   -- --------------------------------------------------------------------------------
   IF @p_schema IS NULL
      BEGIN
         IF ((OBJECT_ID(@p_sourceTableName,'U') IS NULL) AND (OBJECT_ID(@p_sourceTableName,'V') IS NULL)) 
            BEGIN
               RAISERROR('User table or view not found.', 16, 1);
               PRINT 'You may see this error, if you are not the owner of this table or view. In that case use @p_schema parameter to specify the owner name. Make sure you have SELECT permission on that table or view.';
               RETURN -1;
            END;
      END
   ELSE
      BEGIN
         IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @p_sourceTableName AND (TABLE_TYPE = 'BASE TABLE' OR TABLE_TYPE = 'VIEW') AND TABLE_SCHEMA = @p_schema)
            BEGIN
               RAISERROR('User table or view not found.', 16, 1);
               PRINT 'You may see this error, if you are not the owner of this table. In that case use @p_schema parameter to specify the owner name. Make sure you have SELECT permission on that table or view.';
               RETURN -1;
            END;
      END;

   -- --------------------------------------------------------------------------------
   -- Start building the SQL Statement
   -- --------------------------------------------------------------------------------
   IF @p_schema IS NULL 
      BEGIN
         SET @startInsert = 'INSERT INTO ' + '[' + RTRIM(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ']';
      END
   ELSE
      BEGIN
         SET @startInsert = 'INSERT INTO ' + '[' + LTRIM(RTRIM(@p_schema)) + '].' + '[' + RTRIM(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ']';
      END;


   --To get the first column's ID
   SELECT   
      @columnID = MIN([ORDINAL_POSITION])
   FROM   
      [INFORMATION_SCHEMA].[COLUMNS] (NOLOCK) 
   WHERE    
          [TABLE_NAME] = @p_sourceTableName 
      AND (    @p_schema IS NULL 
           OR [TABLE_SCHEMA] = @p_schema
          );

   -- --------------------------------------------------------------------------------
   -- Loop through all the columns of the table, to get the column names and their 
   -- data types.
   -- --------------------------------------------------------------------------------
   WHILE @columnID IS NOT NULL
      BEGIN
         SELECT    
             @columnName = QUOTENAME(COLUMN_NAME)
            ,@dataType   = DATA_TYPE 
         FROM    
            [INFORMATION_SCHEMA].[COLUMNS] (NOLOCK) 
         WHERE    
                [ORDINAL_POSITION] = @columnID 
            AND [TABLE_NAME]       = @p_sourceTableName 
            AND (   @p_schema IS NULL 
                 OR [TABLE_SCHEMA] = @p_schema
                );

         -- --------------------------------------------------------------------------------
         -- Check, wther the current column name ist part of the INCLUDE list. If not, 
         -- proceed with the next column.
         -- --------------------------------------------------------------------------------
         IF @p_columnsToInclude IS NOT NULL --Selecting only user specified columns
            BEGIN
               IF CHARINDEX( '''' + SUBSTRING(@columnName, 2, LEN(@columnName) - 2) + '''', @p_columnsToInclude) = 0 
                  BEGIN
                     GOTO SKIP_LOOP;
                  END;
            END;

         -- --------------------------------------------------------------------------------
         -- Check, wther the current column name ist part of the EXCLUDE list. If yes, 
         -- proceed with the next column.
         -- --------------------------------------------------------------------------------
         IF @p_columnsToExclude IS NOT NULL 
            BEGIN
               IF CHARINDEX( '''' + SUBSTRING(@columnName, 2, LEN(@columnName) - 2) + '''', @p_columnsToExclude) <> 0 
                  BEGIN
                     GOTO SKIP_LOOP
                  END;
            END;

         -- --------------------------------------------------------------------------------
         -- Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an 
         -- IDENTITY column.
         -- --------------------------------------------------------------------------------
         IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@p_schema,USER_NAME())) + '.' + @p_sourceTableName),SUBSTRING(@columnName,2,LEN(@columnName) - 2),'IsIdentity')) = 1 
            BEGIN
               IF @p_ommitIdentity = 0 --Determing whether to include or exclude the IDENTITY column
                  BEGIN
                     SET @identityColumn = @columnName;
                  END;
               ELSE
                  BEGIN
                     GOTO SKIP_LOOP;
                  END;
            END;
      
         -- --------------------------------------------------------------------------------
         --Making sure whether to output computed columns or not
         -- --------------------------------------------------------------------------------
         IF @p_ommitComputedColumns = 1
            BEGIN
               IF (SELECT COLUMNPROPERTY(OBJECT_ID(QUOTENAME(COALESCE(@p_schema, USER_NAME())) + '.' + @p_sourceTableName), SUBSTRING(@columnName, 2, LEN(@columnName) - 2), 'IsComputed')) = 1 
                  BEGIN
                     GOTO SKIP_LOOP;
                  END;
            END;
      
         -- --------------------------------------------------------------------------------
         -- Tables with columns of IMAGE data type are not supported for obvious reasons
         -- --------------------------------------------------------------------------------
         IF @dataType = 'image'
            BEGIN
               IF @p_ommitImages = 0
                  BEGIN
                     RAISERROR('Tables with image columns are not supported.', 16, 1);
                     PRINT 'Use @p_ommitImages = 1 parameter to generate INSERTs for the rest of the columns. DO NOT ommit Column List in the INSERT statements. If you ommit column list using @p_includeColumnList=0, the generated INSERTs will fail.';
                     RETURN -1;
                  END;
               ELSE
                  BEGIN
                     GOTO SKIP_LOOP;
                  END;
            END;

         -- --------------------------------------------------------------------------------
         -- Depending on the data type of the column the VALUES must be formatted properly 
         -- for the INSERT statement.
         -- Take care of handling columns with NULL values
         -- Make sure, not to lose any data from flot, real, money, smallmomey 
         -- or datetime columns.
         -- --------------------------------------------------------------------------------
         SET @actualValues = @actualValues  +
         CASE 
            WHEN @dataType IN ('char', 'varchar', 'nchar', 'nvarchar'          ) THEN 'COALESCE('''''''' + REPLACE(RTRIM(' + @columnName + '), '''''''', '''''''''''') + '''''''', ''NULL'')'
            WHEN @dataType IN ('datetime', 'datetime2', 'smalldatetime', 'date') THEN 'COALESCE('''''''' + RTRIM  (CONVERT(char,' + @columnName + ', 109)) + '''''''', ''NULL'')'
            WHEN @dataType IN ('uniqueidentifier'                              ) THEN 'COALESCE('''''''' + REPLACE(CONVERT(char(255), RTRIM(' + @columnName + ')), '''''''', '''''''''''') + '''''''', ''NULL'')'
            WHEN @dataType IN ('text', 'ntext'                                 ) THEN 'COALESCE('''''''' + REPLACE(CONVERT(char(8000), ' + @columnName + '), '''''''', '''''''''''') + '''''''', ''NULL'')'
            WHEN @dataType IN ('binary', 'varbinary'                           ) THEN 'COALESCE(RTRIM(CONVERT(char, ' + 'CONVERT(int, ' + @columnName + '))), ''NULL'')'  
            WHEN @dataType IN ('timestamp', 'rowversion'                       ) 
               THEN  
                  CASE 
                     WHEN @p_includeTimestamp = 0 THEN '''DEFAULT''' 
                     ELSE                             'COALESCE(RTRIM(CONVERT(char, ' + 'CONVERT(int, ' + @columnName + '))), ''NULL'')'  
           END
            WHEN @dataType IN ('float', 'real', 'money', 'smallmoney'          ) THEN 'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @columnName  + ',104)' + ')),''NULL'')' 
            ELSE 'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @columnName  + ')' + ')), ''NULL'')' 
         END   + '+' +  ''',''' + ' + ';
      
         -- --------------------------------------------------------------------------------
         -- Generating the column list for the INSERT statement
         -- --------------------------------------------------------------------------------
         SET @columnList = @columnList +  @columnName + ', ';

SKIP_LOOP:
         SELECT    
            @columnID = MIN([ORDINAL_POSITION])
         FROM    
            [INFORMATION_SCHEMA].[COLUMNS] (NOLOCK) 
         WHERE
                [TABLE_NAME]       = @p_sourceTableName 
            AND [ORDINAL_POSITION] > @columnID 
            AND (   @p_schema IS NULL 
                 OR [TABLE_SCHEMA] = @p_schema
                );
   END;

   -- --------------------------------------------------------------------------------
   -- To get rid of the extra characters that got concatenated during the last run through the loop
   -- --------------------------------------------------------------------------------
   SET @columnList   = LEFT(@columnList  , len(@columnList)   - 1);
   SET @actualValues = LEFT(@actualValues, len(@actualValues) - 6);

   IF LTRIM(@columnList) = '' 
      BEGIN
         RAISERROR('No columns to select. There should at least be one column to generate the output', 16, 1);
         RETURN -1;
      END;

   -- --------------------------------------------------------------------------------
   -- Forming the final string that will be executed, to output the INSERT statements
   -- --------------------------------------------------------------------------------
   SET @sql = 'SELECT ';

   IF @p_rowLimit > 0
      BEGIN
         SET @sql = @sql + ' TOP ' + LTRIM(STR(@p_rowLimit)) + ' ';
      END;

   SET @sql = @sql + '''' + RTRIM(@startInsert);

   IF (@p_includeColumnList <> 0)
      BEGIN
         SET @sql = @sql + ' ''+' + '''(' + RTRIM(@columnList) +  '''+' + ''')''';
      END;

   SET @sql = @sql + ' +'' VALUES (''+ ' +  @actualValues  + '+'');''' + ' AS [-- Insert statements for ''' + RTRIM(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ''']' + ' '

   IF @p_from IS NOT NULL
      BEGIN
         SET @sql = @sql + @p_from + ' ';
      END
   ELSE
      BEGIN
         SET @sql = @sql + ' FROM ';
         IF @p_schema IS NOT NULL 
            BEGIN
               SET @sql = @sql + '[' + LTRIM(RTRIM(@p_schema)) + '].' 
            END;
         SET @sql = @sql + '[' + rtrim(@p_sourceTableName) + ']' + '(NOLOCK) ';
      END;

   -- --------------------------------------------------------------------------------
   -- Determining whether to ouput any debug information
   -- --------------------------------------------------------------------------------
   IF @p_debugMode =1
      BEGIN
         PRINT '/*****START OF DEBUG INFORMATION*****';
         PRINT 'Beginning of the INSERT statement:';
         PRINT @startInsert;
         PRINT '';
         PRINT 'The column list:';
         PRINT @columnList;
         PRINT '';
         PRINT 'The SELECT statement executed to generate the INSERTs';
         PRINT @sql;
         PRINT '';
         PRINT '*****END OF DEBUG INFORMATION*****/';
         PRINT '';
      END
      
   --PRINT '--INSERTs generated by ''sp_generate_inserts'' stored procedure written by Vyas'
   --PRINT '--Build number: 22'
   --PRINT '--Problems/Suggestions? Contact Vyas @ vyaskn@hotmail.com'
   --PRINT '--http://vyaskn.tripod.com'
   --PRINT ''
   PRINT 'SET NOCOUNT ON'

   -- --------------------------------------------------------------------------------
   -- Determining whether to print IDENTITY_INSERT or not
   -- --------------------------------------------------------------------------------
   IF (@identityColumn <> '')
      BEGIN
         PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@p_schema,USER_NAME())) + '.' + QUOTENAME(@p_sourceTableName) + ' ON';
         PRINT 'GO';
         PRINT '';
      END

   -- --------------------------------------------------------------------------------
   -- 
   -- --------------------------------------------------------------------------------
   IF @p_disableConstraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@p_schema,USER_NAME())) + '.' + @p_sourceTableName, 'U') IS NOT NULL)
      BEGIN
         IF @p_schema IS NULL
            BEGIN
               SELECT 'ALTER TABLE ' + QUOTENAME(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily';
            END;
         ELSE
            BEGIN
               SELECT 'ALTER TABLE ' + QUOTENAME(@p_schema) + '.' + QUOTENAME(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily';
            END;  
         PRINT 'GO';
      END;

   -- --------------------------------------------------------------------------------
   -- All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes! 
   -- --------------------------------------------------------------------------------
   EXEC (@sql)

   --PRINT 'PRINT ''Done'''
   
   -- --------------------------------------------------------------------------------
   -- 
   -- --------------------------------------------------------------------------------
   IF @p_disableConstraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@p_schema,USER_NAME())) + '.' + @p_sourceTableName, 'U') IS NOT NULL)
      BEGIN
         IF @p_schema IS NULL
            BEGIN
               SELECT 'ALTER TABLE ' + QUOTENAME(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ' CHECK CONSTRAINT ALL'  AS '--Code to enable the previously disabled constraints';
            END
         ELSE
            BEGIN
               SELECT 'ALTER TABLE ' + QUOTENAME(@p_schema) + '.' + QUOTENAME(COALESCE(@p_destinationTableName, @p_sourceTableName)) + ' CHECK CONSTRAINT ALL' AS '--Code to enable the previously disabled constraints';
            END;
         PRINT 'GO';
      END;

   PRINT '';

   IF (@identityColumn <> '')
      BEGIN
         PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@p_schema,USER_NAME())) + '.' + QUOTENAME(@p_sourceTableName) + ' OFF';
         PRINT 'GO';
      END
   
   PRINT 'SET NOCOUNT OFF';   
   PRINT '';
   
   SET NOCOUNT OFF

   RETURN 0 
END
-- [dbo].[sp_Generate_Inserts]
-- EXEC [dbo].[sp_Generate_Inserts]
--     @p_sourceTableName       = 'DimCustomer'
--    ,@p_destinationTableName  = NULL
--    ,@p_includeColumnList     = 1
--    ,@p_from                  = NULL
--    ,@p_includeTimestamp      = 1
--    ,@p_debugMode             = 1
--    ,@p_schema                = 'dbo'
--    ,@p_ommitImages           = 1
--    ,@p_ommitIdentity         = 1
--    ,@p_rowLimit              = NULL
--    ,@p_columnsToInclude      = NULL
--    ,@p_columnsToExclude      = NULL
--    ,@p_disableConstraints    = 0
--    ,@p_ommitComputedColumns  = 0;
--    ;

/* ORIGINBAL COMMENTS by Narayana Vyas Kondreddi ************************************************************

Procedure:   sp_generate_inserts  (Build 22) 
      (Copyright © 2002 Narayana Vyas Kondreddi. All rights reserved.)
                                          
Purpose:   To generate INSERT statements from existing data. 
      These INSERTS can be executed to regenerate the data at some other location.
      This procedure is also useful to create a database setup, where in you can 
      script your data along with your table definitions.

Written by:   Narayana Vyas Kondreddi
           

Acknowledgements:
      Divya Kalra     -- For beta testing
      Mark Charsley   -- For reporting a problem with scripting uniqueidentifier columns with NULL values
      Artur Zeygman   -- For helping me simplify a bit of code for handling non-dbo owned tables
      Joris Laperre   -- For reporting a regression bug in handling text/ntext columns

Tested on:    SQL Server 7.0 and SQL Server 2000

Date created:   January 17th 2001 21:52 GMT

Date modified:   May 1st 2002 19:50 GMT

Email:       vyaskn@hotmail.com

NOTE:      This procedure may not work with tables with too many columns.
      Results can be unpredictable with huge text columns or SQL Server 2000's sql_variant data types
      Whenever possible, Use @p_includeColumnList parameter to ommit column list in the INSERT statement, for better results
      IMPORTANT: This procedure is not tested with internation data (Extended characters or Unicode). If needed
      you might want to convert the datatypes of character variables in this procedure to their respective unicode counterparts
      like nchar and nvarchar
      

Example 1:   To generate INSERT statements for table 'titles':
      
      EXEC sp_generate_inserts 'titles'

Example 2:    To ommit the column list in the INSERT statement: (Column list is included by default)
      IMPORTANT: If you have too many columns, you are advised to ommit column list, as shown below,
      to avoid erroneous results
      
      EXEC sp_generate_inserts 'titles', @p_includeColumnList = 0

Example 3:   To generate INSERT statements for 'titlesCopy' table from 'titles' table:

      EXEC sp_generate_inserts 'titles', 'titlesCopy'

Example 4:   To generate INSERT statements for 'titles' table for only those titles 
      which contain the word 'Computer' in them:
      NOTE: Do not complicate the FROM or WHERE clause here. It's assumed that you are good with T-SQL if you are using this parameter

      EXEC sp_generate_inserts 'titles', @p_from = "from titles where title like '%Computer%'"

Example 5:    To specify that you want to include TIMESTAMP column's data as well in the INSERT statement:
      (By default TIMESTAMP column's data is not scripted)

      EXEC sp_generate_inserts 'titles', @p_includeTimestamp = 1

Example 6:   To print the debug information:
  
      EXEC sp_generate_inserts 'titles', @p_debugMode = 1

Example 7:    If you are not the owner of the table, use @p_schema parameter to specify the owner name
      To use this option, you must have SELECT permissions on that table

      EXEC sp_generate_inserts Nickstable, @p_schema = 'Nick'

Example 8:    To generate INSERT statements for the rest of the columns excluding images
      When using this otion, DO NOT set @p_includeColumnList parameter to 0.

      EXEC sp_generate_inserts imgtable, @p_ommitImages = 1

Example 9:    To generate INSERT statements excluding (ommiting) IDENTITY columns:
      (By default IDENTITY columns are included in the INSERT statement)

      EXEC sp_generate_inserts mytable, @p_ommitIdentity = 1

Example 10:    To generate INSERT statements for the TOP 10 rows in the table:
      
      EXEC sp_generate_inserts mytable, @p_rowLimit = 10

Example 11:    To generate INSERT statements with only those columns you want:
      
      EXEC sp_generate_inserts titles, @p_columnsToInclude = "'title','title_id','au_id'"

Example 12:    To generate INSERT statements by omitting certain columns:
      
      EXEC sp_generate_inserts titles, @p_columnsToExclude = "'title','title_id','au_id'"

Example 13:   To avoid checking the foreign key constraints while loading data with INSERT statements:
      
      EXEC sp_generate_inserts titles, @p_disableConstraints = 1

Example 14:    To exclude computed columns from the INSERT statement:
      EXEC sp_generate_inserts MyTable, @p_ommitComputedColumns = 1
***********************************************************************************************************/


--EXEC [dbo].[spGenerateInsertStatements]  @p_sourceTableName = 'Entity'        , @p_schema = 'SRC', @p_debugMode = 1
--SELECT 1