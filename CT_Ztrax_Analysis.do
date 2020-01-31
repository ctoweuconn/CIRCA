clear all
set more off
cap log close
set seed 123456789

*Change directories here
global root ""
global dta "$root\dta"
global dta0 "$root\dta"
global results "$root\"
global Zitrax ""   
global GISdata ""


*********************
*      Matching     *
********************* 
set more off
use "$dta0\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop

drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="EAST HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
drop if urban==1
*
tab SalesPriceAmountStndCode
*Now we have 81,981 prices, 75,811 are confirmed to be backed up by (closing) documents.


*lnPrice
gen Ln_Price=ln(SalesPrice)

tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice
drop if duptrans>=1 /*restriction 3,246 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

*drop possible house flipping events
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship period duptrans,force
capture drop duptrans neg_transprice

*Creating categorical Match variables 
*Use qualtiles and viewshed availability to devide bands
sum Dist_Coast if view_analysis==1,d
gen Band1=(Dist_Coast<=r(p50)&view_analysis==1)
gen Band2=(Dist_Coast>r(p50)&view_analysis==1)
gen Band3=(Band1==0&Band2==0)
gen Band=1 if Band1==1
replace Band=2 if Band2==1
replace Band=3 if Band3==1

gen SalewithLoan=(DataClassStndCode=="H")

*Block median income
drop if Block_MedInc==.
hist Block_MedInc
gen rich_neighbor=(Block_MedInc>=150000)
tab rich_neighbor

/*
gen Era=1 if e_Year<2002 /*pre-911 moving out from NYC*/
replace Era=2 if e_Year>=2002&e_Year<2008 /*pre-financial crisis*/
replace Era=3 if e_Year>=2008&e_Year<2013 /*Irene&Sandy*/
replace Era=4 if e_Year>=2013
tab Era
Matching on era is too coarse*/
egen town=group(LegalTownship)
drop if town==.
drop if fid_school==.
*CRS towns
gen CRS_town=1 if LegalTownship=="EAST LYME"|LegalTownship=="MILFORD"|LegalTownship=="STAMFORD"|LegalTownship=="STONINGTON"|LegalTownship=="WEST HARTFORD"|LegalTownship=="WESTPORT"
replace CRS_town=0 if CRS_town==.

*Check FIPS for each year
foreach y of numlist 1994/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Band rich_neighbor urban"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
tab SFHA

*Drop those cells with less than 2 treated or less than 4 controls (exact match and robust standard errors cannot apply)
gen I=1
egen N_torc=total(I), by($Match_cat SFHA)
gen N_t=N_torc if SFHA==1
gen N_c=N_torc if SFHA==0
egen CellN_t=mean(N_t),by($Match_cat)
egen CellN_c=mean(N_c),by($Match_cat)
drop I N_torc N_t N_c
replace CellN_t=0 if CellN_t==.
replace CellN_c=0 if CellN_c==.

count if CellN_t<2
gen os=(CellN_t<2|CellN_c<4)
tab os SFHA
drop if CellN_t<2|CellN_c<4
/*restriction 722 dropped */
*106 treated dropped here (do not have two treated in one cell or have less than 4 potentially paried controls)

*Simple NNMatching
capture drop nn*
capture drop os*
set seed 1234567
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) os(os1)
*identify those still cannot be exact-matched (having two treated in a cell but have fewer than 2 exact matches for some reason) 
replace os1=. if os1==0
tab os1
egen Cellos=mean(os1),by($Match_cat)
*12 treated dropped here, 294 total dropped
drop if Cellos==1

reg SalesPrice SFHA
eststo Mean_diff

duplicates report PropertyFullStreetAddress PropertyCity LegalTownship
di r(unique_value)
tab SFHA
duplicates report PropertyFullStreetAddress PropertyCity LegalTownship if SFHA==1
di r(unique_value)
*8641 treated, 6336 properties 
capture drop os2
capture drop nn*
set seed 1234567
teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo Matching_overall
tebalance summarize
mat list r(table)
/*Balance?  Post-matching, none of the normalized differences 
are greater than 0.15 standard deviations, which is below the suggested rule
 of thumb of 0.25 standard deviations (Rubin 2001; Imbens and Wooldridge 2009)
*/
duplicates report nn1 if SFHA==1&nn1!=.
di r(unique_value)
*8641/5521
/*
capture drop os2
capture drop nn*
*BCME
teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_overall
*/
capture drop os2
capture drop nn*
*BCME_Ln
teffects nnmatch (Ln_Price $Match_continue)(SFHA), tlevel(1) bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_overall

esttab Mean_diff Matching_overall BCME_Ln_overall using"$results\results_BCMEoverall.csv", keep(SFHA *.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*esttab Mean_diff Matching_overall BCME_overall BCME_Ln_overall using"$results\results_BCMEoverall.csv", keep(SFHA *.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

estat summarize 
gen ID=_n
capture drop _merge
save "$dta\data_analysis_tem.dta",replace


*Construct the matched sample
use "$dta\data_analysis_tem.dta",clear
keep if SFHA==1
keep nn1 
bysort nn1: gen weight=_N // count how many times each control observation is a match
by nn1: keep if _n==1 // keep just one row per control observation
ren nn1 ID //rename for merging purposes

capture drop _merge
merge 1:m ID using "$dta\data_analysis_tem.dta"
replace weight=1 if SFHA==1
drop _merge
tab weight
save "$dta\data_4analysis.dta",replace
*******************************************
*  End Generate Matched Sample (weights)  *
*******************************************




*****************************************
*      BCME for multiple estimates      *
*****************************************
set more off
use "$dta\data_analysis_tem.dta",clear

*BCME
global Match_cat "e_Year Band rich_neighbor urban"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat)
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*6639/4277
/*
capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_H
*/
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_H


set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat)
* treated dropped here,  total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*2002/1290
/*
capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_D
*/
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_D

esttab BCME_Ln_H BCME_Ln_D using"$results\results_BCMEHandD.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))




**********************************************************
*      BCME without properties in sandy/irene surges     *
**********************************************************
set more off
clear all
set maxvar 30000
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Band rich_neighbor urban"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

tab SFHA if Sandysurge_feet>0|Irenesurge_feet>0
drop if Sandysurge_feet>0|Irenesurge_feet>0
gen I=1
egen N_torc=total(I), by($Match_cat SFHA)
gen N_t=N_torc if SFHA==1
gen N_c=N_torc if SFHA==0
capture drop CellN_t 
capture drop CellN_c
egen CellN_t=mean(N_t),by($Match_cat)
egen CellN_c=mean(N_c),by($Match_cat)
drop I N_torc N_t N_c

replace CellN_t=0 if CellN_t==.
replace CellN_c=0 if CellN_c==.

count if CellN_t<2
gen os=(CellN_t<2|CellN_c<4)
tab os SFHA
drop if CellN_t<2|CellN_c<4
*24 treated dropped here, 352 dropped in total

*All transactions
capture drop nn*
capture drop os*
set seed 1234567
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) os(os1)
*identify those still cannot be exact-matched (having two treated in a cell but have fewer than 2 exact matches for some reason) 
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat)
*20 treated dropped here, 305 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
set seed 1234567
teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo Matching_overall
tebalance summarize
mat list r(table)
duplicates report nn1 if SFHA==1&nn1!=.
di r(unique_value)
*4649/3686
capture drop os2
capture drop nn*
*BCME_Ln
teffects nnmatch (Ln_Price $Match_continue)(SFHA), tlevel(1) bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_nosurge

*With Loan 
global Match_cat "e_Year Band rich_neighbor"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
capture drop Cellos
egen Cellos=mean(os1),by($Match_cat)
*No drop here
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*3580/2860
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_H_nosurge

*Without loan
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
capture drop Cellos
egen Cellos=mean(os1),by($Match_cat)
*no drop here
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*1069/847
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_D_nosurge

esttab BCME_Ln_nosurge BCME_Ln_H_nosurge BCME_Ln_D_nosurge using"$results\results_BCMEnosurge.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))



*********************************************
*      BCME for different neighborhood      *
*********************************************
set more off
use "$dta0\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop

drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="EAST HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
drop if urban==1
*
tab SalesPriceAmountStndCode
*Now we have 89,000 prices, 82,459 are confirmed to be backed up by (closing) documents.

*lnPrice
gen Ln_Price=ln(SalesPrice)
tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice
drop if duptrans>=1 /*restriction 3,246 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

*drop possible house flipping events
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship period duptrans,force
capture drop duptrans neg_transprice

*Creating categorical Match variables 
*Use qualtiles and viewshed availability to devide bands
sum Dist_Coast if view_analysis==1,d
gen Band1=(Dist_Coast<=r(p50)&view_analysis==1)
gen Band2=(Dist_Coast>r(p50)&view_analysis==1)
gen Band3=(Band1==0&Band2==0)
gen Band=1 if Band1==1
replace Band=2 if Band2==1
replace Band=3 if Band3==1

gen SalewithLoan=(DataClassStndCode=="H")

*Block median income
drop if Block_MedInc==.
hist Block_MedInc
gen lowInc_neighbor=(Block_MedInc<=70000)
gen normInc_neighbor=(Block_MedInc>70000&Block_MedInc<150000)
gen rich_neighbor=(Block_MedInc>=150000)
tab rich_neighbor
gen neighbor_cat=0 if lowInc_neighbor==1
replace neighbor_cat=1 if normInc_neighbor==1
replace neighbor_cat=2 if rich_neighbor==1
tab neighbor_cat

egen town=group(LegalTownship)
drop if town==.
drop if fid_school==.
*CRS towns
gen CRS_town=1 if LegalTownship=="EAST LYME"|LegalTownship=="MILFORD"|LegalTownship=="STAMFORD"|LegalTownship=="STONINGTON"|LegalTownship=="WEST HARTFORD"|LegalTownship=="WESTPORT"
replace CRS_town=0 if CRS_town==.

*Check FIPS for each year
foreach y of numlist 1994/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Band neighbor_cat urban"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
tab SFHA

*Drop those cells with less than 2 treated or less than 4 controls (exact match and robust standard errors cannot apply)
gen I=1
egen N_torc=total(I), by($Match_cat SFHA)
gen N_t=N_torc if SFHA==1
gen N_c=N_torc if SFHA==0
egen CellN_t=mean(N_t),by($Match_cat)
egen CellN_c=mean(N_c),by($Match_cat)
drop I N_torc N_t N_c
replace CellN_t=0 if CellN_t==.
replace CellN_c=0 if CellN_c==.

count if CellN_t<2
gen os=(CellN_t<2|CellN_c<4)
tab os SFHA
drop if CellN_t<2|CellN_c<4
*117 treated dropped, 1230 dropped in total


*use 70000 as low income criterion
*BCME
*Low Inc neighbor
global Match_cat "e_Year Band urban"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*2 treated dropped here, 21 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*1816/1016
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnH_lowInc

set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*12 treated dropped here, 213 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*550/310
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_lowInc


*Normal Inc neighbor
global Match_cat "e_Year Band urban"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*4 treated dropped here, 265 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*3839/2675
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnH_normInc


set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*2 treated dropped here, 84 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*1255/867
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_normInc


*High Inc neighbor
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==2, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*2 treated dropped here, 11 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*971/564
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnH_HighInc


set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==2, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*10 treated dropped here, 283 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*179/90
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fips) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_HighInc

esttab BCME_LnH_lowInc BCME_LnH_normInc BCME_LnH_HighInc BCME_LnD_lowInc BCME_LnD_normInc BCME_LnD_HighInc using"$results\results_BCME_neighborInc.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
cap sum $View1 $View2
*fldzone
global FRisk "SFHA BFE post_FIRM Sandysurge_feet Irenesurge_feet"
global StndX "e_LnSQFT e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_NoOfBuildings e_TotalCalculatedBathCount  e_GarageNoOfCars e_Pool e_FireplaceNumber AirCondition e_TotalBedrooms e_TotalRooms e_NoOfStories BuildingCondition HeatingType"
global Geo "Coastfront1 e_Elev_dev e_Elev_devsq Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev fid_school sewer_service"

global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.AirCondition i.SalesYear i.SalesMonth i.FIPS i.fid_school"

*Set graphic scheme
set scheme sj,perm
**********************
* Summary Statistics *
**********************
set more off
use "$dta\data_4analysis.dta",clear

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.
global X "Waterfront_ocean Waterfront_river Waterfront_street  e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_TotalCalculatedBathCount  e_GarageNoOfCars e_Pool e_FireplaceNumber e_TotalBedrooms e_NoOfStories Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev"

foreach v in $View1 rich_neighbor $FRisk $X $FE {
sum `v'
}
duplicates report PropertyFullStreetAddress PropertyCity LegalTownship period

global X "Waterfront_ocean Waterfront_river Waterfront_street  e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_Elevation sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Ag ratio_Dev ratio_Fore ratio_Open"

*Haven't processed structure elevation yet
eststo House_all: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  
eststo House_treat: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  if SFHA==1
eststo House_control: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  if SFHA==0
esttab House_* using "$results/Summary_sample.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")

eststo House_all: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  [aweight=weight] 
eststo House_treat: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  [aweight=weight] if SFHA==1
eststo House_control: estpost sum SalesPrice $FRisk rich_neighbor $View2 $X  [aweight=weight] if SFHA==0
esttab House_* using "$results/Summary_matched.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")
*N exported is sum of weights. 

tab fldzone,sum(SalesPrice)
eststo Price_all: estpost sum SalesPrice
eststo Price_Nfz: estpost sum SalesPrice if fldzone==""
eststo Price_A: estpost sum SalesPrice if fldzone=="A"
eststo Price_AE: estpost sum SalesPrice if fldzone=="AE"
eststo Price_VE: estpost sum SalesPrice if fldzone=="VE"
esttab Price_* using "$results/Summaryprice.csv", replace cells("mean(fmt(3))" "sd(fmt(3) par)")

tab SFHA, sum(e_BuildingAge)
tab SFHA, sum(SalesPrice)
tab SFHA if weight!=.

tab LegalTownship, sum(SalesPrice)
tab LegalTownship DataClassStndCode

eststo SalesbyYear: estpost tab e_Year
esttab SalesbyYear using"$results\SalesbyYear.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

//Preliminary Analysis
set more off
set matsize 11000
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
duplicates report PID
di r(unique_value)
tab SFHA
duplicates report PID if SFHA==1
di r(unique_value)

xtset PID period

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.AirCondition i.SalesYear i.SalesMonth i.FIPS"

*simple regression
eststo OLS: reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period i.fid_school#i.period, cluster(ImportParcelID)
eststo OLS_Ln: reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.fid_school#i.period, cluster(ImportParcelID)
tab SFHA
esttab OLS OLS_Ln using"$results\results_SFHA_OLS.csv", keep(SFHA $View2 e_LnSQFT e_LnSQFT_tot e_LnLSQFT $X) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*Prices by coastal town
clear all
set more off
use "$dta\data_4analysis.dta",clear
*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.

set more off
foreach t in "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
eststo: estpost sum SalesPrice if LegalTownship=="`t'"
}
eststo: estpost sum SalesPrice
esttab using "$results/Summary_townprice.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")
eststo clear

set more off
foreach t in "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
eststo: estpost tab SalewithLoan if LegalTownship=="`t'"
}
eststo: estpost tab SalewithLoan
esttab using"$results\bytown.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
eststo clear
*************************
* Main Analysis-Hedonic *
*************************
set more off
use "$dta\data_4analysis.dta",clear

ren e_Elevation Elevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren e_SQFT_liv SquareFootage
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit
ren Dist_freeway DistancetoHighway
ren Dist_NWaterbody DistancetoWaterbody
ren Dist_NRailroad DistancetoRailroad
ren Dist_beach_near1 DistancetoPublicBeach

foreach v in Elevation LISViewarea LISViewangle SquareFootage Dist_I95_NYC DistancetoCoast DistancetoPublicBeach DistancetoHighwayExit  DistancetoHighway DistancetoRailroad{
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA==1
gen `v'_0=`v' if SFHA==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' pre-match) msize(vsmall)
graph save "$results\\`v'_qqplot.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\Elevation_qqplot.gph" "$results\LISViewarea_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\DistancetoCoast_qqplot.gph" "$results\DistancetoHighwayExit_qqplot.gph", saving("$results\qqplot_pre.gph",replace)

set more off
use "$dta\data_4analysis.dta",clear

drop if weight==.
keep weight SFHA e_Elevation Lisview_area total_viewangle e_SQFT_liv Dist_I95_NYC Dist_Coast Dist_exit_near1 Dist_freeway Dist_NWaterbody Dist_NRailroad Dist_beach_near1
ren e_Elevation Elevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren e_SQFT_liv SquareFootage
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit
ren Dist_freeway DistancetoHighway
ren Dist_NWaterbody DistancetoWaterbody
ren Dist_NRailroad DistancetoRailroad
ren Dist_beach_near1 DistancetoPublicBeach

expand weight
foreach v in Elevation LISViewarea LISViewangle SquareFootage Dist_I95_NYC DistancetoCoast DistancetoPublicBeach DistancetoHighwayExit  DistancetoHighway DistancetoRailroad  {
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA==1
gen `v'_0=`v' if SFHA==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' post-match) msize(vsmall)
graph save "$results\\`v'_qqplot1.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\Elevation_qqplot1.gph" "$results\LISViewarea_qqplot1.gph" "$results\LISViewangle_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\DistancetoCoast_qqplot1.gph" "$results\DistancetoHighwayExit_qqplot1.gph", saving("$results\qqplot_post.gph",replace)
gr combine "$results\Elevation_qqplot.gph" "$results\LISViewarea_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\DistancetoCoast_qqplot.gph" "$results\Elevation_qqplot1.gph" "$results\LISViewarea_qqplot1.gph" "$results\LISViewangle_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\DistancetoCoast_qqplot1.gph", saving("$results\qqplot_compare.gph",replace) rows(2) altshrink




*fixed effects model
*year by qt + tract by y + SFHA by year
*Trend
set more off
clear all
set maxvar 30000
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.
tab SFHA

global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"

global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

*With different sets of fixed effects and specification
set more off
eststo RA_ln_noperiod:   reg Ln_Price SFHA $View2 $X $FE i.fid_school [pweight=weight],cluster(PID)
eststo RA_ln_withperiod: reg Ln_Price SFHA $View2 $X $FE i.fid_school i.period [pweight=weight],cluster(PID)
eststo RA_ln_withall:    reg Ln_Price SFHA $View2 $X $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
*Same-with lnSQFTs
set more off
eststo RA_ln_noperiodM:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school [pweight=weight],cluster(PID)
eststo RA_ln_withperiodM:reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period [pweight=weight],cluster(PID)
eststo RA_ln_withallM:   reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)

set more off
eststo RA_l_noperiod:   reg SalesPrice SFHA $View2 $X $FE i.fid_school [pweight=weight],cluster(PID)
eststo RA_l_withperiod: reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period [pweight=weight],cluster(PID)
eststo RA_l_withall:    reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)

set more off
eststo RA_l_noperiodM:   reg SalesPrice SFHA $View2 $X1 $FE i.fid_school [pweight=weight],cluster(PID)
eststo RA_l_withperiodM: reg SalesPrice SFHA $View2 $X1 $FE i.fid_school i.period [pweight=weight],cluster(PID)
eststo RA_l_withallM:    reg SalesPrice SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)

esttab RA_ln_noperiod RA_ln_withperiod RA_ln_withall RA_ln_noperiodM RA_ln_withperiodM RA_ln_withallM RA_l_noperiod RA_l_withperiod RA_l_withall RA_l_noperiodM RA_l_withperiodM RA_l_withallM using"$results\results_SFHA_RA1.csv", keep(SFHA $View2 e_LnSQFT e_LnSQFT_tot e_LnLSQFT $X) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*RA1-Specification check_table4-0


*preIrene - if period<71 postSandy - if period>76

*Differentiate transactions with and without loans
set more off
eststo RA_ln_noperiod_H:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)
eststo RA_ln_withperiod_H:reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period [pweight=weight] if DataClassStndCode=="H",cluster(PID)
eststo RA_ln_withall_H:   reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)

set more off
eststo RA_ln_noperiod_D:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)
eststo RA_ln_withperiod_D:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period [pweight=weight] if DataClassStndCode=="D",cluster(PID)
eststo RA_ln_withall_D:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)
esttab RA_ln_noperiod_H RA_ln_withperiod_H RA_ln_withall_H RA_ln_noperiod_D RA_ln_withperiod_D RA_ln_withall_D using"$results\results_SFHA_RA2.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Differentiate transactions with and without loans_linear price
set more off
eststo RA_l_noperiod_H:  reg SalesPrice SFHA $View2 $X $FE i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)
eststo RA_l_withperiod_H:reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period [pweight=weight] if DataClassStndCode=="H",cluster(PID)
eststo RA_l_withall_H:   reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)

set more off
eststo RA_l_noperiod_D:  reg SalesPrice SFHA $View2 $X $FE i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)
eststo RA_l_withperiod_D:  reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period [pweight=weight] if DataClassStndCode=="D",cluster(PID)
eststo RA_l_withall_D:  reg SalesPrice SFHA $View2 $X $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)

esttab RA_l_noperiod_H RA_l_withperiod_H RA_l_withall_H RA_l_noperiod_D RA_l_withperiod_D RA_l_withall_D using"$results\results_SFHA_RA2_L.csv", keep(SFHA $View2 $X) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*RA2-break up by with loan or not_table4-1
/*
set more off
eststo RA_ln_withall_DID_DH:  reg Ln_Price SFHA SalewithLoan 1.SalewithLoan#1.SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
eststo RA_l_withall_DID_DH:  reg SalesPrice SFHA SalewithLoan 1.SalewithLoan#1.SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
esttab RA_ln_withall_DID_DH RA_l_withall_DID_DH using"$results\results_SFHA_RA2_DID.csv", keep(SFHA SalewithLoan *.SalewithLoan#*.SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*/

*Differentiate transactions preIrene postSandy
set more off
eststo RA_ln_preIrene:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school  [pweight=weight] if period<71,cluster(PID)
eststo RA_ln_postSandy:reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if period>76,cluster(PID)

eststo RA_ln_preIreneH:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school  [pweight=weight] if period<71&DataClassStndCode=="H",cluster(PID)
eststo RA_ln_postSandyH:reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school  [pweight=weight] if period>76&DataClassStndCode=="H",cluster(PID)

eststo RA_ln_preIreneD:  reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school  [pweight=weight] if period<71&DataClassStndCode=="D",cluster(PID)
eststo RA_ln_postSandyD:reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school  [pweight=weight] if period>76&DataClassStndCode=="D",cluster(PID)

esttab RA_ln_preIrene RA_ln_postSandy RA_ln_preIreneH RA_ln_postSandyH RA_ln_preIreneD RA_ln_postSandyD using"$results\results_SFHA_RA3.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*Year Trend of SFHA effect 
set more off
eststo RA_ln_trend: reg Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year i.period i.fid_school i.period#i.fid_school [pweight=weight],cluster(PID)
esttab RA_ln_trend using"$results\results_yeartrend.csv", keep(*.e_Year#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_trend, saving("$results\SFHA_yeartrend.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

*Year Trend of SFHA effect for transactions with loan
set more off
eststo RA_ln_trend_wloan: reg Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year i.period i.fid_school i.period#i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)

coefplot RA_ln_trend_wloan, saving("$results\SFHA_yeartrendwloan.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

*Year Trend of SFHA effect for transactions without loan
set more off
eststo RA_ln_trend_woloan: reg Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year i.period i.fid_school i.period#i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)

coefplot RA_ln_trend_woloan, saving("$results\SFHA_yeartrendwoloan.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) ylabel(-.6(.2).6) ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

tab e_Year if DataClassStndCode=="D"&SFHA==1

*Coastal proxy heterogeneity
set more off
eststo RA_ln_proxytrend: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
esttab RA_ln_proxytrend using"$results\results_proxytrend_BandM.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrend, saving("$results\SFHA_proxytrend_BandM.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"q0toq10(0to733ft)" 2"q10toq20(733to1737ft)" 3"q20toq30(1737to3104ft)" 4"q30toq40(3104to4679ft)" 5"q40toq50(4679ft/.89mito1.22mi)" 6"q50toq60(1.22to1.57mi)" 7"q60toq70(1.57to2.00mi)" 8"q70toq80(2.00to2.56mi)" 9"q80toq90(2.56to3.45mi)" 10"q90toq100(above3.45mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
*As it goes further from the coast, the analysis becomes less and less accurate, since the SFHA will be more related to rivers and we don't calculate river view. 
*But, even with this understandable bias, we can still tell there's a sorting process-people caring little about the flood risk tend to live close to the coast.
 
set more off
eststo RA_ln_proxytrendwloan: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)
esttab RA_ln_proxytrendwloan using"$results\results_proxytrendwloan_BandM.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwloan, saving("$results\SFHA_proxytrendwloan_BandM.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"q0toq10(0to733ft)" 2"q10toq20(733to1737ft)" 3"q20toq30(1737to3104ft)" 4"q30toq40(3104to4679ft)" 5"q40toq50(4679ft/.89mito1.22mi)" 6"q50toq60(1.22to1.57mi)" 7"q60toq70(1.57to2.00mi)" 8"q70toq80(2.00to2.56mi)" 9"q80toq90(2.56to3.45mi)" 10"q90toq100(above3.45mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

set more off
eststo RA_ln_proxytrendwoloan: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)
esttab RA_ln_proxytrendwoloan using"$results\results_proxytrendwoloan_BandM.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwoloan, saving("$results\SFHA_proxytrendwoloan_BandM.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"q0toq10(0to733ft)" 2"q10toq20(733to1737ft)" 3"q20toq30(1737to3104ft)" 4"q30toq40(3104to4679ft)" 5"q40toq50(4679ft/.89mito1.22mi)" 6"q50toq60(1.22to1.57mi)" 7"q60toq70(1.57to2.00mi)" 8"q70toq80(2.00to2.56mi)" 9"q80toq90(2.56to3.45mi)" 10"q90toq100(above3.45mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


*Quantile regression with full example (heterogenous flood zone effect and viewshed effects on property value)
set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_ln_all_Q`num',ti("Q(`q')"): qreg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight],vce(robust) quantile(`q')
}
eststo RA_ln_all_Q_OLS: reg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight],vce(robust)
esttab RA_ln_all_Q* using"$results\results_qreg.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_l_all_Q*
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_l_all_Q`num',ti("Q(`q')"): qreg SalesPrice SFHA $View2 $X1 $FE i.fid_school  i.period [pweight=weight],vce(robust) quantile(`q')
}
eststo RA_l_all_Q_OLS: reg SalesPrice SFHA $View2 $X1 $FE i.fid_school  i.period [pweight=weight],vce(robust)

esttab RA_l_all_Q* using"$results\results_qreg_L.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*With Loan - heterogeneity risk perception vs. relatively uniformly capitalization of insurance cost
set more off
eststo drop RA_l_all_Q*
* 
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_l_loan_Q`num',ti("Q(`q')"): qreg SalesPrice SFHA $View2 $X1 $FE i.fid_school  i.period [pweight=weight] if DataClassStndCode=="H", vce(robust) quantile(`q') wlsiter(2)
}
eststo RA_l_loan_Q_OLS: reg SalesPrice SFHA $View2 $X1 $FE i.fid_school  i.period [pweight=weight] if DataClassStndCode=="H",vce(robust)
esttab RA_l_loan_Q* using"$results\results_qreg_loanL.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_ln_loan_Q`num',ti("Q(`q')"): qreg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight] if DataClassStndCode=="H", vce(robust) quantile(`q') wlsiter(2)
}
eststo RA_ln_loan_Q_OLS: reg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight] if DataClassStndCode=="H",vce(robust)
esttab RA_ln_loan_Q* using"$results\results_qreg_loanln.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*heterogeneity risk perception with no loan
set more off
eststo drop RA_l_all_Q*
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_l_noloan_Q`num',ti("Q(`q')"): qreg SalesPrice SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight] if DataClassStndCode=="D", vce(robust) quantile(`q')
}
eststo RA_l_noloan_Q_OLS: reg SalesPrice SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight] if DataClassStndCode=="D",vce(robust)
esttab RA_l_noloan_Q_OLS using"$results\results_qreg_noloanLOLS.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
esttab RA_l_noloan_Q* using"$results\results_qreg_noloanL1.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .25 .5 .75 .9{
local num=100*`q'
eststo RA_ln_noloan_Q`num',ti("Q(`q')"): qreg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period  [pweight=weight] if DataClassStndCode=="D", vce(robust) quantile(`q')
}
eststo RA_ln_noloan_Q_OLS: reg Ln_Price SFHA $View2 $X1 $FE  i.fid_school  i.period [pweight=weight] if DataClassStndCode=="D",vce(robust)
esttab RA_ln_noloan_Q* using"$results\results_qreg_noloanln1.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
esttab RA_ln_noloan_Q_OLS using"$results\results_qreg_noloanlnOLS.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*What if we build in a insurance cost variable?
/*gen NFIPcost=1 if SFHA_Dfirm==1&DataClassStndCode=="H"
replace NFIPcost=0 if NFIPcost==.

set more off
eststo RA_ln_0toquarter_All_Icost:   reg Ln_Price SFHA_Dfirm NFIPcost $X2_M $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if Band1==1,cluster(ImportParcelID)
eststo RA_ln_quartertoone_Icost:   reg Ln_Price SFHA_Dfirm NFIPcost $X2_M $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if Band1==0,cluster(ImportParcelID)
*Cannot use a simple linear regression to recover this
*1. functional form is highly nonlinear
*2. prices with mortgage are inherently higher (more about bargaining process)
*/

sum SalesPrice [aweight=weight] if DataClassStndCode=="H"

*Different Flood zones
egen floodzone=group(fld_zone)
replace floodzone=0 if floodzone==.
set more off
eststo RA_ln_fldzones:  reg Ln_Price i.floodzone $X2 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(ImportParcelID)

*Sandy surge
set more off
eststo RA_Sandysurge: reg Ln_Price i.Sandysurge_feet $X2 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(ImportParcelID)
*eststo OLS_Sandysurge:reg Ln_Price i.Sandysurge_feet $X2 $FE i.fid_school,cluster(ImportParcelID)
set more off
eststo RA_surgeandDfirm: reg Ln_Price SFHA_Dfirm i.Sandysurge_feet $X2 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(ImportParcelID)

*BFE
set more off
*eststo RA_ln_bfe:  reg Ln_Price i.static_bfe $X2 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(ImportParcelID)

esttab RA_Sandysurge RA_ln_fldzones using"$results\results_Otherfactors.csv", keep(*.Sandysurge_feet *.floodzone $X2) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
esttab RA_surgeandDfirm using"$results\results_SandySandDfirm.csv", keep(SFHA_Dfirm *.Sandysurge_feet $X2) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_Sandysurge, saving("$results\Sandysurge_discount.gph",replace)  vertical keep(*.Sandysurge_feet) levels(90) recast(con) xlabel(,angle(45)) m(D) msize(small) mfcolor(white) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))



*******************************************
*  Re-matching with ematch on mile-buffer *
*******************************************
*Investigate more on the conclusion of J&M2019
*Detailed sorting-based-on-coastal-proxy 
set more off

use "$dta\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="EAST HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
drop if urban==1
tab SalesPriceAmountStndCode
*Now we have 116,221 prices, 107,703 are confirmed to be backed up by (closing) documents.

*lnPrice
gen Ln_Price=ln(SalesPrice)

tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice
drop if duptrans>=1 /*restriction 3,246 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

*drop possible house flipping events
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship period duptrans,force
capture drop duptrans neg_transprice

gen rich_neighbor=(Block_MedInc>=150000)
tab rich_neighbor

*Creating categorical Match variables 
*Use qualtiles and viewshed availability to devide bands
sum Dist_Coast if view_analysis==1,d
gen Band1=(Dist_Coast<=r(p50)&view_analysis==1)
gen Band2=(Dist_Coast>r(p50)&view_analysis==1)
gen Band3=(Band1==0&Band2==0)
gen Band=1 if Band1==1
replace Band=2 if Band2==1
replace Band=3 if Band3==1

gen SalewithLoan=(DataClassStndCode=="H")
/*
gen Era=1 if e_Year<2002 /*pre-911 moving out from NYC*/
replace Era=2 if e_Year>=2002&e_Year<2008 /*pre-financial crisis*/
replace Era=3 if e_Year>=2008&e_Year<2013 /*Irene&Sandy*/
replace Era=4 if e_Year>=2013
tab Era
Matching on era is too coarse*/
egen town=group(LegalTownship)
drop if town==.
drop if fid_school==.

*Check FIPS for each year
foreach y of numlist 1994/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Buffer_Coast rich_neighbor urban"
*Exact match on quantile buffers
*Due to the curse of dimension, cannot require exact match on all possible variables.

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

capture drop nn*
capture drop os*
set seed 1234567
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) os(os1)
tab SFHA os1
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat)
*16 treated dropped here, 115 total dropped
drop if Cellos==1


capture drop os2
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if os1!=1, tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) vce(iid) os(os2)
tebalance summarize
duplicates report nn1 if nn1!=.
di r(unique_value) /*6623*/

*0 SFHA property (treated) have no exact match
estat summarize 
gen ID=_n
capture drop _merge
save "$dta\data_analysis_tem1.dta",replace


use "$dta\data_analysis_tem1.dta",clear
*BCME with finer buffers
global Match_cat "e_Year SalewithLoan Buffer_Coast rich_neighbor urban"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set seed 1234567
capture drop nn*
capture drop os2
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if os1!=1, tlevel(1) ematch($Match_cat) bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet nn(1) gen(nn) vce(iid) os(os2)
eststo BCME_Buffer_all

global Match_cat "e_Year Buffer_Coast rich_neighbor"
capture drop os1
capture drop nn*
capture teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
tab SFHA os1
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan)
* treated dropped here,  total dropped
drop if Cellos==1
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1, tlevel(1) ematch($Match_cat)  bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet vce(iid) nn(1) gen(nn) os(os2)
eststo BCME_Buffer_H

capture drop os1
capture drop nn*
capture teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
tab SFHA os1
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan)
* treated dropped here,  total dropped
drop if Cellos==1
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet vce(iid) nn(1) gen(nn) os(os2)
eststo BCME_Buffer_D

esttab BCME_Buffer_all BCME_Buffer_H BCME_Buffer_D using"$results\results_BCMEBuffer_HandD.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Construct the matched sample
use "$dta\data_analysis_tem1.dta",clear
keep if SFHA==1
keep nn1 
bysort nn1: gen weight=_N // count how many times each control observation is a match
by nn1: keep if _n==1 // keep just one row per control observation
ren nn1 ID //rename for merging purposes

capture drop _merge
merge 1:m ID using "$dta\data_analysis_tem1.dta"
replace weight=1 if SFHA==1
drop _merge
tab weight
save "$dta\data_4proxytrend.dta",replace


set more off
clear all
set maxvar 30000
use "$dta\data_4proxytrend.dta",clear
set matsize 11000
set emptycells drop

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.

global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"

global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

sum Dist_Coast if view_analysis==1,d
sum Dist_Coast if major_view==1,d

set more off
eststo RA_ln_proxytrend: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
esttab RA_ln_proxytrend using"$results\results_proxytrend.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrend, saving("$results\SFHA_proxytrend.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to686ft)" 2"Q10toQ20(686to1608ft)" 3"Q20toQ30(1608to2900ft)" 4"Q30toQ40(2900to4472ft)" 5"Q40toQ50(4472ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
*As it goes further from the coast, the analysis becomes less and less accurate, since the SFHA will be more related to rivers and we don't calculate river view. 
*But, even with this understandable bias, we can still tell there's a sorting process-people caring little about the flood risk tend to live close to the coast.
* 
set more off
eststo RA_ln_proxytrendwloan: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="H",cluster(PID)
esttab RA_ln_proxytrendwloan using"$results\results_proxytrendwloan.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwloan, saving("$results\SFHA_proxytrendwloan.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to686ft)" 2"Q10toQ20(686to1608ft)" 3"Q20toQ30(1608to2900ft)" 4"Q30toQ40(2900to4472ft)" 5"Q40toQ50(4472ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
/*
10th percentile-732.55164 to 20th percentile-1736.8153

20th percentile-1736.8153 to 30th percentile-3103.678

30th percentile-3103.678 to 40th percentile-4679.2998

40th percentile-4679.2998 to 50th percentile-6434.9932

50th percentile-6434.9932 to 60th percentile-8293.918

60th percentile-8293.918 to 70th percentile-10565.83

70th percentile-10565.83 to 80th percentile-13536.546

80th percentile-13536.546 to 90th percentile-18230.719

90th percentile-18230.719 to 100th percentile-.
*/
set more off
eststo RA_ln_proxytrendwoloan: reg Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if DataClassStndCode=="D",cluster(PID)
esttab RA_ln_proxytrendwoloan using"$results\results_proxytrendwoloan.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwoloan, saving("$results\SFHA_proxytrendwoloan.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to686ft)" 2"Q10toQ20(686to1608ft)" 3"Q20toQ30(1608to2900ft)" 4"Q30toQ40(2900to4472ft)" 5"Q40toQ50(4472ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood Zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


*Check whether the previous results are replicable here - Yes
set more off
eststo RA_ln_MBuffer_B12: reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if view_analysis==1,cluster(PID)
eststo RA_ln_MBuffer_B12H: reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if view_analysis==1&SalewithLoan==1,cluster(PID)
eststo RA_ln_MBuffer_B3: reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight] if view_analysis==0,cluster(PID)
eststo RA_ln_MBuffer: reg Ln_Price SFHA $View2 $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)

esttab RA_ln_MBuffer_B12 RA_ln_MBuffer_B12H RA_ln_MBuffer_B3 RA_ln_MBuffer using"$results\results_MBuffer_B12.csv", keep(SFHA $View2 $X1) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


