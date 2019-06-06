clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global zdta "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"

use "$zdta\historic_assess_09.dta",clear
keep PropertyFullStreetAddress PropertyCity PropertyAddressUnitNumber PropertyZip PropertyZip4 ImportParcelID
duplicates drop ImportParcelID, force

ren ImportParcelID ha_ImportParcelID
label variable ha_ImportParcelID "id from historic assessemnt file"
destring(PropertyZip), replace
destring(PropertyZip4), replace
duplicates tag PropertyFullStreetAddress PropertyCity PropertyAddressUnitNumber, gen(badAssessData) 
merge m:m PropertyFullStreetAddress PropertyCity PropertyAddressUnitNumber using "$zdta\current_assess_09.dta", 

drop if trim(PropertyFullStreetAddress)==""

keep ha_ImportParcelID ImportParcelID

save $dta\ha_to_curr_idKey.dta, replace
