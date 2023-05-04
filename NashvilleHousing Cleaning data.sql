/*
Cleaning Data in SQL Queries
*/
SELECT *
FROM NashvilleHousing.dbo.NashvilleData
-------------------------------------------------------------------------------------

-- Standardize Data Format
SELECT  saleDateConverted, CONVERT(date,saleDate)
FROM NashvilleHousing.dbo.NashvilleData

UPDATE NashvilleData
SET saleDate = CONVERT(date,saleDate)

ALTER TABLE NashvilleData
ADD saleDateConverted date;

UPDATE NashvilleData
SET saleDateConverted = CONVERT(date,saleDate)

----------------------------------------------------
-- Populate Property Address Data

SELECT  *
FROM NashvilleHousing.dbo.NashvilleData
--WHERE PropertyAddress is null
ORDER BY ParcelID

-- isnull is replace the a.propertyaddress by b.propertyaddress
SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleData a
JOIN NashvilleHousing.dbo.NashvilleData b
     ON a.ParcelID =b.ParcelID
	 AND a.[UniqueID]<> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleData a
JOIN NashvilleHousing.dbo.NashvilleData b
     ON a.ParcelID =b.ParcelID
	 AND a.[UniqueID]<> b.[UniqueID]

-- Breaking out address into individual columns( Address,city, state)


SELECT  PropertyAddress
FROM NashvilleHousing.dbo.NashvilleData
--WHERE PropertyAddress is null
--ORDER BY ParcelID

-- using substring, -1 to get rid of the comma, 2ns substring is made for the rest of address to appear

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing.dbo.NashvilleData

ALTER TABLE NashvilleData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))



SELECT *
FROM NashvilleHousing.dbo.NashvilleData


--breake owneraddress, using parsename( PARSENAME DOING THE THINGS BACKWARD) THATS why thee order is 3,2,1


SELECT OwnerAddress
FROM NashvilleHousing.dbo.NashvilleData


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.') ,3) as OwnerSplitAddress
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2) as OwnerSplitCity
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1) as OwnerSplitSate
FROM NashvilleHousing.dbo.NashvilleData

ALTER TABLE NashvilleData
ADD OwnerSplitAddress nvarchar(255);


UPDATE NashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleData
ADD OwnerSplitCity nvarchar(255);


UPDATE NashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleData
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)


SELECT *
FROM NashvilleHousing.dbo.NashvilleData


-- Change Y and N to Yes and No in "Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing.dbo.NashvilleData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing.dbo.NashvilleData

UPDATE NashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- remove duplicates, rank, order rank, row numbers

SELECT *,
    ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
	            PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num
FROM NashvilleHousing.dbo.NashvilleData
ORDER BY ParcelID

-- other way
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
	            PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num
FROM NashvilleHousing.dbo.NashvilleData
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Delete Unsed Columns

SELECT *
FROM NashvilleHousing.dbo.NashvilleData


ALTER TABLE NashvilleHousing.dbo.NashvilleData
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing.dbo.NashvilleData
DROP COLUMN SaleDate