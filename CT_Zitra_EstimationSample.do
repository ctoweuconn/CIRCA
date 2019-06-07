
/************************************/
* Put together the different sources into an
* estimation sample.
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
global narms "$root\working\09\dta"

use "$dta\allYrs_assess_ct.dta",replace

* now put this with transaction data
merge 1:m ImportParcelID e_Year  using  "$dta\transAllCT.dta"
keep if _merge==3
drop _merge 
drop if SalesPriceAmount <15000
drop if SalesPriceAmount > 30000000 /*30 million*/


save $dta\prelimEstSample.dta, replace

merge 1:1 TransId using "$narms\state9_NonArms.dta" 
keep if _merge==1 | _merge==3
mvencode nonARMS, mv(0) override
drop nonARMS_corp1 nonARMS_text nonARMSs_* nonARMSb_*

save $dta\prelimEstSample_wNonARMS.dta, replace


