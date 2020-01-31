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
*120,250 matched
gen matched_PID=(_merge==3)
drop if _merge==2
drop _merge

drop if ha_ImportParcelID==.&ImportParcelID==.&trim(PropertyFullStreetAddress)==""

joinby ha_ImportParcelID e_Year using"$dta0\Allassess_oneunitcoastal_nodup.dta",update unmatched(master)
gen matched_haPID=(_merge==3)
tab matched_PID matched_haPID
*2799 missing updated
drop if _merge==3&ha_ImportParcelID==.
drop _merge

*Check if alternative merging can pick up more matches
joinby PropertyFullStreetAddress PropertyCity e_Year using"$dta0\Allassess_oneunitcoastal_nodup.dta",update unmatched(master)
count if _merge==3&matched_PID==0&matched_haPID==0
*253 missing updated 
gen matched_add=(_merge==3)
drop _merge

drop if matched_PID==0&matched_haPID==0&matched_add==0
/*Restriction 111,492 dropped No assessment data for transactions*/
*Reasons: outside the study period （before 1994) or study region, wrong importparcelid, or property not included in the assessment data
*123,739 left
duplicates report TransId
set seed 1234567 
gen R=rnormal()
sort TransId R
duplicates drop TransId,force/*restriction 445 dropped*/
drop R
*123,294 left
save "$dta0\data_oneunitcoastsale.dta",replace
********************************************
*   End merge sales with assessment data   *
********************************************

