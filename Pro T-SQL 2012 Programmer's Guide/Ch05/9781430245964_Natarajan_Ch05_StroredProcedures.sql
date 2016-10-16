/* Listing 5-1. Retrieving an Employee’s Name and E-mail with an SP */
CREATE PROCEDURE Person.GetEmployee (@BusinessEntityID int = 199,
@Email_Address nvarchar(50) OUTPUT,
@Full_Name nvarchar(100) OUTPUT)
AS
BEGIN
-- Retrieve email address and full name from HumanResources.Employee table
SELECT @Email_Address = ea.EmailAddress,
@Full_Name = p.FirstName + ' ' + COALESCE(p.MiddleName,'') + ' ' + p.LastName
FROM HumanResources.Employee e
INNER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID
INNER JOIN Person.EmailAddress ea
ON p.BusinessEntityID = ea.BusinessEntityID
WHERE e.BusinessEntityID = @BusinessEntityID;
-- Return a code of 1 when no match is found, 0 for success
RETURN (
CASE
WHEN @Email_Address IS NULL THEN 1
ELSE 0
END
);
END;
GO

/* Listing 5-2. Calling the Person.GetEmployee SP */
-- Declare variables to hold the result
DECLARE @Email nvarchar(50),@Name nvarchar(100),@Result int;
--Call procedure to get employee information
EXECUTE @Result = Person.GetEmployee 123, @Email OUTPUT, @Name OUTPUT;

/* Listing 5-3. Retrieving a Contact’s ID, Name, Title, and DOB with an SP */
CREATE PROCEDURE Person.GetContactDetails (@ID int)
AS
BEGIN
SET NOCOUNT ON
-- Retrieve Name and title for a given PersonID
SELECT @ID, p.FirstName + ' ' + COALESCE(p.MiddleName,'') + ' ' + p.LastName, ct.[Name],
cast(p.ModifiedDate as varchar(20)), 'Vendor Contact'
FROM [Purchasing].[Vendor] AS v
INNER JOIN [Person].[BusinessEntityContact] bec
ON bec.[BusinessEntityID] = v.[BusinessEntityID]
INNER JOIN [Person].ContactType ct
ON ct.[ContactTypeID] = bec.[ContactTypeID]
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = bec.[PersonID]
WHERE bec.[PersonID] = @ID;
END;
GO

/*Listing 5-4. Calling the Person.GetContactDetails SP */
-- Declare variables to hold the result
DECLARE @ContactID int;
SET @ContactID = 1511;
--Call procedure to get consumer information
EXEC dbo.GetContactDetails @ContactID with result sets(
(
ContactID int,--Column Name changed
ContactName varchar(200),--Column Name changed
Title varchar(50),--Column Name changed
LastUpdatedBy varchar(20),--Column Name changed and the data type has been changed from date to
varchar
TypeOfContact varchar(20)
))

/*Listing 5-5. Retrieving a Contact’s ID, Name, Title, and DOB with an SP */
ALTER PROCEDURE Person.GetContactDetails
AS
BEGIN
SET NOCOUNT ON
-- Retrieve Name and title for a given PersonID
SELECT p.BusinessEntityID, p.FirstName + ' ' + COALESCE(p.MiddleName,'') + ' ' +
p.LastName, ct.[Name], cast(p.ModifiedDate as varchar(20)), 'Vendor Contact'
FROM [Purchasing].[Vendor] AS v
INNER JOIN [Person].[BusinessEntityContact] bec
ON bec.[BusinessEntityID] = v.[BusinessEntityID]
INNER JOIN [Person].ContactType ct
ON ct.[ContactTypeID] = bec.[ContactTypeID]
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = bec.[PersonID];
SELECT p.BusinessEntityID, p.FirstName + ' ' + COALESCE(p.MiddleName,'') + ' ' +
p.LastName, ct.[Name], cast(p.ModifiedDate as varchar(20)), p.Suffix, 'Store Contact'
FROM [Sales].[Store] AS s
INNER JOIN [Person].[BusinessEntityContact] bec
ON bec.[BusinessEntityID] = s.[BusinessEntityID]
INNER JOIN [Person].ContactType ct
ON ct.[ContactTypeID] = bec.[ContactTypeID]
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = bec.[PersonID];
END;
GO

/*Listing 5-6. Calling the Modified Person.GetContactDetails SP */
--Call procedure to get consumer information
EXEC Person.GetContactDetails with result sets(
--Return Vendor Contact Details
(
ContactID int,--Column Name changed
ContactName varchar(200),--Column Name changed
Title varchar(50),--Column Name changed
LastUpdatedBy varchar(20),--Column Name changed and the data type has been changed from date to
varchar
TypeOfContact varchar(20)
),
--Return Store Contact Details
(
ContactID int,--Column Name changed
ContactName varchar(200),--Column Name changed
Title varchar(50),--Column Name changed
LastUpdatedBy varchar(20),--Column Name changed and the data type has been changed from date to
varchar
Suffix varchar(5),
TypeOfContact varchar(20)
)
)

/*Listing 5-7. Dropping the Person.GetEmployee SP */
DROP PROCEDURE Person.GetEmployee;

/*Listing 5-8. Procedure to Calculate and Retrieve Running Total for Sales */
CREATE PROCEDURE Sales.GetSalesRunningTotal (@Year int)
AS
BEGIN
WITH RunningTotalCTE
AS
(
SELECT soh.SalesOrderNumber,
soh.OrderDate,
soh.TotalDue,
(
SELECT SUM(soh1.TotalDue)
FROM Sales.SalesOrderHeader soh1
WHERE soh1.SalesOrderNumber <= soh.SalesOrderNumber
) AS RunningTotal,
SUM(soh.TotalDue) OVER () AS GrandTotal
FROM Sales.SalesOrderHeader soh
WHERE DATEPART(year, soh.OrderDate) = @Year
GROUP BY soh.SalesOrderNumber,
soh.OrderDate,
soh.TotalDue
)
SELECT rt.SalesOrderNumber,
rt.OrderDate,
rt.TotalDue,
rt.RunningTotal,
(rt.RunningTotal / rt.GrandTotal) * 100 AS PercentTotal
FROM RunningTotalCTE rt
ORDER BY rt.SalesOrderNumber;
RETURN 0;
END;
GO

EXEC Sales.GetSalesRunningTotal @Year = 2005;
GO

/*Listing 5 - 9. Recommended Product List SP */
CREATE PROCEDURE Production.GetProductRecommendations (@ProductID int = 776)
AS
BEGIN
WITH RecommendedProducts
(
ProductID,
ProductSubCategoryID,
TotalQtyOrdered,
TotalDollarsOrdered
)
AS
(
SELECT
od2.ProductID,
p1.ProductSubCategoryID,
SUM(od2.OrderQty) AS TotalQtyOrdered,
SUM(od2.UnitPrice * od2.OrderQty) AS TotalDollarsOrdered
FROM Sales.SalesOrderDetail od1
INNER JOIN Sales.SalesOrderDetail od2
ON od1.SalesOrderID = od2.SalesOrderID
INNER JOIN Production.Product p1
ON od2.ProductID = p1.ProductID
WHERE od1.ProductID = @ProductID
AND od2.ProductID <> @ProductID
GROUP BY
od2.ProductID,
p1.ProductSubcategoryID
)
SELECT TOP(10) ROW_NUMBER() OVER
(
ORDER BY rp.TotalQtyOrdered DESC
) AS Rank,
rp.TotalQtyOrdered,
rp.ProductID,
rp.TotalDollarsOrdered,
p.[Name]
FROM RecommendedProducts rp
INNER JOIN Production.Product p
ON rp.ProductID = p.ProductID
WHERE rp.ProductSubcategoryID <>
(
SELECT ProductSubcategoryID
FROM Production.Product
WHERE ProductID = @ProductID
)
ORDER BY TotalQtyOrdered DESC;
END;
GO

/*Listing 5 - 10. Getting a Recommended Product List */
EXECUTE Production..GetProductRecommendations 773;

/*Listing 5 - 11. The Towers of Hanoi Puzzle */
-- This stored procedure displays all the discs in the appropriate
-- towers.
CREATE PROCEDURE dbo.ShowTowers
AS
BEGIN
-- Each disc is displayed like this "===3===" where the number is the disc
-- and the width of the === signs on either side indicates the width of the
-- disc.
-- These CTEs are designed for displaying the discs in proper order on each
-- tower.
WITH FiveNumbers(Num) -- Recursive CTE generates table with numbers 1...5
AS
(
SELECT 1
UNION ALL
SELECT Num + 1
FROM FiveNumbers
WHERE Num < 5
),
GetTowerA (Disc) -- The discs for Tower A
AS
(
SELECT COALESCE(a.Disc, -1) AS Disc
FROM FiveNumbers f
LEFT JOIN #TowerA a
ON f.Num = a.Disc
),
GetTowerB (Disc) -- The discs for Tower B
AS
(
SELECT COALESCE(b.Disc, -1) AS Disc
FROM FiveNumbers f
LEFT JOIN #TowerB b
ON f.Num = b.Disc
),
GetTowerC (Disc) -- The discs for Tower C
AS
(
SELECT COALESCE(c.Disc, -1) AS Disc
FROM FiveNumbers f
LEFT JOIN #TowerC c
ON f.Num = c.Disc
)
-- This SELECT query generates the text representation for all three towers
-- and all five discs. FULL OUTER JOIN is used to represent the towers in a
-- side-by-side format.
SELECT CASE a.Disc
WHEN 5 THEN ' =====5===== '
WHEN 4 THEN ' ====4==== '
WHEN 3 THEN '===3=== '
WHEN 2 THEN ' ==2== '
WHEN 1 THEN ' =1= '
ELSE ' | '
END AS Tower_A,
CASE b.Disc
WHEN 5 THEN ' =====5===== '
WHEN 4 THEN ' ====4==== '
WHEN 3 THEN ' ===3=== '
WHEN 2 THEN ' ==2== '
WHEN 1 THEN ' =1= '
ELSE ' | '
END AS Tower_B,
CASE c.Disc
WHEN 5 THEN ' =====5===== '
WHEN 4 THEN ' ====4==== '
WHEN 3 THEN ' ===3=== '
WHEN 2 THEN ' ==2== '
WHEN 1 THEN ' =1= '
ELSE ' | '
END AS Tower_C
FROM (
SELECT ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
COALESCE(Disc, -1) AS Disc
FROM GetTowerA
) a
FULL OUTER JOIN (
SELECT ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
COALESCE(Disc, -1) AS Disc
FROM GetTowerB
) b
ON a.Num = b.Num
FULL OUTER JOIN (
SELECT ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
COALESCE(Disc, -1) AS Disc
FROM GetTowerC
) c
ON b.Num = c.Num
ORDER BY a.Num;
END;
GO
-- This SP moves a single disc from the specified source tower to the
-- specified destination tower.
CREATE PROCEDURE dbo.MoveOneDisc (@Source nchar(1),
@Dest nchar(1))
AS
BEGIN
-- @SmallestDisc is the smallest disc on the source tower
DECLARE @SmallestDisc int = 0;
-- IF ... ELSE conditional statement gets the smallest disc from the
-- correct source tower
IF @Source = N'A'
BEGIN
-- This gets the smallest disc from Tower A
SELECT @SmallestDisc = MIN(Disc)
FROM #TowerA;
-- Then delete it from Tower A
DELETE FROM #TowerA
WHERE Disc = @SmallestDisc;
END
ELSE IF @Source = N'B'
BEGIN
-- This gets the smallest disc from Tower B
SELECT @SmallestDisc = MIN(Disc)
FROM #TowerB;
-- Then delete it from Tower B
DELETE FROM #TowerB
WHERE Disc = @SmallestDisc;
END
ELSE IF @Source = N'C'
BEGIN
-- This gets the smallest disc from Tower C
SELECT @SmallestDisc = MIN(Disc)
FROM #TowerC;
-- Then delete it from Tower C
DELETE FROM #TowerC
WHERE Disc = @SmallestDisc;
END
-- Show the disc move performed
SELECT N'Moving Disc (' + CAST(COALESCE(@SmallestDisc, 0) AS nchar(1)) +
N') from Tower ' + @Source + N' to Tower ' + @Dest + ':' AS Description;
-- Perform the move - INSERT the disc from the source tower into the
-- destination tower
IF @Dest = N'A'
INSERT INTO #TowerA (Disc) VALUES (@SmallestDisc);
ELSE IF @Dest = N'B'
INSERT INTO #TowerB (Disc) VALUES (@SmallestDisc);
ELSE IF @Dest = N'C'
INSERT INTO #TowerC (Disc) VALUES (@SmallestDisc);
-- Show the towers
EXECUTE dbo.ShowTowers;
END;
GO
-- This SP moves multiple discs recursively
CREATE PROCEDURE dbo.MoveDiscs (@DiscNum int,
@MoveNum int OUTPUT,
@Source nchar(1) = N'A',
@Dest nchar(1) = N'C',
@Aux nchar(1) = N'B'
)
AS
BEGIN
-- If the number of discs to move is 0, the solution has been found
IF @DiscNum = 0
PRINT N'Done';
ELSE
BEGIN
-- If the number of discs to move is 1, go ahead and move it
IF @DiscNum = 1
BEGIN
-- Increase the move counter by 1
SELECT @MoveNum += 1;
-- And finally move one disc from source to destination
EXEC dbo.MoveOneDisc @Source, @Dest;
END
ELSE
BEGIN
-- Determine number of discs to move from source to auxiliary tower
DECLARE @n int = @DiscNum - 1;
-- Move (@DiscNum - 1) discs from source to auxiliary tower
EXEC dbo.MoveDiscs @n, @MoveNum OUTPUT, @Source, @Aux, @Dest;
-- Move 1 disc from source to final destination tower
EXEC dbo.MoveDiscs 1, @MoveNum OUTPUT, @Source, @Dest, @Aux;
-- Move (@DiscNum - 1) discs from auxiliary to final destination tower
EXEC dbo.MoveDiscs @n, @MoveNum OUTPUT, @Aux, @Dest, @Source;
END;
END;
END;
GO
-- This SP creates the three towers and populates Tower A with 5 discs
CREATE PROCEDURE dbo.SolveTowers
AS
BEGIN
-- SET NOCOUNT ON to eliminate system messages that will clutter up
-- the Message display
SET NOCOUNT ON;
-- Create the three towers: Tower A, Tower B, and Tower C
CREATE TABLE #TowerA (Disc int PRIMARY KEY NOT NULL);
CREATE TABLE #TowerB (Disc int PRIMARY KEY NOT NULL);
CREATE TABLE #TowerC (Disc int PRIMARY KEY NOT NULL);
-- Populate Tower A with all five discs
INSERT INTO #TowerA (Disc)
VALUES (1), (2), (3), (4), (5);
-- Initialize the move number to 0
DECLARE @MoveNum int = 0;
-- Show the initial state of the towers
EXECUTE dbo.ShowTowers;
-- Solve the puzzle. Notice you don't need to specify the parameters
-- with defaults
EXECUTE dbo.MoveDiscs 5, @MoveNum OUTPUT;
-- How many moves did it take?
PRINT N'Solved in ' + CAST (@MoveNum AS nvarchar(10)) + N' moves.';
-- Drop the temp tables to clean up - always a good idea.
DROP TABLE #TowerC;
DROP TABLE #TowerB;
DROP TABLE #TowerA;
-- SET NOCOUNT OFF before we exit
SET NOCOUNT OFF;
END;
GO

/*Listing 5 - 12. Creating a Table Type */
CREATE TYPE HumanResources.LastNameTableType
AS TABLE (LastName nvarchar(50) NOT NULL PRIMARY KEY);
GO

/*Listing 5 - 13. Simple Procedure Accepting a Table-valued Parameter */
CREATE PROCEDURE HumanResources.GetEmployees
(@LastNameTable HumanResources.LastNameTableType READONLY)
AS
BEGIN
SELECT
p.LastName,
p.FirstName,
p.MiddleName,
e.NationalIDNumber,
e.Gender,
e.HireDate
FROM HumanResources.Employee e
INNER JOIN Person.Person p
ON e.BusinessEntityID = p.BusinessEntityID
INNER JOIN @LastNameTable lnt
ON p.LastName = lnt.LastName
ORDER BY
p.LastName,
p.FirstName,
p.MiddleName;
END;
GO

/*Listing 5 - 14. Calling a Procedure with a Table-valued Parameter */
DECLARE @LastNameList HumanResources.LastNameTableType;
INSERT INTO @LastNameList
(LastName)
VALUES
(N'Walters'),
(N'Anderson'),
(N'Chen'),
(N'Rettig'),
(N'Lugo'),
(N'Zwilling'),
(N'Johnson');
EXECUTE HumanResources.GetEmployees @LastNameList;

/*Listing 5 - 15. Procedure to Retrieve SP Statistics with DMVs and DMFs */
CREATE PROCEDURE dbo.GetProcStats (@order varchar(100) = 'use')
AS
BEGIN
WITH GetQueryStats
(
plan_handle,
total_elapsed_time,
total_logical_reads,
total_logical_writes,
total_physical_reads
)
AS
(
SELECT
qs.plan_handle,
SUM(qs.total_elapsed_time) AS total_elapsed_time,
SUM(qs.total_logical_reads) AS total_logical_reads,
SUM(qs.total_logical_writes) AS total_logical_writes,
SUM(qs.total_physical_reads) AS total_physical_reads
FROM sys.dm_exec_query_stats qs
GROUP BY qs.plan_handle
)
SELECT
DB_NAME(st.dbid) AS database_name,
OBJECT_SCHEMA_NAME(st.objectid, st.dbid) AS schema_name,
OBJECT_NAME(st.objectid, st.dbid) AS proc_name,
SUM(cp.usecounts) AS use_counts,
SUM(cp.size_in_bytes) AS size_in_bytes,
SUM(qs.total_elapsed_time) AS total_elapsed_time,
CAST
(
SUM(qs.total_elapsed_time) AS decimal(38, 4)
) / SUM(cp.usecounts) AS avg_elapsed_time_per_use,
SUM(qs.total_logical_reads) AS total_logical_reads,
CAST
(
SUM(qs.total_logical_reads) AS decimal(38, 4)
) / SUM(cp.usecounts) AS avg_logical_reads_per_use,
SUM(qs.total_logical_writes) AS total_logical_writes,
CAST
(
SUM(qs.total_logical_writes) AS decimal(38, 4)
) / SUM(cp.usecounts) AS avg_logical_writes_per_use,
SUM(qs.total_physical_reads) AS total_physical_reads,
CAST
(
SUM(qs.total_physical_reads) AS decimal(38, 4)
) / SUM(cp.usecounts) AS avg_physical_reads_per_use,
st.text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
INNER JOIN GetQueryStats qs
ON cp.plan_handle = qs.plan_handle
INNER JOIN sys.procedures p
ON st.objectid = p.object_id
WHERE p.type IN ('P', 'PC')
GROUP BY st.dbid, st.objectid, st.text
ORDER BY
CASE @order
WHEN 'name' THEN OBJECT_NAME(st.objectid)
WHEN 'size' THEN SUM(cp.size_in_bytes)
WHEN 'read' THEN SUM(qs.total_logical_reads)
WHEN 'write' THEN SUM(qs.total_logical_writes)
ELSE SUM(cp.usecounts)
END DESC;
END;
GO

/*Listing 5 - 16. Retrieving SP Statistics */
EXEC dbo.GetProcStats @order = 'use';
GO

/*Listing 5 - 17. Simple Procedure to Demonstrate Parameter Sniffing */
CREATE PROCEDURE Production.GetProductsByName
@Prefix NVARCHAR(100)
AS
BEGIN
SELECT
p.Name,
p.ProductID
FROM Production.Product p
WHERE p.Name LIKE @Prefix;
END;
GO

/*Listing 5 - 18. Overriding Parameter Sniffing in an SP */
ALTER PROCEDURE Production.GetProductsByName
@Prefix NVARCHAR(100)
AS
BEGIN
DECLARE @PrefixVar NVARCHAR(100) = @Prefix;
SELECT
p.Name,
p.ProductID
FROM Production.Product p
WHERE p.Name LIKE @PrefixVar;
END;
GO

/*Listing 5 - 19. SP to Retrieve Orders by Salesperson */
CREATE PROCEDURE Sales.GetSalesBySalesPerson (@SalesPersonId int)
AS
BEGIN
SELECT
soh.SalesOrderID,
soh.OrderDate,
soh.TotalDue
FROM Sales.SalesOrderHeader soh
WHERE soh.SalesPersonID = @SalesPersonId;
END;
GO

/*Listing 5 - 20. Retrieving Sales for Salesperson 277 */
EXECUTE Sales.GetSalesBySalesPerson 277;

/*Listing 5 - 21. Executing an SP with Recompilation */
EXECUTE Sales.GetSalesBySalesPerson 285 WITH RECOMPILE;

/*Listing 5 - 22. Adding Statement-Level Recompilation to the SP */
ALTER PROCEDURE Sales.GetSalesBySalesPerson (@SalesPersonId int)
AS
BEGIN
SELECT
soh.SalesOrderID,
soh.OrderDate,
soh.TotalDue
FROM Sales.SalesOrderHeader soh
WHERE soh.SalesPersonID = @SalesPersonId
OPTION (RECOMPILE);
END;
GO

/*Listing 5 - 23. SP to Retutn List of Stored Procedures That Have Been Recompiled */
CREATE PROCEDURE dbo.GetRecompiledProcs
AS
BEGIN
SELECT
sql_text.text,
stats.sql_handle,
stats.plan_generation_num,
stats.creation_time,
stats.execution_count,
sql_text.dbid,
sql_text.objectid
FROM sys.dm_exec_query_stats stats
Cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
WHERE stats.plan_generation_num > 1
and sql_text.objectid is not null --Filter adhoc queries
ORDER BY stats.plan_generation_num desc
END;
GO

/*Listing 5 - 24. Retrieving SP Statistics */
EXEC dbo.GetRecompiledProcs;
GO
