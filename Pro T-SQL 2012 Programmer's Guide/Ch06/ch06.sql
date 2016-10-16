--------------------------------------------------
-- Listing 6-1. Disabling and Enabling Triggers --
--------------------------------------------------

DISABLE TRIGGER HumanResources.EmployeeUpdateTrigger 
ON HumanResources.Employee;
GO

SELECT 
    name, 
    OBJECT_SCHEMA_NAME(parent_id) + '.' + OBJECT_NAME(parent_id) as Parent 
FROM sys.triggers 
WHERE is_disabled = 1;
GO

ENABLE TRIGGER HumanResources.EmployeeUpdateTrigger 
ON HumanResources.Employee;
GO

-- disabling and enabling all triggers on the object
DISABLE TRIGGER ALL ON HumanResources.Employee;
ENABLE TRIGGER ALL ON HumanResources.Employee;
GO

------------------------------------------------------------
-- Listing 6-2. HumanResources.EmployeeUpdateTrigger Code --
------------------------------------------------------------
CREATE TRIGGER HumanResources.EmployeeUpdateTrigger
ON HumanResources.Employee
AFTER UPDATE
NOT FOR REPLICATION
AS
BEGIN
    -- stop if no row was affected
    IF @@ROWCOUNT = 0 RETURN
    -- Turn off "rows affected" messages 
    SET NOCOUNT ON;

    -- Make sure at least one row was affected
    -- Update ModifiedDate for all affected rows
    UPDATE HumanResources.Employee
    SET ModifiedDate = GETDATE()
    WHERE EXISTS
     (
        SELECT 1
        FROM inserted i
        WHERE i.BusinessEntityID = HumanResources.Employee.BusinessEntityID
    );
END;
GO

---------------------------------------------------------------
-- Listing 6-3. Testing HumanResources.EmployeeUpdateTrigger --
---------------------------------------------------------------
UPDATE HumanResources.Employee
SET MaritalStatus = 'M'
WHERE BusinessEntityID IN (1, 2);

SELECT BusinessEntityID, NationalIDNumber, MaritalStatus, ModifiedDate 
FROM HumanResources.Employee 
WHERE BusinessEntityID IN (1, 2);
GO

------------------------------------------
-- Listing 6-4. DML Audit Logging Table --
------------------------------------------
CREATE TABLE dbo.DmlActionLog (
    EntryNum int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
    ActionType nvarchar(10) NOT NULL,
    ActionXml xml NOT NULL,
    LoginName sysname NOT NULL,
    ApplicationName sysname NOT NULL,
    HostName sysname NOT NULL,
    ActionDateTime datetime2(0) NOT NULL DEFAULT (SYSDATETIME()) 
); 
GO

--------------------------------------------
-- Listing 6-5. DML Audit Logging Trigger --
-------------------------------------------- 
CREATE TRIGGER HumanResources.DepartmentChangeAudit
ON HumanResources.Department
AFTER INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS
BEGIN
    -- stop if no row was affected
    IF @@ROWCOUNT = 0 RETURN

    -- Turn off "rows affected" messages 
    SET NOCOUNT ON;
    
    DECLARE @ActionType nvarchar(10), @ActionXml xml;

    -- Get count of inserted rows 
    DECLARE @inserted_count int = (
        SELECT COUNT(*)
        FROM inserted 
    );
    -- Get count of deleted rows 
    DECLARE @deleted_count int = (
        SELECT COUNT(*)
        FROM deleted
    );

    -- Determine the type of DML action that fired the trigger 
    SET @ActionType = CASE
        WHEN (@inserted_count > 0) AND (@deleted_count = 0) THEN N'insert' 
        WHEN (@inserted_count = 0) AND (@deleted_count > 0) THEN N'delete' 
        ELSE N'update' 
    END;

    -- Use FOR XML AUTO to retrieve before and after snapshots of the changed
    --  data  in  XML  format
    SELECT @ActionXml = COALESCE
    (
        (
            SELECT  *
            FROM  deleted
            FOR  XML  AUTO
        ),  N'<deleted/>'
    )  +  COALESCE
    (
        (
            SELECT  *
            FROM  inserted
            FOR  XML  AUTO
        ),  N'<inserted/>'
    );
    
    -- Insert a row for the logged action in the audit logging table
    INSERT INTO dbo.DmlActionLog
    (
        SchemaName,
        TableName,
        ActionType,
        ActionXml,
        LoginName,
        ApplicationName,
        HostName
    ) 
    SELECT
        OBJECT_SCHEMA_NAME(@@PROCID, DB_ID()),
        OBJECT_NAME(t.parent_id, DB_ID()),
        @ActionType,
        @ActionXml,
        SUSER_SNAME(),
        APP_NAME(),
        HOST_NAME()
    FROM sys.triggers t 
    WHERE t.object_id = @@PROCID;
END; 
GO

--------------------------------------------------------
-- Listing 6-6. Testing the DML Audit Logging Trigger --
--------------------------------------------------------
UPDATE HumanResources.Department SET Name = N'Information Technology' 
WHERE DepartmentId = 11;

INSERT INTO HumanResources.Department 
(
    Name,
    GroupName
) 
VALUES
(
    N'Customer Service', 
    N'Sales and Marketing'
);

DELETE
FROM HumanResources.Department
WHERE Name = N'Customer Service';

SELECT
    EntryNum,
    SchemaName,
    TableName,
    ActionType,
    ActionXml,
    LoginName,
    ApplicationName,
    HostName,
    ActionDateTime 
FROM dbo.DmlActionLog;
GO

----------------------------------------------
-- Listing 6-7. Turning Off Nested Triggers --
----------------------------------------------
EXEC sp_configure 'nested triggers', 0;
RECONFIGURE;
GO

-------------------------------------------------------
-- Listing 6-8. Turning Off Recursive AFTER Triggers --
-------------------------------------------------------
ALTER DATABASE AdventureWorks SET RECURSIVE_TRIGGERS OFF;
GO

----------------------------------------------------
-- Listing 6-9. Trigger to Enforce Standard Sizes --
----------------------------------------------------
CREATE TRIGGER Production.ProductEnforceStandardSizes
ON Production.Product
AFTER INSERT, UPDATE
NOT FOR REPLICATION
AS
BEGIN 
    -- Make sure at least one row was affected and either the Size or 
    -- SizeUnitMeasureCode column was changed 
    IF (@@ROWCOUNT > 0) AND (UPDATE(SizeUnitMeasureCode) OR UPDATE(Size)) 
    BEGIN
        -- Eliminate "rows affected" messages 
        SET NOCOUNT ON;
        -- Only accept recognized units of measure or NULL
        IF EXISTS
        (
            SELECT 1
            FROM inserted
            WHERE NOT
                ( SizeUnitMeasureCode IN (N'M', N'DM', N'CM', N'MM', N'IN') 
                    OR SizeUnitMeasureCode IS NULL
                ) 
            ) 
        BEGIN
            -- If the unit of measure wasn't recognized raise an error and roll back
            -- the transaction
            RAISERROR ('Invalid Size Unit Measure Code.', 10, 127);
            ROLLBACK TRANSACTION; 
        END
        ELSE
        BEGIN
            -- If the unit of measure is a recognized unit of measure then set the 
            -- SizeUnitMeasureCode to centimeters and perform the Size conversion 
            UPDATE Production.Product 
            SET SizeUnitMeasureCode = CASE 
                    WHEN Production.Product.SizeUnitMeasureCode IS NULL THEN NULL ELSE N'CM' END,
                Size = CAST ( 
                    CAST ( CAST(i.Size AS float) *
                        CASE i.SizeUnitMeasureCode
                            WHEN N'M' THEN 100.0 
                            WHEN N'DM' THEN 10.0
                            WHEN N'CM' THEN 1.0 
                            WHEN N'MM' THEN 0.10 
                            WHEN N'IN' THEN 2.54 
                        END
                    AS int 
                    ) AS nvarchar(5) 
                ) 
            FROM inserted i
            WHERE Production.Product.ProductID = i.ProductID 
            AND i.SizeUnitMeasureCode IS NOT NULL;
        END;
    END;
END; 
GO

---------------------------------------------------------------
-- Listing 6-10. Testing the Trigger by Adding a New Product --
---------------------------------------------------------------
UPDATE  Production.Product
SET Size = N'600',
    SizeUnitMeasureCode = N'MM'
WHERE  ProductId  =  680;

UPDATE  Production.Product
SET Size = N'22.85',
    SizeUnitMeasureCode = N'IN'
WHERE  ProductId  =  706;

SELECT  ProductID,
    Name,
    ProductNumber,
    Size,
    SizeUnitMeasureCode
FROM  Production.Product
WHERE  ProductID  IN  (680,  706);
GO

------------------------------------------------
-- Listing 6-11. INSTEAD OF Trigger on a View --
------------------------------------------------
CREATE TRIGGER Sales.vIndividualCustomerUpdate
ON Sales.vIndividualCustomer
INSTEAD OF UPDATE
NOT FOR REPLICATION
AS
BEGIN
    -- First make sure at least one row was affected
    IF @@ROWCOUNT = 0 RETURN
    -- Turn off "rows affected" messages 
    SET NOCOUNT ON;
    -- Initialize a flag to indicate update success 
    DECLARE @UpdateSuccessful bit = 0;

    -- Check for updatable columns in the first table
    IF UPDATE(FirstName) OR UPDATE(MiddleName) OR UPDATE(LastName)
    BEGIN
        -- Update columns in the base table
        UPDATE Person.Person
        SET FirstName = i.FirstName,
            MiddleName = i.MiddleName,
            LastName = i.LastName 
        FROM inserted i 
        WHERE i.BusinessEntityID = Person.Person.BusinessEntityID;
        
        -- Set flag to indicate success 
        SET @UpdateSuccessful = 1; 
    END;
    -- If updatable columns from the second table were specified, update those 
    -- columns in the base table 
    IF UPDATE(EmailAddress) 
    BEGIN
        -- Update columns in the base table
        UPDATE Person.EmailAddress
        SET EmailAddress = i.EmailAddress
        FROM inserted i
        WHERE i.BusinessEntityID = Person.EmailAddress.BusinessEntityID;
        
        -- Set flag to indicate success 
        SET @UpdateSuccessful = 1; 
    END;
    -- If the update was not successful, raise an error and roll back the 
    -- transaction 
    IF @UpdateSuccessful = 0 
        RAISERROR('Must specify updatable columns.', 10, 127); 
END; 
GO

-----------------------------------------------------------------
-- Listing 6-12. Updating a View Through an INSTEAD OF Trigger --
-----------------------------------------------------------------
UPDATE Sales.vIndividualCustomer
SET FirstName = N'Dave',
    MiddleName = N'Robert',
    EmailAddress = N'dave.robinett@adventure-works.com' 
WHERE BusinessEntityID = 1699;

SELECT BusinessEntityID, FirstName, MiddleName, LastName, EmailAddress
FROM Sales.vIndividualCustomer 
WHERE BusinessEntityID = 1699;
GO

----------------------------------------------------
-- Listing 6-14. CREATE TABLE DDL Trigger Example --
----------------------------------------------------
-- Create a table to log DDL CREATE TABLE actions
CREATE TABLE dbo.DdlActionLog
(
    EntryId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
    EventType nvarchar(200) NOT NULL,
    PostTime datetime NOT NULL,
    LoginName sysname NOT NULL,
    UserName sysname NOT NULL,
    ServerName sysname NOT NULL,
    SchemaName sysname NOT NULL,
    DatabaseName sysname NOT NULL,
    ObjectName sysname NOT NULL,
    ObjectType sysname NOT NULL,
    CommandText nvarchar(max) NOT NULL 
); 
GO

CREATE TRIGGER AuditCreateTable
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN 
    -- Assign the XML event data to an xml variable 
    DECLARE @eventdata xml = EVENTDATA();

    -- Shred the XML event data and insert a row in the log table
    INSERT INTO dbo.DdlActionLog
    (
        EventType,
        PostTime,
        LoginName,
        UserName,
        ServerName,
        SchemaName,
        DatabaseName,
        ObjectName,
        ObjectType,
        CommandText 
    ) 
    SELECT
        EventNode.value(N'EventType[1]', N'nvarchar(200)'),
        EventNode.value(N'PostTime[1]', N'datetime'),
        EventNode.value(N'LoginName[1]', N'sysname'),
        EventNode.value(N'UserName[1]', N'sysname'),
        EventNode.value(N'ServerName[1]', N'sysname'),
        EventNode.value(N'SchemaName[1]', N'sysname'),
        EventNode.value(N'DatabaseName[1]', N'sysname'),
        EventNode.value(N'ObjectName[1]', N'sysname'),
        EventNode.value(N'ObjectType[1]', N'sysname'),
        EventNode.value(N'(TSQLCommand/CommandText)[1]', 'nvarchar(max)') 
    FROM @eventdata.nodes('/EVENT_INSTANCE') EventTable(EventNode);
END; 
GO

-------------------------------------------------------------------------
-- Listing 6-15. Testing the DDL Trigger with a CREATE TABLE Statement --
-------------------------------------------------------------------------
CREATE TABLE dbo.MyTable (i int); 
GO

SELECT
    EntryId,
    EventType,
    UserName,
    ObjectName,
    CommandText 
FROM DdlActionLog;
GO

------------------------------------------
-- Listing 6-16. Dropping a DDL Trigger --
------------------------------------------
DROP TRIGGER AuditCreateTable
ON DATABASE;
GO

-------------------------------------------------------------------
-- Listing 6-17. Creating a Test Login and Logon Denial Schedule --
-------------------------------------------------------------------
CREATE LOGIN PublicUser WITH PASSWORD = 'p@$$w0rd';
GO

USE Master;

CREATE TABLE dbo.DenyLogonSchedule (
    UserId sysname NOT NULL,
    DayOfWeek tinyint NOT NULL,
    TimeStart time NOT NULL,
    TimeEnd time NOT NULL,
    PRIMARY KEY (UserId, DayOfWeek, TimeStart, TimeEnd)
 );
 GO

INSERT INTO dbo.DenyLogonSchedule (
    UserId,
    DayOfWeek,
    TimeStart,
    TimeEnd 
) VALUES (
    'PublicUser',
    7,
    '21:00:00',
    '23:00:00' 
 );
GO

----------------------------------------
-- Listing 6-18. Sample Logon Trigger --
----------------------------------------
USE Master;

CREATE TRIGGER DenyLogons
ON ALL SERVER
WITH EXECUTE AS 'sa'
FOR LOGON
AS
BEGIN
    IF EXISTS ( SELECT 1
        FROM Master .dbo.DenyLogonSchedule 
        WHERE UserId = ORIGINAL_LOGIN() 
        AND DayOfWeek = DATEPART(WeekDay, GETDATE()) 
        AND CAST(GETDATE() AS TIME) BETWEEN TimeStart AND TimeEnd 
    ) BEGIN
        ROLLBACK TRANSACTION;
    END; 
END;
