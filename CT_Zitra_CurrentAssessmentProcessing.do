clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global zdta "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"


global code "StoryTypeStndCode TimeshareStndCode SewerStndCode WaterStndCode ElevatorStndCode FoundationTypeStndCode AirConditioningStndCode HeatingTypeorSystemStndCode RoofStructureTypeStndCode RoofCoverStndCode BathSourceStndCode ArchitecturalStyleStndCode BuildingConditionStndCode BuildingQualityStndCode BuildingClassStndCode PropertyLandUseStndCode PropertyCountyLandUseCode OccupancyStatusStndCode"
global vars "TotalRooms TotalBedrooms TotalCalculatedBathCount NoOfStories YearBuilt FireplaceNumber GarageAreaSqFt GarageNoOfCars NoOfBuildings LotSizeSquareFeet"


****************************************************************************************************
* current assessement value processing
****************************************************************************************************
*Get sales data and property data
use "$zdta\current_assess_sale_09.dta",clear 
*drop SalesPriceAmountStndCode SellerFullName BuyerFullName DocumentDate RecordingDocumentNumber
* in this file the RowID is not unique and shows two sales for some parcels 
save "$dta\current_assess_sale_ct.dta",replace


use "$zdta\current_assess_value_09.dta",clear
*keep RowID ImprovementAssessedValue LandAssessedValue TotalAssessedValue AssessmentYear
save "$dta\current_assess_value_ct.dta",replace

*merge
use "$zdta\current_assess_09.dta",clear

*merge 1:m RowID using"$dta\current_assess_sale_ct.dta"  /*get from transaction files*/
*capture drop _merge
merge m:1 RowID using"$dta\current_assess_value_ct.dta"
capture drop _merge


* a better way   
replace LegalTownship = strtrim(LegalTownship)
keep if LegalTownship=="BRANFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="CLINTON"|LegalTownship=="DARIEN"| ///
LegalTownship=="EAST HAVEN"|LegalTownship=="EAST LYME"|LegalTownship=="FAIRFIELD"|LegalTownship=="GREENWICH"| ///
LegalTownship=="GROTON"|LegalTownship=="GUILFORD"|LegalTownship=="MADISON"|LegalTownship=="MILFORD"|LegalTownship=="NEW HAVEN" ///
|LegalTownship=="NEW LONDON"|LegalTownship=="NORWALK"|LegalTownship=="OLD LYME"|LegalTownship=="OLD SAYBROOK"|LegalTownship=="STAMFORD" ///
|LegalTownship=="STONINGTON"|LegalTownship=="STRATFORD"|LegalTownship=="WATERFORD"|LegalTownship=="WEST HAVEN"|LegalTownship=="WESTBROOK" ///
|LegalTownship=="WESTPORT"

save "$dta\current_assess.dta",replace

*** This step was not saved*** so the geo fix is not in.
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

/*** move this sqft processing to after putting the historic assessment together with this file
sort RowID BuildingAreaSequenceNumber
ren BuildingAreaSqFt SQFT
/*BuildingAre |
  aStndCode |      Freq.     Percent        Cum.
------------+-----------------------------------
        ATC |    132,899        3.83        3.83
        BAG |    965,365       27.84       31.67
        BAL |  1,098,437       31.67       63.34
        BAT |     60,000        1.73       65.07
        BSH |     12,178        0.35       65.42
        BSU |    306,407        8.84       74.26
        BSY |    507,843       14.64       88.90
        GMR |     55,785        1.61       90.51
        ST1 |    329,167        9.49      100.00
------------+-----------------------------------
/
keep if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"|BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"| ///
BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"|BuildingAreaStndCode=="BAT"|BuildingAreaStndCode=="BAG"|BuildingAreaStndCode=="BAL" ///
|BuildingAreaStndCode=="ST1"
** dropping game room GMR and attics ATC from the square foot    * restriction **


* I would not replace a variable  that exists in Zillow's data, create a new variable so we can be clear 
* which are original and which we created
replace BuildingAreaStndCode="BASE" if BuildingAreaStndCode=="BSF"|BuildingAreaStndCode=="BSH"| ///
BuildingAreaStndCode=="BSN"|BuildingAreaStndCode=="BSP"|BuildingAreaStndCode=="BSU"|BuildingAreaStndCode=="BSY"

drop BuildingOrImprovementNumber BuildingAreaSequenceNumber FIPS BatchID
drop if SQFT==.  /* restriction - careful there may be sqft available somewhere else, none are missing anyway*/
duplicates drop /*restriction but not doing anything bad */
duplicates tag RowID BuildingAreaStndCode, g(dup1)
egen SQFT1=sum(SQFT) if dup1==1,by(RowID BuildingAreaStndCode)
replace SQFT=SQFT1 if SQFT1~=.
drop dup1 SQFT1
duplicates drop
reshape wide SQFT, i(RowID) j(BuildingAreaStndCode) string
duplicates report RowID
drop SQFTST1 SQFTBAT
save "$dta\current_assess_ct_buildingarea.dta",replace
*/


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
