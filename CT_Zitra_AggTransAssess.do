
clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"


********************************************
*  Begin merge sales with assessment data  *
********************************************
*Preprocess assessment data
use "$dta\Allassess_oneunitcoastal.dta",clear
duplicates report ImportParcelID e_Year
duplicates tag ImportParcelID e_Year,gen(dup1)

global vars "GarageNoOfCars Pool FireplaceNumber TotalBedrooms TotalRooms NoOfStories EffectiveYearBuilt YearBuilt BuildingOrImprovementNumber PropertyCountyLandUseCode NoOfUnits AssessmentYear TotalAssessedValue ImprovementAssessedValue LandAssessedValue "
/*ZC it's hard to know which one is more trustworthy, only some with assessment year while some doesn't. So keep those with assessment year*/
gen missing_AssYear=(AssessmentYear==.)
egen R_dup1_Ass=rank(missing_AssYear),by(ImportParcelID e_Year dup1)

gen missing_num=0
foreach v in $vars {
replace missing_num=missing_num+1 if e_`v'==.
}
sort ImportParcelID e_Year
egen R_dup1=rank(missing_num),by(ImportParcelID e_Year dup1)
sort ImportParcelID e_Year R_dup1
*impute values from the duplicated obs with more missings to the one with less missings
foreach v in $vars {
replace e_`v'=e_`v'[_n+1] if e_`v'==.&dup1==1&dup1[_n+1]==1
}

sort ImportParcelID e_Year R_dup1_Ass R_dup1
*duplicates drop those observations with missing AssYear or more missing values
duplicates drop ImportParcelID e_Year,force
/*restriction 288,585 dropped*/
drop markForAdd numToAdd dup1 missing_AssYear R_dup1_Ass missing_num R_dup1


sort ImportParcelID PropertyFullStreetAddress PropertyCity LegalTownship e_Year
* populate one-parcel-consecutive-years where SQFT are missing
foreach v of varlist SQFTBAG SQFTBAL SQFTBASE{
gen e_`v'=`v'
}
foreach yr of numlist 2017/1995{
foreach v of varlist SQFTBAG SQFTBAL SQFTBASE{
	display " working on `v' for `yr' now"
	replace e_`v' = e_`v'[_n-1] if ImportParcelID==ImportParcelID[_n-1] & e_`v'==. & e_Year ==`yr'
}
}
*then go backward 
foreach yr of numlist 2016/1994{
	foreach v of varlist SQFTBAG SQFTBAL SQFTBASE{
		display " working on `v' for `yr' now"
		replace e_`v' = e_`v'[_n+1] if ImportParcelID==ImportParcelID[_n+1] & e_`v'==. & e_Year ==`yr'
}
}
save "$dta\Allassess_oneunitcoastal_nodup.dta",replace

use "$dta\sales_nonarmsprocessed.dta",replace
duplicates report TransId
merge m:1 ImportParcelID e_Year using"$dta\Allassess_oneunitcoastal_nodup.dta"
*114,442 matched
gen matched_PID=(_merge==3)
drop if _merge==2
drop _merge

drop if ha_ImportParcelID==.&ImportParcelID==.&trim(PropertyFullStreetAddress)==""
/*
merge m:m ha_ImportParcelID e_Year using"$dta\Allassess_oneunitcoastal_nodup.dta",update
*0 missing updated,so won't use this
gen matched_haPID=(_merge==3|_merge==5)
drop if _merge==3&ha_ImportParcelID==.
drop if _merge==2
drop _merge
*/

merge m:m PropertyFullStreetAddress PropertyCity e_Year using"$dta\Allassess_oneunitcoastal_nodup.dta",update
*52 missing updated 
gen matched_add=(_merge==3|_merge==4|_merge==5)
drop if _merge==2
drop _merge

drop if matched_PID==0&matched_add==0

duplicates report TransId
duplicates drop TransId,force
/*restriction 170 dropped*/
save "$dta\data_oneunitcoastsale.dta",replace
********************************************
*   End merge sales with assessment data   *
********************************************
