/*
Cleaning Data in SQL Queries
*/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---Standardize Date format
SELECT *
FROM   portfolioproject.dbo.nashvillehousing
select saledate
FROM   portfolioproject.dbo.nashvillehousing
SELECT saledate,
       CONVERT(date,saledate)
FROM   portfolioproject.dbo.nashvillehousing
ALTER TABLE nashvillehousing ADD saledateconverted date
UPDATE nashvillehousing
SET    saledateconverted=CONVERT(date,saledate)
SELECT saledateconverted
FROM   portfolioproject.dbo.nashvillehousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----Populate property address data
SELECT *
FROM   portfolioproject.dbo.nashvillehousing
WHERE  propertyaddress IS NULL
SELECT a.parcelid,
       a.propertyaddress,
       b.parcelid,
       b.propertyaddress
FROM   portfolioproject.dbo.nashvillehousing a
JOIN   portfolioproject.dbo.nashvillehousing b
ON     a.parcelid=b.parcelid
AND    a.uniqueid <> b.uniqueid
WHERE  a.propertyaddress IS NULL
SELECT a.parcelid,
       a.propertyaddress,
       b.parcelid,
       b.propertyaddress,
       isnull(a.propertyaddress,b.propertyaddress)
FROM   portfolioproject.dbo.nashvillehousing a
JOIN   portfolioproject.dbo.nashvillehousing b
ON     a.parcelid=b.parcelid
AND    a.uniqueid <> b.uniqueid
WHERE  a.propertyaddress IS NULL
UPDATE a
SET    propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
FROM   portfolioproject.dbo.nashvillehousing a
JOIN   portfolioproject.dbo.nashvillehousing b
ON     a.parcelid=b.parcelid
AND    a.uniqueid <> b.uniqueid
WHERE  a.propertyaddress IS NULL


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out property address into individual columns (Address,City,State)

SELECT propertyaddress
FROM   portfolioproject.dbo.nashvillehousing
SELECT substring(propertyaddress, 1, charindex(',',propertyaddress)-1) AS address
FROM   portfolioproject.dbo.nashvillehousing;SELECT Substring(propertyaddress, 1, Charindex(',', propertyaddress) -1 )                     AS Address ,
       Substring(propertyaddress, Charindex(',', propertyaddress) + 1 , Len(propertyaddress)) AS Address;ALTER TABLE portfolioproject.dbo.nashvillehousing ADD propertysplitaddress NVARCHAR(255);UPDATE portfolioproject.dbo.nashvillehousing
SET    propertysplitaddress=Substring(propertyaddress, 1, Charindex(',', propertyaddress) -1 );ALTER TABLE portfolioproject.dbo.nashvillehousing ADD propertsplitcity NVARCHAR(255);UPDATE portfolioproject.dbo.nashvillehousing
SET    propertsplitcity=Substring(propertyaddress, Charindex(',', propertyaddress) + 1 , Len(propertyaddress));SELECT *
FROM   portfolioproject.dbo.nashvillehousing;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out owner address into individual columns (Address,City,State)

SELECT owneraddress
FROM   portfolioproject.dbo.nashvillehousing
select parsename(REPLACE(owneraddress,',','.'),3),
       parsename(REPLACE(owneraddress,',','.'),2),
       parsename(REPLACE(owneraddress,',','.'),1)
FROM   portfolioproject.dbo.nashvillehousing
ALTER TABLE portfolioproject.dbo.nashvillehousing ADD ownersplitaddress nvarchar(255);UPDATE portfolioproject.dbo.nashvillehousing
SET    ownersplitaddress=Parsename(REPLACE(owneraddress,',','.'),3)
alter TABLE portfolioproject.dbo.nashvillehousing ADD ownersplitcity nvarchar(255);UPDATE portfolioproject.dbo.nashvillehousing
SET    ownersplitcity=Parsename(REPLACE(owneraddress,',','.'),2)
alter TABLE portfolioproject.dbo.nashvillehousing ADD ownersplitstate nvarchar(255);UPDATE portfolioproject.dbo.nashvillehousing
SET    ownersplitstate=Parsename(REPLACE(owneraddress,',','.'),1)
select *
FROM   portfolioproject.dbo.nashvillehousing


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(soldasvacant),
                count(soldasvacant)
FROM            portfolioproject.dbo.nashvillehousing
GROUP BY        soldasvacant
ORDER BY        2;SELECT soldasvacant ,
       CASE
              WHEN soldasvacant ='Y' THEN 'YES'
              WHEN soldasvacant='N' THEN 'NO'
              ELSE soldasvacant
       end
FROM   portfolioproject.dbo.nashvillehousing
update portfolioproject.dbo.nashvillehousing
SET    soldasvacant=
       CASE
              WHEN soldasvacant ='Y' THEN 'YES'
              WHEN soldasvacant='N' THEN 'NO'
              ELSE soldasvacant
       end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates

SELECT   *,
         row_number() over ( partition BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid) row_num
FROM     portfolioproject.dbo.nashvillehousing
ORDER BY parcelid;

--WITH rownumcte
AS
  (
           SELECT   *,
                    row_number() over ( partition BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid) row_num
           FROM     portfolioproject.dbo.nashvillehousing
                    --order by ParcelID;
  )
  SELECT   *
  FROM     rownumcte
  WHERE    row_num>1
  ORDER BY propertyaddress
           --
           WITH rownumcte AS
           (
                    SELECT   *,
                             row_number() over ( partition BY parcelid, propertyaddress, saleprice, saledate, legalreference ORDER BY uniqueid) row_num
                    FROM     portfolioproject.dbo.nashvillehousing
                             --order by ParcelID;
           )
  DELETE
  FROM   rownumcte
  WHERE  row_num>1
  --order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---Delete Unused Columns
 
  SELECT *
  FROM   portfolioproject.dbo.nashvillehousing
  ALTER TABLE portfolioproject.dbo.nashvillehousing DROP COLUMN propertyaddress,
              owneraddress,
              taxdistrict,
              saledate
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------		