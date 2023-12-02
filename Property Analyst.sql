SELECT *
FROM bms_db1.navfile;
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, DATE_FORMAT(SaleDate, '%Y-%m-%d') AS ConvertedSaleDate
FROM bms_db1.navfile;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From bms_db1.navfile
-- Where PropertyAddress is null
order by ParcelID;



SELECT 
    a.ParcelID, 
     --  COALESCE is wrking as a ISNULL
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM 
    bms_db1.navfile a
JOIN 
    bms_db1.navfile b 
ON 
    a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
WHERE 
    a.PropertyAddress IS NULL;    


UPDATE bms_db1.navfile a
JOIN bms_db1.navfile b ON a.ParcelID = b.ParcelID AND a.`UniqueID` <> b.`UniqueID`
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
From bms_db1.navfile
-- Where PropertyAddress is null
order by ParcelID;

-- here split the address

SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address1,
    SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 2) AS Address2
FROM
    bms_db1.navfile;


ALTER TABLE navfile
ADD COLUMN PropertySplitAddress NVARCHAR(255);

UPDATE navfile
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE navfile
ADD COLUMN PropertySplitCity Nvarchar(255);

UPDATE navfile
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);




SELECT *
From bms_db1.navfile;

Select OwnerAddress
From bms_db1.navfile;


SELECT 
  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1) AS Part3,
  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', -1) AS Part2,
  SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) AS Part1
FROM bms_db1.navfile;


ALTER TABLE navfile
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE navfile
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1);


ALTER TABLE navfile
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE navfile
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);



ALTER TABLE navfile
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE navfile
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)
WHERE UniqueID IS NOT NULL;


SELECT *
FROM bms_db1.navfile;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS CountSold
FROM bms_db1.navfile
GROUP BY SoldAsVacant
ORDER BY CountSold;


SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacantAlias
FROM bms_db1.navfile;


UPDATE navfile
SET SoldAsVacant = CASE
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM bms_db1.navfile
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



Select *
From bms_db1.navfile;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From bms_db1.navfile;


ALTER TABLE bms_db1.navfile
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;