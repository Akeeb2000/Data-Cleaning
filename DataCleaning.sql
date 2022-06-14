--DATA CLEANING IN MYSQL

USE Portfolio

SELECT 
* FROM NatashHousing

----STANDARDIZING DATE FORMAT
SELECT 
SaleDateCov, CONVERT(DATE,SaleDate)
FROM NatashHousing

UPDATE NatashHousing
SET SaleDate =  CONVERT(DATE,SaleDate)

ALTER TABLE NatashHousing
ADD SaleDateCov DATE;

UPDATE NatashHousing
SET SaleDateCov = CONVERT(DATE,SaleDate)

---PROPERTY ADDRESS

SELECT 
*
FROM NatashHousing
--WHERE PropertyAddress IS NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NatashHousing a
JOIN NatashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NatashHousing a
JOIN NatashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--BREAKING ADDRESS INTO DIFFERENT COLUMNS
SELECT 
PropertyAddress
FROM NatashHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM NatashHousing

ALTER TABLE NatashHousing
Add PropertySplitAddress Nvarchar(255);

Update NatashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NatashHousing
Add PropertySplitCity Nvarchar(255);

Update NatashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---OWNER ADDRESS
SELECT
OwnerAddress
FROM NatashHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NatashHousing

ALTER TABLE NatashHousing
Add OwnerSplitAddress Nvarchar(255);

Update NatashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NatashHousing
Add OwnerSplitCity Nvarchar(255);

Update NatashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NatashHousing
Add OwnerSplitState Nvarchar(255);

Update NatashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Changing Y and N to Yes and No in the Sold as Vacant field
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM NatashHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NatashHousing

Update NatashHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---Removing Duplicate Values
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NatashHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--DELETE DUPLICATE ROW
--REPLACE SELECT FROM THE CTE WITH DELETE
--Property Address

--DROPPING UNUSED COLUMNS
--NOT ADVISABLE FOR RAW DATA

/*  ALTER TABLE NatashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate */
