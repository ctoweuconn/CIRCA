/************************************/
* This file aims to make a row of data for each 
* ImportParcelID in each year so an appropriate
* merge with the transaction data can occur later on.
*
*
/************************************/
clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global zdta "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"

* which code variables from Ztrax to keep
global code "StoryTypeStndCode TimeshareStndCode SewerStndCode WaterStndCode ElevatorStndCode FoundationTypeStndCode AirConditioningStndCode HeatingTypeorSystemStndCode RoofStructureTypeStndCode RoofCoverStndCode BathSourceStndCode ArchitecturalStyleStndCode BuildingConditionStndCode BuildingQualityStndCode BuildingClassStndCode PropertyLandUseStndCode PropertyCountyLandUseCode OccupancyStatusStndCode"
* which continuous variables to keep
global vars "TotalRooms TotalBedrooms TotalCalculatedBathCount NoOfStories YearBuilt FireplaceNumber GarageAreaSqFt GarageNoOfCars NoOfBuildings LotSizeSquareFeet"


****************************************************************************************************
* current assessement value processing
****************************************************************************************************
*Get sales data and property data and work with them in your directory
use "$zdta\current_assess_sale_09.dta",clear 
* in this file the RowID is not unique and shows two sales for some parcels 
save "$dta\current_assess_sale_ct.dta",replace


use "$zdta\current_assess_value_09.dta",clear
save "$dta\current_assess_value_ct.dta",replace

*merge
use "$zdta\current_assess_09.dta",clear

merge m:1 RowID using"$dta\current_assess_value_ct.dta"
capture drop _merge

* restrict to our target towns and munis 
replace LegalTownship = strtrim(LegalTownship)
keep if LegalTownship=="BRANFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="CLINTON"|LegalTownship=="DARIEN"| ///
LegalTownship=="EAST HAVEN"|LegalTownship=="EAST LYME"|LegalTownship=="FAIRFIELD"|LegalTownship=="GREENWICH"| ///
LegalTownship=="GROTON"|LegalTownship=="GUILFORD"|LegalTownship=="MADISON"|LegalTownship=="MILFORD"|LegalTownship=="NEW HAVEN" ///
|LegalTownship=="NEW LONDON"|LegalTownship=="NORWALK"|LegalTownship=="OLD LYME"|LegalTownship=="OLD SAYBROOK"|LegalTownship=="STAMFORD" ///
|LegalTownship=="STONINGTON"|LegalTownship=="STRATFORD"|LegalTownship=="WATERFORD"|LegalTownship=="WEST HAVEN"|LegalTownship=="WESTBROOK" ///
|LegalTownship=="WESTPORT"

save "$dta\current_assess.dta",replace

****************************************************************************************************
* end current assessement value processing
****************************************************************************************************



****************************************************************************************************
* property attribute processing (some GIS some ZTRAX)
****************************************************************************************************

merge 1:1 RowID using  "$zdta\current_assess_lotappeal_09.dta",
drop if _merge==2
drop _merge

merge 1:1 RowID using  "$zdta\current_assess_pool_09.dta",
drop if _merge==2
drop _merge

merge 1:1 RowID using  "$zdta\current_assess_garage_09.dta",
drop if _merge==2
drop _merge

merge 1:1 RowID using "$zdta\current_assess_building_09.dta",
drop if _merge==2
drop _merge

merge 1:m RowID using "$zdta\current_assess_buildingarea_09.dta",
drop if _merge==2
drop _merge

save "$dta\current_assess_all.dta",replace
use "$dta\current_assess_all.dta",replace


use "$zdta\current_assess_lotappeal_09.dta",clear
keep RowID LotSiteAppealStndCode FIPS BatchID
gen Waterfront=(LotSiteAppealStndCode=="WFS")  /* how to aggregate this to the ImportParcelID is a question*/
duplicates drop
duplicates report RowID
save "$dta\current_assess_ct_waterfront.dta",replace

use "$zdta\current_assess_pool_09.dta",clear
keep RowID PoolStndCode FIPS BatchID
gen Pool=1    /* how to aggregate this to the ImportParcelID is a question but one can add and remove pools so not so sure*/
duplicates drop
duplicates report RowID
save "$zdta\current_assess_ct_pool.dta",replace

use "$zdta\current_assess_garage_09.dta",clear
keep RowID GarageNoOfCars GarageStndCode FIPS BatchID
duplicates drop
duplicates report RowID
save "$dta\current_assess_ct_garage.dta",replace
