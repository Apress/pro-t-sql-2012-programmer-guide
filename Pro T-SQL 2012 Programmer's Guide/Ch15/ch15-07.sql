------------------------------------------------------
-- Listing 15-7. Creating the ZipCodes Target Table --
------------------------------------------------------
CREATE  TABLE  dbo.ZipCodes
(
    ZIP  CHAR(5)  NOT  NULL  PRIMARY  KEY,
    Latitude NUMERIC(8, 4) NOT NULL,
    Longitude NUMERIC(8, 4) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    State CHAR(2) NOT NULL
)
GO
