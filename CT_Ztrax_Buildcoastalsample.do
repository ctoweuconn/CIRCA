clear all
set more off
cap log close
*Change directories here
global zroot ""
global root ""
global dta "$root\dta"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis ""


******************************************************************************************************
*  Limit Sample to coastal(towns) single-fam residences & Merge with standard attributes from ZTRAX  *
******************************************************************************************************
use "$dta0\all_assess_ct.dta",clear
replace LegalTownship = strtrim(LegalTownship)
keep if LegalTownship=="BRANFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="CLINTON"| ///
LegalTownship=="DARIEN"|LegalTownship=="EAST HAVEN"|LegalTownship=="EAST LYME"| ///
LegalTownship=="FAIRFIELD"|LegalTownship=="GREENWICH"|LegalTownship=="GROTON"| ///
LegalTownship=="GUILFORD"|LegalTownship=="MADISON"|LegalTownship=="MILFORD"| ///
LegalTownship=="NEW HAVEN"|LegalTownship=="NEW LONDON"|LegalTownship=="NORWALK"| ///
LegalTownship=="OLD LYME"|LegalTownship=="OLD SAYBROOK"|LegalTownship=="STAMFORD"| ///
LegalTownship=="STONINGTON"|LegalTownship=="STRATFORD"|LegalTownship=="WATERFORD"| ///
LegalTownship=="WEST HAVEN"|LegalTownship=="WESTBROOK"|LegalTownship=="WESTPORT"

merge m:1 RowID using"$dta0\current_assess_value_ct.dta"
drop if _merge==2
capture drop _merge
merge m:1 RowID using"$dta0\current_assess_ct_building.dta"
drop if _merge==2
capture drop _merge
merge m:1 RowID using"$dta0\current_assess_ct_buildingarea.dta",keepusing(SQFTBAG SQFTBAL SQFTBASE)
drop if _merge==2
capture drop _merge
merge m:1 RowID using"$dta0\current_assess_ct_waterfront.dta", keepusing(Waterfront)
drop if _merge==2
capture drop _merge
replace Waterfront=0 if Waterfront==.
merge m:1 RowID using"$dta0\current_assess_ct_pool.dta",keepusing(PoolStndCode Pool)
drop if _merge==2
capture drop _merge
replace Pool=0 if Pool==.
merge m:1 RowID using"$dta0\current_assess_ct_garage.dta",keepusing(GarageNoOfCars GarageStndCode)
drop if _merge==2
capture drop _merge


merge m:1 RowID using"$dta0\historic_assess_value_ct.dta",update
drop if _merge==2
drop _merge

merge m:1 RowID using"$dta0\historic_assess_ct_building.dta",update keepusing(NoOfUnits PropertyCountyLandUseDescription PropertyCountyLandUseCode BuildingOrImprovementNumber BuildingConditionStndCode YearBuilt NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount HeatingTypeorSystemStndCode AirConditioningStndCode FireplaceNumber *Stnd*)
drop if _merge==2
drop _merge

count if TaxYear==.
count if AssessmentYear==.
replace TaxYear=AssessmentYear if TaxYear==.
drop if TaxYear==.


duplicates report RowID
merge m:1 RowID using"$dta0\historic_assess_ct_buildingarea.dta",update keepusing(SQFTBAG SQFTBAL SQFTBASE)
drop if _merge==2
drop _merge
merge m:1 RowID using"$dta0\historic_assess_ct_garage.dta",update keepusing(GarageStndCode GarageNoOfCars)
drop if _merge==2
drop _merge

*Stnds with very bad quality are dropped during processing above
global code "BuildingConditionStndCode RoofStructureTypeStndCode HeatingTypeorSystemStndCode AirConditioningStndCode FoundationTypeStndCode PoolStndCode GarageStndCode"

global vars "GarageNoOfCars Pool FireplaceNumber TotalBedrooms TotalRooms NoOfStories EffectiveYearBuilt YearBuilt BuildingOrImprovementNumber PropertyCountyLandUseCode NoOfUnits AssessmentYear TotalAssessedValue ImprovementAssessedValue LandAssessedValue "

duplicates drop ImportParcelID TaxYear $code $vars, force

replace PropertyCountyLandUseDescription = trim(PropertyCountyLandUseDescription)
keep if PropertyCountyLandUseDescription=="1-FAMILY RESIDENCE" | ///
		 PropertyCountyLandUseDescription =="SINGLE FAMILY RESIDENCE" | ///	
		 PropertyCountyLandUseDescription =="SINGLE FAMILY RESIDENTIAL" | ///
		 PropertyCountyLandUseDescription =="1-FAM RES" 
*Impute missing values from other periods if this variable is constant over time
foreach v of varlist $vars { 

	display " working on `v' now"
	egen mins = min(`v'), by(ImportParcelID)
	egen maxs = max(`v'), by(ImportParcelID)
	egen means = mean(`v'), by(ImportParcelID)
	
	gen e_`v'=`v'
	replace e_`v' = means if maxs==means & mins == means & `v'==.
	drop mins maxs means
}
foreach v of varlist $code { 

	display " working on `v' now"
	
	gen e_`v'=`v'
}


*Fill in missing years
gen e_Year = TaxYear
replace ImportParcelID=ha_ImportParcelID if ImportParcelID==.
sort ImportParcelID TaxYear
* mark missing year from the bottom
gen markForAdd = 1 if ImportParcelID==ImportParcelID[_n+1] & e_Year < e_Year[_n+1]-1  
mvencode markForAdd, mv(0) override
gen numToAdd =  e_Year[_n+1]-e_Year if ImportParcelID==ImportParcelID[_n+1] & markForAdd==1
expand numToAdd if markForAdd ==1
sort ImportParcelID TaxYear
*revise year generation process so we don't need to generate temp files
tab numToAdd
gen RN1=rnormal()
egen Rank1=rank(RN1),by(ImportParcelID TaxYear markForAdd numToAdd)
replace e_Year=e_Year+Rank1-1
sort ImportParcelID e_Year
capture drop RN1 Rank1

* populate consecutive years where data are missing
foreach yr of numlist 2017/1995{
foreach v of varlist $vars{
	display " working on `v' for `yr' now"
	replace e_`v' = e_`v'[_n-1] if ImportParcelID==ImportParcelID[_n-1] & e_`v'==. & TaxYear ==`yr'
	
}

** do the same with the Codes
foreach v of varlist $code {
	display " working on `v' for `yr' now"
	replace e_`v' = e_`v'[_n-1] if ImportParcelID==ImportParcelID[_n-1] & e_`v'=="" & TaxYear ==`yr'
	
}	
}
*then go backward 
foreach yr of numlist 2016/1994{
	foreach v of varlist $vars{
		display " working on `v' for `yr' now"
		replace e_`v' = e_`v'[_n+1] if ImportParcelID==ImportParcelID[_n+1] & e_`v'==. & TaxYear ==`yr'

	}

	** do the same with the Codes
	foreach v of varlist $code {
		display " working on `v' for `yr' now"
		replace e_`v' = e_`v'[_n+1] if ImportParcelID==ImportParcelID[_n+1] & e_`v'=="" & TaxYear ==`yr'

	}
	
}
drop if e_Year==2018

 * fix gis - one and only time
gen LatFixed =PropertyAddressLatitude+0.00008
gen LongFixed=PropertyAddressLongitude+0.000428

save "$dta0\Allassess_oneunitcoastal.dta",replace
*********************************************************************************************************
* End Limit Sample to coastal(towns) single-fam residences & Merge with standard attributes from ZTRAX  *
*********************************************************************************************************
