/*
Nashville Housing data 2013-2016,, downloaded from kaggle and uploaded to github repo
https://github.com/Horanituze/PortfolioProjects/blob/main/Nashville_housing_data_2013_2016.csv

Cleaning Data in SQL Queries
*/

--Renamed the table as Nashville_housing

select *
from Nashville_housing

------------------------------------

--Populate Property Address Data following the idea that housings with the same ParcelID have the same property address

select *
from Nashville_housing
order by Parcel_ID
--where Property_Address is null

select a.Parcel_ID, 
    a.Property_Address, 
    b.Parcel_ID,
    b.Property_Address,
    ISNULL(a.Property_Address, b.Property_Address)
from Nashville_housing a
join  Nashville_housing b
on a.Parcel_ID = b.Parcel_ID
    and a.id <> b.Id
where a.Property_Address is null

UPDATE a
SET Property_Address = ISNULL(a.Property_Address, b.Property_Address)
from Nashville_housing a
join  Nashville_housing b
on a.Parcel_ID = b.Parcel_ID
    and a.id <> b.Id
where a.Property_Address is null

--------------------------------------------------

--Populate Property City Data following the idea that housings with the same ParcelID have the same property address and City

select a.Parcel_ID, 
    a.Property_Address, 
    a.Property_City,
    b.Parcel_ID,
    b.Property_Address,
    b.property_city,
    ISNULL(a.Property_City, b.Property_City)
from Nashville_housing a
join  Nashville_housing b
on a.Parcel_ID = b.Parcel_ID
    and a.id <> b.Id
where a.Property_city is null


UPDATE a
SET Property_City = ISNULL(a.Property_City, b.Property_City)
from Nashville_housing a
join  Nashville_housing b
on a.Parcel_ID = b.Parcel_ID
    and a.id <> b.Id
where a.Property_City is null


---------------------------------------

-- Rename columns for Owner Address, City and State

EXEC sp_rename 'Nashville_housing.address', 'Owner_Address', 'COLUMN'
EXEC sp_rename 'Nashville_housing.city', 'Owner_City', 'COLUMN'
EXEC sp_rename 'Nashville_housing.state', 'Owner_State', 'COLUMN'

select *
from Nashville_housing

-------------------------------------------------------------------

--Remove Duplicates

with Row_num as (
    select *,
        ROW_NUMBER() over (partition by parcel_id, 
                                    property_address,
                                    Sale_Price,
                                    sale_date, 
                                    legal_reference
                                    order by id) rn
    from  Nashville_housing
    
)

Delete from row_num
where rn >1


---------------------------------------

--Delete unused columns 

alter table Nashville_housing
drop column image

select * 
from Nashville_housing