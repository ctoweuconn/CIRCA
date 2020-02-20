clear all
set more off
cap log close
set seed 123456789
*Change directories here
global root ""
global dta "$root\dta"
global results "$root\results"
global Zitrax ""
global GISdata ""

***************************
*   Developing criteria   *
***************************
set more off
use "$dta\Allassess_oneunitcoastal_nodup.dta",clear
set seed 1234567
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\proponeunit_building_revise.dta"
drop if _merge==1|_merge==2
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"

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
drop connected_add*
drop ID

*Extremely small lots - nonconforming <10k
hist e_LotSizeSquareFeet if e_LotSizeSquareFeet<=30000
gen small_nonconforming=(e_LotSizeSquareFeet<10000)
save "$dta\oneunit_lots.dta",replace
tab small_nonconforming
keep if small_nonconforming==1
*keep housing value too

keep ImportParcelID PropertyFullStreetAddress PropertyCity FIPS State County lat_rev long_rev small_nonconforming e_LotSizeSquareFeet e_TotalAssessedValue e_ImprovementAssessedValue
*lat_rev long_rev are the revised coordinates
compress
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Small_lots.csv", replace
save "$dta\Nonconforming_lots.dta",replace

*Block median income
*merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockincome.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedianIncome)

*100 yr SLR - 20inch MHHW
set more off
use "$GISdata\building_100yrSLR.dta",clear
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
gen twentyinch_SLR=1 
save "$dta\building_100yrSLR.dta",replace
*merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\building_100yrSLR.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID twentyinch_SLR)
/*
*Combining the criteria 1-individual property value
set more off
use "$dta\proponeunit_building_revise.dta",clear
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockincome.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedianIncome)
drop if _merge==2
drop if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockMedHV.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedHouseValue)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\building_100yrSLR.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID twentyinch_SLR)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Nonconforming_lots.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID small_nonconforming e_TotalAssessedValue)
drop if _merge!=3
drop _merge
hist MedianIncome
hist MedHouseValue
hist e_TotalAssessedValue
sum e_TotalAssessedValue, d
*keep if MedianIncome<70000
keep if e_TotalAssessedValue<200000
tab LegalTownship
duplicates report PropertyFullStreetAddress PropertyCity ImportParcelID 
save "$dta\Scenario_1_toberemoved.dta",replace
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Scenario_1_toberemoved.csv", replace


*Combining the criteria 2-block median house value
set more off
use "$dta\proponeunit_building_revise.dta",clear
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockincome.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedianIncome)
drop if _merge==2
drop if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockMedHV.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedHouseValue)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\building_100yrSLR.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID twentyinch_SLR)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Nonconforming_lots.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID small_nonconforming e_TotalAssessedValue)
drop if _merge!=3
drop _merge
hist MedianIncome
hist MedHouseValue
hist e_TotalAssessedValue
sum e_TotalAssessedValue, d
keep if MedHouseValue<400000
tab LegalTownship
duplicates report PropertyFullStreetAddress PropertyCity ImportParcelID 
save "$dta\Scenario_2_toberemoved.dta",replace
ren PropertyFullStreetAddress propertyfu
ren PropertyCity propertyci
merge 1:1 propertyfu propertyci using"$dta\Sewer_service.dta"
drop if _merge==2
drop _merge
replace sewer_service=0 if sewer_service==.
ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity

keep PropertyFullStreetAddress PropertyCity FIPS State County LegalTownship ImportParcelID lat_rev long_rev MedianIncome MedHouseValue twentyinch_SLR e_TotalAssessedValue small_nonconforming sewer_service
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Scenario_2_toberemoved.csv", replace
*/

*Building long term full retreat scenario - 100-year SLR, non-conforming lot
set more off
use "$dta\proponeunit_building_revise.dta",clear
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockincome.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedianIncome)
drop if _merge==2
drop if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\property_blockMedHV.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID MedHouseValue)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\building_100yrSLR.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID twentyinch_SLR)
drop if _merge!=3
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Nonconforming_lots.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID small_nonconforming e_TotalAssessedValue e_ImprovementAssessedValue)
drop if _merge!=3
drop _merge
hist MedianIncome
hist MedHouseValue
hist e_TotalAssessedValue
sum e_TotalAssessedValue, d
*50th percentile 257145
*200,000 about 40th percentile
ren PropertyFullStreetAddress propertyfu
ren PropertyCity propertyci
merge 1:1 propertyfu propertyci using"$dta\Sewer_service.dta"
drop if _merge==2
drop _merge
replace sewer_service=0 if sewer_service==.
ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity
tab sewer_service

tab LegalTownship
keep PropertyFullStreetAddress PropertyCity FIPS State County LegalTownship ImportParcelID lat_rev long_rev MedianIncome MedHouseValue twentyinch_SLR e_TotalAssessedValue e_ImprovementAssessedValue small_nonconforming sewer_service
duplicates report PropertyFullStreetAddress PropertyCity ImportParcelID 
save "$dta\Scenario_Baseline_toberemoved.dta",replace
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Scenario_Baseline_toberemoved.csv", replace

*Buiding long term cost effective scenario - SLR, non-conforming lot, property value, then look at no public sewer service
set more off
use "$dta\Scenario_Baseline_toberemoved.dta",clear
*Select houses whose value is below 250k
keep if e_TotalAssessedValue<=250000
*Not quite strict on sewer service
tab sewer_service
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Scenario1_toberemoved.csv", replace
*It is then hand picked based on spatial continuity, sewer service, and historic district

*Buiding long term meet-the-needs scenario - SLR, non-conforming lot, *structure* value, then look at no public sewer service
set more off
use "$dta\Scenario_Baseline_toberemoved.dta",clear
*Select houses whose value is below 250k
hist e_ImprovementAssessedValue if e_ImprovementAssessedValue<=70000
sum e_ImprovementAssessedValue,d
keep if e_ImprovementAssessedValue<=60000 /*about the 25th percentile*/
*Not quite strict on sewer service
tab sewer_service
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\Scenario2_toberemoved.csv", replace
*It is then hand picked based on spatial continuity, sewer service, and historic district



*getting statistics
*Short-term retreat scenario
set more off
use "$GISdata\scenario2050_remove_final.dta",clear
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
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propOneunitcoastal.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID e_TotalAssessedValue)
drop if _merge!=3
drop _merge
*merge
sum e_TotalAssessedValue
save "$dta\scenario2050_remove_final.dta",replace

set more off
use "$GISdata\baseline_remove_final.dta",clear
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
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propOneunitcoastal.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID e_TotalAssessedValue)
drop if _merge!=3
drop _merge
sum e_TotalAssessedValue
save "$dta\baseline_remove_final.dta",replace

set more off
use "$GISdata\scenario1_remove_final.dta",clear
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
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propOneunitcoastal.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID e_TotalAssessedValue)
drop if _merge!=3
drop _merge
replace project="OldSaybrook1" if project=="Oldsaybrook1"
*merge
sum e_TotalAssessedValue
tab project, sum(e_TotalAssessedValue)
tab project
save "$dta\scenario1_remove_final.dta",replace


set more off
use "$GISdata\scenario2_remove_final.dta",clear
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
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\propOneunitcoastal.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID e_TotalAssessedValue e_ImprovementAssessedValue)
drop if _merge!=3
drop _merge
replace project="OldSaybrook1" if project=="Oldsaybrook1"
*merge
sum e_TotalAssessedValue e_ImprovementAssessedValue
tab project, sum(e_ImprovementAssessedValue)
tab project, sum(e_TotalAssessedValue)
tab project
save "$dta\scenario2_remove_final.dta",replace


************************************************
*       Viewshed changes - Short term          *
************************************************
*Short-term 2050 SLR
clear all
set more off
use "$GISdata\buildingp_va_scenario2050.dta",clear
ren fid_build FID_Buildingfootprint
gen FID=_n-1
save "$dta\buildingp_scenario2050.dta",replace

*Linking fid to addresses (through original buildingfootprint_fid)
use "$GISdata\proponeunit_link_building.dta",clear
ren fid_build FID_Buildingfootprint
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren legaltowns LegalTownship
save "$dta\proponeunit_link_building_final.dta",replace


*5603-Apirl2019
clear all
set more off
use "D:\Work\CIRCA\Circa\ViewshedScenario2050_poly\LISview_2.dta",clear
forv n=0 (1) 5603 {
capture append using "D:\Work\CIRCA\Circa\ViewshedScenario2050_poly\LISview_`n'.dta"
}
duplicates drop

ren near_fid FID

merge m:1 FID using"$dta\buildingp_scenario2050.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if near_dist==-1

egen Lisview_area=sum(area_geo),by(FID_Buildingfootprint)
hist area_geo if area_geo<10000

*from meters to feet
replace near_dist=near_dist*3.28084
*agg small but connected area
gen angle=floor(near_angle)
egen agg_area=sum(area_geo),by(angle FID_Buildingfootprint)
gen Lisview_major=1 if agg_area>10000
egen Lisview_mndist=min(near_dist) if Lisview_major==1, by(FID_Buildingfootprint)

gen neg_area_geo=-area_geo
sort FID angle neg_area_geo
duplicates drop angle FID_Buildingfootprint Lisview_major,force
egen Lisview_mnum=sum(Lisview_major),by(FID_Buildingfootprint)

egen Lisview_ndist=mean(Lisview_mndist),by(FID_Buildingfootprint)


gen wide_angle=1 if area_geo<1000
gen wide_angle1=360*area_geo/(3.141593*(5280*5280-near_dist*near_dist))   if Lisview_major==1&wide_angle!=1
replace wide_angle1=1 if wide_angle1<1

*perimeter not reliable since outlines are not straight
gen wide_angle2=360*(perim_geo-2*(5280-near_dist))/(2*3.141593*5280)   if Lisview_major==1&wide_angle!=1
*wide angle 
replace wide_angle=wide_angle1 if wide_angle==.
capture drop total_angle

egen total_angle=sum(wide_angle) if wide_angle>1, by(FID_Buildingfootprint)
capture drop total_viewangle
egen total_viewangle=mean(total_angle),by(FID_Buildingfootprint)
replace total_viewangle=1 if total_viewangle==.

capture drop major_viewshed
gen major_viewshed=(wide_angle>30&wide_angle!=.)
egen major_view=max(major_viewshed), by(FID_Buildingfootprint)

keep _merge FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge


merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'_SC2050
}
ren FID_Buildingfootprint FID_Buildingfootprint_SC2050
save "$dta\Viewshed_scenario2050.dta",replace

*Preview the viewshed changes
use "$dta\proponeunit_building_revise.dta",clear
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_Ggl.dta"
drop if _merge==2
gen view_analysis=(_merge==3)
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_rev.dta", update replace
drop if _merge==2
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_rev1.dta",keepusing(*rev PropertyFullStreetAddress PropertyCity ImportParcelID) update
drop if _merge==2
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
replace `v'=`v'rev if `v'rev!=.
drop `v'rev
}
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID  using "$dta\Viewshed_scenario2050.dta"
drop if _merge==2
drop _merge
order FID FID_Buildingfootprint FID_Buildingfootprint_SC2050 Lisview_area Lisview_area_SC2050 total_viewangle total_viewangle_SC2050
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
drop if _merge==3

count if total_viewangle>total_viewangle_SC2050& total_viewangle_SC2050!=.
*********************************************************
* Viewshed data Retreat —— Baseline/longtermfullretreat *
*********************************************************
clear all
set more off
use "$GISdata\buildingp_va_baseline.dta",clear
ren fid_build FID_Buildingfootprint
gen FID=_n-1
save "$dta\buildingp_baseline.dta",replace

*29472-Apirl2019
clear all
set more off
use "D:\Work\CIRCA\Circa\ViewshedBaseline_poly\LISview_0.dta",clear
forv n=0 (1) 29473 {
capture append using "D:\Work\CIRCA\Circa\ViewshedBaseline_poly\LISview_`n'.dta"
}
duplicates drop

ren near_fid FID

merge m:1 FID using"$dta\buildingp_baseline.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if near_dist==-1

egen Lisview_area=sum(area_geo),by(FID_Buildingfootprint)
hist area_geo if area_geo<10000

*from meters to feet
replace near_dist=near_dist*3.28084
*agg small but connected area
gen angle=floor(near_angle)
egen agg_area=sum(area_geo),by(angle FID_Buildingfootprint)
gen Lisview_major=1 if agg_area>10000
egen Lisview_mndist=min(near_dist) if Lisview_major==1, by(FID_Buildingfootprint)

gen neg_area_geo=-area_geo
sort FID angle neg_area_geo
duplicates drop angle FID_Buildingfootprint Lisview_major,force
egen Lisview_mnum=sum(Lisview_major),by(FID_Buildingfootprint)

egen Lisview_ndist=mean(Lisview_mndist),by(FID_Buildingfootprint)


gen wide_angle=1 if area_geo<1000
gen wide_angle1=360*area_geo/(3.141593*(5280*5280-near_dist*near_dist))   if Lisview_major==1&wide_angle!=1
replace wide_angle1=1 if wide_angle1<1

*perimeter not reliable since outlines are not straight
gen wide_angle2=360*(perim_geo-2*(5280-near_dist))/(2*3.141593*5280)   if Lisview_major==1&wide_angle!=1
*wide angle 
replace wide_angle=wide_angle1 if wide_angle==.
capture drop total_angle

egen total_angle=sum(wide_angle) if wide_angle>1, by(FID_Buildingfootprint)
capture drop total_viewangle
egen total_viewangle=mean(total_angle),by(FID_Buildingfootprint)
replace total_viewangle=1 if total_viewangle==.

capture drop major_viewshed
gen major_viewshed=(wide_angle>30&wide_angle!=.)
egen major_view=max(major_viewshed), by(FID_Buildingfootprint)

keep _merge FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge


merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'_baseline
}
ren FID_Buildingfootprint FID_Buildingfootprint_baseline
save "$dta\Viewshed_baseline.dta",replace

*Preview the viewshed changes
use "$dta\proponeunit_building_revise.dta",clear
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_Ggl.dta"
drop if _merge==2
gen view_analysis=(_merge==3)
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_rev.dta", update replace
drop if _merge==2
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_rev1.dta",keepusing(*rev PropertyFullStreetAddress PropertyCity ImportParcelID) update
drop if _merge==2
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
replace `v'=`v'rev if `v'rev!=.
drop `v'rev
}
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID  using"$dta\Viewshed_baseline.dta"
drop if _merge==2
drop _merge
order FID FID_Buildingfootprint FID_Buildingfootprint_baseline Lisview_area Lisview_area_baseline total_viewangle total_viewangle_baseline

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID  using"$dta\oneunit_lots.dta", keepusing(e_TotalAssessedValue)
drop if _merge!=3
drop _merge
merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID  using"$dta\GeoAttributes.dta"
drop if _merge!=3
drop _merge

save "$dta\proponeunit_forsimulation.dta",replace

***************************************************
* Viewshed data ——Scenario1/longtermcosteffective *
***************************************************
clear all
set more off
use "$GISdata\buildingp_va_scenario1.dta",clear
ren fid_build FID_Buildingfootprint
gen FID=_n-1
save "$dta\buildingp_scenario1.dta",replace


*6694-Apirl2019
clear all
set more off
use "D:\Work\CIRCA\Circa\ViewshedScenario1_poly\\LISview_0.dta",clear
forv n=0 (1) 6694 {
capture append using "D:\Work\CIRCA\Circa\ViewshedScenario1_poly\\LISview_`n'.dta"
}
duplicates drop

ren near_fid FID

merge m:1 FID using"$dta\buildingp_scenario1.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if near_dist==-1

egen Lisview_area=sum(area_geo),by(FID_Buildingfootprint)
hist area_geo if area_geo<10000

*from meters to feet
replace near_dist=near_dist*3.28084
*agg small but connected area
gen angle=floor(near_angle)
egen agg_area=sum(area_geo),by(angle FID_Buildingfootprint)
gen Lisview_major=1 if agg_area>10000
egen Lisview_mndist=min(near_dist) if Lisview_major==1, by(FID_Buildingfootprint)

gen neg_area_geo=-area_geo
sort FID angle neg_area_geo
duplicates drop angle FID_Buildingfootprint Lisview_major,force
egen Lisview_mnum=sum(Lisview_major),by(FID_Buildingfootprint)

egen Lisview_ndist=mean(Lisview_mndist),by(FID_Buildingfootprint)


gen wide_angle=1 if area_geo<1000
gen wide_angle1=360*area_geo/(3.141593*(5280*5280-near_dist*near_dist))   if Lisview_major==1&wide_angle!=1
replace wide_angle1=1 if wide_angle1<1

*perimeter not reliable since outlines are not straight
gen wide_angle2=360*(perim_geo-2*(5280-near_dist))/(2*3.141593*5280)   if Lisview_major==1&wide_angle!=1
*wide angle 
replace wide_angle=wide_angle1 if wide_angle==.
capture drop total_angle

egen total_angle=sum(wide_angle) if wide_angle>1, by(FID_Buildingfootprint)
capture drop total_viewangle
egen total_viewangle=mean(total_angle),by(FID_Buildingfootprint)
replace total_viewangle=1 if total_viewangle==.

capture drop major_viewshed
gen major_viewshed=(wide_angle>30&wide_angle!=.)
egen major_view=max(major_viewshed), by(FID_Buildingfootprint)

keep _merge FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge



merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'_scenario1
}
ren FID_Buildingfootprint FID_Buildingfootprint_scenario1
save "$dta\Viewshed_scenario1.dta",replace


***************************************************
*  Viewshed data ——Scenario2/longtermmeettheneeds *
***************************************************
clear all
set more off
use "$GISdata\buildingp_va_scenario2.dta",clear
ren fid_build FID_Buildingfootprint
gen FID=_n-1
save "$dta\buildingp_scenario2.dta",replace


*4054-Apirl2019
clear all
set more off

use "D:\Work\CIRCA\Circa\ViewshedScenario2_poly\LISview_7.dta",clear
forv n=0 (1) 4054 {
capture append using "D:\Work\CIRCA\Circa\ViewshedScenario2_poly\LISview_`n'.dta"
}
duplicates drop

ren near_fid FID

merge m:1 FID using"$dta\buildingp_scenario2.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if near_dist==-1

egen Lisview_area=sum(area_geo),by(FID_Buildingfootprint)
hist area_geo if area_geo<10000

*from meters to feet
replace near_dist=near_dist*3.28084
*agg small but connected area
gen angle=floor(near_angle)
egen agg_area=sum(area_geo),by(angle FID_Buildingfootprint)
gen Lisview_major=1 if agg_area>10000
egen Lisview_mndist=min(near_dist) if Lisview_major==1, by(FID_Buildingfootprint)

gen neg_area_geo=-area_geo
sort FID angle neg_area_geo
duplicates drop angle FID_Buildingfootprint Lisview_major,force
egen Lisview_mnum=sum(Lisview_major),by(FID_Buildingfootprint)

egen Lisview_ndist=mean(Lisview_mndist),by(FID_Buildingfootprint)


gen wide_angle=1 if area_geo<1000
gen wide_angle1=360*area_geo/(3.141593*(5280*5280-near_dist*near_dist))   if Lisview_major==1&wide_angle!=1
replace wide_angle1=1 if wide_angle1<1

*perimeter not reliable since outlines are not straight
gen wide_angle2=360*(perim_geo-2*(5280-near_dist))/(2*3.141593*5280)   if Lisview_major==1&wide_angle!=1
*wide angle 
replace wide_angle=wide_angle1 if wide_angle==.
capture drop total_angle

egen total_angle=sum(wide_angle) if wide_angle>1, by(FID_Buildingfootprint)
capture drop total_viewangle
egen total_viewangle=mean(total_angle),by(FID_Buildingfootprint)
replace total_viewangle=1 if total_viewangle==.

capture drop major_viewshed
gen major_viewshed=(wide_angle>30&wide_angle!=.)
egen major_view=max(major_viewshed), by(FID_Buildingfootprint)

keep _merge FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge

merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'_scenario2
}
ren FID_Buildingfootprint FID_Buildingfootprint_scenario2
save "$dta\Viewshed_scenario2.dta",replace

****************************************************
*    New Waterfront properties due to the removal  *
****************************************************
use "$GISdata\newwaterfrontp_baseline.dta",clear
ren fid_build FID_Buildingfootprint
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren legaltowns LegalTownship
gen Waterfront_baseline=1 
save "$dta\newwaterfront_baseline.dta",replace

use "$GISdata\newwaterfrontp_scenario1.dta",clear
ren fid_build FID_Buildingfootprint
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren legaltowns LegalTownship
gen Waterfront_scenario1=1 
save "$dta\newwaterfront_scenario1.dta",replace

use "$GISdata\newwaterfrontp_scenario2.dta",clear
ren fid_build FID_Buildingfootprint
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren legaltowns LegalTownship
gen Waterfront_scenario2=1 
save "$dta\newwaterfront_scenario2.dta",replace

use "$GISdata\newwaterfrontp_scenario2050.dta",clear
ren fid_build FID_Buildingfootprint
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren legaltowns LegalTownship
gen Waterfront_scenario2050=1 
save "$dta\newwaterfront_scenario2050.dta",replace

*********************************************************************************************************
*  Simulated Property value change from viewshed change and water front status_Short term full retreat  *
*********************************************************************************************************
/*Short-term full retreat: assume that all nonconforming (i.e., lot size below 10k sqft) 
properties within the projected 20inch-sea-level-rise (SLR) area in 2050 are removed. 
(Most of these properties are on the coast.)*/

 *fixed effects model
*year by qt + tract by y + SFHA by year
*Trend

clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " "_b[Waterfront_street]
esttab using"$results\results_Simu_scenario2050.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force

*tab AssessmentYear
*drop if AssessmentYear!=2017

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2050.dta", keepusing(Lisview_area_SC2050 Lisview_mnum_SC2050 total_viewangle_SC2050)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_SC2050=ln(Lisview_area_SC2050+1)
gen lnviewangle_SC2050=ln(total_viewangle_SC2050+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_SC2050=`v' if `v'_SC2050==.
}

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario2050.dta", keepusing(Waterfront_scenario2050)
drop if _merge==2
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_SC2050=(_merge==3)
drop _merge

sum lnviewarea lnviewarea_SC2050
sum lnviewangle lnviewangle_SC2050
sum Lisview_mnum Lisview_mnum_SC2050
capture drop delta_angle
gen delta_angle=total_viewangle_SC2050-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_SC2050
browse if neg_change_angle==1&remove_SC2050==0
replace remove_SC2050=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_SC2050
*Do not include insignificant coefficients
*gen MarketValue_baseline=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[Lisview_mnum]*Lisview_mnum+_b[lnviewangle]*lnviewangle_baseline+_b[Lisview_mnum]*Lisview_mnum_baseline)
gen MarketValue_SC2050=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+_b[lnviewangle]*lnviewangle_SC2050+_b[lnviewarea]*lnviewarea_SC2050)

sum MarketValue_SC2050 MarketValue

capture drop delta_MV_SC2050
gen delta_MV_SC2050=MarketValue_SC2050-MarketValue
sum delta_MV_SC2050
sum delta_MV_SC2050 if remove_SC2050==0
sum delta_MV_SC2050 if remove_SC2050==1
sum lnviewarea lnviewarea_SC2050 if remove_SC2050==0
sum lnviewangle lnviewangle_SC2050 if remove_SC2050==0
sum Lisview_mnum Lisview_mnum_SC2050 if remove_SC2050==0

capture drop Taxbaseloss_SC2050
egen Taxbaseloss_SC2050=sum(0.75*MarketValue) if remove_SC2050==1,by(LegalTownship)
capture drop Taxbasegain_SC2050

egen Taxbasegain_SC2050=sum(0.75*delta_MV_SC2050) if remove_SC2050==0,by(LegalTownship)
replace Taxbasegain_SC2050=. if remove_SC2050==0&delta_MV_SC2050==0

recast long Taxbaseloss_SC2050 Taxbasegain_SC2050

tab LegalTownship,sum(Taxbaseloss_SC2050)
tab LegalTownship,sum(Taxbasegain_SC2050)

tab remove_SC2050

*Calculate NPV for 30 years tax gain through viewshed
replace delta_MV_SC2050=. if remove_SC2050==1
foreach n of numlist 1(1)30{
gen NPV_DVview`n'=delta_MV_SC2050/((1+0.05)^`n')
}
gen NPV_DVview30years=0

foreach n of numlist 1(1)30{
replace NPV_DVview30years=NPV_DVview30years+NPV_DVview`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxRview_30years=0.75*NPV_DVview30years*Mill_rate/1000
egen NPV_30yTaxRview_SC2050=sum(NPV_DTaxRview_30years), by(LegalTownship)
replace NPV_30yTaxRview_SC2050=. if remove_SC2050==1
replace NPV_30yTaxRview_SC2050=. if delta_MV_SC2050==0
tab LegalTownship,sum(NPV_30yTaxRview_SC2050)


replace Waterfront_scenario2050=Waterfront_street if Waterfront_scenario2050==.
gen MarketValue_SC2050_WF=exp(ln(MarketValue)-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario2050)
gen delta_MV_SC2050WF=MarketValue_SC2050_WF-MarketValue
sum delta_MV_SC2050WF
sum delta_MV_SC2050WF if remove_SC2050==0
sum delta_MV_SC2050WF if remove_SC2050==1

egen TaxbasegainWF_SC2050=sum(0.75*delta_MV_SC2050WF) if remove_SC2050==0,by(LegalTownship)
replace TaxbasegainWF_SC2050=. if remove_SC2050==0&delta_MV_SC2050WF==0
tab LegalTownship,sum(TaxbasegainWF_SC2050)

*Calculate NPV for 30 years tax gain through waterfront
replace delta_MV_SC2050WF=. if remove_SC2050==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_SC2050WF/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_SC2050=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_SC2050=. if remove_SC2050==1
drop if delta_MV_SC2050WF==.
tab LegalTownship,sum(NPV_30yTaxR_SC2050)

*********************************************************************************************************
*  Simulated Property value change from viewshed change and water front status _Long term full retreat  *
*********************************************************************************************************
/*The long term full retreat scenario selects non-conforming (to minimum size limits – selected by a threshold of 10k square foot) properties 
 with 100-year sea level rise (SLR, defined by 20-inch Mean Higher High Water/MHHW). 
*/
*Referred as Baseline scenario in data
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " " _b[Waterfront_street]
esttab using"$results\results_Simu_baseline.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force

*tab AssessmentYear
*drop if AssessmentYear!=2017

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_baseline.dta", keepusing(Lisview_area_baseline Lisview_mnum_baseline total_viewangle_baseline)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_baseline=ln(Lisview_area_baseline+1)
gen lnviewangle_baseline=ln(total_viewangle_baseline+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_baseline=`v' if `v'_baseline==.
}


merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_baseline.dta", keepusing(Waterfront_baseline)
drop if _merge==2
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_baseline=(_merge==3)
drop _merge

sum lnviewarea lnviewarea_baseline
sum lnviewangle lnviewangle_baseline
sum Lisview_mnum Lisview_mnum_baseline
capture drop delta_angle
gen delta_angle=total_viewangle_baseline-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_baseline
browse if neg_change_angle==1&remove_baseline==0
replace remove_baseline=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_baseline
*Do not include insignificant coefficients
*gen MarketValue_baseline=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[Lisview_mnum]*Lisview_mnum+_b[lnviewangle]*lnviewangle_baseline+_b[Lisview_mnum]*Lisview_mnum_baseline)
gen MarketValue_baseline=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+_b[lnviewangle]*lnviewangle_baseline+_b[lnviewarea]*lnviewarea_baseline)

sum MarketValue_baseline MarketValue

capture drop delta_MV_baseline
gen delta_MV_baseline=MarketValue_baseline-MarketValue
sum delta_MV_baseline
sum delta_MV_baseline if remove_baseline==0
sum delta_MV_baseline if remove_baseline==1
sum lnviewarea lnviewarea_baseline if remove_baseline==0
sum lnviewangle lnviewangle_baseline if remove_baseline==0
sum Lisview_mnum Lisview_mnum_baseline if remove_baseline==0


capture drop Taxbaseloss_baseline
egen Taxbaseloss_baseline=sum(0.75*MarketValue) if remove_baseline==1,by(LegalTownship)
capture drop Taxbasegain_baseline

egen Taxbasegain_baseline=sum(0.75*delta_MV_baseline) if remove_baseline==0,by(LegalTownship)
replace Taxbasegain_baseline=. if remove_baseline==0&delta_MV_baseline==0

recast long Taxbaseloss_baseline Taxbasegain_baseline

tab LegalTownship,sum(Taxbaseloss_baseline)
tab LegalTownship,sum(Taxbasegain_baseline)

tab remove_baseline

*Calculate NPV for 30 years tax gain through viewshed
replace delta_MV_baseline=. if remove_baseline==1
foreach n of numlist 1(1)30{
gen NPV_DVview`n'=delta_MV_baseline/((1+0.05)^`n')
}
gen NPV_DVview30years=0

foreach n of numlist 1(1)30{
replace NPV_DVview30years=NPV_DVview30years+NPV_DVview`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxRview_30years=0.75*NPV_DVview30years*Mill_rate/1000
egen NPV_30yTaxRview_baseline=sum(NPV_DTaxRview_30years), by(LegalTownship)
replace NPV_30yTaxRview_baseline=. if remove_baseline==1
replace NPV_30yTaxRview_baseline=. if delta_MV_baseline==0
tab LegalTownship,sum(NPV_30yTaxRview_baseline)


replace Waterfront_baseline=Waterfront_street if Waterfront_baseline==.
gen MarketValue_baseline_WF=exp(ln(MarketValue)-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_baseline)
gen delta_MV_baselineWF=MarketValue_baseline_WF-MarketValue
sum delta_MV_baselineWF
sum delta_MV_baselineWF if remove_baseline==0
sum delta_MV_baselineWF if remove_baseline==1

egen TaxbasegainWF_baseline=sum(0.75*delta_MV_baselineWF) if remove_baseline==0,by(LegalTownship)
replace TaxbasegainWF_baseline=. if remove_baseline==0&delta_MV_baselineWF==0
tab LegalTownship,sum(TaxbasegainWF_baseline)

*Calculate NPV for 30 years tax gain through waterfront

replace delta_MV_baselineWF=. if remove_baseline==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_baselineWF/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_baseline=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_baseline=. if remove_baseline==1
drop if delta_MV_baselineWF==0
tab LegalTownship,sum(NPV_30yTaxR_baseline)

**************************************************************************************************
*  Simulated Viewshed/Waterfront changes and Property value change _S1 - longtermcosteffective   *
**************************************************************************************************
/*Scenario 1, Long-term cost-effective retreat: on top of the criteria for Retreat Scenario 2, add a 
filter on total assessed value (less than or equal to $250k), look for spatial contiguity, consider 
project scale, and prioritize properties without public sewer service. 
*/
*fixed effects model
*year by qt + tract by y + SFHA by year
*Trend

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum]  " " _b[Waterfront_street]
esttab using"$results\results_Simu_scenario1.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum Waterfront_street) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario1.dta", keepusing(Lisview_area_scenario1 Lisview_mnum_scenario1 total_viewangle_scenario1)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_scenario1=ln(Lisview_area_scenario1+1)
gen lnviewangle_scenario1=ln(total_viewangle_scenario1+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_scenario1=`v' if `v'_scenario1==.
}

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario1.dta", keepusing(Waterfront_scenario1)
drop if _merge==2
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario1=(_merge==3)
drop _merge

sum lnviewarea lnviewarea_scenario1
sum lnviewangle lnviewangle_scenario1
sum Lisview_mnum Lisview_mnum_scenario1
capture drop delta_angle
gen delta_angle=total_viewangle_scenario1-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_scenario1
browse if neg_change_angle==1&remove_scenario1==0
*
replace remove_scenario1=1 if neg_change_angle==1


capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario1
*Only include significant coefficients
*gen MarketValue_scenario1=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[Lisview_mnum]*Lisview_mnum+_b[lnviewangle]*lnviewangle_scenario1+_b[Lisview_mnum]*Lisview_mnum_scenario1)
gen MarketValue_scenario1=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+_b[lnviewangle]*lnviewangle_scenario1+_b[lnviewarea]*lnviewarea_scenario1)

sum MarketValue_scenario1 MarketValue

capture drop delta_MV_scenario1
gen delta_MV_scenario1=MarketValue_scenario1-MarketValue
sum delta_MV_scenario1
sum delta_MV_scenario1 if remove_scenario1==0
sum delta_MV_scenario1 if remove_scenario1==1
sum lnviewarea lnviewarea_scenario1 if remove_scenario1==0
sum lnviewangle lnviewangle_scenario1 if remove_scenario1==0
sum Lisview_mnum Lisview_mnum_scenario1 if remove_scenario1==0


capture drop Taxbaseloss_scenario1
egen Taxbaseloss_scenario1=sum(0.75*MarketValue) if remove_scenario1==1,by(LegalTownship)
capture drop Taxbasegain_scenario1

egen Taxbasegain_scenario1=sum(0.75*delta_MV_scenario1) if remove_scenario1==0,by(LegalTownship)
replace Taxbasegain_scenario1=. if remove_scenario1==0&delta_MV_scenario1==0

recast long Taxbaseloss_scenario1 Taxbasegain_scenario1

tab LegalTownship,sum(Taxbaseloss_scenario1)
tab LegalTownship,sum(Taxbasegain_scenario1)

tab remove_scenario1

*Calculate NPV for 30 years tax gain through viewshed
replace delta_MV_scenario1=. if remove_scenario1==1
foreach n of numlist 1(1)30{
gen NPV_DVview`n'=delta_MV_scenario1/((1+0.05)^`n')
}
gen NPV_DVview30years=0

foreach n of numlist 1(1)30{
replace NPV_DVview30years=NPV_DVview30years+NPV_DVview`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxRview_30years=0.75*NPV_DVview30years*Mill_rate/1000
egen NPV_30yTaxRview_scenario1=sum(NPV_DTaxRview_30years), by(LegalTownship)
replace NPV_30yTaxRview_scenario1=. if remove_scenario1==1
replace NPV_30yTaxRview_scenario1=. if delta_MV_scenario1==0
tab LegalTownship,sum(NPV_30yTaxRview_scenario1)

*Waterfront gain
replace Waterfront_scenario1=Waterfront_street if Waterfront_scenario1==.
gen MarketValue_scenario1_WF=exp(ln(MarketValue)-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario1)
gen delta_MV_scenario1WF=MarketValue_scenario1_WF-MarketValue
sum delta_MV_scenario1WF
sum delta_MV_scenario1WF if remove_scenario1==0
sum delta_MV_scenario1WF if remove_scenario1==1

egen TaxbasegainWF_scenario1=sum(0.75*delta_MV_scenario1WF) if remove_scenario1==0,by(LegalTownship)
replace TaxbasegainWF_scenario1=. if remove_scenario1==0&delta_MV_scenario1WF==0
tab LegalTownship,sum(TaxbasegainWF_scenario1)

*Calculate NPV for 30 years tax gain through waterfront
replace delta_MV_scenario1WF=. if remove_scenario1==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario1WF/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario1=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario1=. if remove_scenario1==1
drop if delta_MV_scenario1WF==0
tab LegalTownship,sum(NPV_30yTaxR_scenario1)

*************************************************************************************************
*  Simulated Viewshed/Waterfront changes and Property value change _S2 - longtermmeettheneeds   *
*************************************************************************************************
/*Scenario2: Long-term meet-the-needs retreat: this selection applies the same strategy as Retreat 
Scenario 3, except the filter added is on building assessed value (less than or equal to 
$60k). This scenario intents to mimic the situation where structures that are repeatedly 
damaged and hence have quite low values are removed.
*/
*fixed effects model
*year by qt + tract by y + SFHA by year
*Trend

/*To be updated
*/
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " " _b[Waterfront_street]
esttab using"$results\results_Simu_scenario2.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum Waterfront_street) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2.dta", keepusing(Lisview_area_scenario2 Lisview_mnum_scenario2 total_viewangle_scenario2)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_scenario2=ln(Lisview_area_scenario2+1)
gen lnviewangle_scenario2=ln(total_viewangle_scenario2+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_scenario2=`v' if `v'_scenario2==.
}

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario2.dta", keepusing(Waterfront_scenario2)
drop if _merge==2
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2=(_merge==3)
drop _merge

sum lnviewarea lnviewarea_scenario2
sum lnviewangle lnviewangle_scenario2
sum Lisview_mnum Lisview_mnum_scenario2
capture drop delta_angle
gen delta_angle=total_viewangle_scenario2-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_scenario2
browse if neg_change_angle==1&remove_scenario2==0
*
replace remove_scenario2=1 if neg_change_angle==1


capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario2
*Only include significant coefficients
*gen MarketValue_scenario1=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[Lisview_mnum]*Lisview_mnum+_b[lnviewangle]*lnviewangle_scenario1+_b[Lisview_mnum]*Lisview_mnum_scenario1)
gen MarketValue_scenario2=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+_b[lnviewangle]*lnviewangle_scenario2+_b[lnviewarea]*lnviewarea_scenario2)

sum MarketValue_scenario2 MarketValue

capture drop delta_MV_scenario2
gen delta_MV_scenario2=MarketValue_scenario2-MarketValue
sum delta_MV_scenario2
sum delta_MV_scenario2 if remove_scenario2==0
sum delta_MV_scenario2 if remove_scenario2==1
sum lnviewarea lnviewarea_scenario2 if remove_scenario2==0
sum lnviewangle lnviewangle_scenario2 if remove_scenario2==0
sum Lisview_mnum Lisview_mnum_scenario2 if remove_scenario2==0

capture drop Taxbaseloss_scenario2
egen Taxbaseloss_scenario2=sum(0.75*MarketValue) if remove_scenario2==1,by(LegalTownship)
capture drop Taxbasegain_scenario2

egen Taxbasegain_scenario2=sum(0.75*delta_MV_scenario2) if remove_scenario2==0,by(LegalTownship)
replace Taxbasegain_scenario2=. if remove_scenario2==0&delta_MV_scenario2==0


recast long Taxbaseloss_scenario2 Taxbasegain_scenario2

tab LegalTownship,sum(Taxbaseloss_scenario2)
tab LegalTownship,sum(Taxbasegain_scenario2)
tab remove_scenario2

*Calculate NPV for 30 years tax gain through viewshed
replace delta_MV_scenario2=. if remove_scenario2==1
foreach n of numlist 1(1)30{
gen NPV_DVview`n'=delta_MV_scenario2/((1+0.05)^`n')
}
gen NPV_DVview30years=0

foreach n of numlist 1(1)30{
replace NPV_DVview30years=NPV_DVview30years+NPV_DVview`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxRview_30years=0.75*NPV_DVview30years*Mill_rate/1000
egen NPV_30yTaxRview_scenario2=sum(NPV_DTaxRview_30years), by(LegalTownship)
replace NPV_30yTaxRview_scenario2=. if remove_scenario2==1
replace NPV_30yTaxRview_scenario2=. if delta_MV_scenario2==0
tab LegalTownship,sum(NPV_30yTaxRview_scenario2)


replace Waterfront_scenario2=Waterfront_street if Waterfront_scenario2==.
gen MarketValue_scenario2_WF=exp(ln(MarketValue)-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario2)
gen delta_MV_scenario2WF=MarketValue_scenario2_WF-MarketValue
sum delta_MV_scenario2WF
sum delta_MV_scenario2WF if remove_scenario2==0
sum delta_MV_scenario2WF if remove_scenario2==1

egen TaxbasegainWF_scenario2=sum(0.75*delta_MV_scenario2WF) if remove_scenario2==0,by(LegalTownship)
replace TaxbasegainWF_scenario2=. if remove_scenario2==0&delta_MV_scenario2WF==0
tab LegalTownship,sum(TaxbasegainWF_scenario2)

*drop if remove_scenario==1
replace delta_MV_scenario2WF=. if remove_scenario2==1
*Calculate NPV for 30 years tax gain through waterfront
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario2WF/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario2=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario2=. if remove_scenario2==1
drop if delta_MV_scenario2WF==0
tab LegalTownship,sum(NPV_30yTaxR_scenario2)


*********************************************************************************************************
*    Simulate the Value changes brought by changed public open space - longtermcost-effective retreat   *
*********************************************************************************************************
use "$GISdata\Openspace_100mN_scenario1.dta",clear
ren fid_build FID_Buildingfootprint

keep fid_nopens FID_Buildingfootprint area
egen PublicOpenSpace=sum(area),by(FID_Buildingfootprint)
drop area
duplicates drop
duplicates report FID_Buildingfootprint
sort fid_nopens FID_Buildingfootprint
merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
gen total_buffer_area=3.14159265*328*328
gen openspace_delta_R=PublicOpenSpace/total_buffer_area
sum openspace_delta_R
save "$dta\Increase_openspace_scenario1.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Increase_openspace_scenario1.dta", keepusing(openspace_delta_R)
drop if _merge==2|_merge==1
drop _merge
replace openspace_delta_R=0 if openspace_delta_R==.

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario1=(_merge==3)
drop _merge

gen delta_openspace=(openspace_delta_R>0)


capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario1
*Parameter 0.0826 for public openspace is borrowed from Irwin 2002
gen MarketValue_scenario1=exp(ln(MarketValue)+0.0826*openspace_delta_R)

sum MarketValue_scenario1 MarketValue

capture drop delta_MV_scenario1
gen delta_MV_scenario1=MarketValue_scenario1-MarketValue
sum delta_MV_scenario1
sum delta_MV_scenario1 if remove_scenario1==0
sum delta_MV_scenario1 if remove_scenario1==1

capture drop Taxbasegain_scenario1
egen Taxbasegain_scenario1=sum(0.75*delta_MV_scenario1) if remove_scenario1==0,by(LegalTownship)
replace Taxbasegain_scenario1=. if remove_scenario1==0&delta_MV_scenario1==0

recast long Taxbasegain_scenario1
tab LegalTownship,sum(Taxbasegain_scenario1)

tab remove_scenario1
*Calculate NPV for 30 years tax gain through openspace
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario1/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario1=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario1=. if remove_scenario1==1
tab LegalTownship,sum(NPV_30yTaxR_scenario1)


*********************************************************************************************************
*    Simulate the Value changes brought by changed public open space - longterm meet-the-needs retreat   *
*********************************************************************************************************
use "$GISdata\Openspace_100mN_scenario2.dta",clear
ren fid_build FID_Buildingfootprint

keep fid_nopens FID_Buildingfootprint area
egen PublicOpenSpace=sum(area),by(FID_Buildingfootprint)
drop area
duplicates drop
duplicates report FID_Buildingfootprint
sort fid_nopens FID_Buildingfootprint
merge 1:m FID_Buildingfootprint using"$dta\proponeunit_link_building_final.dta",keepusing(PropertyFullStreetAddress PropertyCity LegalTownship ImportParcelID)
drop if _merge!=3
drop _merge
gen total_buffer_area=3.14159265*328*328
gen openspace_delta_R=PublicOpenSpace/total_buffer_area
sum openspace_delta_R
save "$dta\Increase_openspace_scenario2.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Increase_openspace_scenario2.dta", keepusing(openspace_delta_R)
drop if _merge==2|_merge==1
drop _merge
replace openspace_delta_R=0 if openspace_delta_R==.

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2=(_merge==3)
drop _merge

gen delta_openspace=(openspace_delta_R>0)


capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario1
*Parameter 0.0826 for public openspace is borrowed from Irwin 2002
gen MarketValue_scenario2=exp(ln(MarketValue)+0.0826*openspace_delta_R)

sum MarketValue_scenario2 MarketValue

capture drop delta_MV_scenario2
gen delta_MV_scenario2=MarketValue_scenario2-MarketValue
sum delta_MV_scenario2
sum delta_MV_scenario2 if remove_scenario2==0
sum delta_MV_scenario2 if remove_scenario2==1

capture drop Taxbasegain_scenario2
egen Taxbasegain_scenario2=sum(0.75*delta_MV_scenario2) if remove_scenario2==0,by(LegalTownship)
replace Taxbasegain_scenario2=. if remove_scenario2==0&delta_MV_scenario2==0

recast long Taxbasegain_scenario2
tab LegalTownship,sum(Taxbasegain_scenario2)

tab remove_scenario2

*Calculate NPV for 30 years tax gain through openspace
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario2/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario2=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario2=. if remove_scenario2==1
tab LegalTownship,sum(NPV_30yTaxR_scenario2)


************************************************************************************************************
*    Simulate the Value changes brought by removing damaged houses via spillover - shortterm full retreat   *
************************************************************************************************************
use "$GISdata\scenario2050_spillover.dta",clear
ren fid_build FID_Buildingfootprint
drop fid_buildi fid_buil_1 fid_coast2 fid_point

ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity
ren importparc ImportParcelID
save "$dta\scenario2050_removingdamaged_spillover.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2|_merge==1
gen increase_damageremoval=1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2050=(_merge==3)
drop _merge

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario2050
*Parameter 0.0826 for public openspace is borrowed from Irwin 2002
gen MarketValue_scenario2050=exp(ln(MarketValue)+0.0101*increase_damageremoval)

sum MarketValue_scenario2050 MarketValue

capture drop delta_MV_scenario2050
gen delta_MV_scenario2050=MarketValue_scenario2050-MarketValue
sum delta_MV_scenario2050
sum delta_MV_scenario2050 if remove_scenario2050==0
sum delta_MV_scenario2050 if remove_scenario2050==1

capture drop Taxbasegain_scenario2050
egen Taxbasegain_scenario2050=sum(0.75*delta_MV_scenario2050) if remove_scenario2050==0,by(LegalTownship)
replace Taxbasegain_scenario2050=. if remove_scenario2050==0&delta_MV_scenario2050==0

recast long Taxbasegain_scenario2050
tab LegalTownship,sum(Taxbasegain_scenario2050)

tab remove_scenario2050
*Calculate NPV for 30 years tax gain through spillover
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario2050/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_SC2050=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_SC2050=. if remove_scenario2050==1
tab LegalTownship,sum(NPV_30yTaxR_SC2050)
************************************************************************************************************
*    Simulate the Value changes brought by removing damaged houses via spillover - longterm full retreat   *
************************************************************************************************************
use "$GISdata\baseline_spillover.dta",clear
ren fid_build FID_Buildingfootprint
drop fid_buildi fid_buil_1 fid_coast2 fid_point

ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity
ren importparc ImportParcelID
save "$dta\baseline_removingdamaged_spillover.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2|_merge==1
gen increase_damageremoval=1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_baseline=(_merge==3)
drop _merge

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_baseline
*Parameter 0.0826 for public openspace is borrowed from Irwin 2002
gen MarketValue_baseline=exp(ln(MarketValue)+0.0101*increase_damageremoval)

sum MarketValue_baseline MarketValue

capture drop delta_MV_baseline
gen delta_MV_baseline=MarketValue_baseline-MarketValue
sum delta_MV_baseline
sum delta_MV_baseline if remove_baseline==0
sum delta_MV_baseline if remove_baseline==1

capture drop Taxbasegain_baseline
egen Taxbasegain_baseline=sum(0.75*delta_MV_baseline) if remove_baseline==0,by(LegalTownship)
replace Taxbasegain_baseline=. if remove_baseline==0&delta_MV_baseline==0

recast long Taxbasegain_baseline
tab LegalTownship,sum(Taxbasegain_baseline)

tab remove_baseline

*Calculate NPV for 30 years tax gain through spillover
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_baseline/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_baseline=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_baseline=. if remove_baseline==1
tab LegalTownship,sum(NPV_30yTaxR_baseline)
*********************************************************************************************************************
*    Simulate the Value changes brought by removing damaged houses via spillover - longtermcost-effective retreat   *
*********************************************************************************************************************
use "$GISdata\scenario1_spillover.dta",clear
ren fid_build FID_Buildingfootprint
drop fid_buildi fid_buil_1 fid_coast2 fid_point

ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity
ren importparc ImportParcelID
save "$dta\scenario1_removingdamaged_spillover.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2|_merge==1
gen increase_damageremoval=1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario1=(_merge==3)
drop _merge

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario1
*Parameter 0.0826 for public openspace is borrowed from Irwin 2002
gen MarketValue_scenario1=exp(ln(MarketValue)+0.0101*increase_damageremoval)

sum MarketValue_scenario1 MarketValue

capture drop delta_MV_scenario1
gen delta_MV_scenario1=MarketValue_scenario1-MarketValue
sum delta_MV_scenario1
sum delta_MV_scenario1 if remove_scenario1==0
sum delta_MV_scenario1 if remove_scenario1==1

capture drop Taxbasegain_scenario1
egen Taxbasegain_scenario1=sum(0.75*delta_MV_scenario1) if remove_scenario1==0,by(LegalTownship)
replace Taxbasegain_scenario1=. if remove_scenario1==0&delta_MV_scenario1==0

recast long Taxbasegain_scenario1
tab LegalTownship,sum(Taxbasegain_scenario1)

tab remove_scenario1

*Calculate NPV for 30 years tax gain through spillover
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario1/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario1=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario1=. if remove_scenario1==1
tab LegalTownship,sum(NPV_30yTaxR_scenario1)

*********************************************************************************************************************
*    Simulate the Value changes brought by removing damaged houses via spillover - longterm meet-the-needs retreat   *
*********************************************************************************************************************
use "$GISdata\scenario2_spillover.dta",clear
ren fid_build FID_Buildingfootprint
drop fid_buildi fid_buil_1 fid_coast2 fid_point

ren propertyfu PropertyFullStreetAddress 
ren propertyci PropertyCity
ren importparc ImportParcelID
save "$dta\scenario2_removingdamaged_spillover.dta",replace

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2|_merge==1
gen increase_damageremoval=1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2=(_merge==3)
drop _merge

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario2

gen MarketValue_scenario2=exp(ln(MarketValue)+0.0101*increase_damageremoval)

sum MarketValue_scenario2 MarketValue

capture drop delta_MV_scenario2
gen delta_MV_scenario2=MarketValue_scenario2-MarketValue
sum delta_MV_scenario2
sum delta_MV_scenario2 if remove_scenario2==0
sum delta_MV_scenario2 if remove_scenario2==1

capture drop Taxbasegain_scenario2
egen Taxbasegain_scenario2=sum(0.75*delta_MV_scenario2) if remove_scenario2==0,by(LegalTownship)
replace Taxbasegain_scenario2=. if remove_scenario2==0&delta_MV_scenario2==0

recast long Taxbasegain_scenario2
tab LegalTownship,sum(Taxbasegain_scenario2)
tab remove_scenario2

*Calculate NPV for 30 years tax gain through spillover
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario2/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario2=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario2=. if remove_scenario2==1
tab LegalTownship,sum(NPV_30yTaxR_scenario2)


*********************************************************************************************************
*  Simulated total property value change_Short term full retreat  *
*********************************************************************************************************
/*Short-term full retreat: assume that all nonconforming (i.e., lot size below 10k sqft) 
properties within the projected 20inch-sea-level-rise (SLR) area in 2050 are removed. 
(Most of these properties are on the coast.)*/

clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " "_b[Waterfront_street]
esttab using"$results\results_Simu_scenario2050.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force

*tab AssessmentYear
*drop if AssessmentYear!=2017

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2050.dta", keepusing(Lisview_area_SC2050 Lisview_mnum_SC2050 total_viewangle_SC2050)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_SC2050=ln(Lisview_area_SC2050+1)
gen lnviewangle_SC2050=ln(total_viewangle_SC2050+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_SC2050=`v' if `v'_SC2050==.
}

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario2050.dta", keepusing(Waterfront_scenario2050)
drop if _merge==2
replace Waterfront_scenario2050=Waterfront_street if Waterfront_scenario2050==.
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2
gen increase_damageremoval=(_merge==3)
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_SC2050=(_merge==3)
drop _merge

capture drop delta_angle
gen delta_angle=total_viewangle_SC2050-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_SC2050
browse if neg_change_angle==1&remove_SC2050==0
replace remove_SC2050=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_SC2050
*Do not include insignificant coefficients
gen MarketValue_SC2050=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+ _b[lnviewangle]*lnviewangle_SC2050+_b[lnviewarea]*lnviewarea_SC2050-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario2050+0.0101*increase_damageremoval)
sum MarketValue_SC2050 MarketValue

capture drop delta_MV_SC2050
gen delta_MV_SC2050=MarketValue_SC2050-MarketValue
sum delta_MV_SC2050
sum delta_MV_SC2050 if remove_SC2050==0
sum delta_MV_SC2050 if remove_SC2050==1

capture drop Taxbaseloss_SC2050
egen Taxbaseloss_SC2050=sum(0.75*MarketValue) if remove_SC2050==1,by(LegalTownship)
capture drop Taxbasegain_SC2050

egen Taxbasegain_SC2050=sum(0.75*delta_MV_SC2050) if remove_SC2050==0,by(LegalTownship)
replace Taxbasegain_SC2050=. if remove_SC2050==0&delta_MV_SC2050==0
recast long Taxbaseloss_SC2050 Taxbasegain_SC2050

tab LegalTownship,sum(Taxbasegain_SC2050)
tab remove_SC2050


*Calculate NPV for 30 years tax gain 
replace delta_MV_SC2050=. if remove_SC2050==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_SC2050/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DVview`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_SC2050=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_SC2050=. if remove_SC2050==1
replace NPV_30yTaxR_SC2050=. if delta_MV_SC2050==0
tab LegalTownship,sum(NPV_30yTaxR_SC2050)


*********************************************************************************************************
*  Simulated total property value change _Long term full retreat  *
*********************************************************************************************************
/*The long term full retreat scenario selects non-conforming (to minimum size limits – selected by a threshold of 10k square foot) properties 
 with 100-year sea level rise (SLR, defined by 20-inch Mean Higher High Water/MHHW). 
*/
*Referred as Baseline scenario in data
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " " _b[Waterfront_street]
esttab using"$results\results_Simu_baseline.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force

*tab AssessmentYear
*drop if AssessmentYear!=2017

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_baseline.dta", keepusing(Lisview_area_baseline Lisview_mnum_baseline total_viewangle_baseline)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_baseline=ln(Lisview_area_baseline+1)
gen lnviewangle_baseline=ln(total_viewangle_baseline+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_baseline=`v' if `v'_baseline==.
}


merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_baseline.dta", keepusing(Waterfront_baseline)
drop if _merge==2
replace Waterfront_baseline=Waterfront_street if Waterfront_baseline==.
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2
gen increase_damageremoval=(_merge==3)
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_baseline=(_merge==3)
drop _merge

capture drop delta_angle
gen delta_angle=total_viewangle_baseline-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_baseline
browse if neg_change_angle==1&remove_baseline==0
replace remove_baseline=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_baseline
*Do not include insignificant coefficients
gen MarketValue_baseline=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+ _b[lnviewangle]*lnviewangle_baseline+_b[lnviewarea]*lnviewarea_baseline-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_baseline+0.0101*increase_damageremoval)
sum MarketValue_baseline MarketValue

capture drop delta_MV_baseline
gen delta_MV_baseline=MarketValue_baseline-MarketValue
sum delta_MV_baseline
sum delta_MV_baseline if remove_baseline==0
sum delta_MV_baseline if remove_baseline==1

capture drop Taxbaseloss_baseline
egen Taxbaseloss_baseline=sum(0.75*MarketValue) if remove_baseline==1,by(LegalTownship)
capture drop Taxbasegain_baseline

egen Taxbasegain_baseline=sum(0.75*delta_MV_baseline) if remove_baseline==0,by(LegalTownship)
replace Taxbasegain_baseline=. if remove_baseline==0&delta_MV_baseline==0
recast long Taxbaseloss_baseline Taxbasegain_baseline

tab LegalTownship,sum(Taxbasegain_baseline)
tab remove_baseline


*Calculate NPV for 30 years tax gain
replace delta_MV_baseline=. if remove_baseline==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_baseline/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_baseline=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_baseline=. if remove_baseline==1
replace NPV_30yTaxR_baseline=. if delta_MV_baseline==0
tab LegalTownship,sum(NPV_30yTaxR_baseline)

**************************************************************************************************
*  Simulated total property value change _S1 - longtermcosteffective   *
**************************************************************************************************

/*Scenario 1, Long-term cost-effective retreat: on top of the criteria for Retreat Scenario 2, add a 
filter on total assessed value (less than or equal to $250k), look for spatial contiguity, consider 
project scale, and prioritize properties without public sewer service. 
*/
*fixed effects model
*year by qt + tract by y + SFHA by year
*Trend

clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum]  " " _b[Waterfront_street]
esttab using"$results\results_Simu_scenario1.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum Waterfront_street) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario1.dta", keepusing(Lisview_area_scenario1 Lisview_mnum_scenario1 total_viewangle_scenario1)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_scenario1=ln(Lisview_area_scenario1+1)
gen lnviewangle_scenario1=ln(total_viewangle_scenario1+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_scenario1=`v' if `v'_scenario1==.
}


merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario1.dta", keepusing(Waterfront_scenario1)
drop if _merge==2
replace Waterfront_scenario1=Waterfront_street if Waterfront_scenario1==.
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Increase_openspace_scenario1.dta", keepusing(openspace_delta_R)
drop if _merge==2
drop _merge
replace openspace_delta_R=0 if openspace_delta_R==.

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2
gen increase_damageremoval=(_merge==3)
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario1=(_merge==3)
drop _merge

capture drop delta_angle
gen delta_angle=total_viewangle_scenario1-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_scenario1
browse if neg_change_angle==1&remove_scenario1==0
replace remove_scenario1=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario1
*Do not include insignificant coefficients
gen MarketValue_scenario1=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+ _b[lnviewangle]*lnviewangle_scenario1+_b[lnviewarea]*lnviewarea_scenario1-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario1+0.0826*openspace_delta_R+0.0101*increase_damageremoval)
sum MarketValue_scenario1 MarketValue

capture drop delta_MV_scenario1
gen delta_MV_scenario1=MarketValue_scenario1-MarketValue
sum delta_MV_scenario1
sum delta_MV_scenario1 if remove_scenario1==0
sum delta_MV_scenario1 if remove_scenario1==1

capture drop Taxbaseloss_scenario1
egen Taxbaseloss_scenario1=sum(0.75*MarketValue) if remove_scenario1==1,by(LegalTownship)
capture drop Taxbasegain_scenario1

egen Taxbasegain_scenario1=sum(0.75*delta_MV_scenario1) if remove_scenario1==0,by(LegalTownship)
replace Taxbasegain_scenario1=. if remove_scenario1==0&delta_MV_scenario1==0
recast long Taxbaseloss_scenario1 Taxbasegain_scenario1

tab LegalTownship,sum(Taxbasegain_scenario1)
tab remove_scenario1


*Calculate NPV for 30 years tax gain
replace delta_MV_scenario1=. if remove_scenario1==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario1/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario1=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario1=. if remove_scenario1==1
replace NPV_30yTaxR_scenario1=. if delta_MV_scenario1==0
tab LegalTownship,sum(NPV_30yTaxR_scenario1)

*************************************************************************************************
*  Simulated total property value change _S2 - longtermmeettheneeds   *
*************************************************************************************************
/*Scenario2: Long-term meet-the-needs retreat: this selection applies the same strategy as Retreat 
Scenario 3, except the filter added is on building assessed value (less than or equal to 
$60k). This scenario intents to mimic the situation where structures that are repeatedly 
damaged and hence have quite low values are removed.
*/
*fixed effects model
*year by qt + tract by y + SFHA by year
*Trend

/*To be updated
*/
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}

capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

set more off
reg Ln_Price SFHA $View $X1 $FE i.fid_school i.period i.period#i.fid_school [pweight=weight],cluster(PID)
di _b[SFHA] " "_b[lnviewarea] " " _b[lnviewangle] " " _b[Lisview_mnum] " " _b[Waterfront_street]
esttab using"$results\results_Simu_scenario2.csv", keep(SFHA lnviewarea lnviewangle Lisview_mnum Waterfront_street) replace b(a3) se r2(3) star(+ .1 * .05 ** .01 *** .001) stats (N N_g r2, fmt(0 3))

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2.dta", keepusing(Lisview_area_scenario2 Lisview_mnum_scenario2 total_viewangle_scenario2)
drop if _merge==2|_merge==1
drop _merge
gen lnviewarea=ln(Lisview_area+1)
gen lnviewangle=ln(total_viewangle+1)
gen lnviewarea_scenario2=ln(Lisview_area_scenario2+1)
gen lnviewangle_scenario2=ln(total_viewangle_scenario2+1)

foreach v in lnviewarea lnviewangle Lisview_mnum {
replace `v'_scenario2=`v' if `v'_scenario2==.
}

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\newwaterfront_scenario2.dta", keepusing(Waterfront_scenario2)
drop if _merge==2
replace Waterfront_scenario2=Waterfront_street if Waterfront_scenario2==.
drop _merge

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Increase_openspace_scenario2.dta", keepusing(openspace_delta_R)
drop if _merge==2
drop _merge
replace openspace_delta_R=0 if openspace_delta_R==.

merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_removingdamaged_spillover.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID )
drop if _merge==2
gen increase_damageremoval=(_merge==3)
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2=(_merge==3)
drop _merge

capture drop delta_angle
gen delta_angle=total_viewangle_scenario2-total_viewangle
*hist delta_angle
gen neg_change_angle=(delta_angle<0)
tab neg_change_angle if delta_angle!=0
tab neg_change_angle remove_scenario2
browse if neg_change_angle==1&remove_scenario2==0
replace remove_scenario2=1 if neg_change_angle==1

capture drop MarketValue
gen MarketValue=e_TotalAssessedValue/0.75
capture drop MarketValue_scenario2
*Do not include insignificant coefficients
gen MarketValue_scenario2=exp(ln(MarketValue)-_b[lnviewangle]*lnviewangle-_b[lnviewarea]*lnviewarea+ _b[lnviewangle]*lnviewangle_scenario2+_b[lnviewarea]*lnviewarea_scenario2-_b[Waterfront_street]*Waterfront_street+_b[Waterfront_street]*Waterfront_scenario2+0.0826*openspace_delta_R+0.0101*increase_damageremoval)
sum MarketValue_scenario2 MarketValue

capture drop delta_MV_scenario2
gen delta_MV_scenario2=MarketValue_scenario2-MarketValue
sum delta_MV_scenario2
sum delta_MV_scenario2 if remove_scenario2==0
sum delta_MV_scenario2 if remove_scenario2==1

capture drop Taxbaseloss_scenario2
egen Taxbaseloss_scenario2=sum(0.75*MarketValue) if remove_scenario2==1,by(LegalTownship)
capture drop Taxbasegain_scenario2

egen Taxbasegain_scenario2=sum(0.75*delta_MV_scenario2) if remove_scenario2==0,by(LegalTownship)
replace Taxbasegain_scenario2=. if remove_scenario2==0&delta_MV_scenario2==0
recast long Taxbaseloss_scenario2 Taxbasegain_scenario2

tab LegalTownship,sum(Taxbasegain_scenario2)
tab remove_scenario2

*Calculate NPV for 30 years tax gain
replace delta_MV_scenario2=. if remove_scenario2==1
foreach n of numlist 1(1)30{
gen NPV_DV`n'=delta_MV_scenario2/((1+0.05)^`n')
}
gen NPV_DV30years=0

foreach n of numlist 1(1)30{
replace NPV_DV30years=NPV_DV30years+NPV_DV`n'
}

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_DTaxR_30years=0.75*NPV_DV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario2=sum(NPV_DTaxR_30years), by(LegalTownship)
replace NPV_30yTaxR_scenario2=. if remove_scenario2==1
replace NPV_30yTaxR_scenario2=. if delta_MV_scenario2==0
tab LegalTownship,sum(NPV_30yTaxR_scenario2)





















**************************************************************
*       Depreciation - log-form for the removed houses       *
**************************************************************
*scenario2050
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*Merge with viewshed domain, just analyze viewshed domain-coastal area: some more in-land areas do exist projected retreats
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2050.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2|_merge==1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2050_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2050=(_merge==3)
drop _merge

drop if remove_scenario2050==0
*Market Value is an approximation of appraised value
gen MarketValue=e_TotalAssessedValue/0.75
*Assuming that the properties in 2050-SLR affected area will depreciate to zero value in 2050
*Log-depreciation:y=alfa_logdep*ln(31-t) 
gen alfa_logdep=MarketValue/(ln(31))
*MarketValue#:#th year market value
foreach n of numlist 1(1)30{
gen MarketValue`n'=alfa_logdep*ln(31-`n')
}
*Calculate the net present value - 5% discount rate
foreach n of numlist 1(1)30{
gen NPV_MV`n'=MarketValue`n'/((1+0.05)^`n')
}
gen NPV_MV30years=0
foreach n of numlist 1(1)30{
replace NPV_MV30years=NPV_MV30years+NPV_MV`n'
}

*Apply the mill rate, so that we get the net present value of the tax flow
/*
Town	Mill Rate	
Branford	28.64	
Bridgeport	54.37?	
Clinton	30.54	
East Haven	32.54	
East Lyme	27.35	
Fairfield	26.36	
Groton	24.17	
  City of Groton	    Add 4.58	
  Groton Long Point	    Add 3.71	
  Noank	              Add 1.39	
Guilford	31.28	
Madison	28.04	
Milford	27.74	
New Haven	42.98	Add 1.5
New London	43.17	
Norwalk	apprx 26	
Old Lyme	21.91	
Old Saybrook	19.6	
Stonington	22.68	add 1.5
Stratford	39.97	
Waterford	27.42	
Westbrook	24.37	
West Haven	41	
Westport	16.86	
*/
gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_TaxR_30years=0.75*NPV_MV30years*Mill_rate/1000
egen NPV_30yTaxR_SC2050=sum(NPV_TaxR_30years), by(LegalTownship)

capture drop Taxbaseloss_SC2050
egen Taxbaseloss_SC2050=sum(0.75*MarketValue),by(LegalTownship)
recast long Taxbaseloss_SC2050

tab LegalTownship,sum(Taxbaseloss_SC2050)
tab LegalTownship,sum(NPV_30yTaxR_SC2050)

*baseline
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*Merge with viewshed domain, just analyze viewshed domain-coastal area: some more in-land areas do exist projected retreats
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_baseline.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2|_merge==1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\baseline_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_baseline=(_merge==3)
drop _merge

drop if remove_baseline==0
*Market Value is an approximation of appraised value
gen MarketValue=e_TotalAssessedValue/0.75
*Assuming that the properties in 2050-SFHA will depreciate by a half in 2050
*Log-depreciation:y=alfa_logdep*ln(31-t)+.5Y0 
gen alfa_logdep=(.5*MarketValue/(ln(31)))
*MarketValue#:#th year market value
foreach n of numlist 1(1)30{
gen MarketValue`n'=alfa_logdep*ln(31-`n')+.5*MarketValue
}
*Calculate the net present value - 5% discount rate
foreach n of numlist 1(1)30{
gen NPV_MV`n'=MarketValue`n'/((1+0.05)^`n')
}
gen NPV_MV30years=0
foreach n of numlist 1(1)30{
replace NPV_MV30years=NPV_MV30years+NPV_MV`n'
}

*Apply the mill rate, so that we get the net present value of the tax flow

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_TaxR_30years=0.75*NPV_MV30years*Mill_rate/1000
egen NPV_30yTaxR_baseline=sum(NPV_TaxR_30years), by(LegalTownship)

capture drop Taxbaseloss_baseline
egen Taxbaseloss_baseline=sum(0.75*MarketValue),by(LegalTownship)
recast long Taxbaseloss_baseline

tab LegalTownship,sum(Taxbaseloss_baseline)
tab LegalTownship,sum(NPV_30yTaxR_baseline)


*scenario 1
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*Merge with viewshed domain, just analyze viewshed domain-coastal area: some more in-land areas do exist projected retreats
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario1.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2|_merge==1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario1_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario1=(_merge==3)
drop _merge

drop if remove_scenario1==0
*Market Value is an approximation of appraised value
gen MarketValue=e_TotalAssessedValue/0.75
*Assuming that the properties in 2050-SFHA will depreciate by a half in 2050
*Log-depreciation:y=alfa_logdep*ln(31-t)+.5Y0 
gen alfa_logdep=(.5*MarketValue/(ln(31)))
*MarketValue#:#th year market value
foreach n of numlist 1(1)30{
gen MarketValue`n'=alfa_logdep*ln(31-`n')+.5*MarketValue
}
*Calculate the net present value - 5% discount rate
foreach n of numlist 1(1)30{
gen NPV_MV`n'=MarketValue`n'/((1+0.05)^`n')
}
gen NPV_MV30years=0
foreach n of numlist 1(1)30{
replace NPV_MV30years=NPV_MV30years+NPV_MV`n'
}

*Apply the mill rate, so that we get the net present value of the tax flow

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_TaxR_30years=0.75*NPV_MV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario1=sum(NPV_TaxR_30years), by(LegalTownship)

capture drop Taxbaseloss_scenario1
egen Taxbaseloss_scenario1=sum(0.75*MarketValue),by(LegalTownship)
recast long Taxbaseloss_scenario1

tab LegalTownship,sum(Taxbaseloss_scenario1)
tab LegalTownship,sum(NPV_30yTaxR_scenario1)

*scenario 2
clear all
set more off
clear all
set more off
use "$dta\data_4analysis.dta",clear
set matsize 11000
set emptycells drop

foreach v in BuildingCondition Ground_elev HeatingType SalesYear SalesMonth FIPS {
sum `v'
drop if `v'==.
}
capture drop Quarter
gen Quarter=1 if SalesMonth>=1&SalesMonth<4
replace Quarter=2 if SalesMonth>=4&SalesMonth<7
replace Quarter=3 if SalesMonth>=7&SalesMonth<10
replace Quarter=4 if SalesMonth>=10&SalesMonth<=12
capture drop period
gen period=4*(e_Year-1994)+Quarter

sort PropertyFullStreetAddress PropertyCity LegalTownship e_Year
egen PID=group(PropertyFullStreetAddress PropertyCity LegalTownship)
xtset PID period

global View "lnviewarea lnviewangle Lisview_mnum"
global X "Waterfront_ocean Waterfront_river Waterfront_street e_SQFT_liv e_SQFT_tot e_LotSizeSquareFeet e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global X1 "Waterfront_ocean Waterfront_river Waterfront_street e_LnSQFT e_LnSQFT_tot e_LnLSQFT e_BuildingAge e_BuildingAge_sq e_Elev_dev e_Elev_devsq sewer_service e_NoOfBuildings e_NoOfStories e_TotalRooms e_TotalBedrooms e_TotalCalculatedBathCount AirCondition e_FireplaceNumber e_Pool e_GarageNoOfCars Dist_I95_NYC Lndist_coast Lndist_nearexit Lndist_highway Lndist_nrailroad Lndist_beach Lndist_brownfield Lndist_nwaterbody Lndist_develop Lndist_StatePark Lndist_airp Lndist_CBRS ratio_Dev ratio_Fore ratio_Open"
global FE "i.BuildingCondition i.HeatingType i.SalesMonth"

keep PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street
append using "$dta\proponeunit_forsimulation.dta", keep(PropertyFullStreetAddress PropertyCity ImportParcelID  view_analysis LegalTownship Lisview_area Lisview_mnum total_viewangle e_TotalAssessedValue Waterfront_street)
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID ,force
*Merge with viewshed domain, just analyze viewshed domain-coastal area: some more in-land areas do exist projected retreats
merge m:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\Viewshed_scenario2.dta", keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2|_merge==1
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\scenario2_remove_final.dta",keepusing(PropertyFullStreetAddress PropertyCity ImportParcelID)
drop if _merge==2
gen remove_scenario2=(_merge==3)
drop _merge

drop if remove_scenario2==0
*Market Value is an approximation of appraised value
gen MarketValue=e_TotalAssessedValue/0.75
*Assuming that the properties in 2050-SFHA will depreciate by a half in 2050
*Log-depreciation:y=alfa_logdep*ln(31-t)+.5Y0 
gen alfa_logdep=(.5*MarketValue/(ln(31)))
*MarketValue#:#th year market value
foreach n of numlist 1(1)30{
gen MarketValue`n'=alfa_logdep*ln(31-`n')+.5*MarketValue
}
*Calculate the net present value - 5% discount rate
foreach n of numlist 1(1)30{
gen NPV_MV`n'=MarketValue`n'/((1+0.05)^`n')
}
gen NPV_MV30years=0
foreach n of numlist 1(1)30{
replace NPV_MV30years=NPV_MV30years+NPV_MV`n'
}

*Apply the mill rate, so that we get the net present value of the tax flow

gen Mill_rate=28.64 if LegalTownship=="BRANFORD"
replace Mill_rate=54.37 if LegalTownship=="BRIDGEPORT"
replace Mill_rate=30.54 if LegalTownship=="CLINTON"
replace Mill_rate=32.54 if LegalTownship=="EAST HAVEN"
replace Mill_rate=27.35 if LegalTownship=="EAST LYME"
replace Mill_rate=26.36 if LegalTownship=="FAIRFIELD"
replace Mill_rate=24.17+3.71 if LegalTownship=="GROTON"
replace Mill_rate=31.28 if LegalTownship=="GUILFORD"
replace Mill_rate=28.04 if LegalTownship=="MADISON"
replace Mill_rate=27.74 if LegalTownship=="MILFORD"
replace Mill_rate=42.98+1.5 if LegalTownship=="NEW HAVEN"
replace Mill_rate=43.17 if LegalTownship=="NEW LONDON"
replace Mill_rate=26 if LegalTownship=="NORWALK"
replace Mill_rate=21.91 if LegalTownship=="OLD LYME"
replace Mill_rate=19.6 if LegalTownship=="OLD SAYBROOK"
replace Mill_rate=22.68+1.5 if LegalTownship=="STONINGTON"
replace Mill_rate=39.97 if LegalTownship=="STRATFORD"
replace Mill_rate=27.42 if LegalTownship=="WATERFORD"
replace Mill_rate=24.37 if LegalTownship=="WESTBROOK"
replace Mill_rate=41 if LegalTownship=="WEST HAVEN"
replace Mill_rate=16.86 if LegalTownship=="WESTPORT"

gen NPV_TaxR_30years=0.75*NPV_MV30years*Mill_rate/1000
egen NPV_30yTaxR_scenario2=sum(NPV_TaxR_30years), by(LegalTownship)

capture drop Taxbaseloss_scenario2
egen Taxbaseloss_scenario2=sum(0.75*MarketValue),by(LegalTownship)
recast long Taxbaseloss_scenario2

tab LegalTownship,sum(Taxbaseloss_scenario2)
tab LegalTownship,sum(NPV_30yTaxR_scenario2)


