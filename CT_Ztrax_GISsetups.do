
clear all
set more off
cap log close
*Change directories here
global zroot ""
global root ""
global dta "$root\dta\"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis ""


*******************************************************************
*  Begin pull out address points-prepare sample for GIS analysis  *
*******************************************************************
use "$dta0\Allassess_oneunitcoastal.dta",clear
set seed 1234567
tab e_NoOfUnits
count if e_NoOfUnits==.
gen ID=_n
sort ImportParcelID PropertyFullStreetAddress PropertyCity e_Year ID
gen neg_Year=-(e_Year)
sort ImportParcelID neg_Year ID

duplicates drop PropertyFullStreetAddress PropertyCity,force
duplicates drop ImportParcelID,force


tab e_Year
drop neg_Year
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
/*restriction 1,368 dropped*/
*drop if NoOfUnits>1
drop if e_NoOfUnits>1&e_NoOfUnits!=.
/*restriction 4,845 dropped*/
drop markForAdd numToAdd
drop connected_add*
drop ID
save "$dta0\propOneunitcoastal.dta",replace

use "$dta0\propOneunitcoastal.dta",clear
keep ImportParcelID PropertyFullStreetAddress PropertyCity LatFixed LongFixed FIPS State County
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\propOneunitcoastal.csv", replace
*This dataset is then going through GoogleAPI so that we get google points for these addresses
*This dataset further restricted by LiDAR2012 domain will be the one to conduct viewshed analysis on
*ZC: the actual google API work only applies to those viewshed-analysis one-unit properties (selected based on ZTRAX points)

*After the coordinate revision, the final file is "proponeunit_building_revise.dta"

*Creat the dataset for viewshed analysis with google points
use "$dta0\propOneunitcoastal.dta",clear
keep ImportParcelID PropertyFullStreetAddress PropertyCity LegalTownship LatFixed LongFixed FIPS State County
merge 1:1 PropertyFullStreetAddress PropertyCity using"$dta\prop_va_oneunitfixgoogle.dta",keepusing(accuracy latitude longitude)
drop if _merge==2
ren latitude latGoogle
ren longitude longGoogle
replace latGoogle=LatFixed if _merge!=3
replace longGoogle=LongFixed if _merge!=3
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\propOneunitcoastal.csv", replace
*This dataset is then plotted in ArcGIS, which is named prop_oneunitcoastGgl.shp. The corresponding dta is prop_oneunitcoastGgl.dta

keep if _merge==3
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\prop_va_oneunit.csv", replace
*ZC: This viewshed analysis point set might be of different order from the shapefile, do not import this to generate shapefile again.
****************************************
*    End pulling out address points    *
****************************************


