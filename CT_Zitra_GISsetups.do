
clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"


*******************************************************************
*  Begin pull out address points-prepare sample for GIS analysis  *
*******************************************************************
use "$dta\Allassess_oneunitcoastal.dta",clear
tab e_NoOfUnits
count if e_NoOfUnits==.

duplicates drop PropertyFullStreetAddress PropertyCity,force
duplicates drop ImportParcelID,force
tab e_NoOfUnits 
count if e_NoOfUnits==.
count if e_NoOfUnits>=2&e_NoOfUnits!=.
count if e_NoOfUnits==1|(e_NoOfUnits==0)
tab LegalTownship 
tab LegalTownship if e_NoOfUnits==1|(e_NoOfUnits==0)

order e_NoOfUnits PropertyFullStreetAddress PropertyCity
gen connected_address_code=ustrpos(PropertyFullStreetAddress,"-")
order connected_address

tab e_NoOfUnits if connected_address>=1
*drop if the address is a connected address and does not have NoOfUnits as 1.
drop if connected_address>=1&e_NoOfUnits!=1
/*restriction 2,891 dropped*/
*drop if NoOfUnits>1
drop if e_NoOfUnits>1&e_NoOfUnits!=.
/*restriction 6,496 dropped*/
drop markForAdd numToAdd
drop connected_add*
save "$dta\propOneunitcoastal.dta",replace
****************************************
*    End pulling out address points    *
****************************************

