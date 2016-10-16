/*Listing 18 - 1. Creating a Narrow Table */
CREATE TABLE dbo.SmallRows
(
Id int NOT NULL,
LastName nchar(50) NOT NULL,
FirstName nchar(50) NOT NULL,
MiddleName nchar(50) NULL
);
INSERT INTO dbo.SmallRows
(
Id,
LastName,
FirstName,
MiddleName
)
SELECT
BusinessEntityID,
LastName,
FirstName,
MiddleName
FROM Person.Person;

/*Listing 18 - 2. Looking at Data Allocations for the SmallRows Table */
SELECT
sys.fn_PhysLocFormatter(%%physloc%%) AS [Row_Locator],
Id
FROM dbo.SmallRows;

/*Listing 18 - 3. Creating a Table with Wide Rows */
CREATE TABLE dbo.LargeRows
(
Id int NOT NULL,
LastName nchar(600) NOT NULL,
FirstName nchar(600) NOT NULL,
MiddleName nchar(600) NULL
);
INSERT INTO dbo.LargeRows
(
Id,
LastName,
FirstName,
MiddleName
)
SELECT
BusinessEntityID,
LastName,
FirstName,
MiddleName
FROM Person.Person;
SELECT
sys.fn_PhysLocFormatter(%%physloc%%) AS [Row_Locator],
Id
FROM dbo.LargeRows;

/*Listing 18 - 4. I/O Comparison of Narrow and Wide Tables */
SET STATISTICS IO ON;
SELECT
Id,
LastName,
FirstName,
MiddleName
FROM dbo.SmallRows;
SELECT
Id,
LastName,
FirstName,
MiddleName
FROM dbo.LargeRows;

/*Listing 18 - 5. Estimating Row Compression Space Savings */
EXEC sp_estimate_data_compression_savings 'Production',
'TransactionHistory',
NULL,
NULL,
'ROW';

/*Listing 18 - 5. Estimating Row Compression Space Savings */
EXEC sp_estimate_data_compression_savings 'Production',
'TransactionHistory',
NULL,
NULL,
'ROW';

/*Listing 18 - 5. Estimating Row Compression Space Savings */
EXEC sp_estimate_data_compression_savings 'Production',
'TransactionHistory',
NULL,
NULL,
'ROW';

/*Listing 18 - 8. Estimating Data Compression Savings with Page Compression */
EXEC sp_estimate_data_compression_savings 'Person',
'Person',
NULL,
NULL,
'PAGE';

/*Listing 18 - 9. Applying Page Compression to the Person.Person Table */
ALTER TABLE Person.Person REBUILD
WITH (DATA_COMPRESSION = PAGE);

/*Listing 18 - 10. Pivot Query that Generates Columns with Many NULLs */
SELECT
CustomerID,
[HL Road Frame - Black, 58],
[HL Road Frame - Red, 58],
[HL Road Frame - Red, 62],
[HL Road Frame - Red, 44],
[HL Road Frame - Red, 48],
[HL Road Frame - Red, 52],
[HL Road Frame - Red, 56],
[LL Road Frame - Black, 58]
FROM
(
SELECT soh.CustomerID, p.Name AS ProductName,
COUNT
(
CASE WHEN sod.LineTotal IS NULL THEN NULL
ELSE 1
END
) AS NumberOfItems
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod
ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p
ON sod.ProductID = p.ProductID
GROUP BY
soh.CustomerID,
sod.ProductID,
p.Name
) src
PIVOT
(
SUM(NumberOfItems) FOR ProductName
IN
(
"HL Road Frame - Black, 58",
"HL Road Frame - Red, 58",
"HL Road Frame - Red, 62",
"HL Road Frame - Red, 44",
"HL Road Frame - Red, 48",
"HL Road Frame - Red, 52",
"HL Road Frame - Red, 56",
"LL Road Frame - Black, 58"
)
) AS pvt;

/*Listing 18 - 11. Creating Sparse and Nonsparse Tables */
CREATE TABLE NonSparseTable
(
CustomerID int NOT NULL PRIMARY KEY,
"HL Road Frame - Black, 58" int NULL,
"HL Road Frame - Red, 58" int NULL,
"HL Road Frame - Red, 62" int NULL,
"HL Road Frame - Red, 44" int NULL,
"HL Road Frame - Red, 48" int NULL,
"HL Road Frame - Red, 52" int NULL,
"HL Road Frame - Red, 56" int NULL,
"LL Road Frame - Black, 58" int NULL
);
CREATE TABLE SparseTable
(
CustomerID int NOT NULL PRIMARY KEY,
"HL Road Frame - Black, 58" int SPARSE NULL,
"HL Road Frame - Red, 58" int SPARSE NULL,
"HL Road Frame - Red, 62" int SPARSE NULL,
"HL Road Frame - Red, 44" int SPARSE NULL,
"HL Road Frame - Red, 48" int SPARSE NULL,
"HL Road Frame - Red, 52" int SPARSE NULL,
"HL Road Frame - Red, 56" int SPARSE NULL,
"LL Road Frame - Black, 58" int SPARSE NULL
);

/*Listing 18 - 12. Calculating the Space Savings of Sparse Columns */
EXEC sp_spaceused N'NonSparseTable';
EXEC sp_spaceused N'SparseTable';

/*Listing 18 - 13. Creating and Populating a Table with a Sparse Column Set */
CREATE TABLE Production.SparseProduct
(
ProductID int NOT NULL PRIMARY KEY,
Name dbo.Name NOT NULL,
ProductNumber nvarchar(25) NOT NULL,
Color nvarchar(15) SPARSE NULL,
Size nvarchar(5) SPARSE NULL,
SizeUnitMeasureCode nchar(3) SPARSE NULL,
WeightUnitMeasureCode nchar(3) SPARSE NULL,
Weight decimal(8, 2) SPARSE NULL,
Class nchar(2) SPARSE NULL,
Style nchar(2) SPARSE NULL,
SellStartDate datetime NOT NULL,
SellEndDate datetime SPARSE NULL,
DiscontinuedDate datetime SPARSE NULL,
SparseColumnSet xml COLUMN_SET FOR ALL_SPARSE_COLUMNS
);
GO
INSERT INTO Production.SparseProduct
(
ProductID,
Name,
ProductNumber,
Color,
Size,
SizeUnitMeasureCode,
WeightUnitMeasureCode,
Weight,
Class,
Style,
SellStartDate,
SellEndDate,
DiscontinuedDate
)
SELECT
ProductID,
Name,
ProductNumber,
Color,
Size,
SizeUnitMeasureCode,
WeightUnitMeasureCode,
Weight,
Class,
Style,
SellStartDate,
SellEndDate,
DiscontinuedDate
FROM Production.Product;
GO


/*Listing 18 - 14. Querying XML Sparse Column Set as XML */
SELECT TOP(7)
ProductID,
SparseColumnSet FROM Production.SparseProduct;

/*Listing 18 - 15. Querying Sparse Column Sets by Name */
SELECT
ProductID,
Name,
ProductNumber,
SellStartDate,
Color,
Class
FROM Production.SparseProduct
WHERE ProductID IN (1, 317);

/*Listing 18 - 16. Query Requiring a Bookmark Lookup */
SELECT
BusinessEntityID,
LastName,
FirstName,
MiddleName,
Title FROM Person.Person WHERE LastName = N'Duffy';

/*Listing 18 - 17. Query Using a Covering Index */
CREATE NONCLUSTERED INDEX [IX_Covering_Person_LastName_FirstName_MiddleName] ON
[Person].[Person]
(
[LastName] ASC,
[FirstName] ASC,
[MiddleName] ASC
) INCLUDE (Title)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF,
ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/*Listing 18 - 18. Creating and Testing a Filtered Index on the Production.Product Table */
CREATE NONCLUSTERED INDEX IX_Product_Size
ON Production.Product
(
Size,
SizeUnitMeasureCode )
WHERE Size IS NOT NULL;
GO
SELECT
ProductID,
Size,
SizeUnitMeasureCode FROM Production.Product WHERE Size = 'L';
GO

/*Listing 18 - 19. Script to Demonstrate Waits */
use adventureworks
go
CREATE TABLE [dbo].[waitsdemo](
[Id] [int] NOT NULL,
[LastName] [nchar](600) NOT NULL,
[FirstName] [nchar](600) NOT NULL,
[MiddleName] [nchar](600) NULL
) ON [PRIMARY]
GO
declare @id int = 1
while (@id < = 50000)
begin
insert into waitsdemo
select @id,'Foo', 'User',NULL
SET @id = @id + 1
end

/*Listing 18 - 20. DMV to Query Current Processes and Waiting Tasks */
--List waiting user requests
SELECT
er.session_id, er.wait_type, er.wait_time,
er.wait_resource, er.last_wait_type,
er.command,et.text,er.blocking_session_id
FROM sys.dm_exec_requests AS er
JOIN sys.dm_exec_sessions AS es
ON es.session_id = er.session_id
AND es.is_user_process = 1
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS et
GO
--List waiting user tasks
SELECT
wt.waiting_task_address, wt.session_id, wt.wait_type,
wt.wait_duration_ms, wt.resource_description
FROM sys.dm_os_waiting_tasks AS wt
JOIN sys.dm_exec_sessions AS es
ON wt.session_id = es.session_id
AND es.is_user_process = 1
GO
-- List user tasks
SELECT
t.session_id, t.request_id, t.exec_context_id,
t.scheduler_id, t.task_address,
t.parent_task_address
FROM sys.dm_os_tasks AS t
JOIN sys.dm_exec_sessions AS es
ON t.session_id = es.session_id
AND es.is_user_process = 1
GO


/*Listing 18 - 21. Extended Event Session Script to Troubleshoot Login Timeouts */
CREATE EVENT SESSION [Troubleshoot page split] ON SERVER
ADD EVENT sqlserver.page_split(
ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_
handle,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_
sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_
id,sqlserver.username)),
ADD EVENT sqlserver.rpc_completed(
ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_
handle,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_
sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_
id,sqlserver.username)),
ADD EVENT sqlserver.rpc_starting(
ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_
handle,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_
sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_
id,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_completed(
ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_
handle,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_
sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_
id,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_starting(
ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.plan_
handle,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_
sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.transaction_
id,sqlserver.username))
ADD TARGET package0.event_file(SET filename = N'C:\Temp\Troubleshoot page split.xel')
WITH (MAX_MEMORY = 4096
KB,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY = 30 SECONDS,MAX_EVENT_SIZE = 0
KB,MEMORY_PARTITION_MODE = NONE,TRACK_CAUSALITY = OFF,STARTUP_STATE = OFF)
GO

