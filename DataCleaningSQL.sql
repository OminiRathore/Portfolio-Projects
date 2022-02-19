Select * from PortfolioProject..HousingData

--Satndardize Date Format

Select SaleDate2, CONVERT(Date, SAleDate) from PortfolioProject..HousingData


Alter table HousingData
Add SaleDate2 Date;
Update HousingData
Set SaleDate2 = CONVERT(Date, SAleDate)

--Handling Null Property Address


Select * from PortfolioProject..HousingData 
where PropertyAddress is null


Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
Set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Splitting Property Address into Address and City

Select PropertyAddress from PortfolioProject..HousingData

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..HousingData

ALter table HousingData
Add PropertyLocation varchar(255),
City varchar(255)


Update HousingData
Set PropertyLocation = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Update HousingData
Set City = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Select PropertyLocation, City
from PortfolioProject..HousingData

--Splitting Owner Address into Address, City and State

Select OwnerAddress from PortfolioProject..HousingData

Select PARSENAME(replace(OwnerAddress,',', '.'), 3) as Address,
PARSENAME(replace(OwnerAddress,',', '.'), 2) as Address,
PARSENAME(replace(OwnerAddress,',', '.'), 1) as Address
from PortfolioProject..HousingData

ALter table PortfolioProject..HousingData
Add OwnerLocation varchar(255),
OwnerCity varchar(255),
OwnerState varchar(255)


Update PortfolioProject..HousingData
Set OwnerLocation = PARSENAME(replace(OwnerAddress,',', '.'), 3)


Update PortfolioProject..HousingData
Set OwnerCity = PARSENAME(replace(OwnerAddress,',', '.'), 2)


Update PortfolioProject..HousingData
Set OwnerState = PARSENAME(replace(OwnerAddress,',', '.'), 1)

Select * from PortfolioProject..HousingData

--Change Y and N to Yes and No for 'SoldAsVaccant' field

Select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortfolioProject..HousingData
group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'N' then 'No'
     when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
	 End
as Modified
from PortfolioProject..HousingData
--where SoldAsVacant in ('Y','N')


Update PortfolioProject..HousingData
Set SoldAsVacant = Case when SoldAsVacant = 'N' then 'No'
     when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
	 End

--Removing Duplicates
With CTE_Duplicates as 
(
Select *, Row_number() over
                      ( Partition by ParcelId,
					                 PropertyAddress,
					                 SaleDate,
									 SalePrice,
									 LegalReference
						Order by ParcelID
                       ) as RowNum
from PortfolioProject..HousingData
)
--Delete from CTE_Duplicates
--where RowNum > 1
Select * from CTE_Duplicates
where RowNum > 1


--Removing Unused columns


Alter table PortfolioProject..HousingData
Drop Column SaleDate, PropertyAddress, OwnerAddress


Select * from PortfolioProject..HousingData



