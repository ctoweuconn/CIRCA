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
********************************************
*  Begin merge sales with assessment data  *
********************************************
use "$dta0\sales_nonarmsprocessed.dta",replace
duplicates report TransId
merge m:1 ImportParcelID e_Year using"$dta0\Allassess_oneunitcoastal_nodup.dta"
*132,270 matched 
gen matched_PID=(_merge==3)
drop if _merge==2
drop _merge

drop if ha_ImportParcelID==.&ImportParcelID==.&trim(PropertyFullStreetAddress)==""

joinby ha_ImportParcelID e_Year using"$dta0\Allassess_oneunitcoastal_nodup.dta",update unmatched(master)
gen matched_haPID=(_merge==3)
tab matched_PID matched_haPID
*3,016 missing updated
drop if _merge==3&ha_ImportParcelID==.
drop _merge

*Check if alternative merging can pick up more matches
joinby PropertyFullStreetAddress PropertyCity e_Year using"$dta0\Allassess_oneunitcoastal_nodup.dta",update unmatched(master)
count if _merge==3&matched_PID==0&matched_haPID==0
*318 missing updated 
gen matched_add=(_merge==3)
drop _merge

drop if matched_PID==0&matched_haPID==0&matched_add==0
/*Restriction 113,829 dropped No assessment data for transactions*/
*Reasons: sales happen before the tax record starts, not matching the property type being studied,
* or holding wrong importparcelid, or property not included in the assessment data
*136,076 left
duplicates report TransId
set seed 1234567 
gen R=rnormal()
sort TransId R
duplicates drop TransId,force/*restriction 471 dropped*/
drop R
*135,605 left
save "$dta0\data_oneunitcoastsale.dta",replace
********************************************
*   End merge sales with assessment data   *
********************************************


