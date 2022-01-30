/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


  /*
Cleaning Data in SQL Queries
*/
Select *
From PortfolioProject.dbo.NashvilleHousing


--CHANGE THE FORMAT OF SALEDATE COLLUMN
--------------------------------------------------------------------------------------------------------------------------
-- In the saleDate collumn => 2015-01-14 00:00:00.000
--There is :00:00 at the end, doesnt look goo
Select saleDate
From PortfolioProject.dbo.NashvilleHousing
--How to standardize Date Format and get it back to " 2015-01-14"
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) -->This doesnt work

--Try another method If it doesn't Update properly

ALTER TABLE NashvilleHousing -->Add a collumn SaleDateConverted
Add SaleDateConverted Date;

Update NashvilleHousing --> Set the collumn with converted saleDate
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted  --> Now the collumn is updated
From PortfolioProject.dbo.NashvilleHousing


-- POPULATE THE PROPERTYADDRESS COLLUMN DATA
--------------------------------------------------------------------------------------------------------------------------
--There are some missing value (Null) in PropertyAddress collumn
Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

-- Look like The ParcelID is matching with the PropertyAddress
--So we gonna utilize ParcelID collumn to fill the PropertyAddress
--Because each transaction will have the unique ID, we dont want those same transactions 
--Therefore we must add the condition where the unique IDs must be different

Select a.UniqueID, b.UniqueID, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- ISNULL(a.PropertyAddress, b.PropertyAddress) meaning: if a.PropertyAddress is null, 
--result in b.PropertyAddress values
--Next step is to update table "a" with b.PropertyAddress values

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--  BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--------------------------------------------------------------------------------------------------------------------------

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--Split the address using these 2 operation
--SUBSTRING(string, start, length): Get the substring based on the starting point and endpoint
--CHARINDEX(substring, string, start): return the index of certain substring
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

--Create a new collumn name PropertySplitAddress 
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--Fill the new collumn with the address part of the splitted PropertyAddress
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--Create a new collumn name PropertySplitCity
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
--Fill the new collumn with the city part of the splitted PropertyAddress
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Now view the result
Select *
From PortfolioProject.dbo.NashvilleHousing




--Check the collumn OwnerAddress
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--Use the Parsename function to split the OwnerAddress into specified parts
--REPLACE(string, old_string, new_string)
--PARSENAME ('object_name' , object_piece )--Returns the specified parts of an object name separated by the "."

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing



-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
--------------------------------------------------------------------------------------------------------------------------

Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2
--> There are some cell with Y (meaning YES) and N (meaning NO), we want to replace these Y/N with YES/NO

--To change Y/N with YES/NO we will use CASE statement (kind of control flow statements (something like IF ELSE)).
--CASE Input_Expression
     --WHEN test_expression THEN result_expression
     --.........
     --ELSE default_expression
--END

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- REMOVE DUPLICATES
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Using a Common Table Expressions (CTE) which is a temporary named result set that we can reference within 
--a SELECT, INSERT, UPDATE or DELETE.
--In this case, within the CTE, we use PARTITION BY 
--(similar idea as group by but with full rows result) to partition the data on 
--ParcelID, PropertyAddress, salesprice, salesdate, legalRefern to see if any Rows are duplicated. 
--Using ROW_NUMBER() function to mark the Row No. and finally Output only rows with row no. >1
--Because these are the duplicate values


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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress,row_num --=> result in the duplicated rows

--After we identified the duplicated rows, we can use this DELETE ROW FUNCTIONS
--DELETE
--From RowNumCTE
--Where row_num > 1



---------------------------------------------------------------------------------------------------------

-- DELETE UNSUED COLUMNS 

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO














