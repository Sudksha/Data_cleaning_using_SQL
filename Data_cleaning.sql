---------Cleaning data through queries

Select * from dbo.Housing_data_cleaning$


-------------------------------------------------------------------------------------------------------------
----Standardise the date format

Select SaleDate,convert(date, SaleDate)
from dbo.Housing_data_cleaning$

ALTER TABLE dbo.Housing_data_cleaning$
ADD SaledateConverted Date;

Update dbo.Housing_data_cleaning$
set SaledateConverted=convert(date, SaleDate)

Select SaledateConverted
from dbo.Housing_data_cleaning$

-------------------------------------------------------------------------------------------------------------------------

-----Populate Property Address


Select * from dbo.Housing_data_cleaning$
--where PropertyAddress is null
order by 2

---There are some ParcelID which are same have the same propertyaddress. Hence we need to self join 2 columns

---Here we have joined to columns which have same ParcelID but different UniqueID

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing_data_cleaning$ a
JOIN dbo.Housing_data_cleaning$ b 
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing_data_cleaning$ a
JOIN dbo.Housing_data_cleaning$ b 
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID]
where a.PropertyAddress is null

---So at the end of this query in the dataset where ever the PropertAddress is null is now filled with the address based on the same parcelID.

------------------------------------------------------------------------------------------------------------------------------------------------------------


----Next we will break the PropertAddress as Address,city,state.

SELECT PropertyAddress from dbo.Housing_data_cleaning$

SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS State
from dbo.Housing_data_cleaning$

-----Here charindex will give position number of ',' hence adding -1 mean ',' should not be present in the addess

---Let's alter and update the dataset
ALTER TABLE dbo.Housing_data_cleaning$

ADD PropertySplitAddress Nvarchar(255)

Update dbo.Housing_data_cleaning$
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.Housing_data_cleaning$
ADD PropertySplitCity Nvarchar(255);

Update dbo.Housing_data_cleaning$
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


Select * from dbo.Housing_data_cleaning$
order by 1

Select OwnerAddress from dbo.Housing_data_cleaning$
--where OwnerAddress is null

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from dbo.Housing_data_cleaning$
where OwnerAddress is NOT null

ALTER TABLE dbo.Housing_data_cleaning$
ADD OwnerSplitAddress Nvarchar(255)

Update dbo.Housing_data_cleaning$
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE dbo.Housing_data_cleaning$
ADD OwnerSplitCity Nvarchar(255)

Update dbo.Housing_data_cleaning$
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE dbo.Housing_data_cleaning$
ADD OwnerSplitCountry Nvarchar(255)

Update dbo.Housing_data_cleaning$
set OwnerSplitCountry=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * from dbo.Housing_data_cleaning$


----------------------------------------------------------------------------------------------------------------------------------------

---Now from soldCount let's change y as Yes and n as No

Select distinct(SoldAsVacant) from dbo.Housing_data_cleaning$

Select SoldAsVacant,
CASE
	WHEN  SoldAsVacant='N' then 'No'
	WHEN  SoldAsVacant='Y' then 'Yes'
	ELSE SoldAsVacant
END	
from dbo.Housing_data_cleaning$

UPDATE dbo.Housing_data_cleaning$
SET SoldAsVacant= CASE
					WHEN  SoldAsVacant='N' then 'No'
					WHEN  SoldAsVacant='Y' then 'Yes'
					ELSE SoldAsVacant
					END	

Select distinct(SoldAsVacant) from dbo.Housing_data_cleaning$


------------------------------------------------------------------------------------------------------------------------------------------------------

----Let's Remove Duplicates
WITH ROWNUMCTE AS (
SELECT * ,
	ROW_NUMBER() OVER(
			PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY 
				UniqueID
				) row_num
from dbo.Housing_data_cleaning$
)



--DELETE from ROWNUMCTE
--WHERE row_num>1

---Hope there are no duplicates now
SELECT * from ROWNUMCTE
WHERE row_num>1


---------------------------------------------------------------------------------------------------------------------------------------------------
---As we have cleaned up some data and we have some unwanted coloumns let's delete those coloumns
ALTER TABLE dbo.Housing_data_cleaning$
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE dbo.Housing_data_cleaning$
DROP COLUMN SaleDate

Select * from dbo.Housing_data_cleaning$