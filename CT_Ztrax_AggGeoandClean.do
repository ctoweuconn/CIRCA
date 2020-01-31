clear all
set more off
cap log close

*Change directories here
global zroot ""
global root ""
global dta "$root\dta"
global results "$root\results"
global Zitrax "$zroot\dta"

global gis ""



***************************************************************************
*   Merge with GIS variables, Update Lat&Long from Google Geocoding API   *
***************************************************************************
*Update Lat&Long from Google API
import delimited D:\Work\CIRCA\Circa\CT_Property\dta\prop_va_oneunitfix.csv, clear
gen firstcommapos=ustrpos(input_string,",")
gen CTpos=ustrpos(input_string,",CT")
gen PropertyFullStreetAddress=substr(input_string,1,firstcommapos-1)
gen PropertyCity=substr(input_string,firstcommapos+1,CTpos-firstcommapo-1)
gen State=substr(input_string,CTpos+1,2)
duplicates tag PropertyFullStreetAddress PropertyCity,gen(dup1)
drop dup1
duplicates drop
save "$dta0\prop_va_oneunitfixgoogle.dta",replace

*Aggregate distance variables
use "$dta0\proponeunit_building_revise.dta",clear
*use "$dta\property_oneunitcoastGgl.dta",clear
capture drop _merge
merge 1:1 FID using"$dta0\NearAirport.dta"
drop if _merge==1
drop _merge
merge 1:1 FID using"$dta0\NearHDdevelop.dta"
drop _merge
merge 1:1 FID using"$dta0\NearCBRS.dta"
drop _merge
merge 1:1 FID using"$dta0\NearStatePark.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearexit.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearpubbeach.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearfreeway.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearbrownfield.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearshore.dta"
drop if _merge==1
drop _merge
merge 1:1 FID using"$dta0\property_nearwaterbody.dta"
drop if _merge==1
drop _merge
merge 1:1 FID using"$dta0\property_nearrailroad.dta"
drop if _merge==1
drop _merge
merge 1:1 FID using"$dta0\property_disti95nyc.dta"
drop _merge
merge 1:1 FID using"$dta0\property_nearI95.dta"
drop _merge
save "$dta0\Distances.dta",replace

*Aggregate other geographic variables
use "$dta0\property_oneunitcoastGgl.dta",clear
drop _merge
merge 1:1 FID using"$dta0\Sewer_service.dta"
replace sewer_service=0 if sewer_service==.
drop _merge
merge 1:1 FID using"$dta0\property_schoold.dta"
*Since every property is supposed to have a school district, check what's happenning with unmatched
*1. Drop those with missing coordinates
drop if latgoogle==0
*2. Drop thos with missing addresses
drop if propertyfu==""
count if _merge==1
*3. The left over no-school-district properties are basically due to the simple polygon shape of the school district file.
*   So impute these (366) missing districts with legaltownship.
sort legaltowns propertyci fid_school Sch_District
replace fid_school = fid_school[_n-1] if fid_school==. & legaltowns==legaltowns[_n-1] &  propertyci==propertyci[_n-1]
replace Sch_District = Sch_District[_n-1] if trim(Sch_District)=="" & legaltowns==legaltowns[_n-1] &  propertyci==propertyci[_n-1]
count if Sch_District==""		
drop _merge
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren fips FIPS
ren state State
ren county County
ren legaltowns LegalTownship
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

*2012 Building SFHA assignment
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_brev_2012SFHA.dta"
replace SFHA_2012=0 if SFHA_2012==.
ren fld_zone fldzone_2012
ren static_bfe statbfe_2012
drop _merge
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\buildingpoly_2012SFHA.dta"
replace SFHA_poly2012=1 if SFHA_poly2012==.&SFHA_2012==1
replace SFHA_poly2012=0 if SFHA_poly2012==.
ren fld_zonepoly fldzone_poly2012
ren static_bfepoly statbfe_poly2012
drop _merge
tab SFHA_2012 SFHA_poly2012
*revise flood zone factors according to polygon SFHA results
replace SFHA_2012=SFHA_poly2012 if SFHA_2012!=SFHA_poly2012
*2169 revised
replace fldzone_2012=fldzone_poly2012 if fldzone_2012!=fldzone_poly2012&fldzone_poly2012!=""
*2574 revised
replace statbfe_2012=statbfe_poly2012 if statbfe_2012!=statbfe_poly2012&statbfe_poly2012!=.
*2620 revised

*2017 Building SFHA assignment
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_brev_2017SFHA.dta"
drop if _merge==2
replace SFHA_2017=0 if SFHA_2017==.
ren fld_zone fldzone_2017
ren static_bfe statbfe_2017
drop _merge
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\buildingpoly_2017SFHA.dta"
drop if _merge==2
replace SFHA_poly2017=1 if SFHA_poly2017==.&SFHA_2017==1
replace SFHA_poly2017=0 if SFHA_poly2017==.
ren fld_zonepoly fldzone_poly2017
ren static_bfepoly statbfe_poly2017
drop _merge
tab SFHA_2017 SFHA_poly2017
*revise flood zone factors according to polygon SFHA results
replace SFHA_2017=SFHA_poly2017 if SFHA_2017!=SFHA_poly2017
*2231 revised
replace fldzone_2017=fldzone_poly2017 if fldzone_2017!=fldzone_poly2017&fldzone_poly2017!=""
*3118 revised
replace statbfe_2017=statbfe_poly2017 if statbfe_2017!=statbfe_poly2017&statbfe_poly2017!=.
*3051 revised

*2019 Building SFHA assignment
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_brev_2019SFHA.dta"
drop if _merge==2
replace SFHA_2019=0 if SFHA_2019==.
ren fld_zone fldzone_2019
ren static_bfe statbfe_2019
drop _merge
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\buildingpoly_2019SFHA.dta"
drop if _merge==2
replace SFHA_poly2019=1 if SFHA_poly2019==.&SFHA_2019==1
replace SFHA_poly2019=0 if SFHA_poly2019==.
ren fld_zonepoly fldzone_poly2019
ren static_bfepoly statbfe_poly2019
drop _merge
tab SFHA_2019 SFHA_poly2019
*revise flood zone factors according to polygon SFHA results
replace SFHA_2019=SFHA_poly2019 if SFHA_2019!=SFHA_poly2019
*2306 revised
replace fldzone_2019=fldzone_poly2019 if fldzone_2019!=fldzone_poly2019&fldzone_poly2019!=""
*3243 revised
replace statbfe_2019=statbfe_poly2019 if statbfe_2019!=statbfe_poly2019&statbfe_poly2019!=.
*3141 revised

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\NearSFHA12boundary.dta",keepusing(Dist_12SFHA_B)
drop if _merge==2
drop _merge 
replace Dist_12SFHA_B=-Dist_12SFHA_B if SFHA_2012==1
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\NearSFHA17boundary.dta",keepusing(Dist_17SFHA_B)
drop if _merge==2
drop _merge 
replace Dist_17SFHA_B=-Dist_17SFHA_B if SFHA_2017==1
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\NearSFHA19boundary.dta",keepusing(Dist_19SFHA_B)
drop if _merge==2
drop _merge 
replace Dist_19SFHA_B=-Dist_19SFHA_B if SFHA_2019==1

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propertybrev_sandysurge.dta",keepusing(Sandysurge_feet)
replace Sandysurge_feet=0 if Sandysurge_feet==.
drop _merge
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propertybrev_irenesurge.dta",keepusing(Irenesurge_feet)
replace Irenesurge_feet=0 if Irenesurge_feet==.
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\waterfront_oneunitct.dta",keepusing(Waterfronttype)
gen Waterfront_ocean=(Waterfronttype=="W")
gen Waterfront_river=(Waterfronttype=="R")
gen Waterfront_street=(Waterfronttype=="S")
replace Waterfront_ocean=1 if PropertyCity=="NEW LONDON"&(PropertyFullStreetAddress=="810 PEQUOT AVE"|PropertyFullStreetAddress=="824 PEQUOT AVE"|PropertyFullStreetAddress=="836 PEQUOT AVE"|PropertyFullStreetAddress=="650 PEQUOT AVE"|PropertyFullStreetAddress=="670 PEQUOT AVE"|PropertyFullStreetAddress=="189 PEQUOT AVE"|PropertyFullStreetAddress=="195 PEQUOT AVE"|PropertyFullStreetAddress=="177 PEQUOT AVE")

/*The coding definitions are:
W = property effectively on the Sound
R = property on rivers or bays up to about Rt 95, but doesn’t include lakes, streams, etc.  Where to stop is always a judgement call, but this is an order of smallness not worth worrying about.
S = property across the street from the water with only the street and perhaps some open land (beach, rocks, or whatever) dividing the parcel from the water.  For the most part ‘S’ is only used along the sound but in some bays and rivers the property is sufficiently affected by proximity to water to make me mark it with an ‘S’.
*/
drop _merge
save "$dta0\GeoAttributes.dta",replace



*Merge
use "$dta0\data_oneunitcoastsale.dta",clear
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID LegalTownship using"$dta0\Distances.dta"
drop if _merge==2
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta0\Distances.dta",update
drop if _merge==2|_merge==1
drop _merge
*1237 still not merged,dropped

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID LegalTownship using"$dta0\GeoAttributes.dta"
drop if _merge==2
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta0\GeoAttributes.dta",update replace
drop if _merge==2
drop _merge
merge m:1 ImportParcelID using"$dta0\GeoAttributes.dta",update
drop if _merge==2|_merge==1
drop _merge

*Ground (building footprint) elevation and viewshed
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Ground_elevation2016.dta"
drop if _merge==2
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Viewshed_Ggl.dta"
drop if _merge==2
gen view_analysis=(_merge==3)
drop _merge

*Get ground elevation from NED to fill in unpopulated elevation
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Elevation.dta"
drop if _merge==2
*meters to feet
replace NED_elevation=NED_elevation*3.28084
replace NED_elevation=Ground_elev if NED_elevation==.
drop _merge

gen e_Elevation=Ground_elev
replace e_Elevation=NED_elevation if Ground_elev==.

*Landcover 2002
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\lcratio_2002.dta"
drop if _merge==2

drop orig_fid
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
sum `v'
replace `v'=r(mean) if `v'==.&_merge==1
replace `v'=0 if `v'==.
ren `v' `v'02
}
drop _merge
*Landcover 2011
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\lcratio_2011.dta"
drop if _merge==2
drop orig_fid
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
sum `v'
replace `v'=r(mean) if `v'==.&_merge==1
replace `v'=0 if `v'==.
ren `v' `v'11
}
drop _merge
*Landcover 2015
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\lcratio_2015.dta"
drop if _merge==2
drop orig_fid
foreach v in ratio_Dev ratio_Fore ratio_Open ratio_Ag {
sum `v'
replace `v'=r(mean) if `v'==.&_merge==1
replace `v'=0 if `v'==.
ren `v' `v'15
}
drop _merge

*Purge obs with inaccurate coordinates
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Ggl_points_toberevised.dta"
drop if _merge==2
gen Wrong_point_VA=(_merge==3)
*2319 wrong address points
drop diff_street diff_address PropertyStreet PropertyStreetNum
drop _merge
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,ustrpos(PropertyFullStreetAddress," ",2))
drop if trim(PropertyFullStreetAddress)==""
destring PropertyStreetNum,gen(address_num) force
sort address_num
gen address_num1=substr(PropertyStreetNum,1,1)
destring address_num1,replace force
drop if address_num1==.
/*restriction missing address number 3 dropped*/
drop PropertyStreetNum address_num address_num1

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\viewshedprop_buildingcoor.dta"
drop if _merge==2
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\pointcheck_NONVA.dta"
drop if _merge==2
drop _merge
*6241 wrong points in NONVA zone according to NONVA revision
gen Wrong_point_NONVA=1 if diff_address==1
tab Wrong_point_NONVA

*drop if Wrong_point_VA==1&buildingAM_rev!=1 (754)
drop if Wrong_point_VA==1&buildingAM_rev!=1&Wrong_point_NONVA==1
/*restriction drop 602 points that identified as wrong according to VA revision and not picked up by the NONVA revision*/
drop if Wrong_point_NONVA==1
/*restriction drop 5639 wrong points according to NONVA revision */
*Wrongly mapped points that dropped in total 6241

tab buildingAM_rev

gen Lat=latGoogle
gen Long=longGoogle
replace Lat=Lat_rev if Lat_rev!=.
replace Long=Long_rev if Long_rev!=.
replace buildingNM_rev=0 if buildingNM_rev==.
replace buildingAM_rev=0 if buildingAM_rev==.

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Viewshed_rev.dta"
drop if _merge==2
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\Viewshed_rev1.dta",keepusing(*rev PropertyFullStreetAddress PropertyCity ImportParcelID) update
drop if _merge==2
drop _merge

foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
replace `v'=`v'rev if buildingAM_rev==1
drop `v'rev
}
*about 300-500 viewshed revised due to the coordinate revision (out of 31,942 that viewshed has been analyzed)

*drop non-VA properties that do not fall in any parcel polygons
/*
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID  using"$dta\proponeunit_nonVA.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
count if buildingNM_rev==0&buildingAM_rev==0&_merge==1
count if buildingNM_rev==0&buildingAM_rev==0&_merge==3
*/
*get block median income
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta0\property_blockincome.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedianIncome)
drop if _merge==2
drop _merge
ren MedianIncome Block_MedInc
merge m:1 PropertyFullStreetAddress LegalTownship using"$dta0\LOMA_formerge.dta"
*760 transactions are merged with LOMAs, 1150 LOMAs are not merged
drop if _merge==2
drop _merge
ren IssueDate LOMADate
ren IssueYear LOMAYear
ren IssueMonth LOMAMonth
ren IssueDay LOMADay
ren Status LOMAStatus
ren StatusDate LOMAStatusDate
save "$dta0\oneunitcoastsale_Geo.dta",replace
************************************
*   End merge with GIS variables   *
************************************


************************************
*       Begin clean  variables     *
************************************
use "$dta0\oneunitcoastsale_Geo.dta",clear
tab PropertyCountyLandUseDescription
drop if NoOfBuilding==0 /*restriction 8 obs dropped*/
tab SFHA_2012, sum(SalesPrice)
tab SFHA_2017, sum(SalesPrice)

*Building age
count if e_YearBuilt==.
drop if e_YearBuilt==. /*restriction 291 dropped*/
gen e_BuildingAge=e_Year-e_YearBuilt
sum e_BuildingAge
drop if e_BuildingAge<0 /*restriction 40 dropped*/
gen e_BuildingAge_sq=e_BuildingAge*e_BuildingAge

*Building area
replace LotSizeAcres=LotSizeSquareFeet/43560 if LotSizeAcres==.&LotSizeSquareFeet!=.
replace LotSizeSquareFeet=LotSizeAcres*43560 if LotSizeSquareFeet==.&LotSizeAcres!=.

count if LotSizeSquareFeet==.|LotSizeSquareFeet==0
count if e_LandAssessedValue==.|e_LandAssessedValue==0
count if LotSizeSquareFeet==.&e_LandAssessedValue==.
drop if LotSizeSquareFeet==.&e_LandAssessedValue==.
/*restriction 76 likely misclassified condons dropped*/

count if SQFTBAG==.&SQFTBAL==.&SQFTBASE==.
count if e_SQFTBAG==.&e_SQFTBAL==.&e_SQFTBASE==.
count if LotSizeSquareFeet==.
count if e_LotSizeSquareFeet==.
drop if e_SQFTBAG==.&e_SQFTBAL==.&e_SQFTBASE==. /*restriction missing sqft 475 dropped*/
drop if e_LotSizeSquareFeet==./*restriction missing lotsize 19 dropped*/

gen e_SQFT_liv=e_SQFTBAL
gen e_SQFT_tot=e_SQFTBAG if e_SQFTBASE==.
replace e_SQFT_tot=e_SQFTBAG+e_SQFTBASE if e_SQFTBASE!=.
replace e_SQFT_tot=e_SQFT_liv if e_SQFT_tot==.
sum e_SQFT_liv e_SQFT_tot
drop if e_SQFT_liv==. /*restriction 12 missing SQFT*/
gen e_LnSQFT=ln(e_SQFT_liv)
gen e_LnSQFT_tot=ln(e_SQFT_tot)
gen e_LnLSQFT=ln(e_LotSizeSquareFeet+1)
sum e_LnLSQFT

*Standard attributes
sum e_NoOfStories
count if e_NoOfStories==.
replace e_NoOfStories=round(SQFTBAG/SQFTBAL) if e_NoOfStories==.
count if e_NoOfStories==.
replace e_NoOfStories=1 if e_NoOfStories==.
tab LegalTownship,sum(e_NoOfStories)
*imputed 2980 e_NoOfStories=1

sum e_GarageNoOfCars
tab LegalTownship,sum(e_GarageNoOfCars)
*several towns do not populate garage information at all
gen missing_garage=(e_GarageNoOfCars==.)
replace e_GarageNoOfCars=0 if e_GarageNoOfCars==.

sum e_FireplaceNumber
count if e_FireplaceNumber==.
tab LegalTownship,sum(e_FireplaceNumber)
tab e_FireplaceNumber,sum(e_YearBuilt)
sum e_FireplaceNumber
replace e_FireplaceNumber=r(mean) if e_FireplaceNumber==.
*This slightly biases town fixed effects

tab LegalTownship, sum(e_TotalBedrooms)
tab LegalTownship if e_TotalBedrooms==.
sum e_TotalBedrooms
replace e_TotalBedrooms=r(mean) if e_TotalBedrooms==.
*This slightly biased town fixed effects
sum e_TotalRooms
replace e_TotalRooms=r(mean) if e_TotalRooms==.
sum e_TotalCalculatedBathCount
replace e_TotalCalculatedBathCount=r(mean) if e_TotalCalculatedBathCount==.
sum e_NoOfBuildings
drop if e_NoOfBuildings==. /*restriction 25 missing noofbuildings*/

foreach v in e_BuildingConditionStndCode e_RoofStructureTypeStndCode e_HeatingTypeorSystemStndCode e_AirConditioningStndCode e_FoundationTypeStndCode e_PoolStndCode e_GarageStndCode {
replace `v'=trim(`v')
}
egen BuildingCondition=group(e_BuildingConditionStndCode)
replace BuildingCondition=0 if BuildingCondition==.
*BuildingCondition 0 means no building condition information
tab BuildingCondition
tab e_BuildingConditionStndCode

/*
group(e_Bui |
ldingCondit |
ionStndCode |
          ) |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     30,128       26.23       26.23
          1 |     54,236       47.22       73.44
          2 |      6,517        5.67       79.12
          3 |      1,109        0.97       80.08
          4 |     22,700       19.76       99.85
          5 |        176        0.15      100.00
          6 |          1        0.00      100.00
------------+-----------------------------------
      Total |    114,867      100.00
*/

egen HeatingType=group(e_HeatingTypeorSystemStndCode)
replace HeatingType=0 if HeatingType==.

egen RoofStructure=group(e_RoofStructureTypeStndCode)
replace RoofStructure=0 if RoofStructure==.

egen FoundationType=group(e_FoundationTypeStndCode)
replace FoundationType=0 if FoundationType==.
*Foundation types are mostly not populated

gen AirCondition=1 if AirConditioningStndCode=="YY"
replace AirCondition=0 if AirCondition==.


*All distances are in feet (Dist_I95_NYC in miles)
global Dist "Dist_I95_NYC Dist_Airport Dist_HDdevelop Dist_CBRS Dist_StatePark Dist_exit_near1 Dist_beach_near1 Dist_freeway Dist_NRailroad Dist_Brownfield Dist_Coast Dist_NWaterbody"
sum $Dist

gen Lndist_coast=ln(Dist_Coast+1)
gen Lndist_nwaterbody=ln(Dist_NWaterbody+1)
gen Lndist_airp=ln(Dist_Airport+1)
gen Lndist_develop=ln(Dist_HDdevelop+1)
gen Lndist_CBRS=ln(Dist_CBRS+1)
gen Lndist_StatePark=ln(Dist_StatePark+1) 
gen Lndist_nearexit=ln(Dist_exit_near1+1)
gen Lndist_beach=ln(Dist_beach_near1+1)
gen Lndist_highway=ln(Dist_freeway+1)
gen Lndist_I95=ln(Dist_I95+1)
gen Lndist_brownfield=ln(Dist_Brownfield+1)
gen Lndist_nrailroad=ln(Dist_NRailroad+1)

global LnDist "Lndist_coast Lndist_nwaterbody Lndist_airp Lndist_develop Lndist_CBRS Lndist_StatePark Lndist_nearexit Lndist_beach Lndist_highway Lndist_brownfield"
sum $LnDist

*Creating categorical Match variables 
*Use qualtiles and viewshed availability to devide bands
_pctile Dist_Coast,p(10(10)90)
*generate buffer categories every 10-percentile
capture drop Buffer_Coast
gen Buffer_Coast=0
foreach n of numlist 1/9 {
local l=`n'+1
replace Buffer_Coast=`n' if Dist_Coast>=r(r`n')&Dist_Coast<r(r`l')
di `n' "0th percentile-" r(r`n') " to " `l' "0th percentile-" r(r`l')
}
tab Buffer_Coast,sum(Dist_Coast)
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

egen town_Elevation=mean(e_Elevation), by(LegalTownship Buffer_Coast)
gen e_Elev_dev=e_Elevation-town_Elevation

capture gen e_Elev_devsq=e_Elev_dev*e_Elev_dev

*viewshed variables
hist Dist_Coast if total_viewangle>30, saving("$results\coastproxy_goodview.gph",replace)
replace Lisview_area=0 if Lisview_area==.
replace total_viewangle=0 if total_viewangle==.
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)

replace Lisview_mnum=0 if Lisview_mnum==.
replace Lisview_ndist=5280 if Lisview_ndist==.

replace view_analysis=0 if Wrong_point_VA==1&buildingAM_rev!=1&Wrong_point_NONVA!=1

*Land cover
gen ratio_Dev=ratio_Dev02
gen ratio_Fore=ratio_Fore02
gen ratio_Open=ratio_Open02
gen ratio_Ag=ratio_Ag02
replace ratio_Dev=ratio_Dev11 if e_Year>=2009
replace ratio_Fore=ratio_Fore11 if e_Year>=2009
replace ratio_Open=ratio_Open11 if e_Year>=2009
replace ratio_Ag=ratio_Ag11 if e_Year>=2009
replace ratio_Dev=ratio_Dev15 if e_Year>=2013
replace ratio_Fore=ratio_Fore15 if e_Year>=2013
replace ratio_Open=ratio_Open15 if e_Year>=2013
replace ratio_Ag=ratio_Ag15 if e_Year>=2013

*Sale time
gen SalesYear=substr(RecordingDate,1,4)
gen SalesMonth=substr(RecordingDate,6,2)
gen SalesDay=substr(RecordingDate,9,2)
destring SalesYear,replace
destring SalesMonth,replace
destring SalesDay,replace

*Flood risk factors
gen fldzone=fldzone_2012
gen BFE=statbfe_2012
gen SFHA=SFHA_2012
gen Dist_SFHAB=Dist_12SFHA_B

replace fldzone=fldzone_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>8)|(e_Year==2013&SalesMonth==8&SalesDay>5))&(LegalTownship=="STONINGTON"|LegalTownship=="GROTON"|LegalTownship=="NEW LONDON"|LegalTownship=="WATERFORD"|LegalTownship=="EAST LYME"|LegalTownship=="OLD LYME")
replace BFE=statbfe_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>8)|(e_Year==2013&SalesMonth==8&SalesDay>5))&(LegalTownship=="STONINGTON"|LegalTownship=="GROTON"|LegalTownship=="NEW LONDON"|LegalTownship=="WATERFORD"|LegalTownship=="EAST LYME"|LegalTownship=="OLD LYME")
replace SFHA=SFHA_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>8)|(e_Year==2013&SalesMonth==8&SalesDay>5))&(LegalTownship=="STONINGTON"|LegalTownship=="GROTON"|LegalTownship=="NEW LONDON"|LegalTownship=="WATERFORD"|LegalTownship=="EAST LYME"|LegalTownship=="OLD LYME")
replace Dist_SFHAB=Dist_17SFHA_B if (e_Year>2013|(e_Year==2013&SalesMonth>8)|(e_Year==2013&SalesMonth==8&SalesDay>5))&(LegalTownship=="STONINGTON"|LegalTownship=="GROTON"|LegalTownship=="NEW LONDON"|LegalTownship=="WATERFORD"|LegalTownship=="EAST LYME"|LegalTownship=="OLD LYME")

replace fldzone=fldzone_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>2)|(e_Year==2013&SalesMonth==2&SalesDay>6))&(LegalTownship=="OLD SAYBROOK"|LegalTownship=="WESTBROOK"|LegalTownship=="CLINTON")
replace BFE=statbfe_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>2)|(e_Year==2013&SalesMonth==2&SalesDay>6))&(LegalTownship=="OLD SAYBROOK"|LegalTownship=="WESTBROOK"|LegalTownship=="CLINTON")
replace SFHA=SFHA_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>2)|(e_Year==2013&SalesMonth==2&SalesDay>6))&(LegalTownship=="OLD SAYBROOK"|LegalTownship=="WESTBROOK"|LegalTownship=="CLINTON")
replace Dist_SFHAB=Dist_17SFHA_B if (e_Year>2013|(e_Year==2013&SalesMonth>2)|(e_Year==2013&SalesMonth==2&SalesDay>6))&(LegalTownship=="OLD SAYBROOK"|LegalTownship=="WESTBROOK"|LegalTownship=="CLINTON")

replace fldzone=fldzone_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="STRATFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="FAIRFIELD"|LegalTownship=="WESTPORT"|LegalTownship=="DARIEN"|LegalTownship=="STAMFORD"|LegalTownship=="GREENWICH"|LegalTownship=="MADISON"|LegalTownship=="WEST HAVEN")
replace BFE=statbfe_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="STRATFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="FAIRFIELD"|LegalTownship=="WESTPORT"|LegalTownship=="DARIEN"|LegalTownship=="STAMFORD"|LegalTownship=="GREENWICH"|LegalTownship=="MADISON"|LegalTownship=="WEST HAVEN")
replace SFHA=SFHA_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="STRATFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="FAIRFIELD"|LegalTownship=="WESTPORT"|LegalTownship=="DARIEN"|LegalTownship=="STAMFORD"|LegalTownship=="GREENWICH"|LegalTownship=="MADISON"|LegalTownship=="WEST HAVEN")
replace Dist_SFHAB=Dist_17SFHA_B if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="STRATFORD"|LegalTownship=="BRIDGEPORT"|LegalTownship=="FAIRFIELD"|LegalTownship=="WESTPORT"|LegalTownship=="DARIEN"|LegalTownship=="STAMFORD"|LegalTownship=="GREENWICH"|LegalTownship=="MADISON"|LegalTownship=="WEST HAVEN")

replace fldzone=fldzone_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>10)|(e_Year==2013&SalesMonth==10&SalesDay>16))&(LegalTownship=="NORWALK")
replace BFE=statbfe_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>10)|(e_Year==2013&SalesMonth==10&SalesDay>16))&(LegalTownship=="NORWALK")
replace SFHA=SFHA_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>10)|(e_Year==2013&SalesMonth==10&SalesDay>16))&(LegalTownship=="NORWALK")
replace Dist_SFHAB=Dist_17SFHA_B if (e_Year>2013|(e_Year==2013&SalesMonth>10)|(e_Year==2013&SalesMonth==10&SalesDay>16))&(LegalTownship=="NORWALK")

replace fldzone=fldzone_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace BFE=statbfe_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace SFHA=SFHA_2017 if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace Dist_SFHAB=Dist_17SFHA_B if (e_Year>2013|(e_Year==2013&SalesMonth>7)|(e_Year==2013&SalesMonth==7&SalesDay>8))&(LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")

replace fldzone=fldzone_2019 if (e_Year>2017|(e_Year==2017&SalesMonth>5)|(e_Year==2017&SalesMonth==5&SalesDay>16))&(LegalTownship=="GUILFORD"|LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace BFE=statbfe_2019 if (e_Year>2017|(e_Year==2017&SalesMonth>5)|(e_Year==2017&SalesMonth==5&SalesDay>16))&(LegalTownship=="GUILFORD"|LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace SFHA=SFHA_2019 if (e_Year>2017|(e_Year==2017&SalesMonth>5)|(e_Year==2017&SalesMonth==5&SalesDay>16))&(LegalTownship=="GUILFORD"|LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")
replace Dist_SFHAB=Dist_19SFHA_B if (e_Year>2017|(e_Year==2017&SalesMonth>5)|(e_Year==2017&SalesMonth==5&SalesDay>16))&(LegalTownship=="GUILFORD"|LegalTownship=="BRANFORD"|LegalTownship=="EAST HAVEN"|LegalTownship=="NEW HAVEN"|LegalTownship=="MILFORD")

*Revise Flood zone info based on LOMA
gen SalesDate=mdy(SalesMonth,SalesDay,SalesYear)
format SalesDate %tdnn/dd/CCYY

count if LOMADate!=.
count if SalesDate>=LOMADate
count if SalesDate>=LOMADate&SFHA==1
replace SFHA=0 if SFHA==1&SalesDate>=LOMADate&LOMAStatus!="LOMCs Superseded"
replace SFHA=0 if SFHA==1&(SalesDate>=LOMADate&SalesDate<=LOMAStatusDate)&LOMAStatus=="LOMCs Superseded"
*180 changed SFHA status

drop if BuildingConditionStndCode=="PR"|BuildingConditionStndCode=="UD"

*calculate pre-FIRM/post-FIRM
replace e_EffectiveYearBuilt=e_YearBuilt if e_EffectiveYearBuilt==.
gen post_FIRM=(e_YearBuilt>1977) if LegalTownship=="BRANFORD"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="BRIDGEPORT"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="CLINTON"
replace post_FIRM=(e_YearBuilt>1981) if LegalTownship=="DARIEN"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="EAST HAVEN"
replace post_FIRM=(e_YearBuilt>1981) if LegalTownship=="EAST LYME"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="FAIRFIELD"
replace post_FIRM=(e_YearBuilt>1977) if LegalTownship=="GREENWICH"
replace post_FIRM=(e_YearBuilt>1977) if LegalTownship=="GROTON"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="GUILFORD"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="LYME"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="MADISON"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="MILFORD"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="NEW HAVEN"
replace post_FIRM=(e_YearBuilt>1977) if LegalTownship=="NEW LONDON"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="NORWALK"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="OLD LYME"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="OLD SAYBROOK"
replace post_FIRM=(e_YearBuilt>1981) if LegalTownship=="STAMFORD"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="STONINGTON"
replace post_FIRM=(e_YearBuilt>1978) if LegalTownship=="STRATFORD"
replace post_FIRM=(e_YearBuilt>1981) if LegalTownship=="WATERFORD"
replace post_FIRM=(e_YearBuilt>1979) if LegalTownship=="WEST HAVEN"
replace post_FIRM=(e_YearBuilt>1982) if LegalTownship=="WESTBROOK"
replace post_FIRM=(e_YearBuilt>1980) if LegalTownship=="WESTPORT"
tab LegalTownship,sum(post_FIRM)

/*
merge m:1 RowID using "$dta\firstrow_sc2.dta",keepusing(RowID)
drop if _merge==2
gen Coastfront=(_merge==3)
drop _merge
*/
gen Coastfront1=(Dist_Coast<=300) 
*ZC: A place holder for waterfront
tab Coastfront1
tab Waterfront_ocean
tab Waterfront_river
tab Waterfront_street

*Declare global variable sets
global View1 "Lisview_area total_viewangle Lisview_mnum Lisview_ndist"
global View2 "lnviewarea lnviewangle Lisview_mnum Lisview_ndist"
sum $View1 $View2

global FRisk "Sandysurge_feet Irenesurge_feet fldzone BFE SFHA post_FIRM"

global StndX "e_LnSQFT e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_NoOfBuildings e_TotalCalculatedBathCount  e_GarageNoOfCars e_Pool e_FireplaceNumber AirCondition e_TotalBedrooms e_TotalRooms e_NoOfStories BuildingCondition HeatingType"
sum $StndX
global Geo "Waterfront_* e_Elev_dev e_Elev_devsq Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev fid_school sewer_service"
sum $Geo

global Match_continue "lnviewarea lnviewangle e_Elev_dev Dist_I95_NYC Lndist_brownfield Lndist_highway Lndist_nrailroad Lndist_beach Lndist_nearexit Lndist_StatePark Lndist_CBRS Lndist_develop Lndist_airp Lndist_nwaterbody Lndist_coast ratio_Ag ratio_Open ratio_Fore ratio_Dev e_SQFT_liv e_LotSizeSquareFeet e_BuildingAge e_NoOfBuildings e_TotalCalculatedBathCount e_GarageNoOfCars e_FireplaceNumber  e_TotalBedrooms e_NoOfStories"
save "$dta0\oneunitcoastsale_formatch.dta",replace

hist Dist_Coast if Dist_Coast<=60000, xtitle(Distance to the Coastline) xline(3168,lc(red))
*******************************
*     End clean variables     *
*******************************
