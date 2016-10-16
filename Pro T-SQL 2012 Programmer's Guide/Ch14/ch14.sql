--------------------------------------------------------------------------
-- Listing 14-1. Registering a CLR Integration Assembly with SQL Server --
--------------------------------------------------------------------------
EXEC sp_configure 'CLR Enabled';
RECONFIGURE;

CREATE ASSEMBLY ApressExamples
AUTHORIZATION dbo
FROM N'C:\MyApplication\ Apress.Examples.DLL'
WITH PERMISSION_SET = SAFE;
GO

---------------------------------------------------------
-- Listing 14-3. Creating CLR UDF from Assembly Method --
---------------------------------------------------------
CREATE FUNCTION dbo.EmailMatch (@input nvarchar(4000))
RETURNS bit
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME ApressExamples.[Apress.Examples.UDFExample].EmailMatch
GO

------------------------------------------------------------------------
-- Listing 14-4. Validating E-mail Addresses with Regular Expressions --
------------------------------------------------------------------------
SELECT 
    'nospam-123@yahoo.com' AS Email,
    dbo.EmailMatch (N'nospam-123@yahoo.com') AS Valid 
UNION 
SELECT 
    '123@456789',
    dbo.EmailMatch('123@456789') 
UNION 
    SELECT 'BillyG@HOTMAIL.COM',
    dbo.EmailMatch('BillyG@HOTMAIL.COM');
GO

-----------------------------------------------------------------------
-- Listing 14-6. CREATE ASSEMBLY with EXTERNAL_ACCESS Permission Set --
-----------------------------------------------------------------------
CREATE ASSEMBLY ApressExample
AUTHORIZATION dbo
FROM N'C:\MyApplication\ Apress.Example.DLL'
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

--------------------------------------------------
-- Listing 14-7. Querying a CLR Integration TVF --
--------------------------------------------------
CREATE FUNCTION dbo.GetYahooNews()
RETURNS TABLE(title nvarchar(256), link nvarchar(256), pubdate datetime, description nvarchar(max))
AS EXTERNAL NAME ApressExamples.[Apress.Examples.YahooRSS].GetYahooNews
GO

SELECT
    title,
    link,
    pubdate,
    description 
FROM dbo.GetYahooNews();
GO

------------------------------------------------------------------
-- Listing 14-9. Executing the GetEnvironmentVars CLR Procedure --
------------------------------------------------------------------
CREATE PROCEDURE dbo.GetEnvironmentVars
AS EXTERNAL NAME ApressExamples.[Apress.Examples.SampleProc].GetEnvironmentVars;
GO

EXEC dbo.GetEnvironmentVars;
GO

-----------------------------------------------------------
-- Listing 14-11. Retrieving Statistical Ranges with UDA --
-----------------------------------------------------------
CREATE AGGREGATE Range (@value float) RETURNS float
EXTERNAL NAME ApressExamples.[Apress.Examples.Range];
GO

SELECT
    ProductID,
    dbo.Range(UnitPrice) AS UnitPriceRange 
FROM Sales.SalesOrderDetail 
WHERE UnitPrice > 0 
GROUP BY ProductID;
GO

-------------------------------------------------------------
-- Listing 14-13. Calculating Median Unit Price with a UDA --
-------------------------------------------------------------
CREATE AGGREGATE dbo.Median (@value float) RETURNS float
EXTERNAL NAME ApressExamples.[Apress.Examples.Median];
GO

SELECT
    ProductID,
    dbo.Median(UnitPrice) AS MedianUnitPrice 
FROM Sales.SalesOrderDetail 
GROUP BY ProductID;
GO

------------------------------------------------------------------------------
-- Listing 14-17. Creation of the CLR Trigger to Validate an E-mail Address --
------------------------------------------------------------------------------
CREATE TRIGGER atr_Person_EmailAddress_ValidateEmail
ON Person.EmailAddress
AFTER INSERT, UPDATE
AS EXTERNAL NAME ApressExamples.[Apress.Examples.Triggers].EmailAddressTrigger;
GO

------------------------------------------------------
-- Listing 14-18. Setting an Invalid E-mail Address --
------------------------------------------------------
UPDATE Person.EmailAddress
SET EmailAddress = 'pro%sql@apress@com'
WHERE EmailAddress = 'dylan0@adventure-works.com';
GO

------------------------------------------------------------------
-- Listing 14-19. UPDATE Statement Modified to Handle the Error --
------------------------------------------------------------------
BEGIN TRY
    UPDATE Person.EmailAddress
    SET EmailAddress = 'pro%sql@apress@com'
    WHERE EmailAddress = 'dylan0@adventure-works.com';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 3991
        RAISERROR('invalid email address', 16, 10)
END CATCH
GO

----------------------------------------------------------------
-- Listing 14-20. T-SQL Trigger to Validate an E-mail Address --
----------------------------------------------------------------
CREATE TRIGGER atr_Person_EmailAddress_ValidateEmail
ON Person.EmailAddress
AFTER INSERT, UPDATE
AS BEGIN
    IF @@ROWCOUNT = 0 RETURN

    IF EXISTS (SELECT * FROM inserted WHERE dbo.EmailMatch(EmailAddress) = 0)
    BEGIN
        RAISERROR('an email is invalid', 16, 10)
        ROLLBACK TRANSACTION        
    END

END;
GO