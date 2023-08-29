-- cleaning data in SQL queries
-- skills used: joins, CTE's, aggregate functions, converting data types, CASE statement


-- quering the data from the database


SELECT 
	* 
FROM 
	portfolio_project_02.dbo.nashville_housing


-- standardize date format


SELECT 
	SaleDate, 
	CONVERT(Date, SaleDate)
FROM 
	portfolio_project_02.dbo.nashville_housing

UPDATE portfolio_project_02.dbo.nashville_housing
SET SaleDate = CONVERT(Date, SaleDate)


-- populate Property Address data


SELECT
	*
FROM 
	portfolio_project_02.dbo.nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
	A.ParcelID, 
	A.PropertyAddress, 
	B.ParcelID, 
	B.PropertyAddress, 
	ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM 
	portfolio_project_02.dbo.nashville_housing A
	JOIN portfolio_project_02.dbo.nashville_housing B ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE 
	A.PropertyAddress IS NULL

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM 
	portfolio_project_02.dbo.nashville_housing A
	JOIN portfolio_project_02.dbo.nashville_housing B ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE 
	A.PropertyAddress IS NULL


-- breaking out Address into individual columns (Address, City, State)


SELECT 
	PropertyAddress
FROM 
	portfolio_project_02.dbo.nashville_housing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM 
	portfolio_project_02.dbo.nashville_housing


ALTER TABLE portfolio_project_02.dbo.nashville_housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE portfolio_project_02.dbo.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE portfolio_project_02.dbo.nashville_housing
ADD PropertySplitCity Nvarchar(255);

UPDATE portfolio_project_02.dbo.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT
	*
FROM
	portfolio_project_02.dbo.nashville_housing

SELECT 
	OwnerAddress
FROM 
	portfolio_project_02.dbo.nashville_housing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM 
	portfolio_project_02.dbo.nashville_housing

ALTER TABLE portfolio_project_02.dbo.nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE portfolio_project_02.dbo.nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE portfolio_project_02.dbo.nashville_housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE portfolio_project_02.dbo.nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE portfolio_project_02.dbo.nashville_housing
ADD OwnerSplitState Nvarchar(255);

UPDATE portfolio_project_02.dbo.nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT 
	*
FROM
	portfolio_project_02.dbo.nashville_housing


-- change Y and N to Yes and No in "Sold as Vacant" field


SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM 
	portfolio_project_02.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM portfolio_project_02.dbo.nashville_housing

UPDATE portfolio_project_02.dbo.nashville_housing
SET SoldAsVacant = CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END


-- remove duplicates


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

From portfolio_project_02.dbo.nashville_housing
--order by ParcelID
)
SELECT 
	*
FROM 
	RowNumCTE
WHERE 
	row_num > 1
ORDER BY PropertyAddress

SELECT 
	*
FROM
	portfolio_project_02.dbo.nashville_housing


-- delete unused columns


SELECT 
	*
FROM 
	portfolio_project_02.dbo.nashville_housing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


