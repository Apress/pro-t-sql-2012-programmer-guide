/*Listing 12 - 1. Retrieving Names and E-mail Addresses with FOR XML PATH */
SELECT
p.BusinessEntityID AS "Person/ID",
p.FirstName AS "Person/Name/First",
p.MiddleName AS "Person/Name/Middle",
p.LastName AS "Person/Name/Last",
e.EmailAddress AS "Person/Email"
FROM Person.Person p INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID
FOR XML PATH, ROOT('PersonEmailAddress');

/*Listing 12 - 2. FOR XML PATH Creating XML Attributes */
SELECT p.BusinessEntityID AS "Person/@ID",
e.EmailAddress AS "Person/@Email",
p.FirstName AS "Person/Name/First",
p.MiddleName AS "Person/Name/Middle",
p.LastName AS "Person/Name/Last"
FROM Person.Person p INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID FOR XML PATH;

/*Listing 12 - 3. Using Columns without Names and Wildcards with FOR XML PATH */
SELECT p.BusinessEntityID AS "*", ',' + e.EmailAddress,
p.FirstName AS "Person/Name/First",
p.MiddleName AS "Person/Name/Middle",
p.LastName AS "Person/Name/Last" FROM Person.Person p INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID FOR XML PATH;

/*Listing 12 - 4. Two Elements with a Common Parent Element Separated */
SELECT p.BusinessEntityID AS "@ID",
e.EmailAddress AS "@EmailAddress",
p.FirstName AS "Person/Name/First",
pp.PhoneNumber AS "Phone/BusinessPhone",
p.MiddleName AS "Person/Name/Middle",
p.LastName AS "Person/Name/Last"
FROM Person.Person p
INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID
INNER JOIN Person.PersonPhone pp
ON p.BusinessEntityID = pp.BusinessEntityID
AND pp.PhoneNumberTypeID = 3 FOR XML PATH;

/*Listing 12 - 5. The FOR XML PATH XPath data Node Test */
SELECT DISTINCT soh.SalesPersonID AS "SalesPerson/@ID", (
SELECT soh2.SalesOrderID AS "data()"
FROM Sales.SalesOrderHeader soh2
WHERE soh2.SalesPersonID = soh.SalesPersonID FOR XML PATH ('') ) AS
"SalesPerson/@Orders",
p.FirstName AS "SalesPerson/Name/First",
p.MiddleName AS "SalesPerson/Name/Middle",
p.LastName AS "SalesPerson/Name/Last",
e.EmailAddress AS "SalesPerson/Email"
FROM Sales.SalesOrderHeader soh
INNER JOIN Person.Person p
ON p.BusinessEntityID = soh.SalesPersonID
INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID
WHERE soh.SalesPersonID IS NOT NULL FOR XML PATH;

/*Listing 12 - 6. FOR XML with the ELEMENTS XSINIL Option */
SELECT
p.BusinessEntityID AS "Person/ID",
p.FirstName AS "Person/Name/First",
p.MiddleName AS "Person/Name/Middle",
p.LastName AS "Person/Name/Last",
e.EmailAddress AS "Person/Email" FROM Person.Person p INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID FOR XML PATH,
ELEMENTS XSINIL;

/*Listing 12 - 7. Using WITH XMLNAMESPACES to Specify Namespaces */
WITH XMLNAMESPACES(' http://www.apress.com/xml/sampleSqlXmlNameSpace ' as ns)
SELECT
p.BusinessEntityID AS "ns:Person/ID",
p.FirstName AS "ns:Person/Name/First",
p.MiddleName AS "ns:Person/Name/Middle",
p.LastName AS "ns:Person/Name/Last",
e.EmailAddress AS "ns:Person/Email"
FROM Person.Person p
INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID
FOR XML PATH;

/*Listing 12 - 8. FOR XML PATH Using XPath Node Tests */
SELECT
p.NameStyle AS "processing-instruction(nameStyle)",
p.BusinessEntityID AS "Person/@ID",
p.ModifiedDate AS "comment()",
pp.PhoneNumber AS "text()",
FirstName AS "Person/Name/First",
MiddleName AS "Person/Name/Middle",
LastName AS "Person/Name/Last",
EmailAddress AS "Person/Email"
FROM Person.Person p
INNER JOIN Person.EmailAddress e
ON p.BusinessEntityID = e.BusinessEntityID
INNER JOIN Person.PersonPhone pp
ON p.BusinessEntityID = pp.BusinessEntityID
FOR XML PATH;

/*Listing 12 - 9. Retrieving Job Candidates with the query Method */
SELECT Resume.query
(
N'//*:Name.First,
//*:Name.Middle,
//*:Name.Last,
//*:Edu.Level'
)
FROM HumanResources.JobCandidate;

/*Listing 12 - 10. Querying with an Absolute Location Path */
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Geocode>
<Info ID = "1">
<Coordinates Resolution = "High">
<Latitude > 37.859609</Latitude>
<Longitude > −122.291673</Longitude>
</Coordinates>
<Location Type = "Business">
<Name > APress, Inc.</Name>
</Location>
</Info>
<Info ID = "2">
<Coordinates Resolution = "High">
<Latitude > 37.423268</Latitude>
<Longitude > −122.086345</Longitude>
</Coordinates>
<Location Type = "Business">
<Name > Google, Inc.</Name>
</Location>
</Info>
</Geocode > ';
SELECT @x.query(N'/Geocode/Info/Coordinates');

/*Listing 12 - 11. Sample Processing-instruction Node Test */
SELECT CatalogDescription.query(N'/processing-instruction()') AS Processing_Instr
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 12. Sample comment Node Test */
SELECT CatalogDescription.query(N'//comment()') AS Comments
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 13. Sample node Node Test */
SELECT CatalogDescription.query(N'//*:Specifications/node()') AS Specifications
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 14. Querying CatalogDescription with No Namespaces */
SELECT CatalogDescription.query(N'//Specifications/node()') AS Specifications
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 15. Prolog Namespace Declaration */
SELECT CatalogDescription.query
(
N'declare namespace
p1 = " http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
//p1:Specifications/node()'
)
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 16. Prolog Default Namespace Declaration */
SELECT CatalogDescription.query
(
N'declare default element namespace
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
//Specifications/node()'
)
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 17. Query with and Without Default Axes */
SELECT CatalogDescription.query(N'//*:Specifications/node()') AS Specifications
FROM Production.ProductModel
WHERE ProductModelID = 19;
SELECT CatalogDescription.query(N'//child::*:Specifications/child::node()')
AS Specifications
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 18. Sample Using the parent:: Axis */
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Geocode>
<Info ID = "1">
<Coordinates Resolution = "High">
<Latitude > 37.859609</Latitude>
<Longitude > −122.291673</Longitude>
</Coordinates>
<Location Type = "Business">
<Name > APress, Inc.</Name>
</Location>
</Info>
<Info ID = "2">
<Coordinates Resolution = "High">
<Latitude > 37.423268</Latitude>
<Longitude > −122.086345</Longitude>
</Coordinates>
<Location Type = "Business">
<Name > Google, Inc.</Name>
</Location>
</Info>
</Geocode > ';
SELECT @x.query(N'//Location/parent::node()/Coordinates');

/*Listing 12 - 19. XQuery Dynamic XML Construction */
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Geocode>
<Info ID = "1">
<Location Type = "Business">
<Name > APress, Inc.</Name>
</Location>
</Info>
<Info ID = "2">
<Location Type = "Business">
<Name > Google, Inc.</Name>
</Location>
</Info>
</Geocode > ';
SELECT @x.query(N'< Companies>
{
//Info/Location/Name
}
</Companies > ');

/*Listing 12 - 20. Element and Attribute Dynamic Constructors */
SELECT CatalogDescription.query
(
N'declare namespace
p1 = " http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
//p1:Specifications/node()'
)
FROM Production.ProductModel
WHERE ProductModelID = 19;
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Geocode>
<Info ID = "1">
<Location Type = "Business">
<Name > APress, Inc.</Name>
<Address>
<Street > 2560 Ninth St, Ste 219</Street>
<City > Berkeley</City>
<State > CA</State>
<Zip > 94710-2500</Zip>
<Country > US</Country>
</Address>
</Location>
</Info>
</Geocode > ';
SELECT @x.query
(
N'element Companies
{
element FirstCompany
{
attribute CompanyID
{
(//Info/@ID)[1]
},
(//Info/Location/Name)[1]
}
}'
);

/*Listing 12 - 21. Value Comparison Examples */
DECLARE @x xml = N'< ?xml version = "1.0" ?>
<Animal>
Cat
</Animal > ';
SELECT @x.query(N'9 eq 9.0 (: 9 is equal to 9.0 :)');
SELECT @x.query(N'4 gt 3 (: 4 is greater than 3 :)');
SELECT @x.query(N'(/Animal/text())[1] lt "Dog" (: Cat is less than Dog :)') ;

/*Listing 12 - 22. Incompatible Type Value Comparison */
DECLARE @x xml = N'';
SELECT @x.query(N'3.141592 eq "Pi"') ;
Msg 2234, Level 16, State 1, Line 2
XQuery [query()]: The operator "eq" cannot be applied to "xs:decimal" and "xs:string" operands.

/*Listing 12 - 23. General Comparison Examples */
DECLARE @x xml = '';
SELECT @x.query('(3.141592, 1) = (2, 3.141592) (: true :) ');
SELECT @x.query('(1.0, 2.0, 3.0) = 1 (: true :) ');
SELECT @x.query('("Joe", "Harold") < "Adam" (: false :) ');
SELECT @x.query('xs:date("1999-01-01") < xs:date("2006-01-01") (: true :)');

/*Listing 12 - 24. General Comparison with Heterogeneous Sequence */
DECLARE @x xml = '';
SELECT @x.query('(xs:date("2006-10-09"), 6.02E23) > xs:date("2007-01-01")');

/*Listing 12 - 25. Mixing Nodes and Atomic Values in Sequences */
DECLARE @x xml = '';
SELECT @x.query('(1, <myNode > Testing</myNode>)');

/*Listing 12 - 26. Node Comparison Samples */
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Root>
<NodeA > Test Node</NodeA>
<NodeA > Test Node</NodeA>
<NodeB > Test Node</NodeB>
</Root > ';
SELECT @x.query('((/Root/NodeA)[1] is (//NodeA)[1]) (: true :)');
SELECT @x.query('((/Root/NodeA)[1] is (/Root/NodeA)[2]) (: false :)');
SELECT @x.query('((/Root/NodeA)[2] is (/Root/NodeB)[1]) (: true :)');

/*Listing 12 - 27. Node Comparison That Evaluates to an Empty Sequence */
DECLARE @x xml = N'< ?xml version = "1.0"?>
<Root>
<NodeA > Test Node</NodeA>
</Root > ';
SELECT @x.query('((/Root/NodeA)[1] is (/Root/NodeZ)[1]) (: empty sequence :)');

/*Listing 12 - 28. The sql:column Function */
DECLARE @x xml = N'';
SELECT @x.query(N'< Name>
<ID>
{
sql:column("p.BusinessEntityID")
}
</ID>
<FullName>
{
sql:column("p.FirstName"),
sql:column("p.MiddleName"),
sql:column("p.LastName")
}
</FullName>
</Name > ')
FROM Person.Person p
WHERE p.BusinessEntityID < = 5
ORDER BY p.BusinessEntityID;

/*Listing 12 - 29. XQuery sql:column and sql:variable Functions Example */
/* 10 % discount */
DECLARE @discount NUMERIC(3, 2);
SELECT @discount = 0.10;
DECLARE @x xml;
SELECT @x = '';
SELECT @x.query('< Product>
<Model-ID > { sql:column("ProductModelID") }</Model-ID>
<Name > { sql:column("Name") }</Name>
<Price > { sql:column("ListPrice") } </Price>
<DiscountPrice>
{ sql:column("ListPrice") -
(sql:column("ListPrice") * sql:variable("@discount") ) }
</DiscountPrice>
</Product>
')
FROM Production.Product p
WHERE ProductModelID = 30;

/*Listing 12 - 30. Basic XQuery for . . . return Expression */
SELECT CatalogDescription.query(N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/*
return fn:string($spec)') AS Description FROM Production.ProductModel WHERE ProductModelID = 19;

/*Listing 12 - 31. XQuery for . . . return Expression with XML Result */
SELECT CatalogDescription.query (
N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/* return < detail > {
$spec/text() } </detail > ' ) AS Description
FROM Production.ProductModel WHERE ProductModelID = 19;

/*Listing 12 - 32. XQuery Cartesian Product with for Expression */
SELECT CatalogDescription.query(N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/*,
$feat in //ns:ProductDescription/*:Features/*:Warranty/node()
return < detail>
{
$spec/text()
} +
{
fn:string($feat/.)
}
</detail > '
) AS Description
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 33. Using a Bound Variable in the for Clause */
SELECT CatalogDescription.query
(
N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications,
$color in $spec/Color
return < color>
{
$color/text()
}
</color > '
) AS Color
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 34. where Clause Demonstration */
SELECT CatalogDescription.query
(
N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/*
where $spec[ contains( . , "A" ) ]
return < detail>
{
$spec/text()
}
</detail > '
) AS Detail
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 35. order by Clause */
SELECT CatalogDescription.query(N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/*
order by $spec/. descending
return < detail > { $spec/text() } </detail > ') AS Detail
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 36. let Clause */
SELECT CatalogDescription.query
(
N'declare namespace ns =
" http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription ";
for $spec in //ns:ProductDescription/ns:Specifications/*
let $val := $spec/text()
order by fn:string($val[1]) ascending
return < spec>
{
$val
}
</spec > '
) AS Detail
FROM Production.ProductModel
WHERE ProductModelID = 19;

/*Listing 12 - 37. Create Record to Demonstrate UTF-16 */
declare @BusinessEntityId int
INSERT INTO Person.BusinessEntity(rowguid, ModifiedDate)
VALUES (NEWID(),CURRENT_TIMESTAMP)
SET @BusinessEntityId = SCOPE_IDENTITY()
INSERT INTO [Person].[Person]
([BusinessEntityID]
,[PersonType]
,[NameStyle]
,[Title]
,[FirstName]
,[MiddleName]
,[LastName]
,[Suffix]
,[EmailPromotion]
,[AdditionalContactInfo]
,[Demographics]
,[rowguid]
,[ModifiedDate])
VALUES
396
(@BusinessEntityId,
'EM',
0,
NULL,
N'T' + nchar(0xD834) + nchar(0xDD25),
'J',
'Kim',
NULL,
0,
NULL,
'< IndividualSurvey xmlns = " http://schemas.microsoft.com/sqlserver/2004/07/
adventure-works/IndividualSurvey"><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey >',
NEWID(),
CURRENT_TIMESTAMP)


/*Listing 12 - 38. SQL Server to Check for Presence of Surrogates */
SELECT
p.NameStyle AS "processing-instruction(nameStyle)",
p.BusinessEntityID AS "Person/@ID",
p.ModifiedDate AS "comment()",
FirstName AS "Person/Name/First",
Len(FirstName) AS "Person/FirstName/Length",
MiddleName AS "Person/Name/Middle",
LastName AS "Person/Name/Last"
FROM Person.Person p
WHERE BusinessEntityID = 20778
FOR XML PATH;

/*Listing 12-39. Surroage Pair with UTF-16 and _SC collation */
SELECT
p.NameStyle AS "processing-instruction(nameStyle)",
p.BusinessEntityID AS "Person/@ID",
p.ModifiedDate AS "comment()",
FirstName AS "Person/Name/First",
Len(FirstName COLLATE Latin1_General_100_CS_AS_SC) AS "Person/FirstName/Length",
MiddleName AS "Person/Name/Middle",
LastName AS "Person/Name/Last"
FROM Person.Person p
WHERE BusinessEntityID = 20778
FOR XML PATH;
