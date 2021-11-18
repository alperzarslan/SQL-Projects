/*

Data cleaning in SQL for Nashville Housing

*/

--Checking on data:
select * from Housing.dbo.Nashvillehousing

--Individual checking on saledate coloumn:
select saledate from Housing.dbo.Nashvillehousing
-- 1 - Comment: date looks confusing, let's change its format for a shorter date

-- 1 - Standardizing date format --step by step apply
-- by USING update and set statements

select saledate, convert(date, saledate)
from Housing.dbo.Nashvillehousing

update nashvillehousing
set saledate = convert(date, saledate)

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = convert(date, saledate)

select * from Housing.dbo.Nashvillehousing


--Individual checking on propertyaddress coloumn:

select propertyaddress
from Housing.dbo.Nashvillehousing
where propertyaddress is null --we have null values with this
--2 - Comment: propertyaddress has null values. However, parcelid has propertyaddress info already, so we can use existing propertyid's addresses to bring propertyaddress to the null values 


-- 2 - We will not create a new table to make to join, use existing table to make the changes in it.
-- HOW TO MAKE CHANGES INSIDE OF THE TABLE with self-join
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress) as UpdatedPropertyaddress
from Housing.dbo.Nashvillehousing a
join Housing.dbo.Nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress) --or we could say in second variable in isnull like 'no address available' 
from Housing.dbo.Nashvillehousing a
join Housing.dbo.Nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

--Individual checking on propertyaddress coloumn:

select propertyaddress 
from Housing.dbo.Nashvillehousing
-- 3 - Comment: There is a delimiter that seperates the state from other address information like nashville, or madison

-- 3 - We will try to break out the address into individual column as state

select
SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)) as address 
--charindex(',', propertyaddress) will help us to search comma as ',' inside of the propertyaddress coloumn
from Housing.dbo.Nashvillehousing
--Comment 3.1: It still brings the comma so let's add -1 inside of charindex so comma will not be visible

--sub- solution to 3.1
select
SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1) as address 
,SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as state 
from Housing.dbo.Nashvillehousing

------------------------------------------------------------------
--SUBSTRING USAGE 
select
SUBSTRING(propertyaddress, 1, 3) as first_three_characters 
from Housing.dbo.Nashvillehousing

--SUBSTRING USAGE 
select
SUBSTRING(propertyaddress, 1, charindex(' ', propertyaddress)-1) as first_three_characters --from first character until the space but without the space (-1)
from Housing.dbo.Nashvillehousing

--charindex is to make a search in the given variable (coloumn)
--charindex (what you search, where you search, optional_starting from which charachter)

------------------------------------------------------------------

--So lets create two new coloumn to add our changes

alter table nashvillehousing
add PropertySplitAddress nvarchar(255); --in case of address may be large text, we added ncharvar(255)

update nashvillehousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1)


alter table nashvillehousing
add PropertySplitcity nvarchar(255);

update nashvillehousing
set PropertySplitcity = SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress))


select * 
from Housing.dbo.Nashvillehousing


----------------------------------
--Individual checking on owneraddress coloumn:
select owneraddress
from Housing.dbo.Nashvillehousing

--Let's break it down as well
--by using PARSENAME --it simply work backgworks as it is taking values in between '.' dots. If you dont have dots in your column, you can replace commas with dots via replace funtion then run it

select
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from Housing.dbo.Nashvillehousing

--SO lets implement it into new columns:

--1
alter table nashvillehousing
add Ownersplitaddress nvarchar(255); --in case of address may be large text, we added ncharvar(255)

update nashvillehousing
set Ownersplitaddress = PARSENAME(replace(owneraddress,',','.'),3)

--2
alter table nashvillehousing
add Ownersplitcity nvarchar(255); --in case of address may be large text, we added ncharvar(255)

update nashvillehousing
set Ownersplitcity = PARSENAME(replace(owneraddress,',','.'),2)

--3
alter table nashvillehousing
add Ownersplitstate nvarchar(255); --in case of address may be large text, we added ncharvar(255)

update nashvillehousing
set Ownersplitstate = PARSENAME(replace(owneraddress,',','.'),1)

--lets check now 

select *
from Housing.dbo.Nashvillehousing

-----------------------------------------

--Individual checking on Soldasvacant coloumn:
--but unique ones

select distinct(soldasvacant)
from Housing.dbo.Nashvillehousing
--Problem: it has both Yes, Y and N, No lets choose one and convert the rest for that

--Lets see further how many of those we have
select distinct(soldasvacant), count(soldasvacant) as how_many-- aggregate function, so we should have groupby clause
from Housing.dbo.Nashvillehousing
group by soldasvacant
order by 2
--So we should convert them into Yes and No instead of Y and N

--CASE STATEMENT AND CHANGING stuff then applying again
select soldasvacant
,CASE	when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant --if they are not mentioned as above show as itself
		END
from Housing.dbo.Nashvillehousing
--We enter it to below statement and run it one by one
----------------
--we do not need to use alter table, bec we will do the changes directly in the data

update nashvillehousing
set soldasvacant = CASE	when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant --if they are not mentioned as above show as itself
		END

-- Removing duplicates

--to see if there are any duplicates

select *,
		ROW_NUMBER() over 
		(
		partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
		) row_num

from Housing.dbo.Nashvillehousing

--what we said here is to create a new coloumn as row_num, which says how many rows that has ParcelID, PropertyAddress,SalePrice, LegalReference are same! in this row number, 
--if it is one then it is unique, if not then it is a duplicate
-- comment: we saw some 2 but we dont now how many
-- So, lets use CTE function to see initially:
-- CTE is like a temprorary table to use for us

WITH RowNumCTE AS
		(	
		select *,
		ROW_NUMBER() over 
			(
		partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
			) row_num
from Housing.dbo.Nashvillehousing
		)
-- now lets see the ones that are more than 1, which means they are the duplicates__ via RowNumCTE which is a CTE function that we created

select *
from RowNumCTE
--where RowNumCTE > 1
--order by ParcelID

--it worked now under RowNumCTE, so lets go ahead to make the search

WITH RowNumCTE AS
		(	
		select *,
		ROW_NUMBER() over 
			(
		partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
			) row_num
from Housing.dbo.Nashvillehousing
		)

select *
from RowNumCTE
-- now lets see the ones that are more than 1, which means they are the duplicates__ via RowNumCTE which is a CTE function that we created
-- HERE ARE THE DUPLICATES:

WITH RowNumCTE AS
		(	
		select *,
		ROW_NUMBER() over 
			(
		partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
			) row_num
from Housing.dbo.Nashvillehousing
		)

select *
from RowNumCTE
where row_num > 1 -- here 
order by ParcelID --added bec of above

-- in the same way, we can use CTE to delete the duplicates


WITH RowNumCTE AS
		(	
		select *,
		ROW_NUMBER() over 
			(
		partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
			) row_num
from Housing.dbo.Nashvillehousing
		)

DELETE
from RowNumCTE
where row_num > 1 

--104 rows deleted

-- LETS DELETE SOME COLOUMNS

select * 
from Housing.dbo.Nashvillehousing

ALTER TABLE Housing.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress --3 deleted
