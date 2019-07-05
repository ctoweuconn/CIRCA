clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"

/*
This process purges non-armslength transaction, search "restrition" to see where obs are dropped
*/
*******************************************
*     Begin process transaction data      *
*******************************************
*****Make sure the properties to be matched have transactions******
set more off
use "$Zitrax\dta\transaction_09.dta",clear
merge 1:m TransId using"$Zitrax\dta\transaction_property_09.dta",keepusing(AssessorParcelNumber ImportParcelID PropertyFullStreetAddress PropertyCity)
drop if _merge!=3
*All matched with ImportParcelID (5.3m)

count if ImportParcelID==.
*drop obs for which we cannot get attributes and geographics
drop if ImportParcelID==.&AssessorParcelNumber==""&(trim(PropertyFullStreetAddress)=="0"|trim(PropertyFullStreetAddress)=="")
drop if (trim(PropertyFullStreetAddress)=="0"|trim(PropertyFullStreetAddress)=="")
/*restriction 81,400 dropped*/
*Later, try merge with address or AssessorParcelNumber if ImportParcelID is missing



*Deleting non-armslength here 
tab IntraFamilyTransferFlag
*Not populated at all
tab TransferTaxExemptFlag
*Not populated at all
tab PropertyUseStndCode
drop if PropertyUseStndCode=="CM" /*restriction commercial 68,139 dropped*/
drop if PropertyUseStndCode=="IN" /*restriction industrial 12,577 dropped*/
drop if PropertyUseStndCode=="EX" /*restriction exempt 3,952 dropped*/


tab DataClassStndCode
tab DataClassStndCode, sum(SalesPriceAmount)

*keep only real transactions (D-trans without mortgage,H-deed with concurrent mortgage)
*Foreclosures are temporally kept to identify nonarmslength
keep if DataClassStndCode=="D"|DataClassStndCode=="H"|DataClassStndCode=="F"
/*restriction 2,820,494 dropped*/
tab DataClassStndCode, sum(LoanAmount)

*754k deed records, 1,325,962 refinance records (deed with cocurrent mortgage)
tab DocumentTypeStndCode
/*Major categories might not be full market value:   DELU (in lieu of foreclosure documents), 
       EXDE (executor's deed), 
       FCDE (foreclosure deed), 
       FDDE (fiduciary deed),
       QCDE (quitclaim deed),
	   TXDE (tax deed),
	   TRFC (foreclosure sale transfer).
*/
drop if DocumentTypeStndCode=="DELU"|DocumentTypeStndCode=="EXDE"|DocumentTypeStndCode=="FCDE"|DocumentTypeStndCode=="FDDE"|DocumentTypeStndCode=="QCDE"|DocumentTypeStndCode=="TXDE"|DocumentTypeStndCode=="TRFC"|DocumentTypeStndCode=="NTSL"
/*restriction 401,960 deed records dropped*/


* foreclosure deeds transactions and substitute deeds 
* sometimes DocumentTypeStndCode=="OTHR" are FC sales like TransId 187733346
/*ZC: TRFC catches too few (63) in CT gen pFCs = (DocumentTypeStndCode=="TRFC" | DocumentTypeStndCode=="NTSL")
*/
gen pFCs = (DataClassStndCode=="F"& RecordingBookNumber!="" ) /*ZC auction dates are not populated in CT*/
tab pFCs

gen n=1
egen countall=sum(n), by(ImportParcelID PropertyFullStreetAddress PropertyCity)
egen _countFs =sum(n) if pFCs==1, by(ImportParcelID PropertyFullStreetAddress PropertyCity)
egen countFs =mean(_countFs) , by(ImportParcelID PropertyFullStreetAddress PropertyCity)

gen possibleFC = ( countFs<countall & countFs >0 & countFs!=.)


gen recYear = substr(RecordingDate, 1,4)  /* for merge later on*/
gen recMonth = substr(RecordingDate, 6,2)  /* for merge later on*/
gen recDay = substr(RecordingDate, 9,2)  /* for merge later on*/
destring(recYear), replace
destring(recMonth), replace
destring(recDay), replace
gen dayOfRec = mdy(recMonth,recDay,recYear)

sort ImportParcelID PropertyFullStreetAddress PropertyCity dayOfRec

* running total of observations
gen Ftotal = 0 
egen minIPI = min(_n), by(ImportParcelID PropertyFullStreetAddress PropertyCity dayOfRec)
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

tab nonARMS_sat1
tab nonARMS_sat2
tab nonARMS_sat3 

*Drop foreclosures 
drop if DataClassStndCode=="F"
/*restriction  321,301 dropped*/

*Drop possible foreclosure sales (within in 1yr or 2yrs after default)
drop if nonARMS_sat1==1
/*restriction  91,980 dropped*/
drop if nonARMS_sat2==1
/*restriction  20,886 dropped*/


gen withloan=(LoanAmount>0&LoanAmount!=.)
keep TransId AssessorParcelNumber ImportParcelID PropertyFullStreetAddress PropertyCity SalesPriceAmount SalesPriceAmountStndCode LoanAmount LoanRateTypeStndCode /// 
LoanDueDate DataClassStndCode DocumentTypeStndCode IntraFamilyTransferFlag LoanTypeStndCode /// 
PropertyUseStndCode RecordingDate withloan LenderName LenderTypeStndCode LenderIDStndCode




duplicates tag TransId,gen(dup1)
foreach v in ImportParcelID{
drop if dup1==1&`v'==.
}
/*restriction 439 dropped*/
foreach v in AssessorParcelNumber PropertyFullStreetAddress PropertyCity{
drop if dup1==1&trim(`v')==""
}
duplicates report TransId
duplicates drop TransId,force
/*restriction 568 dropped*/

merge 1:m TransId using"$Zitrax\dta\transaction_buyer_09.dta",keepusing(BuyerLastName BuyerIndividualFullName BuyerNonIndividualName)
drop if _merge==2
drop _merge
duplicates report TransId

merge m:m TransId using"$Zitrax\dta\transaction_seller_09.dta",keepusing(SellerLastName SellerIndividualFullName SellerNonIndividualName)
drop if _merge==2 
drop _merge
duplicates report TransId

egen TransId_rank=rank(_n),by(TransId)
reshape wide BuyerLastName BuyerIndividualFullName BuyerNonIndividualName SellerLastName SellerIndividualFullName SellerNonIndividualName, i(TransId) j(TransId_rank)
duplicates report TransId

ren SalesPriceAmount SalesPrice
*identify multiple parcel sale
*Same buyer name, and record date
duplicates report RecordingDate SalesPrice DataClassStndCode BuyerLastName1 BuyerIndividualFullName1 BuyerNonIndividualName1 BuyerLastName2 BuyerIndividualFullName2 BuyerNonIndividualName2
*Add seller name 
duplicates report RecordingDate SalesPrice DataClassStndCode /// 
BuyerLastName1 BuyerIndividualFullName1 BuyerNonIndividualName1 ///
BuyerLastName2 BuyerIndividualFullName2 BuyerNonIndividualName2 ///
SellerLastName1 SellerIndividualFullName1 SellerNonIndividualName1 ///
SellerLastName2 SellerIndividualFullName2 SellerNonIndividualName2

duplicates tag RecordingDate SalesPrice DataClassStndCode /// 
BuyerLastName1 BuyerIndividualFullName1 BuyerNonIndividualName1 ///
BuyerLastName2 BuyerIndividualFullName2 BuyerNonIndividualName2 ///
SellerLastName1 SellerIndividualFullName1 SellerNonIndividualName1 ///
SellerLastName2 SellerIndividualFullName2 SellerNonIndividualName2, gen(Mul_sale)

sort RecordingDate SalesPrice DataClassStndCode /// 
BuyerLastName1 BuyerIndividualFullName1 BuyerNonIndividualName1 ///
BuyerLastName2 BuyerIndividualFullName2 BuyerNonIndividualName2 ///
SellerLastName1 SellerIndividualFullName1 SellerNonIndividualName1 ///
SellerLastName2 SellerIndividualFullName2 SellerNonIndividualName2
*drop all identified multiple sales
drop if Mul_sale==1
/*restriction 6,848 dropped */
drop Mul_sale



*Generate indicator showing buyer seller having the same last name
gen BS_SameLast=1 if BuyerLastName1==SellerLastName1|BuyerLastName1==SellerLastName2|BuyerLastName2==SellerLastName1|BuyerLastName2==SellerLastName2
replace BS_SameLast=. if BuyerLastName1==""&SellerLastName1==""|BuyerLastName1==""&SellerLastName2==""|BuyerLastName2==""&SellerLastName1==""|BuyerLastName2==""&SellerLastName2==""
tab BS_SameLast
ren BS_SameLast BS_relation

*Generate indicator showing buyer and lender are the same group
gen LB_Same=1 if LenderName==BuyerNonIndividualName1&BuyerNonIndividualName1!=""|LenderName==BuyerNonIndividualName2&BuyerNonIndividualName2!=""
ren LB_Same LB_relation
duplicates drop TransId SalesPrice,force
/*restriction 0 dropped*/

tab LB_relation
tab BS_relation

*drop transactions with buyer seller or buyer lender relations
drop if BS_relation==1
/*restriction 24,443 dropped*/
drop if LB_relation==1
/*restriction 65 dropped*/

* now let's loop over common nonARMS terms in buyer and seller
gen nonARMS_termmark=.
foreach v of varlist BuyerLastName1 BuyerIndividualFullName1 BuyerNonIndividualName1 BuyerLastName2 BuyerIndividualFullName2 BuyerNonIndividualName2 SellerLastName1 SellerIndividualFullName1 SellerNonIndividualName1 SellerLastName2 SellerIndividualFullName2 SellerNonIndividualName2{

	replace nonARMS_termmark = 1 if strpos(`v', "SEC OF HOUSING & URBAN")>0 /* s bad*/
	replace nonARMS_termmark = 1 if strpos(`v', "BANK OF AMERICA")>0 /* s bad*/
	replace nonARMS_termmark = 1 if strpos(`v', "ET AL")>0  /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1  if strpos(`v', "VETERANS AFFAIRS")>0
	replace nonARMS_termmark = 1  if strpos(`v', "SECRETARY")>0
	replace nonARMS_termmark = 1 if strpos(`v', "SEC OF")>0
	replace nonARMS_termmark = 1 if strpos(`v', "HOUSING")>0
	replace nonARMS_termmark = 1 if strpos(`v', "NATIONAL")>0
	replace nonARMS_termmark = 1 if strpos(`v', "FEDERAL")>0
	replace nonARMS_termmark = 1 if strpos(`v', "MORTGAGE")>0
	replace nonARMS_termmark = 1 if strpos(`v', "LOAN")>0
	replace nonARMS_termmark = 1 if strpos(`v', "CAPITAL")>0 
	replace nonARMS_termmark = 1 if strpos(`v', "CAPITOL")>0
	replace nonARMS_termmark = 1 if strpos(`v', "FINANCE")>0 
	*gen nonARMS`f'_15 = 1 if strpos(`v', "UNITED")>0 /*b - almost all legit sales*/
	*gen nonARMS`f'_16 = 1 if strpos(`v', " INC")>0 /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', " LLC")>0 /*b - almost all legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', " CORP")>0 /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', " CORPORATION")>0 /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', " ASSOCIATION")>0
	replace nonARMS_termmark = 1 if strpos(`v', " COMPANY")>0
	*gen nonARMS`f'_23 = 1 if strpos(`v', "DEVELOPMENT")>0 /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', " F S B")>0
	replace nonARMS_termmark = 1 if strpos(`v', "REGIONAL OFFICE DIRECTOR")>0
	replace nonARMS_termmark = 1 if strpos(`v', " USA")>0
	replace nonARMS_termmark = 1 if strpos(`v', "HSBC")>0
	replace nonARMS_termmark = 1 if strpos(`v', "GUARANTY")>0
	*gen nonARMS`f'_29 = 1 if strpos(`v', "UNITED")>0 /*b - almost all legit sales*/
	*gen nonARMS`f'_30 = 1 if strpos(`v', "TRUST")>0 /*b - grabs alot of legit sales*/
	*gen nonARMS`f'_31 = 1 if strpos(`v', "TRUSTEE")>0  /*b - grabs alot of legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', "BANK OF")>0
	replace nonARMS_termmark = 1 if strpos(`v', "ST OF")>0
	replace nonARMS_termmark = 1 if strpos(`v', "STATE OF")>0
	replace nonARMS_termmark = 1 if strpos(`v', "MUTUAL")>0
	*gen nonARMS`f'_36 = 1 if strpos(`v', "C/O")>0 /*b - almost all legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', "(TR)")>0
	*gen nonARMS`f'_38 = 1 if strpos(`v', "LTD")>0 /*b - almost all legit sales*/
	replace nonARMS_termmark = 1 if strpos(`v', "CHEVY CHASE BANK")>0
	replace nonARMS_termmark = 1 if strpos(`v', " BANK")>0

}
mvencode nonARMS_termmark, mv(0) override
*drop transactions with participants with nonARMS terms 
drop if nonARMS_termmark==1
/*restriction 147,953 dropped*/

*drop transactions with prices that are too low, with indicator coded by towns
drop if SalesPrice<15000
/*restriction  40,794 dropped*/

*drop price outlier
sum SalesPrice,detail
drop if SalesPrice<=r(p1)|SalesPrice>=r(p99)
/*restriction 26,685 dropped */


gen TransactionYear=substr(RecordingDate,1,4)
destring TransactionYear,replace
tab TransactionYear
ren TransactionYear e_Year



count if e_Year>=2005
count if e_Year>=1994


tab SalesPriceAmountStndCode
drop if SalesPriceAmountStndCode=="NA"  /*NA is non ARMS*/
/*restriction  5,004 dropped*/
tab e_Year if ImportParcelID==.
gen ha_ImportParcelID=ImportParcelID
save "$dta\sales_nonarmsprocessed.dta",replace
*********************************************************************************
*      End process transaction data, processed non-armslength transactions      *
*********************************************************************************



