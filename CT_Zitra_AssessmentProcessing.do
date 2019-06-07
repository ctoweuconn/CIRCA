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
global Zitrax "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"


**************************************
* Begin assessment data aggregation  *
**************************************
*get ImportParcelID matched pairs between hist assess and current assess
use "$Zitrax\dta\historic_assess_09.dta",clear
keep PropertyFullStreetAddress PropertyCity PropertyAddressUnitNumber PropertyZip PropertyZip4 ImportParcelID
duplicates drop ImportParcelID, force

ren ImportParcelID ha_ImportParcelID
label variable ha_ImportParcelID "id from historic assessemnt file"
drop if trim(PropertyFullStreetAddress)==""
drop if trim(PropertyCity)==""
merge m:m PropertyFullStreetAddress PropertyCity PropertyAddressUnitNumber using "$Zitrax\dta\current_assess_09.dta", keepusing(ImportParcelID)
keep ha_ImportParcelID ImportParcelID
drop if ha_ImportParcelID==.|ImportParcelID==.
save $dta\ha_to_curr_idKey.dta, replace


use "$Zitrax\dta\historic_assess_09.dta",clear
tab TaxYear
keep if TaxYear>=1994

keep RowID ImportParcelID FIPS State County ExtractDate AssessorParcelNumber ///
UnformattedAssessorParcelNumber PropertyFullStreetAddress PropertyCity PropertyZip /// 
PropertyZoningDescription TaxIDNumber TaxAmount TaxYear NoOfBuildings LegalTownship ///
LotSizeAcres LotSizeSquareFeet PropertyAddressLatitude PropertyAddressLongitude BatchID

ren ImportParcelID ha_ImportParcelID
merge m:m ha_ImportParcelID using "$dta\ha_to_curr_idkey.dta"
drop _merge
/*_merge==1 means the address is missing or doesn't show up at all in current assess file, so it's 
not associated with an ImportParcelID */
global strings "County AssessorParcelNumber UnformattedAssessorParcelNumber PropertyFullStreetAddress PropertyCity PropertyZip PropertyZoningDescription TaxIDNumber LegalTownship"
foreach v in $strings {
replace `v'=trim(`v')
}
*Now the ImportParcelID and ha_ImportParcelID gaurantee the tax record can be matched with transactions (try both at merging),
*even if the ImportParcelID is changed - at least one of them should be right

destring(PropertyZip), replace

append using "$Zitrax\dta\current_assess_09.dta"

keep RowID ImportParcelID ha_ImportParcelID FIPS State County ExtractDate AssessorParcelNumber ///
UnformattedAssessorParcelNumber PropertyFullStreetAddress PropertyCity PropertyZip /// 
PropertyZoningDescription TaxIDNumber TaxAmount TaxYear NoOfBuildings LegalTownship ///
LotSizeAcres LotSizeSquareFeet PropertyAddressLatitude PropertyAddressLongitude BatchID

duplicates drop
save "$dta\all_assess_ct.dta",replace
**************************************
*  End assessment data aggregation   *
**************************************





