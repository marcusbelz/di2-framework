CREATE SCHEMA [sec]
    AUTHORIZATION [dbo];




GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Security Layer', @level0type = N'SCHEMA', @level0name = N'sec';

