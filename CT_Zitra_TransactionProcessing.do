/************************************/
* work with the transaction file here
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


*********************************************************************************
*********************************************************************************
*****Make sure the properties to be matched have transactions******
*********************************************************************************
*********************************************************************************
set more off
use "$zdta\transaction_09.dta",clear   /*this is the only transaction data to use*/
*** this transaction file has real transactions and many mortgage events
*** just keep the actual transactions
keep if SalesPriceAmount!=. & SalesPriceAmount>0
gen withloan=(LoanAmount>0)
keep TransId SalesPriceAmount RecordingDate withloan
merge 1:m TransId using "$zdta\transaction_property_09.dta",
drop if _merge!=3

keep TransId ImportParcelID RecordingDate SalesPrice PropertyFullStreetAddress ///
	PropertyBuildingNumber PropertyCity PropertyState PropertyZip PropertyAddressLatitude ///
	PropertyAddressLongitude PropertyAddressCTractAndBlock

gen TransactionYear= substr(RecordingDate,1,4)
gen TransactionMonth=substr(RecordingDate,6,2)
gen TransactionDay = substr(RecordingDate,9,2)

tab TransactionYear
destring(TransactionYear), replace
drop if TransactionYear<2005
 
 * fix gis - one and only time
gen LatFixed =PropertyAddressLatitude+0.00008
gen LongFixed=PropertyAddressLongitude+0.000428

gen e_Year = TransactionYear /*for merge with estimation data*/
duplicates drop TransId, force
* some mult sales in same day have diff TransID but same price
duplicates drop ImportParcelID RecordingDate SalesPriceAmount, force
save "$dta\transAllCT.dta", replace


