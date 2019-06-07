/*
*  Input files needed these can be prerestricted 
*  by state or even better by county or town to save
*  on processing time
*  
*  from \Zillow\current_assess_transaction\24\ZTrans
*  
*  Main
*  ForeclosureNameAddress
*  PropertyInfo
*  BuyerName
*  SellerName
*  
*  
*  from the historical assessment files
*  from \Zillow\historic_assessment\24\ZAsmt
*  
*  Main
*  Value
*/
*clear all
set more off

global state "09"
*Change the directories here
 *work space
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow"
global towe "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles"

 *processed data file
global dta "$towe\dta\\$state"
 
********************************************************
********************************************************
*Note: Search for the term "restriction" to see where we dropped anything from the data
********************************************************
********************************************************

*output directory
global working "$towe\working\\$state\dta"
********************************************************

use "$dta\MainTrans.dta",replace
gen ctSaleYear = substr(RecordingDate, 1,4)  /* for merge later on*/

gen nonARMS_if = IntraFamilyTransferFlag=="Y"
	label variable nonARMS_if "Non ARMS intra family transfer" 

drop if SalesPriceAmountStndCode =="NA"  /*NA is non ARMS*/
drop if SalesPriceAmountStndCode =="DL" /*delinquent amount */
drop if PropertyUseStndCode=="CM" /*commercial*/
drop if PropertyUseStndCode=="IN" /*industrial*/
drop if PropertyUseStndCode=="EX" /*exempt*/

************************************************************
* note no transfer taxes are paid on a foreclosure deed ****
************************************************************
gen nonARMS_tte = TransferTaxExemptFlag=="Y"
	label variable nonARMS_tte "Non ARMS transfer tax exempt - meaning not changing hands between unrelated parties" 

* mark foreclosures check the next transaction by ImportParcelId to 
* see if you can locate sales this way.
merge 1:1 TransId using "$dta\ForeclosureNameAddress.dta", gen(_mFCs)

***restriction*****
*keep if SalesPriceAmount >0 & SalesPriceAmount!=. | _mFCs==3

* merge with PropertyInfo to get to an ImportParcelID
merge 1:1 TransId using  "$dta\TransPropertyInfo.dta", gen(_mergeTransInfo) keepusing(ImportParcelID Property*)
keep if _mergeTransInfo==3

* now merge with the historic assessments
* use the ImportParcelID in this file to get a rowID
* keep what we need
keep Auction* ImportParcelID _mFC* TransId Recording* ctSaleYear DataClassStndCode DocumentTypeStndCode ///
     SalesPriceAmount SalesPriceAmountStndCode Propert* nonARM*

*** restriction ***
drop if ImportParcelID ==. /* I am not sure why this occurs but we cannot get other information on these transactions without this id*/

gen n=1
egen countall =sum(n), by(ImportParcelID)

* foreclosure deeds transactions and substitute deeds 
* sometimes DocumentTypeStndCode=="OTHR" are FC sales like TransId 187733346
* catches too many gen pFCs = (DocumentTypeStndCode=="TRFC" | DocumentTypeStndCode=="NTSL")
gen pFCs = (DataClassStndCode=="F" & RecordingBookNumber!="" | (AuctionDate!=""))
egen _countFs =sum(n) if pFCs==1, by(ImportParcelID)
egen countFs =mean(_countFs) , by(ImportParcelID)

gen possibleFC = ( countFs<countall & countFs >0 & countFs!=.)

** find the F's and mark the next sale as possible convey 9
gen recYear = substr(RecordingDate, 1,4)  /* for merge later on*/
gen recMonth = substr(RecordingDate, 6,2)  /* for merge later on*/
gen recDay = substr(RecordingDate, 9,2)  /* for merge later on*/
destring(recYear), replace
destring(recMonth), replace
destring(recDay), replace
gen dayOfRec = mdy(recMonth,recDay,recYear)

sort ImportParcelID dayOfRec

* running total of observations
gen Ftotal = 0 
gen cumFtotal = 0
egen minIPI = min(_n), by(ImportParcelID)
replace Ftotal = 1 if minIPI ==_n &	 pFCs==1
replace Ftotal = Ftotal[_n-1]+1 if minIPI <_n &  pFCs==1

* running transactions total
gen Ttotal = 0 
replace Ttotal = 1 if minIPI ==_n 
replace Ttotal = Ttotal[_n-1]+1 if minIPI <_n 

*** mark the first transaction after a substitute deed
gen _firstPostPossibleFC = (Ftotal==1 & Ftotal[_n+1]-1!=Ftotal[_n] ) | /// 
						  (Ftotal>1 & Ftotal[_n-1]+1==Ftotal[_n] & ///	 
						   Ftotal[_n+1]-1!=Ftotal[_n] )
						   
*** check the years difference as well if it is really long maybe don't mark it
gen _TransFC = Ttotal if _firstPostPossibleFC==1
gen TransFC = 1 if _TransFC==. & _TransFC[_n-1]>0 & _TransFC[_n-1]!=. 

gen TransFC_daysSince = dayOfRec[_n] - dayOfRec[_n-1] if _TransFC==. & _TransFC[_n-1]>0 & _TransFC[_n-1]!=. 
gen TransFC_1y = TransFC if TransFC_daysSince<=365
gen TransFC_2y = TransFC if TransFC_daysSince<=730 & TransFC_daysSince>365
gen TransFC_gt2y = TransFC  if TransFC_daysSinc>730

rename TransFC_1y nonARMS_sat1
rename TransFC_2y nonARMS_sat2
rename TransFC_gt2y nonARMS_sat3
mvencode nonARMS_*, mv(0) override

label variable nonARMS_sat1 "Likely non Arms sale due to first sale (in 1yr) after default and appt of substitute trustee"
label variable nonARMS_sat2 "Likely non Arms sale due to first sale (in 2yr) after default and appt of substitute trustee"
label variable nonARMS_sat3 "Likely non Arms sale due to first sale (in gt2yr) after default and appt of substitute trustee"

* save how many days since the substitute trustee was appointed
gen aYear = substr(AuctionDate, 1,4)  /* for merge later on*/
gen aDay = substr(AuctionDate, 9,2)  /* for merge later on*/
gen aMonth = substr(AuctionDate, 6,2)  /* for merge later on*/
destring(aYear), replace
destring(aMonth), replace
destring(aDay), replace
gen wasAuctionedDate = mdy(aMonth,aDay,aYear)

tempfile t
save "`t'", replace
keep Import* wasAuctionedDate
drop if wasAuctionedDate==.

sort ImportParcelID wasAuctionedDate
egen _m = min(_n), by(ImportParcelID)
gen ctr = _n-_m+1

* for up to 10 auctions ( more would be exceedingly rare)
foreach n of numlist 1/10{
	gen _auctionDOY_`n' = .
}
foreach n of numlist 1/10{
	replace _auctionDOY_`n' = wasAuctionedDate if ctr==`n'
	egen  auctionDOY_`n' = mean(_auctionDOY_`n'), by(ImportParcelID)
}

duplicates drop ImportParcelID, force

merge 1:m ImportParcelID using "`t'", gen(_mAuction)

* cleaned transaction file with auction, property info, and foreclosures
save "$working\trans.dta", replace
use "$working\trans.dta", replace
* get a RowID 
keep ImportParcelID TransId
duplicates drop ImportParcelID TransId, force

** attach the historic assessment data
merge m:m ImportParcelID using "$dta\MainHistoric.dta",gen(_mergeTransInfoHistAsmt) keepusing(RowID LotSizeSq* Unform*)
keep if _mergeTransInfoHistAsmt==3
drop if RowID==""   /*** restriction ****/
* use the RowID to get historical values from assessment files merge with RowID to get historic values
merge m:1 RowID using "$dta\ValueHistoric.dta", gen(_mergeHistAsValue)
*merge m:1 RowID using "$dta\\historic_assess_building_24Mont.dta", gen(_mergeHistAsBldg) keepusing(*Land*)


** now merge back to the full transid transaction data
merge m:1 TransId using "$working\trans.dta", gen(_mTrans)
keep if _mTrans==3
drop _mTrans 



*** at this point the RowID mapping to ImportParcelId tends to misalign the attributes and the years they should just be done on
*** ImportParcelId here let's delink the transactions and assessment as they were done on RowID and redo the link on 
*** ImportParcelId and year of sale (RecordingDate)

save "$working\_temp.dta", replace
use "$working\_temp.dta", replace

*These codes are already embedded in the CT_Zitra do file. Make sure don't do it twice.
rename PropertyAddressLatitude PropertyAddressLatitude_orig
rename PropertyAddressLongitude PropertyAddressLongitude_orig
gen PropertyAddressLatitude=PropertyAddressLatitude_orig+0.00008
gen PropertyAddressLongitude=PropertyAddressLongitude_orig+0.000428

*export delimited using "$towe\maps\MontSales.csv", replace

destring(ctSaleYear), replace
* count be MarketValueYear or AssessmentYear
foreach n of numlist 0/8{
	gen _ratio`n' = SalesPriceAmount/ TotalMarketValue if ctSaleYear+`n'== AssessmentYear 
	if `n' ==0{
		replace _ratio`n' = SalesPriceAmount/ TotalAssessedValue if ctSaleYear-1== AssessmentYear & _ratio`n'==.
	}
	egen ratio`n' = mean(_ratio`n'), by(TransId)
}

*** these are zillow files
* merge with buyers file to get buyer names
merge m:m TransId using "$dta\buyers.dta", gen(_mBuyers)
keep if _mBuyers==3
* merge with sellers file to get seller names
merge m:m TransId using "$dta\sellers.dta", gen(_mSellers)
keep if _mSellers==3

* corporate 
gen nonARMS_corp = 0
replace nonARMS_corp = (CorpBuyer!="")
replace nonARMS_corp = 1 if LastSeller == LastBuyer & (LastSeller!="" & LastBuyer!="")

*maybe others here
gen nonARMS_sb = 0
gen nonARMS_fd = 0
* these are auction sales
replace nonARMS_fd = 1 if DocumentTypeStndCode == "TRFC" | DocumentTypeStndCode=="NTSL"

* now let's loop over common nonARMS terms in buyer and seller
foreach v of varlist FullBuyer FullSeller{
	*FullSeller{
	if "`v'" =="FullBuyer" {
		local f = "b" 
	}
	*all bad for seller don't use
	if "`v'" == "FullSeller"{
		local f = "s" 
	}	
	gen nonARMS`f'_1 = 1 if strpos(`v', "SEC OF HOUSING & URBAN")>0 /* s bad*/
	gen nonARMS`f'_2 = 1 if strpos(`v', "BANK OF AMERICA")>0 /* s bad*/
	*gen nonARMS`f'_3 = 1 if strpos(`v', "ET AL")>0  /*b - grabs alot of legit sales*/
	gen nonARMS`f'_4 = 1 if strpos(`v', "VETERANS AFFAIRS")>0
	gen nonARMS`f'_5 = 1 if strpos(`v', "SECRETARY")>0
	gen nonARMS`f'_6 = 1 if strpos(`v', "SEC OF")>0
	gen nonARMS`f'_7 = 1 if strpos(`v', "HOUSING")>0
	gen nonARMS`f'_8 = 1 if strpos(`v', "NATIONAL")>0
	gen nonARMS`f'_9 = 1 if strpos(`v', "FEDERAL")>0
	gen nonARMS`f'_10 = 1 if strpos(`v', "MORTGAGE")>0
	gen nonARMS`f'_11 = 1 if strpos(`v', "LOAN")>0
	gen nonARMS`f'_12 = 1 if strpos(`v', "CAPITAL")>0 
	gen nonARMS`f'_13 = 1 if strpos(`v', "CAPITOL")>0
	gen nonARMS`f'_14 = 1 if strpos(`v', "FINANCE")>0 
	*gen nonARMS`f'_15 = 1 if strpos(`v', "UNITED")>0 /*b - almost all legit sales*/
	*gen nonARMS`f'_16 = 1 if strpos(`v', " INC")>0 /*b - grabs alot of legit sales*/
	gen nonARMS`f'_17 = 1 if strpos(`v', " LLC")>0 /*b - almost all legit sales*/
	gen nonARMS`f'_18 = 1 if strpos(`v', " CORP")>0 /*b - grabs alot of legit sales*/
	gen nonARMS`f'_19 = 1 if strpos(`v', " CORPORATION")>0 /*b - grabs alot of legit sales*/
	gen nonARMS`f'_21 = 1 if strpos(`v', " ASSOCIATION")>0
	gen nonARMS`f'_22 = 1 if strpos(`v', " COMPANY")>0
	*gen nonARMS`f'_23 = 1 if strpos(`v', "DEVELOPMENT")>0 /*b - grabs alot of legit sales*/
	gen nonARMS`f'_24 = 1 if strpos(`v', " F S B")>0
	gen nonARMS`f'_25 = 1 if strpos(`v', "REGIONAL OFFICE DIRECTOR")>0
	gen nonARMS`f'_26 = 1 if strpos(`v', " USA")>0
	gen nonARMS`f'_27 = 1 if strpos(`v', "HSBC")>0
	gen nonARMS`f'_28 = 1 if strpos(`v', "GUARANTY")>0
	*gen nonARMS`f'_29 = 1 if strpos(`v', "UNITED")>0 /*b - almost all legit sales*/
	*gen nonARMS`f'_30 = 1 if strpos(`v', "TRUST")>0 /*b - grabs alot of legit sales*/
	*gen nonARMS`f'_31 = 1 if strpos(`v', "TRUSTEE")>0  /*b - grabs alot of legit sales*/
	gen nonARMS`f'_32 = 1 if strpos(`v', "BANK OF")>0
	gen nonARMS`f'_33 = 1 if strpos(`v', "ST OF")>0
	gen nonARMS`f'_34 = 1 if strpos(`v', "STATE OF")>0
	gen nonARMS`f'_35 = 1 if strpos(`v', "MUTUAL")>0
	*gen nonARMS`f'_36 = 1 if strpos(`v', "C/O")>0 /*b - almost all legit sales*/
	gen nonARMS`f'_37 = 1 if strpos(`v', "(TR)")>0
	*gen nonARMS`f'_38 = 1 if strpos(`v', "LTD")>0 /*b - almost all legit sales*/
	gen nonARMS`f'_39 = 1 if strpos(`v', "CHEVY CHASE BANK")>0
	gen nonARMS`f'_40 = 1 if strpos(`v', " BANK")>0

}
mvencode nonARMS*, mv(0) override

* ratio clean up 
* note it is likely the first ratio filled in is the best
gen ratioToUse = 99
gen ratioDist = 99

foreach n of numlist 0/8{
	replace ratioToUse = ratio`n' if ratioToUse==99 | ratioToUse >2 | ratioToUse <.3 
	replace ratioDist = `n' if ratioToUse==ratio`n' 

}

*** use the ratio and suspect obs to mark nonARMS (burned in with actual MD data)
gen nonARMS_text = 0
foreach v of varlist nonARMSb_* nonARMSs_*{
	replace nonARMS_text = 1 if `v'==1 & (ratioToUse<.8 | ratioToUse>1.2 | ratioToUse==.)
}

gen nonARMS_corp1 = 0
replace nonARMS_corp1 = nonARMS_corp if  nonARMS_corp==1 & (ratioToUse<.8 | ratioToUse>1.2 | ratioToUse!=.)

save "$working\beforeDrops.dta", replace


use "$working\beforeDrops.dta", replace

duplicates drop TransId, force

gen nonARMS = nonARMS_if +nonARMS_tte +nonARMS_text +nonARMS_fd +nonARMS_sat2 +nonARMS_sat1 +nonARMS_corp1

local state = $state
save "$working\\state`state'_wNArms.dta", replace

keep  nonARMS TransId  RowID

save "$working\\state`state'_NonArms.dta", replace



