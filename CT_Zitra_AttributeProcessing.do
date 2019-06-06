clear all
set more off
cap log close

global zroot "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\Zillow\"
global root "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\Sandbox\Charles\"
global dta "$root\dta\CT_Property\"
global results "$root\results"
global zdta "$zroot\dta"

global gis "\\Guild.grove.ad.uconn.edu\EFS\CTOWE\CIRCA\GIS_data\GISdata"

****************************************************************************************************
* attributes processing
****************************************************************************************************

use "$gis\property_schoold.dta",clear
ren rowid_ RowID 
keep RowID fid_school name
ren name Sch_District
duplicates drop
save "$dta\property_schoold.dta",replace

import delimited using "$gis\Property_nearshoreline.txt", clear
drop rowid_ objectid 
ren in_fid fid
save "$dta\property_nearshore.dta",replace

***
import delimited using "$gis\Property_nearwaterbody.txt", clear
drop rowid_ objectid 
ren in_fid fid
save "$dta\property_nearwaterbody.dta",replace

*Sep new attributes
use "$gis\prop_int_newsfha.dta",clear
ren fid_proper FID
ren rowid_ RowID
keep FID RowID fld_zone static_bfe 
gen SFHA_Dfirm=1
duplicates report RowID
duplicates drop RowID,force
save "$dta\property_newSFHA.dta",replace

* not in the Q: drive files
use "$dta\Sandysurge.dta",clear
ren rowid_ RowID
duplicates report RowID
duplicates drop RowID,force
save "$dta\property_sandysurge.dta",replace

*Aggregate
use "$gis\property_add_ct.dta",clear
gen fid=_n-1  /*CT - I am sure this is fine but we should double check */
ren rowid_ RowID
capture drop near_fid near_dist
merge 1:1 fid using"$dta\property_nearshore.dta", keepusing(near_dist)
ren near_dist Dist_Coast
capture drop _merge
merge 1:1 fid using"$dta\property_nearwaterbody.dta", keepusing(near_dist)
ren near_dist Dist_NWaterbody
drop _merge
drop if propertyad==0
duplicates drop RowID Dist_Coast Dist_NWaterbody, force
save "$dta\property_nearshoreline.dta",replace

use "$gis\property_sfha_ct.dta",clear
ren rowid_ RowID
gen SFHA=1
duplicates drop RowID, force
save "$dta\property_sfha_ct1.dta",replace    /*approximately 61k properties in floodplain*/

****************************************************************************************************
* end property attribute processing
****************************************************************************************************


****************************************************************************************************
* Now let's put this together
****************************************************************************************************

use "$dta\current_assess_ct.dta",clear
*put it with the historic assessments

capture drop _merge
merge m:1 RowID using"$dta\property_sfha_ct1.dta", keepusing(SFHA)
replace SFHA=0 if SFHA==.
capture drop _merge

tab AssessmentYear
*This SFHA may not be precise    
merge m:1 RowID using"$dta\property_in_SFHA_50ft.dta", keepusing(SFHA_50ft)
replace SFHA_50ft=0 if SFHA_50ft==.
capture drop _merge

merge m:1 RowID using"$dta\current_assess_ct_building.dta"
capture drop _merge

merge m:1 RowID using"$dta\current_assess_ct_buildingarea.dta",keepusing(SQFTBAG SQFTBAL SQFTBASE)
capture drop _merge

merge m:1 RowID using"$dta\current_assess_ct_waterfront.dta", keepusing(Waterfront)
capture drop _merge
replace Waterfront=0 if Waterfront==.

merge m:1 RowID using"$dta\current_assess_ct_pool.dta",keepusing(PoolStndCode Pool)
capture drop _merge
replace Pool=0 if Pool==.

merge m:1 RowID using"$dta\current_assess_ct_garage.dta",keepusing(GarageNoOfCars GarageStndCode)
capture drop _merge
replace GarageNoOfCars=0 if GarageNoOfCars==.
replace SQFTBAG=SQFTBAL*NoOfStories if SQFTBAG==.

merge m:1 RowID using"$dta\property_nearshoreline.dta", keepusing(Dist_Coast Dist_NWaterbody)
capture drop _merge

merge m:1 RowID using"$dta\property_schoold.dta", keepusing(Sch_District fid_school)
capture drop _merge

merge m:1 RowID using"$dta\Elevation.dta", keepusing(elevation)    
capture drop _merge
replace PropertyAddressLatitude=PropertyAddressLatitude+0.00008
replace PropertyAddressLongitude=PropertyAddressLongitude+0.000428

save "$dta\data_analysis1.dta",replace
****************************************************************************************************
***********Create elevated list 12-16*******************
****************************************************************************************************
use "$dta\data_analysis1.dta",clear

merge m:1 RowID using "$dta\Elevated_property.dta"  

keep if _merge==3
save "$dta\Elev_pproperty.dta",replace
****************************************************************************************************
****************************************************************************************************


use "$dta\data_analysis1.dta",clear     /*~1.3m*/
drop if NoOfUnits!=1   /*restriction drops ~388k */
drop if NoOfBuilding==0  /*restriction drops ~14.5k*/
tab SFHA, sum(SalesPrice)

count if SQFTBAG==.&SQFTBAL==.&SQFTBASE==.  
drop if SQFTBAG==.&SQFTBAL==.&SQFTBASE==.  /*restriction  drop ~14.8k*/
drop if YearBuilt==. /*restriction  6.5k*/
*drop if LotSizeSquareFeet==.
*Looks like a lot parcels do not have lot size square feet, investigate this further -- probably condos
drop if elevation==.    /*restriction  ~1.7k*/

*Drop counties without digitalized SFHA
drop if County=="WINDHAM"  /*restriction*/
drop if County=="TOLLAND"   /*restriction*/
drop if County=="LITCHFIELD"  /*restriction*/
*** CT - why not drop Hartford too?
drop if PropertyCountyLandUseDescription!="1-FAMILY RESIDENCE"  /*restriction, and why?*/

egen BuildingCondition=group(BuildingConditionStndCode)
replace BuildingCondition=0 if BuildingCondition==.
drop if BuildingCondition==0   /*restriction*/
drop if BuildingCondition==5|BuildingCondition==6   /*restriction*/  
egen HeatingType=group(HeatingTypeorSystemStndCode)
replace HeatingType=0 if HeatingType==.
egen RoofStructure=group(RoofStructureTypeStndCode)
replace RoofStructure=0 if RoofStructure==.
egen FoundationType=group(FoundationTypeStndCode)
replace FoundationType=0 if FoundationType==.

gen AirCondition=1 if AirConditioningStndCode=="YY"
replace AirCondition=0 if AirCondition==.
replace FireplaceNumber=0 if FireplaceNumber==.
*Convert distance from meter to foot
replace Dist_Coast=Dist_Coast*3.28084
replace Dist_NWaterbody=Dist_NWaterbody*3.28084

gen Lndist_coast=ln(Dist_Coast)
gen Lndist_nwaterbody=ln(Dist_NWaterbody)

gen SQFT_liv=SQFTBAL
gen SQFT_tot=SQFTBAG if SQFTBASE==.
replace SQFT_tot=SQFTBAG+SQFTBASE if SQFTBASE!=.
replace SQFT_tot=SQFT_liv if SQFT_tot==.

gen LnSQFT=ln(SQFT_liv)
gen LnSQFT_tot=ln(SQFT_tot)

gen Closetocoast=(Dist_Coast<=100)  /*CT - This is 100 feet?*/
tab Closetocoast Waterfront

replace NoOfStories=round(SQFTBAG/SQFTBAL) if NoOfStories==.
count if NoOfStories==.
replace NoOfStories=1 if NoOfStories==.

global X "SQFT_liv SQFT_tot LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"
*hist Dist_Coast
global Match "SQFT_liv LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount FireplaceNumber"
save "$dta\data_analysis2.dta",replace
*This dataset contains only one unit properties


set more off
use "$dta\data_analysis2.dta",clear

 
***************************************************************************************************************************
* end data_analysis2  - at this point the Sales data etc are from current assessment zillow suggests using the trans file
***************************************************************************************************************************
merge m:1 RowID using"$dta\Elevated_property.dta"
global X "BuildingSQFT LotSizeSquareFeet Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"

sum $X

keep RowID PropertyAddressLatitude PropertyAddressLongitude SFHA
duplicates drop
tab SFHA
*replace PropertyAddressLatitude=PropertyAddressLatitude+0.00008  /*already done*/
*replace PropertyAddressLongitude=PropertyAddressLongitude+0.000428
duplicates report PropertyAddressLatitude PropertyAddressLongitude
duplicates drop PropertyAddressLatitude PropertyAddressLongitude,force
export delimited using "D:\UConn2\Circa\CT_Property\dta\Property_Analysis_Coastal.csv", replace
*This data will be plotted, selected by LiDAR location, and turn out to be prop_VA_oneunit.shp


*Generate list for all properties, including those without transactions
use "$dta\data_analysis1.dta",clear
drop if PropertyFullStreetAddress==""
drop if PropertyAddressLatitude==.

duplicates report PropertyAddressLatitude PropertyAddressLongitude PropertyFullStreetAddress
duplicates drop PropertyAddressLatitude PropertyAddressLongitude PropertyFullStreetAddress,force    /*restriction*/
duplicates drop PropertyFullStreetAddress PropertyCity,force  /*restriction*/
save "$dta\data_analysis1_1.dta",replace

*check elevated list
set more off
use "$dta\data_analysis2.dta",clear
global X "SQFT_liv SQFT_tot LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"

sum $X
drop if NoOfUnits!=1  /*restriction*/
drop if SalesPriceAmount<1000  /*restriction  -  since this is from the currrent assessment file maybe we shouldn't drop yet*/
keep if Dist_Coast<=5280  /*restriction*/
/*Generate Sample for each coastal town
gen R1=rnormal()
egen town=group(LegalTownship)
capture drop Rank_town
egen Rank_town=rank(R1),by(LegalTownship)
keep if Rank_town==1
drop Rank_town R1
export delimited using "D:\UConn2\Circa\CT_Property\dta\propertysample_1.csv", replace
*/
capture drop _merge
merge m:1 RowID using"$dta\Elev_pproperty.dta"
egen town=group(LegalTownship)
replace Elev_flag=0 if Elev_flag==.
logit Elev_flag i.town
tab LegalTownship if Elev_flag==1, sort














******************************************************************
*Merge viewshed data

*Creat the dataset for viewshed analysis
*Only those fall in the LiDAR domain has the viewshed analysis
/*
use "$gis\property_va_oneunit.dta",clear
keep rowid_
ren rowid_ RowID
gen FID=_n-1
save "$dta\viewshed_prop.dta",replace
*/

set more off
use "$dta\data_analysis2.dta",clear
merge m:1 RowID using"$dta\Viewshed_new.dta"
gen view_analysis=(_merge==3)   /* this only keeps 51k parcels*/
*Only include those properties having been analyzed viewshed
keep if _merge==3
drop _merge

/*Get assessed values
keep RowID LegalTownship PropertyFullStreetAddress TotalAssessedValue PropertyAddressLatitude PropertyAddressLongitude
export delimited using "D:\UConn2\Circa\CT_Property\dta\Viewshed_oneU_AssessedV.csv", replace
*/

gen SalesYear=substr(RecordingDate,1,4)  /*CT - pull these from the transactions files, */
gen SalesMonth=substr(RecordingDate,6,2)  /*CT - pull these from the transactions files*/
destring SalesYear,replace
destring SalesMonth,replace


replace Lisview_area=0 if Lisview_area==.
replace total_viewangle=0 if total_viewangle==.
gen lnviewarea=ln(Lisview_area+1)
replace lnviewarea=0 if lnviewarea==.
gen lnviewangle=ln(total_viewangle+1)
replace lnviewangle=0 if lnviewangle==.

global View "lnviewarea lnviewangle Lisview_mnum"
foreach v in $View {
replace `v'=0 if `v'==.
}
replace Lisview_ndist=5280 if Lisview_ndist==.

global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global X "SQFT_liv SQFT_tot LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"
global Match "SQFT_liv LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount FireplaceNumber"

gen elevation_sq=elevation*elevation


*Merge with new attributes here.
merge 1:1 RowID using"$dta\Distances.dta"
keep if _merge==3
drop _merge
merge 1:1 RowID using"$dta\property_newSFHA.dta", keepusing(SFHA_Dfirm fld_zone static_bfe)   /* what year is this SFHA?*/
tab SFHA_Dfirm
drop if _merge==2
replace SFHA_Dfirm=0 if SFHA_Dfirm==.
drop _merge
tab SFHA_Dfirm
merge 1:1 RowID using"$dta\property_sandysurge.dta", keepusing(Sandysurge_feet)
drop if _merge==2
replace Sandysurge_feet=0 if Sandysurge_feet==.
tab Sandysurge_feet
tab SFHA_Dfirm Sandysurge_feet
drop _merge
merge 1:1 RowID using"$dta\Sewer_service.dta", keepusing(sewer_service)
drop if _merge==2
drop _merge
gen Sewer=1 if sewer_service!=""
replace Sewer=0 if Sewer==.

merge 1:1 RowID using"$dta\Ground_elevation2016.dta"
drop _merge
merge 1:1 RowID using"$dta\Str_elevation2016.dta"
drop _merge
ren Str_elev Str_elev2016
ren TaxYear Year  /* CT -  becomes the Year used in the merge between 3 and 4, seems potentially problematic*/
merge 1:1 RowID using"$dta\Str_elevation2012.dta"
drop _merge
ren Str_elev Str_elev2012
*landcover proportion measures will take more time
merge 1:1 RowID using"$dta\lcratio_2002.dta"
keep if _merge!=2
drop _merge
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
replace `v'=0 if `v'==.
ren `v' `v'02
}

merge 1:1 RowID using"$dta\lcratio_2011.dta"
keep if _merge!=2
drop _merge
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
replace `v'=0 if `v'==.
ren `v' `v'11
}

merge 1:1 RowID using"$dta\lcratio_2015.dta"
keep if _merge!=2
drop _merge
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
replace `v'=0 if `v'==.
ren `v' `v'15
}
gen ratio_Dev=(ratio_Dev02+ratio_Dev11+ratio_Dev15)/3
gen ratio_Fore=(ratio_Fore02+ratio_Fore11+ratio_Fore15)/3
gen ratio_Open=(ratio_Open02+ratio_Open11+ratio_Open15)/3
gen ratio_Ag=(ratio_Ag02+ratio_Ag11+ratio_Ag15)/3
gen ratio_sum=ratio_Dev+ratio_Fore+ratio_Open+ratio_Ag
sum ratio_sum
*/
save "$dta\data_analysis3.dta",replace
*This dataset contains only one unit and viewshed analyzed properties    ~51k but it restricts SalesPrice using currentassessment sales price




use "$dta\data_analysis3.dta",clear
eststo Stockbytown: estpost tab LegalTownship
esttab Stockbytown using"$results\Stockbytown.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Linking building height with story number
gen Building_high2016=Str_elev2016-Ground_elev
gen Building_high2012=Str_elev2012-Ground_elev
sum Building_high2016
replace Building_high2016=r(mean) if Building_high2016==.
sum Building_high2012
replace Building_high2012=r(mean) if Building_high2012==.
hist Building_high2016
hist Building_high2012
tab SFHA_Dfirm,sum(Building_high2016)
tab NoOfStories
reg Building_high2016 NoOfStories i.FoundationType i.RoofStructure
reg Building_high2012 NoOfStories i.FoundationType i.RoofStructure

*generate identifiers for elevated houses
gen Residual_h=Building_high2016-10*(NoOfStories)
hist Residual_h
sum Residual_h,detail
gen elev16_ID1=(Residual_h>r(p95))

reg Building_high2016 NoOfStories i.FoundationType i.RoofStructure
predict h_reg,xb
gen Residual_reg=Building_high2016-h_reg
hist Residual_reg
sum Residual_reg,detail
gen elev16_ID2=(Residual_reg>r(p95))
tab elev16_ID1 elev16_ID2

gen elev16_ID3=(Residual_h>10&Residual_reg>10)
tab elev16_ID3

gen elev16_ID4=(Residual_h>10|Residual_reg>10)
tab elev16_ID4

gen Residual_h2=Building_high2012-10*(NoOfStories)
hist Residual_h2
sum Residual_h2,detail
gen elev12_ID1=(Residual_h2>r(p95))

reg Building_high2012 NoOfStories i.FoundationType i.RoofStructure
predict h_reg2,xb
gen Residual_reg2=Building_high2012-h_reg2
hist Residual_reg2
sum Residual_reg2,detail
gen elev12_ID2=(Residual_reg2>r(p95))
tab elev12_ID1 elev12_ID2

gen elev12_ID3=(Residual_h2>10&Residual_reg2>10)
tab elev12_ID3

gen elev12_ID4=(Residual_h2>10|Residual_reg2>10)
tab elev12_ID4

keep RowID ImportParcelID FIPS State County LegalTownship PropertyFullStreetAddress fld_zone SFHA_Dfirm static_bfe ///
PropertyCity PropertyZip Building_high2016 Building_high2012 Residual_h elev16_ID1 Residual_reg elev16_ID2 elev16_ID3 ///
elev16_ID4 Residual_h2 elev12_ID1 Residual_reg2 elev12_ID2 elev12_ID3 elev12_ID4
save "$dta\data_IDforelevated.dta",replace

use "$dta\EC_Fairfield1.dta",clear
append using "$dta\EC_OldSaybrook.dta"
append using "$dta\EC_Stonington.dta"
*More
save "$dta\EC_CT.dta",replace


use "$dta\data_IDforelevated.dta",clear
tab static_bfe if SFHA_Dfirm==1
*10653 SFHA properties, 192 no bfe.
ren PropertyFullStreetAddress Address

merge m:m Address LegalTownship using"$dta\EC_CT.dta"
drop if _merge==2  /*restriction*/
keep if _merge==3
drop _merge
drop E1 E2 E3 E4 E5 G1 G2 G3 G4 G5 G6 G7 G8 G9
drop if BFE==""   /*restriction*/
replace BFE="11" if BFE=="10 & 11"
replace Areaoffloodopenings="" if Areaoffloodopenings=="Yes"

tab LegalTownship
foreach v in BFE Topofbottomfloor_elev Topofnexthigher Sqftcrawlspace Areaoffloodopenings Sqftattachedgara Areaoffloodopeningsingara{
replace `v'="" if `v'=="N/A"
destring `v',replace
}


gen FEMA_compl_project=1 if BuildingdiagramNo=="5"&Topofbottomfloor_elev>=BFE+1
replace FEMA_compl_project=1 if BuildingdiagramNo!="5"&(Areaoffloodopenings>=Sqftcrawlspace)&(Areaoffloodopeningsingara>=Sqftattachedgara)&Topofnexthigher>BFE+1
replace FEMA_compl_project=1 if BuildingdiagramNo!="5"&(Areaoffloodopenings<Sqftcrawlspace|Areaoffloodopeningsingara<Sqftattachedgara)&Topofbottomfloor_elev>BFE+1

replace FEMA_compl_project=0 if FEMA_compl_project==.
tab FEMA_compl_project
save "$dta\FEMA_compliance_CT.dta",replace

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
ren SalesPriceAmount SalesPrice
merge 1:m TransId using "$zdta\transaction_property_09.dta",keepusing(AssessorParcelNumber ImportParcelID )
drop if _merge!=3
gen TransactionYear=substr(RecordingDate,1,4)
gen TransactionMonth=substr(RecordingDate,6,2)
gen TransactionDay=substr(RecordingDate,9,2)

destring TransactionYear,replace
drop _merge
keep SalesPrice Transaction* ImportParcelID TransId AssessorParcelNumber Recording* TransId  /*CT- Recording date and TransId kept by CT*/
tab TransactionYear
 /* CT-was a rename here ren TransactionYear Year*/
 
 
***********************************************************
* After much deliberation I have determined you cannot easily put 
* the historical assessment and the transaction files together
***********************************************************
*****Merge with historical assessment data******
merge m:m ImportParcelID  using"$dta\hist_assess_ct.dta"  /* CT - This Year is not the same as the transaction year in the assessment data and will stop at 2015*/
drop if _merge==1 /*was 2 should be 1 because we don't want transactions without assessment data*/
* CT now mark the actual sales rows and clean the rest
gen hedonicSale = (Year == TransactionYear)
duplicates drop _all, force
drop _merge
drop GarageAreaSqFt

* CT - at this point you have all the transactions and the historic assessments you really only need to add the information for the current assessment

*****

* CT -  this will bring back into the mix a lot of data as long as it is merged with Year you should be fine
* this is essentially an append of the current assessment to the transaction file because the successful merges will all 
* be from Year 2017 
merge m:1 ImportParcelID Year using"$dta\data_analysis3.dta",keepusing(AssessorParcelNumber ///
				ImportParcelID Year RowID FIPS State ExtractDate County UnformattedAssessorParcelNumber PropertyFullStreetAddress ///
				PropertyCity PropertyZip PropertyZoningDescription TaxIDNumber TaxAmount LegalTownship NoOfBuildings LotSizeAcres ///
				LotSizeSquareFeet PropertyAddressLatitude PropertyAddressLongitude BatchID LandAssessedValue ImprovementAssessedValue ///
				TotalAssessedValue AssessmentYear NoOfUnits PropertyCountyLandUseDescription PropertyCountyLandUseCode ///
				BuildingOrImprovementNumber BuildingConditionStndCode YearBuilt NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount ///
				HeatingTypeorSystemStndCode AirConditioningStndCode FireplaceNumber SQFTBAG SQFTBAL SQFTBASE GarageNoOfCars) force 
				
drop if _merge==2
drop _merge
*****Merge with geo attributes now*******  CT -  this is the merge that is really messing with things like prices
merge m:1 ImportParcelID using"$dta\data_analysis3.dta", update force
drop if _merge==1|_merge==2
drop _merge
save "$dta\data_analysis3_formatching.dta",replace

*********************
*      Matching     *
********************* 
set more off
use "$dta\data_analysis3_formatching.dta",clear
gen BuildingAge=Year-YearBuilt
drop if BuildingAge<0
gen BuildingAge_sq=BuildingAge*BuildingAge
gen lnBSQFT=ln(SQFT_liv)
gen lnLSQFT=ln(LotSizeSquareFeet+1)
sum lnLSQFT
replace lnLSQFT=r(mean) if lnLSQFT==.
gen lndist_airp=ln(Dist_Airport)
gen lndist_develop=ln(Dist_HDdevelop+1)
gen lndist_CBRS=ln(Dist_CBRS+1)
gen lndist_StatePark=ln(Dist_StatePark+1) 
gen lndist_nearexit=ln(Dist_exit_near1+1)
gen lndist_beach=ln(Dist_beach_near1+1)
gen lndist_highway=ln(Dist_freeway+1)
gen lndist_brownfield=ln(Dist_Brownfield+1)

*Transfer Prices in 2017 dollar
*Inflation Rate is based on Bureau of Labor Statistics CPI
* don't do this - time dummies will do the same thing

**CT - this uses the currentassessment sales price
replace SalesPrice=SalesPrice*1.80 if Year==1991
replace SalesPrice=SalesPrice*1.74 if Year==1992
replace SalesPrice=SalesPrice*1.69 if Year==1993
replace SalesPrice=SalesPrice*1.65 if Year==1994
replace SalesPrice=SalesPrice*1.61 if Year==1995
replace SalesPrice=SalesPrice*1.56 if Year==1996
replace SalesPrice=SalesPrice*1.53 if Year==1997
replace SalesPrice=SalesPrice*1.50 if Year==1998
replace SalesPrice=SalesPrice*1.47 if Year==1999
replace SalesPrice=SalesPrice*1.42 if Year==2000
replace SalesPrice=SalesPrice*1.38 if Year==2001
replace SalesPrice=SalesPrice*1.36 if Year==2002
replace SalesPrice=SalesPrice*1.33 if Year==2003
replace SalesPrice=SalesPrice*1.30 if Year==2004
replace SalesPrice=SalesPrice*1.25 if Year==2005
replace SalesPrice=SalesPrice*1.21 if Year==2006
replace SalesPrice=SalesPrice*1.18 if Year==2007
replace SalesPrice=SalesPrice*1.14 if Year==2008
replace SalesPrice=SalesPrice*1.14 if Year==2009
replace SalesPrice=SalesPrice*1.12 if Year==2010
replace SalesPrice=SalesPrice*1.09 if Year==2011
replace SalesPrice=SalesPrice*1.07 if Year==2012
replace SalesPrice=SalesPrice*1.05 if Year==2013
replace SalesPrice=SalesPrice*1.03 if Year==2014
replace SalesPrice=SalesPrice*1.03 if Year==2015
replace SalesPrice=SalesPrice*1.02 if Year==2016


keep if Year>1996    /*restriction*/
drop if NoOfUnits!=1  /*restriction*/
drop if SalesPrice<1000  /*restriction*/
drop if SalesPrice==.  /*restriction*/
*drop non arms-length transaction
sum SalesPrice,detail
drop if SalesPrice<=r(p1)|SalesPrice>=r(p99)
*drop price outlier
gen TransactionMonth=substr(RecordingDate,6,2)
destring TransactionMonth,replace
sort ImportParcelID Year TransactionMonth
duplicates tag ImportParcelID Year TransactionMonth,gen(duptrans)
gen neg_transprice=-SalesPrice
sort RowID Year TransactionMonth neg_transprice
duplicates drop RowID Year TransactionMonth duptrans,force
capture drop duptrans neg_transprice

duplicates tag ImportParcelID ,gen(NoOfTrans)
sort ImportParcelID Year
replace NoOfTrans=NoOfTrans+1

tab SFHA_Dfirm,sum(SalesPrice)



global Match "Lisview_area total_viewangle SQFT_liv LotSizeSquareFeet BuildingAge Dist_Coast Dist_NWaterbody Dist_exit_near1 Dist_freeway Dist_beach_near1 Dist_Airport Dist_HDdevelop Dist_CBRS Dist_StatePark Dist_Brownfield GarageNoOfCars elevation NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount FireplaceNumber"
*ratio_Dev ratio_Fore ratio_Open 
global RA "Waterfront Pool AirCondition Lisview_mnum Lisview_ndist elevation_sq i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS"

global X "SQFT_liv SQFT_tot LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"
global X1 "lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber lndist_nearexit lndist_beach Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS lndist_brownfield ratio_Dev ratio_Fore ratio_Open"
global X2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist major_view lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber lndist_nearexit lndist_highway lndist_beach Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS lndist_brownfield ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS"
*ratio_Dev ratio_Fore ratio_Open

eststo OLS: reg SalesPrice SFHA_Dfirm $X1 i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS, cluster(fid_school)
eststo OLS_view: reg SalesPrice SFHA_Dfirm $X2 i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS, cluster(fid_school)

capture drop nn*
capture drop os*
set seed 1234567
teffects nnmatch (SalesPrice $Match)(SFHA_Dfirm), ematch(Year) atet nn(1) gen(nn) os(os1)


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
egen town=group(LegalTownship)
drop if town==.
drop if fid_school==.

tab SFHA,sum(SalesPrice)
drop _merge
capture gen elevation_sq=elevation*elevation
gen Ln_Price=ln(SalesPrice)

sum Lndist_nwaterbody
replace Lndist_nwaterbody=r(mean) if Lndist_nwaterbody==.
sum Lndist_coast
replace Lndist_coast=r(mean) if Lndist_coast==.
save "$dta\data_analysis4.dta",replace

set more off
use "$dta\data_analysis4.dta",clear
global FE "i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS"
*Assign 0 bfe to those non SFHA areas
sum static_bfe if SFHA_Dfirm==1&static_bfe!=-9999
replace static_bfe=r(min) if static_bfe==-9999
replace static_bfe=0 if static_bfe==.

foreach v in BuildingCondition HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

global X2 "lnviewarea lnviewangle Lisview_mnum lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Pool GarageNoOfCars Ground_elev Str_elev2012 Str_elev2016 Sewer NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber lndist_nearexit lndist_highway lndist_beach Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS lndist_brownfield ratio_Dev ratio_Fore ratio_Open"
* 
eststo House_all: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view 
eststo House_treat: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view  if SFHA_Dfirm==1
eststo House_control: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view  if SFHA_Dfirm==0
esttab House_* using "$results/Summary_sample.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")

eststo House_all: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view  [aweight=weight]
eststo House_treat: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view  [aweight=weight] if SFHA_Dfirm==1
eststo House_control: estpost sum SFHA_Dfirm Sandysurge_feet static_bfe $X2 elevation major_view  [aweight=weight] if SFHA_Dfirm==0
esttab House_* using "$results/Summary_matched.csv",replace cells("mean(fmt(3))" "sd(fmt(3) par)")
*N exported is plan count, not sum of weights. Need to change it.

tab SFHA_Dfirm, sum(BuildingAge)
tab SFHA_Dfirm, sum(SalesPrice)

tab LegalTownship, sum(SalesPrice)
eststo Salesbytown: estpost tab LegalTownship
esttab Salesbytown using"$results\bytown.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
eststo SalesbyYear: estpost tab Year
esttab SalesbyYear using"$results\SalesbyYear.csv", replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
global X2 "lnviewarea lnviewangle Lisview_mnum lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Pool GarageNoOfCars Ground_elev Sewer NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber lndist_nearexit lndist_highway lndist_beach Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS lndist_brownfield ratio_Dev ratio_Fore ratio_Open"

*regression adjustment on matched sample
eststo RA1: reg SalesPrice SFHA_Dfirm $X2 $FE i.fid_school [fweight=weight],vce(robust)

eststo RA2: reg SalesPrice SFHA_Dfirm $X2 $FE [fweight=weight],vce(robust)

eststo OLS: reg SalesPrice SFHA_Dfirm $X2 $FE i.fid_school, robust


eststo RA1_ln: reg Ln_Price SFHA_Dfirm $X2 $FE i.fid_school [fweight=weight],vce(robust)

eststo RA2_ln: reg Ln_Price SFHA_Dfirm $X2 $FE [fweight=weight],vce(robust)

*eststo RA3_ln: reg Ln_Price SFHA_Dfirm major_view $X2 $FE i.fid_school [fweight=weight],vce(robust)

eststo OLS_ln: reg Ln_Price SFHA_Dfirm $X2 $FE i.fid_school, robust
esttab RA1 RA2 OLS RA1_ln RA2_ln OLS_ln using"$results\results_SFHA_RA.csv", keep(SFHA_Dfirm $X2) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


eststo RA_Sandysurge: reg Ln_Price i.Sandysurge_feet $X2 $FE i.fid_school [fweight=weight],vce(robust)
eststo OLS_Sandysurge:reg Ln_Price i.Sandysurge_feet $X2 $FE i.fid_school,vce(robust)
eststo RA_surgeandDfirm: reg Ln_Price SFHA_Dfirm i.Sandysurge_feet $X2 $FE i.fid_school [fweight=weight],vce(robust)

esttab RA_Sandysurge OLS_Sandysurge using"$results\results_Sandysurge.csv", keep(*.Sandysurge_feet $X2) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
esttab RA_surgeandDfirm using"$results\results_Sandysurge.csv", keep(SFHA_Dfirm *.Sandysurge_feet $X2) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

coefplot RA_Sandysurge, saving("$results\Sandysurge_discount.gph",replace)  vertical keep(*.Sandysurge_feet) levels(90) recast(con) xlabel(,angle(45)) m(D) msize(small) mfcolor(white) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


//Things to be added:

*DID
gen PostSandy=(Year>=2012)
set more off
eststo DID_Dfirm: reg Ln_Price i.SFHA_Dfirm##i.PostSandy $X2 $FE i.fid_school [fweight=weight],vce(robust)
eststo DID_Sandysurge: reg Ln_Price i.Sandysurge_feet##i.PostSandy $X2 $FE i.fid_school [fweight=weight],vce(robust)
esttab DID_Dfirm DID_Sandysurge using"$results\results_DID_Dfirm_surge.csv", keep(1.SFHA_Dfirm 1.PostSandy 1.SFHA_Dfirm#1.PostSandy *.Sandysurge_feet *.Sandysurge_feet#1.PostSandy) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

 

set more off
use "$dta\data_analysis4.dta",clear
drop SalesYear
ren elevation Elevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren SQFT_liv SquareFootage
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit

foreach v in Elevation LISViewarea LISViewangle SquareFootage DistancetoCoast DistancetoHighwayExit  {
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA_Dfirm==1
gen `v'_0=`v' if SFHA_Dfirm==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' pre-match)
graph save "$results\\`v'_qqplot.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\Elevation_qqplot.gph" "$results\LISViewarea_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\DistancetoCoast_qqplot.gph" "$results\DistancetoHighwayExit_qqplot.gph", saving("$results\qqplot_pre.gph",replace)

set more off
use "$dta\data_analysis4.dta",clear
drop if weight==.
keep weight SFHA_Dfirm elevation Lisview_area total_viewangle SQFT_liv Dist_Coast Dist_exit_near1 
ren elevation Elevation
ren Lisview_area LISViewarea
ren total_viewangle LISViewangle
ren SQFT_liv SquareFootage
ren Dist_Coast DistancetoCoast
ren Dist_exit_near1 DistancetoHighwayExit

expand weight
foreach v in Elevation LISViewarea LISViewangle SquareFootage DistancetoCoast DistancetoHighwayExit   {
capture drop `v'_1 `v'_0
gen `v'_1=`v' if SFHA_Dfirm==1
gen `v'_0=`v' if SFHA_Dfirm==0
qqplot `v'_1 `v'_0,xtitle(SFHA=0) ytitle(SFHA=1) title(`v' post-match)
graph save "$results\\`v'_qqplot1.gph",replace
drop `v'_1 `v'_0
}
gr combine "$results\Elevation_qqplot1.gph" "$results\LISViewarea_qqplot1.gph" "$results\LISViewangle_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\DistancetoCoast_qqplot1.gph" "$results\DistancetoHighwayExit_qqplot1.gph", saving("$results\qqplot_post.gph",replace)

gr combine "$results\DistancetoCoast_qqplot.gph" "$results\SquareFootage_qqplot.gph" "$results\LISViewangle_qqplot.gph" "$results\DistancetoCoast_qqplot1.gph" "$results\SquareFootage_qqplot1.gph" "$results\LISViewangle_qqplot1.gph", saving("$results\qqplot_compare.gph",replace)


/*
*fixed effects model
*year by qt + tract by y + SFHA by year
set more off
clear all
set maxvar 30000
use "$dta\data_analysis5.dta",clear
set matsize 11000
set emptycells drop
global X2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber Lndist_coast Lndist_nwaterbody lndist_develop elevation_sq lndist_StatePark lndist_airp lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "Waterfront Pool i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS"
gen period=12*(Year-1997)+TransactionMonth
gen PostIrene=(period>176)
xtset ImportParcelID period

set more off
eststo RA_FE: xtreg SalesPrice i.period#SFHA i.Year#c.lnviewarea i.Year#c.lnviewangle withloan $match $RA i.period i.Year#i.fid_school i.TransactionMonth#i.fid_school [fweight=weight],fe
esttab RA_FE using"$results\results_SFHA_RAFE.csv", keep(*.period#1.SFHA withloan *.Year#c.lnviewarea *.Year#c.lnviewangle) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
coefplot RA_FE, vertical keep(*.period#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(0(50)252) xline(104 191 236 248,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


*without property fixed effects, but with school zone fixed effects
set more off
clear all
set maxvar 30000
use "$dta\data_analysis5.dta",clear
tab SFHA,sum(SalesPrice)
drop Ln_Price
gen Ln_Price=ln(SalesPrice)

set matsize 11000
set emptycells drop 
global X2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.FIPS"
global X3 "Lisview_mnum Lisview_ndist lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber Lndist_coast Lndist_nwaterbody lndist_develop elevation_sq lndist_StatePark lndist_airp lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X4 "lnBSQFT lnLSQFT BuildingAge BuildingAge_sq Waterfront Pool GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS ratio_Dev ratio_Fore ratio_Open"


gen Quarter=1 if TransactionMonth>=1&TransactionMonth<4
replace Quarter=2 if TransactionMonth>=4&TransactionMonth<7
replace Quarter=3 if TransactionMonth>=7&TransactionMonth<10
replace Quarter=4 if TransactionMonth>=10&TransactionMonth<=12
gen period=4*(Year-1997)+Quarter

set more off
eststo RA_noFE: reg SalesPrice i.period#SFHA i.period#c.lnviewarea i.period#c.lnviewangle withloan $X3 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [fweight=weight],cluster(fid_school)
esttab RA_noFE using"$results\results_SFHA_RAnoFE.csv", keep(*.period#1.SFHA withloan *.period#c.lnviewarea *.period#c.lnviewangle) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))
coefplot RA_noFE, saving("$results\SFHA_timetrend.gph",replace)  vertical keep(*.period#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(0(10)84) xline(35 59 64 79 83,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
coefplot RA_noFE, saving("$results\Viewshed_timetrend.gph",replace) vertical keep(*.period#c.lnviewarea) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(0(10)84) xline(35 59 64 79 83,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))


set more off
eststo RA: reg SalesPrice SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [aweight=weight],cluster(fid_school)

eststo OLS: reg SalesPrice SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school, cluster(fid_school)

eststo OLS_noview: reg SalesPrice SFHA withloan $X4 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school, cluster(fid_school)

eststo RA_ln: reg Ln_Price SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [aweight=weight],cluster(fid_school)

eststo OLS_ln: reg Ln_Price SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school, cluster(fid_school)

eststo OLS_noview_ln: reg Ln_Price SFHA withloan $X4 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school, cluster(fid_school)

esttab RA OLS OLS_noview RA_ln OLS_ln OLS_noview_ln using"$results\results_SFHA_RA1.csv", keep(SFHA $X2 withloan ) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

*Only include pre-Irene sample
set more off
eststo RA: reg SalesPriceAmount SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [aweight=weight] if period<59,cluster(fid_school)

eststo OLS: reg SalesPriceAmount SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school if period<59, cluster(fid_school)

eststo OLS_noview: reg SalesPriceAmount SFHA withloan $X4 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school if period<59, cluster(fid_school)

eststo RA_ln: reg Ln_Price SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [aweight=weight] if period<59,cluster(fid_school)

eststo OLS_ln: reg Ln_Price SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school if period<59, cluster(fid_school)

eststo OLS_noview_ln: reg Ln_Price SFHA withloan $X4 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school if period<59, cluster(fid_school)

esttab RA OLS OLS_noview RA_ln OLS_ln OLS_noview_ln using"$results\results_SFHA_RA1_PreIrene.csv", keep(SFHA $X2 withloan ) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


set more off
eststo RA_ln_trend: reg Ln_Price i.period#SFHA withloan $X2 $FE i.period i.fid_school i.Year#i.fid_school i.Quarter#i.fid_school [aweight=weight] if period<59,cluster(fid_school)
coefplot RA_ln_trend, saving("$results\SFHA_timetrend_preIrene.gph",replace)  vertical keep(*.period#1.SFHA) levels(90) recast(con) m(D) msize(small) mfcolor(white) xlabel(0(10)59) xline(35,lc(red)) base ciopts(recast(rconnected) msize(tiny) lwidth(vvthin))
*/





*Valuing Elevation/FEMA compliance
*Elevated 2012-2016
clear all
set more off
set maxvar 30000
set matsize 11000
use "$dta\data_analysis3_formatching.dta",clear
gen BuildingAge=Year-YearBuilt
drop if BuildingAge<0
gen BuildingAge_sq=BuildingAge*BuildingAge
gen lnBSQFT=ln(SQFT_liv)
gen lnLSQFT=ln(LotSizeSquareFeet+1)
sum lnLSQFT
replace lnLSQFT=r(mean) if lnLSQFT==.
gen lndist_airp=ln(Dist_Airport)
gen lndist_develop=ln(Dist_HDdevelop+1)
gen lndist_CBRS=ln(Dist_CBRS+1)
gen lndist_StatePark=ln(Dist_StatePark+1) 
gen lndist_nearexit=ln(Dist_exit_near1+1)
gen lndist_beach=ln(Dist_beach_near1+1)
gen lndist_highway=ln(Dist_freeway+1)
gen lndist_brownfield=ln(Dist_Brownfield+1)


*Transfer Prices in 2017 dollar
*Inflation Rate is based on Bureau of Labor Statistics CPI
replace SalesPrice=SalesPrice*1.80 if Year==1991
replace SalesPrice=SalesPrice*1.74 if Year==1992
replace SalesPrice=SalesPrice*1.69 if Year==1993
replace SalesPrice=SalesPrice*1.65 if Year==1994
replace SalesPrice=SalesPrice*1.61 if Year==1995
replace SalesPrice=SalesPrice*1.56 if Year==1996
replace SalesPrice=SalesPrice*1.53 if Year==1997
replace SalesPrice=SalesPrice*1.50 if Year==1998
replace SalesPrice=SalesPrice*1.47 if Year==1999
replace SalesPrice=SalesPrice*1.42 if Year==2000
replace SalesPrice=SalesPrice*1.38 if Year==2001
replace SalesPrice=SalesPrice*1.36 if Year==2002
replace SalesPrice=SalesPrice*1.33 if Year==2003
replace SalesPrice=SalesPrice*1.30 if Year==2004
replace SalesPrice=SalesPrice*1.25 if Year==2005
replace SalesPrice=SalesPrice*1.21 if Year==2006
replace SalesPrice=SalesPrice*1.18 if Year==2007
replace SalesPrice=SalesPrice*1.14 if Year==2008
replace SalesPrice=SalesPrice*1.14 if Year==2009
replace SalesPrice=SalesPrice*1.12 if Year==2010
replace SalesPrice=SalesPrice*1.09 if Year==2011
replace SalesPrice=SalesPrice*1.07 if Year==2012
replace SalesPrice=SalesPrice*1.05 if Year==2013
replace SalesPrice=SalesPrice*1.03 if Year==2014
replace SalesPrice=SalesPrice*1.03 if Year==2015
replace SalesPrice=SalesPrice*1.02 if Year==2016


keep if Year>1996
drop if NoOfUnits!=1
drop if SalesPrice<1000
drop if SalesPrice==.
*drop non arms-length transaction
sum SalesPrice,detail
drop if SalesPrice<=r(p1)|SalesPrice>=r(p99)
*drop price outlier
gen TransactionMonth=substr(RecordingDate,6,2)
destring TransactionMonth,replace
sort ImportParcelID Year TransactionMonth
duplicates tag ImportParcelID Year TransactionMonth,gen(duptrans)
gen neg_transprice=-SalesPrice
sort RowID Year TransactionMonth neg_transprice
duplicates drop RowID Year TransactionMonth duptrans,force
capture drop duptrans neg_transprice

duplicates tag ImportParcelID ,gen(NoOfTrans)
sort ImportParcelID Year
replace NoOfTrans=NoOfTrans+1

tab SFHA_Dfirm,sum(SalesPrice)

ren PropertyFullStreetAddress Address

duplicates report Address



gen elevatedft_1216=Str_elev2016-Str_elev2012
sum elevatedft_1216
hist elevatedft_1216
count if elevatedft_1216>7
gen elev_1216=(elevatedft_1216>7)


tab elev_1216

duplicates report ImportParcelID if elev_1216==1

*DID
gen post=(Year>=2016)
gen Ln_Price=ln(SalesPrice)
tab post elev_1216
count if post==1&elev_1216==1&Year>=2013


global X2 "lnviewarea lnviewangle Lisview_mnum lnBSQFT lnLSQFT  BuildingAge BuildingAge_sq Pool GarageNoOfCars Ground_elev Sewer NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber lndist_nearexit lndist_highway lndist_beach Lndist_coast Lndist_nwaterbody lndist_develop lndist_StatePark lndist_airp lndist_CBRS lndist_brownfield ratio_Dev ratio_Fore ratio_Open"

*i.fid_school#i.Year

set more off
eststo Elev_1: reg SalesPrice elev_1216##post SFHA_Dfirm $X2 i.fid_school 
eststo Elev_2: reg Ln_Price elev_1216##post SFHA_Dfirm $X2 i.fid_school 

esttab Elev_1 Elev_2 using"$results\results_Elevated.csv", keep(1.elev_1216 1.post 1.elev_1216#1.post SFHA_Dfirm lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))




*FEMA compliance
*3 towns for now

set more off
merge m:1 Address using"$dta\FEMA_compliance_CT.dta",keepusing(BuildingdiagramNo Floodzone FEMA_compl_project BFE)
drop if _merge==2

keep if LegalTownship=="FAIRFIELD"|LegalTownship=="STONINGTON"|LegalTownship=="OLD SAYBROOK"

gen EC=(FEMA_compl_project!=.)
replace FEMA_compl_project=0 if FEMA_compl_project==.

gen Stilt=(BuildingdiagramNo=="5"|BuildingdiagramNo=="6"|BuildingdiagramNo=="7")

set more off
eststo FEMAC_1: reg SalesPrice FEMA_compl_project SFHA_Dfirm $X2 i.fid_school 
eststo FEMAC_2: reg Ln_Price FEMA_compl_project SFHA_Dfirm $X2 i.fid_school 
eststo EC_1: reg SalesPrice EC SFHA_Dfirm $X2 i.fid_school 
eststo EC_2: reg Ln_Price EC SFHA_Dfirm $X2 i.fid_school 


esttab FEMAC_1 FEMAC_2 EC_1 EC_2 using"$results\results_FEMAC.csv", keep(FEMA_compl_project EC SFHA_Dfirm lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

set more off
eststo FEMAC_1: reg SalesPrice i.FEMA_compl_project##i.post SFHA_Dfirm $X2 i.fid_school 
eststo FEMAC_2: reg Ln_Price i.FEMA_compl_project##i.post SFHA_Dfirm $X2 i.fid_school 
eststo EC_1: reg SalesPrice i.EC##i.post SFHA_Dfirm $X2 i.fid_school 
eststo EC_2: reg Ln_Price i.EC##i.post SFHA_Dfirm $X2 i.fid_school 

reg SalesPrice Stilt SFHA_Dfirm $X2 i.fid_school 
reg Ln_Price Stilt SFHA_Dfirm $X2 i.fid_school 
reg Ln_Price Stilt SFHA_Dfirm $X2 i.fid_school if EC==1




*Sale probability
clear all
set more off
use "J:\Zitrax\dta\transaction_09.dta",clear
gen withloan=(LoanAmount>0)
keep TransId SalesPriceAmount RecordingDate withloan
ren SalesPriceAmount SalesPrice
merge 1:m TransId using"J:\Zitrax\dta\transaction_property_09.dta",keepusing(AssessorParcelNumber ImportParcelID PropertyFullStreetAddress PropertyCity)
drop if _merge!=3
gen TransactionYear=substr(RecordingDate,1,4)
destring TransactionYear,replace
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\data_analysis1_1.dta"
*merge m:1 ImportParcelID AssessorParcelNumber using"$dta\data_analysis4.dta"

drop if _merge==1
gen nosales=1 if _merge==2
drop _merge
tab TransactionYear
rename TransactionYear Year


*Inflation Rate is based on Bureau of Labor Statistics CPI
replace SalesPrice=SalesPrice*1.80 if Year==1991
replace SalesPrice=SalesPrice*1.74 if Year==1992
replace SalesPrice=SalesPrice*1.69 if Year==1993
replace SalesPrice=SalesPrice*1.65 if Year==1994
replace SalesPrice=SalesPrice*1.61 if Year==1995
replace SalesPrice=SalesPrice*1.56 if Year==1996
replace SalesPrice=SalesPrice*1.53 if Year==1997
replace SalesPrice=SalesPrice*1.50 if Year==1998
replace SalesPrice=SalesPrice*1.47 if Year==1999
replace SalesPrice=SalesPrice*1.42 if Year==2000
replace SalesPrice=SalesPrice*1.38 if Year==2001
replace SalesPrice=SalesPrice*1.36 if Year==2002
replace SalesPrice=SalesPrice*1.33 if Year==2003
replace SalesPrice=SalesPrice*1.30 if Year==2004
replace SalesPrice=SalesPrice*1.25 if Year==2005
replace SalesPrice=SalesPrice*1.21 if Year==2006
replace SalesPrice=SalesPrice*1.18 if Year==2007
replace SalesPrice=SalesPrice*1.14 if Year==2008
replace SalesPrice=SalesPrice*1.14 if Year==2009
replace SalesPrice=SalesPrice*1.12 if Year==2010
replace SalesPrice=SalesPrice*1.09 if Year==2011
replace SalesPrice=SalesPrice*1.07 if Year==2012
replace SalesPrice=SalesPrice*1.05 if Year==2013
replace SalesPrice=SalesPrice*1.03 if Year==2014
replace SalesPrice=SalesPrice*1.03 if Year==2015
replace SalesPrice=SalesPrice*1.02 if Year==2016


keep if Year>1996|Year==.
drop if NoOfUnits!=1

keep if LegalTownship=="FAIRFIELD" 
ren PropertyFullStreetAddress Address

duplicates report Address
drop if Address==""

merge m:1 Address using"$dta\Fairfield_permit.dta"
drop StreetNumber StreetName

drop if _merge==2
capture drop _merge
merge m:1 ImportParcelID using"$dta\Elev_pproperty1.dta"
drop if _merge==2
capture drop _merge
replace Elev_flag=0 if Elev_flag==.
tab Elev_flag
tab code
*code C means FEMA compliance, no time on it yet
gen FEMA_comp=1 if code=="C"
replace FEMA_comp=0 if FEMA_comp==.

keep if Year==2016|Year==2017|Year==.
duplicates report Address


capture drop transaction
gen transaction=0 if nosales==1
replace transaction=1 if Year==2016
replace transaction=1 if Year==2017

expand 2 if transaction==0
egen R=rank(_n) if transaction==0,by(Address)
tab R if transaction==0
replace Year=2016 if R==1
replace Year=2017 if R==2

tab Year
gen lnBSQFT=ln(BuildingSQFT)
gen lnLSQFT=ln(LotSizeSquareFeet)
gen BuildingAge_sq=BuildingAge*BuildingAge

global X2 "lnBSQFT lnLSQFT Pool GarageNoOfCars elevation NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculated AirCondition FireplaceNumber"
probit transaction Elev_flag FEMA_comp SFHA i.Year

/*
set more off
foreach V in lnviewarea BuildingSQFT LotSizeSquareFeet BuildingAge Lndist_coast elevation{
sum `V' if SFHA==1 
local a=r(mean)
sum `V' if SFHA==0
local b=r(mean)
kdensity `V' if SFHA==1, gen(`V'_treat) nograph at(`V')
kdensity `V' if SFHA==0, gen(`V'_control) nograph at(`V')
twoway (line `V'_treat `V' if SFHA==1, xline(`a') msize(vsmall) sort) ///
       (line `V'_control `V' if SFHA==0, xline(`b') sort), legend(order(1 "SFHA" 2 "Not SFHA"))
graph save `V',replace
drop `V'_treat `V'_control
}
gr combine lnviewarea.gph BuildingSQFT.gph LotSizeSquareFeet.gph BuildingAge.gph Lndist_coast.gph elevation.gph, saving("$results\Balance_pre.gph") ycom

set more off
foreach V in lnviewarea BuildingSQFT LotSizeSquareFeet BuildingAge Lndist_coast elevation{
sum `V' if SFHA==1 [iw=weight]
local a=r(mean)
sum `V' if SFHA==0 [iw=weight]
local b=r(mean)
*kdensity `V' if SFHA==1 [iw=weight], gen(`V'_treat) nograph at(`V')
*kdensity `V' if SFHA==0 [iw=weight], gen(`V'_control) nograph at(`V')
*twoway (line `V'_treat `V' if SFHA==1, xline(`a') msize(vsmall) sort) ///
       (line `V'_control `V' if SFHA==0, xline(`b') sort), legend(order(1 "SFHA" 2 "Not SFHA"))
*graph save `V',replace
*drop `V'_treat `V'_control
}
gr combine BuildingSQFT.gph LotSizeSquareFeet.gph BuildingAge.gph Lndist_coast.gph elevation.gph lnviewarea.gph, saving("$results\Balance_post.gph") ycom
*/


/*
use "$dta\data_analysis5.dta",clear
egen Price=mean(SalesPriceAmount),by(RowID)
duplicates drop Price RowID,force

*regression adjustment with average price of all transactions
global match "lnviewarea lnviewangle BuildingSQFT LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody GarageNoOfCars elevation elevation_sq NoOfBuildings NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount FireplaceNumber"
global RA "Waterfront Pool AirCondition Lisview_mnum Lisview_ndist i.BuildingCondition i.HeatingType i.FIPS"

eststo RA1: reg Price SFHA $match $RA i.fid_school [fweight=weight],cluster(fid_school)

eststo RA2: reg Price SFHA $match $RA [fweight=weight],cluster(fid_school)

eststo OLS: reg Price SFHA $match $RA i.fid_school,cluster(fid_school)

esttab RA1 RA2 OLS using"$results\results_SFHA_RA2.csv", keep(SFHA $match Pool AirCondition Lisview_mnum Lisview_ndist) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))


/*
use "$dta\data_analysis2.dta",clear
merge m:1 RowID using"$dta\viewshed_prop1.dta"
keep if _merge==3
drop _merge

global X "BuildingSQFT LotSizeSquareFeet BuildingAge Lndist_coast Lndist_nwaterbody Waterfront Pool GarageNoOfCars elevation NoOfBuildings NoOfUnits NoOfStories TotalRooms TotalBedrooms TotalCalculatedBathCount AirCondition FireplaceNumber"
reg Ln_Price SFHA $X i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS, cluster(fid_school)
reg SalesPrice SFHA $X i.BuildingCondition i.HeatingType i.SalesYear i.SalesMonth i.FIPS, cluster(fid_school)

