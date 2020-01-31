clear all
set more off
cap log close
*Change directories here
global zroot ""
global root ""
global dta "$root\dta\"
global results "$root\results"
global zdta "$zroot\dta"

global gis ""

*****************************************************************************************************
* Begin standard attribute processing (various attributes from zillow hist or current assess)       *
*****************************************************************************************************
*Get current sales data
use "$Zitrax\dta\current_assess_sale_09.dta",clear
drop SalesPriceAmountStndCode SellerFullName BuyerFullName DocumentDate ///
 RecordingDocumentNumber
* in this file the RowID is not unique and shows two sales for some parcels 
save "$dta0\current_assess_sale_ct.dta",replace

*current assess value data
use "$Zitrax\dta\current_assess_value_09.dta",clear
keep RowID ImprovementAssessedValue LandAssessedValue TotalAssessedValue AssessmentYear
save "$dta0\current_assess_value_ct.dta",replace

use "$Zitrax\dta\current_assess_building_09.dta",clear
keep RowID NoOfUnits PropertyCountyLandUseDescription PropertyCountyLandUseCode BuildingOrImprovementNumber BuildingConditionStndCode ///
YearBuilt EffectiveYearBuilt NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount HeatingTypeorSystemStndCode AirConditioningStndCode FireplaceNumber ///
RoofStructureTypeStndCode FoundationTypeStndCode FIPS
save "$dta0\current_assess_ct_building.dta",replace

*hist assess value data
use "$Zitrax\dta\historic_assess_value_09.dta",clear
keep RowID ImprovementAssessedValue LandAssessedValue TotalAssessedValue AssessmentYear
save "$dta0\historic_assess_value_ct.dta",replace

use "$Zitrax\dta\historic_assess_building_09.dta",clear
keep RowID NoOfUnits PropertyCountyLandUseDescription PropertyCountyLandUseCode BuildingOrImprovementNumber BuildingConditionStndCode ///
YearBuilt EffectiveYearBuilt NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount HeatingTypeorSystemStndCode AirConditioningStndCode FireplaceNumber ///
RoofStructureTypeStndCode FoundationTypeStndCode FIPS
destring PropertyCountyLandUseCode,replace
save "$dta0\historic_assess_ct_building.dta",replace

use "$Zitrax\dta\current_assess_buildingarea_09.dta",clear
sort RowID BuildingAreaSequenceNumber
ren BuildingAreaSqFt SQFT
keep if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"|BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"|BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"|BuildingAreaStndCode=="BAT"|BuildingAreaStndCode=="BAG"|BuildingAreaStndCode=="BAL"|BuildingAreaStndCode=="ST1"
replace BuildingAreaStndCode="BASE" if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"|BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"|BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"
drop BuildingOrImprovementNumber BuildingAreaSequenceNumber FIPS BatchID

duplicates drop
duplicates tag RowID BuildingAreaStndCode, g(dup1)
egen SQFT1=sum(SQFT) if dup1==1,by(RowID BuildingAreaStndCode)
replace SQFT=SQFT1 if SQFT1~=.
drop dup1 SQFT1
duplicates drop
reshape wide SQFT, i(RowID) j(BuildingAreaStndCode) string
duplicates report RowID
drop SQFTST1 SQFTBAT
save "$dta0\current_assess_ct_buildingarea.dta",replace

use "$Zitrax\dta\historic_assess_buildingarea_09.dta",clear
sort RowID BuildingAreaSequenceNumber
ren BuildingAreaSqFt SQFT
keep if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"|BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"|BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"|BuildingAreaStndCode=="BAT"|BuildingAreaStndCode=="BAG"|BuildingAreaStndCode=="BAL"|BuildingAreaStndCode=="ST1"
replace BuildingAreaStndCode="BASE" if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"|BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"|BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"
drop BuildingOrImprovementNumber BuildingAreaSequenceNumber FIPS BatchID

duplicates drop
duplicates tag RowID BuildingAreaStndCode, g(dup1)
egen SQFT1=sum(SQFT) if dup1==1,by(RowID BuildingAreaStndCode)
replace SQFT=SQFT1 if SQFT1~=.
drop dup1 SQFT1
duplicates drop
reshape wide SQFT, i(RowID) j(BuildingAreaStndCode) string
duplicates report RowID
drop SQFTST1 SQFTBAT
save "$dta0\historic_assess_ct_buildingarea.dta",replace

use "$Zitrax\dta\current_assess_lotappeal_09.dta",clear
keep RowID LotSiteAppealStndCode FIPS BatchID
gen Waterfront=(LotSiteAppealStndCode=="WFS")
duplicates drop
duplicates report RowID
save "$dta0\current_assess_ct_waterfront.dta",replace

use "$Zitrax\dta\current_assess_pool_09.dta",clear
keep RowID PoolStndCode FIPS BatchID
gen Pool=1
duplicates drop
duplicates report RowID
save "$dta0\current_assess_ct_pool.dta",replace

use "$Zitrax\dta\current_assess_garage_09.dta",clear
keep RowID GarageNoOfCars GarageStndCode FIPS BatchID
duplicates drop
duplicates report RowID
save "$dta0\current_assess_ct_garage.dta",replace

use "$Zitrax\dta\historic_assess_garage_09.dta",clear
keep RowID GarageNoOfCars GarageStndCode FIPS BatchID
duplicates drop
duplicates report RowID
save "$dta0\historic_assess_ct_garage.dta",replace
***************************************
* End property attributes processing  *
***************************************



