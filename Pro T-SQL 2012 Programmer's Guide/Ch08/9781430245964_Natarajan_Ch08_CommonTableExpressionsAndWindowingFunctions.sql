/*Listing 8-1. Simple CTE */
WITH GetNamesCTE (
BusinessEntityID,
FirstName,
MiddleName,
LastName )
AS (
SELECT
BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person ) SELECT
BusinessEntityID,
FirstName,
MiddleName,
LastName FROM GetNamesCTE
;

/*Listing 8-2. Multiple CTEs */
WITH GetNamesCTE (
BusinessEntityID,
FirstName,
MiddleName,
LastName )
AS (
SELECT
BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person ),
GetContactCTE (
BusinessEntityID,
FirstName,
MiddleName, LastName, Email, HomePhoneNumber
)
AS ( SELECT gn.BusinessEntityID, gn.FirstName, gn.MiddleName, gn.LastName, ea.EmailAddress,
pp.PhoneNumber FROM GetNamesCTE gn LEFT JOIN Person.EmailAddress ea
ON gn.BusinessEntityID = ea.BusinessEntityID LEFT JOIN Person.PersonPhone pp ON
gn.BusinessEntityID = pp.BusinessEntityID AND pp.PhoneNumberTypeID = 2 )
SELECT BusinessEntityID, FirstName, MiddleName, LastName, Email,
HomePhoneNumber FROM GetContactCTE;

/*Listing 8-3. Simple Recursive CTE */
WITH Numbers (n) AS ( SELECT 1 AS n
UNION ALL
SELECT n + 1 FROM Numbers WHERE n < 10 )
SELECT n FROM Numbers;

/*Listing 8-4. Recursive CTE with MAXRECURSION Option */
WITH Numbers (n) AS ( SELECT 0 AS n
UNION ALL
SELECT n + 1
FROM Numbers
WHERE n < 1000 )
SELECT n FROM Numbers OPTION (MAXRECURSION 1000);

/*Listing 8-5. Recursive BOM CTE */
DECLARE @ComponentID int = 774;
WITH BillOfMaterialsCTE
(
BillOfMaterialsID,
ProductAssemblyID,
ComponentID,
Quantity,
Level
)
AS
(
SELECT
bom.BillOfMaterialsID,
bom.ProductAssemblyID,
bom.ComponentID,
bom.PerAssemblyQty AS Quantity,
0 AS Level
FROM Production.BillOfMaterials bom
WHERE bom.ComponentID = @ComponentID
UNION ALL
SELECT
bom.BillOfMaterialsID,
bom.ProductAssemblyID,
bom.ComponentID,
bom.PerAssemblyQty,
Level + 1
FROM Production.BillOfMaterials bom
ComponentID 774
ComponentID 516
ComponentID 497
ProductAssemblyID 774
ProductAssemblyID 516
INNER JOIN BillOfMaterialsCTE bomcte
ON bom.ProductAssemblyID = bomcte.ComponentID
WHERE bom.EndDate IS NULL
)
SELECT
bomcte.ProductAssemblyID,
p.ProductID,
p.ProductNumber,
p.Name,
p.Color,
bomcte.Quantity,
bomcte.Level
FROM BillOfMaterialsCTE bomcte
INNER JOIN Production.Product p
ON bomcte.ComponentID = p.ProductID
order by bomcte.Level;

/*Listing 8-6. ROW_NUMBER with Partitioning */
SELECT
ROW_NUMBER() OVER
(
PARTITION BY
LastName
ORDER BY
LastName,
FirstName,
MiddleName
) AS Number,
LastName,
FirstName,
MiddleName
FROM Person.Person;

/*Listing 8-7. OFFSET/FETCH Example */
CREATE PROCEDURE Person.GetContacts
@StartPageNum int,
@RowsPerPage int
AS
SELECT
LastName,
FirstName,
MiddleName
FROM Person.Person
ORDER BY
LastName,
FirstName,
MiddleName
OFFSET (@StartPageNum - 1) * @RowsPerPage ROWS
FETCH NEXT @RowsPerPage ROWS ONLY;
GO

/*Listing 8-8. Ranking AdventureWorks Daily Sales Totals */
WITH TotalSalesBySalesDate
(
DailySales,
OrderDate
)
AS
(
SELECT
SUM(soh.SubTotal) AS DailySales,
soh.OrderDate
FROM Sales.SalesOrderHeader soh
WHERE soh.OrderDate > = '20060101'
AND soh.OrderDate < '20070101'
GROUP BY soh.OrderDate
)
SELECT
RANK() OVER
(
ORDER BY
DailySales DESC
) AS Ranking,
DailySales,
OrderDate
FROM TotalSalesBySalesDate
ORDER BY Ranking;

/*Listing 8-9. Determining the daily sales rankings partitioned by month */
WITH TotalSalesBySalesDatePartitioned
(
DailySales,
OrderMonth,
OrderDate
)
AS
(
SELECT
SUM(soh.SubTotal) AS DailySales,
DATENAME(MONTH, soh.OrderDate) AS OrderMonth,
soh.OrderDate
FROM Sales.SalesOrderHeader soh
WHERE soh.OrderDate > = '20050101'
AND soh.OrderDate < '20060101'
GROUP BY soh.OrderDate
)
SELECT
RANK() OVER
(
PARTITION BY
OrderMonth
ORDER BY
DailySales DESC
) AS Ranking,
DailySales,
OrderMonth,
OrderDate
FROM TotalSalesBySalesDatePartitioned
ORDER BY DATEPART(mm,OrderDate),
Ranking;

/*Listing 8-10. Using DENSE_RANK to Rank Best Daily Sales Per Month */
WITH TotalSalesBySalesDatePartitioned
(
DailySales,
OrderMonth,
OrderDate
)
AS
(
SELECT
SUM(soh.SubTotal) AS DailySales,
DATENAME(MONTH, soh.OrderDate) AS OrderMonth,
soh.OrderDate
FROM Sales.SalesOrderHeader soh
WHERE soh.OrderDate > = '20050101'
AND soh.OrderDate < '20060101'
GROUP BY soh.OrderDate
)
SELECT
RANK() OVER
(
PARTITION BY
OrderMonth
ORDER BY
DailySales DESC
) AS Ranking,
DENSE_RANK() OVER
(
PARTITION BY
OrderMonth
ORDER BY
DailySales DESC
) AS Dense_Ranking,
DailySales,
OrderMonth,
OrderDate
FROM TotalSalesBySalesDatePartitioned
ORDER BY DATEPART(mm,OrderDate),
Ranking;

/*Listing 8-11. Using NTILE to Group and Rank Salespeople */
WITH SalesTotalBySalesPerson
(
SalesPersonID, SalesTotal
)
AS
(
SELECT
soh.SalesPersonID, SUM(soh.SubTotal) AS SalesTotal
FROM Sales.SalesOrderHeader soh
WHERE DATEPART(YEAR, soh.OrderDate) = 2005
AND DATEPART(MONTH, soh.OrderDate) = 7
GROUP BY soh.SalesPersonID ) SELECT
NTILE(4) OVER
( ORDER BY
st.SalesTotal DESC
) AS Tile,
p.LastName,
p.FirstName,
p.MiddleName,
st.SalesPersonID,
st.SalesTotal FROM SalesTotalBySalesPerson st INNER JOIN Person.Person p
ON st.SalesPersonID = p.BusinessEntityID ;

/*Listing 8-13. Using the OVER Clause with SUM */
SELECT
PurchaseOrderID,
ProductID,
OrderQty,
UnitPrice,
LineTotal,
SUM(LineTotal)
OVER (PARTITION BY PurchaseOrderID
ORDER BY ProductId
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS CumulativeOrderOty
FROM Purchasing.PurchaseOrderDetail;

/*Listing 8-14. Query results due to default framing specification */
SELECT
PurchaseOrderID,
ProductID,
OrderQty,
UnitPrice,
LineTotal,
SUM(LineTotal)
OVER (PARTITION BY PurchaseOrderID
ORDER BY ProductId
)
AS TotalSalesDefaultFraming,
SUM(LineTotal)
OVER (PARTITION BY PurchaseOrderID
ORDER BY ProductId RANGE BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
)
AS TotalSalesDefinedFraming
FROM Purchasing.PurchaseOrderDetail
ORDER BY PurchaseOrderID;

/*Listing 8-15. Using the OVER Clause define frame sizes to return two-day, moving average */
SELECT
PurchaseOrderID,
ProductID,
Duedate,
LineTotal,
Avg(LineTotal)
OVER (ORDER BY Duedate
ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
AS [2DayAvg]
FROM Purchasing.PurchaseOrderDetail
ORDER BY Duedate;

/*Listing 8-16. Defining frames from within the OVER clause to calcualte running total */
SELECT
PurchaseOrderID,
ProductID,
OrderQty,
UnitPrice,
LineTotal,
SUM(LineTotal) OVER (PARTITION BY ProductId ORDER BY DueDate
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeTotal,
ROW_NUMBER() OVER (PARTITION BY ProductId ORDER BY DueDate ) AS No
FROM Purchasing.PurchaseOrderDetail
ORDER BY ProductId, DueDate;

/*Listing 8-17. Using the CUME_DIST function */
SELECT
round(SUM(TotalDue),1) AS Sales,
LastName,
FirstName,
SalesPersonId,
CUME_DIST() OVER (ORDER BY round(SUM(TotalDue),1)) as CUME_DIST
FROM
Sales.SalesOrderHeader soh
JOIN Sales.vSalesPerson sp
ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY SalesPersonID,LastName,FirstName;

/*Listing 8-18. Using the PERCENT_RANK function */
SELECT
round(SUM(TotalDue),1) AS Sales,
LastName,
FirstName,
SalesPersonId,
CUME_DIST() OVER (ORDER BY round(SUM(TotalDue),1)) as CUME_DIST
,PERCENT_RANK() OVER (ORDER BY round(SUM(TotalDue),1)) as PERCENT_RANK
FROM
Sales.SalesOrderHeader soh
JOIN Sales.vSalesPerson sp
ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY SalesPersonID,LastName,FirstName;

/*Listing 8-19. Using PERCENTILE_CONT AND PERCENTILE_DISC */
SELECT
round(SUM(TotalDue),1) AS Sales,
LastName,
FirstName,
SalesPersonId,
AccountNumber,
PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY round(SUM(TotalDue),1))
OVER(PARTITION BY AccountNumber ) AS PERCENTILE_CONT,
PERCENTILE_DISC(0.4) WITHIN GROUP(ORDER BY round(SUM(TotalDue),1))
OVER(PARTITION BY AccountNumber ) AS PERCENTILE_DISC
FROM
Sales.SalesOrderHeader soh
JOIN Sales.vSalesPerson sp
ON soh.SalesPersonID = sp.BusinessEntityID
GROUP BY AccountNumber,SalesPersonID,LastName,FirstName

/*Listing 8-20. Using the LAG function */
WITH ProductCostHistory AS
(SELECT
ProductID,
LAG(StandardCost) OVER (PARTITION BY ProductID ORDER BY ProductID) AS PreviousProductCost,
StandardCost AS CurrentProductCost,
Startdate,Enddate
FROM Production.ProductCostHistory
)
SELECT
ProductID,
PreviousProductCost,
CurrentProductCost,
StartDate,
EndDate
FROM ProductCostHistory
WHERE Enddate IS NULL

/* Listing 8-21. Using the LEAD function */
Select
LastName,
SalesPersonID,
Sum(SubTotal) CurrentMonthSales,
DateNAME(Month,OrderDate) Month,
DateName(Year,OrderDate) Year,
LEAD(Sum(SubTotal),1) OVER (ORDER BY SalesPersonID, OrderDate) TotalSalesNextMonth
FROM
Sales.SalesOrderHeader soh
JOIN Sales.vSalesPerson sp
ON soh.SalesPersonID = sp.BusinessEntityID
WHERE DateName(Year,OrderDate) = 2007
GROUP BY
FirstName, LastName, SalesPersonID,OrderDate
ORDER BY SalesPersonID,OrderDate;

/*Listing 8-22. Using FIRST_VALUE and LAST_VALUE */
SELECT DISTINCT
LastName,
SalesPersonID,
datename(year,OrderDate) OrderYear,
datename(month, OrderDate) OrderMonth,
FIRST_VALUE(SubTotal) OVER (PARTITION BY SalesPersonID, OrderDate ORDER BY
SalesPersonID ) FirstSalesAmount,
LAST_VALUE(SubTotal) OVER (PARTITION BY SalesPersonID, OrderDate ORDER BY
SalesPersonID) LastSalesAmount,
OrderDate
FROM
Sales.SalesOrderHeader soh
JOIN Sales.vSalesPerson sp
ON soh.SalesPersonID = sp.BusinessEntityID
ORDER BY OrderDate;

