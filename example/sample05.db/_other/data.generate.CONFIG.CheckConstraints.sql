-- --------------------------------------------------------------------------------
-- Author     : Marcus Belz
-- Create date: 01.01.2018
-- Description: Inserts check constraints into table [CONFIG].[CheckConstraint]
-- --------------------------------------------------------------------------------
-- Check constraints will be used for conducting a technical check of the 
-- convertibility of the source data. A constraint is nothing else but a WHERE 
-- clause, that helps identifying non convertible data.
-- Constraints can be derived from the meta data in the table 
-- [CONFIG].[TableMetadata]. However, there are constraints that cannot be 
-- derived from the meta data, such as primary keys, alternate keys, value ranges, 
-- etc. These constraints must be added 'manually' by using table constructors in 
-- this script
--
-- The statement in this script generates the following check constraints:
--    # CheckTextLength
--      The text length is determined by the underlying datatype. The maximum
--      text length that fits into a nvachar(100) column is 100 characters. Please 
--      note, that the constraint checks the bytes of the string and not the number 
--      of characters.
--
--      Example: DATALENGTH([column_E1]) > 200
--
--    # CheckConvertibility 
--      A source value will be converted by using the SQL function TRY_CONVERT. 
--      TRY_CONVERT returns NULL if a value cannot be converted into the target 
--      data type. A comparison similar to like 'source value is NOT NULL and 
--      converted value is NULL' identifies a problem with the convertibility.
--      The function [dbo].[fnIsNullOrEmpty] checks either NULLs or empty strings. 
--      Optionally - as in this case - the incoming value will be left and right 
--      trimmed before the check (second parameter equals 1). 
--      If [dbo].[fnIsNullOrEmpty] returns 0, then the incoming value is neither 
--      NULL nor an empty (trimmed) string.
--
--      Example: [dbo].[fnIsNullOrEmpty]([ColumnName_E1], 1) = 0 AND [ColumnName] IS NULL
--
--    # CheckPrimaryKey
--      A primary key cannot be configured in T1 tables. If they were configured, 
--      rows with duplicate primary keys would be rejected when loading data from 
--      E1 to T1. There is a procedure 'spInsertErrorCheckUniqueIdColumns' checking 
--      the uniqueness of a set of specified columns. 
--
--      Example: EntitySchema, EntityName
--
--    # AlternatKey 
--      ...the same applies to alternate keys.
--
--    # CheckNotNullable1
--      Columns that are declared as not nullable must be checked, whether the 
--      source provides values for this column. All columns that are declared as 
--      not nullable will be checked. Missing values will be logged as errors.
--
--      Example: [dbo].[fnIsNullOrEmpty]([ColumnName_E1], 1) = 1
--
--    # CheckNotNullable2
--      In some cases you may want to know whether the source provides values for 
--      a certain column. Missing values are not necessarily errors. For these 
--      cases the table TableMetadata provides the column [NullHandling], where 
--      you can state the error type (E, W, I) that will be logged with missing 
--      values.
--
--      Example: [dbo].[fnIsNullOrEmpty]([ColumnName_E1], 1) = 1
--
--    # CheckUserDefinedConstraints
--      Finally, you can defined any check that is based on a valid WHERE that is 
--      applicable on the table that is check. For exampe you may want to check the 
--      range of a value or whether a value falls between two values.
--
--      Example:      [I_VALUE] NOT BETWEEN [I_MIN] AND  [I_MAX]
--               -or- [I_VALUE] > 10000
-- --------------------------------------------------------------------------------
-- History
-- --------------------------------------------------------------------------------
-- 20180101 Marcus Belz
--          Created
-- --------------------------------------------------------------------------------

TRUNCATE TABLE [CONFIG].[CheckConstraint];

WITH 
CTE_CheckUserDefinedConstraints AS
(
   SELECT 
       [ProcedureName]
      ,[ErrorType]
      ,[Task]
      ,[Entity]
      ,[Step]
      ,[SchemaName]
      ,[TableName]
      ,[Id1_FieldName]
      ,[Id2_FieldName]
      ,[Id3_FieldName]
      ,[Check_FieldName]
      ,[Constraint]
      ,[MaxOccurance]
      ,[Message]
      ,[Description]
      ,[ActiveFlag]
      ,[ManualFlag]
   FROM 
      (VALUES
           ('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateCreated'    , '[DateCreated_Count]     > 60 AND [DateCreated_Count]     <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateModified'   , '[DateModified_Count]    > 60 AND [DateModified_Count]    <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'MappedToContact', '[MappedToContact_Count] > 60 AND [MappedToContact_Count] <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'IPv4Address'    , '[IPv4Address_Count]     > 60 AND [IPv4Address_Count]     <= 400', NULL, '60 < value <= 400', NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Salutation'     , '[Salutation_Count]      > 1 AND [Salutation_Count]       <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'FirstName'      , '[FirstName_Count]       > 1 AND [FirstName_Count]        <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'LastName'       , '[LastName_Count]        > 1 AND [LastName_Count]         <= 5'  , NULL, '1 < value <= 5'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field1'         , '[Field1_Count]          > 1 AND [Field1_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field2'         , '[Field2_Count]          > 1 AND [Field2_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field3'         , '[Field3_Count]          > 1 AND [Field3_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'W', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field4'         , '[Field4_Count]          > 1 AND [Field4_Count]           <= 3'  , NULL, '1 < value <= 3'   , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Salutation'     , '[Salutation_Count]      > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'FirstName'      , '[FirstName_Count]       > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'LastName'       , '[LastName_Count]        > 5'                                    , NULL, 'value >   5'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field1'         , '[Field1_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field2'         , '[Field2_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field3'         , '[Field3_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'Field4'         , '[Field4_Count]          > 3'                                    , NULL, 'value >   3'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateCreated'    , '[DateCreated_Count]     > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'DateModified'   , '[DateModified_Count]    > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'MappedToContact', '[MappedToContact_Count] > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
          ,('spInsertErrorCheckConstraint', 'E', NULL, '[T1].[Test]' , 'Check value in range', 'T1', 'Test' , 'ID', NULL, NULL, 'IPv4Address'    , '[IPv4Address_Count]     > 400'                                  , NULL, 'value > 400'      , NULL, 1, 1)
      )
      AS UserDefinedConstraints ([ProcedureName], [ErrorType], [Task], [Entity], [Step], [SchemaName], [TableName], [Id1_FieldName], [Id2_FieldName], [Id3_FieldName], [Check_FieldName], [Constraint], [MaxOccurance], [Message], [Description], [ActiveFlag], [ManualFlag])
)
INSERT INTO [CONFIG].[CheckConstraint]
(
    [ProcedureName]
   ,[ErrorType]
   ,[Task]
   ,[Entity]
   ,[Step]
   ,[SchemaName]
   ,[TableName]
   ,[Id1_FieldName]
   ,[Id2_FieldName]
   ,[Id3_FieldName]
   ,[Check_FieldName]
   ,[Constraint]
   ,[MaxOccurance]
   ,[Message]
   ,[Description]
   ,[ActiveFlag]
   ,[ManualFlag]
)
SELECT  [ProcedureName], [ErrorType], [Task], [Entity], [Step], [SchemaName], [TableName], [Id1_FieldName], [Id2_FieldName], [Id3_FieldName], [Check_FieldName], [Constraint], [MaxOccurance], [Message], [Description], [ActiveFlag], [ManualFlag] FROM CTE_CheckUserDefinedConstraints
