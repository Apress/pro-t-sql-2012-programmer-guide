------------------------------------
-- Listing 10-1. Unicode Handling --
------------------------------------
DECLARE
    @string VARCHAR(50) = 'hello earth',
    @nstring NVARCHAR(50) = 'hello earth';

SELECT
    DATALENGTH(@string) as DatalengthString,
    DATALENGTH(@nstring) as DatalengthNString,
    LEN(@string) as lenString,
    LEN(@nstring) as lenNString;
GO

-----------------------------------------------------------------
-- Listing 10-2. Comparison of .WRITE Clause and String Append --
-----------------------------------------------------------------
-- Turn off messages that can affect performance 
SET NOCOUNT ON;
-- Create and initially populate a test table 
CREATE TABLE #test ( 
    Id int NOT NULL PRIMARY KEY, 
    String varchar(max) NOT NULL
);

INSERT INTO #test (
    Id, 
    String
) VALUES (
    1,
    ''
), ( 
    2,
    ''
);
-- Initialize variables and get start time
DECLARE @i int = 1;
DECLARE @quote varchar(50) = 'Four score and seven years ago...';
DECLARE @start_time datetime2(7) = SYSDATETIME();
-- Loop 2500 times and use .WRITE to append to a varchar(max) column
WHILE @i < 2500
BEGIN
    UPDATE #test
    SET string.WRITE(@quote, LEN(string), LEN(@quote))
    WHERE Id = 1;

    SET @i += 1; 
END;

SELECT '.WRITE Clause', DATEDIFF(ms, @start_time, SYSDATETIME()), 'ms';

-- Reset variables and get new start time
SET @i  = 1;
SET @start_time = SYSDATETIME();

-- Loop 2500 times and use string append to a varchar(max) column
WHILE @i < 2500
BEGIN
    UPDATE #test
    SET string += @quote
    WHERE Id = 2;

    SET @i += 1; 
END;
    
SELECT 'Append Method', DATEDIFF(ms, @start_time, SYSDATETIME()), 'ms';

SELECT
    Id,
    String,
    LEN(String) 
FROM #test;

DROP TABLE #test;
GO

-----------------------------------------------------------------------------
-- Listing 10-3. Use the Full Range of 32-bit Integer for IDENTITY Columns --
-----------------------------------------------------------------------------
CREATE TABLE dbo.bigtable (
    bigtableId int identity(-2147483648,1) NOT NULL
);

INSERT INTO dbo.bigtable DEFAULT VALUES;
INSERT INTO dbo.bigtable DEFAULT VALUES;

SELECT * FROM dbo.bigtable;

-----------------------------------
-- Listing 10-4. Date Comparison --
-----------------------------------
SELECT *
FROM Person.StateProvince
WHERE ModifiedDate = '2008-03-11';
GO

------------------------------------------------------
-- Listing 10-5. Date Comparison Executed Correctly --
------------------------------------------------------
SELECT *
FROM Person.StateProvince
WHERE ModifiedDate BETWEEN '2008-03-11' AND '2008-03-12';
-- or
SELECT *
FROM Person.StateProvince
WHERE CONVERT(CHAR(10), ModifiedDate, 126) = '2008-03-11';
GO

--------------------------------------------------
-- Listing 10-6. Correcting the Date Comparison --
--------------------------------------------------
SELECT *
FROM Production.Product
WHERE ModifiedDate BETWEEN '2008-03-11' AND '2008-03-11 23:59:59.997';
-- or
SELECT *
FROM Person.StateProvince
WHERE ModifiedDate >= '2008-03-11' AND ModifiedDate < '2008-03-12';

-----------------------------------------------
-- Listing 10-7. Sample Date Data Type Usage --
-----------------------------------------------
-- August 19, 14 C.E.
DECLARE @d1 date = '0014-08-19';

-- February 26, 1983
DECLARE @d2 date = '1983-02-26';
SELECT @d1  AS Date1, @d2 AS Date2, DATEDIFF(YEAR, @d1,  @d2) AS YearsDifference;
GO

------------------------------------------------------
-- Listing 10-8. Demonstrating Time Data Type Usage --
------------------------------------------------------
-- 6:25:19.1 AM
DECLARE @start_time time(1) = '06:25:19.1'; -- 1 digit fractional precision
-- 6:25:19.1234567 PM
DECLARE @end_time time = '18:25:19.1234567'; -- default fractional precision
SELECT @start_time AS start_time, @end_time AS end_time,
DATEADD(HOUR, 6, @start_time) AS StartTimePlus, DATEDIFF(HOUR, @start_time, @end_time) AS
 EndStartDiff;
GO

--------------------------------------------------------------
-- Listing 10-9. Declaring and Querying Datetime2 Variables --
--------------------------------------------------------------
DECLARE @start_dt2 datetime2 = '1972-07-06T07:13:28.8230234', 
        @end_dt2   datetime2 = '2009-12-14T03:14:13.2349832';
SELECT @start_dt2 AS start_dt2, @end_dt2 AS end_dt2;
GO

----------------------------------------------------
-- Listing 10-10. Datetimeoffset Data Type Sample --
----------------------------------------------------
DECLARE @start_dto datetimeoffset = '1492-10-12T13:29:59.9999999-05:00';
SELECT @start_dto AS start_to, DATEPART(YEAR, @start_dto) AS start_year;
GO

-------------------------------------------------------
-- Listing 10-11. Demonstration of Datetime Rounding --
-------------------------------------------------------
SELECT CAST('2011-12-31T23:59:59.999' as datetime) as WhatTimeIsIt;
GO

--------------------------------------------------------
-- Listing 10-12. CONVERT() and FORMAT() Usage Sample --
--------------------------------------------------------
DECLARE @dt2 datetime2 = '2011-12-31T23:59:59';

SELECT  FORMAT(@dt2, 'F', 'en-US') as with_format,
        CONVERT(varchar(50), @dt2, 109) as with_convert;
GO

---------------------------------------------------------------------
-- Listing 10-13. How to Check the Current Language of the Session --
---------------------------------------------------------------------
SELECT language 
FROM sys.dm_exec_sessions 
WHERE session_id = @@SPID;
-- or 
SELECT @@LANGUAGE;
GO

-------------------------------------------------------------------
-- Listing 10-14. Language Dependent Date String Representations --
-------------------------------------------------------------------
DECLARE @lang sysname;

SET @lang = @@LANGUAGE

SELECT CAST('12/31/2012' as datetime2); --this works

SET LANGUAGE 'spanish';

SELECT 
    CASE WHEN TRY_CAST('12/31/2012' as datetime2) IS NULL 
    THEN 'Cast failed'
    ELSE 'Cast succeeded'
END AS Result;

SET LANGUAGE @lang;
GO

--------------------------------------------
-- Listing 10-15. Usage of SET DATEFORMAT --
--------------------------------------------
SET DATEFORMAT mdy;
SET LANGUAGE 'spanish';
SELECT CAST('12/31/2012' as datetime2); --this works now
GO

------------------------------------------------------
-- Listing 10-17. Using the Date and Time Functions --
------------------------------------------------------
SELECT SYSDATETIME() AS [SYSDATETIME];
SELECT SYSUTCDATETIME() AS [SYSUTCDATETIME];
SELECT SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];
GO

---------------------------------------------------------
-- Listing 10-18. Adding an Offset to a Datetime Value --
---------------------------------------------------------
DECLARE @current datetime = CURRENT_TIMESTAMP;
SELECT @current AS [No_0ffset];
SELECT TODATETIMEOFFSET(@current, '-04:00') AS [With_0ffset];
GO

------------------------------------------------------------------------
-- Listing 10-19. Converting a Datetimeoffset to Several Time Offsets --
------------------------------------------------------------------------
DECLARE @current datetimeoffset = '2012-05-04 19:30:00 -07:00';
SELECT 'Los Angeles' AS [Location], @current AS [Current Time]
UNION ALL
SELECT 'New York', SWITCHOFFSET(@current, '-04:00')
UNION ALL
SELECT 'Bermuda', SWITCHOFFSET(@current, '-03:00')
UNION ALL
SELECT 'London', SWITCHOFFSET(@current, '+01:00');
GO

-------------------------------------------
-- Listing 10-20. Using Uniqueidentifier --
-------------------------------------------
CREATE TABLE dbo.Document (
    DocumentId uniqueidentifier NOT NULL PRIMARY KEY DEFAULT (NEWID())
);

INSERT INTO dbo.Document DEFAULT VALUES;
INSERT INTO dbo.Document DEFAULT VALUES;
INSERT INTO dbo.Document DEFAULT VALUES;

SELECT * FROM dbo.Document;

------------------------------------------------
-- Listing 10-21. Generating Sequential GUIDs --
------------------------------------------------
CREATE TABLE #TestSeqID (
    ID uniqueidentifier DEFAULT NEWSEQUENTIALID() PRIMARY KEY NOT NULL,
    Num int NOT NULL
);

INSERT INTO #TestSeqID (Num)
VALUES (1), (2), (3);

SELECT ID, Num 
FROM #TestSeqID;

DROP TABLE #TestSeqID;
GO

---------------------------------------------------------------------
-- Listing 10-22. Creating the Hierarchyid Bill of Materials Table --
---------------------------------------------------------------------
CREATE TABLE Production.HierBillOfMaterials
(
    BomNode hierarchyid NOT NULL PRIMARY KEY NONCLUSTERED,
    ProductAssemblyID int NULL,
    ComponentID int NULL,
    UnitMeasureCode nchar(3) NULL,
    PerAssemblyQty decimal(8, 2) NULL,
    BomLevel AS BomNode.GetLevel()
);
GO

-----------------------------------------------------------------------
-- Listing 10-23. Converting AdventureWorks BOMs to hierarchyid Form --
-----------------------------------------------------------------------
;WITH  BomChildren
(
    ProductAssemblyID,
    ComponentID
)
AS
(
    SELECT
        b1.ProductAssemblyID,
        b1.ComponentID
    FROM  Production.BillOfMaterials  b1
    GROUP BY
        b1.ProductAssemblyID,
        b1.ComponentID
),
BomPaths
(
    Path,
    ComponentID,
    ProductAssemblyID
)
AS
(
    SELECT
        hierarchyid::GetRoot() AS Path,
        NULL,
        NULL
    UNION ALL

    SELECT
        CAST
        ('/'  + CAST (bc.ComponentId  AS  varchar(30))  + '/' AS hierarchyid)  AS  Path,
        bc.ComponentID,
        bc.ProductAssemblyID
    FROM  BomChildren  AS  bc
    WHERE bc.ProductAssemblyID IS NULL

    UNION ALL

    SELECT
        CAST
        (bp.path.ToString()  + 
            CAST(bc.ComponentID  AS  varchar(30)) + '/' AS hierarchyid)  AS  Path,
        bc.ComponentID,
        bc.ProductAssemblyID
    FROM  BomChildren  AS  bc
    INNER JOIN BomPaths AS bp
        ON bc.ProductAssemblyID = bp.ComponentID
)
INSERT INTO Production.HierBillOfMaterials
(
    BomNode,
    ProductAssemblyID,
    ComponentID,
    UnitMeasureCode,
    PerAssemblyQty
)
SELECT
    bp.Path,
    bp.ProductAssemblyID,
    bp.ComponentID,
    bom.UnitMeasureCode,
    bom.PerAssemblyQty
FROM BomPaths AS bp
LEFT OUTER JOIN Production.BillOfMaterials bom
    ON  bp.ComponentID = bom.ComponentID
        AND COALESCE(bp.ProductAssemblyID, -1) = COALESCE(bom.ProductAssemblyID, -1)
WHERE bom.EndDate IS NULL
GROUP BY
    bp.path,
    bp.ProductAssemblyID,
    bp.ComponentID,
    bom.UnitMeasureCode,
    bom.PerAssemblyQty;
GO

-------------------------------------------------
-- Listing 10-24. Viewing the Hierarchyid BOMs --
-------------------------------------------------
SELECT 
    BomNode,
    BomNode.ToString(), 
    ProductAssemblyID,
    ComponentID,
    UnitMeasureCode,
    PerAssemblyQty,
    BomLevel 
FROM Production.HierBillOfMaterialsORDER BY BomNode;
GO

----------------------------------------------------------------
-- Listing 10-25. Retrieving Descendant Nodes of Assembly 749 --
----------------------------------------------------------------
DECLARE @CurrentNode hierarchyid;

SELECT @CurrentNode = BomNode
FROM Production.HierBillOfMaterials
WHERE ProductAssemblyID = 749;

SELECT
    BomNode,
    BomNode.ToString(),
    ProductAssemblyID,
    ComponentID,
    UnitMeasureCode,
    PerAssemblyQty,
    BomLevel
FROM Production.HierBillOfMaterials
WHERE @CurrentNode.IsDescendantOf(BomNode) = 1;
GO

--------------------------------------------------------------
-- Listing 10-26. Representing Wyoming as a Geometry Object --
--------------------------------------------------------------
DECLARE @Wyoming geometry;
SET @Wyoming = geometry::STGeomFromText ('POLYGON ( 
( -104.053108 41.698246, -104.054993 41.564247,
-104.053505 41.388107, -104.051201 41.003227,
-104.933968 40.994305, -105.278259 40.996365,
-106.202896 41.000111, -106.328545 41.001316,
-106.864838 40.998489, -107.303436 41.000168,
-107.918037 41.00341, -109.047638 40.998474,
-110.001457 40.997646, -110.062477 40.99794,
-111.050285 40.996635, -111.050911 41.25848,
-111.050323 41.578648, -111.047951 41.996265,
-111.046028 42.503323, -111.048447 43.019962,
-111.04673 43.284813, -111.045998 43.515606,
-111.049629 43.982632, -111.050789 44.473396,
-111.050842 44.664562, -111.05265 44.995766,
-110.428894 44.992348, -110.392006 44.998688,
-109.994789 45.002853, -109.798653 44.99958,
-108.624573 44.997643, -108.258568 45.00016,
-107.893715 44.999813, -106.258644 44.996174,
-106.020576 44.997227, -105.084465 44.999832,
-105.04126 45.001091, -104.059349 44.997349,
-104.058975 44.574368, -104.060547 44.181843,
-104.059242 44.145844, -104.05899 43.852928,
-104.057426 43.503738, -104.05867 43.47916,
-104.05571 43.003094, -104.055725 42.614704,
-104.053009 41.999851, -104.053108 41.698246) )', 0);

SELECT @Wyoming as Wyoming;
GO

-------------------------------------------------------------------------
-- Listing 10-27. Using GML to Represent Wyoming as a Geography Object --
-------------------------------------------------------------------------
DECLARE @Wyoming geography;
SET  @Wyoming = geography::GeomFromGml ('<Polygon
    xmlns="http://www.opengis.net/gml">
    <exterior>
        <LinearRing>
        <posList>
        41.698246  -104.053108  41.999851       -104.053009
        43.003094  -104.05571  43.503738        -104.057426
        44.145844  -104.059242  44.574368       -104.058975
        45.001091  -105.04126  44.997227        -106.020576
        44.999813  -107.893715  44.997643       -108.624573
        45.002853  -109.994789  44.992348       -110.428894
        44.664562  -111.050842  43.982632       -111.049629
        43.284813  -111.04673  42.503323        -111.046028
        41.578648  -111.050323  40.996635       -111.050285
        40.997646  -110.001457  41.00341        -107.918037
        40.998489  -106.864838  41.000111       -106.202896
        40.994305  -104.933968  41.388107       -104.053505
        41.698246  -104.053108
        </posList>
        </LinearRing>
    </exterior>
</Polygon>', 4269);
GO

----------------------------------------------------------------------
-- Listing 10-28. Are the Statue of Liberty and Laramie in Wyoming? --
----------------------------------------------------------------------
DECLARE @Wyoming geography,
    @StatueOfLiberty geography,
    @Laramie geography;

SET  @Wyoming = geography::GeomFromGml ('<Polygon
    xmlns="http://www.opengis.net/gml">
    <exterior>
        <LinearRing>
        <posList>
        41.698246  -104.053108  41.999851       -104.053009
        43.003094  -104.05571  43.503738        -104.057426
        44.145844  -104.059242  44.574368       -104.058975
        45.001091  -105.04126  44.997227        -106.020576
        44.999813  -107.893715  44.997643       -108.624573
        45.002853  -109.994789  44.992348       -110.428894
        44.664562  -111.050842  43.982632       -111.049629
        43.284813  -111.04673  42.503323        -111.046028
        41.578648  -111.050323  40.996635       -111.050285
        40.997646  -110.001457  41.00341        -107.918037
        40.998489  -106.864838  41.000111       -106.202896
        40.994305  -104.933968  41.388107       -104.053505
        41.698246  -104.053108
        </posList>
        </LinearRing>
    </exterior>
</Polygon>', 4269);

SET @StatueOfLiberty = geography::GeomFromGml('<Point
    xmlns="http://www.opengis.net/gml">
    <pos>
        40.689124 -74.044483
    </pos>
    </Point>', 4269);

SET @Laramie = geography::GeomFromGml('<Point
    xmlns="http://www.opengis.net/gml">
    <pos>
        41.312928 -105.587253
    </pos>
    </Point>', 4269);

SELECT  'Is  the  Statue  of  Liberty  in Wyoming?',
    CASE @Wyoming.STIntersects(@StatueOfLiberty)
        WHEN 0 THEN 'No'
        ELSE 'Yes'
    END  AS  Answer
UNION
SELECT  'Is  Laramie  in  Wyoming?',
    CASE @Wyoming.STIntersects(@Laramie)
        WHEN 0 THEN 'No'
        ELSE 'Yes'
    END;
GO

---------------------------------------------
-- Listing 10-29. Creating a Spatial Index --
---------------------------------------------
CREATE SPATIAL INDEX SIX_Location ON MyTable (SpatialColumn);
GO

--------------------------------------------------------------
-- Listing 10-30. Enabling FILESTREAM Support on the Server --
--------------------------------------------------------------
EXEC sp_configure 'filestream access level', 2;
RECONFIGURE;
GO

-----------------------------------------------------------------
-- Listing 10-31. Viewing FILESTREAM Configuration Information --
-----------------------------------------------------------------
SELECT 
    SERVERPROPERTY('ServerName') AS ServerName, 
    SERVERPROPERTY('FilestreamSharename') AS ShareName, 
    CASE SERVERPROPERTY('FilestreamEffectiveLevel')
        WHEN 0 THEN 'Disabled'
        WHEN 1 THEN 'T-SQL Access Only'
        WHEN 2 THEN 'Local T-SOL/File System Access Only'
        WHEN 3 THEN 'Local T-SOL/File System and Remote File System Access'
    END AS Effective_Level, 
    CASE SERVERPROPERTY('FilestreamConfiguredLevel')
        WHEN 0 THEN 'Disabled'
        WHEN 1 THEN 'T-SQL Access Only'
        WHEN 2 THEN 'Local T-SOL/File System Access Only'
        WHEN 3 THEN 'Local T-SOL/File System and Remote File System Access'
    END AS Configured_Level;
GO

----------------------------------------------------------------
-- Listing 10-32. CREATE DATABASE for AdventureWorks Database --
----------------------------------------------------------------
CREATE DATABASE [AdventureWorks]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AdventureWorks2012_Data', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012_Data.mdf' , SIZE = 226304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB ), 
 FILEGROUP [FILESTREAM1] CONTAINS FILESTREAM  DEFAULT 
( NAME = N'AdventureWordsFS', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWordsFS' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'AdventureWorks2012_Log', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012_log.ldf' , SIZE = 5696KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%);
GO

--------------------------------------------------------------------------
-- Listing 10-33. Adding a FILESTREAM Filegroup to an Existing Database --
--------------------------------------------------------------------------
ALTER DATABASE AdventureWorks
ADD FILEGROUP FILESTREAM1 CONTAINS FILESTREAM;
GO
ALTER DATABASE AdventureWorks
ADD FILE
(
NAME = N' AdventureWordsFS',
FILENAME = N' C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWordsFS' )
TO FILEGROUP FILESTREAM1;
GO

-----------------------------------------------------------------
-- Listing 10-34. Production.Document FILESTREAM-Enabled Table --
-----------------------------------------------------------------
CREATE TABLE Production.DocumentFS (
    DocumentNode    hierarchyid NOT NULL PRIMARY KEY,
    DocumentLevel   AS (DocumentNode.GetLevel()),
    Title           nvarchar(50) NOT NULL,
    Owner           int NOT NULL,
    FolderFlag      bit NOT NULL,
    FileName        nvarchar(400) NOT NULL,
    FileExtension   nvarchar(8) NOT NULL,
    Revision        nchar(5) NOT NULL,
    ChangeNumber    int NOT NULL,
    Status          tinyint NOT NULL,
    DocumentSummary nvarchar(max) NULL,
    Document        varbinary(max) FILESTREAM NULL,
    rowguid         uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE,
    ModifiedDate    datetime NOT NULL
);
GO

INSERT INTO Production.DocumentFS
    (DocumentNode, Title, Owner, FolderFlag, FileName, FileExtension, Revision, ChangeNumber, Status, DocumentSummary, Document, rowguid, ModifiedDate)
SELECT 
    DocumentNode, Title, Owner, FolderFlag, FileName, FileExtension, Revision, ChangeNumber, Status, DocumentSummary, Document, rowguid, ModifiedDate
FROM Production.Document; 
GO

--------------------------------------------------------
-- Listing 10-35. Querying a FILESTREAM-Enabled Table --
--------------------------------------------------------
SELECT
    d.Title,
    d.Document.PathName() AS LOB_Path,
    d.Document AS LOB_Data 
FROM Production.DocumentFS d 
WHERE d.Document IS NOT NULL;
GO

--------------------------------------------------------------------
-- Listing 10-36. Creating a Database with a FILESTREAM Filegroup --
--------------------------------------------------------------------
CREATE DATABASE cliparts
CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'cliparts', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\cliparts.mdf' , SIZE = 5120KB , FILEGROWTH = 1024KB ), 
FILEGROUP [filestreamFG1] CONTAINS FILESTREAM 
( NAME = N'filestream1', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\filestream1' )
LOG ON 
( NAME = N'cliparts_log', FILENAME = N'C:\sqldata\MSSQL11.MSSQLSERVER\MSSQL\DATA\cliparts_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%);
GO

ALTER DATABASE [cliparts] SET FILESTREAM( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'cliparts' );
GO

-------------------------------------------
-- Listing 10-37. Creating the Filetable --
-------------------------------------------
USE [cliparts];
GO

CREATE TABLE dbo.OpenClipartsLibrary AS FILETABLE
WITH
    (
        FILETABLE_DIRECTORY = 'OpenClipartsLibrary'
    );
GO

INSERT INTO dbo.OpenClipartsLibrary (name,is_directory)
VALUES ('import_20120501',1);
GO

-----------------------------------------------------------
-- Listing 10-38. Inserting a Directory in the Filetable --
-----------------------------------------------------------
INSERT INTO dbo.OpenClipartsLibrary (name, is_directory)
VALUES ('directory01',1);
GO

---------------------------------------------
-- Listing 10-39. Inserting a Subdirectory --
---------------------------------------------
INSERT INTO dbo.OpenClipartsLibrary
     (name, is_directory, creation_time, path_locator)
SELECT 
    'directory02',1, dateadd(year, -1, sysdatetime()), path_locator.GetDescendant(NULL, NULL)
FROM dbo.OpenClipartsLibrary
WHERE name = 'directory01'
AND   is_directory = 1
AND   parent_path_locator IS NULL; 
GO

----------------------------------------------
-- Listing 10-40. Using FileTableRootPath() --
----------------------------------------------
USE cliparts;

SELECT FileTableRootPath();
SELECT FileTableRootPath('dbo.OpenClipartsLibrary'); 
GO

--------------------------------------------------
-- Listing 10-41. Using GetFileNamespacePath(). --
--------------------------------------------------
SELECT file_stream.GetFileNamespacePath(1) as path
FROM dbo.OpenClipartsLibrary
WHERE is_directory = 1
ORDER BY path_locator.GetLevel(), path;
GO

------------------------------------------------
-- Listing 10-42. Using Hierarchyid Functions --
------------------------------------------------
SELECT l1.name, l1.path_locator.GetLevel(), l2.name as parent_directory
FROM dbo.OpenClipartsLibrary l1
JOIN dbo.OpenClipartsLibrary l2 ON l1.path_locator.GetAncestor(1) = l2.path_locator
WHERE l1.is_directory = 1;
GO

-----------------------------------------------------
-- Listing 10-43. Using Parent_path_locator Column --
-----------------------------------------------------
SELECT l1.name, l1.path_locator.GetLevel(), l2.name as parent_directory
FROM dbo.OpenClipartsLibrary l1
JOIN dbo.OpenClipartsLibrary l2 ON l1.parent_path_locator = l2.path_locator
WHERE l1.is_directory = 1;
GO

--------------------------------------------------------------------------
-- Listing 10-44. Using a CTE to Travel Down the Directories’ Hierarchy --
--------------------------------------------------------------------------
;WITH mycte AS (
    SELECT name, path_locator.GetLevel() as Level, path_locator
    FROM dbo.OpenClipartsLibrary
    WHERE name = 'Yason' 
    AND is_directory = 1

    UNION ALL 

    SELECT l1.name, l1.path_locator.GetLevel() as Level, l1.path_locator
    FROM dbo.OpenClipartsLibrary l1
    JOIN mycte l2 ON l1.parent_path_locator = l2.path_locator
    WHERE l1.is_directory = 1
)
SELECT name, Level
FROM mycte
ORDER BY level, name;
GO

-----------------------------------------------------------------------------------------
-- Listing 10-45. Using hierarchyid Functions to Travel Down the Directory’s Hierarchy --
-----------------------------------------------------------------------------------------
SELECT l1.name, l1.path_locator.GetLevel() as Level
FROM dbo.OpenClipartsLibrary l1
JOIN dbo.OpenClipartsLibrary l2 ON l1.path_locator.IsDescendantOf(l2.path_locator) = 1 OR l1.path_locator = l2.path_locator
WHERE l1.is_directory = 1
AND l2.is_directory = 1
AND l2.name = 'Yason'
ORDER BY level, name;
GO

---------------------------------------------------------
-- Listing 10-46. Using the GetPathLocator() function. --
---------------------------------------------------------
DECLARE @path_locator hierarchyid

SET @path_locator = GetPathLocator('\\Sql2012\mssqlserver\cliparts\OpenClipartsLibrary\import_20120501\Yason');

SELECT * 
FROM dbo.OpenClipartsLibrary
WHERE path_locator = @path_locator;
GO

-------------------------------------------------------------------------------------------
-- Listing 10-47. Creating an Audit Table and a Trigger on the OpenClipartsLibrary Table --
-------------------------------------------------------------------------------------------
CREATE TABLE dbo.cliparts_log (
    path nvarchar(4000) not null,
    deletion_date datetime2(0),
    deletion_user sysname,
    is_directory bit
)
GO

CREATE TRIGGER OpenClipartsLibrary_logTrigger
ON [dbo].[OpenClipartsLibrary]
AFTER DELETE
AS BEGIN
    IF @@ROWCOUNT = 0 RETURN;
    SET NOCOUNT ON;

    INSERT INTO dbo.cliparts_log (path, deletion_date, deletion_user, is_directory)
    SELECT name, SYSDATETIME(), SUSER_SNAME(),is_directory
    FROM deleted
END;
GO

