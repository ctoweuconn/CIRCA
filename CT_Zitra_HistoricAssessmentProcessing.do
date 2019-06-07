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
****************************************************************************************************
* begin historic assessement processing
****************************************************************************************************
*Historical assessment
use "$zdta\historic_assess_09.dta",clear
tab TaxYear
keep if TaxYear>=2005   /*restriction*/

keep RowID ImportParcelID FIPS State County ExtractDate AssessorParcelNumber UnformattedAssessorParcelNumber ///
PropertyFullStreetAddress PropertyCity PropertyZip PropertyZoningDescription TaxIDNumber TaxAmount TaxYear ///
NoOfBuildings LegalTownship LotSizeAcres LotSizeSquareFeet PropertyAddressLatitude PropertyAddressLongitude BatchID
merge 1:1 RowID using "$zdta\historic_assess_value_09.dta"
tab AssessmentYear if _merge==2   /* these are primarily pre 2005 */
drop if _merge!=3
drop _merge


* an example of a bad Batch for pulling AssessmentYr 336905

* focus on our towns   
replace LegalTownship = strtrim(LegalTownship)
keep if LegalTownship=="BRANFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="CLINTON"|LegalTownship=="DARIEN"| ///
LegalTownship=="EAST HAVEN"|LegalTownship=="EAST LYME"|LegalTownship=="FAIRFIELD"|LegalTownship=="GREENWICH"| ///
LegalTownship=="GROTON"|LegalTownship=="GUILFORD"|LegalTownship=="MADISON"|LegalTownship=="MILFORD"|LegalTownship=="NEW HAVEN" ///
|LegalTownship=="NEW LONDON"|LegalTownship=="NORWALK"|LegalTownship=="OLD LYME"|LegalTownship=="OLD SAYBROOK"|LegalTownship=="STAMFORD" ///
|LegalTownship=="STONINGTON"|LegalTownship=="STRATFORD"|LegalTownship=="WATERFORD"|LegalTownship=="WEST HAVEN"|LegalTownship=="WESTBROOK" ///
|LegalTownship=="WESTPORT"


merge 1:1 RowID using"$zdta\historic_assess_building_09.dta",keepusing(NoOfUnits PropertyCountyLandUseDescription PropertyCountyLandUseCode ///
BuildingOrImprovementNumber BuildingConditionStndCode YearBuilt NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount HeatingTypeorSystemStndCode ///
AirConditioningStndCode FireplaceNumber  *Stnd* )   /* CT -added keeping the codes*/
drop if _merge==2
drop _merge

merge 1:1 RowID using"$zdta\historic_assess_Garage_09.dta",keepusing(GarageAreaSqFt GarageNoOfCars)
drop if _merge==2
drop _merge
*replace GarageNoOfCars=0 if GarageNoOfCars==.   /*CT Note:can't do this else places like Branford, Old Saybrook, Old Lyme are marked as no homes with garages*/
*replace FireplaceNumber=0 if FireplaceNumber==.  /*CT Note:can't do this else places like Madison, Milford, New Haven are marked as no homes with fireplaces*/

* I know this is useless but it is left in for now
merge 1:1 RowID using"$zdta\historic_assess_lotappeal_09.dta"
drop if _merge==2
drop _merge

merge 1:m RowID using "$zdta\historic_assess_buildingarea_09.dta",

* keepusing(SQFTBAG SQFTBAL SQFTBASE)  /*BAG -gross bldg area, BAL - living bldg area*/ 
* BASE must be base sqft but I don't find it in the codebook
drop if _merge==2
drop _merge

destring(PropertyZip), replace
destring(PropertyCountyLandUseCode), replace
destring( BuildingClassStndCode), replace
destring(  BuildingQualityStndCode ), replace
destring(  TimeshareStndCode  ), replace

** get the corrected ImportParcelID from CT_Zitra_HistoricAssessmentIDFix.do
rename ImportParcelID ha_ImportParcelID
merge m:m ha_ImportParcelID using "$dta\ha_to_curr_idkey.dta", 
keep if _merge==3
drop _merge

* and append with the current assessment data produced in CT_Zitra_CurrentAssessmentProcessing.do
append using "$dta\current_assess_all.dta"

** the building areas are many per ImportParcelID
/*      'BAL',  # Building Area Living
        'BAF',  # Building Area Finished
        'BAE',  # Effective Building Area
        'BAG',  # Gross Building Area
        'BAJ',  # Building Area Adjusted
        'BAT',  # Building Area Total
        'BLF'), # Building Area Finished Living
*/
save "$dta\preprocessed.dta", replace
use "$dta\preprocessed.dta", replace


keep if BuildingAreaStndCode == "BAL" | ///
			BuildingAreaStndCode == "BAG" | ///
			TaxYear<=2007
gen _SQFTBAL = BuildingAreaSqFt if BuildingAreaStndCode=="BAL" 
gen _SQFTBAG = BuildingAreaSqFt if BuildingAreaStndCode=="BAG"
egen SQFTBAL = mean(_SQFTBAL),  by(ImportParcelID TaxYear)
egen SQFTBAG = mean(_SQFTBAG),  by(ImportParcelID TaxYear)

* CT - this inparticular should not be done as there are often other year's data is populated
*replace SQFTBAG=SQFTBAL*NoOfStories if SQFTBAG==.  /*CT Note: I think this will grossly inflate the sqft because BAL is already on all floors */
* not sure how we are going to use these so will not fix changed parcels now
*   BuildingAreaSequenceNumber BuildingOrImprovementNumber
rename PropertyCountyLandUseDescription PropertyCountyLandUseDesc /*name too long*/
* work with the variables we care about to fill in the empty slots in the assessment record
global code " LotSiteAppealStndCode StoryTypeStndCode SewerStndCode WaterStndCode ElevatorStndCode FoundationTypeStndCode AirConditioningStndCode HeatingTypeorSystemStndCode RoofStructureTypeStndCode RoofCoverStndCode BathSourceStndCode ArchitecturalStyleStndCode BuildingConditionStndCode   PropertyCountyLandUseDesc PropertyLandUseStndCode OccupancyStatusStndCode"
global vars "SQFTBAL SQFTBAG PropertyCountyLandUseCode BuildingClassStndCode  TotalRooms TotalBedrooms TotalCalculatedBathCount NoOfStories YearBuilt FireplaceNumber GarageAreaSqFt GarageNoOfCars NoOfBuildings LotSizeSquareFeet"

**********************************************************************************************
**********************************************************************************************
* now sqft is estimated on one row
duplicates drop ImportParcelID TaxYear $code $vars, force
drop BuildingArea* /*these are not specific to ImportParcel so purge them to prevent confusion*/
replace PropertyCountyLandUseDesc = trim(PropertyCountyLandUseDesc)
keep if PropertyCountyLandUseDesc =="1-FAMILY RESIDENCE" | ///
		 PropertyCountyLandUseDesc =="SINGLE FAMILY RESIDENCE" | ///	
		 PropertyCountyLandUseDesc =="SINGLE FAMILY RESIDENTIAL" | ///
		 PropertyCountyLandUseDesc =="1-FAM RES" 
**********************************************************************************************
**********************************************************************************************
foreach v of varlist $vars { 

	display " working on `v' now"
	egen mins = min(`v'), by(ImportParcelID)
	egen maxs = max(`v'), by(ImportParcelID)
	egen means = mean(`v'), by(ImportParcelID)
	
	gen e_`v'=`v'
	replace e_`v' = means if maxs==means & mins == means & `v'==.
	drop mins maxs means
}
drop Fire*Code
foreach v of varlist $code { 

	display " working on `v' now"
	
	gen e_`v'=`v'
}

keep ImportParcelID e_* $vars TaxYear Assess* *Code $code LegalTownship


* first fill in any missing years 
gen e_Year = TaxYear
sort ImportParcelID TaxYear
* mark missing year from the bottom
gen markForAdd = 1 if ImportParcelID==ImportParcelID[_n+1] & e_Year < e_Year[_n+1]-1  
mvencode markForAdd, mv(0) override

gen numToAdd =  e_Year[_n+1]-e_Year if ImportParcelID==ImportParcelID[_n+1] & markForAdd==1
expand numToAdd if markForAdd ==1
sort ImportParcelID TaxYear
save $dta\t, replace
keep if markForAdd==0
save $dta\mfa.dta, replace
use $dta\t, replace
keep if markForAdd==1
sort ImportParcelID TaxYear
save $dta\mfa1.dta , replace
* has to be done over a loop from 1/12 based on the data (this would be variable)
foreach n of numlist 2/12{
	use $dta\mfa1.dta, replace
	keep if numToAdd==`n'
	local toAdd = `n'+1
	sort ImportParcelID TaxYear
	egen ctr = fill(1/`toAdd' 1/`toAdd')
	sort ImportParcelID TaxYear
	
	foreach i of numlist 1/`n'{
		local ip = `i'+1
		replace e_Year = e_Year+`i' if ctr==`ip'
	}
	
	save "$dta\mfa1_`n'.dta", replace
	
}
use "$dta\mfa1_2.dta", replace
foreach n of numlist 3/12{
	append using  "$dta\mfa1_`n'.dta",
}
append using $dta\mfa.dta


* populate past years where data are missing do 2015 first from 2014 data
sort ImportParcelID TaxYear
* there may be duplicate years with different data on other variables so work not
* just off by one year but by 1 or 2 years
foreach v of varlist $vars{
	display " working on `v' now"
	replace e_`v' = e_`v'[_n-1] if ImportParcelID==ImportParcelID[_n-1] & e_`v'==. & TaxYear ==2017
	replace e_`v' = e_`v'[_n-2] if ImportParcelID==ImportParcelID[_n-2] & e_`v'==. & TaxYear ==2017 & ImportParcelID[_n-1]==.
}

** do the same with the Codes
foreach v of varlist $code {
	display " working on `v' now"
	replace e_`v' = e_`v'[_n-1] if ImportParcelID==ImportParcelID[_n-1] & e_`v'=="" & TaxYear ==2017
	replace e_`v' = e_`v'[_n-2] if ImportParcelID==ImportParcelID[_n-2] & e_`v'=="" & TaxYear ==2017 & ImportParcelID[_n-1]==.
}	
*then go backward 
foreach yr of numlist 2016/2005{
	foreach v of varlist $vars{
		display " working on `v' now"
		replace e_`v' = e_`v'[_n+1] if ImportParcelID==ImportParcelID[_n+1] & e_`v'==. & TaxYear ==`yr'
		replace e_`v' = e_`v'[_n+2] if ImportParcelID==ImportParcelID[_n+2] & e_`v'==. & TaxYear ==`yr' & ImportParcelID[_n+1]==.
	}

	** do the same with the Codes
	foreach v of varlist $code {
		display " working on `v' now"
		replace e_`v' = e_`v'[_n+1] if ImportParcelID==ImportParcelID[_n+1] & e_`v'=="" & TaxYear ==`yr'
		replace e_`v' = e_`v'[_n+2] if ImportParcelID==ImportParcelID[_n+2] & e_`v'=="" & TaxYear ==`yr' & ImportParcelID[_n+1]==.
	}
	
}

save "$dta\allPre.dta", replace
keep ImportParcelID e_* LegalTownship


gen Year =  e_Year  /* CT -  changing from ren TaxYear Year*/

duplicates drop _all,force  /*restriction*/


** there are many 2008 and 2009 dups with very slight differences
** in things like BathSource let's just take our lumps and drop some
duplicates drop ImportParcelID e_Year, force
save "$dta\allYrs_assess_ct.dta",replace

***************************************************************************************************
* end historic assessement processing
****************************************************************************************************





