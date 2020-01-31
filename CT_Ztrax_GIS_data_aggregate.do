clear all
set more off
*Change the directories here
global root ""
global dta "$root\dta"

global GIS ""
global viewshed ""
global viewshed_S2 ""
global viewshed_S3 ""
global landcover ""
global stilting ""
global Parcel_Poly ""




***********************
* Viewshed data - New *
***********************
*Matching points to building polygons* 
import delimited D:\UConn2\Circa\GISdata\Point_Building1.txt, clear 
ren in_fid FID
replace near_dist=near_dist*3.28084
ren near_dist Dist_Buildingfootprint
ren near_fid FID_Buildingfootprint
ren FID FID_point
save "$dta\Point_Buildingfootprint.dta",replace


use "$dta\Point_Buildingfootprint.dta",clear
duplicates drop FID_Buildingfootprint,force
save "$dta\Point_Buildingfootprint_nodup.dta",replace

*creat a variable indicating usable one-unit building footprint
use "D:\UConn2\Circa\GISdata\Impervioussurface\buildings2012_coast.dta",clear
replace fid_build=_n-1
ren fid_build FID_Buildingfootprint
merge 1:1 FID_Buildingfootprint using"$dta\Point_Buildingfootprint_nodup.dta"
replace fid_point=FID_point
ren FID_Buildingfootprint fid_build 
keep shape_leng shape_area fid_point fid_build
save "D:\UConn2\Circa\GISdata\Impervioussurface\buildings2012_coast.dta",replace
export delimited using "D:\UConn2\Circa\GISdata\Impervioussurface\buildings2012_coast.csv", replace

use "D:\UConn2\Circa\GISdata\buildingp_va_oneunit.dta",clear
ren fid_build FID_Buildingfootprint
ren fid_point FID
save "$dta\buildingp_va_oneunit.dta",replace


*59395-Feb2019
clear all
set more off

use "$viewshed\lisview_0.dta",clear
forv n=0 (1) 55744 {
capture append using "$viewshed\lisview_`n'.dta"
}
duplicates drop

ren near_fid orig_fid

merge m:1 orig_fid using"$dta\buildingp_va_oneunit.dta",keepusing(FID_Buildingfootprint)
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

keep _merge orig_fid FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge

drop orig_fid


merge 1:m FID_Buildingfootprint using"$dta\Point_Buildingfootprint.dta",keepusing(FID_point Dist_Buildingfootprint)
ren FID_point FID
drop _merge
merge m:1 FID using"$dta\viewshed_prop.dta"
drop _merge
save "$dta\Viewshed_new.dta",replace

**************************
* Viewshed data ——Google *
**************************
*generate the dta file of prop_va_oneunit-from google points
import delimited $root\dta\prop_va_oneunit.csv, clear 
keep propertyfullstreetaddress propertycity importparcelid latfixed longfixed latgoogle longgoogle
gen FID=_n-1
save "$dta\viewshed_prop_ggl.dta",replace

*Matching points to building polygons* 
import delimited $GIS\Point_BuildingGgl.txt, clear 
ren in_fid FID
replace near_dist=near_dist*3.28084
ren near_dist Dist_Buildingfootprint
ren near_fid FID_Buildingfootprint
ren FID FID_point
save "$dta\Point_BuildingfootprintGgl.dta",replace

use "$dta\Point_BuildingfootprintGgl.dta",clear
duplicates drop FID_Buildingfootprint,force
save "$dta\Point_BuildingfootprintGgl_nodup.dta",replace

*creat a variable indicating usable one-unit building footprint
use "D:\UConn2\Circa\GISdata\buildings2012_coastggl.dta",clear
replace fid_build=_n-1
ren fid_build FID_Buildingfootprint
merge 1:1 FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl_nodup.dta"
replace fid_point=FID_point
ren FID_Buildingfootprint fid_build 
keep fid_buildi fid_coast2 fid_point fid_build
sort fid_build
save "D:\UConn2\Circa\GISdata\Impervioussurface\buildings2012_coastggl.dta",replace
export delimited using "D:\UConn2\Circa\GISdata\buildings2012_coastggl.csv", replace
*This table will be merged in to the shapefile, and the shapefile will be further selected to get building_va_ggl.shp


use "D:\Work\CIRCA\Circa\GISdata\buildingp_va_ggl.dta",clear
ren fid_build FID_Buildingfootprint
ren fid_point FID
save "$dta\buildingp_va_ggl.dta",replace

*61736-Feb2019
clear all
set more off

use "$viewshed\lisview_0.dta",clear
forv n=0 (1) 61736 {
capture append using "$viewshed\lisview_`n'.dta"
}
duplicates drop

ren near_fid orig_fid

merge m:1 orig_fid using"$dta\buildingp_va_ggl.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
*when near feature is not found, near_fid(orig_fid)=-1,near_dist=-1
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

keep _merge orig_fid FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge

drop orig_fid


merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle
*drop if one building is matched with multiple parcels

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build
save "$dta\Viewshed_Ggl.dta",replace

***********************
*  Distance Variables *
***********************
*Calculating distance for one-unit properties

set more off
use "D:\Work\CIRCA\Circa\GISdata\prop_oneunitcoastGgl.dta",clear
gen FID=_n-1
save "$dta\property_oneunitcoastGgl.dta",replace

import delimited D:\Work\CIRCA\Circa\CT_Property\dta\proponeunit_building_revised.csv, clear 
gen FID=_n-1
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
save "$dta\proponeunit_building_revise.dta",replace

*Only I95-revised
import delimited using "D:\Work\CIRCA\Circa\GISdata\NearI95.txt",clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_I95
save "$dta\property_nearI95.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearAirport.txt, clear 
ren in_fid FID
*from meters to feet
replace near_dist=near_dist*3.28084
ren near_dist Dist_Airport
keep FID Dist_Airport
save "$dta\NearAirport.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearHDdevelop.txt, clear 
ren in_fid FID
replace near_dist=near_dist*3.28084
ren near_dist Dist_HDdevelop
keep FID Dist_HDdevelop
save "$dta\NearHDdevelop.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearCBRS.txt, clear 
ren in_fid FID
replace near_dist=near_dist*3.28084
ren near_dist Dist_CBRS
keep FID Dist_CBRS
*Coastal Barrier Resources System
save "$dta\NearCBRS.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearStatePark.txt, clear 
ren in_fid FID
replace near_dist=near_dist*3.28084
ren near_dist Dist_StatePark
keep FID Dist_StatePark
save "$dta\NearStatePark.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearExit.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
reshape wide near_dist, i(FID) j(near_rank)
ren near_dist1 Dist_exit_near1
ren near_dist2 Dist_exit_near2
ren near_dist3 Dist_exit_near3
save "$dta\property_nearexit.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearPubbeach.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
duplicates report FID near_rank
duplicates drop FID near_rank,force
reshape wide near_dist, i(FID) j(near_rank)
ren near_dist1 Dist_beach_near1
ren near_dist2 Dist_beach_near2
ren near_dist3 Dist_beach_near3
save "$dta\property_nearpubbeach.dta",replace

*Both primary and secondary roads (they are in the highway system) are considered here.
import delimited using "D:\Work\CIRCA\Circa\GISdata\NearFreeway.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_freeway
save "$dta\property_nearfreeway.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearBrownfield.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_Brownfield
save "$dta\property_nearbrownfield.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearShoreline.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_Coast
save "$dta\property_nearshore.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearWaterbody.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_NWaterbody
save "$dta\property_nearwaterbody.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearRailroad.txt", clear
drop objectid 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_NRailroad
save "$dta\property_nearrailroad.dta",replace

*Dist to NYC along I-95 - from network analysis
use "D:\Work\CIRCA\Circa\GISdata\dist_i95nyc.dta",clear
*add distance from the facility to the NYC boundary 
gen dist_exit_NYC=(total_leng*3.28084)/5280+14.2
ren incidentid location_id
keep location_id dist_exit_NYC
save "$dta\dist_i95nyc.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\i95_exits.dta",clear
gen location_id=_n
merge m:1 location_id using"$dta\dist_i95nyc.dta"
drop _merge
*many exit distances are missing since network analysis doesn't calculate the distance for exits on the opposit direction
*impute using exit numbers
destring exit_num,gen(exit_No) force
replace exit_No=27 if exit_No==.&exit_num=="27A"
replace exit_No=39 if exit_No==.&exit_num=="39A"
replace exit_No=39 if exit_No==.&exit_num=="39B"
replace exit_No=82 if exit_No==.&exit_num=="82A"
replace exit_No=84 if exit_No==.&exit_num=="84S-N-E"
replace from_name=trim(from_name)
sort from_name exit_No
egen dist_exit_NYC1=mean(dist_exit_NYC),by(exit_No)
replace dist_exit_NYC1=. if exit_No==.
replace dist_exit_NYC1 = dist_exit_NYC1[_n-1] if (exit_No==exit_No[_n-1]+1|exit_No==exit_No[_n-1]) & (dist_exit_NYC1==.|dist_exit_NYC1>=200)
*range interpolation
replace dist_exit_NYC1 = 30.29342+1.08*(exit_No-16) if exit_No>=17&exit_No<29
*Individual imputation with nearby exit values
replace dist_exit_NYC1 = 54.05342 if from_name=="MILFORD PKWY"
replace dist_exit_NYC1 = (102.6534+101.5734)/2 if from_name=="S FRONTAGE RD"
replace dist_exit_NYC1 = 106.9734 if from_name=="STATE HWY 184"
replace dist_exit_NYC1 = 106.9734 if from_name=="STATE HWY 349"
replace dist_exit_NYC1 = 121.6905 if from_name=="STATE HWY 78"
replace dist_exit_NYC1 = (102.6534+101.5734)/2 if from_name=="US HWY 1"
replace dist_exit_NYC1 = 73.49342 if objectid==28221
replace dist_exit_NYC1 = 105.8934 if objectid==28633
replace dist_exit_NYC1 = (102.6534+101.5734)/2 if objectid==28630
replace dist_exit_NYC1 = 63.77342 if objectid==28190
replace dist_exit_NYC1 = 63.77342 if objectid==28191

keep location_id dist_exit_NYC1
save "$dta\dist_i95nyc_impute.dta",replace

import delimited using "D:\Work\CIRCA\Circa\GISdata\NearI95Exits.txt", clear
drop objectid 
ren in_fid FID
gen location_id=near_fid+1
drop near_fid
*distance in ft - property to exit
replace near_dist=near_dist*3.28084
merge m:1 location_id using"$dta\dist_i95nyc_impute.dta"
drop if _merge==2
sort FID near_rank
drop _merge
gen dist_I95_NYC1=near_dist/5280+dist_exit_NYC1
egen dist_I95_NYC=min(dist_I95_NYC1),by(FID)

keep FID dist_I95_NYC
duplicates drop
hist dist_I95_NYC,bin(30)
ren dist_I95_NYC Dist_I95_NYC
*distance in mile now
save "$dta\property_disti95nyc.dta",replace

*************************
*  Other Geo-variables  *
*************************
use "D:\Work\CIRCA\Circa\GISdata\prop_int_12sfha.dta",clear
keep fid_prop_o propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle fld_zone static_bfe 
ren fid_prop_o FID
gen SFHA_2012=1
save "$dta\property_2012SFHA.dta",replace
*This flood map layer is extracted in Spet 2012

use "D:\Work\CIRCA\Circa\GISdata\prop_int_17sfha.dta",clear
keep fid_prop_o propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle fld_zone static_bfe 
ren fid_prop_o FID
gen SFHA_2017=1
save "$dta\property_2017SFHA.dta",replace
*This flood map layer is extracted in Mar 2017

use "D:\Work\CIRCA\Circa\GISdata\prop_int_19sfha.dta",clear
keep fid_prop_o propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle fld_zone static_bfe 
ren fid_prop_o FID
gen SFHA_2019=1
save "$dta\property_2019SFHA.dta",replace
*This flood map layer is extracted in April 2019

*building revised points to assign SFHA and surge feets
use "D:\Work\CIRCA\Circa\GISdata\prop_brev_12sfha.dta",clear
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_2012=1
save "$dta\property_brev_2012SFHA.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\prop_brev_17sfha.dta",clear
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_2017=1
save "$dta\property_brev_2017SFHA.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\prop_brev_19sfha.dta",clear
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_2019=1
save "$dta\property_brev_2019SFHA.dta",replace

*SFHA 2012 asssigning with building polygons
use "D:\Work\CIRCA\Circa\GISdata\buildings_SFHA2012.dta",clear
sort fid_buildi fld_zone
duplicates tag fid_buildi, gen(dup1)
drop if dup1>=1&fld_zone=="AE"
duplicates report fid_buildi
duplicates drop fid_buildi fld_zone,force
duplicates report fid_buildi
drop dup1
save "$dta\buildings_SFHA2012.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\buildingpoly_add.dta",clear
duplicates report fid_buildi
merge m:1 fid_buildi using"$dta\buildings_SFHA2012.dta",keepusing(fld_zone static_bfe)
drop if _merge==2
drop if _merge==1
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_poly2012=1
ren fld_zone fld_zonepoly
ren static_bfe static_bfepoly
save "$dta\buildingpoly_2012SFHA.dta",replace

*SFHA 2017 asssigning with building polygons
use "D:\Work\CIRCA\Circa\GISdata\buildings_SFHA2017.dta",clear
sort fid_buildi fld_zone
duplicates tag fid_buildi, gen(dup1)
drop if dup1>=1&fld_zone=="AE"|fld_zone=="AO"
duplicates report fid_buildi
duplicates drop fid_buildi fld_zone,force
duplicates report fid_buildi
drop dup1
save "$dta\buildings_SFHA2017.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\buildingpoly_add.dta",clear
duplicates report fid_buildi
merge m:1 fid_buildi using"$dta\buildings_SFHA2017.dta",keepusing(fld_zone static_bfe)
drop if _merge==2
drop if _merge==1
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_poly2017=1
ren fld_zone fld_zonepoly
ren static_bfe static_bfepoly
save "$dta\buildingpoly_2017SFHA.dta",replace

*SFHA 2019 asssigning with building polygons
use "D:\Work\CIRCA\Circa\GISdata\buildings_SFHA2019.dta",clear
sort fid_buildi fld_zone
duplicates tag fid_buildi, gen(dup1)
drop if dup1>=1&fld_zone=="AE"|fld_zone=="AO"
duplicates report fid_buildi
duplicates drop fid_buildi fld_zone,force
duplicates report fid_buildi
drop dup1
save "$dta\buildings_SFHA2019.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\buildingpoly_add.dta",clear
duplicates report fid_buildi
merge m:1 fid_buildi using"$dta\buildings_SFHA2019.dta",keepusing(fld_zone static_bfe)
drop if _merge==2
drop if _merge==1
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle lat_rev long_rev fld_zone static_bfe 
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
ren lat_rev Lat_rev
ren long_rev Long_rev
ren fid_propon FID
gen SFHA_poly2019=1
ren fld_zone fld_zonepoly
ren static_bfe static_bfepoly
save "$dta\buildingpoly_2019SFHA.dta",replace


import delimited D:\Work\CIRCA\Circa\GISdata\NearSFHA12boundary.txt, clear 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_12SFHA_B
merge 1:1 FID using"$dta\proponeunit_building_revise.dta"
drop if _merge==2
drop _merge
save "$dta\NearSFHA12boundary.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearSFHA17boundary.txt, clear 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_17SFHA_B
merge 1:1 FID using"$dta\proponeunit_building_revise.dta"
drop if _merge==2
drop _merge
save "$dta\NearSFHA17boundary.dta",replace

import delimited D:\Work\CIRCA\Circa\GISdata\NearSFHA19boundary.txt, clear 
ren in_fid FID
drop near_fid
replace near_dist=near_dist*3.28084
ren near_dist Dist_19SFHA_B
merge 1:1 FID using"$dta\proponeunit_building_revise.dta"
drop if _merge==2
drop _merge
save "$dta\NearSFHA19boundary.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\prop_brev_sandyi.dta",clear
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle gridcode
ren fid_propon FID
duplicates tag FID,gen(dup1)
gen neggridcode=-gridcode
sort FID neggridcode
duplicates drop FID,force
*keep only the higher surge if one property is intersected with two surges (6 properties involved)
ren gridcode Sandysurge_feet
drop neggridcode dup1
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren fips FIPS
ren state State
ren county County
ren legaltowns LegalTownship
save "$dta\propertybrev_sandysurge.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\prop_brev_irenei.dta",clear
keep fid_propon propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle gridcode
ren fid_propon FID
duplicates tag FID,gen(dup1)
gen neggridcode=-gridcode
sort FID neggridcode
duplicates drop FID,force
*keep only the higher surge if one property is intersected with two surges (3 properties involved)
ren gridcode Irenesurge_feet
drop neggridcode dup1
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren fips FIPS
ren state State
ren county County
ren legaltowns LegalTownship
save "$dta\propertybrev_irenesurge.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\prop_sewer.dta",clear
keep fid_prop_o propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle
ren fid_prop_o FID
gen sewer_service=1
save "$dta\Sewer_service.dta",replace 

use "D:\Work\CIRCA\Circa\GISdata\prop_schoold.dta",clear
keep fid_prop_o propertyfu propertyci fips state county legaltowns importparc latfixed longfixed latgoogle longgoogle fid_school affgeoid name
ren fid_prop_o FID
ren name Sch_District
duplicates drop
save "$dta\property_schoold.dta",replace

*property intersect with census block - median income
import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\MediumIncome\GraphingNonUrban.xlsx", sheet("ACS_17_5YR_B19013_with_ann") firstrow clear
recast double GEOid2
ren Town LegalTownship
hist MedianIncome
save "$dta\blockincome_nonurban.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\MediumIncome\UrbanGraphing.xlsx", sheet("Sheet1") firstrow clear
recast double GEOid2
ren Town LegalTownship
hist MedianIncome
save "$dta\blockincome_urban.dta",replace

*Impute missing values in median income
use "D:\Work\CIRCA\Circa\GISdata\blockgroups_21town.dta",clear
gen FID=_n-1
destring geoid,gen(GEOid2)

merge m:1 GEOid2 using"$dta\blockincome_nonurban.dta",keepusing(MedianIncome)
drop if _merge==2
drop _merge
replace medianinco=MedianIncome if medianinco==.
merge m:1 GEOid2 using"$dta\blockincome_urban.dta",keepusing(MedianIncome) update
drop if _merge==2
drop _merge
replace medianinco=MedianIncome if medianinco==.
sort FID
drop FID GEOid2
drop MedianIncome
*export delimited using "D:\Work\CIRCA\Circa\GISdata\blockgroups_21town.csv", replace
export excel using "D:\Work\CIRCA\Circa\GISdata\blockgroups_21town.xls", sheetreplace firstrow(variables)
*This spreadsheet with medianincome will be merged back to the shapefile, and imputation will happen using nearby block values
destring geoid,gen(GEOid2)
save "$dta\blockgroups_MedianInc_miss.dta",replace

*polygon neighbor table-imputation 1st round
import delimited D:\Work\CIRCA\Circa\GISdata\block_polyneighbor.txt, clear 
ren src_geoid GEOid2
merge m:1 GEOid2 using"$dta\blockgroups_MedianInc_miss.dta",keepusing(medianinco)
ren GEOid2 src_geoid
ren nbr_geoid GEOid2
ren medianinco medianinco_src
drop _merge
merge m:1 GEOid2 using"$dta\blockgroups_MedianInc_miss.dta",keepusing(medianinco)
sort src_geoid
ren GEOid2 nbr_geoid
drop _merge
egen Median_impute=mean(medianinco), by(src_geoid)
replace medianinco_src=Median_impute if medianinco_src==.
ren src_geoid GEOid2
keep GEOid2 medianinco_src
duplicates drop
sort GEOid2
ren medianinco_src medianinco
save "$dta\block_imputed_MedianInc.dta",replace

*Second round of imputation to get the remaining 3 missing obs
import delimited D:\Work\CIRCA\Circa\GISdata\block_polyneighbor.txt, clear 
ren src_geoid GEOid2
merge m:1 GEOid2 using"$dta\blockgroups_MedianInc_miss.dta",keepusing(medianinco)
ren GEOid2 src_geoid
ren nbr_geoid GEOid2
ren medianinco medianinco_src
drop _merge
merge m:1 GEOid2 using"$dta\blockgroups_MedianInc_miss.dta",keepusing(medianinco)
sort src_geoid
ren GEOid2 nbr_geoid
drop _merge
egen Median_impute=mean(medianinco), by(src_geoid)
replace medianinco_src=Median_impute if medianinco_src==.

ren nbr_geoid GEOid2
drop medianinco
merge m:1 GEOid2 using"$dta\block_imputed_MedianInc.dta",keepusing(medianinco)
drop _merge
sort src_geoid
egen Median_impute1=mean(medianinco), by(src_geoid)
replace medianinco_src=Median_impute1 if medianinco_src==.
ren GEOid2 nbr_geoid
ren src_geoid GEOid2
keep GEOid2 medianinco_src
duplicates drop
save "$dta\block_imputed_MedianInc1.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\propbuildrev_censusblock.dta",clear
destring geoid,gen(GEOid2)
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren fips FIPS
ren state State
ren county County
ren legaltowns LegalTownship
duplicates report GEOid2 if LegalTownship!="DARIEN"&LegalTownship!="GREENWICH"&LegalTownship!="STAMFORD"
di r(unique_value)

merge m:1 GEOid2 using"$dta\block_imputed_MedianInc1.dta", keepusing(medianinco_src)
drop if _merge==2
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
tab _merge
ren medianinco_src MedianIncome
count if MedianIncome==.&_merge==3
drop if _merge==1
drop _merge
/*
merge m:1 GEOid2 using"$dta\blockincome_nonurban.dta",keepusing(MedianIncome LegalTownship)
drop if _merge==2
drop _merge
merge m:1 GEOid2 using"$dta\blockincome_urban.dta",keepusing(MedianIncome LegalTownship) update
drop if _merge==2
drop _merge
*/
hist MedianIncome
save "$dta\property_blockincome.dta",replace
sum MedianIncome


******Property median value******
use "$dta\FairfieldCntyBG_data.dta",clear
compress
save "$dta\FairfieldCntyBG_data.dta",replace
use "$dta\MiddlesexCntyBG_data.dta",clear
compress
save "$dta\MiddlesexCntyBG_data.dta",replace
use "$dta\NewHavenCntyBG_data.dta",clear
compress
save "$dta\NewHavenCntyBG_data.dta",replace
use "$dta\NewLondonCntyBG_data.dta",clear
tostring MedHshldInc,replace
compress
save "$dta\NewLondonCntyBG_data.dta",replace

use "D:\Work\CIRCA\Circa\GISdata\blockgroups_21town.dta",clear
gen FID=_n-1
destring geoid,gen(Id2)

merge m:1 Id2 using"$dta\FairfieldCntyBG_data.dta"
drop if _merge==2
drop _merge
merge m:1 Id2 using"$dta\MiddlesexCntyBG_data.dta",update
drop if _merge==2
drop _merge
merge m:1 Id2 using"$dta\NewHavenCntyBG_data.dta",update
drop if _merge==2
drop _merge
merge m:1 Id2 using"$dta\NewLondonCntyBG_data.dta",update
drop if _merge==2
drop _merge
save "$dta\blockgroups_PropValue_miss.dta",replace
use "$dta\blockgroups_PropValue_miss.dta",clear
destring MedHouseValue,force replace
duplicates drop
count if MedHouseValue==.


*polygon neighbor table-imputation 1st round
import delimited D:\Work\CIRCA\Circa\GISdata\block_polyneighbor.txt, clear 
ren src_geoid Id2
merge m:1 Id2 using"$dta\blockgroups_PropValue_miss.dta",keepusing(MedHouseValue)
ren Id2 src_geoid
ren nbr_geoid Id2
ren MedHouseValue MedHouseValue_src
drop _merge
merge m:1 Id2 using"$dta\blockgroups_PropValue_miss.dta",keepusing(MedHouseValue)
sort src_geoid
ren Id2 nbr_geoid
drop _merge

destring MedHouseValue_src, force replace
destring MedHouseValue, force replace
egen MedHV_impute=mean(MedHouseValue), by(src_geoid)
replace MedHouseValue_src=MedHV_impute if MedHouseValue_src==.
ren src_geoid Id2
keep Id2 MedHouseValue_src
sort MedHouseValue_src

duplicates drop
sort Id2
ren MedHouseValue_src MedHouseV
count if MedHouseV==.
save "$dta\block_imputed_MedHV.dta",replace

*Second round of imputation to get the remaining 7 missing obs
*polygon neighbor table-imputation 1st round
import delimited D:\Work\CIRCA\Circa\GISdata\block_polyneighbor.txt, clear 
ren src_geoid Id2
merge m:1 Id2 using"$dta\blockgroups_PropValue_miss.dta",keepusing(MedHouseValue)
ren Id2 src_geoid
ren nbr_geoid Id2
ren MedHouseValue MedHouseValue_src
drop _merge
merge m:1 Id2 using"$dta\blockgroups_PropValue_miss.dta",keepusing(MedHouseValue)
sort src_geoid
ren Id2 nbr_geoid
drop _merge

destring MedHouseValue_src, force replace
destring MedHouseValue, force replace
egen MedHV_impute=mean(MedHouseValue), by(src_geoid)
replace MedHouseValue_src=MedHV_impute if MedHouseValue_src==.

ren nbr_geoid Id2
drop MedHouseValue
merge m:1 Id2 using"$dta\block_imputed_MedHV.dta",keepusing(MedHouseV)
drop _merge
sort src_geoid
egen MedHouseValue1=mean(MedHouseV), by(src_geoid)
replace MedHouseValue_src= MedHouseValue1 if MedHouseValue_src==.

ren Id2 nbr_geoid
ren src_geoid Id2
keep Id2 MedHouseValue_src
duplicates drop
count if MedHouseValue_src==.
save "$dta\block_imputed_MedHV1.dta",replace
sort Id2

****
use "D:\Work\CIRCA\Circa\GISdata\propbuildrev_censusblock.dta",clear
destring geoid,gen(Id2)
ren propertyfu PropertyFullStreetAddress
ren propertyci PropertyCity
ren importparc ImportParcelID
ren fips FIPS
ren state State
ren county County
ren legaltowns LegalTownship
duplicates report Id2 if LegalTownship!="DARIEN"&LegalTownship!="GREENWICH"&LegalTownship!="STAMFORD"
di r(unique_value)

merge m:1 Id2 using"$dta\block_imputed_MedHV1.dta", keepusing(MedHouseValue_src)
drop if _merge==2
drop if LegalTownship=="DARIEN"|LegalTownship=="GREENWICH"|LegalTownship=="STAMFORD"
tab _merge
ren MedHouseValue_src MedHouseValue
count if MedHouseValue==.&_merge==3
drop if _merge==1
drop _merge
hist MedHouseValue
save "$dta\property_blockMedHV.dta",replace
sum MedHouseValue

*************************************************
*                   Waterfront                  *
*************************************************
*use "$dta\proponeunit_building_revise.dta",clear

*****Clinton**********
use "$GIS\propbrev_wf_clinton.dta",clear
ren streetaddr location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street
*Clinton

replace location=subinstr(location,"GROVE WAY","GROVEWAY",1)
replace street=subinstr(street,"GROVE WAY","GROVEWAY",1)
ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_clinton.dta",replace

*****Groton**********
use "$GIS\propbrev_wf_groton.dta",clear
ren property_l location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_groton.dta",replace

*******East Haven********
use "$GIS\propbrev_wf_easthaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
ren house_no addressnum

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_easthaven.dta",replace

******East Lyme*********
use "$GIS\propbrev_wf_eastlyme.dta",clear
ren siteaddres location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_eastlyme.dta",replace

*****Fairfield**********
use "$GIS\propbrev_wf_fairfield.dta",clear
ren address location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_fairfield.dta",replace

*******guilford********
use "$GIS\propbrev_wf_guilford.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_guilford.dta",replace

********Milford*******
use "$GIS\propbrev_wf_milford.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_milford.dta",replace

********New Haven*******
use "$GIS\propbrev_wf_newhaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_newhaven.dta",replace

*******Old Lyme********
use "$GIS\propbrev_wf_oldlyme.dta",clear
ren streetaddr location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_oldlyme.dta",replace

********oldsaybrook*******
use "$GIS\propbrev_wf_oldsaybrook.dta",clear
ren streetaddr location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_oldsaybrook.dta",replace

*******Stonington********
use "$GIS\propbrev_wf_stonington.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_stonington.dta",replace

********Waterford*******
use "$GIS\propbrev_wf_waterford.dta",clear
ren siteaddres location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_waterford.dta",replace

*******westbrook********
use "$GIS\propbrev_wf_westbrook.dta",clear
ren streetaddr location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_westbrook.dta",replace

********West haven*******
use "$GIS\propbrev_wf_westhaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_westhaven.dta",replace

********Westport*******
use "$GIS\propbrev_wf_westport.dta",clear

tostring street_num, gen(addressnum)
gen location=addressnum+" "+street_nam
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)


drop if street==""|addressnum==""

drop if type_circa==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type_circa PropertyStreetNum
ren type_circa Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_westport.dta",replace

*******Stratford********
use "$GIS\propbrev_wf_stratford.dta",clear
ren realmast_3 location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_stratford.dta",replace

*******Branford********
use "$GIS\propbrev_wf_branford.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=house_no

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_branford.dta",replace

********Bridgeport*******
use "$GIS\propbrev_wf_bridgeport.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if typewatfnt==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship typewatfnt PropertyStreetNum
ren typewatfnt Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_bridgeport.dta",replace

*******New London********
use "$GIS\propbrev_wf_newlondon.dta",clear
ren siteaddres location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_newlondon.dta",replace

*******Norwalk********
use "$GIS\propbrev_wf_norwalk.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_norwalk.dta",replace

*******Madison********
use "$GIS\propbrev_wf_madison.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

drop if type==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship type PropertyStreetNum
ren type Waterfronttype
ren importparc ImportParcelID
save "$dta\waterfront_madison.dta",replace
*********Aggregate waterfront list****************
use "$dta\waterfront_clinton.dta",clear
append using "$dta\waterfront_groton.dta"
append using "$dta\waterfront_easthaven.dta"
append using "$dta\waterfront_eastlyme.dta"
append using "$dta\waterfront_fairfield.dta"
append using "$dta\waterfront_guilford.dta"
append using "$dta\waterfront_milford.dta"
append using "$dta\waterfront_newhaven.dta"
append using "$dta\waterfront_oldlyme.dta"
append using "$dta\waterfront_oldsaybrook.dta"
append using "$dta\waterfront_stonington.dta"
append using "$dta\waterfront_waterford.dta"
append using "$dta\waterfront_westbrook.dta"
append using "$dta\waterfront_westhaven.dta"
append using "$dta\waterfront_westport.dta"
append using "$dta\waterfront_stratford.dta"
append using "$dta\waterfront_branford.dta"
append using "$dta\waterfront_bridgeport.dta"
append using "$dta\waterfront_newlondon.dta"
append using "$dta\waterfront_norwalk.dta"
append using "$dta\waterfront_madison.dta"

duplicates drop
save "$dta\waterfront_oneunitct.dta",replace

******************************************************
*             Ground elevation from NED              *
******************************************************
use "D:\Work\CIRCA\Circa\GISdata\ints_ned30m41071.dta",clear
foreach n in 41072 41073 {
append using "D:\Work\CIRCA\Circa\GISdata\ints_ned30m`n'.dta"
}
ren gridcode NED_elevation
duplicates report 

ren fid_prop_o FID
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
drop _merge
drop fid_ned30m id

sort FID PropertyFullStreetAddress PropertyCity NED_elevation
duplicates drop FID,force
save "$dta\Elevation.dta",replace


******************************************************
*            Ground elevation LiDAR 2016             *
******************************************************
clear all
set more off
global Gelevation "D:\Work\CIRCA\Circa\GElevation_P"

use "$Gelevation\gel_0_2016.dta",clear
gen orig_fid=0

forv n=0 (1) 61736 {
capture append using "$Gelevation\gel_`n'_2016.dta"
replace orig_fid=`n' if orig_fid==.
}
duplicates drop


drop fid_poly_*
drop shape_leng shape_area
drop fid_coast2
merge m:1 orig_fid using"$dta\buildingp_va_ggl.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if _merge==2


egen T_area=sum(area_geo),by(FID_Buildingfootprint)
egen Ground_elev=sum(gridcode*area_geo/T_area),by(FID_Buildingfootprint)

drop _merge
keep orig_fid FID_Buildingfootprint Ground_elev
duplicates drop

drop orig_fid


merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point)
drop if _merge==2
ren FID_point FID
drop _merge
merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop _merge
ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle
save "$dta\Ground_elevation2016.dta",replace


*****************************
*          Landcover        *
*****************************
set more off

forv n=0 (1) 231648 {

capture:{
*use "D:\Work\CIRCA\Circa\nearbylandcover02\plandc_32002.dta",clear
use "D:\Work\CIRCA\Circa\nearbylandcover02\plandc_`n'2002.dta",clear
egen area_t=sum(area_geo)

*Developed includes areas with impervious surface constituting a share larger than 20%
*Imperviousness threshold values used to derive the NLCD developed classes are: (Class 21) developed open space (imperviousness < 20%), (Class 22) low-intensity developed (imperviousness from 20 - 49%), (Class 23) medium intensity developed (imperviousness from 50 -79%), and (Class 24) high-intensity developed (imperviousness > 79%). 
gen Developed=1 if gridcode==82|(gridcode>=122&gridcode<=124)
replace Developed=0 if Developed==.
egen area_dev=sum(area_geo) if Developed==1
egen area_Dev=min(area_dev)
gen ratio_Dev=area_Dev/area_t

*Forest includes: various forests, shrubland, grassland and pasture, and woody/herbaceous wetlands
gen Forest=1 if (gridcode>=141&gridcode<=195)|gridcode==63|gridcode==64
replace Forest=0 if Forest==.
egen area_fore=sum(area_geo) if Forest==1
egen area_Fore=min(area_fore)
replace area_Fore=0 if area_Fore==.
gen ratio_Fore=area_Fore/area_t

*Openspace includes: 61-Fallow/Idle Cropland, 65-Barren, 87-Wetlands, 121-Open Space, 131-Barren, 0&111-Open water,
gen Openspace=1 if gridcode==61|gridcode==65|gridcode==87|gridcode==121|gridcode==131|gridcode==0|gridcode==111
replace Openspace=0 if Openspace==.
egen area_open=sum(area_geo) if Openspace==1
egen area_Open=min(area_open)
gen ratio_Open=area_Open/area_t

*Agland includes: not dev, not forest, not openspace, and not 88-nonag/undefined, and not 81-nodata
gen Agland=1 if Developed==0&Forest==0&Openspace==0&gridcode!=88&gridcode!=81
replace Agland=0 if Agland==.
egen area_ag=sum(area_geo) if Agland==1
egen area_Ag=min(area_ag)
replace area_Ag=0 if area_Ag==.
gen ratio_Ag=area_Ag/area_t
*ratio of a landcover within half-mile radius
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
keep PropertyFullStreetAddress PropertyCity FIPS State County LegalTownship ImportParcelID LatFixed LongFixed latGoogle longGoogle orig_fid ratio*
duplicates drop
save "$landcover\lcratio_`n'2002.dta",replace
}
display "_`n'"
}

use "$landcover\lcratio_12002.dta",clear
forv n=0 (1) 231649 {
capture append using "$landcover\lcratio_`n'2002.dta"
}
duplicates drop 
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
drop if PropertyFullStreetAddress==""
save "$dta\lcratio_2002.dta",replace

set more off
forv n=0 (1) 231649 {

capture:{
*use "D:\Work\CIRCA\Circa\nearbylandcover11\plandc_32011.dta",clear
use "D:\Work\CIRCA\Circa\nearbylandcover11\plandc_`n'2011.dta",clear
egen area_t=sum(area_geo)

*Developed includes areas with impervious surface constituting a share larger than 20%
*Imperviousness threshold values used to derive the NLCD developed classes are: (Class 21) developed open space (imperviousness < 20%), (Class 22) low-intensity developed (imperviousness from 20 - 49%), (Class 23) medium intensity developed (imperviousness from 50 -79%), and (Class 24) high-intensity developed (imperviousness > 79%). 
gen Developed=1 if gridcode==82|(gridcode>=122&gridcode<=124)
replace Developed=0 if Developed==.
egen area_dev=sum(area_geo) if Developed==1
egen area_Dev=min(area_dev)
gen ratio_Dev=area_Dev/area_t

*Forest includes: various forests, shrubland, grassland and pasture, and woody/herbaceous wetlands
gen Forest=1 if (gridcode>=141&gridcode<=195)|gridcode==63|gridcode==64
replace Forest=0 if Forest==.
egen area_fore=sum(area_geo) if Forest==1
egen area_Fore=min(area_fore)
replace area_Fore=0 if area_Fore==.
gen ratio_Fore=area_Fore/area_t

*Openspace includes: 61-Fallow/Idle Cropland, 65-Barren, 87-Wetlands, 121-Open Space, 131-Barren, 0&111-Open water,
gen Openspace=1 if gridcode==61|gridcode==65|gridcode==87|gridcode==121|gridcode==131|gridcode==0|gridcode==111
replace Openspace=0 if Openspace==.
egen area_open=sum(area_geo) if Openspace==1
egen area_Open=min(area_open)
gen ratio_Open=area_Open/area_t

*Agland includes: not dev, not forest, not openspace, and not 88-nonag/undefined, and not 81-nodata
gen Agland=1 if Developed==0&Forest==0&Openspace==0&gridcode!=88&gridcode!=81
replace Agland=0 if Agland==.
egen area_ag=sum(area_geo) if Agland==1
egen area_Ag=min(area_ag)
replace area_Ag=0 if area_Ag==.
gen ratio_Ag=area_Ag/area_t
*ratio of a landcover within half-mile radius
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
keep PropertyFullStreetAddress PropertyCity FIPS State County LegalTownship ImportParcelID LatFixed LongFixed latGoogle longGoogle orig_fid ratio*
duplicates drop
save "$landcover\lcratio_`n'2011.dta",replace
}
display "_`n'"
}

use "$landcover\lcratio_12011.dta",clear
forv n=0 (1) 231649 {
capture append using "$landcover\lcratio_`n'2011.dta"
}
duplicates drop 
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
drop if PropertyFullStreetAddress==""
save "$dta\lcratio_2011.dta",replace


set more off
forv n=0 (1) 231649 {

capture:{
*use "$landcover\plandc_32015.dta",clear
use "$landcover\plandc_`n'2015.dta",clear
egen area_t=sum(area_geo)

*Developed includes areas with impervious surface constituting a share larger than 20%
*Imperviousness threshold values used to derive the NLCD developed classes are: (Class 21) developed open space (imperviousness < 20%), (Class 22) low-intensity developed (imperviousness from 20 - 49%), (Class 23) medium intensity developed (imperviousness from 50 -79%), and (Class 24) high-intensity developed (imperviousness > 79%). 
gen Developed=1 if gridcode==82|(gridcode>=122&gridcode<=124)
replace Developed=0 if Developed==.
egen area_dev=sum(area_geo) if Developed==1
egen area_Dev=min(area_dev)
gen ratio_Dev=area_Dev/area_t

*Forest includes: various forests, shrubland, grassland and pasture, and woody/herbaceous wetlands
gen Forest=1 if (gridcode>=141&gridcode<=195)|gridcode==63|gridcode==64
replace Forest=0 if Forest==.
egen area_fore=sum(area_geo) if Forest==1
egen area_Fore=min(area_fore)
gen ratio_Fore=area_Fore/area_t

*Openspace includes: 61-Fallow/Idle Cropland, 65-Barren, 87-Wetlands, 121-Open Space, 131-Barren, 0&111-Open water,
gen Openspace=1 if gridcode==61|gridcode==65|gridcode==87|gridcode==121|gridcode==131|gridcode==0|gridcode==111
replace Openspace=0 if Openspace==.
egen area_open=sum(area_geo) if Openspace==1
egen area_Open=min(area_open)
gen ratio_Open=area_Open/area_t

*Agland includes: not dev, not forest, not openspace, and not 88-nonag/undefined, and not 81-nodata
gen Agland=1 if Developed==0&Forest==0&Openspace==0&gridcode!=88&gridcode!=81
replace Agland=0 if Agland==.
egen area_ag=sum(area_geo) if Agland==1
egen area_Ag=min(area_ag)
replace area_Ag=0 if area_Ag==.
gen ratio_Ag=area_Ag/area_t
*ratio of a landcover within half-mile radius
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
keep PropertyFullStreetAddress PropertyCity FIPS State County LegalTownship ImportParcelID LatFixed LongFixed latGoogle longGoogle orig_fid ratio*
duplicates drop
save "$landcover\lcratio_`n'2015.dta",replace
}
display "_`n'"
}

use "$landcover\lcratio_12015.dta",clear
forv n=0 (1) 231649 {
capture append using "$landcover\lcratio_`n'2015.dta"
}
duplicates drop 
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
drop if PropertyFullStreetAddress==""
save "$dta\lcratio_2015.dta",replace













**************Parcel Polygon*******************
set more off
use "$Parcel_Poly\parcel.dta",clear
replace fid_viewsh=_n-1
merge 1:m fid_viewsh using"$dta\viewshed_poly.dta",keepusing(fid_viewsh)
duplicates report fid_viewsh
duplicates drop fid_viewsh,force
replace vsanalysis=1 if _merge==3
replace vsanalysis=0 if _merge!=3
drop _merge
export delimited using "D:\UConn2\Circa\GISdata\Parcel_shp\PARCEL.csv", replace


use "$GIS\viewshed_poly",clear
drop fid_viewsh vsanalysis
ren fid_parcel fid_viewsh
duplicates report fid_viewsh
duplicates report fid_proper
duplicates drop fid_proper,force

save "$dta\viewshed_poly.dta",replace


************Stilting Between 2012 and 2016**********
set more off
forv m=0 (1) 109700 {
capture:{
clear all
use "$stilting\pel_`m'_16m12.dta",clear
*use "$stilting\pel_107519_16m12.dta",clear
*gridcode=elevation difference in .5 ft

gen elev_ft=.5*gridcode
gen elev_timesarea=elev_ft*area_geo
egen elev_timesa_total=sum(elev_ti mesarea)

drop if gridcode==0
*hist gridcode
egen area_t=sum(area_geo)
drop elev_timesarea shape_leng shape_area gridcode id fid_pelbuf buff_dist orig_fid fid_elpoly
egen area_elev=sum(area_geo),by(elev_ft)

*Identifying small-cell area (trees or vegitations)
gen rising=1 if elev_ft[_n]>elev_ft[_n-1]
gen dropping=1 if elev_ft[_n-1]>elev_ft[_n]
replace dropping=0 if dropping==.

gen positive=1 if elev_ft>0
replace positive=0 if positive==.

gen N_consecutive=.

egen Noobs=max(_n)

tempname x y max
scalar `max' = Noobs

di `max'

scalar `x'=1

while `x' < `max'{

tempname v n

scalar `v'=0
scalar `n'=`x'

if  dropping[`n']==1 {
        while dropping[`n']==1 {
        scalar `n'=`n'+1
        }
		scalar `v'=`n'-`x'
		}
		else {
		    while dropping[`n']==0 {
            scalar `n'=`n'+1
            }
		    scalar `v'=`n'-`x'
        }
		
replace N_consecutive=`v' if _n<`n'&_n>=`x'
scalar `x'=`n'
}


gen N_consecutive_s=.

scalar `y'=1

while `y' < `max'{

tempname v n

scalar `v'=0
scalar `n'=`y'

if  positive[`n']==1 {
        while positive[`n']==1 {
        scalar `n'=`n'+1
        }
		scalar `v'=`n'-`y'
		}
		else {
		    while positive[`n']==0 {
            scalar `n'=`n'+1
            }
		    scalar `v'=`n'-`y'
        }
		
replace N_consecutive_s=`v' if _n<`n'&_n>=`y'
scalar `y'=`n'
}


drop area_geo
egen N_Consecutive_elev=mean(N_consecutive),by(elev_ft)
drop N_consecutive

egen N_Consecutive_sign=mean(N_consecutive_s),by(elev_ft)
drop N_consecutive_s

duplicates drop

keep rowid_ elev_timesa_total area_elev area_t elev_ft N_Consecutive_elev N_Consecutive_sign
duplicates drop
sort elev_ft

*further sorting, get those with a large area being elevated a certain feet
gen approxy=0
replace approxy=5 if elev_ft>=0&elev_ft<7.5
replace approxy=10 if elev_ft>=7.5&elev_ft<12.5
replace approxy=15 if elev_ft>=12.5&elev_ft<17.5
replace approxy=20 if elev_ft>=17.5&elev_ft<22.5
replace approxy=25 if elev_ft>=22.5&elev_ft<27.5
replace approxy=30 if elev_ft>=27.5&elev_ft<32.5
replace approxy=35 if elev_ft>=32.5&elev_ft<37.5
replace approxy=40 if elev_ft>=37.5&elev_ft<42.5
replace approxy=45 if elev_ft>=42.5&elev_ft<47.5
replace approxy=50 if elev_ft>=47.5
egen area_elevapp=sum(area_elev),by(approxy)
egen Nconsecutive_elevapp=sum(N_Consecutive_elev*area_elev/area_elevapp),by(approxy)
egen Nconsecutive_signapp=sum(N_Consecutive_sign*area_elev/area_elevapp),by(approxy)
drop area_elev elev_ft N_Consecutive_elev N_Consecutive_sign
duplicates drop
drop if approxy==0

gen Elevated_ft=(area_elevapp>1500&approxy==5)
replace Elevated_ft=1 if area_elevapp>500&approxy==10
replace Elevated_ft=1 if area_elevapp>450&approxy==15
replace Elevated_ft=1 if area_elevapp>350&approxy>=20&approxy<=30
replace Elevated_ft=1 if area_elevapp>300&approxy>=35

replace Elevated_ft=0 if (Nconsecutive_elevapp<2|Nconsecutive_signapp<4.8)&(Nconsecutive_signapp<18)

reshape wide area_elevapp Elevated_ft Nconsecutive_elevapp Nconsecutive_signapp,i(rowid_ elev_timesa_total area_t) j(approxy)

save "$stilting\elev_`m'_16m12.dta",replace
} 
display "_`m'"
}

*Separating makes it faster
/*old script 
forv n=0 (1) 109700 {
capture:{
use "$stilting\pel_`n'_16m12.dta",clear
*gridcode=elevation difference in .5 ft

gen elev_ft=.5*gridcode
gen elev_timesarea=elev_ft*area_geo
egen elev_timesa_total=sum(elev_timesarea)

drop if gridcode==0
egen area_t=sum(area_geo)

drop elev_timesarea shape_leng shape_area gridcode id fid_pelbuf buff_dist orig_fid fid_elpoly

egen area_elev=sum(area_geo),by(elev_ft)
drop area_geo
duplicates drop

keep rowid_ elev_timesa_total area_elev area_t elev_ft
duplicates drop
sort elev_ft

*further sorting, get those with a large area being elevated a certain feet
gen approxy=0
replace approxy=5 if elev_ft>=0&elev_ft<7.5
replace approxy=10 if elev_ft>=7.5&elev_ft<12.5
replace approxy=15 if elev_ft>=12.5&elev_ft<17.5
replace approxy=20 if elev_ft>17.5&elev_ft<22.5
replace approxy=25 if elev_ft>=22.5&elev_ft<27.5
replace approxy=30 if elev_ft>27.5&elev_ft<32.5
replace approxy=35 if elev_ft>=32.5&elev_ft<37.5
replace approxy=40 if elev_ft>37.5&elev_ft<42.5
replace approxy=45 if elev_ft>=42.5&elev_ft<47.5
replace approxy=50 if elev_ft>47.5
egen area_elevapp=sum(area_elev),by(approxy)
drop area_elev elev_ft
duplicates drop
drop if approxy==0

gen Elevated_ft=(area_elevapp>1500&approxy==5)
replace Elevated_ft=1 if area_elevapp>500&approxy>5
reshape wide area_elevapp Elevated_ft,i(rowid_ elev_timesa_total area_t) j(approxy)

save "$stilting\elev_`n'_16m12.dta",replace
} 
display "_`n'"
}
*/
use "$stilting\elev_0_16m12.dta",clear
forv n=0 (1) 109700 {
*forv n=0 (1) 41500 {
capture append using "$stilting\elev_`n'_16m12.dta"
}
duplicates drop 

ren rowid_ RowID
gen Elev_flag=1 if (Elevated_ft5==1|Elevated_ft10==1|Elevated_ft15==1|Elevated_ft20==1|Elevated_ft25==1|Elevated_ft35==1|Elevated_ft30==1|Elevated_ft40==1|Elevated_ft50==1|Elevated_ft45==1)
count if Elev_flag==1
gen Elev_ft=.
forv n=5 (5) 50{
replace Elev_ft=`n' if Elevated_ft`n'==1&Elev_flag==1
}
tab Elev_ft if Elev_flag==1

save "$dta\stilting_12_16.dta",replace

use "$dta\stilting_12_16.dta",clear
hist area_elevapp35
hist Nconsecutive_elevapp5
hist Nconsecutive_elevapp10
hist Nconsecutive_elevapp15
hist Nconsecutive_elevapp20

hist Nconsecutive_signapp5
hist Nconsecutive_signapp10
hist Nconsecutive_signapp15
hist Nconsecutive_signapp20

keep if Elev_flag==1
save "$dta\Elevated_property.dta",replace





************************************************
*          Structure elevation 2016            *
************************************************
clear all
set more off
global STRelevation "D:\UConn2\Circa\Strelevation_P"

use "$STRelevation\gel_0_2016.dta",clear
gen orig_fid=0

forv n=0 (1) 48255 {
capture append using "$STRelevation\gel_`n'_2016.dta"
replace orig_fid=`n' if orig_fid==.
}
duplicates drop


drop fid_poly_*
drop shape_leng shape_area
drop shape_le_1 shape_ar_1
merge m:1 orig_fid using"$dta\buildingp_va_oneunit.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if _merge==2


egen T_area=sum(area_geo),by(FID_Buildingfootprint)
egen Str_elev=sum(gridcode*area_geo/T_area),by(FID_Buildingfootprint)

drop _merge
keep orig_fid FID_Buildingfootprint Str_elev
duplicates drop

drop orig_fid


merge 1:m FID_Buildingfootprint using"$dta\Point_Buildingfootprint.dta",keepusing(FID_point)
ren FID_point FID
drop _merge
merge m:1 FID using"$dta\viewshed_prop.dta"
drop _merge
save "$dta\Str_elevation2016.dta",replace


************************************************
*          Structure elevation 2012            *
************************************************
clear all
set more off
global STRelevation "D:\UConn2\Circa\Strelev12_P"

use "$STRelevation\gel_0_2012.dta",clear
gen orig_fid=0

forv n=0 (1) 48255 {
capture append using "$STRelevation\gel_`n'_2012.dta"
replace orig_fid=`n' if orig_fid==.
}
duplicates drop


drop fid_poly_*
drop shape_leng shape_area
drop shape_le_1 shape_ar_1
merge m:1 orig_fid using"$dta\buildingp_va_oneunit.dta",keepusing(FID_Buildingfootprint)
drop if _merge==1
drop if _merge==2


egen T_area=sum(area_geo),by(FID_Buildingfootprint)
egen Str_elev=sum(gridcode*area_geo/T_area),by(FID_Buildingfootprint)

drop _merge
keep orig_fid FID_Buildingfootprint Str_elev
duplicates drop

drop orig_fid


merge 1:m FID_Buildingfootprint using"$dta\Point_Buildingfootprint.dta",keepusing(FID_point)
ren FID_point FID
drop _merge
merge m:1 FID using"$dta\viewshed_prop.dta"
drop _merge
save "$dta\Str_elevation2012.dta",replace


*****************************************
*          Elevation Certificates       *
*****************************************
import excel "D:\UConn2\Circa\CT_Property\Permit\Tables\Old Saybrook - ElevationCertificates.xlsx", sheet("Old Saybrook EC's") firstrow clear
ren PDFFileName Filename
ren A1 Ownername
ren A2 Address
ren A3 Lotandblock
ren A4 Buildinguse
ren A5 Latlong
ren A6 twophotosattached
ren A7 BuildingdiagramNo
ren A8a Sqftcrawlspace
ren A8b Nooffloodopenings
ren A8c Areaoffloodopenings
ren A8d Engineeredopenings
ren A9a Sqftattachedgara
ren A9b Nooffloodopeningsingara
ren A9c Areaoffloodopeningsingara
ren A9d Engineeredopeningsingara
ren B1 NFIPCommunity
ren B2 County
ren B3 State
ren B4 MapPanelNumber
ren B5 MapSuffix
ren B6 FIRMIndexDate
ren B7 FIRMEffectiveDate
ren B8 Floodzone
ren B9 BFE
ren B10 BFEsource
ren B11 VerticalDatum 
ren B12 CBRSorOPA
ren C1 Constructionstatus
ren C2aft Topofbottomfloor_elev
ren C2b Topofnexthigher
ren C2c BotofthelowestVonly
ren C2d Attachedgara
ren C2e Lowestofmachinery
ren C2f Lowestadjacent
ren C2g Highestadjacent
ren C2h Lowestadjatlowestelevofdeck

tostring *,replace

replace Address=upper(Address)
replace Address=subinword(Address,"STREET","ST",1)
replace Address=subinword(Address,"AVENUE","AVE",1)
replace Address=subinword(Address,"DRIVE","DR",1)
replace Address=subinword(Address,"ROAD","RD",1)
replace Address=subinword(Address,"LANE","LN",1)
replace Address=subinword(Address,"CIRCLE","CIR",1)
replace Address=subinword(Address,"COURT","CT",1)

replace Address=subinstr(Address," IS "," ISLAND ",1)
replace Address=subinstr(Address," IS. "," ISLAND ",1)
replace Address=subinstr(Address," RD."," RD",1)
replace Address=subinstr(Address," ST."," ST",1)
replace Address=subinstr(Address," PT "," POINT ",1)
replace Address=subinstr(Address," PT. "," POINT ",1)
replace Address=subinstr(Address," DR."," DR",1) 
replace Address=subinstr(Address," DR "," DR",1) 
replace Address=subinstr(Address," RD "," RD",1) 
replace Address=subinstr(Address," AVE "," AVE",1)
replace Address=subinstr(Address," AVE."," AVE",1)  
replace Address=subinstr(Address," SOUND VIEW AVE-1"," SOUNDVIEW AVE",1)  
replace Address=subinstr(Address," SEA LANE-2"," SEA LN",1)  
gen LegalTownship="OLD SAYBROOK"
save "$dta\EC_OldSaybrook.dta",replace

import excel "D:\UConn2\Circa\CT_Property\Permit\Tables\Fairfield_ElevationCertficates_part1.xlsx", sheet("Fairfield EC") firstrow clear
ren PDFFile Filename
ren A1 Ownername
ren A2 Address
ren A3 Lotandblock
ren A4 Buildinguse
ren A5 Latlong
ren A6 twophotosattached
ren A7 BuildingdiagramNo
ren A8a Sqftcrawlspace
ren A8b Nooffloodopenings
ren A8c Areaoffloodopenings
ren A8d Engineeredopenings
ren A9a Sqftattachedgara
ren A9b Nooffloodopeningsingara
ren A9c Areaoffloodopeningsingara
ren A9d Engineeredopeningsingara
ren B1 NFIPCommunity
ren B2 County
ren B3 State
ren B4 MapPanelNumber
ren B5 MapSuffix
ren B6 FIRMIndexDate
ren B7 FIRMEffectiveDate
ren B8 Floodzone
ren B9 BFE
ren B10 BFEsource
ren B11 VerticalDatum 
ren B12 CBRSorOPA
ren C1 Constructionstatus
ren C2aft Topofbottomfloor_elev
ren C2b Topofnexthigher
ren C2c BotofthelowestVonly
ren C2d Attachedgara
ren C2e Lowestofmachinery
ren C2f Lowestadjacent
ren C2g Highestadjacent
ren C2h Lowestadjatlowestelevofdeck

tostring *,replace

replace Address=upper(Address)
replace Address=subinword(Address,"STREET","ST",1)
replace Address=subinword(Address,"AVENUE","AVE",1)
replace Address=subinword(Address,"DRIVE","DR",1)
replace Address=subinword(Address,"ROAD","RD",1)
replace Address=subinword(Address,"LANE","LN",1)
replace Address=subinword(Address,"CIRCLE","CIR",1)
replace Address=subinword(Address,"COURT","CT",1)

replace Address=subinstr(Address," IS "," ISLAND ",1)
replace Address=subinstr(Address," IS. "," ISLAND ",1)
replace Address=subinstr(Address," RD."," RD",1)
replace Address=subinstr(Address," ST."," ST",1)
replace Address=subinstr(Address," PT "," POINT ",1)
replace Address=subinstr(Address," PT. "," POINT ",1)
replace Address=subinstr(Address," DR."," DR",1) 
replace Address=subinstr(Address," DR "," DR",1) 
replace Address=subinstr(Address," RD "," RD",1) 
replace Address=subinstr(Address," AVE "," AVE",1)
replace Address=subinstr(Address," AVE."," AVE",1)  
replace Address=subinstr(Address," SOUND VIEW AVE-1"," SOUNDVIEW AVE",1)  
replace Address=subinstr(Address," SEA LANE-2"," SEA LN",1) 
drop if Filename==""
gen LegalTownship="FAIRFIELD"

save "$dta\EC_Fairfield1.dta",replace

*See what makes a FEMA compliant property
use "$dta\Fairfield_permit",clear
merge 1:m Address using"$dta\EC_Fairfield1.dta"
order BFE Topofbottomfloor_elev Topofnexthigher BotofthelowestVonly Attachedgara Lowestofmachinery Lowestadjacent Highestadjacent

*Determine FEMA compliance
use "$dta\EC_Fairfield1.dta",clear
replace Topofbottomfloor_elev="" if Topofbottomfloor_elev=="N/A"
destring Topofbottomfloor_elev,replace
replace Topofnexthigher="" if Topofnexthigher=="N/A"
destring Topofnexthigher,replace
replace Sqftattachedgara="" if Sqftattachedgara=="N/A"
destring Sqftattachedgara,replace
replace Areaoffloodopeningsingara="" if Areaoffloodopeningsingara=="N/A"
destring Areaoffloodopeningsingara,replace
gen FEMA_compl_project=1 if BuildingdiagramNo=="5"&Topofbottomfloor_elev>=BFE+1
replace FEMA_compl_project=1 if BuildingdiagramNo!="5"&(Areaoffloodopenings>=Sqftcrawlspace)&(Areaoffloodopeningsingara>=Sqftattachedgara)&Topofnexthigher>BFE+1
replace FEMA_compl_project=1 if BuildingdiagramNo!="5"&(Areaoffloodopenings<Sqftcrawlspace|Areaoffloodopeningsingara<Sqftattachedgara)&Topofbottomfloor_elev>BFE+1

replace FEMA_compl_project=0 if FEMA_compl_project==.
tab FEMA_compl_project
*keep if _merge==3




import excel "D:\UConn2\Circa\CT_Property\Permit\Tables\Stonington_ElevationCertificates.xlsx", sheet("Elevation Data") firstrow clear
ren A Filename
ren A1 Ownername
ren A2 Address
ren A3 Lotandblock
ren A4 Buildinguse
ren A5 Latlong
ren A6 twophotosattached
ren A7 BuildingdiagramNo
ren A8a Sqftcrawlspace
ren A8b Nooffloodopenings
ren A8c Areaoffloodopenings
ren A8d Engineeredopenings
ren A9a Sqftattachedgara
ren A9b Nooffloodopeningsingara
ren A9c Areaoffloodopeningsingara
ren A9d Engineeredopeningsingara
ren B1 NFIPCommunity
ren B2 County
ren B3 State
ren B4 MapPanelNumber
ren B5 MapSuffix
ren B6 FIRMIndexDate
ren B7 FIRMEffectiveDate
ren B8 Floodzone
ren B9 BFE
ren B10 BFEsource
ren B11 VerticalDatum 
ren B12 CBRSorOPA
ren C1 Constructionstatus
ren C2aft Topofbottomfloor_elev
ren C2b Topofnexthigher
ren C2c BotofthelowestVonly
ren C2d Attachedgara
ren C2e Lowestofmachinery
ren C2f Lowestadjacent
ren C2g Highestadjacent
ren C2h Lowestadjatlowestelevofdeck

tostring *,replace

replace Address=upper(Address)
replace Address=subinword(Address,"STREET","ST",1)
replace Address=subinword(Address,"AVENUE","AVE",1)
replace Address=subinword(Address,"DRIVE","DR",1)
replace Address=subinword(Address,"ROAD","RD",1)
replace Address=subinword(Address,"LANE","LN",1)
replace Address=subinword(Address,"CIRCLE","CIR",1)
replace Address=subinword(Address,"COURT","CT",1)

replace Address=subinstr(Address," IS "," ISLAND ",1)
replace Address=subinstr(Address," IS. "," ISLAND ",1)
replace Address=subinstr(Address," RD."," RD",1)
replace Address=subinstr(Address," ST."," ST",1)
replace Address=subinstr(Address," PT "," POINT ",1)
replace Address=subinstr(Address," PT. "," POINT ",1)
replace Address=subinstr(Address," DR."," DR",1) 
replace Address=subinstr(Address," DR "," DR",1) 
replace Address=subinstr(Address," RD "," RD",1) 
replace Address=subinstr(Address," AVE "," AVE",1)
replace Address=subinstr(Address," AVE."," AVE",1)  
replace Address=subinstr(Address," SOUND VIEW AVE-1"," SOUNDVIEW AVE",1)  
replace Address=subinstr(Address," SEA LANE-2"," SEA LN",1)  

gen LegalTownship="STONINGTON"
save "$dta\EC_Stonington.dta",replace



*******************************************************
*               Elevations from permit                *
*******************************************************
clear all
set more off
import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\milfordelevation_Permit\hereismilfordalthoughiknowyouarentreadyforthisy\MilfordPermits_Raise_Elev_Lift.xlsx", sheet("Sheet1") firstrow clear
gen Elevated=1
drop Goodrating
ren DateIssued Date
keep Location Date DateComplete Elevated
gen date_complete=date(DateComplete,"MDY")
format date_complete %tdnn/dd/CCYY
drop DateComplete
ren date_complete DateComplete
save "$dta\Milford_Elev_Permit.dta",replace

set more off
import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\milfordelevation_Permit\hereismilfordalthoughiknowyouarentreadyforthisy\MilfordPermits_DemoRebuilds.xlsx", sheet("Sheet1") firstrow clear
gen DemoRebuild=1
drop Goodrating
ren DateIssued Date
keep Location Date DateComplete DemoRebuild
save "$dta\Milford_DemRebuild_Permit.dta",replace

set more off
import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\milfordelevation_Permit\hereismilfordalthoughiknowyouarentreadyforthisy\MIlfordPermits_NewConstruct.xlsx", sheet("Sheet1") firstrow clear
gen NewBuild=1
drop Goodrating
ren DateIssued Date
keep Location Date DateComplete NewBuild
save "$dta\Milford_Newbuild_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\branfordelevation_Permit\BranfordPermits_Lift_Raise_Elevate.xlsx", sheet("Sheet1") firstrow clear
ren Address Location
gen Elevated=1
keep Location Date Elevated
save "$dta\Branford_Elev_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\branfordelevation_Permit\BranfordPermits_Demos.xlsx", sheet("Sheet1") firstrow clear
ren Address Location
gen DemoRebuild=1
keep Location Date DemoRebuild
save "$dta\Branford_DemRebuild_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\branfordelevation_Permit\BanfordPermits_NewConstruction.xlsx", sheet("Sheet1") firstrow clear
ren Address Location
gen NewBuild=1
keep Location Date NewBuild
save "$dta\Branford_Newbuild_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\norwalkelevations_Permit\NorwalkPermitList.xlsx", sheet("Sheet1") firstrow clear
ren DatePermitFiled Date
ren AddressStreetnumberinparent Location
gen Elevated=1
gen branketpos=strpos(Location,"(")
gen StreetNum=substr(Location,branketpos+1,3)
destring StreetNum,replace
tostring StreetNum,replace
gen Street=substr(Location,1,branketpos-2)
replace Street=subinstr(Street,".","",.)
replace Location=StreetNum+" "+Street

keep Location Date Elevated
save "$dta\Norwalk_Elev_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\oldsaybrookelevations_Permit\OldSaybrookPermits_Elevations.xlsx",sheet("Sheet1") firstrow clear
ren FloodPermitApprovalDate Date
gen Elevated=1
gen Location=G+" "+Street

keep Location Date Elevated FEMACOMPLY
save "$dta\OldSaybrook_Elev_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\oldsaybrookelevations_Permit\OldSaybrookPermits_FEMAComplianceStatus.xlsx", sheet("Sheet1") firstrow clear
ren FloodPermitApprovalDate Date
replace FEMACOMPLY=upper(FEMACOMPLY)
gen FEMA_COMPLY=(FEMACOMPLY=="YES")
gen Location=G+" "+Street
replace Location=subinstr(Location,".","",.)
replace Location=trim(Location)
keep Location Date FEMA_COMPLY
save "$dta\OldSaybrook_FEMAComply_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\oldsaybrookelevations_Permit\OldSaybrookPermits_DemoRebuild.xlsx", sheet("Sheet1") firstrow clear
ren FloodPermitApprovalDate Date
gen DemoRebuild=1
gen Location=G+" "+Street
replace Location=subinstr(Location,".","",.)
replace Location=trim(Location)
keep Location Date DemoRebuild FEMACOMPLY
save "$dta\OldSaybrook_DemRebuild_Permit.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\oldsaybrookelevations_Permit\OldSaybrookPermits_NewConstruction.xlsx", sheet("Sheet1") firstrow clear
ren FloodPermitApprovalDate Date
gen NewBuild=1
gen Location=G+" "+Street
replace Location=subinstr(Location,".","",.)
replace Location=trim(Location)
keep Location Date NewBuild FEMACOMPLY
save "$dta\OldSaybrook_NewBuild_Permit.dta",replace


import excel "D:\Work\CIRCA\Circa\CT_Property\Permit&parcelsummary\westport_permit\westport\Westport_permit.xlsx", sheet("Sheet1")firstrow clear
ren PermitDate Date
drop if Date==.
tab Action
gen Elevated=(Action=="Elev/Mitigate")
gen NewBuild=(Action=="NewConstruct"|Action=="new house")
tostring Num, gen(StreetNo)
replace Location=StreetNo+" "+Location
keep Location Date Elevated NewBuild
save "$dta\Westport_Elev_Permit.dta",replace


**********************************
*         LOMA aggregation       *
**********************************
/*
import excel "D:\Work\CIRCA\Circa\CT_Property\LOMA\Dig_scan\Summary_All.xlsx", sheet("Sheet1") firstrow clear
drop F G H I J K L M N
drop O P Q R S T U V W
replace IssueDate=trim(IssueDate)
export excel using "D:\Work\CIRCA\Circa\CT_Property\LOMA\Dig_scan\Summary_All.xlsx", firstrow(variables) replace
*/
import excel "D:\Work\CIRCA\Circa\CT_Property\LOMA\Dig_scan\Summary_All.xlsx", sheet("Sheet1") firstrow clear
gen IssueYear=substr(IssueDate,-4,4)
destring IssueYear,replace
gen slash_pos=strpos(IssueDate,"/")

gen IssueDay=substr(IssueDate,1,2) if slash_pos==0
replace IssueDay=substr(IssueDate,slash_pos+1,2) if slash_pos>0
destring IssueDay,replace

gen IssueMonth=substr(IssueDate,1,2) if slash_pos>0
replace IssueMonth="01" if substr(IssueDate,3,3)=="jan"&slash_pos==0
replace IssueMonth="02" if substr(IssueDate,3,3)=="feb"&slash_pos==0
replace IssueMonth="03" if substr(IssueDate,3,3)=="mar"&slash_pos==0
replace IssueMonth="04" if substr(IssueDate,3,3)=="apr"&slash_pos==0
replace IssueMonth="05" if substr(IssueDate,3,3)=="may"&slash_pos==0
replace IssueMonth="06" if substr(IssueDate,3,3)=="jun"&slash_pos==0
replace IssueMonth="07" if substr(IssueDate,3,3)=="jul"&slash_pos==0
replace IssueMonth="08" if substr(IssueDate,3,3)=="aug"&slash_pos==0
replace IssueMonth="09" if substr(IssueDate,3,3)=="sep"&slash_pos==0
replace IssueMonth="10" if substr(IssueDate,3,3)=="oct"&slash_pos==0
replace IssueMonth="11" if substr(IssueDate,3,3)=="nov"&slash_pos==0
replace IssueMonth="12" if substr(IssueDate,3,3)=="dec"&slash_pos==0
destring IssueMonth,replace

*Errors detected from excel's auto recognition of dates, revise here
gen sub=.
replace sub=IssueDay if slash_pos==0&IssueDay<=12
replace IssueDay=IssueMonth if slash_pos==0&IssueDay<=12
replace IssueMonth=sub if sub!=.

drop sub
drop IssueDate
gen IssueDate=mdy(IssueMonth,IssueDay,IssueYear)
format IssueDate %tdnn/dd/CCYY
drop if IssueDate==.

keep IssueDate IssueYear IssueMonth IssueDay Community Address Status StatusDate
order IssueDate IssueYear IssueMonth IssueDay Community Address Status StatusDate

replace Address=subinstr(Address,"."," ",.)
replace Address=subinstr(Address,"·"," ",.)
gen dash_lastpos=strrpos(Address,"-")
replace Address=substr(Address,dash_lastpos+1,strlen(Address)-dash_lastpos)
replace Address=strtrim(Address)
replace Address=stritrim(Address)

replace Community="Groton" if Community=="City of Groton"|Community=="Town of Groton"
replace Community="STONINGTON" if Community=="STONINGTON, Borough of"
replace Community=strtrim(Community)
replace Community=stritrim(Community)
replace Community=upper(Community)
drop dash_lastpos
save "$dta\LOMA_Summary.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\LOMA\Dig_scan\LOMA_All.xlsx", sheet("Sheet1") firstrow clear
replace IssueDate=substr(IssueDate,strpos(IssueDate,":")+2,strlen(IssueDate)-strpos(IssueDate,":")-1)
gen slash_pos=strpos(IssueDate,"/")

gen IssueDay=substr(IssueDate,slash_pos+1,strlen(IssueDate)-5-slash_pos) if slash_pos>0
gen IssueMonth=substr(IssueDate,1,slash_pos-1) if slash_pos>0
gen IssueYear=substr(IssueDate,-4,4) if slash_pos>0
destring IssueDay,replace
destring IssueMonth,replace
destring IssueYear,replace
drop IssueDate
gen IssueDate=mdy(IssueMonth,IssueDay,IssueYear)
format IssueDate %tdnn/dd/CCYY
drop if IssueDate==.
keep IssueDate IssueYear IssueMonth IssueDay Community Address
order IssueDate IssueYear IssueMonth IssueDay Community Address
tab Community
replace Community="GROTON" if Community=="CITY OF GROTON"|Community=="TOWN OF GROTON"|Community=="GROTON LONG POINT ASSOCIATION"
replace Community="NEW HAVEN" if Community=="CITY OF NEW HAVEN"
save "$dta\LOMA_Scan.dta",replace

import excel "D:\Work\CIRCA\Circa\CT_Property\LOMA\Dig_scan\LOMA_Publicdata.xlsx", sheet("Sheet1") firstrow clear
ren issue_date IssueDate
ren address Address
replace IssueDate=substr(IssueDate,strpos(IssueDate,":")+2,strlen(IssueDate)-strpos(IssueDate,":")-1)
gen slash_pos=strpos(IssueDate,"/")

gen IssueDay=substr(IssueDate,slash_pos+1,strlen(IssueDate)-5-slash_pos) if slash_pos>0
gen IssueMonth=substr(IssueDate,1,slash_pos-1) if slash_pos>0
gen IssueYear=substr(IssueDate,-4,4) if slash_pos>0
destring IssueDay,replace
destring IssueMonth,replace
destring IssueYear,replace
drop IssueDate
gen IssueDate=mdy(IssueMonth,IssueDay,IssueYear)
format IssueDate %tdnn/dd/CCYY
drop if IssueDate==.
keep IssueDate IssueYear IssueMonth IssueDay Community Address
order IssueDate IssueYear IssueMonth IssueDay Community Address

gen of_pos=strpos(Community," OF ")
replace Community=substr(Community,of_pos+4,strlen(Community)-of_pos-3)
tab Community
drop of_pos
save "$dta\LOMA_Publicdata.dta",replace

*append
use "$dta\LOMA_Summary.dta",clear
append using "$dta\LOMA_Scan.dta"
append using "$dta\LOMA_Publicdata.dta"
replace Community="OLD SAYBROOK" if Community=="FENWICK"
replace Community="GROTON" if Community=="NK FIRE DISTRICT"
replace Community="GROTON" if Community=="NOANK FIRE DISTRICT"
tab Community
replace Address=upper(Address)
duplicates drop
duplicates report IssueDate Address Community
duplicates tag IssueDate Address Community,gen(dup)
tab dup
drop if dup>0&Status==""

sort Community Address IssueDate Status StatusDate
duplicates drop IssueDate Address Community Status,force
drop dup
duplicates tag IssueDate Address Community,gen(dup)
tab dup
browse if dup>0
drop if dup>0&(Status=="LOMCs Not Incorporated"|Status=="LOMCs To Be Redetermined")
drop dup
duplicates report IssueDate Address Community

*Prepare for merge with the main dataset
duplicates report Community Address
duplicates tag Community Address,gen(dup)
browse if dup>0
sort Community Address IssueDate
duplicates drop Community Address Status,force
drop dup
duplicates tag Community Address,gen(dup)
drop if dup>0&Status==""
drop dup
duplicates report Community Address
duplicates tag Community Address,gen(dup)
drop if dup>0&Status=="LOMCs Not Incorporated"
drop dup

gen lastblank_in_add=strrpos(Address," ")
gen last_word_address=substr(Address,lastblank_in_add+1,strlen(Address)-lastblank_in_add)
tab last_word_address
drop lastblank_in_add last_word_address

ren Address PropertyFullStreetAddress
ren Community LegalTownship
tab LegalTownship

*revise address

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," ROAD"," RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," ROA"," RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," ROAO"," RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," AVENUE"," AVE",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," AVEN"," AVE",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," COURT"," CT",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," CIRCLE"," CIR",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," DRIVE"," DR",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," LANE"," LN",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," PLACE"," PL",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," POINT"," PT",1)


replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," STREET"," ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," SREET"," ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," STREET(CL)"," ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," STREETS"," ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," STRET"," ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," SOUTH PINE"," S PINE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," TERRACE"," TER",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," BOULEVARD"," BLVD",1)


replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"SHENNECOSSETTROAD","SHENNECOSSETT RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"34PARKWAY","34 PARKWAY",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"37HEWJTIROAD","37 HEWJTI RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"5NORTHROAD","5 NORTH RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"71DODGEAVENUE","71 DODGE AVE",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"76DODGEAVE","76 DODGE AVE",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"8AGADAROAD","8A GADA RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"BROOKLANE","BROOK LN",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"CASTLELANE","CASTLE LN",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"FLANDERSROAD","FLANDERS RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"GRIFFITHROAD","GRIFFITH RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"MARSHROAD","MARSH RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"MERRILLDRIVE","MERRILL DR",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"MILLROAD","MILL RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"SOUTHROAD","SOUTH RD",1)


replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"100CATHERINE ST","100 CATHERINE ST",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," PARKWAY"," PKWY",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"104 EAST ROCKS RD","104 E ROCKS RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"1040 SOUTH RD","1040 SOUTH AVE",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," THIRD AVE EXTENSION"," 3RD AVE EXTENSION",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," CROSSING"," XING",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," FROGS HOLLOW RD"," FROG HOLLOW RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," TURNPIKE"," TPKE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," NORTH HIGH ST"," N HIGH ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"14 CUTLER RD HONORABLE BENJAMIN BLAKEYOR, CITY OF MILFORD","14 CUTLER RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," SOUTH MONTOWESE ST"," S MONTOWESE ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"146MIDWOOD RD","146 MIDWOOD RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," SOUTH WATER ST"," S WATER ST",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," EAST SHORE AVE"," E SHORE AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," SIMONS LN"," SIMOS LN",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," STONY PT RD"," STONY POINT RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," WEST BANK LN"," W BANK LN",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," DOLPHIN COVE"," DOLPHIN COVE QUAY",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"203AYBERRY LN","20 BAYBERRY LN",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," NORTH COVE RD"," N COVE RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"203 REITTER ST , TOWN OF STRATFORDIN STREET","203 REITTER ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"22 CHASMARS PT","22 CHASMARS POND RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," COMMONS"," CMNS",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," NORTH COVE RD"," N COVE RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"248 SHORE RD (CD","248 SHORE RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"BROOK RD SOUTH","BROOK RD S",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," WEST SPRING ST"," W SPRING ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," TUDOR CT EAST"," TUDOR CT E",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," WEST RUTLAND RD"," W RUTLAND RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"31OLD KINGS HIGHWAY","31 OLD KINGS HWY",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," NORTH PORCHUCK RD"," N PORCHUCK RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," OLD KINGS HIGHWAY"," OLD KINGS HWY",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"36MAPLEVALE RD","36 MAPLEVALE RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"37 SEABRIGHT AV","37 SEABRIGHT AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"39MORGAN AVE","39 MORGAN AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," TRAIL"," TRL",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," LONG PT RD"," LONG POINT RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," OCEAN DR WEST"," OCEAN DR W",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," IRON WORKS RD"," IRONWORKS RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," FRANKLINE AV"," FRANKLINE AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"46 PARKWAY SOUTH","46 PARKWAY S",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"461SOUTH PINE CREEK RD","461 S PINE CREEK RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"47 ECHO DR NORTH TABLE (CONTINUED)","47 ECHO DR N",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," OCEAN DR NORTH"," OCEAN DR N",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"4800 WAKELEE AVE","480 WAKELEE AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"5 FERRMILY LN","5 FERMILY LN",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," WEST BROTHER DR"," W BROTHER DR",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," CLIPPER PT RD"," CLIPPER POINT RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"67 LINCOLN AVE EXTENSION","67 LINCOLN AVENUE EXT",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"7FOURTH AVE","7 4TH AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress," EUNICE PARKWAY"," EUNICE PKWY",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"8 CAMBRIDGE COU EAST","8 CAMBRIDGE CT E",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"8, RIVERS EDGE CONDOMINIUM,2612 NORTH AVE","2612 NORTH AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"80 EUNICE PARKWAY","80 EUNICE PKWY",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"95MIDDLE BEACH RD","95 MIDDLE BEACH RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"98 SHOREFRONT PARKWAY","98 SHOREFRONT PARK",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"LOT 116 • 69 BLAKEMAN RD","69 BLAKEMAN RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"LOT 13, BLOCK 1612,1141 KOSSUTH ST","1141 KOSSUTH ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"LOT 2 147 OSWEGATCHIE RD (CN","147 OSWEGATCHIE RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"LOT 68 • 15 N E INDUSTRIAL RD","15 N E INDUSTRIAL RD",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"LOTS 4 & 5 BLUFF AVE","5 BLUFF AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"NORTHFIELD CONDOMINIUM, 20 AMSTERDAM AVE","20 AMSTERDAM AVE",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"OAKWOOD, LOT 841, 53 CAMDEN ST","53 CAMDEN ST",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"ONEYBROOK, BLOCK 23, LOT 320 20AYBERRY LN","20 BAYBERRY LN",1)
replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"","",1)

replace LegalTownship="DARIEN" if PropertyFullStreetAddress=="32 PASTURE LN"
duplicates report LegalTownship PropertyFullStreetAddress
duplicates tag LegalTownship PropertyFullStreetAddress,gen(dup)
sort LegalTownship PropertyFullStreetAddress IssueDate Status StatusDate
duplicates drop LegalTownship PropertyFullStreetAddress,force
drop dup
save "$dta\LOMA_formerge.dta",replace

