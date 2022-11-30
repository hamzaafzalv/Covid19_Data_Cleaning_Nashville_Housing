USE PortfolioProject;

Select * from NashvilleHousing;

-- Standardize Date Format for Sale Date

Select SaleDate ,CONVERT(Date, SaleDate) from NashvilleHousing

UPDATE NashvilleHousing SET SaleDate = CONVERT(Date, SaleDate)


-- Populate Property Address

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,a.[UniqueID ],b.[UniqueID ], ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- Breaking Address down into individual string 
select propertyaddress from NashvilleHousing

select 
substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(Propertyaddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
from  NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = substring(Propertyaddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress  = substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

Select * from NashvilleHousing

-- Breaking down owner address into address,city and state 

Select OwnerAddress from NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- Change Y and N to Yes or No in Sold as Vacant column

Select Distinct(SoldasVacant), count(soldasvacant)
from nashvillehousing 
GROUP BY soldasvacant
order by soldasvacant 


Select SoldasVacant ,
CASE When Soldasvacant = 'Y' THEN 'Yes'
	When Soldasvacant = 'N' THEN 'No'
	Else SoldasVacant
	END
from Nashvillehousing

---- Removing Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY  ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
				) row_num

From NashvilleHousing 
)

SELECT * from RowNumCTE
DELETE 
from RowNumCTE
WHERE row_num > 1

-- delete unused column
 