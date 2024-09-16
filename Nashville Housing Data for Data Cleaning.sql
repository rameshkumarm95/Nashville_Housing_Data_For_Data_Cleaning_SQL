-- Database 
USE [SQL_Portfolio_Projects];


-- View all the attributes and the records
SELECT * FROM Nashville_Housing_Data;

-- Data cleaning

-- 1. Standardize Date format
ALTER TABLE Nashville_Housing_Data
ALTER COLUMN SaleDate DATE;

SELECT SaleDate
FROM Nashville_Housing_Data;

-- 2. Populate Property Address data
SELECT PropertyAddress
FROM Nashville_Housing_Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- 3. Breaking out Address into individual columns(Address, city, state)
SELECT PropertyAddress
FROM Nashville_Housing_Data;

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
AS propertysplitaddress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress))
AS propertysplitcity
FROM Nashville_Housing_Data


ALTER TABLE Nashville_Housing_data
ADD propertysplitaddress NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET propertysplitaddress = 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE Nashville_Housing_Data
ADD propertysplitcity NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET propertysplitcity = 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress));


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS ownersplitaddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS ownersplitcity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS ownersplitstate
FROM Nashville_Housing_Data;


ALTER TABLE Nashville_Housing_Data
ADD ownersplitaddress NVARCHAR(255);

ALTER TABLE Nashville_Housing_Data
ADD ownersplitcity NVARCHAR(255);

ALTER TABLE Nashville_Housing_Data
ADD ownersplitstate NVARCHAR(255);

UPDATE Nashville_Housing_Data
SET ownersplitaddress =
PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE Nashville_Housing_Data
SET ownersplitcity =
PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE Nashville_Housing_Data
SET ownersplitstate =
PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT ownersplitcity, ownersplitstate, ownersplitaddress
FROM Nashville_Housing_Data;



-- 4. Change y and n to yes and no in 'sold as vacant' field
SELECT DISTINCT SoldAsVacant
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ALTER COLUMN SoldAsVacant NVARCHAR(10);

UPDATE Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN
'Yes' WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant END


-- 5. Remove Duplicates
WITH duplicates AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) AS rn
FROM Nashville_Housing_Data
)
DELETE
FROM duplicates
WHERE rn > 1;


-- 6. Drop unused columns
SELECT * FROM 
Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
