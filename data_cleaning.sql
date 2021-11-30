CREATE TABLE nv_housing(
UniqueID INT, ParcelID VARCHAR(100),
LandUse VARCHAR(100),PropertyAddress VARCHAR(100),
SaleDate TIMESTAMP,SalePrice INT,
LegalReference VARCHAR(100),SoldAsVacant VARCHAR(10),
OwnerName VARCHAR(100),
OwnerAddress VARCHAR(100),
Acreage FLOAT,TaxDistrict VARCHAR(100),
LandValue INT,BuildingValue INT,
TotalValue INT,YearBuilt VARCHAR(20),
Bedrooms VARCHAR(20),FullBath VARCHAR(20),HalfBath VARCHAR(20)
);

ALTER TABLE nv_housing
ADD COLUMN convertedsaledate DATE;

UPDATE nv_housing
SET saledateconverted = saledate:: DATE;

SELECT * 
FROM nv_housing
WHERE propertyaddress is null


SELECT a.parcelid,a.propertyaddress,
		b.parcelid, b.propertyaddress
FROM nv_housing a
JOIN nv_housing b 
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null

UPDATE nv_housing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nv_housing a
JOIN nv_housing b 
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a = nv_housing

SELECT
SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',')-1) as Address
FROM nv_housing

SELECT propertyaddress,
SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',')-1) as Address
,SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',')+2, LENGTH(propertyaddress)) as Address1
FROM nv_housing

ALTER TABLE nv_housing
ADD COLUMN pro_address VARCHAR(100);

ALTER TABLE nv_housing
ADD COLUMN pro_city VARCHAR(100);

UPDATE nv_housing
SET pro_address = SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',')-1);

UPDATE nv_housing
SET pro_city = SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',')+2, LENGTH(propertyaddress))

ALTER TABLE nv_housing
ADD COLUMN owner_address VARCHAR(100),
ADD COLUMN owner_city VARCHAR(100),
ADD COLUMN owner_state VARCHAR(100);

UPDATE nv_housing
SET  owner_address = SPLIT_PART(owneraddress,',', 1),
	 owner_city =    TRIM(SPLIT_PART(owneraddress,',', 2)),
	 owner_state =	TRIM(SPLIT_PART(owneraddress,',', 3));


SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nv_housing
GROUP BY 1
ORDER BY 2

SELECT soldasvacant,
		CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			 WHEN soldasvacant = 'N' THEN  'No'
			 ELSE soldasvacant
			 END
FROM nv_housing



UPDATE nv_housing
SET  soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
			 WHEN soldasvacant = 'N' THEN  'No'
			 ELSE soldasvacant
			 END


WITH CTE AS (
	SELECT *,
	  	 	ROW_NUMBER() OVER(
	   		PARTITION BY parcelid,
	   				propertyaddress,
	   				saleprice,
	   				saledate,
	   				legalreference
	   				ORDER BY 
	   				uniqueid) row_num
	FROM nv_housing)
SELECT * row_num
FROM CTE
WHERE row_num > 1 


DELETE FROM 
	nv_housing a
		USING nv_housing b
			WHERE a.uniqueid > b.uniqueid
				AND a.parcelid = b.parcelid
				AND a.propertyaddress = b.propertyaddress
	   				  AND a.saleprice = b.saleprice
	   				AND a.saledate = b.saledate
	   				AND a.legalreference = b.legalreference



ALTER TABLE nv_housing
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress,
DROP COLUMN saledate;