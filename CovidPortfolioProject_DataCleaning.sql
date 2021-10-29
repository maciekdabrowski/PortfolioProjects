/*

Cleaning data in SQL queries

*/

SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing

 
--Standardize Date Format
SELECT 
	SaleDate,
	CONVERT(Date,SaleDate)
 FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT 
	SaleDateConverted,
	CONVERT(Date,SaleDate)
 FROM PortfolioProject..NashvilleHousing


--Populate Property Address Data
SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out address into individual columns (Address, City, State)
SELECT PropertyAddress
 FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, --CHARINDEX includes comma, '-1' removes it
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
 FROM PortfolioProject.dbo.NashvilleHousing

--		property address
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--		property city
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--		OwnerAddress
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), --address --PARSENAME looks for periods ('.'), and does things backwards
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), --city
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) --state
 FROM PortfolioProject.dbo.NashvilleHousing

 --		owner address
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--		owner city
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--		owner state
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
 FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

SELECT DISTINCT
	SoldAsVacant,
	COUNT(SoldAsVacant)
 FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


--Remove Duplicates
WITH RowNumCTE AS(
	SELECT 
		*,
		ROW_NUMBER() OVER (
			PARTITION BY
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS row_num

	 FROM PortfolioProject..NashvilleHousing
)
DELETE
 FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN
	OwnerAddress,
	TaxDistrict,
	PropertyAddress,

ALTER TABLE PortfolioProject..NashvilleHousing --alter table cannot be rolled back and changed so need to write another statement
DROP COLUMN
	SaleDate

SELECT * --checking if worked
 FROM PortfolioProject..NashvilleHousing
