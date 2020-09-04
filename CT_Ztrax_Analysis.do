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


* install package here
ssc install reghdfe
ssc install ftools
*********************
*      Matching     *
********************* 
set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop

drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="NEW HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
*

*lnPrice
gen Ln_Price=ln(SalesPrice)
tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
gen neg_transprice=-SalesPrice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate, gen(dupsale)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year RecordingDate neg_transprice *
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate,force
/*restriction 6925 duplicate records dropped*/

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice *
drop if duptrans>=1 /*restriction 396 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans dupsale neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year *
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

tab SalesPriceAmountStndCode
*Now we have 88,152 prices, 84,173 are confirmed to be backed up by (closing) documents.

*Drop observations before 1998 (only three towns, GIS data maybe inaccurate for older sales)
drop if e_Year<1998
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1998)+Quarter

*drop possible house flipping events (within the same season)
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
drop if duptrans>=1 /*restriction 328 dup transactions within the same season drops, likely including house flippers*/
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
egen Tract=group(tractce)
*219 tracts
egen Block=group(tractce blkgrpce)
*CRS towns
gen CRS_town=1 if LegalTownship=="EAST LYME"|LegalTownship=="MILFORD"|LegalTownship=="STAMFORD"|LegalTownship=="STONINGTON"|LegalTownship=="WEST HARTFORD"|LegalTownship=="WESTPORT"
replace CRS_town=0 if CRS_town==.

*Check FIPS for each year
foreach y of numlist 1998/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*Dropping since very few sales are in middlesex county before 2000
drop if FIPS==9007&e_Year<=2000

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
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
/*restriction 1318 dropped */
*125 treated dropped here (do not have two treated in one cell or have less than 4 potentially paried controls)

*Simple NNMatching
capture drop nn*
capture drop os*
set seed 1234567
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) os(os1)
*identify those still cannot be exact-matched (having two treated in a cell but have fewer than 2 exact matches for some reason) 
replace os1=. if os1==0
tab os1
egen Cellos=mean(os1),by($Match_cat)
*40 treated dropped here, 772 total dropped
drop if Cellos==1

reg SalesPrice SFHA
eststo Mean_diff

duplicates report PropertyFullStreetAddress PropertyCity LegalTownship
di r(unique_value)
*90,652 transactions - 65508 properties

tab SFHA
duplicates report PropertyFullStreetAddress PropertyCity LegalTownship if SFHA==1
di r(unique_value)
*9,623 SFHA transactions - 7040 properties

capture drop os2
capture drop nn*
set seed 1234567
teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo Matching_overall
tebalance summarize
mat list r(table)
/*Balance?  Post-matching, none of the normalized dif
ferences are greater than 0.15 standard deviations, which is below the suggested rule
 of thumb of 0.25 standard deviations (Rubin 2001; Imbens and Wooldridge 2009)
*/
duplicates report nn1 if SFHA==1&nn1!=.
di r(unique_value)
*9623/6104 -6103

capture drop os2
capture drop nn*
*BCME_Ln
teffects nnmatch (Ln_Price $Match_continue)(SFHA), tlevel(1) bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_overall
*-.0274757   .0074615    -3.68   0.000    -.0421001   -.0128514
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
*gen pweight
gen weight_inv=210/weight
save "$dta\data_4analysis.dta",replace
*******************************************
*  End Generate Matched Sample (weights)  *
*******************************************

*****************************************
*    BCME for by-mortgage estimates     *
*****************************************
set more off
use "$dta\data_analysis_tem.dta",clear
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
*BCME
global Match_cat "e_Year Band rich_neighbor urban"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan)
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
* 7482/4806
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

set more off
use "$dta\data_analysis_tem.dta",clear
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan)
* treated dropped here,  total dropped
drop if Cellos==1

set seed 123456789
capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
* 2136/1402
/*
capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_D
*/
set seed 123456789
sort *
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_D

esttab BCME_Ln_H BCME_Ln_D using"$results\results_BCMEHandD.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

**********************************************************
*      BCME without properties in sandy/irene surges     *
**********************************************************
set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop

drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="NEW HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
*
tab SalesPriceAmountStndCode

*lnPrice
gen Ln_Price=ln(SalesPrice)
tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
gen neg_transprice=-SalesPrice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate, gen(dupsale)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year RecordingDate neg_transprice *
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate,force
/*restriction 6925 duplicate records dropped*/

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice *
drop if duptrans>=1 /*restriction 396 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans dupsale neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year *
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

tab SalesPriceAmountStndCode
*Now we have 88,152 prices, 84,173 are confirmed to be backed up by (closing) documents.

*Drop observations before 1998 (only three towns, GIS data maybe inaccurate for older sales)
drop if e_Year<1998
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1998)+Quarter

*drop possible house flipping events (within the same season)
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
drop if duptrans>=1 /*restriction 328 dup transactions within the same season drops, likely including house flippers*/
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
egen Tract=group(tractce)
egen Block=group(tractce blkgrpce)
*CRS towns
gen CRS_town=1 if LegalTownship=="EAST LYME"|LegalTownship=="MILFORD"|LegalTownship=="STAMFORD"|LegalTownship=="STONINGTON"|LegalTownship=="WEST HARTFORD"|LegalTownship=="WESTPORT"
replace CRS_town=0 if CRS_town==.

*Check FIPS for each year
foreach y of numlist 1998/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Band rich_neighbor urban"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
tab SFHA

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
*71 treated dropped here, 1885 dropped in total

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
*74 treated dropped here, 1465 total dropped
drop if Cellos==1
count if SFHA==1
scalar BCME_nosurge_treat=r(N)

capture drop os2
capture drop nn*
set seed 1234567
teffects nnmatch (SalesPrice $Match_continue)(SFHA), tlevel(1) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo Matching_overall
tebalance summarize
mat list r(table)
duplicates report nn1 if SFHA==1&nn1!=.
di r(unique_value)
scalar BCME_nosurge_control=r(unique_value)
capture drop os2
capture drop nn*
*BCME_Ln
teffects nnmatch (Ln_Price $Match_continue)(SFHA), tlevel(1) bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) ematch($Match_cat) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_nosurge
estadd scalar Nobs_treat=BCME_nosurge_treat:BCME_Ln_nosurge
estadd scalar Nobs_control=BCME_nosurge_control:BCME_Ln_nosurge

gen ID=_n
capture drop _merge
save "$dta\data_analysis_tem_nosurge.dta",replace

use "$dta\data_analysis_tem_nosurge.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
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
*4168/3268
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_H_nosurge

use "$dta\data_analysis_tem_nosurge.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
*With Loan 
global Match_cat "e_Year Band rich_neighbor"
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
*1155/902
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_Ln_D_nosurge

esttab BCME_Ln_nosurge BCME_Ln_H_nosurge BCME_Ln_D_nosurge using"$results\results_BCMEnosurge.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Construct the matched sample
use "$dta\data_analysis_tem_nosurge.dta",clear
keep if SFHA==1
keep nn1 
bysort nn1: gen weight=_N // count how many times each control observation is a match
by nn1: keep if _n==1 // keep just one row per control observation
ren nn1 ID //rename for merging purposes

capture drop _merge
merge 1:m ID using "$dta\data_analysis_tem_nosurge.dta"
replace weight=1 if SFHA==1
drop _merge
tab weight
*gen pweight
gen weight_inv=210/weight
save "$dta\data_4analysis_nosurge.dta",replace

*Trend
set more off
clear all
set maxvar 30000
use "$dta\data_4analysis_nosurge.dta",clear
set matsize 11000
set emptycells drop

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Dist_NWaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Dist_NWaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

*With different sets of fixed effects and specification
set more off
eststo RA_ln_withallM:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
*Differentiate transactions with and without loans
set more off
eststo RA_ln_withall_H:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
set more off
eststo RA_ln_withall_D:  reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D",a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)

esttab RA_ln_withallM RA_ln_withall_H RA_ln_withall_D using"$results\results_SFHA_RA1_nosurge.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*RA2-break up by with loan or not

tab SFHA SalewithLoan if weight!=.

***************************************************
*   Matched Regression for different Inc groups   *
***************************************************
set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="EAST HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.
*drop if urban==1
tab SalesPriceAmountStndCode

*lnPrice
gen Ln_Price=ln(SalesPrice)
tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
gen neg_transprice=-SalesPrice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate, gen(dupsale)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year RecordingDate neg_transprice *
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate,force
/*restriction 6925 duplicate records dropped*/

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice
drop if duptrans>=1 /*restriction 396 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans dupsale neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

drop if e_Year<1998
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1998)+Quarter

*drop possible house flipping events (within the same season)
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
drop if duptrans>=1 /*restriction 328 dup transactions within the same season drops, likely including house flippers*/
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
egen Tract=group(tractce)
egen Block=group(tractce blkgrpce)
*CRS towns
gen CRS_town=1 if LegalTownship=="EAST LYME"|LegalTownship=="MILFORD"|LegalTownship=="STAMFORD"|LegalTownship=="STONINGTON"|LegalTownship=="WEST HARTFORD"|LegalTownship=="WESTPORT"
replace CRS_town=0 if CRS_town==.

*Check FIPS for each year
foreach y of numlist 1998/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (13 dropped Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
*Potential Categorical Match: e_Year SalewithLoan Band FIPS(county) fid_school town AirCondition e_Pool sewer_service BuildingCondition HeatingType
global Match_cat "e_Year SalewithLoan Band neighbor_cat urban"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
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
*181 treated dropped, 1807 dropped in total

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
*62 treated dropped here, 818 total dropped
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
*9538/6045
gen ID=_n
capture drop _merge
save "$dta\data_analysis_neighborhoodtem.dta",replace

*Construct the matched sample
use "$dta\data_analysis_neighborhoodtem.dta",clear
keep if SFHA==1
keep nn1 
bysort nn1: gen weight=_N // count how many times each control observation is a match
by nn1: keep if _n==1 // keep just one row per control observation
ren nn1 ID //rename for merging purposes

capture drop _merge
merge 1:m ID using "$dta\data_analysis_neighborhoodtem.dta"
replace weight=1 if SFHA==1
drop _merge
tab weight
*gen pweight
gen weight_inv=210/weight
save "$dta\data_4analysis_neighborhood.dta",replace

set more off
clear all
set maxvar 30000
use "$dta\data_4analysis_neighborhood.dta",clear
set matsize 11000
set emptycells drop

*Assign 0 bfe to those non SFHA areas
sum BFE if SFHA==1&BFE!=-9999
replace BFE=r(min) if BFE==-9999
replace BFE=0 if BFE==.

global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

tab SFHA neighbor_cat if DataClassStndCode=="H"&weight!=.
tab SFHA neighbor_cat if DataClassStndCode=="D"&weight!=.
*RA
set more off
eststo RA_lnH_neighbor_LowInc:   reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if DataClassStndCode=="H"&neighbor_cat==0 , a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
eststo RA_lnH_neighbor_NormInc:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H"&neighbor_cat==1 , a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
eststo RA_lnH_neighbor_HighInc:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H"&neighbor_cat==2 , a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)

count if SFHA==1&SalewithLoan==1&weight!=.&neighbor_cat==0
estadd scalar Nobs_treat=r(N):RA_lnH_neighbor_LowInc
count if SFHA==0&SalewithLoan==1&weight!=.&neighbor_cat==0
estadd scalar Nobs_control=r(N):RA_lnH_neighbor_LowInc
count if SFHA==1&SalewithLoan==1&weight!=.&neighbor_cat==1
estadd scalar Nobs_treat=r(N):RA_lnH_neighbor_NormInc
count if SFHA==0&SalewithLoan==1&weight!=.&neighbor_cat==1
estadd scalar Nobs_control=r(N):RA_lnH_neighbor_NormInc
count if SFHA==1&SalewithLoan==1&weight!=.&neighbor_cat==2
estadd scalar Nobs_treat=r(N):RA_lnH_neighbor_HighInc
count if SFHA==0&SalewithLoan==1&weight!=.&neighbor_cat==2
estadd scalar Nobs_control=r(N):RA_lnH_neighbor_HighInc

set more off
eststo RA_lnD_neighbor_LowInc:    reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D"&neighbor_cat==0, a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
eststo RA_lnD_neighbor_NormInc:    reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D"&neighbor_cat==1, a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
eststo RA_lnD_neighbor_HighInc:    reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D"&neighbor_cat==2, a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)

count if SFHA==1&SalewithLoan==0&weight!=.&neighbor_cat==0
estadd scalar Nobs_treat=r(N):RA_lnD_neighbor_LowInc
count if SFHA==0&SalewithLoan==0&weight!=.&neighbor_cat==0
estadd scalar Nobs_control=r(N):RA_lnD_neighbor_LowInc
count if SFHA==1&SalewithLoan==0&weight!=.&neighbor_cat==1
estadd scalar Nobs_treat=r(N):RA_lnD_neighbor_NormInc
count if SFHA==0&SalewithLoan==0&weight!=.&neighbor_cat==1
estadd scalar Nobs_control=r(N):RA_lnD_neighbor_NormInc
count if SFHA==1&SalewithLoan==0&weight!=.&neighbor_cat==2
estadd scalar Nobs_treat=r(N):RA_lnD_neighbor_HighInc
count if SFHA==0&SalewithLoan==0&weight!=.&neighbor_cat==2
estadd scalar Nobs_control=r(N):RA_lnD_neighbor_HighInc
esttab RA_lnH_neighbor_LowInc RA_lnH_neighbor_NormInc RA_lnH_neighbor_HighInc RA_lnD_neighbor_LowInc RA_lnD_neighbor_NormInc RA_lnD_neighbor_HighInc using"$results\results_RA_neighborbyloan.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2 Nobs_treat Nobs_control)


*********************************************
*      BCME for different neighborhood      *
*********************************************
*use 70000 as low income criterion
*BCME
set more off
use "$dta\data_analysis_neighborhoodtem.dta",clear
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

*Low Inc neighbor
global Match_cat "e_Year Band urban"
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*2079/1185
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnH_lowInc

set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*573/333
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==0&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.urban) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_lowInc

set more off
use "$dta\data_analysis_neighborhoodtem.dta",clear
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

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
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*4338/2971
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
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*1342/926
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==1&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.fid_school) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_normInc

set more off
use "$dta\data_analysis_neighborhoodtem.dta",clear
set matsize 11000
set emptycells drop
global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"
*High Inc neighbor
set seed 1234567
capture drop os1
capture drop nn*
capture teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==2, tlevel(1) ematch($Match_cat)  atet nn(1) gen(nn) os(os1)
replace os1=. if os1==0
tab os1
cap drop Cellos
egen Cellos=mean(os1),by($Match_cat SalewithLoan neighbor_cat)
*0 treated dropped here, 0 total dropped
drop if Cellos==1

capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==1&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*1016/571
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
*0 treated dropped here, 0 total dropped
drop if Cellos==1

set seed 123456789
capture drop os2
capture drop nn*
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
tebalance summarize
mat list r(table)
duplicates report nn1 if nn1!=.&SFHA==1
di r(unique_value)
*190/105
capture drop os2
capture drop nn*
teffects nnmatch (Ln_Price $Match_continue)(SFHA) if SalewithLoan==0&neighbor_cat==2&os1!=1, tlevel(1) ematch($Match_cat)  bias($View2 $X1 $FE i.fid_school i.period i.period#i.urban) atet vce(robust,nn(2)) nn(1) gen(nn) os(os2)
eststo BCME_LnD_HighInc

esttab BCME_LnH_lowInc BCME_LnH_normInc BCME_LnH_HighInc BCME_LnD_lowInc BCME_LnD_normInc BCME_LnD_HighInc using"$results\results_BCME_neighborInc.csv", keep(*.SFHA) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


*************************
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
***************************************************
* Summary Statistics & By town by year statistics *
***************************************************
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

duplicates report PropertyFullStreetAddress PropertyCity LegalTownship if weight!=.
di r(unique_value)

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

replace Waterfronttype="No" if Waterfronttype==""
replace fldzone="No" if fldzone==""
tab fldzone Waterfronttype

tab SFHA, sum(e_BuildingAge)
tab SFHA, sum(SalesPrice)

tab LegalTownship, sum(SalesPrice)
tab LegalTownship DataClassStndCode

eststo SalesbyYear: estpost tab e_Year
esttab SalesbyYear using"$results\SalesbyYear.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

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

set more off
foreach t in "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
eststo: estpost sum SalesPrice if LegalTownship=="`t'"&SalewithLoan==1
}
eststo: estpost sum SalesPrice if SalewithLoan==1
esttab using"$results\PriceLoan_bytown.csv", replace cells("mean(fmt(3))" "sd(fmt(3) par)")
eststo clear


set more off
foreach t in "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
eststo: estpost sum SalesPrice if LegalTownship=="`t'"&SalewithLoan==0
}
eststo: estpost sum SalesPrice if SalewithLoan==0
esttab using"$results\PriceNoLoan_bytown.csv", replace cells("mean(fmt(3))" "sd(fmt(3) par)")
eststo clear


set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
drop if e_Year<1998
*Average Price trend - by flood zone status
tab e_Year if SFHA==1, sum(SalesPrice)
tab e_Year if SFHA==0, sum(SalesPrice)

*Average sales number by town by year by flood zone
est clear
set more off
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
foreach year of numlist 2000(1)2017 {
eststo `town'_`year'_SFHA: capture estpost sum SalesPrice if LegalTownship=="`t'"&SFHA==1&e_Year==`year'
}
esttab `town'_* using"$results\Price_SFHA_`town'byyear.csv", replace mti cells("mean(fmt(3))" "sd(fmt(3) par)")
est clear
}

est clear
set more off
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
foreach year of numlist 2000(1)2017 {
eststo `town'_`year'_SFHA: capture estpost sum SalesPrice if LegalTownship=="`t'"&SFHA==0&e_Year==`year'
}
esttab `town'_* using"$results\Price_noSFHA_`town'byyear.csv", replace mti cells("mean(fmt(3))" "sd(fmt(3) par)")
est clear
}

*Processing the by town by year by flood zone price result tables, so that it's visualization is better
*For SFHA
set more off
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
import delimited D:\Work\CIRCA\Circa\CT_Property\results\Price_SFHA_`town'byyear.csv, varnames(1) clear
drop v1 
drop if _n==2
drop if _n==3
foreach n of numlist 2(1)19  {
local v = "v"+"`n'"
replace `v'=subinstr(`v',`"""',"",.)
replace `v'=subinstr(`v',"=","",.)
replace `v'=subinstr(`v',"`town'_","",.)
replace `v'=subinstr(`v',"_SFHA","",.)
destring `v',replace
}
xpose,clear
gen Town="`town'"
ren v1 Year
ren v2 AveragePrice
ren v3 Count
order Town Year AveragePrice Count
save "$results/Price_SFHA_`town'byyear.dta",replace
}
use $results/Price_SFHA_GREENWICHbyyear.dta,clear
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
append using $results/Price_SFHA_`town'byyear.dta
erase $results/Price_SFHA_`town'byyear.dta
erase $results/Price_SFHA_`town'byyear.csv
}
duplicates drop
foreach l in 1 2 3 4 {
replace AveragePrice=. if AveragePrice[_n]==AveragePrice[_n-`l']&Count[_n]==Count[_n-`l']
replace Count=. if AveragePrice[_n]==.&Count[_n]==Count[_n-`l']
}
export excel using "D:\Work\CIRCA\Circa\CT_Property\results\Price_SFHA_bytownbyyear.xlsx", sheetreplace firstrow(variables) nolabel

*For nonSFHA
set more off
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
import delimited D:\Work\CIRCA\Circa\CT_Property\results\Price_noSFHA_`town'byyear.csv, varnames(1) clear
drop v1 
drop if _n==2
drop if _n==3
foreach n of numlist 2(1)19  {
local v = "v"+"`n'"
replace `v'=subinstr(`v',`"""',"",.)
replace `v'=subinstr(`v',"=","",.)
replace `v'=subinstr(`v',"`town'_","",.)
replace `v'=subinstr(`v',"_SFHA","",.)
destring `v',replace
}
xpose,clear
gen Town="`town'"
ren v1 Year
ren v2 AveragePrice
ren v3 Count
order Town Year AveragePrice Count
save "$results/Price_noSFHA_`town'byyear.dta",replace
}
use $results/Price_noSFHA_GREENWICHbyyear.dta,clear
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
local town = subinstr("`t'"," ","",.)
append using $results/Price_noSFHA_`town'byyear.dta
erase $results/Price_noSFHA_`town'byyear.dta
erase $results/Price_noSFHA_`town'byyear.csv
}
duplicates drop
foreach l in 1 2 3 4 {
replace AveragePrice=. if AveragePrice[_n]==AveragePrice[_n-`l']&Count[_n]==Count[_n-`l']
replace Count=. if AveragePrice[_n]==.&Count[_n]==Count[_n-`l']
}
export excel using "D:\Work\CIRCA\Circa\CT_Property\results\Price_noSFHA_bytownbyyear.xlsx", sheetreplace firstrow(variables) nolabel

set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
drop if e_Year<1998
*Price distribution along the coast by town
set more off
foreach t in "GREENWICH" "STAMFORD" "DARIEN" "NORWALK" "WESTPORT" "FAIRFIELD" "BRIDGEPORT" "STRATFORD" "MILFORD" "WEST HAVEN" "NEW HAVEN" "EAST HAVEN" "BRANFORD" "GUILFORD" "MADISON" "CLINTON" "WESTBROOK" "OLD SAYBROOK" "OLD LYME" "EAST LYME" "WATERFORD" "NEW LONDON" "GROTON" "STONINGTON" {
eststo: estpost sum SalesPrice if LegalTownship=="`t'"
}
eststo: estpost sum SalesPrice
esttab using "$results/Summary_Alltownprice.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")
eststo clear

*************************
* Main Analysis-Hedonic *
*************************
set more off
use "$dta\data_4analysis.dta",clear

ren e_Elev_dev RelativeElevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren e_SQFT_liv SquareFootage
ren e_TotalRooms TotalRoomNumber
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit
ren Dist_freeway DistancetoHighway
ren Dist_NWaterbody DistancetoWaterbody
ren Dist_NRailroad DistancetoRailroad
ren Dist_beach_near1 DistancetoPublicBeach
ren ratio_Dev HalfMileDevelopedRatio

foreach v in RelativeElevation LISViewarea LISViewangle SquareFootage TotalRoomNumber Dist_I95_NYC DistancetoCoast DistancetoPublicBeach DistancetoHighwayExit  DistancetoHighway DistancetoRailroad HalfMileDevelopedRatio{
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA==1
gen `v'_0=`v' if SFHA==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' pre-match) xlabel(.,nolabels) ylabel(.,nolabels) msize(vsmall)
graph save "$results\\`v'_qqplot.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\RelativeElevation_qqplot.gph" "$results\LISViewarea_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\TotalRoomNumber_qqplot.gph" "$results\Dist_I95_NYC_qqplot.gph", saving("$results\qqplot_pre.gph",replace)

gr combine "$results\DistancetoCoast_qqplot.gph" "$results\DistancetoPublicBeach_qqplot.gph" "$results\DistancetoHighwayExit_qqplot.gph" "$results\DistancetoHighway_qqplot.gph" "$results\DistancetoRailroad_qqplot.gph" "$results\HalfMileDevelopedRatio_qqplot.gph", saving("$results\qqplot_pre1.gph",replace)


set more off
use "$dta\data_4analysis.dta",clear

drop if weight==.
keep weight SFHA e_Elev_dev Lisview_area total_viewangle e_SQFT_liv Dist_I95_NYC e_TotalRooms Dist_Coast Dist_exit_near1 Dist_freeway Dist_NWaterbody Dist_NRailroad Dist_beach_near1 ratio_Dev
ren e_Elev_dev RelativeElevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren e_SQFT_liv SquareFootage
ren e_TotalRooms TotalRoomNumber
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit
ren Dist_freeway DistancetoHighway
ren Dist_NWaterbody DistancetoWaterbody
ren Dist_NRailroad DistancetoRailroad
ren Dist_beach_near1 DistancetoPublicBeach
ren ratio_Dev HalfMileDevelopedRatio

expand weight
foreach v in RelativeElevation LISViewarea LISViewangle SquareFootage TotalRoomNumber Dist_I95_NYC DistancetoCoast DistancetoPublicBeach DistancetoHighwayExit  DistancetoHighway DistancetoRailroad HalfMileDevelopedRatio  {
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA==1
gen `v'_0=`v' if SFHA==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' post-match) xlabel(.,nolabels) ylabel(.,nolabels) msize(vsmall)
graph save "$results\\`v'_qqplot1.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\RelativeElevation_qqplot1.gph" "$results\LISViewarea_qqplot1.gph" "$results\LISViewangle_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\TotalRoomNumber_qqplot1.gph" "$results\Dist_I95_NYC_qqplot1.gph", saving("$results\qqplot_post.gph",replace)

gr combine "$results\DistancetoCoast_qqplot1.gph" "$results\DistancetoPublicBeach_qqplot1.gph" "$results\DistancetoHighwayExit_qqplot1.gph" "$results\DistancetoHighway_qqplot1.gph" "$results\DistancetoRailroad_qqplot1.gph" "$results\HalfMileDevelopedRatio_qqplot1.gph", saving("$results\qqplot_post1.gph",replace)

*gr combine "$results\Elevation_qqplot.gph" "$results\LISViewarea_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\DistancetoCoast_qqplot.gph" "$results\Elevation_qqplot1.gph" "$results\LISViewarea_qqplot1.gph" "$results\LISViewangle_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\DistancetoCoast_qqplot1.gph", saving("$results\qqplot_compare.gph",replace) rows(2) altshrink


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
eststo RA_ln_noperiod:   reghdfe Ln_Price SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school) cluster(PID)
eststo RA_ln_withperiod: reghdfe Ln_Price SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school i.period) cluster(PID)
eststo RA_ln_withall:    reghdfe Ln_Price SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
*Same-with lnSQFTs
set more off
eststo RA_ln_noperiodM:  reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school) cluster(PID)
eststo RA_ln_withperiodM:reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period) cluster(PID)
eststo RA_ln_withallM:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

set more off
eststo RA_l_noperiod:   reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school) cluster(PID)
eststo RA_l_withperiod: reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school i.period) cluster(PID)
eststo RA_l_withall:    reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

set more off
eststo RA_l_noperiodM:   reghdfe SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school) cluster(PID)
eststo RA_l_withperiodM: reghdfe SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period) cluster(PID)
eststo RA_l_withallM:    reghdfe SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

esttab RA_ln_noperiod RA_ln_withperiod RA_ln_withall RA_ln_noperiodM RA_ln_withperiodM RA_ln_withallM RA_l_noperiod RA_l_withperiod RA_l_withall RA_l_noperiodM RA_l_withperiodM RA_l_withallM using"$results\results_SFHA_RA1.csv", keep(SFHA $View2 e_LnSQFT e_LnSQFT_tot e_LnLSQFT $X) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*RA1-Specification check_table4-0

*Differentiate transactions with and without loans
set more off
eststo RA_ln_noperiod_H:  reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school) cluster(PID)
eststo RA_ln_withperiod_H:reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period) cluster(PID)
eststo RA_ln_withall_H:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

set more off
eststo RA_ln_noperiod_D:   reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school) cluster(PID)
eststo RA_ln_withperiod_D: reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school i.period) cluster(PID)
eststo RA_ln_withall_D:    reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
esttab RA_ln_noperiod_H RA_ln_withperiod_H RA_ln_withall_H RA_ln_noperiod_D RA_ln_withperiod_D RA_ln_withall_D using"$results\results_SFHA_RA2.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Differentiate transactions with and without loans_linear price
set more off
eststo RA_l_noperiod_H:  reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school) cluster(PID)
eststo RA_l_withperiod_H:reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period) cluster(PID)
eststo RA_l_withall_H:   reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

set more off
eststo RA_l_noperiod_D:   reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school) cluster(PID)
eststo RA_l_withperiod_D: reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school i.period) cluster(PID)
eststo RA_l_withall_D:    reghdfe SalesPrice SFHA $View2 $X $FE [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

esttab RA_l_noperiod_H RA_l_withperiod_H RA_l_withall_H RA_l_noperiod_D RA_l_withperiod_D RA_l_withall_D using"$results\results_SFHA_RA2_L.csv", keep(SFHA $View2 $X) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
*RA2-break up by with loan or not_table4-1
tab SFHA SalewithLoan if weight!=.a

*preIrene - if period<55 postSandy - if period>60
*Differentiate transactions preIrene postSandy
set more off
eststo RA_ln_preIrene:  reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period<55, a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
eststo RA_ln_postSandy:reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period>60, a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

eststo RA_ln_preIreneH:  reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period<55&DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
eststo RA_ln_postSandyH:reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period>60&DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

eststo RA_ln_preIreneD:  reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period<55&DataClassStndCode=="D", a(i.fid_school i.period i.period#i.fid_school ) cluster(PID)
eststo RA_ln_postSandyD:reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if period>60&DataClassStndCode=="D", a(i.fid_school i.period i.period#i.fid_school ) cluster(PID)

esttab RA_ln_preIrene RA_ln_postSandy RA_ln_preIreneH RA_ln_postSandyH RA_ln_preIreneD RA_ln_postSandyD using"$results\results_SFHA_RA3.csv", keep(SFHA $View2 $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

tab e_Year, gen(Years)
foreach n of numlist 1(1)20 {
gen Year_`n'_lnviewangle = Years`n'*lnviewangle
}
global View3 "lnviewarea Lisview_mnum Lisview_ndist"
global X2 "i.e_Year#Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

*Year Trend of SFHA effect 
set more off
eststo RA_ln_trend: reghdfe Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year  [pweight=weight_inv], a(i.period i.fid_school i.period#i.fid_school) cluster(PID)
esttab RA_ln_trend using"$results\results_yeartrend.csv", keep(*.e_Year#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

eststo RA_ln_trend1: reghdfe Ln_Price i.e_Year#SFHA Year_*_lnviewangle $View3 $X2 $FE i.e_Year [pweight=weight_inv], a(i.period i.fid_school i.period#i.fid_school) cluster(PID)
esttab RA_ln_trend1 using"$results\results_yeartrend1.csv", keep(*.e_Year#1.SFHA Year_*_lnviewangle *.e_Year#1.Waterfront_ocean) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_trend, saving("$results\SFHA_yeartrend.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) yline(0,lc(black)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
 
coefplot RA_ln_trend1, saving("$results\Viewangle_yeartrend.gph",replace) ///
 vertical keep(Year_3_lnviewangle Year_4_lnviewangle Year_5_lnviewangle  Year_6_lnviewangle Year_7_lnviewangle Year_8_lnviewangle /// 
 Year_9_lnviewangle Year_10_lnviewangle Year_11_lnviewangle  Year_12_lnviewangle Year_13_lnviewangle Year_14_lnviewangle Year_15_lnviewangle  ///
  Year_16_lnviewangle Year_17_lnviewangle Year_18_lnviewangle Year_19_lnviewangle Year_20_lnviewangle ///
 ) levels(95) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Ocean View effect on housing price",) xlabel(1"2000" 6"Katrina" 9"Financial Crisis" 12"Irene" 13"Sandy&B-W Act" 15"Affordability" 17"2016",angle(45)) xline(6 9 12 13 15,lc(red)) yline(0,lc(black)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

coefplot RA_ln_trend1, saving("$results\Coastfront_yeartrend.gph",replace) ///
 vertical keep(2000.e_Year#1.Waterfront_ocean 2001.e_Year#1.Waterfront_ocean 2002.e_Year#1.Waterfront_ocean 2003.e_Year#1.Waterfront_ocean 2004.e_Year#1.Waterfront_ocean 2005.e_Year#1.Waterfront_ocean /// 
 2006.e_Year#1.Waterfront_ocean 2007.e_Year#1.Waterfront_ocean 2008.e_Year#1.Waterfront_ocean 2009.e_Year#1.Waterfront_ocean 2010.e_Year#1.Waterfront_ocean 2011.e_Year#1.Waterfront_ocean 2012.e_Year#1.Waterfront_ocean ///
 2013.e_Year#1.Waterfront_ocean 2014.e_Year#1.Waterfront_ocean 2015.e_Year#1.Waterfront_ocean 2016.e_Year#1.Waterfront_ocean 2017.e_Year#1.Waterfront_ocean) levels(95) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Coastal front effect on housing price",) xlabel(1"2000" 6"Katrina" 9"Financial Crisis" 12"Irene" 13"Sandy&B-W Act" 15"Affordability" 17"2016",angle(45)) xline(6 9 12 13 15,lc(red)) yline(0,lc(black)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

*Do average SFHA effect change if we allow amenity effects to change over time? (No, and it doesn't really change the trend)
set more off
eststo RA_ln_amenitytrend: reghdfe Ln_Price SFHA Year_*_lnviewangle $View3 $X2 $FE i.e_Year [pweight=weight_inv], a(i.period i.fid_school i.period#i.fid_school) cluster(PID)
esttab RA_ln_amenitytrend using"$results\results_SFHA_withamenitytrend.csv", keep(SFHA Year_*_lnviewangle *.e_Year#1.Waterfront_ocean) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Year Trend of SFHA effect for transactions with loan
set more off
eststo RA_ln_trend_wloan: reghdfe Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year [pweight=weight_inv] if DataClassStndCode=="H", a(i.period i.fid_school i.period#i.fid_school) cluster(PID)

coefplot RA_ln_trend_wloan, saving("$results\SFHA_yeartrendwloan.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) ylabel() ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) yline(0,lc(black)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

*Year Trend of SFHA effect for transactions without loan
set more off
eststo RA_ln_trend_woloan: reghdfe Ln_Price i.e_Year#SFHA $View2 $X1 $FE i.e_Year [pweight=weight_inv] if DataClassStndCode=="D", a(i.period i.fid_school i.period#i.fid_school) cluster(PID)

coefplot RA_ln_trend_woloan, saving("$results\SFHA_yeartrendwoloan.gph",replace) ///
 vertical keep(1999.e_Year#1.SFHA 2000.e_Year#1.SFHA 2001.e_Year#1.SFHA 2002.e_Year#1.SFHA 2003.e_Year#1.SFHA 2004.e_Year#1.SFHA 2005.e_Year#1.SFHA /// 
 2006.e_Year#1.SFHA 2007.e_Year#1.SFHA 2008.e_Year#1.SFHA 2009.e_Year#1.SFHA 2010.e_Year#1.SFHA 2011.e_Year#1.SFHA 2012.e_Year#1.SFHA 2013.e_Year#1.SFHA ///
 2014.e_Year#1.SFHA 2015.e_Year#1.SFHA 2016.e_Year#1.SFHA 2017.e_Year#1.SFHA) levels(95) recast(con) m(D) msize(small) mfcolor(white) ylabel(-.6(.2).6) ytitle("Flood zone effect on housing price",) xlabel(2"2000" 7"Katrina" 10"Financial Crisis" 13"Irene" 14"Sandy&B-W Act" 16"Affordability" 18"2016",angle(45)) xline(7 10 13 14 16,lc(red)) yline(0,lc(black)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))

tab e_Year if DataClassStndCode=="D"&SFHA==1

*Quantile regression with full example (heterogenous flood zone effect and viewshed effects on property value)
set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_ln_all_Q`num',ti("Q(`q')"): rifhdreg Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv], rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_ln_all_Q* using"$results\results_qreg.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_l_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_l_all_Q`num',ti("Q(`q')"): rifhdreg SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv], rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_l_all_Q* using"$results\results_qreg_L.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*With Loan - heterogeneity risk perception vs. relatively uniformly capitalization of insurance cost
set more off
eststo drop RA_l_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_l_loan_Q`num',ti("Q(`q')"): rifhdreg SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_l_loan_Q* using"$results\results_qreg_loanL.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_ln_loan_Q`num',ti("Q(`q')"): rifhdreg Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_ln_loan_Q* using"$results\results_qreg_loanln.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*heterogeneity risk perception with no loan
set more off
eststo drop RA_l_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_l_noloan_Q`num',ti("Q(`q')"): rifhdreg SalesPrice SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D", rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_l_noloan_Q* using"$results\results_qreg_noloanL1.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo drop RA_ln_all_Q*
foreach q in .1 .2 .3 .4 .5 .6 .7 .8 .9{
local num=100*`q'
eststo RA_ln_noloan_Q`num',ti("Q(`q')"): rifhdreg Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="D", rif(q(`num')) att cluster(Tract) retain(rif_q`num') abs(sz_int_period period) replace iseed(1234567)
}
esttab RA_ln_noloan_Q* using"$results\results_qreg_noloanln1.csv", keep(SFHA lnviewangle Lisview_mnum) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


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
egen floodzone=group(fldzone)
replace floodzone=0 if floodzone==.

gen A_zone=(fldzone=="A"|fldzone=="AE"|fldzone=="AO")
gen V_zone=(fldzone=="VE")
set more off
eststo RA_ln_fldzones:  reghdfe Ln_Price A_zone V_zone $View2 $X1 $FE  [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

*Sandy surge
set more off
eststo RA_Sandysurge: reghdfe Ln_Price i.Sandysurge_feet $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
*eststo OLS_Sandysurge:reg Ln_Price i.Sandysurge_feet $View2 $X1 $FE i.fid_school,cluster(ImportParcelID)
set more off
eststo RA_surgeandDfirm: reghdfe Ln_Price SFHA i.Sandysurge_feet $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

*BFE
set more off
eststo RA_ln_bfe:     reghdfe Ln_Price i.BFE $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(ImportParcelID)

esttab RA_Sandysurge RA_ln_fldzones RA_ln_bfe using"$results\results_Otherfactors.csv", keep(*.Sandysurge_feet A_zone V_zone *.BFE $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
esttab RA_surgeandDfirm using"$results\results_SandySandDfirm.csv", keep(SFHA *.Sandysurge_feet $X1) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_Sandysurge, saving("$results\Sandysurge_discount.gph",replace)  vertical keep(*.Sandysurge_feet) levels(90) recast(con) xlabel(,angle(45)) m(D) msize(small) mfcolor(white) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


********************************************************************************
*   investigate whether the upfront payments go beyond direct capitalization   *
********************************************************************************
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

global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"

global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"

global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

hist LoanAmount if LoanAmount<=1000000
hist LoanAmount if SFHA==1&LoanAmount<=1000000
hist LoanAmount if SFHA==1&SalewithLoan==1&LoanAmount<=1000000
sum LoanAmount

*Calculate average upfront payment
gen upfront_payment=LoanAmount*1395/250000
sum upfront_payment if SalewithLoan==1&SFHA==1
scalar annual_flow=r(mean)
scalar NPV_30_d5=annual_flow*((1-(1/1.05)^30)/(1-1/1.05))
di NPV_30_d5
scalar NPV_30_d7=annual_flow*((1-(1/1.07)^30)/(1-1/1.07))
di NPV_30_d7
scalar NPV_Inf_d7=annual_flow*(1/(1-1/1.07))
di NPV_Inf_d7
sum SalesPrice if SalewithLoan==1&SFHA==1

*******************************************
*  pre-matching with ematch on mile-buffer *
*******************************************
*Investigate more on the conclusion of J&M2019
*Detailed sorting-based-on-coastal-proxy 
*Notice that Buffer_Coast is generated based on coastal proxy percentiles in "Preanalysis.do" 
 /* details
10th percentile-6.8212562 to 20th percentile-16.098896
20th percentile-16.098896 to 30th percentile-29.049139
30th percentile-29.049139 to 40th percentile-44.697788
40th percentile-44.697788 to 50th percentile-62.806004
50th percentile-62.806004 to 60th percentile-81.785568
70th percentile-104.64304 to 80th percentile-134.47058
80th percentile-134.47058 to 90th percentile-181.77643
90th percentile-181.77643 to 100th percentile-.
*/
set more off
use "$dta\oneunitcoastsale_formatch.dta",clear
set seed 1234567
set matsize 11000
set emptycells drop

drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
gen urban=1 if LegalTownship=="BRIDGEPORT"|LegalTownship=="NEW HAVEN"|LegalTownship=="New London"
replace urban=0 if urban==.

*lnPrice
gen Ln_Price=ln(SalesPrice)
tab SalesYear
tab SalesMonth

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth
gen neg_transprice=-SalesPrice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate, gen(dupsale)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year RecordingDate neg_transprice *
duplicates drop PropertyFullStreetAddress PropertyCity LegalTownship RecordingDate,force
/*restriction 6925 duplicate records dropped*/

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth,gen(duptrans)
tab duptrans
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year SalesMonth neg_transprice *
drop if duptrans>=1 /*restriction 396 dup transactions within the same month drops, likely including house flippers*/
capture drop duptrans dupsale neg_transprice

duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship,gen(NoOfTrans)
sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year *
replace NoOfTrans=NoOfTrans+1
tab SFHA,sum(SalesPrice)
tab NoOfTrans

tab SalesPriceAmountStndCode
*Now we have 88,152 prices, 84,173 are confirmed to be backed up by (closing) documents.

*Drop observations before 1998 (only three towns, GIS data maybe inaccurate for older sales)
drop if e_Year<1998
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1998)+Quarter

*drop possible house flipping events (within the same season)
duplicates tag PropertyFullStreetAddress PropertyCity LegalTownship period,gen(duptrans)
gen neg_transprice=-SalesPrice
sort PropertyFullStreetAddress PropertyCity LegalTownship period neg_transprice TransId
tab duptrans
drop if duptrans>=1 /*restriction 328 dup transactions within the same season drops, likely including house flippers*/
capture drop duptrans neg_transprice

*Creating categorical Match variables 
*Use qualtiles and viewshed availability to devide bands - not used in analysis
sum Dist_Coast if view_analysis==1,d
gen Band1=(Dist_Coast<=r(p50)&view_analysis==1)
gen Band2=(Dist_Coast>r(p50)&view_analysis==1)
gen Band3=(Band1==0&Band2==0)
gen Band=1 if Band1==1
replace Band=2 if Band2==1
replace Band=3 if Band3==1

*Block median income
drop if Block_MedInc==.
gen rich_neighbor=(Block_MedInc>=150000)
tab rich_neighbor
gen SalewithLoan=(DataClassStndCode=="H")

egen town=group(LegalTownship)
drop if town==.
drop if fid_school==.
egen Tract=group(tractce)
egen Block=group(tractce blkgrpce)
*Check FIPS for each year
foreach y of numlist 1998/2017 {
di `y'
tab FIPS if e_Year==`y'
}
*FIPS 9007 (Middlesex has no more than 7 obs annually before 2001)
drop if FIPS==9007&e_Year<2001

global Match_continue "lnviewarea lnviewangle e_Elev_dev Lisview_ndist Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber e_TotalRooms  e_TotalBedrooms e_NoOfStories"
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

capture drop os2
teffects nnmatch (SalesPrice $Match_continue)(SFHA) if os1!=1, tlevel(1) ematch($Match_cat) atet nn(1) gen(nn) vce(iid) os(os2)
tebalance summarize
duplicates report nn1 if nn1!=.
di r(unique_value) /*6224*/

*0 SFHA property (treated) have no exact match
estat summarize 
gen ID=_n
capture drop _merge
save "$dta\data_analysis_tem1.dta",replace


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
*gen pweight
gen weight_inv=210/weight
save "$dta\data_4proxytrend.dta",replace

set more off
clear all
set maxvar 30000
use "$dta\data_4proxytrend.dta",clear
set matsize 11000
set emptycells drop

global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

set more off
eststo RA_ln_proxytrend: reghdfe Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
esttab RA_ln_proxytrend using"$results\results_proxytrend.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrend, saving("$results\SFHA_proxytrend.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to682ft)" 2"Q10toQ20(682to1610ft)" 3"Q20toQ30(1610to2905ft)" 4"Q30toQ40(2905to4470ft)" 5"Q40toQ50(4470ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
*As it goes further from the coast, the analysis becomes less accurate, since the SFHA will be more related to rivers and we are not full accurate about river view (may miss some upstream views). 
graph export "$results\SFHA_proxytrend.tif",as(tif) replace

set more off
eststo RA_ln_proxytrendwloan: reghdfe Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE [pweight=weight_inv] if DataClassStndCode=="H", a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
esttab RA_ln_proxytrendwloan using"$results\results_proxytrendwloan.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwloan, saving("$results\SFHA_proxytrendwloan.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to682ft)" 2"Q10toQ20(682to1610ft)" 3"Q20toQ30(1610to2905ft)" 4"Q30toQ40(2905to4470ft)" 5"Q40toQ50(4470ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
graph export "$results\SFHA_proxytrendwloan.tif",as(tif) replace

set more off
eststo RA_ln_proxytrendwoloan: reghdfe Ln_Price i.Buffer_Coast#SFHA i.Buffer_Coast $View2 $X1 $FE  [pweight=weight_inv] if DataClassStndCode=="D", a(i.fid_school i.period i.period#i.fid_school) cluster(Tract)
esttab RA_ln_proxytrendwoloan using"$results\results_proxytrendwoloan.csv", keep(*.Buffer_Coast#1.SFHA) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_ln_proxytrendwoloan, saving("$results\SFHA_proxytrendwoloan.gph",replace) ///
 vertical keep(*.Buffer_Coast#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(1"Q0toQ10(0to682ft)" 2"Q10toQ20(682to1610ft)" 3"Q20toQ30(1610to2905ft)" 4"Q30toQ40(2905to4470ft)" 5"Q40toQ50(4470ftto1.19mi)" 6"Q50toQ60(1.19to1.55mi)" 7"Q60toQ70(1.55to1.98mi)" 8"Q70toQ80(1.98to2.55mi)" 9"Q80toQ90(2.55to3.44mi)" 10"Q90toQ100(above3.44mi)",angle(45)) ylabel() ytitle("Flood zone effect on housing price",) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
graph export "$results\SFHA_proxytrendwoloan.tif",as(tif) replace

*Check whether the previous results are replicable here - Yes
set more off
eststo RA_ln_MBuffer_B12: reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if view_analysis==1, a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
eststo RA_ln_MBuffer_B12H: reghdfe Ln_Price SFHA $View2 $X1 $FE [pweight=weight_inv] if view_analysis==1&SalewithLoan==1,a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
eststo RA_ln_MBuffer_B3: reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv] if view_analysis==0, a(i.fid_school i.period i.period#i.fid_school) cluster(PID)
eststo RA_ln_MBuffer: reghdfe Ln_Price SFHA $View2 $X1 $FE  [pweight=weight_inv], a(i.fid_school i.period i.period#i.fid_school) cluster(PID)

esttab RA_ln_MBuffer_B12 RA_ln_MBuffer_B12H RA_ln_MBuffer_B3 RA_ln_MBuffer using"$results\results_MBuffer_B12.csv", keep(SFHA $View2 $X1) mti("") replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


