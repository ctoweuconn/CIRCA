clear all
set more off
*Change directories here
global root ""
global dta "$root\dta"

global GIS ""

*This do file conducts the revision of address points based on the parcel polygons
*acquired from the towns and regional COGs.
***********************************************************
*  Check coordinates-building match quality - East Haven  *
***********************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_easthaven.dta",clear
duplicates report orig_fid
keep fid_build orig_fid unique_id mbl edit_date map location street house_no muni acres zoning
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint
duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop location,force
duplicates report FID_Buildingfootprint
drop dup1
duplicates tag FID_Buildingfootprint,gen(dup1)
drop if location=="45 MANSFIELD GROVE RD"&dup1>=1
duplicates report FID_Buildingfootprint

destring house_no,gen(address_num) force

keep FID_Buildingfootprint orig_fid location street address_num

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)

*browse if PropertyStreet!=street
order street PropertyStreet

replace location=subinstr(location,"TERR","TER",1)
replace street=subinstr(street,"TERR","TER",1)

replace location=subinstr(location,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)
replace street=subinstr(street,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)

replace location=subinstr(location,"PALMETTO TR","PALMETTO TRL",1)
replace street=subinstr(street,"PALMETTO TR","PALMETTO TRL",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)
replace street=subinstr(street,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)

replace location=subinstr(location,"COLD SPRING ST","COLD SPRING AVE",1)
replace street=subinstr(street,"COLD SPRING ST","COLD SPRING AVE",1)

replace location=subinstr(location,"SENECA TR","SENECA TRL",1)
replace street=subinstr(street,"SENECA TR","SENECA TRL",1)

replace location=subinstr(location,"WHITMAN AVE","WHITMAN ST",1)
replace street=subinstr(street,"WHITMAN AVE","WHITMAN ST",1)

replace location=subinstr(location,"ATWATER ST EXT","ATWATER STREET EXT",1)
replace street=subinstr(street,"ATWATER ST EXT","ATWATER STREET EXT",1)

replace location=subinstr(location,"WHALERS POINT RD","WHALERS PT",1)
replace street=subinstr(street,"WHALERS POINT RD","WHALERS PT",1)

replace location=subinstr(location,"NORTH ATWATER ST","N ATWATER ST",1)
replace street=subinstr(street,"NORTH ATWATER ST","N ATWATER ST",1)

replace location=subinstr(location,"ELLIOTT ST","ELLIOT ST",1)
replace street=subinstr(street,"ELLIOTT ST","ELLIOT ST",1)

replace location=subinstr(location,"PISCITELLI CIR","PISCETELLI CIR",1)
replace street=subinstr(street,"PISCITELLI CIR","PISCETELLI CIR",1)

replace location=subinstr(location,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)
replace street=subinstr(street,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 


gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_easthaven.dta",replace

***********************************************************
*   Check coordinates-building match quality - Fairfield  *
***********************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_fairfield.dta",clear
duplicates report orig_fid
ren address location
keep fid_build orig_fid location
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)

gen firstblankpos_loc=ustrpos(location," ",2)
gen street=substr(location,firstblankpos_loc+1,.)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)



gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

gen address_num=substr(location,1,firstblankpos_loc)
destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_fairfield.dta",replace

*******************************************************************
*   Check coordinates-building match quality - the wave of seven  *
*******************************************************************
*This wave includes Clinton, Groton, OldLyme, OldSaybrook, Milford, Stonington, Westbrook


***********Clinton****************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_clinton.dta",clear
duplicates report orig_fid

*gen firstblankpos_loc=ustrpos(location," ",2)
*gen street=substr(location,firstblankpos_loc+1,.)
ren streetname street
ren streetnumb address_num
ren streetaddr location

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


browse if PropertyStreet!=street
order street PropertyStreet

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"SOLS PT RD","SOLS POINT RD",1)
replace street=subinstr(street,"SOLS PT RD","SOLS POINT RD",1)

replace location=subinstr(location,"WEST LOOP RD","W LOOP RD",1)
replace street=subinstr(street,"WEST LOOP RD","W LOOP RD",1)

replace location=subinstr(location,"EAST LOOP RD","E LOOP RD",1)
replace street=subinstr(street,"EAST LOOP RD","E LOOP RD",1)

replace location=subinstr(location,"SHORE RD #A31","SHORE RD",1)
replace street=subinstr(street,"SHORE RD #A31","SHORE RD",1)

replace location=subinstr(location,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)
replace street=subinstr(street,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)

replace location=subinstr(location,"GROVE WAY","GROVEWAY",1)
replace street=subinstr(street,"GROVE WAY","GROVEWAY",1)

replace location=subinstr(location,"OSPREY COMMONS","OSPREY CMNS",1)
replace street=subinstr(street,"OSPREY COMMONS","OSPREY CMNS",1)

replace location=subinstr(location,"FISK AVE & COMMERCE ST","FISK AVE",1)
replace street=subinstr(street,"FISK AVE & COMMERCE ST","FISK AVE",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"MORGAN PK","MORGAN PARK",1)
replace street=subinstr(street,"MORGAN PK","MORGAN PARK",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_clinton.dta",replace



************Groton*************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_groton.dta",clear
duplicates report orig_fid

ren property_l location
gen firstblankpos_loc=ustrpos(location," ",2)
gen street=substr(location,firstblankpos_loc+1,.)
gen address_num=substr(location,1,firstblankpos_loc-1)
destring address_num,replace


keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

*Groton specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location," HEIGHTS"," HTS",1)
replace street=subinstr(street," HEIGHTS"," HTS",1)

replace location=subinstr(location," (GLP)","",1)
replace street=subinstr(street," (GLP)","",1)

replace location=subinstr(location," (MYSTIC)","",1)
replace street=subinstr(street," (MYSTIC)","",1)

replace location=subinstr(location," (OLD MYSTIC)","",1)
replace street=subinstr(street," (OLD MYSTIC)","",1)

replace location=subinstr(location," (NOANK)","",1)
replace street=subinstr(street," (NOANK)","",1)

replace location=subinstr(location," (CITY)","",1)
replace street=subinstr(street," (CITY)","",1)

replace location=subinstr(location,"CIR AVE","CIRCLE AVE",1)
replace street=subinstr(street,"CIR AVE","CIRCLE AVE",1)

replace location=subinstr(location,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)
replace street=subinstr(street,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)

replace location=subinstr(location,"EAST SHORE AVE","E SHORE AVE",1)
replace street=subinstr(street,"EAST SHORE AVE","E SHORE AVE",1)

replace location=subinstr(location,"EASTERN PT RD","EASTERN POINT RD",1)
replace street=subinstr(street,"EASTERN PT RD","EASTERN POINT RD",1)

replace location=subinstr(location,"ELDREDGE ST","ELDRIDGE ST",1)
replace street=subinstr(street,"ELDREDGE ST","ELDRIDGE ST",1)

replace location=subinstr(location,"ELM ST SOUTH","ELM ST S",1)
replace street=subinstr(street,"ELM ST SOUTH","ELM ST S",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"GROTON LONG PT RD","GROTON LONG POINT RD",1)
replace street=subinstr(street,"GROTON LONG PT RD","GROTON LONG POINT RD",1)

replace location=subinstr(location,"HALEY CRESCENT","HALEY CRES",1)
replace street=subinstr(street,"HALEY CRESCENT","HALEY CRES",1)

replace location=subinstr(location,"HYROCK TERR","HYROCK TER",1)
replace street=subinstr(street,"HYROCK TERR","HYROCK TER",1)

replace location=subinstr(location,"ISLAND CIR NORTH","ISLAND CIR N",1)
replace street=subinstr(street,"ISLAND CIR NORTH","ISLAND CIR N",1)

replace location=subinstr(location,"ISLAND CIR SOUTH","ISLAND CIR S",1)
replace street=subinstr(street,"ISLAND CIR SOUTH","ISLAND CIR S",1)

replace location=subinstr(location,"JUPITER PT RD","JUPITER POINT RD",1)
replace street=subinstr(street,"JUPITER PT RD","JUPITER POINT RD",1)

replace location=subinstr(location,"NORTH PROSPECT ST","N PROSPECT ST",1)
replace street=subinstr(street,"NORTH PROSPECT ST","N PROSPECT ST",1)

replace location=subinstr(location,"ORCHARD LN","ORCHARD ST",1)
replace street=subinstr(street,"ORCHARD LN","ORCHARD ST",1)

replace location=subinstr(location,"PALMERS COVE DR","PALMERS COVE RD",1)
replace street=subinstr(street,"PALMERS COVE DR","PALMERS COVE RD",1)

replace location=subinstr(location,"POTTER CT","POTTER ST",1)
replace street=subinstr(street,"POTTER CT","POTTER ST",1)

replace location=subinstr(location,"SOUND VIEW RD","SOUNDVIEW RD",1)
replace street=subinstr(street,"SOUND VIEW RD","SOUNDVIEW RD",1)

replace location=subinstr(location,"SOUTH PROSPECT ST","S PROSPECT ST",1)
replace street=subinstr(street,"SOUTH PROSPECT ST","S PROSPECT ST",1)

replace location=subinstr(location,"SOUTH SHORE AVE","S SHORE AVE",1)
replace street=subinstr(street,"SOUTH SHORE AVE","S SHORE AVE",1)

replace location=subinstr(location,"ST JOSEPH CT","SAINT JOSEPH CT",1)
replace street=subinstr(street,"ST JOSEPH CT","SAINT JOSEPH CT",1)

replace location=subinstr(location,"ST PAUL CT","SAINT PAUL CT",1)
replace street=subinstr(street,"ST PAUL CT","SAINT PAUL CT",1)

replace location=subinstr(location,"STRIBL LN","STRIBLE LN",1)
replace street=subinstr(street,"STRIBL LN","STRIBLE LN",1)

replace location=subinstr(location,"TER AVE","TERRACE AVE",1)
replace street=subinstr(street,"TER AVE","TERRACE AVE",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST MYSTIC AVE","W MYSTIC AVE",1)
replace street=subinstr(street,"WEST MYSTIC AVE","W MYSTIC AVE",1)

replace location=subinstr(location,"WEST SHORE AVE","W SHORE AVE",1)
replace street=subinstr(street,"WEST SHORE AVE","W SHORE AVE",1)

replace location=subinstr(location,"WESTVIEW AVE","W VIEW AVE",1)
replace street=subinstr(street,"WESTVIEW AVE","W VIEW AVE",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_groton.dta",replace

************Old Lyme*************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_oldlyme.dta",clear
duplicates report orig_fid

ren streetname street
ren streetnumb address_num
ren streetaddr location
destring address_num,replace

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

*Old Lyme specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"DORY LNNDING","DORY LNDG",1)
replace street=subinstr(street,"DORY LNNDING","DORY LNDG",1)
/*
replace location=subinstr(location,"HARTFORD AVE","HARTFORD AVE EXT",1)
replace street=subinstr(street,"HARTFORD AVE","HARTFORD AVE EXT",1)
*/
replace location=subinstr(location,"HATCHETTS PT RD","HATCHETT POINT RD",1)
replace street=subinstr(street,"HATCHETTS PT RD","HATCHETT POINT RD",1)

replace location=subinstr(location,"JOFFRE RD WEST","JOFFRE RD W",1)
replace street=subinstr(street,"JOFFRE RD WEST","JOFFRE RD W",1)

replace location=subinstr(location,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)
replace street=subinstr(street,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)

replace location=subinstr(location,"MEETING HOUSE LN","MEETINGHOUSE LN",1)
replace street=subinstr(street,"MEETING HOUSE LN","MEETINGHOUSE LN",1)

/*
replace location=subinstr(location,"PORTLAND AVE","PORTLAND AVENUE EXT",1)
replace street=subinstr(street,"PORTLAND AVE","PORTLAND AVENUE EXT",1)
*/
replace location=subinstr(location,"RIVERDALE LNNDING","RIVERDALE LDG",1)
replace street=subinstr(street,"RIVERDALE LNNDING","RIVERDALE LDG",1)

replace location=subinstr(location,"ROBBINS AVE","ROBBIN AVE",1)
replace street=subinstr(street,"ROBBINS AVE","ROBBIN AVE",1)

replace location=subinstr(location,"SANDPIPER PT RD","SANDPIPER POINT RD",1)
replace street=subinstr(street,"SANDPIPER PT RD","SANDPIPER POINT RD",1)

replace location=subinstr(location,"SEA VIEW RD","SEAVIEW RD",1)
replace street=subinstr(street,"SEA VIEW RD","SEAVIEW RD",1)

replace location=subinstr(location,"WEST END DR","W END DR",1)
replace street=subinstr(street,"WEST END DR","W END DR",1)

replace location=subinstr(location,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)
replace street=subinstr(street,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_oldlyme.dta",replace



************Old Saybrook*************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_oldsaybrook.dta",clear
duplicates report orig_fid

ren streetname street
ren streetnumb address_num
ren streetaddr location
destring address_num,replace

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Old Saybrook specific
replace location=subinstr(location,"AQUATERRA LA","AQUA TERRA LN",1)
replace street=subinstr(street,"AQUATERRA LA","AQUA TERRA LN",1)

replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AQUATERRA","AQUA TERRA",1)
replace street=subinstr(street,"AQUATERRA","AQUA TERRA",1)

replace location=subinstr(location,"BARNES RD SOUTH","BARNES RD S",1)
replace street=subinstr(street,"BARNES RD SOUTH","BARNES RD S",1)

replace location=subinstr(location,"BAY VIEW AVE","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW AVE","BAYVIEW RD",1)

replace location=subinstr(location,"BEACH RD EAST","BEACH RD E",1)
replace street=subinstr(street,"BEACH RD EAST","BEACH RD E",1)

replace location=subinstr(location,"BEACH RD WEST","BEACH RD W",1)
replace street=subinstr(street,"BEACH RD WEST","BEACH RD W",1)

replace location=subinstr(location,"BEACH VIEW ST","BEACH VIEW AVE",1)
replace street=subinstr(street,"BEACH VIEW ST","BEACH VIEW AVE",1)

replace location=subinstr(location,"BELAIRE DR","BELAIRE MNR",1)
replace street=subinstr(street,"BELAIRE DR","BELAIRE MNR",1)

replace location=subinstr(location,"BELLEAIRE DR","BELLAIRE DR",1)
replace street=subinstr(street,"BELLEAIRE DR","BELLAIRE DR",1)

replace location=subinstr(location,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)
replace street=subinstr(street,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)

replace location=subinstr(location,"BROOKE ST","BROOK ST",1)
replace street=subinstr(street,"BROOKE ST","BROOK ST",1)

replace location=subinstr(location,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)
replace street=subinstr(street,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)

replace location=subinstr(location,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)
replace street=subinstr(street,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)

replace location=subinstr(location,"COVE LNNDING","COVE LNDG",1)
replace street=subinstr(street,"COVE LNNDING","COVE LNDG",1)

replace location=subinstr(location,"CRANTON ST","CRANTON AVE",1)
replace street=subinstr(street,"CRANTON ST","CRANTON AVE",1)

replace location=subinstr(location,"CRICKETCT","CRICKET CT",1)
replace street=subinstr(street,"CRICKETCT","CRICKET CT",1)

replace location=subinstr(location,"CROMWELLCT","CROMWELL CT",1)
replace street=subinstr(street,"CROMWELLCT","CROMWELL CT",1)

replace location=subinstr(location,"CROMWELLCT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELLCT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"CROMWELL CT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELL CT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"FENCOVECT","FENCOVE CT",1)
replace street=subinstr(street,"FENCOVECT","FENCOVE CT",1)

replace location=subinstr(location,"FERRY PL","FERRY RD",1)
replace street=subinstr(street,"FERRY PL","FERRY RD",1)

replace location=subinstr(location,"JAMESCT","JAMES CT",1)
replace street=subinstr(street,"JAMESCT","JAMES CT",1)

replace location=subinstr(location,"LONDONCT","LONDON CT",1)
replace street=subinstr(street,"LONDONCT","LONDON CT",1)

replace location=subinstr(location,"MAPLECT","MAPLE CT",1)
replace street=subinstr(street,"MAPLECT","MAPLE CT",1)

replace location=subinstr(location,"MAYCT","MAY CT",1)
replace street=subinstr(street,"MAYCT","MAY CT",1)

replace location=subinstr(location,"MILL ROCK RD EAST","MILL ROCK RD E",1)
replace street=subinstr(street,"MILL ROCK RD EAST","MILL ROCK RD E",1)

replace location=subinstr(location,"NORTH COVE CIR","N COVE CIR",1)
replace street=subinstr(street,"NORTH COVE CIR","N COVE CIR",1)

replace location=subinstr(location,"NORTH COVE RD","N COVE RD",1)
replace street=subinstr(street,"NORTH COVE RD","N COVE RD",1)

replace location=subinstr(location,"OYSTER PT AVE EAST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE EAST","OYSTER POINT RD",1)

replace location=subinstr(location,"OYSTER PT AVE WEST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE WEST","OYSTER POINT RD",1)

replace location=subinstr(location,"PARKCROFTERS LN","PARK CROFTERS LN",1)
replace street=subinstr(street,"PARKCROFTERS LN","PARK CROFTERS LN",1)

replace location=subinstr(location,"PT RD","POINT RD",1)
replace street=subinstr(street,"PT RD","POINT RD",1)

replace location=subinstr(location,"REEDCT","REED CT",1)
replace street=subinstr(street,"REEDCT","REED CT",1)

replace location=subinstr(location,"RIVER ST WEST","RIVER ST W",1)
replace street=subinstr(street,"RIVER ST WEST","RIVER ST W",1)

replace location=subinstr(location,"SEA BREEZE RD","SEABREEZE RD",1)
replace street=subinstr(street,"SEA BREEZE RD","SEABREEZE RD",1)

replace location=subinstr(location,"SEA CREST RD","SEACREST RD",1)
replace street=subinstr(street,"SEA CREST RD","SEACREST RD",1)

replace location=subinstr(location,"SEA GULL RD","SEAGULL RD",1)
replace street=subinstr(street,"SEA GULL RD","SEAGULL RD",1)

replace location=subinstr(location,"SEA LN-1","SEA LN",1)
replace street=subinstr(street,"SEA LN-1","SEA LN",1)

replace location=subinstr(location,"SEA LN-2","SEA LN",1)
replace street=subinstr(street,"SEA LN-2","SEA LN",1)

replace location=subinstr(location,"SEAVIEW AVE","SEA VIEW AVE",1)
replace street=subinstr(street,"SEAVIEW AVE","SEA VIEW AVE",1)

replace location=subinstr(location,"SHADY RUN AVE","SHADY RUN",1)
replace street=subinstr(street,"SHADY RUN AVE","SHADY RUN",1)

replace location=subinstr(location,"SHORE AVE-2","SHORE AVE",1)
replace street=subinstr(street,"SHORE AVE-2","SHORE AVE",1)

replace location=subinstr(location,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)
replace street=subinstr(street,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)

replace location=subinstr(location,"SOUTH COVE RD-1","S COVE RD",1)
replace street=subinstr(street,"SOUTH COVE RD-1","S COVE RD",1)

replace location=subinstr(location,"SOUTH VIEW CIR","S VIEW CIR",1)
replace street=subinstr(street,"SOUTH VIEW CIR","S VIEW CIR",1)

replace location=subinstr(location,"TUDORCT EAST","TUDOR CT E",1)
replace street=subinstr(street,"TUDORCT EAST","TUDOR CT E",1)

replace location=subinstr(location,"TUDORCT WEST","TUDOR CT W",1)
replace street=subinstr(street,"TUDORCT WEST","TUDOR CT W",1)

replace location=subinstr(location,"WEST SHORE DR","W SHORE DR",1)
replace street=subinstr(street,"WEST SHORE DR","W SHORE DR",1)

replace location=subinstr(location,"WEST VIEW RD","W VIEW RD",1)
replace street=subinstr(street,"WEST VIEW RD","W VIEW RD",1)

replace location=subinstr(location,"WINDSORCT WEST","WINDSOR CT",1)
replace street=subinstr(street,"WINDSORCT WEST","WINDSOR CT",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_oldsaybrook.dta",replace



************Milford*************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_milford.dta",clear
duplicates report orig_fid

ren house_num address_num

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Milford specific
replace location=subinstr(location,"BAYSHORE DR EXT","BAYSHORE DR",1)
replace street=subinstr(street,"BAYSHORE DR EXT","BAYSHORE DR",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY","BROADWAY",1)
replace street=subinstr(street,"BRDWAY","BROADWAY",1)

replace location=subinstr(location,"DEVOLL ST","DEVOL ST",1)
replace street=subinstr(street,"DEVOLL ST","DEVOL ST",1)

replace location=subinstr(location,"DOCK LN","DOCK RD",1)
replace street=subinstr(street,"DOCK LN","DOCK RD",1)

replace location=subinstr(location,"EAST BRDWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BRDWAY","E BROADWAY",1)

replace location=subinstr(location,"EAST BROADWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BROADWAY","E BROADWAY",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"ETTADORE PKWY","ETTADORE PARK",1)
replace street=subinstr(street,"ETTADORE PKWY","ETTADORE PARK",1)

replace location=subinstr(location,"FENWAY NORTH","FENWAY ST N",1)
replace street=subinstr(street,"FENWAY NORTH","FENWAY ST N",1)

replace location=subinstr(location,"FENWAY SOUTH","FENWAY ST S",1)
replace street=subinstr(street,"FENWAY SOUTH","FENWAY ST S",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HILLTOP CIR EAST","HILLTOP CIR E",1)
replace street=subinstr(street,"HILLTOP CIR EAST","HILLTOP CIR E",1)

replace location=subinstr(location,"KINLOCH ST","KINLOCK ST",1)
replace street=subinstr(street,"KINLOCH ST","KINLOCK ST",1)

replace location=subinstr(location,"KINLOCH TER","KINLOCK TER",1)
replace street=subinstr(street,"KINLOCH TER","KINLOCK TER",1)

replace location=subinstr(location,"MANILA AVE","MANILLA AVE",1)
replace street=subinstr(street,"MANILA AVE","MANILLA AVE",1)

replace location=subinstr(location,"MILFORD PT RD","MILFORD POINT RD",1)
replace street=subinstr(street,"MILFORD PT RD","MILFORD POINT RD",1)

replace location=subinstr(location,"MINUTE MAN DR","MINUTEMAN DR",1)
replace street=subinstr(street,"MINUTE MAN DR","MINUTEMAN DR",1)

replace location=subinstr(location,"NORTHMOOR RD","NORTHMOOR ST",1)
replace street=subinstr(street,"NORTHMOOR RD","NORTHMOOR ST",1)

replace location=subinstr(location,"OAKDALE AVE","OAKDALE ST",1)
replace street=subinstr(street,"OAKDALE AVE","OAKDALE ST",1)

replace location=subinstr(location,"OLD PT RD","OLD POINT RD",1)
replace street=subinstr(street,"OLD PT RD","OLD POINT RD",1)

replace location=subinstr(location,"PHELAN PARK DR","PHELAN PARK",1)
replace street=subinstr(street,"PHELAN PARK DR","PHELAN PARK",1)

replace location=subinstr(location,"PT BEACH DR","POINT BEACH DR",1)
replace street=subinstr(street,"PT BEACH DR","POINT BEACH DR",1)

replace location=subinstr(location,"PT LOOKOUT","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT","POINT LOOKOUT",1)

replace location=subinstr(location,"PT LOOKOUT EAST","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT EAST","POINT LOOKOUT",1)

replace location=subinstr(location,"POND PT AVE","POND POINT AVE",1)
replace street=subinstr(street,"POND PT AVE","POND POINT AVE",1)

replace location=subinstr(location,"RIVEREDGE DR","RIVEREDGE ST",1)
replace street=subinstr(street,"RIVEREDGE DR","RIVEREDGE ST",1)

replace location=subinstr(location,"SEA FLOWER RD","SEAFLOWER RD",1)
replace street=subinstr(street,"SEA FLOWER RD","SEAFLOWER RD",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SMITHS PT RD","SMITHS POINT RD",1)
replace street=subinstr(street,"SMITHS PT RD","SMITHS POINT RD",1)

replace location=subinstr(location,"SNOW APPLE LN","SNOWAPPLE LN",1)
replace street=subinstr(street,"SNOW APPLE LN","SNOWAPPLE LN",1)

replace location=subinstr(location,"SPARROW BUSH LN","SPARROWBUSH LN",1)
replace street=subinstr(street,"SPARROW BUSH LN","SPARROWBUSH LN",1)

replace location=subinstr(location,"TER RD","TERRACE RD",1)
replace street=subinstr(street,"TER RD","TERRACE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WELCHS PT RD","WELCHS POINT RD",1)
replace street=subinstr(street,"WELCHS PT RD","WELCHS POINT RD",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST ORLAND ST","W ORLAND ST",1)
replace street=subinstr(street,"WEST ORLAND ST","W ORLAND ST",1)

replace location=subinstr(location,"WEST RIVER ST","W RIVER ST",1)
replace street=subinstr(street,"WEST RIVER ST","W RIVER ST",1)

replace location=subinstr(location,"WEST TOWN ST","W TOWN ST",1)
replace street=subinstr(street,"WEST TOWN ST","W TOWN ST",1)

replace location=subinstr(location,"ASTERRACE RD","ASTER RD",1)
replace street=subinstr(street,"ASTERRACE RD","ASTER RD",1)

replace location=subinstr(location,"BREWSTERRACE RD","BREWSTER RD",1)
replace street=subinstr(street,"BREWSTERRACE RD","BREWSTER RD",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_milford.dta",replace



************Stonington*************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_stonington.dta",clear
duplicates report orig_fid

ren house_num address_num

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Stonington specific
replace location=subinstr(location,"ALLYNS ALLEY","ALLYNS ALY",1)
replace street=subinstr(street,"ALLYNS ALLEY","ALLYNS ALY",1)

replace location=subinstr(location,"BAYBERRY LA","BAYBERRY LN",1)
replace street=subinstr(street,"BAYBERRY LA","BAYBERRY LN",1)

replace location=subinstr(location,"BOULDER AVE EXT","BOULDER AVE",1)
replace street=subinstr(street,"BOULDER AVE EXT","BOULDER AVE",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY AVE","BROADWAY AVE",1)
replace street=subinstr(street,"BRDWAY AVE","BROADWAY AVE",1)

replace location=subinstr(location,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)
replace street=subinstr(street,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)

replace location=subinstr(location,"CHAPMAN LA","CHAPMAN LN",1)
replace street=subinstr(street,"CHAPMAN LA","CHAPMAN LN",1)

replace location=subinstr(location,"CHESEBRO LA","CHESEBRO LN",1)
replace street=subinstr(street,"CHESEBRO LA","CHESEBRO LN",1)

replace location=subinstr(location,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)
replace street=subinstr(street,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)

replace location=subinstr(location,"CHURCH ST M","CHURCH ST",1)
replace street=subinstr(street,"CHURCH ST M","CHURCH ST",1)

replace location=subinstr(location,"DENISON AVE M","DENISON AVE",1)
replace street=subinstr(street,"DENISON AVE M","DENISON AVE",1)

replace location=subinstr(location,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)
replace street=subinstr(street,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)

replace location=subinstr(location,"ENSIGN LA","ENSIGN LN",1)
replace street=subinstr(street,"ENSIGN LA","ENSIGN LN",1)

replace location=subinstr(location,"LAMBERTS LA","LAMBERTS LN",1)
replace street=subinstr(street,"LAMBERTS LA","LAMBERTS LN",1)

replace location=subinstr(location,"LATIMER PT RD","LATIMER POINT RD",1)
replace street=subinstr(street,"LATIMER PT RD","LATIMER POINT RD",1)

replace location=subinstr(location,"LHIRONDELLE LA","LHIRONDELLE LN",1)
replace street=subinstr(street,"LHIRONDELLE LA","LHIRONDELLE LN",1)

replace location=subinstr(location,"LINDEN LA","LINDEN LN",1)
replace street=subinstr(street,"LINDEN LA","LINDEN LN",1)

replace location=subinstr(location,"LONG WHARF RD","LONG WHARF DR",1)
replace street=subinstr(street,"LONG WHARF RD","LONG WHARF DR",1)

replace location=subinstr(location,"MAPLE ST LP","MAPLE ST",1)
replace street=subinstr(street,"MAPLE ST LP","MAPLE ST",1)

replace location=subinstr(location,"MAPLEWOOD LA","MAPLEWOOD LN",1)
replace street=subinstr(street,"MAPLEWOOD LA","MAPLEWOOD LN",1)

replace location=subinstr(location,"MEADOWBROOK LA","MEADOWBROOK LN",1)
replace street=subinstr(street,"MEADOWBROOK LA","MEADOWBROOK LN",1)

replace location=subinstr(location,"MEADOWLARK LA","MEADOW LARK LN",1)
replace street=subinstr(street,"MEADOWLARK LA","MEADOW LARK LN",1)

replace location=subinstr(location,"MONEY PT RD","MONEY POINT RD",1)
replace street=subinstr(street,"MONEY PT RD","MONEY POINT RD",1)

replace location=subinstr(location,"MYSTIC HILL","MYSTIC HILL RD",1)
replace street=subinstr(street,"MYSTIC HILL","MYSTIC HILL RD",1)

replace location=subinstr(location,"NAUYAUG N","NAUYAUG RD N",1)
replace street=subinstr(street,"NAUYAUG N","NAUYAUG RD N",1)

replace location=subinstr(location,"NAUYAUG PT RD","NAUYAUG POINT RD",1)
replace street=subinstr(street,"NAUYAUG PT RD","NAUYAUG POINT RD",1)

replace location=subinstr(location,"NOYES AVE LP","NOYES AVE",1)
replace street=subinstr(street,"NOYES AVE LP","NOYES AVE",1)

replace location=subinstr(location,"PLOVER LA","PLOVER LN",1)
replace street=subinstr(street,"PLOVER LA","PLOVER LN",1)

replace location=subinstr(location,"RICHMOND LA M","RICHMOND LN",1)
replace street=subinstr(street,"RICHMOND LA M","RICHMOND LN",1)

replace location=subinstr(location,"ROSE LA","ROSE LN",1)
replace street=subinstr(street,"ROSE LA","ROSE LN",1)

replace location=subinstr(location,"SCHOOL ST M","SCHOOL ST",1)
replace street=subinstr(street,"SCHOOL ST M","SCHOOL ST",1)

replace location=subinstr(location,"SEAGULL LA","SEAGULL LN",1)
replace street=subinstr(street,"SEAGULL LA","SEAGULL LN",1)

replace location=subinstr(location,"SUMMIT ST M","SUMMIT ST",1)
replace street=subinstr(street,"SUMMIT ST M","SUMMIT ST",1)

replace location=subinstr(location,"SURREY LA","SURREY LN",1)
replace street=subinstr(street,"SURREY LA","SURREY LN",1)

replace location=subinstr(location,"WILBUR HILL LA","WILBUR HILL LN",1)
replace street=subinstr(street,"WILBUR HILL LA","WILBUR HILL LN",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_stonington.dta",replace
*************************Westbrook***********************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_westbrook.dta",clear
duplicates report orig_fid

ren streetnumb address_num
destring address_num,replace
ren streetname street
ren streetaddr location

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop location,force
duplicates report FID_Buildingfootprint
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Westbrook specific
replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"AVE B","AVENUE B",1)
replace street=subinstr(street,"AVE B","AVENUE B",1)

replace location=subinstr(location,"AVE C","AVENUE C",1)
replace street=subinstr(street,"AVE C","AVENUE C",1)

replace location=subinstr(location,"BRDWAY N","BROADWAY N",1)
replace street=subinstr(street,"BRDWAY N","BROADWAY N",1)

replace location=subinstr(location,"BRDWAY S","BROADWAY S",1)
replace street=subinstr(street,"BRDWAY S","BROADWAY S",1)

replace location=subinstr(location,"CHAPMAN AVE","CHAPMAN DR",1)
replace street=subinstr(street,"CHAPMAN AVE","CHAPMAN DR",1)

replace location=subinstr(location,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)
replace street=subinstr(street,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)

replace location=subinstr(location,"E Z ST","EZ ST",1)
replace street=subinstr(street,"E Z ST","EZ ST",1)

replace location=subinstr(location,"JAKOBS LANDING","JAKOBS LNDG",1)
replace street=subinstr(street,"JAKOBS LANDING","JAKOBS LNDG",1)

replace location=subinstr(location,"LYNNE AVE EXT","LYNNE AVE",1)
replace street=subinstr(street,"LYNNE AVE EXT","LYNNE AVE",1)

replace location=subinstr(location,"MCDONALD DR","MACDONALD DR",1)
replace street=subinstr(street,"MCDONALD DR","MACDONALD DR",1)

replace location=subinstr(location,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)
replace street=subinstr(street,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)

replace location=subinstr(location,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)
replace street=subinstr(street,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)

replace location=subinstr(location,"MOHICAN RD E","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD E","MOHICAN RD",1)

replace location=subinstr(location,"MOHICAN RD W","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD W","MOHICAN RD",1)

replace location=subinstr(location,"MULLER AVE","MULLER DR",1)
replace street=subinstr(street,"MULLER AVE","MULLER DR",1)

replace location=subinstr(location,"OAK VALE RD","OAKVALE RD",1)
replace street=subinstr(street,"OAK VALE RD","OAKVALE RD",1)

replace location=subinstr(location,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)
replace street=subinstr(street,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)

replace location=subinstr(location,"PILOTS PT DR","PILOTS POINT DR",1)
replace street=subinstr(street,"PILOTS PT DR","PILOTS POINT DR",1)

replace location=subinstr(location,"PTINA RD","POINTINA RD",1)
replace street=subinstr(street,"PTINA RD","POINTINA RD",1)

replace location=subinstr(location,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)
replace street=subinstr(street,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)

replace location=subinstr(location,"SAGAMORE TER RD E","SAGAMORE TER E",1)
replace street=subinstr(street,"SAGAMORE TER RD E","SAGAMORE TER E",1)

replace location=subinstr(location,"SAGAMORE TER RD S","SAGAMORE TER S",1)
replace street=subinstr(street,"SAGAMORE TER RD S","SAGAMORE TER S",1)

replace location=subinstr(location,"SAGAMORE TER RD W","SAGAMORE TER W",1)
replace street=subinstr(street,"SAGAMORE TER RD W","SAGAMORE TER W",1)

replace location=subinstr(location,"SEASCAPE DR","SEA SCAPE DR",1)
replace street=subinstr(street,"SEASCAPE DR","SEA SCAPE DR",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"STONE HEDGE RD EXT","STONE HEDGE RD",1)
replace street=subinstr(street,"STONE HEDGE RD EXT","STONE HEDGE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"UNCAS RD W","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD W","UNCAS RD",1)

replace location=subinstr(location,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)
replace street=subinstr(street,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)

replace location=subinstr(location,"CHAPMAN DR","CHAPMAN AVE",1)
replace street=subinstr(street,"CHAPMAN DR","CHAPMAN AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)
replace street=subinstr(street,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_westbrook.dta",replace



**************************************************************************
*   Check coordinates-building match quality - the second wave of seven  *
**************************************************************************
*This wave includes New London, East Lyme, Branford, Guilford, Madison, New Haven, West Haven

****************************New London,East Lyme*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_newlondoneastlyme.dta",clear
duplicates report orig_fid

ren circatab_6 address_num
ren circatab_8 street
ren circatab_5 location

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
drop if trim(location)=="SPINNAKER"&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates report FID_Buildingfootprint
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*New London East Lyme specific
replace location=subinstr(location,"ALEWIFE PW","ALEWIFE PKWY",1)
replace street=subinstr(street,"ALEWIFE PW","ALEWIFE PKWY",1)

replace location=subinstr(location,"ARCADIAN RD GNB","ARCADIA RD",1)
replace street=subinstr(street,"ARCADIAN RD GNB","ARCADIA RD",1)

replace location=subinstr(location,"ATLANTIC ST CB","ATLANTIC ST",1)
replace street=subinstr(street,"ATLANTIC ST CB","ATLANTIC ST",1)

replace location=subinstr(location,"ATTAWAN AVE","ATTAWAN RD",1)
replace street=subinstr(street,"ATTAWAN AVE","ATTAWAN RD",1)

replace location=subinstr(location,"BARRETT DR OGBA","BARRETT DR",1)
replace street=subinstr(street,"BARRETT DR OGBA","BARRETT DR",1)

replace location=subinstr(location,"BAY VIEW RD GNH","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW RD GNH","BAYVIEW RD",1)

replace location=subinstr(location,"BAYVIEW AVE CB","BAYVIEW AVE",1)
replace street=subinstr(street,"BAYVIEW AVE CB","BAYVIEW AVE",1)

replace location=subinstr(location,"BEACH AVE CB","BEACH AVE",1)
replace street=subinstr(street,"BEACH AVE CB","BEACH AVE",1)

replace location=subinstr(location,"BELLAIRE RD BPBC","BELLAIRE RD",1)
replace street=subinstr(street,"BELLAIRE RD BPBC","BELLAIRE RD",1)

replace location=subinstr(location,"BILLOW RD BPBC","BILLOW RD",1)
replace street=subinstr(street,"BILLOW RD BPBC","BILLOW RD",1)

replace location=subinstr(location,"BLACK PT RD","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD","BLACK POINT RD",1)

replace location=subinstr(location,"BLACK PT RD CB","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD CB","BLACK POINT RD",1)

replace location=subinstr(location,"BOND ST BPBC","BOND ST",1)
replace street=subinstr(street,"BOND ST BPBC","BOND ST",1)

replace location=subinstr(location,"BRAINERD RD","BRAINARD RD",1)
replace street=subinstr(street,"BRAINERD RD","BRAINARD RD",1)

replace location=subinstr(location,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)
replace street=subinstr(street,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)

replace location=subinstr(location,"BROCKETT RD GNB","BROCKETT RD",1)
replace street=subinstr(street,"BROCKETT RD GNB","BROCKETT RD",1)

replace location=subinstr(location,"CARPENTER AVE CB","CARPENTER AVE",1)
replace street=subinstr(street,"CARPENTER AVE CB","CARPENTER AVE",1)

replace location=subinstr(location,"CENTRAL AVE CB","CENTRAL AVE",1)
replace street=subinstr(street,"CENTRAL AVE CB","CENTRAL AVE",1)

replace location=subinstr(location,"COLUMBUS AVE CB","COLUMBUS AVE",1)
replace street=subinstr(street,"COLUMBUS AVE CB","COLUMBUS AVE",1)

replace location=subinstr(location,"COTTAGE LN BPBC","COTTAGE LN",1)
replace street=subinstr(street,"COTTAGE LN BPBC","COTTAGE LN",1)

replace location=subinstr(location,"CRAB LN CB","CRAB LN",1)
replace street=subinstr(street,"CRAB LN CB","CRAB LN",1)

replace location=subinstr(location,"CRESCENT AVE CB","CRESCENT AVE",1)
replace street=subinstr(street,"CRESCENT AVE CB","CRESCENT AVE",1)

replace location=subinstr(location,"E SHORE DR BPBC","E SHORE DR",1)
replace street=subinstr(street,"E SHORE DR BPBC","E SHORE DR",1)

replace location=subinstr(location,"EDGE HILL RD GNH","EDGE HILL RD",1)
replace street=subinstr(street,"EDGE HILL RD GNH","EDGE HILL RD",1)

replace location=subinstr(location,"FULLER CT CB","FULLER CT",1)
replace street=subinstr(street,"FULLER CT CB","FULLER CT",1)

replace location=subinstr(location,"GLENWOOD PARK NO","GLENWOOD PARK N",1)
replace street=subinstr(street,"GLENWOOD PARK NO","GLENWOOD PARK N",1)

replace location=subinstr(location,"GLENWOOD PARK SO","GLENWOOD PARK S",1)
replace street=subinstr(street,"GLENWOOD PARK SO","GLENWOOD PARK S",1)

replace location=subinstr(location,"GRISWOLD DR GNH","GRISWOLD DR",1)
replace street=subinstr(street,"GRISWOLD DR GNH","GRISWOLD DR",1)

replace location=subinstr(location,"GRISWOLD RD GNB","GRISWOLD RD",1)
replace street=subinstr(street,"GRISWOLD RD GNB","GRISWOLD RD",1)

replace location=subinstr(location,"GROVE AVE CB","GROVE AVE",1)
replace street=subinstr(street,"GROVE AVE CB","GROVE AVE",1)

replace location=subinstr(location,"GROVEDALE RD GNB","GROVEDALE RD",1)
replace street=subinstr(street,"GROVEDALE RD GNB","GROVEDALE RD",1)

replace location=subinstr(location,"HILLCREST RD GNH","HILLCREST RD",1)
replace street=subinstr(street,"HILLCREST RD GNH","HILLCREST RD",1)

replace location=subinstr(location,"HILLSIDE AVE CB","HILLSIDE AVE",1)
replace street=subinstr(street,"HILLSIDE AVE CB","HILLSIDE AVE",1)

replace location=subinstr(location,"HILLTOP RD GNB","HILLTOP RD",1)
replace street=subinstr(street,"HILLTOP RD GNB","HILLTOP RD",1)

replace location=subinstr(location,"HOPE ST (REAR)","HOPE ST",1)
replace street=subinstr(street,"HOPE ST (REAR)","HOPE ST",1)

replace location=subinstr(location,"INDIAN ROCKS RD","INDIAN ROCK RD",1)
replace street=subinstr(street,"INDIAN ROCKS RD","INDIAN ROCK RD",1)

replace location=subinstr(location,"INDIANOLA RD BPBC","INDIANOLA RD",1)
replace street=subinstr(street,"INDIANOLA RD BPBC","INDIANOLA RD",1)

replace location=subinstr(location,"IRVING PL CB","IRVING PL",1)
replace street=subinstr(street,"IRVING PL CB","IRVING PL",1)

replace location=subinstr(location,"JO-ANNE ST","JO ANNE ST",1)
replace street=subinstr(street,"JO-ANNE ST","JO ANNE ST",1)

replace location=subinstr(location,"LAKE AVE EXT","LAKE AVENUE EXT",1)
replace street=subinstr(street,"LAKE AVE EXT","LAKE AVENUE EXT",1)

replace location=subinstr(location,"LAKE SHORE DR GNB","LAKE SHORE DR",1)
replace street=subinstr(street,"LAKE SHORE DR GNB","LAKE SHORE DR",1)

replace location=subinstr(location,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)
replace street=subinstr(street,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)

replace location=subinstr(location,"LEE FARM DR GNH","LEE FARM DR",1)
replace street=subinstr(street,"LEE FARM DR GNH","LEE FARM DR",1)

replace location=subinstr(location,"MAMACOCK RD GNB","MAMACOCK RD",1)
replace street=subinstr(street,"MAMACOCK RD GNB","MAMACOCK RD",1)

replace location=subinstr(location,"MANWARING RD OGBA","MANWARING RD",1)
replace street=subinstr(street,"MANWARING RD OGBA","MANWARING RD",1)

replace location=subinstr(location,"MARSHFIELD RD GNH","MARSHFIELD RD",1)
replace street=subinstr(street,"MARSHFIELD RD GNH","MARSHFIELD RD",1)

replace location=subinstr(location,"NEHANTIC DR BPBC","NEHANTIC DR",1)
replace street=subinstr(street,"NEHANTIC DR BPBC","NEHANTIC DR",1)

replace location=subinstr(location,"NILES CREEK RD GNB","NILES CREEK RD",1)
replace street=subinstr(street,"NILES CREEK RD GNB","NILES CREEK RD",1)

replace location=subinstr(location,"NORTH AVE CB","NORTH AVE",1)
replace street=subinstr(street,"NORTH AVE CB","NORTH AVE",1)

replace location=subinstr(location,"NORTH DR OGBA","NORTH DR",1)
replace street=subinstr(street,"NORTH DR OGBA","NORTH DR",1)

replace location=subinstr(location,"OAKWOOD RD GNH","OAKWOOD RD",1)
replace street=subinstr(street,"OAKWOOD RD GNH","OAKWOOD RD",1)

replace location=subinstr(location,"OCEAN AVE CB","OCEAN AVE",1)
replace street=subinstr(street,"OCEAN AVE CB","OCEAN AVE",1)

replace location=subinstr(location,"OLD BLACK PT RD","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OSPREY LN GNH","OSPREY LN",1)
replace street=subinstr(street,"OSPREY LN GNH","OSPREY LN",1)

replace location=subinstr(location,"OSPREY RD BPBC","OSPREY RD",1)
replace street=subinstr(street,"OSPREY RD BPBC","OSPREY RD",1)

replace location=subinstr(location,"PALLETTE AVE BPBC","PALLETTE DR",1)
replace street=subinstr(street,"PALLETTE AVE BPBC","PALLETTE DR",1)

replace location=subinstr(location,"PARK CT BPBC","PARK CT",1)
replace street=subinstr(street,"PARK CT BPBC","PARK CT",1)

replace location=subinstr(location,"PARK LN GNH","PARK LN",1)
replace street=subinstr(street,"PARK LN GNH","PARK LN",1)

replace location=subinstr(location,"PARK VIEW DR GNH","PARKVIEW DR",1)
replace street=subinstr(street,"PARK VIEW DR GNH","PARKVIEW DR",1)

replace location=subinstr(location,"PARKWAY NORTH","PARKWAY N",1)
replace street=subinstr(street,"PARKWAY NORTH","PARKWAY N",1)

replace location=subinstr(location,"PARKWAY SOUTH","PARKWAY S",1)
replace street=subinstr(street,"PARKWAY SOUTH","PARKWAY S",1)

replace location=subinstr(location,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)
replace street=subinstr(street,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)

replace location=subinstr(location,"POINT RD GNB","POINT RD",1)
replace street=subinstr(street,"POINT RD GNB","POINT RD",1)

replace location=subinstr(location,"PROSPECT AVE CB","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AVE CB","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)
replace street=subinstr(street,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)

replace location=subinstr(location,"RIDGE TR BPBC","RIDGE TRL",1)
replace street=subinstr(street,"RIDGE TR BPBC","RIDGE TRL",1)

replace location=subinstr(location,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)
replace street=subinstr(street,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)

replace location=subinstr(location,"ROCKBOURNE AVE","ROCKBOURNE LN",1)
replace street=subinstr(street,"ROCKBOURNE AVE","ROCKBOURNE LN",1)

replace location=subinstr(location,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)
replace street=subinstr(street,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)

replace location=subinstr(location,"S LEE RD GNB","S LEE RD",1)
replace street=subinstr(street,"S LEE RD GNB","S LEE RD",1)

replace location=subinstr(location,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)
replace street=subinstr(street,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)

replace location=subinstr(location,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)
replace street=subinstr(street,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)

replace location=subinstr(location,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)
replace street=subinstr(street,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)

replace location=subinstr(location,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)
replace street=subinstr(street,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)

replace location=subinstr(location,"SEA VIEW LN GNH","SEA VIEW LN",1)
replace street=subinstr(street,"SEA VIEW LN GNH","SEA VIEW LN",1)

replace location=subinstr(location,"SHERMAN CT CB","SHERMAN CT",1)
replace street=subinstr(street,"SHERMAN CT CB","SHERMAN CT",1)

replace location=subinstr(location,"SHORE RD OGBA","SHORE RD",1)
replace street=subinstr(street,"SHORE RD OGBA","SHORE RD",1)

replace location=subinstr(location,"SOUTH DR OGBA","SOUTH DR",1)
replace street=subinstr(street,"SOUTH DR OGBA","SOUTH DR",1)

replace location=subinstr(location,"SOUTH TR","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR","SOUTH TRL",1)

replace location=subinstr(location,"SOUTH TR BPBC","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR BPBC","SOUTH TRL",1)

replace location=subinstr(location,"SPENCER AVE CB","SPENCER AVE",1)
replace street=subinstr(street,"SPENCER AVE CB","SPENCER AVE",1)

replace location=subinstr(location,"SPRING GLEN RD GNH","SPRING GLEN RD",1)
replace street=subinstr(street,"SPRING GLEN RD GNH","SPRING GLEN RD",1)

replace location=subinstr(location,"SUNRISE AVE BPBC","SUNRISE AVE",1)
replace street=subinstr(street,"SUNRISE AVE BPBC","SUNRISE AVE",1)

replace location=subinstr(location,"SUNSET AVE BPBC","SUNSET AVE",1)
replace street=subinstr(street,"SUNSET AVE BPBC","SUNSET AVE",1)

replace location=subinstr(location,"TABERNACLE AVE CB","TABERNACLE AVE",1)
replace street=subinstr(street,"TABERNACLE AVE CB","TABERNACLE AVE",1)

replace location=subinstr(location,"TERRACE AVE CB","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE CB","TERRACE AVE",1)

replace location=subinstr(location,"TERRACE AVE OGBA","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE OGBA","TERRACE AVE",1)

replace location=subinstr(location,"UNCAS RD BPBC","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD BPBC","UNCAS RD",1)

replace location=subinstr(location,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)
replace street=subinstr(street,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)

replace location=subinstr(location,"WATERSIDE AVE BPBC","WATERSIDE RD",1)
replace street=subinstr(street,"WATERSIDE AVE BPBC","WATERSIDE RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"WESTOMERE TR","WESTOMERE TER",1)
replace street=subinstr(street,"WESTOMERE TR","WESTOMERE TER",1)

replace location=subinstr(location,"WHITECAP RD BPBC","WHITECAP RD",1)
replace street=subinstr(street,"WHITECAP RD BPBC","WHITECAP RD",1)

replace location=subinstr(location,"WHITTLESEY PL","WHITTLESAY PL",1)
replace street=subinstr(street,"WHITTLESEY PL","WHITTLESAY PL",1)

replace location=subinstr(location,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)
replace street=subinstr(street,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)

replace location=subinstr(location,"WOODLAND DR BPBC","WOODLAND DR",1)
replace street=subinstr(street,"WOODLAND DR BPBC","WOODLAND DR",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_newlondoneastlyme.dta",replace

****************************Branford*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_branford.dta",clear
duplicates report orig_fid

ren house_num address_num

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)=="169-193 SO MONTOWESE ST"&dup1>=1
drop if trim(location)=="LANPHIERS COVE CAMP"&dup1>=1
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Branford Specific
replace location=subinstr(location,"ASH CREEK DR","ASH CREEK RD",1)
replace street=subinstr(street,"ASH CREEK DR","ASH CREEK RD",1)

replace location=subinstr(location,"BAYARDS CROSSING","BAYARDS XING",1)
replace street=subinstr(street,"BAYARDS CROSSING","BAYARDS XING",1)

replace location=subinstr(location,"BAYBERRY LA","BAYBERRY LN",1)
replace street=subinstr(street,"BAYBERRY LA","BAYBERRY LN",1)

replace location=subinstr(location,"BRANDEGEE AVE","BRANDAGEE AVE",1)
replace street=subinstr(street,"BRANDEGEE AVE","BRANDAGEE AVE",1)

replace location=subinstr(location,"BREEZY LA","BREEZY LN",1)
replace street=subinstr(street,"BREEZY LA","BREEZY LN",1)

replace location=subinstr(location,"BRIARWOOD LA","BRIARWOOD LN",1)
replace street=subinstr(street,"BRIARWOOD LA","BRIARWOOD LN",1)

replace location=subinstr(location,"BROCKETTS LA","BROCKETTS LN",1)
replace street=subinstr(street,"BROCKETTS LA","BROCKETTS LN",1)

replace location=subinstr(location,"BROCKETTS PT RD","BROCKETTS POINT RD",1)
replace street=subinstr(street,"BROCKETTS PT RD","BROCKETTS POINT RD",1)

replace location=subinstr(location,"BUENA VIS RD","BUENA VISTA RD",1)
replace street=subinstr(street,"BUENA VIS RD","BUENA VISTA RD",1)

replace location=subinstr(location,"BUNGALOW LA","BUNGALOW LN",1)
replace street=subinstr(street,"BUNGALOW LA","BUNGALOW LN",1)

replace location=subinstr(location,"CAPTAINS LA","CAPTAINS LN",1)
replace street=subinstr(street,"CAPTAINS LA","CAPTAINS LN",1)

replace location=subinstr(location,"CIDER MILL LA","CIDER MILL LN",1)
replace street=subinstr(street,"CIDER MILL LA","CIDER MILL LN",1)

replace location=subinstr(location,"EAST HAYCOCK PT RD","E HAYCOCK POINT RD",1)
replace street=subinstr(street,"EAST HAYCOCK PT RD","E HAYCOCK POINT RD",1)

replace location=subinstr(location,"EDGEWOOD ST","EDGEWOOD RD",1)
replace street=subinstr(street,"EDGEWOOD ST","EDGEWOOD RD",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"FERRY LA","FERRY LN",1)
replace street=subinstr(street,"FERRY LA","FERRY LN",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FLYING PT RD","FLYING POINT RD",1)
replace street=subinstr(street,"FLYING PT RD","FLYING POINT RD",1)

replace location=subinstr(location,"FOREST ST EXT","FOREST STREET EXT",1)
replace street=subinstr(street,"FOREST ST EXT","FOREST STREET EXT",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"GOODSELL PT RD","GOODSELL POINT RD",1)
replace street=subinstr(street,"GOODSELL PT RD","GOODSELL POINT RD",1)

replace location=subinstr(location,"GREYLEDGE RD","GRAY LEDGE RD",1)
replace street=subinstr(street,"GREYLEDGE RD","GRAY LEDGE RD",1)

replace location=subinstr(location,"GROVE ST","GROVE STREET EXT",1)
replace street=subinstr(street,"GROVE ST","GROVE STREET EXT",1)

replace location=subinstr(location,"HALLS PT RD","HALLS POINT RD",1)
replace street=subinstr(street,"HALLS PT RD","HALLS POINT RD",1)

replace location=subinstr(location,"HALSTEAD LA","HALSTEAD LN",1)
replace street=subinstr(street,"HALSTEAD LA","HALSTEAD LN",1)

replace location=subinstr(location,"HOLLY LA","HOLLY LN",1)
replace street=subinstr(street,"HOLLY LA","HOLLY LN",1)

replace location=subinstr(location,"INDIAN PT RD","INDIAN POINT RD",1)
replace street=subinstr(street,"INDIAN PT RD","INDIAN POINT RD",1)

replace location=subinstr(location,"ISABEL LA","ISABEL LN",1)
replace street=subinstr(street,"ISABEL LA","ISABEL LN",1)

replace location=subinstr(location,"JOHNSONS PT RD","JOHNSONS POINT RD",1)
replace street=subinstr(street,"JOHNSONS PT RD","JOHNSONS POINT RD",1)

replace location=subinstr(location,"JUNIPER PT RD","JUNIPER POINT RD",1)
replace street=subinstr(street,"JUNIPER PT RD","JUNIPER POINT RD",1)

replace location=subinstr(location,"KATIE-JOE LA","KATIE JOE LN",1)
replace street=subinstr(street,"KATIE-JOE LA","KATIE JOE LN",1)

replace location=subinstr(location,"KELLYCREST RD","KELLY CREST RD",1)
replace street=subinstr(street,"KELLYCREST RD","KELLY CREST RD",1)

replace location=subinstr(location,"KENWOOD LA","KENWOOD LN",1)
replace street=subinstr(street,"KENWOOD LA","KENWOOD LN",1)

replace location=subinstr(location,"KILLAMS PT RD","KILLAMS PT",1)
replace street=subinstr(street,"KILLAMS PT RD","KILLAMS PT",1)

replace location=subinstr(location,"LAKE AVE","LAKE PL",1)
replace street=subinstr(street,"LAKE AVE","LAKE PL",1)

replace location=subinstr(location,"LANPHIERS COVE CAMP","LANPHIERS COVE CP",1)
replace street=subinstr(street,"LANPHIERS COVE CAMP","LANPHIERS COVE CP",1)

replace location=subinstr(location,"LINDEN PT RD","LINDEN POINT RD",1)
replace street=subinstr(street,"LINDEN PT RD","LINDEN POINT RD",1)

replace location=subinstr(location,"LINDSLEY ST","LINSLEY ST",1)
replace street=subinstr(street,"LINDSLEY ST","LINSLEY ST",1)

replace location=subinstr(location,"LITTLE BAY LA","LITTLE BAY LN",1)
replace street=subinstr(street,"LITTLE BAY LA","LITTLE BAY LN",1)

replace location=subinstr(location,"LONG PT RD","LONG POINT RD",1)
replace street=subinstr(street,"LONG PT RD","LONG POINT RD",1)

replace location=subinstr(location,"MARIAN RD","MARION RD",1)
replace street=subinstr(street,"MARIAN RD","MARION RD",1)

replace location=subinstr(location,"NINTH AVE","9TH AVE",1)
replace street=subinstr(street,"NINTH AVE","9TH AVE",1)

replace location=subinstr(location,"PAVILLION DR","PAVILION CT",1)
replace street=subinstr(street,"PAVILLION DR","PAVILION CT",1)

replace location=subinstr(location,"PLEASANT PT RD","PLEASANT POINT RD",1)
replace street=subinstr(street,"PLEASANT PT RD","PLEASANT POINT RD",1)

replace location=subinstr(location,"ROCKLAND PK","ROCKLAND PARK",1)
replace street=subinstr(street,"ROCKLAND PK","ROCKLAND PARK",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SHADY LA","SHADY LN",1)
replace street=subinstr(street,"SHADY LA","SHADY LN",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SO MONTOWESE ST","S MONTOWESE ST",1)
replace street=subinstr(street,"SO MONTOWESE ST","S MONTOWESE ST",1)

replace location=subinstr(location,"SOUND VIEW HGTS","SOUND VIEW HTS",1)
replace street=subinstr(street,"SOUND VIEW HGTS","SOUND VIEW HTS",1)

replace location=subinstr(location,"SPICE BUSH LA","SPICE BUSH LN",1)
replace street=subinstr(street,"SPICE BUSH LA","SPICE BUSH LN",1)

replace location=subinstr(location,"THIMBLE FARMS RD","THIMBLE FARM RD",1)
replace street=subinstr(street,"THIMBLE FARMS RD","THIMBLE FARM RD",1)

replace location=subinstr(location,"THIMBLE ISLANDS RD","THIMBLE ISLAND RD",1)
replace street=subinstr(street,"THIMBLE ISLANDS RD","THIMBLE ISLAND RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"THREE ELM RD","THREE ELMS RD",1)
replace street=subinstr(street,"THREE ELM RD","THREE ELMS RD",1)

replace location=subinstr(location,"UNION AVE","UNION ST",1)
replace street=subinstr(street,"UNION AVE","UNION ST",1)

replace location=subinstr(location,"WEST HAYCOCK PT","W HAYCOCK POINT RD",1)
replace street=subinstr(street,"WEST HAYCOCK PT","W HAYCOCK POINT RD",1)

replace location=subinstr(location,"WEST PT RD","W POINT RD",1)
replace street=subinstr(street,"WEST PT RD","W POINT RD",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_branford.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.
****************************Guilford*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_guilford.dta",clear
duplicates report orig_fid

ren house_num address_num

keep fid_build orig_fid location street address_num
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)=="LEETES ISLAND RD"&dup1>=1
drop if trim(location)=="PADDOCK LN"&dup1>=1
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Guilford Specific
replace location=subinstr(location,"BENTONS KNOLL","BENTONS KNL",1)
replace street=subinstr(street,"BENTONS KNOLL","BENTONS KNL",1)

replace location=subinstr(location,"BIRCH GROVE","BIRCH GRV",1)
replace street=subinstr(street,"BIRCH GROVE","BIRCH GRV",1)

replace location=subinstr(location,"CORN CRIB HILL","CORNCRIB HILL RD",1)
replace street=subinstr(street,"CORN CRIB HILL","CORNCRIB HILL RD",1)

replace location=subinstr(location,"JUNIPER KNOLL","JUNIPER KNLS",1)
replace street=subinstr(street,"JUNIPER KNOLL","JUNIPER KNLS",1)

replace location=subinstr(location,"NO REEVES AVE","N REEVES AVE",1)
replace street=subinstr(street,"NO REEVES AVE","N REEVES AVE",1)

replace location=subinstr(location,"SACHEMS HEAD RD","SACHEM HEAD RD",1)
replace street=subinstr(street,"SACHEMS HEAD RD","SACHEM HEAD RD",1)

replace location=subinstr(location,"SEAVIEW TERR","SEAVIEW TER",1)
replace street=subinstr(street,"SEAVIEW TERR","SEAVIEW TER",1)

replace location=subinstr(location,"SO UNION ST","S UNION ST",1)
replace street=subinstr(street,"SO UNION ST","S UNION ST",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_guilford.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.

****************************Madison*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_madison.dta",clear
duplicates report orig_fid

ren house_num address_num
ren muni propertycity

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Madison Specific
replace location=subinstr(location,"DEER RUN","DEER RUN RD",1)
replace street=subinstr(street,"DEER RUN","DEER RUN RD",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"LANTERN HILL RD","LANTERN HL",1)
replace street=subinstr(street,"LANTERN HILL RD","LANTERN HL",1)

replace location=subinstr(location,"MEETINGHOUSE LN","MEETING HOUSE LN",1)
replace street=subinstr(street,"MEETINGHOUSE LN","MEETING HOUSE LN",1)

replace location=subinstr(location,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)
replace street=subinstr(street,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)

replace location=subinstr(location,"OVERSHORES DR EAST","OVERSHORES E",1)
replace street=subinstr(street,"OVERSHORES DR EAST","OVERSHORES E",1)

replace location=subinstr(location,"OVERSHORES DR WEST","OVERSHORES W",1)
replace street=subinstr(street,"OVERSHORES DR WEST","OVERSHORES W",1)

replace location=subinstr(location,"PENT RD #5","PENT RD",1)
replace street=subinstr(street,"PENT RD #5","PENT RD",1)

replace location=subinstr(location,"STERLING PARK DR","STERLING PARK",1)
replace street=subinstr(street,"STERLING PARK DR","STERLING PARK",1)

replace location=subinstr(location,"WEST WHARF RD","W WHARF RD",1)
replace street=subinstr(street,"WEST WHARF RD","W WHARF RD",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_madison.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.



****************************New Haven*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_newhaven.dta",clear
duplicates report orig_fid

ren house_num address_num
ren muni propertycity

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*New Haven Specific
replace location=subinstr(location,"BLATCHLEY AV","BLATCHLEY AVE",1)
replace street=subinstr(street,"BLATCHLEY AV","BLATCHLEY AVE",1)

replace location=subinstr(location,"DOUGLASS AV","DOUGLASS AVE",1)
replace street=subinstr(street,"DOUGLASS AV","DOUGLASS AVE",1)

replace location=subinstr(location,"FAIRMONT AV","FAIRMONT AVE",1)
replace street=subinstr(street,"FAIRMONT AV","FAIRMONT AVE",1)

replace location=subinstr(location,"FARREN AV","FARREN AVE",1)
replace street=subinstr(street,"FARREN AV","FARREN AVE",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FLORENCE AV","FLORENCE AVE",1)
replace street=subinstr(street,"FLORENCE AV","FLORENCE AVE",1)

replace location=subinstr(location,"FORBES AV","FORBES AVE",1)
replace street=subinstr(street,"FORBES AV","FORBES AVE",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GIRARD AV","GIRARD AVE",1)
replace street=subinstr(street,"GIRARD AV","GIRARD AVE",1)

replace location=subinstr(location,"GREENWICH AV","GREENWICH AVE",1)
replace street=subinstr(street,"GREENWICH AV","GREENWICH AVE",1)

replace location=subinstr(location,"HALLOCK AV","HALLOCK AVE",1)
replace street=subinstr(street,"HALLOCK AV","HALLOCK AVE",1)

replace location=subinstr(location,"HORSLEY AV","HORSLEY AVE",1)
replace street=subinstr(street,"HORSLEY AV","HORSLEY AVE",1)

replace location=subinstr(location,"HOWARD AV","HOWARD AVE",1)
replace street=subinstr(street,"HOWARD AV","HOWARD AVE",1)

replace location=subinstr(location,"KIMBERLY AV","KIMBERLY AVE",1)
replace street=subinstr(street,"KIMBERLY AV","KIMBERLY AVE",1)

replace location=subinstr(location,"MEADOW VIEW ST","MEADOW VIEW RD",1)
replace street=subinstr(street,"MEADOW VIEW ST","MEADOW VIEW RD",1)

replace location=subinstr(location,"MORRIS AV","MORRIS AVE",1)
replace street=subinstr(street,"MORRIS AV","MORRIS AVE",1)

replace location=subinstr(location,"ORCHARD AV","ORCHARD AVE",1)
replace street=subinstr(street,"ORCHARD AV","ORCHARD AVE",1)

replace location=subinstr(location,"PARK LA","PARK LN",1)
replace street=subinstr(street,"PARK LA","PARK LN",1)

replace location=subinstr(location,"PROSPECT AV","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AV","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPIAC AV","QUINNIPIAC AVE",1)
replace street=subinstr(street,"QUINNIPIAC AV","QUINNIPIAC AVE",1)

replace location=subinstr(location,"SALTONSTALL AV","SALTONSTALL AVE",1)
replace street=subinstr(street,"SALTONSTALL AV","SALTONSTALL AVE",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SHEPARD AV","SHEPARD AVE",1)
replace street=subinstr(street,"SHEPARD AV","SHEPARD AVE",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"SOUTH WATER ST","S WATER ST",1)
replace street=subinstr(street,"SOUTH WATER ST","S WATER ST",1)

replace location=subinstr(location,"STUYVESANT AV","STUYVESANT AVE",1)
replace street=subinstr(street,"STUYVESANT AV","STUYVESANT AVE",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TOWNSEND AV","TOWNSEND AVE",1)
replace street=subinstr(street,"TOWNSEND AV","TOWNSEND AVE",1)

replace location=subinstr(location,"WOODWARD AV","WOODWARD AVE",1)
replace street=subinstr(street,"WOODWARD AV","WOODWARD AVE",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_newhaven.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.
*****************************West Haven*********************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_westhaven.dta",clear
duplicates report orig_fid

ren house_num address_num
ren muni propertycity

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*West Haven Specific
replace location=subinstr(location,"BARBARA LA","BARBARA LN",1)
replace street=subinstr(street,"BARBARA LA","BARBARA LN",1)

replace location=subinstr(location,"BATT LA","BATT LN",1)
replace street=subinstr(street,"BATT LA","BATT LN",1)

replace location=subinstr(location,"BAYCREST AVE","BAYCREST DR",1)
replace street=subinstr(street,"BAYCREST AVE","BAYCREST DR",1)

replace location=subinstr(location,"BELLE CIRCLE","BELLE CIR",1)
replace street=subinstr(street,"BELLE CIRCLE","BELLE CIR",1)

replace location=subinstr(location,"BUNGALOW LA","BUNGALOW LN",1)
replace street=subinstr(street,"BUNGALOW LA","BUNGALOW LN",1)

replace location=subinstr(location,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)
replace street=subinstr(street,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)

replace location=subinstr(location,"CHECK PT LN","CHECK POINT LN",1)
replace street=subinstr(street,"CHECK PT LN","CHECK POINT LN",1)

replace location=subinstr(location,"CHERRY LA","CHERRY LN",1)
replace street=subinstr(street,"CHERRY LA","CHERRY LN",1)

replace location=subinstr(location,"CIRCLE ST.","CIRCLE ST",1)
replace street=subinstr(street,"CIRCLE ST.","CIRCLE ST",1)

replace location=subinstr(location,"COLONIAL BLV","COLONIAL BLVD",1)
replace street=subinstr(street,"COLONIAL BLV","COLONIAL BLVD",1)

replace location=subinstr(location,"CONN AVE","CONNECTICUT AVE",1)
replace street=subinstr(street,"CONN AVE","CONNECTICUT AVE",1)

replace location=subinstr(location,"DELAWAN AV","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV","DELAWAN AVE",1)

replace location=subinstr(location,"DELAWAN AV REAR","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV REAR","DELAWAN AVE",1)

replace location=subinstr(location,"EASY RUDDER LA","EASY RUDDER LN",1)
replace street=subinstr(street,"EASY RUDDER LA","EASY RUDDER LN",1)

replace location=subinstr(location,"FAIR SAILING","FAIR SAILING RD",1)
replace street=subinstr(street,"FAIR SAILING","FAIR SAILING RD",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FIRST AV","1ST AVE",1)
replace street=subinstr(street,"FIRST AV","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)
replace street=subinstr(street,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)

replace location=subinstr(location,"LAURIE LA","LAURIE LN",1)
replace street=subinstr(street,"LAURIE LA","LAURIE LN",1)

replace location=subinstr(location,"LEONARD ST.","LEONARD ST",1)
replace street=subinstr(street,"LEONARD ST.","LEONARD ST",1)

replace location=subinstr(location,"MAY ST EXT","MAY ST",1)
replace street=subinstr(street,"MAY ST EXT","MAY ST",1)
/*
replace location=subinstr(location,"MOHAWK DR","MOHAWK DRIVE EXT",1)
replace street=subinstr(street,"MOHAWK DR","MOHAWK DRIVE EXT",1)
*/
replace location=subinstr(location,"MORGAN LA","MORGAN LN",1)
replace street=subinstr(street,"MORGAN LA","MORGAN LN",1)

replace location=subinstr(location,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)
replace street=subinstr(street,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)

replace location=subinstr(location,"NO UNION AVE","N UNION AVE",1)
replace street=subinstr(street,"NO UNION AVE","N UNION AVE",1)

replace location=subinstr(location,"OSBORN AVE","OSBORNE AVE",1)
replace street=subinstr(street,"OSBORN AVE","OSBORNE AVE",1)

replace location=subinstr(location,"PARK TER AVE","PARK TERRACE AVE",1)
replace street=subinstr(street,"PARK TER AVE","PARK TERRACE AVE",1)

replace location=subinstr(location,"PARKER AVE EAST","PARKER AVE E",1)
replace street=subinstr(street,"PARKER AVE EAST","PARKER AVE E",1)

replace location=subinstr(location,"PARKRIDGE RD","PARK RIDGE RD",1)
replace street=subinstr(street,"PARKRIDGE RD","PARK RIDGE RD",1)

replace location=subinstr(location,"PECK LA","PECK LN",1)
replace street=subinstr(street,"PECK LA","PECK LN",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SECOND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"SECOND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"2ND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"2ND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"SOUNDVIEW ST","SOUND VIEW ST",1)
replace street=subinstr(street,"SOUNDVIEW ST","SOUND VIEW ST",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"THIRD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"THIRD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"3RD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"3RD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"TYLER AVE","TYLER ST",1)
replace street=subinstr(street,"TYLER AVE","TYLER ST",1)

replace location=subinstr(location,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WINDSOCK RD","WIND SOCK RD",1)
replace street=subinstr(street,"WINDSOCK RD","WIND SOCK RD",1)

replace location=subinstr(location,"WOODY CREST","WOODY CRST",1)
replace street=subinstr(street,"WOODY CREST","WOODY CRST",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_westhaven.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.






***********************************************************************
*  Check coordinates-building match quality - Bridgeport              *
***********************************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_bridgeport.dta",clear
duplicates report orig_fid

ren cama_gi_13 location
ren cama_gi_14 address_num

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(location," ",2)
gen street=substr(location,firstblankpos+1,.)
gen propertycity="BRIDGEPORT"

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)
capture drop firsthash
gen firsthash=ustrpos(location,"#",1)
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)
browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Bridgeport Specific

replace location=subinstr(location," AV"," AVE",1)
replace street=subinstr(street," AV"," AVE",1)

replace location=subinstr(location,"BYWATER LN","BYWATYR LN",1)
replace street=subinstr(street,"BYWATER LN","BYWATYR LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)
replace street=subinstr(street,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)

replace location=subinstr(location,"FAYERWEATHER TR","FAYERWEATHER TER",1)
replace street=subinstr(street,"FAYERWEATHER TR","FAYERWEATHER TER",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GARDEN TR","GARDEN TER",1)
replace street=subinstr(street,"GARDEN TR","GARDEN TER",1)

replace location=subinstr(location,"MARINA PARK ST","MARINA PARK CIR",1)
replace street=subinstr(street,"MARINA PARK ST","MARINA PARK CIR",1)

replace location=subinstr(location,"MARTIN TR","MARTIN TER",1)
replace street=subinstr(street,"MARTIN TR","MARTIN TER",1)

replace location=subinstr(location," TR"," TER",1)
replace street=subinstr(street," TR"," TER",1)

replace location=subinstr(location,"OGDEN ST EX","OGDEN STREET EXT",1)
replace street=subinstr(street,"OGDEN ST EX","OGDEN STREET EXT",1)

replace location=subinstr(location,"PEARSALL WY","PEARSALL WAY",1)
replace street=subinstr(street,"PEARSALL WY","PEARSALL WAY",1)

replace location=subinstr(location,"SHERMAN PARK CR","SHERMAN PARK CIR",1)
replace street=subinstr(street,"SHERMAN PARK CR","SHERMAN PARK CIR",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"WEST LIBERTY ST","W LIBERTY ST",1)
replace street=subinstr(street,"WEST LIBERTY ST","W LIBERTY ST",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_bridgeport.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.

***********************************************************************
*       Check coordinates-building match quality - Stratford          *
***********************************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_stratford.dta",clear
duplicates report orig_fid

ren realmast_3 location

capture drop firstblankpos
gen firstblankpos=ustrpos(location," ",2)
gen address_num=substr(location,1,firstblankpos-1)
gen propertycity="STRATFORD"
ren realmast_4 street

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location dup1,force
duplicates drop FID_Buildingfootprint dup1,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos
capture drop PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Stratford Specific
replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WEST BEACH DR","W BEACH DR",1)
replace street=subinstr(street,"WEST BEACH DR","W BEACH DR",1)

replace location=subinstr(location,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)
replace street=subinstr(street,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_stratford.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.

***********************************************************************
*        Check coordinates-building match quality - Westport          *
***********************************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_westport.dta",clear
duplicates report orig_fid

tostring street_num,gen(address_num)
gen location=address_num+" "+street_nam
ren street_nam street

gen propertycity="WESTPORT"

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location dup1,force
duplicates drop FID_Buildingfootprint dup1,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos
capture drop PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Westport Specific
replace location=subinstr(location,"APPLETREE TRL","APPLE TREE TRL",1)
replace street=subinstr(street,"APPLETREE TRL","APPLE TREE TRL",1)

replace location=subinstr(location,"BLUEWATER HILL","BLUEWATER HL",1)
replace street=subinstr(street,"BLUEWATER HILL","BLUEWATER HL",1)

replace location=subinstr(location,"BLUEWATER HILL S","BLUEWATER HL S",1)
replace street=subinstr(street,"BLUEWATER HILL S","BLUEWATER HL S",1)

replace location=subinstr(location,"BURNHAM HILL","BURNHAM HL",1)
replace street=subinstr(street,"BURNHAM HILL","BURNHAM HL",1)

replace location=subinstr(location,"COMPO MILL COVE","COMPO MILL CV",1)
replace street=subinstr(street,"COMPO MILL COVE","COMPO MILL CV",1)

replace location=subinstr(location,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)
replace street=subinstr(street,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)

replace location=subinstr(location,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)
replace street=subinstr(street,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)

replace location=subinstr(location,"GREENS FARMS HOL","GREENS FARMS HOLW",1)
replace street=subinstr(street,"GREENS FARMS HOL","GREENS FARMS HOLW",1)

replace location=subinstr(location,"GROVE PT RD","GROVE PT",1)
replace street=subinstr(street,"GROVE PT RD","GROVE PT",1)

replace location=subinstr(location,"HARBOR HILL","HARBOR HL",1)
replace street=subinstr(street,"HARBOR HILL","HARBOR HL",1)

replace location=subinstr(location,"HIAWATHA LN","HIAWATHA LANE EXT",1)
replace street=subinstr(street,"HIAWATHA LN","HIAWATHA LANE EXT",1)

replace location=subinstr(location,"HIDE-AWAY LN","HIDEAWAY LN",1)
replace street=subinstr(street,"HIDE-AWAY LN","HIDEAWAY LN",1)

replace location=subinstr(location,"HORSESHOE CT","HORSESHOE LN",1)
replace street=subinstr(street,"HORSESHOE CT","HORSESHOE LN",1)

replace location=subinstr(location,"JUDY PT LN","JUDY POINT LN",1)
replace street=subinstr(street,"JUDY PT LN","JUDY POINT LN",1)

replace location=subinstr(location,"LAZY BRK LN","LAZY BROOK LN",1)
replace street=subinstr(street,"LAZY BRK LN","LAZY BROOK LN",1)

replace location=subinstr(location,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)
replace street=subinstr(street,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)

replace location=subinstr(location,"MARSH RD","MARSH CT",1)
replace street=subinstr(street,"MARSH RD","MARSH CT",1)

replace location=subinstr(location,"MINUTE MAN HILL","MINUTE MAN HL",1)
replace street=subinstr(street,"MINUTE MAN HILL","MINUTE MAN HL",1)

replace location=subinstr(location,"OAK RDG PK","OAK RIDGE PARK",1)
replace street=subinstr(street,"OAK RDG PK","OAK RIDGE PARK",1)

replace location=subinstr(location,"OWENOKE PK","OWENOKE PARK",1)
replace street=subinstr(street,"OWENOKE PK","OWENOKE PARK",1)

replace location=subinstr(location,"RIVARD CRESCENT","RIVARD CRES",1)
replace street=subinstr(street,"RIVARD CRESCENT","RIVARD CRES",1)

replace location=subinstr(location,"RIVERVIEW RD","RIVER VIEW RD",1)
replace street=subinstr(street,"RIVERVIEW RD","RIVER VIEW RD",1)

replace location=subinstr(location,"ROWLAND CT","ROWLAND PL",1)
replace street=subinstr(street,"ROWLAND CT","ROWLAND PL",1)

replace location=subinstr(location,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)
replace street=subinstr(street,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)

replace location=subinstr(location,"SMOKY LN","SMOKEY LN",1)
replace street=subinstr(street,"SMOKY LN","SMOKEY LN",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"STONEY POINT RD","STONY POINT RD",1)
replace PropertyStreet=subinstr(PropertyStreet,"STONEY POINT RD","STONY POINT RD",1)

replace location=subinstr(location,"STONY PT W","STONY POINT RD W",1)
replace street=subinstr(street,"STONY PT W","STONY POINT RD W",1)

replace location=subinstr(location,"SURREY DR","SURREY LN",1)
replace street=subinstr(street,"SURREY DR","SURREY LN",1)

replace location=subinstr(location,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)
replace street=subinstr(street,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)


gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number

duplicates report PropertyFullStreetAddress PropertyCity
duplicates drop PropertyFullStreetAddress PropertyCity,force
save "$dta\pointcheck_westport.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.



***********************************************************************
*   Check coordinates-building match quality - Waterford              *
***********************************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_waterford.dta",clear
duplicates report orig_fid

ren watfrd_c_5 location
ren watfrd_c_8 street


capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(location," ",2)
gen address_num=substr(location,1,firstblankpos-1)

ren circa_wa_6 propertycity

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location,force
duplicates drop FID_Buildingfootprint,force
drop dup1

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)
capture drop firsthash
gen firsthash=ustrpos(location,"#",1)
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)

order street PropertyStreet
sort street
browse if PropertyStreet!=street
*Waterford Specific
replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"BEACH ST EAST","BEACH ST E",1)
replace street=subinstr(street,"BEACH ST EAST","BEACH ST E",1)

replace location=subinstr(location,"EAST BISHOP ST","E BISHOP ST",1)
replace street=subinstr(street,"EAST BISHOP ST","E BISHOP ST",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)
replace street=subinstr(street,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)

replace location=subinstr(location,"LEONARD CT","LEONARD RD",1)
replace street=subinstr(street,"LEONARD CT","LEONARD RD",1)

replace location=subinstr(location,"LINDROS LN","LINDROSS LN",1)
replace street=subinstr(street,"LINDROS LN","LINDROSS LN",1)

replace location=subinstr(location,"MAGONK PT RD","MAGONK POINT RD",1)
replace street=subinstr(street,"MAGONK PT RD","MAGONK POINT RD",1)

replace location=subinstr(location,"MILLSTONE RD EAST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD EAST","MILLSTONE RD",1)

replace location=subinstr(location,"MILLSTONE RD WEST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD WEST","MILLSTONE RD",1)

replace location=subinstr(location,"PARKWAY DR","PARKWAY",1)
replace street=subinstr(street,"PARKWAY DR","PARKWAY",1)

replace location=subinstr(location,"SEA MEADOW LN","SEA MEADOWS LN",1)
replace street=subinstr(street,"SEA MEADOW LN","SEA MEADOWS LN",1)

replace location=subinstr(location,"STRAND RD","STRAND",1)
replace street=subinstr(street,"STRAND RD","STRAND",1)

replace location=subinstr(location,"WEST NECK RD","W NECK RD",1)
replace street=subinstr(street,"WEST NECK RD","W NECK RD",1)

replace location=subinstr(location,"WEST STRAND RD","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND RD","W STRAND RD",1)

replace location=subinstr(location,"WEST STRAND","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND","W STRAND RD",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_waterford.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.



***********************************************************************
*      Check coordinates-building match quality - Norwalk             *
***********************************************************************
use "D:\Work\CIRCA\Circa\GISdata\pointcheck_norwalk.dta",clear
duplicates report orig_fid

ren streetname street
ren streetnum address_num

ren loccity propertycity

keep fid_build orig_fid location street address_num propertycity
ren fid_build FID_Buildingfootprint
duplicates report FID_Buildingfootprint

merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

duplicates tag FID_Buildingfootprint,gen(dup_build)
gen Inaccur_point=(dup_build>=1)
drop dup_build

replace location=trim(location)
replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
sort FID_Buildingfootprint

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)


capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)
capture drop firsthash
gen firsthash=ustrpos(location,"#",1)
browse if firsthash>=1
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)

order street PropertyStreet
sort street
browse if PropertyStreet!=street
*Norwalk Specific
replace location=subinstr(location,"ACACIA ST","ACACIA DR",1)
replace street=subinstr(street,"ACACIA ST","ACACIA DR",1)

replace location=subinstr(location,"BROWNE PL","BROWN PL",1)
replace street=subinstr(street,"BROWNE PL","BROWN PL",1)

replace location=subinstr(location,"CAPTAINS WALK RD","CAPTAINS WALK",1)
replace street=subinstr(street,"CAPTAINS WALK RD","CAPTAINS WALK",1)

replace location=subinstr(location,"CIRCLE ST","CIRCLE RD",1)
replace street=subinstr(street,"CIRCLE ST","CIRCLE RD",1)

replace location=subinstr(location,"COVLEE DR","COVELEE DR",1)
replace street=subinstr(street,"COVLEE DR","COVELEE DR",1)

replace location=subinstr(location,"EAST BEACH DR","E BEACH DR",1)
replace street=subinstr(street,"EAST BEACH DR","E BEACH DR",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"HILLSIDE ST","HILLSIDE PL",1)
replace street=subinstr(street,"HILLSIDE ST","HILLSIDE PL",1)

replace location=subinstr(location,"JO'S BARN WY","JO S BARN WAY",1)
replace street=subinstr(street,"JO'S BARN WY","JO S BARN WAY",1)

replace location=subinstr(location,"LITTLE WY","LITTLE WAY",1)
replace street=subinstr(street,"LITTLE WY","LITTLE WAY",1)

replace location=subinstr(location,"NAPLES AVE","NAPLES ST",1)
replace street=subinstr(street,"NAPLES AVE","NAPLES ST",1)

replace location=subinstr(location,"OLD TROLLEY WY","OLD TROLLEY WAY",1)
replace street=subinstr(street,"OLD TROLLEY WY","OLD TROLLEY WAY",1)

replace location=subinstr(location,"PHILLENE RD","PHILLENE DR",1)
replace street=subinstr(street,"PHILLENE RD","PHILLENE DR",1)

replace location=subinstr(location,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)
replace street=subinstr(street,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)

replace location=subinstr(location,"POND RIDGE RD","POND RIDGE LN",1)
replace street=subinstr(street,"POND RIDGE RD","POND RIDGE LN",1)

replace location=subinstr(location,"ROBINS SQ EAST","ROBINS SQ E",1)
replace street=subinstr(street,"ROBINS SQ EAST","ROBINS SQ E",1)

replace location=subinstr(location,"ROBINS SQ SOUTH","ROBINS SQ S",1)
replace street=subinstr(street,"ROBINS SQ SOUTH","ROBINS SQ S",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SELDON ST","SELDON PL",1)
replace street=subinstr(street,"SELDON ST","SELDON PL",1)

replace location=subinstr(location,"SHOREFRONT PK","SHOREFRONT PARK",1)
replace street=subinstr(street,"SHOREFRONT PK","SHOREFRONT PARK",1)

replace location=subinstr(location,"SOUTH BEACH DR","S BEACH DR",1)
replace street=subinstr(street,"SOUTH BEACH DR","S BEACH DR",1)

replace location=subinstr(location,"SOUTH MAIN ST","S MAIN ST",1)
replace street=subinstr(street,"SOUTH MAIN ST","S MAIN ST",1)

replace location=subinstr(location,"SOUTH SMITH ST","S SMITH ST",1)
replace street=subinstr(street,"SOUTH SMITH ST","S SMITH ST",1)

replace location=subinstr(location,"ST JAMES PL","SAINT JAMES PL",1)
replace street=subinstr(street,"ST JAMES PL","SAINT JAMES PL",1)

replace location=subinstr(location,"ST. JOHN ST","SAINT JOHN ST",1)
replace street=subinstr(street,"ST. JOHN ST","SAINT JOHN ST",1)

replace location=subinstr(location,"STEEPLETOP RD","STEEPLE TOP RD",1)
replace street=subinstr(street,"STEEPLETOP RD","STEEPLE TOP RD",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TONETTA CR","TONETTA CIR",1)
replace street=subinstr(street,"TONETTA CR","TONETTA CIR",1)

replace location=subinstr(location,"TOPSAIL RD","TOP SAIL RD",1)
replace street=subinstr(street,"TOPSAIL RD","TOP SAIL RD",1)

replace location=subinstr(location,"WEST MEADOW PL","W MEADOW PL",1)
replace street=subinstr(street,"WEST MEADOW PL","W MEADOW PL",1)

gen diff_street=(trim(PropertyStreet)!=street)

gen diff_address=(trim(PropertyFullStreetAddress)!=location)

tab diff_address if Inaccur_point==1 
tab diff_address if Inaccur_point==0 

destring address_num,replace force
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)
destring PropertyStreetNum,replace force
gen diffstr_out4number=(trim(PropertyFullStreetAddress)!=location&abs(PropertyStreetNum-address_num)>4&abs(PropertyStreetNum-address_num)!=.)

tab diff_street
tab diff_address
tab diffstr_out4number
save "$dta\pointcheck_norwalk.dta",replace
count if PropertyStreetNum!=.
count if diff_address==1&PropertyStreetNum!=.


***************************************
*   Fix-Creat the list to be fixed    *
***************************************
use "$dta\pointcheck_easthaven.dta",clear
append using "$dta\pointcheck_fairfield.dta"
append using "$dta\pointcheck_clinton.dta"
append using "$dta\pointcheck_groton.dta"
append using "$dta\pointcheck_oldlyme.dta"
append using "$dta\pointcheck_oldsaybrook.dta"
append using "$dta\pointcheck_milford.dta"
append using "$dta\pointcheck_stonington.dta"
append using "$dta\pointcheck_westbrook.dta"
append using "$dta\pointcheck_newlondoneastlyme.dta"
append using "$dta\pointcheck_branford.dta"
append using "$dta\pointcheck_guilford.dta"
append using "$dta\pointcheck_madison.dta"
append using "$dta\pointcheck_newhaven.dta"
append using "$dta\pointcheck_westhaven.dta"
append using "$dta\pointcheck_bridgeport.dta"
append using "$dta\pointcheck_stratford.dta"
append using "$dta\pointcheck_westport.dta"
*Add more later

keep if diff_address==1
keep FID PropertyFullStreetAddress PropertyStreet PropertyStreetNum PropertyCity ImportParcelID latGoogle longGoogle diff_street diff_address
drop if PropertyStreetNum==.
tab PropertyCity
save "$dta\Ggl_points_toberevised1.dta",replace

use "$dta\pointcheck_waterford.dta",clear
append using "$dta\pointcheck_norwalk.dta"
*append using "$dta\pointcheck_.dta"
keep if diff_address==1
keep FID PropertyFullStreetAddress PropertyStreet PropertyStreetNum PropertyCity ImportParcelID latGoogle longGoogle diff_street diff_address
drop if PropertyStreetNum==.
tab PropertyCity
save "$dta\Ggl_points_toberevised2.dta",replace


use "$dta\pointcheck_easthaven.dta",clear
append using "$dta\pointcheck_fairfield.dta"
append using "$dta\pointcheck_clinton.dta"
append using "$dta\pointcheck_groton.dta"
append using "$dta\pointcheck_oldlyme.dta"
append using "$dta\pointcheck_oldsaybrook.dta"
append using "$dta\pointcheck_milford.dta"
append using "$dta\pointcheck_stonington.dta"
append using "$dta\pointcheck_westbrook.dta"
append using "$dta\pointcheck_newlondoneastlyme.dta"
append using "$dta\pointcheck_branford.dta"
append using "$dta\pointcheck_guilford.dta"
append using "$dta\pointcheck_madison.dta"
append using "$dta\pointcheck_newhaven.dta"
append using "$dta\pointcheck_westhaven.dta"
append using "$dta\pointcheck_bridgeport.dta"
append using "$dta\pointcheck_stratford.dta"
append using "$dta\pointcheck_westport.dta"
append using "$dta\pointcheck_waterford.dta"
append using "$dta\pointcheck_norwalk.dta"
*Add more later

keep if diff_address==1
keep FID PropertyFullStreetAddress PropertyStreet PropertyStreetNum PropertyCity ImportParcelID latGoogle longGoogle diff_street diff_address
drop if PropertyStreetNum==.
tab PropertyCity
replace PropertyCity=upper(PropertyCity)
save "$dta\Ggl_points_toberevised.dta",replace
**********************************************************
*   Fix-Select the set of buildings to be used to fix    *
**********************************************************
************East Haven****************
use "$GIS\buildingwadd_easthaven.dta",clear
keep fid_build orig_fid location street muni


replace location=subinstr(location,"TERR","TER",1)
replace street=subinstr(street,"TERR","TER",1)

replace location=subinstr(location,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)
replace street=subinstr(street,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)

replace location=subinstr(location,"PALMETTO TR","PALMETTO TRL",1)
replace street=subinstr(street,"PALMETTO TR","PALMETTO TRL",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)
replace street=subinstr(street,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)

replace location=subinstr(location,"COLD SPRING ST","COLD SPRING AVE",1)
replace street=subinstr(street,"COLD SPRING ST","COLD SPRING AVE",1)

replace location=subinstr(location,"SENECA TR","SENECA TRL",1)
replace street=subinstr(street,"SENECA TR","SENECA TRL",1)

replace location=subinstr(location,"WHITMAN AVE","WHITMAN ST",1)
replace street=subinstr(street,"WHITMAN AVE","WHITMAN ST",1)

replace location=subinstr(location,"ATWATER ST EXT","ATWATER STREET EXT",1)
replace street=subinstr(street,"ATWATER ST EXT","ATWATER STREET EXT",1)

replace location=subinstr(location,"WHALERS POINT RD","WHALERS PT",1)
replace street=subinstr(street,"WHALERS POINT RD","WHALERS PT",1)

replace location=subinstr(location,"NORTH ATWATER ST","N ATWATER ST",1)
replace street=subinstr(street,"NORTH ATWATER ST","N ATWATER ST",1)

replace location=subinstr(location,"ELLIOTT ST","ELLIOT ST",1)
replace street=subinstr(street,"ELLIOTT ST","ELLIOT ST",1)

replace location=subinstr(location,"PISCITELLI CIR","PISCETELLI CIR",1)
replace street=subinstr(street,"PISCITELLI CIR","PISCETELLI CIR",1)

replace location=subinstr(location,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)
replace street=subinstr(street,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
ren muni PropertyCity
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="EAST HAVEN"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build PropertyFullStreetAddress PropertyCity,force

duplicates tag fid_build,gen(dup1)
drop if trim(PropertyFullStreetAddress)==""&dup1>=1
drop if trim(PropertyFullStreetAddress)=="45 MANSFIELD GROVE RD"&dup1>=1
duplicates drop fid_build if fid_build!=.,force
duplicates report fid_build
drop dup1
drop _merge
save "$dta\buildingsGgl_easthaven_revise.dta",replace
duplicates drop PropertyFullStreetAddress,force
tab revise
*317 revised add for East Haven


************Fairfield****************
use "$GIS\buildingwadd_fairfield.dta",clear
ren address location 
gen firstblankpos_loc=ustrpos(location," ",2)
gen street=substr(location,firstblankpos_loc+1,.)
replace street=trim(street)

gen PropertyCity="FAIRFIELD"
keep fid_build orig_fid location street PropertyCity

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="FAIRFIELD"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_fairfield_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*111 add revised for Fairfield

************Clinton****************
use "$GIS\buildingwadd_clinton.dta",clear
ren streetaddr location
ren streetname street
gen PropertyCity="CLINTON"
keep fid_build orig_fid location street PropertyCity

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"SOLS PT RD","SOLS POINT RD",1)
replace street=subinstr(street,"SOLS PT RD","SOLS POINT RD",1)

replace location=subinstr(location,"WEST LOOP RD","W LOOP RD",1)
replace street=subinstr(street,"WEST LOOP RD","W LOOP RD",1)

replace location=subinstr(location,"EAST LOOP RD","E LOOP RD",1)
replace street=subinstr(street,"EAST LOOP RD","E LOOP RD",1)

replace location=subinstr(location,"SHORE RD #A31","SHORE RD",1)
replace street=subinstr(street,"SHORE RD #A31","SHORE RD",1)

replace location=subinstr(location,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)
replace street=subinstr(street,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)

replace location=subinstr(location,"GROVE WAY","GROVEWAY",1)
replace street=subinstr(street,"GROVE WAY","GROVEWAY",1)

replace location=subinstr(location,"OSPREY COMMONS","OSPREY CMNS",1)
replace street=subinstr(street,"OSPREY COMMONS","OSPREY CMNS",1)

replace location=subinstr(location,"FISK AVE & COMMERCE ST","FISK AVE",1)
replace street=subinstr(street,"FISK AVE & COMMERCE ST","FISK AVE",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"MORGAN PK","MORGAN PARK",1)
replace street=subinstr(street,"MORGAN PK","MORGAN PARK",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="CLINTON"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_clinton_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*946 add revised for Clinton

************Groton****************
use "$GIS\buildingwadd_groton.dta",clear
ren property_l location
gen firstblankpos_loc=ustrpos(location," ",2)
gen street=substr(location,firstblankpos_loc+1,.)
replace street=trim(street)

gen PropertyCity="GROTON"
keep fid_build orig_fid location street PropertyCity

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

*Groton specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location," HEIGHTS"," HTS",1)
replace street=subinstr(street," HEIGHTS"," HTS",1)

replace location=subinstr(location," (GLP)","",1)
replace street=subinstr(street," (GLP)","",1)

replace location=subinstr(location," (MYSTIC)","",1)
replace street=subinstr(street," (MYSTIC)","",1)

replace location=subinstr(location," (OLD MYSTIC)","",1)
replace street=subinstr(street," (OLD MYSTIC)","",1)

replace location=subinstr(location," (NOANK)","",1)
replace street=subinstr(street," (NOANK)","",1)

replace location=subinstr(location," (CITY)","",1)
replace street=subinstr(street," (CITY)","",1)

replace location=subinstr(location,"CIR AVE","CIRCLE AVE",1)
replace street=subinstr(street,"CIR AVE","CIRCLE AVE",1)

replace location=subinstr(location,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)
replace street=subinstr(street,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)

replace location=subinstr(location,"EAST SHORE AVE","E SHORE AVE",1)
replace street=subinstr(street,"EAST SHORE AVE","E SHORE AVE",1)

replace location=subinstr(location,"EASTERN PT RD","EASTERN POINT RD",1)
replace street=subinstr(street,"EASTERN PT RD","EASTERN POINT RD",1)

replace location=subinstr(location,"ELDREDGE ST","ELDRIDGE ST",1)
replace street=subinstr(street,"ELDREDGE ST","ELDRIDGE ST",1)

replace location=subinstr(location,"ELM ST SOUTH","ELM ST S",1)
replace street=subinstr(street,"ELM ST SOUTH","ELM ST S",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"GROTON LONG PT RD","GROTON LONG POINT RD",1)
replace street=subinstr(street,"GROTON LONG PT RD","GROTON LONG POINT RD",1)

replace location=subinstr(location,"HALEY CRESCENT","HALEY CRES",1)
replace street=subinstr(street,"HALEY CRESCENT","HALEY CRES",1)

replace location=subinstr(location,"HYROCK TERR","HYROCK TER",1)
replace street=subinstr(street,"HYROCK TERR","HYROCK TER",1)

replace location=subinstr(location,"ISLAND CIR NORTH","ISLAND CIR N",1)
replace street=subinstr(street,"ISLAND CIR NORTH","ISLAND CIR N",1)

replace location=subinstr(location,"ISLAND CIR SOUTH","ISLAND CIR S",1)
replace street=subinstr(street,"ISLAND CIR SOUTH","ISLAND CIR S",1)

replace location=subinstr(location,"JUPITER PT RD","JUPITER POINT RD",1)
replace street=subinstr(street,"JUPITER PT RD","JUPITER POINT RD",1)

replace location=subinstr(location,"NORTH PROSPECT ST","N PROSPECT ST",1)
replace street=subinstr(street,"NORTH PROSPECT ST","N PROSPECT ST",1)

replace location=subinstr(location,"ORCHARD LN","ORCHARD ST",1)
replace street=subinstr(street,"ORCHARD LN","ORCHARD ST",1)

replace location=subinstr(location,"PALMERS COVE DR","PALMERS COVE RD",1)
replace street=subinstr(street,"PALMERS COVE DR","PALMERS COVE RD",1)

replace location=subinstr(location,"POTTER CT","POTTER ST",1)
replace street=subinstr(street,"POTTER CT","POTTER ST",1)

replace location=subinstr(location,"SOUND VIEW RD","SOUNDVIEW RD",1)
replace street=subinstr(street,"SOUND VIEW RD","SOUNDVIEW RD",1)

replace location=subinstr(location,"SOUTH PROSPECT ST","S PROSPECT ST",1)
replace street=subinstr(street,"SOUTH PROSPECT ST","S PROSPECT ST",1)

replace location=subinstr(location,"SOUTH SHORE AVE","S SHORE AVE",1)
replace street=subinstr(street,"SOUTH SHORE AVE","S SHORE AVE",1)

replace location=subinstr(location,"ST JOSEPH CT","SAINT JOSEPH CT",1)
replace street=subinstr(street,"ST JOSEPH CT","SAINT JOSEPH CT",1)

replace location=subinstr(location,"ST PAUL CT","SAINT PAUL CT",1)
replace street=subinstr(street,"ST PAUL CT","SAINT PAUL CT",1)

replace location=subinstr(location,"STRIBL LN","STRIBLE LN",1)
replace street=subinstr(street,"STRIBL LN","STRIBLE LN",1)

replace location=subinstr(location,"TER AVE","TERRACE AVE",1)
replace street=subinstr(street,"TER AVE","TERRACE AVE",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST MYSTIC AVE","W MYSTIC AVE",1)
replace street=subinstr(street,"WEST MYSTIC AVE","W MYSTIC AVE",1)

replace location=subinstr(location,"WEST SHORE AVE","W SHORE AVE",1)
replace street=subinstr(street,"WEST SHORE AVE","W SHORE AVE",1)

replace location=subinstr(location,"WESTVIEW AVE","W VIEW AVE",1)
replace street=subinstr(street,"WESTVIEW AVE","W VIEW AVE",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
drop if _merge==2
replace PropertyCity="MYSTIC" if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta",update
gen revise=(_merge==3|_merge==4|_merge==5)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="GROTON"
*13 updated
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_groton_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*97 add revised for Groton


**************OldLyme**************
use "$GIS\buildingwadd_oldlyme.dta",clear
ren streetaddr location
ren streetname street
gen PropertyCity="OLD LYME"

keep fid_build orig_fid location street PropertyCity

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

*Old Lyme specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"DORY LNNDING","DORY LNDG",1)
replace street=subinstr(street,"DORY LNNDING","DORY LNDG",1)
/*
replace location=subinstr(location,"HARTFORD AVE","HARTFORD AVE EXT",1)
replace street=subinstr(street,"HARTFORD AVE","HARTFORD AVE EXT",1)
*/
replace location=subinstr(location,"HATCHETTS PT RD","HATCHETT POINT RD",1)
replace street=subinstr(street,"HATCHETTS PT RD","HATCHETT POINT RD",1)

replace location=subinstr(location,"JOFFRE RD WEST","JOFFRE RD W",1)
replace street=subinstr(street,"JOFFRE RD WEST","JOFFRE RD W",1)

replace location=subinstr(location,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)
replace street=subinstr(street,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)

replace location=subinstr(location,"MEETING HOUSE LN","MEETINGHOUSE LN",1)
replace street=subinstr(street,"MEETING HOUSE LN","MEETINGHOUSE LN",1)

/*
replace location=subinstr(location,"PORTLAND AVE","PORTLAND AVENUE EXT",1)
replace street=subinstr(street,"PORTLAND AVE","PORTLAND AVENUE EXT",1)
*/
replace location=subinstr(location,"RIVERDALE LNNDING","RIVERDALE LDG",1)
replace street=subinstr(street,"RIVERDALE LNNDING","RIVERDALE LDG",1)

replace location=subinstr(location,"ROBBINS AVE","ROBBIN AVE",1)
replace street=subinstr(street,"ROBBINS AVE","ROBBIN AVE",1)

replace location=subinstr(location,"SANDPIPER PT RD","SANDPIPER POINT RD",1)
replace street=subinstr(street,"SANDPIPER PT RD","SANDPIPER POINT RD",1)

replace location=subinstr(location,"SEA VIEW RD","SEAVIEW RD",1)
replace street=subinstr(street,"SEA VIEW RD","SEAVIEW RD",1)

replace location=subinstr(location,"WEST END DR","W END DR",1)
replace street=subinstr(street,"WEST END DR","W END DR",1)

replace location=subinstr(location,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)
replace street=subinstr(street,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="OLD LYME"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_oldlyme_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*204 add revised for Old Lyme


************Old Saybrook****************
use "$GIS\buildingwadd_oldsaybrook.dta",clear
ren streetaddr location
ren streetname street
gen PropertyCity="OLD SAYBROOK"
keep fid_build orig_fid location street PropertyCity


replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Old Saybrook specific
replace location=subinstr(location,"AQUATERRA LA","AQUA TERRA LN",1)
replace street=subinstr(street,"AQUATERRA LA","AQUA TERRA LN",1)

replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AQUATERRA","AQUA TERRA",1)
replace street=subinstr(street,"AQUATERRA","AQUA TERRA",1)

replace location=subinstr(location,"BARNES RD SOUTH","BARNES RD S",1)
replace street=subinstr(street,"BARNES RD SOUTH","BARNES RD S",1)

replace location=subinstr(location,"BAY VIEW AVE","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW AVE","BAYVIEW RD",1)

replace location=subinstr(location,"BEACH RD EAST","BEACH RD E",1)
replace street=subinstr(street,"BEACH RD EAST","BEACH RD E",1)

replace location=subinstr(location,"BEACH RD WEST","BEACH RD W",1)
replace street=subinstr(street,"BEACH RD WEST","BEACH RD W",1)

replace location=subinstr(location,"BEACH VIEW ST","BEACH VIEW AVE",1)
replace street=subinstr(street,"BEACH VIEW ST","BEACH VIEW AVE",1)

replace location=subinstr(location,"BELAIRE DR","BELAIRE MNR",1)
replace street=subinstr(street,"BELAIRE DR","BELAIRE MNR",1)

replace location=subinstr(location,"BELLEAIRE DR","BELLAIRE DR",1)
replace street=subinstr(street,"BELLEAIRE DR","BELLAIRE DR",1)

replace location=subinstr(location,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)
replace street=subinstr(street,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)

replace location=subinstr(location,"BROOKE ST","BROOK ST",1)
replace street=subinstr(street,"BROOKE ST","BROOK ST",1)

replace location=subinstr(location,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)
replace street=subinstr(street,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)

replace location=subinstr(location,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)
replace street=subinstr(street,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)

replace location=subinstr(location,"COVE LNNDING","COVE LNDG",1)
replace street=subinstr(street,"COVE LNNDING","COVE LNDG",1)

replace location=subinstr(location,"CRANTON ST","CRANTON AVE",1)
replace street=subinstr(street,"CRANTON ST","CRANTON AVE",1)

replace location=subinstr(location,"CRICKETCT","CRICKET CT",1)
replace street=subinstr(street,"CRICKETCT","CRICKET CT",1)

replace location=subinstr(location,"CROMWELLCT","CROMWELL CT",1)
replace street=subinstr(street,"CROMWELLCT","CROMWELL CT",1)

replace location=subinstr(location,"CROMWELLCT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELLCT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"CROMWELL CT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELL CT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"FENCOVECT","FENCOVE CT",1)
replace street=subinstr(street,"FENCOVECT","FENCOVE CT",1)

replace location=subinstr(location,"FERRY PL","FERRY RD",1)
replace street=subinstr(street,"FERRY PL","FERRY RD",1)

replace location=subinstr(location,"JAMESCT","JAMES CT",1)
replace street=subinstr(street,"JAMESCT","JAMES CT",1)

replace location=subinstr(location,"LONDONCT","LONDON CT",1)
replace street=subinstr(street,"LONDONCT","LONDON CT",1)

replace location=subinstr(location,"MAPLECT","MAPLE CT",1)
replace street=subinstr(street,"MAPLECT","MAPLE CT",1)

replace location=subinstr(location,"MAYCT","MAY CT",1)
replace street=subinstr(street,"MAYCT","MAY CT",1)

replace location=subinstr(location,"MILL ROCK RD EAST","MILL ROCK RD E",1)
replace street=subinstr(street,"MILL ROCK RD EAST","MILL ROCK RD E",1)

replace location=subinstr(location,"NORTH COVE CIR","N COVE CIR",1)
replace street=subinstr(street,"NORTH COVE CIR","N COVE CIR",1)

replace location=subinstr(location,"NORTH COVE RD","N COVE RD",1)
replace street=subinstr(street,"NORTH COVE RD","N COVE RD",1)

replace location=subinstr(location,"OYSTER PT AVE EAST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE EAST","OYSTER POINT RD",1)

replace location=subinstr(location,"OYSTER PT AVE WEST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE WEST","OYSTER POINT RD",1)

replace location=subinstr(location,"PARKCROFTERS LN","PARK CROFTERS LN",1)
replace street=subinstr(street,"PARKCROFTERS LN","PARK CROFTERS LN",1)

replace location=subinstr(location,"PT RD","POINT RD",1)
replace street=subinstr(street,"PT RD","POINT RD",1)

replace location=subinstr(location,"REEDCT","REED CT",1)
replace street=subinstr(street,"REEDCT","REED CT",1)

replace location=subinstr(location,"RIVER ST WEST","RIVER ST W",1)
replace street=subinstr(street,"RIVER ST WEST","RIVER ST W",1)

replace location=subinstr(location,"SEA BREEZE RD","SEABREEZE RD",1)
replace street=subinstr(street,"SEA BREEZE RD","SEABREEZE RD",1)

replace location=subinstr(location,"SEA CREST RD","SEACREST RD",1)
replace street=subinstr(street,"SEA CREST RD","SEACREST RD",1)

replace location=subinstr(location,"SEA GULL RD","SEAGULL RD",1)
replace street=subinstr(street,"SEA GULL RD","SEAGULL RD",1)

replace location=subinstr(location,"SEA LN-1","SEA LN",1)
replace street=subinstr(street,"SEA LN-1","SEA LN",1)

replace location=subinstr(location,"SEA LN-2","SEA LN",1)
replace street=subinstr(street,"SEA LN-2","SEA LN",1)

replace location=subinstr(location,"SEAVIEW AVE","SEA VIEW AVE",1)
replace street=subinstr(street,"SEAVIEW AVE","SEA VIEW AVE",1)

replace location=subinstr(location,"SHADY RUN AVE","SHADY RUN",1)
replace street=subinstr(street,"SHADY RUN AVE","SHADY RUN",1)

replace location=subinstr(location,"SHORE AVE-2","SHORE AVE",1)
replace street=subinstr(street,"SHORE AVE-2","SHORE AVE",1)

replace location=subinstr(location,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)
replace street=subinstr(street,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)

replace location=subinstr(location,"SOUTH COVE RD-1","S COVE RD",1)
replace street=subinstr(street,"SOUTH COVE RD-1","S COVE RD",1)

replace location=subinstr(location,"SOUTH VIEW CIR","S VIEW CIR",1)
replace street=subinstr(street,"SOUTH VIEW CIR","S VIEW CIR",1)

replace location=subinstr(location,"TUDORCT EAST","TUDOR CT E",1)
replace street=subinstr(street,"TUDORCT EAST","TUDOR CT E",1)

replace location=subinstr(location,"TUDORCT WEST","TUDOR CT W",1)
replace street=subinstr(street,"TUDORCT WEST","TUDOR CT W",1)

replace location=subinstr(location,"WEST SHORE DR","W SHORE DR",1)
replace street=subinstr(street,"WEST SHORE DR","W SHORE DR",1)

replace location=subinstr(location,"WEST VIEW RD","W VIEW RD",1)
replace street=subinstr(street,"WEST VIEW RD","W VIEW RD",1)

replace location=subinstr(location,"WINDSORCT WEST","WINDSOR CT",1)
replace street=subinstr(street,"WINDSORCT WEST","WINDSOR CT",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="OLD SAYBROOK"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_oldsaybrook_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*251 add revised for Old Saybrook

************Milford****************
use "$GIS\buildingwadd_milford.dta",clear

ren muni PropertyCity
keep fid_build orig_fid location street PropertyCity


replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Milford specific
replace location=subinstr(location,"BAYSHORE DR EXT","BAYSHORE DR",1)
replace street=subinstr(street,"BAYSHORE DR EXT","BAYSHORE DR",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY","BROADWAY",1)
replace street=subinstr(street,"BRDWAY","BROADWAY",1)

replace location=subinstr(location,"DEVOLL ST","DEVOL ST",1)
replace street=subinstr(street,"DEVOLL ST","DEVOL ST",1)

replace location=subinstr(location,"DOCK LN","DOCK RD",1)
replace street=subinstr(street,"DOCK LN","DOCK RD",1)

replace location=subinstr(location,"EAST BRDWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BRDWAY","E BROADWAY",1)

replace location=subinstr(location,"EAST BROADWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BROADWAY","E BROADWAY",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"ETTADORE PKWY","ETTADORE PARK",1)
replace street=subinstr(street,"ETTADORE PKWY","ETTADORE PARK",1)

replace location=subinstr(location,"FENWAY NORTH","FENWAY ST N",1)
replace street=subinstr(street,"FENWAY NORTH","FENWAY ST N",1)

replace location=subinstr(location,"FENWAY SOUTH","FENWAY ST S",1)
replace street=subinstr(street,"FENWAY SOUTH","FENWAY ST S",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HILLTOP CIR EAST","HILLTOP CIR E",1)
replace street=subinstr(street,"HILLTOP CIR EAST","HILLTOP CIR E",1)

replace location=subinstr(location,"KINLOCH ST","KINLOCK ST",1)
replace street=subinstr(street,"KINLOCH ST","KINLOCK ST",1)

replace location=subinstr(location,"KINLOCH TER","KINLOCK TER",1)
replace street=subinstr(street,"KINLOCH TER","KINLOCK TER",1)

replace location=subinstr(location,"MANILA AVE","MANILLA AVE",1)
replace street=subinstr(street,"MANILA AVE","MANILLA AVE",1)

replace location=subinstr(location,"MILFORD PT RD","MILFORD POINT RD",1)
replace street=subinstr(street,"MILFORD PT RD","MILFORD POINT RD",1)

replace location=subinstr(location,"MINUTE MAN DR","MINUTEMAN DR",1)
replace street=subinstr(street,"MINUTE MAN DR","MINUTEMAN DR",1)

replace location=subinstr(location,"NORTHMOOR RD","NORTHMOOR ST",1)
replace street=subinstr(street,"NORTHMOOR RD","NORTHMOOR ST",1)

replace location=subinstr(location,"OAKDALE AVE","OAKDALE ST",1)
replace street=subinstr(street,"OAKDALE AVE","OAKDALE ST",1)

replace location=subinstr(location,"OLD PT RD","OLD POINT RD",1)
replace street=subinstr(street,"OLD PT RD","OLD POINT RD",1)

replace location=subinstr(location,"PHELAN PARK DR","PHELAN PARK",1)
replace street=subinstr(street,"PHELAN PARK DR","PHELAN PARK",1)

replace location=subinstr(location,"PT BEACH DR","POINT BEACH DR",1)
replace street=subinstr(street,"PT BEACH DR","POINT BEACH DR",1)

replace location=subinstr(location,"PT LOOKOUT","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT","POINT LOOKOUT",1)

replace location=subinstr(location,"PT LOOKOUT EAST","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT EAST","POINT LOOKOUT",1)

replace location=subinstr(location,"POND PT AVE","POND POINT AVE",1)
replace street=subinstr(street,"POND PT AVE","POND POINT AVE",1)

replace location=subinstr(location,"RIVEREDGE DR","RIVEREDGE ST",1)
replace street=subinstr(street,"RIVEREDGE DR","RIVEREDGE ST",1)

replace location=subinstr(location,"SEA FLOWER RD","SEAFLOWER RD",1)
replace street=subinstr(street,"SEA FLOWER RD","SEAFLOWER RD",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SMITHS PT RD","SMITHS POINT RD",1)
replace street=subinstr(street,"SMITHS PT RD","SMITHS POINT RD",1)

replace location=subinstr(location,"SNOW APPLE LN","SNOWAPPLE LN",1)
replace street=subinstr(street,"SNOW APPLE LN","SNOWAPPLE LN",1)

replace location=subinstr(location,"SPARROW BUSH LN","SPARROWBUSH LN",1)
replace street=subinstr(street,"SPARROW BUSH LN","SPARROWBUSH LN",1)

replace location=subinstr(location,"TER RD","TERRACE RD",1)
replace street=subinstr(street,"TER RD","TERRACE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WELCHS PT RD","WELCHS POINT RD",1)
replace street=subinstr(street,"WELCHS PT RD","WELCHS POINT RD",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST ORLAND ST","W ORLAND ST",1)
replace street=subinstr(street,"WEST ORLAND ST","W ORLAND ST",1)

replace location=subinstr(location,"WEST RIVER ST","W RIVER ST",1)
replace street=subinstr(street,"WEST RIVER ST","W RIVER ST",1)

replace location=subinstr(location,"WEST TOWN ST","W TOWN ST",1)
replace street=subinstr(street,"WEST TOWN ST","W TOWN ST",1)

replace location=subinstr(location,"ASTERRACE RD","ASTER RD",1)
replace street=subinstr(street,"ASTERRACE RD","ASTER RD",1)

replace location=subinstr(location,"BREWSTERRACE RD","BREWSTER RD",1)
replace street=subinstr(street,"BREWSTERRACE RD","BREWSTER RD",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="MILFORD"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_milford_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*61 add revised for Milford

************Stonington****************
use "$GIS\buildingwadd_stonington.dta",clear

ren muni PropertyCity
replace PropertyCity="STONINGTON"
keep fid_build orig_fid location street PropertyCity


replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Stonington specific
replace location=subinstr(location,"ALLYNS ALLEY","ALLYNS ALY",1)
replace street=subinstr(street,"ALLYNS ALLEY","ALLYNS ALY",1)

replace location=subinstr(location,"BAYBERRY LA","BAYBERRY LN",1)
replace street=subinstr(street,"BAYBERRY LA","BAYBERRY LN",1)

replace location=subinstr(location,"BOULDER AVE EXT","BOULDER AVE",1)
replace street=subinstr(street,"BOULDER AVE EXT","BOULDER AVE",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY AVE","BROADWAY AVE",1)
replace street=subinstr(street,"BRDWAY AVE","BROADWAY AVE",1)

replace location=subinstr(location,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)
replace street=subinstr(street,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)

replace location=subinstr(location,"CHAPMAN LA","CHAPMAN LN",1)
replace street=subinstr(street,"CHAPMAN LA","CHAPMAN LN",1)

replace location=subinstr(location,"CHESEBRO LA","CHESEBRO LN",1)
replace street=subinstr(street,"CHESEBRO LA","CHESEBRO LN",1)

replace location=subinstr(location,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)
replace street=subinstr(street,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)

replace location=subinstr(location,"CHURCH ST M","CHURCH ST",1)
replace street=subinstr(street,"CHURCH ST M","CHURCH ST",1)

replace location=subinstr(location,"DENISON AVE M","DENISON AVE",1)
replace street=subinstr(street,"DENISON AVE M","DENISON AVE",1)

replace location=subinstr(location,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)
replace street=subinstr(street,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)

replace location=subinstr(location,"ENSIGN LA","ENSIGN LN",1)
replace street=subinstr(street,"ENSIGN LA","ENSIGN LN",1)

replace location=subinstr(location,"LAMBERTS LA","LAMBERTS LN",1)
replace street=subinstr(street,"LAMBERTS LA","LAMBERTS LN",1)

replace location=subinstr(location,"LATIMER PT RD","LATIMER POINT RD",1)
replace street=subinstr(street,"LATIMER PT RD","LATIMER POINT RD",1)

replace location=subinstr(location,"LHIRONDELLE LA","LHIRONDELLE LN",1)
replace street=subinstr(street,"LHIRONDELLE LA","LHIRONDELLE LN",1)

replace location=subinstr(location,"LINDEN LA","LINDEN LN",1)
replace street=subinstr(street,"LINDEN LA","LINDEN LN",1)

replace location=subinstr(location,"LONG WHARF RD","LONG WHARF DR",1)
replace street=subinstr(street,"LONG WHARF RD","LONG WHARF DR",1)

replace location=subinstr(location,"MAPLE ST LP","MAPLE ST",1)
replace street=subinstr(street,"MAPLE ST LP","MAPLE ST",1)

replace location=subinstr(location,"MAPLEWOOD LA","MAPLEWOOD LN",1)
replace street=subinstr(street,"MAPLEWOOD LA","MAPLEWOOD LN",1)

replace location=subinstr(location,"MEADOWBROOK LA","MEADOWBROOK LN",1)
replace street=subinstr(street,"MEADOWBROOK LA","MEADOWBROOK LN",1)

replace location=subinstr(location,"MEADOWLARK LA","MEADOW LARK LN",1)
replace street=subinstr(street,"MEADOWLARK LA","MEADOW LARK LN",1)

replace location=subinstr(location,"MONEY PT RD","MONEY POINT RD",1)
replace street=subinstr(street,"MONEY PT RD","MONEY POINT RD",1)

replace location=subinstr(location,"MYSTIC HILL","MYSTIC HILL RD",1)
replace street=subinstr(street,"MYSTIC HILL","MYSTIC HILL RD",1)

replace location=subinstr(location,"NAUYAUG N","NAUYAUG RD N",1)
replace street=subinstr(street,"NAUYAUG N","NAUYAUG RD N",1)

replace location=subinstr(location,"NAUYAUG PT RD","NAUYAUG POINT RD",1)
replace street=subinstr(street,"NAUYAUG PT RD","NAUYAUG POINT RD",1)

replace location=subinstr(location,"NOYES AVE LP","NOYES AVE",1)
replace street=subinstr(street,"NOYES AVE LP","NOYES AVE",1)

replace location=subinstr(location,"PLOVER LA","PLOVER LN",1)
replace street=subinstr(street,"PLOVER LA","PLOVER LN",1)

replace location=subinstr(location,"RICHMOND LA M","RICHMOND LN",1)
replace street=subinstr(street,"RICHMOND LA M","RICHMOND LN",1)

replace location=subinstr(location,"ROSE LA","ROSE LN",1)
replace street=subinstr(street,"ROSE LA","ROSE LN",1)

replace location=subinstr(location,"SCHOOL ST M","SCHOOL ST",1)
replace street=subinstr(street,"SCHOOL ST M","SCHOOL ST",1)

replace location=subinstr(location,"SEAGULL LA","SEAGULL LN",1)
replace street=subinstr(street,"SEAGULL LA","SEAGULL LN",1)

replace location=subinstr(location,"SUMMIT ST M","SUMMIT ST",1)
replace street=subinstr(street,"SUMMIT ST M","SUMMIT ST",1)

replace location=subinstr(location,"SURREY LA","SURREY LN",1)
replace street=subinstr(street,"SURREY LA","SURREY LN",1)

replace location=subinstr(location,"WILBUR HILL LA","WILBUR HILL LN",1)
replace street=subinstr(street,"WILBUR HILL LA","WILBUR HILL LN",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="STONINGTON"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_stonington_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*157 add revised for Stonington

************Westbrook****************
use "$GIS\buildingwadd_westbrook.dta",clear

ren streetaddr location
ren streetname street
gen PropertyCity="WESTBROOK"
keep fid_build orig_fid location street PropertyCity


replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Westbrook specific
replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"AVE B","AVENUE B",1)
replace street=subinstr(street,"AVE B","AVENUE B",1)

replace location=subinstr(location,"AVE C","AVENUE C",1)
replace street=subinstr(street,"AVE C","AVENUE C",1)

replace location=subinstr(location,"BRDWAY N","BROADWAY N",1)
replace street=subinstr(street,"BRDWAY N","BROADWAY N",1)

replace location=subinstr(location,"BRDWAY S","BROADWAY S",1)
replace street=subinstr(street,"BRDWAY S","BROADWAY S",1)

replace location=subinstr(location,"CHAPMAN AVE","CHAPMAN DR",1)
replace street=subinstr(street,"CHAPMAN AVE","CHAPMAN DR",1)

replace location=subinstr(location,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)
replace street=subinstr(street,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)

replace location=subinstr(location,"E Z ST","EZ ST",1)
replace street=subinstr(street,"E Z ST","EZ ST",1)

replace location=subinstr(location,"JAKOBS LANDING","JAKOBS LNDG",1)
replace street=subinstr(street,"JAKOBS LANDING","JAKOBS LNDG",1)

replace location=subinstr(location,"LYNNE AVE EXT","LYNNE AVE",1)
replace street=subinstr(street,"LYNNE AVE EXT","LYNNE AVE",1)

replace location=subinstr(location,"MCDONALD DR","MACDONALD DR",1)
replace street=subinstr(street,"MCDONALD DR","MACDONALD DR",1)

replace location=subinstr(location,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)
replace street=subinstr(street,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)

replace location=subinstr(location,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)
replace street=subinstr(street,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)

replace location=subinstr(location,"MOHICAN RD E","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD E","MOHICAN RD",1)

replace location=subinstr(location,"MOHICAN RD W","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD W","MOHICAN RD",1)

replace location=subinstr(location,"MULLER AVE","MULLER DR",1)
replace street=subinstr(street,"MULLER AVE","MULLER DR",1)

replace location=subinstr(location,"OAK VALE RD","OAKVALE RD",1)
replace street=subinstr(street,"OAK VALE RD","OAKVALE RD",1)

replace location=subinstr(location,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)
replace street=subinstr(street,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)

replace location=subinstr(location,"PILOTS PT DR","PILOTS POINT DR",1)
replace street=subinstr(street,"PILOTS PT DR","PILOTS POINT DR",1)

replace location=subinstr(location,"PTINA RD","POINTINA RD",1)
replace street=subinstr(street,"PTINA RD","POINTINA RD",1)

replace location=subinstr(location,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)
replace street=subinstr(street,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)

replace location=subinstr(location,"SAGAMORE TER RD E","SAGAMORE TER E",1)
replace street=subinstr(street,"SAGAMORE TER RD E","SAGAMORE TER E",1)

replace location=subinstr(location,"SAGAMORE TER RD S","SAGAMORE TER S",1)
replace street=subinstr(street,"SAGAMORE TER RD S","SAGAMORE TER S",1)

replace location=subinstr(location,"SAGAMORE TER RD W","SAGAMORE TER W",1)
replace street=subinstr(street,"SAGAMORE TER RD W","SAGAMORE TER W",1)

replace location=subinstr(location,"SEASCAPE DR","SEA SCAPE DR",1)
replace street=subinstr(street,"SEASCAPE DR","SEA SCAPE DR",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"STONE HEDGE RD EXT","STONE HEDGE RD",1)
replace street=subinstr(street,"STONE HEDGE RD EXT","STONE HEDGE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"UNCAS RD W","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD W","UNCAS RD",1)

replace location=subinstr(location,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)
replace street=subinstr(street,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)

replace location=subinstr(location,"CHAPMAN DR","CHAPMAN AVE",1)
replace street=subinstr(street,"CHAPMAN DR","CHAPMAN AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)
replace street=subinstr(street,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 

merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="WESTBROOK"
duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force
drop _merge
save "$dta\buildingsGgl_westbrook_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*54 add revised for Westbrook

*Next wave includes New London, East Lyme, Branford, Guilford, Madison, New Haven, West Haven
****************************New London,East Lyme*********************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_newlondoneastlyme.dta",clear
duplicates report orig_fid

ren circatab_6 address_num
ren circatab_8 street
ren circatab_5 location


gen PropertyCity="EAST LYME"
keep fid_build orig_fid location street PropertyCity

duplicates tag fid_build,gen(dup1)
drop if trim(location)==""&dup1>=1
drop if trim(location)=="SPINNAKER"&dup1>=1
duplicates drop fid_build location,force
duplicates report fid_build
drop dup1

*EAST LYME
*NEW LONDON
*NIANTIC

replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*New London East Lyme specific
replace location=subinstr(location,"ALEWIFE PW","ALEWIFE PKWY",1)
replace street=subinstr(street,"ALEWIFE PW","ALEWIFE PKWY",1)

replace location=subinstr(location,"ARCADIAN RD GNB","ARCADIA RD",1)
replace street=subinstr(street,"ARCADIAN RD GNB","ARCADIA RD",1)

replace location=subinstr(location,"ATLANTIC ST CB","ATLANTIC ST",1)
replace street=subinstr(street,"ATLANTIC ST CB","ATLANTIC ST",1)

replace location=subinstr(location,"ATTAWAN AVE","ATTAWAN RD",1)
replace street=subinstr(street,"ATTAWAN AVE","ATTAWAN RD",1)

replace location=subinstr(location,"BARRETT DR OGBA","BARRETT DR",1)
replace street=subinstr(street,"BARRETT DR OGBA","BARRETT DR",1)

replace location=subinstr(location,"BAY VIEW RD GNH","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW RD GNH","BAYVIEW RD",1)

replace location=subinstr(location,"BAYVIEW AVE CB","BAYVIEW AVE",1)
replace street=subinstr(street,"BAYVIEW AVE CB","BAYVIEW AVE",1)

replace location=subinstr(location,"BEACH AVE CB","BEACH AVE",1)
replace street=subinstr(street,"BEACH AVE CB","BEACH AVE",1)

replace location=subinstr(location,"BELLAIRE RD BPBC","BELLAIRE RD",1)
replace street=subinstr(street,"BELLAIRE RD BPBC","BELLAIRE RD",1)

replace location=subinstr(location,"BILLOW RD BPBC","BILLOW RD",1)
replace street=subinstr(street,"BILLOW RD BPBC","BILLOW RD",1)

replace location=subinstr(location,"BLACK PT RD","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD","BLACK POINT RD",1)

replace location=subinstr(location,"BLACK PT RD CB","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD CB","BLACK POINT RD",1)

replace location=subinstr(location,"BOND ST BPBC","BOND ST",1)
replace street=subinstr(street,"BOND ST BPBC","BOND ST",1)

replace location=subinstr(location,"BRAINERD RD","BRAINARD RD",1)
replace street=subinstr(street,"BRAINERD RD","BRAINARD RD",1)

replace location=subinstr(location,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)
replace street=subinstr(street,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)

replace location=subinstr(location,"BROCKETT RD GNB","BROCKETT RD",1)
replace street=subinstr(street,"BROCKETT RD GNB","BROCKETT RD",1)

replace location=subinstr(location,"CARPENTER AVE CB","CARPENTER AVE",1)
replace street=subinstr(street,"CARPENTER AVE CB","CARPENTER AVE",1)

replace location=subinstr(location,"CENTRAL AVE CB","CENTRAL AVE",1)
replace street=subinstr(street,"CENTRAL AVE CB","CENTRAL AVE",1)

replace location=subinstr(location,"COLUMBUS AVE CB","COLUMBUS AVE",1)
replace street=subinstr(street,"COLUMBUS AVE CB","COLUMBUS AVE",1)

replace location=subinstr(location,"COTTAGE LN BPBC","COTTAGE LN",1)
replace street=subinstr(street,"COTTAGE LN BPBC","COTTAGE LN",1)

replace location=subinstr(location,"CRAB LN CB","CRAB LN",1)
replace street=subinstr(street,"CRAB LN CB","CRAB LN",1)

replace location=subinstr(location,"CRESCENT AVE CB","CRESCENT AVE",1)
replace street=subinstr(street,"CRESCENT AVE CB","CRESCENT AVE",1)

replace location=subinstr(location,"E SHORE DR BPBC","E SHORE DR",1)
replace street=subinstr(street,"E SHORE DR BPBC","E SHORE DR",1)

replace location=subinstr(location,"EDGE HILL RD GNH","EDGE HILL RD",1)
replace street=subinstr(street,"EDGE HILL RD GNH","EDGE HILL RD",1)

replace location=subinstr(location,"FULLER CT CB","FULLER CT",1)
replace street=subinstr(street,"FULLER CT CB","FULLER CT",1)

replace location=subinstr(location,"GLENWOOD PARK NO","GLENWOOD PARK N",1)
replace street=subinstr(street,"GLENWOOD PARK NO","GLENWOOD PARK N",1)

replace location=subinstr(location,"GLENWOOD PARK SO","GLENWOOD PARK S",1)
replace street=subinstr(street,"GLENWOOD PARK SO","GLENWOOD PARK S",1)

replace location=subinstr(location,"GRISWOLD DR GNH","GRISWOLD DR",1)
replace street=subinstr(street,"GRISWOLD DR GNH","GRISWOLD DR",1)

replace location=subinstr(location,"GRISWOLD RD GNB","GRISWOLD RD",1)
replace street=subinstr(street,"GRISWOLD RD GNB","GRISWOLD RD",1)

replace location=subinstr(location,"GROVE AVE CB","GROVE AVE",1)
replace street=subinstr(street,"GROVE AVE CB","GROVE AVE",1)

replace location=subinstr(location,"GROVEDALE RD GNB","GROVEDALE RD",1)
replace street=subinstr(street,"GROVEDALE RD GNB","GROVEDALE RD",1)

replace location=subinstr(location,"HILLCREST RD GNH","HILLCREST RD",1)
replace street=subinstr(street,"HILLCREST RD GNH","HILLCREST RD",1)

replace location=subinstr(location,"HILLSIDE AVE CB","HILLSIDE AVE",1)
replace street=subinstr(street,"HILLSIDE AVE CB","HILLSIDE AVE",1)

replace location=subinstr(location,"HILLTOP RD GNB","HILLTOP RD",1)
replace street=subinstr(street,"HILLTOP RD GNB","HILLTOP RD",1)

replace location=subinstr(location,"HOPE ST (REAR)","HOPE ST",1)
replace street=subinstr(street,"HOPE ST (REAR)","HOPE ST",1)

replace location=subinstr(location,"INDIAN ROCKS RD","INDIAN ROCK RD",1)
replace street=subinstr(street,"INDIAN ROCKS RD","INDIAN ROCK RD",1)

replace location=subinstr(location,"INDIANOLA RD BPBC","INDIANOLA RD",1)
replace street=subinstr(street,"INDIANOLA RD BPBC","INDIANOLA RD",1)

replace location=subinstr(location,"IRVING PL CB","IRVING PL",1)
replace street=subinstr(street,"IRVING PL CB","IRVING PL",1)

replace location=subinstr(location,"JO-ANNE ST","JO ANNE ST",1)
replace street=subinstr(street,"JO-ANNE ST","JO ANNE ST",1)

replace location=subinstr(location,"LAKE AVE EXT","LAKE AVENUE EXT",1)
replace street=subinstr(street,"LAKE AVE EXT","LAKE AVENUE EXT",1)

replace location=subinstr(location,"LAKE SHORE DR GNB","LAKE SHORE DR",1)
replace street=subinstr(street,"LAKE SHORE DR GNB","LAKE SHORE DR",1)

replace location=subinstr(location,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)
replace street=subinstr(street,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)

replace location=subinstr(location,"LEE FARM DR GNH","LEE FARM DR",1)
replace street=subinstr(street,"LEE FARM DR GNH","LEE FARM DR",1)

replace location=subinstr(location,"MAMACOCK RD GNB","MAMACOCK RD",1)
replace street=subinstr(street,"MAMACOCK RD GNB","MAMACOCK RD",1)

replace location=subinstr(location,"MANWARING RD OGBA","MANWARING RD",1)
replace street=subinstr(street,"MANWARING RD OGBA","MANWARING RD",1)

replace location=subinstr(location,"MARSHFIELD RD GNH","MARSHFIELD RD",1)
replace street=subinstr(street,"MARSHFIELD RD GNH","MARSHFIELD RD",1)

replace location=subinstr(location,"NEHANTIC DR BPBC","NEHANTIC DR",1)
replace street=subinstr(street,"NEHANTIC DR BPBC","NEHANTIC DR",1)

replace location=subinstr(location,"NILES CREEK RD GNB","NILES CREEK RD",1)
replace street=subinstr(street,"NILES CREEK RD GNB","NILES CREEK RD",1)

replace location=subinstr(location,"NORTH AVE CB","NORTH AVE",1)
replace street=subinstr(street,"NORTH AVE CB","NORTH AVE",1)

replace location=subinstr(location,"NORTH DR OGBA","NORTH DR",1)
replace street=subinstr(street,"NORTH DR OGBA","NORTH DR",1)

replace location=subinstr(location,"OAKWOOD RD GNH","OAKWOOD RD",1)
replace street=subinstr(street,"OAKWOOD RD GNH","OAKWOOD RD",1)

replace location=subinstr(location,"OCEAN AVE CB","OCEAN AVE",1)
replace street=subinstr(street,"OCEAN AVE CB","OCEAN AVE",1)

replace location=subinstr(location,"OLD BLACK PT RD","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OSPREY LN GNH","OSPREY LN",1)
replace street=subinstr(street,"OSPREY LN GNH","OSPREY LN",1)

replace location=subinstr(location,"OSPREY RD BPBC","OSPREY RD",1)
replace street=subinstr(street,"OSPREY RD BPBC","OSPREY RD",1)

replace location=subinstr(location,"PALLETTE AVE BPBC","PALLETTE DR",1)
replace street=subinstr(street,"PALLETTE AVE BPBC","PALLETTE DR",1)

replace location=subinstr(location,"PARK CT BPBC","PARK CT",1)
replace street=subinstr(street,"PARK CT BPBC","PARK CT",1)

replace location=subinstr(location,"PARK LN GNH","PARK LN",1)
replace street=subinstr(street,"PARK LN GNH","PARK LN",1)

replace location=subinstr(location,"PARK VIEW DR GNH","PARKVIEW DR",1)
replace street=subinstr(street,"PARK VIEW DR GNH","PARKVIEW DR",1)

replace location=subinstr(location,"PARKWAY NORTH","PARKWAY N",1)
replace street=subinstr(street,"PARKWAY NORTH","PARKWAY N",1)

replace location=subinstr(location,"PARKWAY SOUTH","PARKWAY S",1)
replace street=subinstr(street,"PARKWAY SOUTH","PARKWAY S",1)

replace location=subinstr(location,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)
replace street=subinstr(street,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)

replace location=subinstr(location,"POINT RD GNB","POINT RD",1)
replace street=subinstr(street,"POINT RD GNB","POINT RD",1)

replace location=subinstr(location,"PROSPECT AVE CB","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AVE CB","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)
replace street=subinstr(street,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)

replace location=subinstr(location,"RIDGE TR BPBC","RIDGE TRL",1)
replace street=subinstr(street,"RIDGE TR BPBC","RIDGE TRL",1)

replace location=subinstr(location,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)
replace street=subinstr(street,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)

replace location=subinstr(location,"ROCKBOURNE AVE","ROCKBOURNE LN",1)
replace street=subinstr(street,"ROCKBOURNE AVE","ROCKBOURNE LN",1)

replace location=subinstr(location,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)
replace street=subinstr(street,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)

replace location=subinstr(location,"S LEE RD GNB","S LEE RD",1)
replace street=subinstr(street,"S LEE RD GNB","S LEE RD",1)

replace location=subinstr(location,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)
replace street=subinstr(street,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)

replace location=subinstr(location,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)
replace street=subinstr(street,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)

replace location=subinstr(location,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)
replace street=subinstr(street,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)

replace location=subinstr(location,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)
replace street=subinstr(street,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)

replace location=subinstr(location,"SEA VIEW LN GNH","SEA VIEW LN",1)
replace street=subinstr(street,"SEA VIEW LN GNH","SEA VIEW LN",1)

replace location=subinstr(location,"SHERMAN CT CB","SHERMAN CT",1)
replace street=subinstr(street,"SHERMAN CT CB","SHERMAN CT",1)

replace location=subinstr(location,"SHORE RD OGBA","SHORE RD",1)
replace street=subinstr(street,"SHORE RD OGBA","SHORE RD",1)

replace location=subinstr(location,"SOUTH DR OGBA","SOUTH DR",1)
replace street=subinstr(street,"SOUTH DR OGBA","SOUTH DR",1)

replace location=subinstr(location,"SOUTH TR","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR","SOUTH TRL",1)

replace location=subinstr(location,"SOUTH TR BPBC","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR BPBC","SOUTH TRL",1)

replace location=subinstr(location,"SPENCER AVE CB","SPENCER AVE",1)
replace street=subinstr(street,"SPENCER AVE CB","SPENCER AVE",1)

replace location=subinstr(location,"SPRING GLEN RD GNH","SPRING GLEN RD",1)
replace street=subinstr(street,"SPRING GLEN RD GNH","SPRING GLEN RD",1)

replace location=subinstr(location,"SUNRISE AVE BPBC","SUNRISE AVE",1)
replace street=subinstr(street,"SUNRISE AVE BPBC","SUNRISE AVE",1)

replace location=subinstr(location,"SUNSET AVE BPBC","SUNSET AVE",1)
replace street=subinstr(street,"SUNSET AVE BPBC","SUNSET AVE",1)

replace location=subinstr(location,"TABERNACLE AVE CB","TABERNACLE AVE",1)
replace street=subinstr(street,"TABERNACLE AVE CB","TABERNACLE AVE",1)

replace location=subinstr(location,"TERRACE AVE CB","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE CB","TERRACE AVE",1)

replace location=subinstr(location,"TERRACE AVE OGBA","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE OGBA","TERRACE AVE",1)

replace location=subinstr(location,"UNCAS RD BPBC","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD BPBC","UNCAS RD",1)

replace location=subinstr(location,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)
replace street=subinstr(street,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)

replace location=subinstr(location,"WATERSIDE AVE BPBC","WATERSIDE RD",1)
replace street=subinstr(street,"WATERSIDE AVE BPBC","WATERSIDE RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"WESTOMERE TR","WESTOMERE TER",1)
replace street=subinstr(street,"WESTOMERE TR","WESTOMERE TER",1)

replace location=subinstr(location,"WHITECAP RD BPBC","WHITECAP RD",1)
replace street=subinstr(street,"WHITECAP RD BPBC","WHITECAP RD",1)

replace location=subinstr(location,"WHITTLESEY PL","WHITTLESAY PL",1)
replace street=subinstr(street,"WHITTLESEY PL","WHITTLESAY PL",1)

replace location=subinstr(location,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)
replace street=subinstr(street,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)

replace location=subinstr(location,"WOODLAND DR BPBC","WOODLAND DR",1)
replace street=subinstr(street,"WOODLAND DR BPBC","WOODLAND DR",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
drop if _merge==2
replace PropertyCity="NEW LONDON" if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta",update
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2
*
replace PropertyCity="NIANTIC" if _merge==1
drop _merge
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta",update
replace revise=1 if _merge==3|_merge==4|_merge==5
replace error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="NEW LONDON"&PropertyCity!="NIANTIC"
*
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_newlondoneastlyme_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*100 add revised for newlondon and eastlyme
****************************Branford*********************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_branford.dta",clear
duplicates report orig_fid


duplicates tag fid_build,gen(dup1)
drop if trim(location)=="169-193 SO MONTOWESE ST"&dup1>=1
drop if trim(location)=="LANPHIERS COVE CAMP"&dup1>=1
drop if trim(location)==""&dup1>=1
duplicates drop fid_build location,force
duplicates drop fid_build,force
drop dup1


gen PropertyCity="BRANFORD"
keep fid_build orig_fid location street PropertyCity

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="BRANFORD"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_branford_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*85 add revised for branford
****************************Guilford*********************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_guilford.dta",clear
duplicates report orig_fid

duplicates report fid_build
duplicates tag fid_build,gen(dup1)
drop if trim(location)=="LEETES ISLAND RD"&dup1>=1
drop if trim(location)=="PADDOCK LN"&dup1>=1
drop if trim(location)==""&dup1>=1
duplicates drop fid_build location,force
duplicates drop fid_build,force
drop dup1

gen PropertyCity="GUILFORD"
keep fid_build orig_fid location street PropertyCity

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="GUILFORD"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_guilford_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*147 add revised for guilford

*******************************Madison******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_madison.dta",clear
duplicates report orig_fid

gen PropertyCity="MADISON"
keep fid_build orig_fid location street PropertyCity

replace location=subinstr(location,"DEER RUN","DEER RUN RD",1)
replace street=subinstr(street,"DEER RUN","DEER RUN RD",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"LANTERN HILL RD","LANTERN HL",1)
replace street=subinstr(street,"LANTERN HILL RD","LANTERN HL",1)

replace location=subinstr(location,"MEETINGHOUSE LN","MEETING HOUSE LN",1)
replace street=subinstr(street,"MEETINGHOUSE LN","MEETING HOUSE LN",1)

replace location=subinstr(location,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)
replace street=subinstr(street,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)

replace location=subinstr(location,"OVERSHORES DR EAST","OVERSHORES E",1)
replace street=subinstr(street,"OVERSHORES DR EAST","OVERSHORES E",1)

replace location=subinstr(location,"OVERSHORES DR WEST","OVERSHORES W",1)
replace street=subinstr(street,"OVERSHORES DR WEST","OVERSHORES W",1)

replace location=subinstr(location,"PENT RD #5","PENT RD",1)
replace street=subinstr(street,"PENT RD #5","PENT RD",1)

replace location=subinstr(location,"STERLING PARK DR","STERLING PARK",1)
replace street=subinstr(street,"STERLING PARK DR","STERLING PARK",1)

replace location=subinstr(location,"WEST WHARF RD","W WHARF RD",1)
replace street=subinstr(street,"WEST WHARF RD","W WHARF RD",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="MADISON"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_madison_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*56 add revised for madison

*******************************New Haven******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_newhaven.dta",clear
duplicates report orig_fid

gen PropertyCity="New Haven"
keep fid_build orig_fid location street PropertyCity

duplicates tag fid_build,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop fid_build location,force
duplicates drop fid_build,force
drop dup1

replace location=subinstr(location,"BLATCHLEY AV","BLATCHLEY AVE",1)
replace street=subinstr(street,"BLATCHLEY AV","BLATCHLEY AVE",1)

replace location=subinstr(location,"DOUGLASS AV","DOUGLASS AVE",1)
replace street=subinstr(street,"DOUGLASS AV","DOUGLASS AVE",1)

replace location=subinstr(location,"FAIRMONT AV","FAIRMONT AVE",1)
replace street=subinstr(street,"FAIRMONT AV","FAIRMONT AVE",1)

replace location=subinstr(location,"FARREN AV","FARREN AVE",1)
replace street=subinstr(street,"FARREN AV","FARREN AVE",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FLORENCE AV","FLORENCE AVE",1)
replace street=subinstr(street,"FLORENCE AV","FLORENCE AVE",1)

replace location=subinstr(location,"FORBES AV","FORBES AVE",1)
replace street=subinstr(street,"FORBES AV","FORBES AVE",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GIRARD AV","GIRARD AVE",1)
replace street=subinstr(street,"GIRARD AV","GIRARD AVE",1)

replace location=subinstr(location,"GREENWICH AV","GREENWICH AVE",1)
replace street=subinstr(street,"GREENWICH AV","GREENWICH AVE",1)

replace location=subinstr(location,"HALLOCK AV","HALLOCK AVE",1)
replace street=subinstr(street,"HALLOCK AV","HALLOCK AVE",1)

replace location=subinstr(location,"HORSLEY AV","HORSLEY AVE",1)
replace street=subinstr(street,"HORSLEY AV","HORSLEY AVE",1)

replace location=subinstr(location,"HOWARD AV","HOWARD AVE",1)
replace street=subinstr(street,"HOWARD AV","HOWARD AVE",1)

replace location=subinstr(location,"KIMBERLY AV","KIMBERLY AVE",1)
replace street=subinstr(street,"KIMBERLY AV","KIMBERLY AVE",1)

replace location=subinstr(location,"MEADOW VIEW ST","MEADOW VIEW RD",1)
replace street=subinstr(street,"MEADOW VIEW ST","MEADOW VIEW RD",1)

replace location=subinstr(location,"MORRIS AV","MORRIS AVE",1)
replace street=subinstr(street,"MORRIS AV","MORRIS AVE",1)

replace location=subinstr(location,"ORCHARD AV","ORCHARD AVE",1)
replace street=subinstr(street,"ORCHARD AV","ORCHARD AVE",1)

replace location=subinstr(location,"PARK LA","PARK LN",1)
replace street=subinstr(street,"PARK LA","PARK LN",1)

replace location=subinstr(location,"PROSPECT AV","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AV","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPIAC AV","QUINNIPIAC AVE",1)
replace street=subinstr(street,"QUINNIPIAC AV","QUINNIPIAC AVE",1)

replace location=subinstr(location,"SALTONSTALL AV","SALTONSTALL AVE",1)
replace street=subinstr(street,"SALTONSTALL AV","SALTONSTALL AVE",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SHEPARD AV","SHEPARD AVE",1)
replace street=subinstr(street,"SHEPARD AV","SHEPARD AVE",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"SOUTH WATER ST","S WATER ST",1)
replace street=subinstr(street,"SOUTH WATER ST","S WATER ST",1)

replace location=subinstr(location,"STUYVESANT AV","STUYVESANT AVE",1)
replace street=subinstr(street,"STUYVESANT AV","STUYVESANT AVE",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TOWNSEND AV","TOWNSEND AVE",1)
replace street=subinstr(street,"TOWNSEND AV","TOWNSEND AVE",1)

replace location=subinstr(location,"WOODWARD AV","WOODWARD AVE",1)
replace street=subinstr(street,"WOODWARD AV","WOODWARD AVE",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="New Haven"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_newhaven_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*23 add revised for new haven

*******************************West Haven******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_westhaven.dta",clear
duplicates report orig_fid

gen PropertyCity="WEST HAVEN"
keep fid_build orig_fid location street PropertyCity


*West Haven Specific
replace location=subinstr(location,"BARBARA LA","BARBARA LN",1)
replace street=subinstr(street,"BARBARA LA","BARBARA LN",1)

replace location=subinstr(location,"BATT LA","BATT LN",1)
replace street=subinstr(street,"BATT LA","BATT LN",1)

replace location=subinstr(location,"BAYCREST AVE","BAYCREST DR",1)
replace street=subinstr(street,"BAYCREST AVE","BAYCREST DR",1)

replace location=subinstr(location,"BELLE CIRCLE","BELLE CIR",1)
replace street=subinstr(street,"BELLE CIRCLE","BELLE CIR",1)

replace location=subinstr(location,"BUNGALOW LA","BUNGALOW LN",1)
replace street=subinstr(street,"BUNGALOW LA","BUNGALOW LN",1)

replace location=subinstr(location,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)
replace street=subinstr(street,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)

replace location=subinstr(location,"CHECK PT LN","CHECK POINT LN",1)
replace street=subinstr(street,"CHECK PT LN","CHECK POINT LN",1)

replace location=subinstr(location,"CHERRY LA","CHERRY LN",1)
replace street=subinstr(street,"CHERRY LA","CHERRY LN",1)

replace location=subinstr(location,"CIRCLE ST.","CIRCLE ST",1)
replace street=subinstr(street,"CIRCLE ST.","CIRCLE ST",1)

replace location=subinstr(location,"COLONIAL BLV","COLONIAL BLVD",1)
replace street=subinstr(street,"COLONIAL BLV","COLONIAL BLVD",1)

replace location=subinstr(location,"CONN AVE","CONNECTICUT AVE",1)
replace street=subinstr(street,"CONN AVE","CONNECTICUT AVE",1)

replace location=subinstr(location,"DELAWAN AV","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV","DELAWAN AVE",1)

replace location=subinstr(location,"DELAWAN AV REAR","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV REAR","DELAWAN AVE",1)

replace location=subinstr(location,"EASY RUDDER LA","EASY RUDDER LN",1)
replace street=subinstr(street,"EASY RUDDER LA","EASY RUDDER LN",1)

replace location=subinstr(location,"FAIR SAILING","FAIR SAILING RD",1)
replace street=subinstr(street,"FAIR SAILING","FAIR SAILING RD",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FIRST AV","1ST AVE",1)
replace street=subinstr(street,"FIRST AV","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)
replace street=subinstr(street,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)

replace location=subinstr(location,"LAURIE LA","LAURIE LN",1)
replace street=subinstr(street,"LAURIE LA","LAURIE LN",1)

replace location=subinstr(location,"LEONARD ST.","LEONARD ST",1)
replace street=subinstr(street,"LEONARD ST.","LEONARD ST",1)

replace location=subinstr(location,"MAY ST EXT","MAY ST",1)
replace street=subinstr(street,"MAY ST EXT","MAY ST",1)
/*
replace location=subinstr(location,"MOHAWK DR","MOHAWK DRIVE EXT",1)
replace street=subinstr(street,"MOHAWK DR","MOHAWK DRIVE EXT",1)
*/
replace location=subinstr(location,"MORGAN LA","MORGAN LN",1)
replace street=subinstr(street,"MORGAN LA","MORGAN LN",1)

replace location=subinstr(location,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)
replace street=subinstr(street,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)

replace location=subinstr(location,"NO UNION AVE","N UNION AVE",1)
replace street=subinstr(street,"NO UNION AVE","N UNION AVE",1)

replace location=subinstr(location,"OSBORN AVE","OSBORNE AVE",1)
replace street=subinstr(street,"OSBORN AVE","OSBORNE AVE",1)

replace location=subinstr(location,"PARK TER AVE","PARK TERRACE AVE",1)
replace street=subinstr(street,"PARK TER AVE","PARK TERRACE AVE",1)

replace location=subinstr(location,"PARKER AVE EAST","PARKER AVE E",1)
replace street=subinstr(street,"PARKER AVE EAST","PARKER AVE E",1)

replace location=subinstr(location,"PARKRIDGE RD","PARK RIDGE RD",1)
replace street=subinstr(street,"PARKRIDGE RD","PARK RIDGE RD",1)

replace location=subinstr(location,"PECK LA","PECK LN",1)
replace street=subinstr(street,"PECK LA","PECK LN",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SECOND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"SECOND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"2ND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"2ND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"SOUNDVIEW ST","SOUND VIEW ST",1)
replace street=subinstr(street,"SOUNDVIEW ST","SOUND VIEW ST",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"THIRD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"THIRD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"3RD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"3RD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"TYLER AVE","TYLER ST",1)
replace street=subinstr(street,"TYLER AVE","TYLER ST",1)

replace location=subinstr(location,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WINDSOCK RD","WIND SOCK RD",1)
replace street=subinstr(street,"WINDSOCK RD","WIND SOCK RD",1)

replace location=subinstr(location,"WOODY CREST","WOODY CRST",1)
replace street=subinstr(street,"WOODY CREST","WOODY CRST",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="WEST HAVEN"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_westhaven_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*74 add revised for west haven
*******************************Bridgeport******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_bridgeport.dta",clear
duplicates report orig_fid
duplicates drop

ren cama_gi_13 location
ren cama_gi_14 address_num

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(location," ",2)
gen street=substr(location,firstblankpos+1,.)
gen PropertyCity="BRIDGEPORT"

keep fid_build orig_fid location street PropertyCity

capture drop firsthash
gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)

capture drop firsthash
gen firsthash=ustrpos(location,"#",1)
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)
*Bridgeport Specific

replace location=subinstr(location," AV"," AVE",1)
replace street=subinstr(street," AV"," AVE",1)

replace location=subinstr(location,"BYWATER LN","BYWATYR LN",1)
replace street=subinstr(street,"BYWATER LN","BYWATYR LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)
replace street=subinstr(street,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)

replace location=subinstr(location,"FAYERWEATHER TR","FAYERWEATHER TER",1)
replace street=subinstr(street,"FAYERWEATHER TR","FAYERWEATHER TER",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GARDEN TR","GARDEN TER",1)
replace street=subinstr(street,"GARDEN TR","GARDEN TER",1)

replace location=subinstr(location,"MARINA PARK ST","MARINA PARK CIR",1)
replace street=subinstr(street,"MARINA PARK ST","MARINA PARK CIR",1)

replace location=subinstr(location,"MARTIN TR","MARTIN TER",1)
replace street=subinstr(street,"MARTIN TR","MARTIN TER",1)

replace location=subinstr(location," TR"," TER",1)
replace street=subinstr(street," TR"," TER",1)

replace location=subinstr(location,"OGDEN ST EX","OGDEN STREET EXT",1)
replace street=subinstr(street,"OGDEN ST EX","OGDEN STREET EXT",1)

replace location=subinstr(location,"PEARSALL WY","PEARSALL WAY",1)
replace street=subinstr(street,"PEARSALL WY","PEARSALL WAY",1)

replace location=subinstr(location,"SHERMAN PARK CR","SHERMAN PARK CIR",1)
replace street=subinstr(street,"SHERMAN PARK CR","SHERMAN PARK CIR",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"WEST LIBERTY ST","W LIBERTY ST",1)
replace street=subinstr(street,"WEST LIBERTY ST","W LIBERTY ST",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="BRIDGEPORT"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_bridgeport_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*243 add revised for Bridgeport
*******************************Stratford******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_stratford.dta",clear
duplicates report orig_fid

ren realmast_3 location

capture drop firstblankpos
gen firstblankpos=ustrpos(location," ",2)
gen address_num=substr(location,1,firstblankpos-1)
gen PropertyCity="STRATFORD"
ren realmast_4 street

keep fid_build orig_fid location street PropertyCity

ren fid_build FID_Buildingfootprint
duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location dup1,force
duplicates drop FID_Buildingfootprint dup1,force
duplicates drop FID_Buildingfootprint,force
drop dup1
ren FID_Buildingfootprint fid_build 

*Stratford Specific

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WEST BEACH DR","W BEACH DR",1)
replace street=subinstr(street,"WEST BEACH DR","W BEACH DR",1)

replace location=subinstr(location,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)
replace street=subinstr(street,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)


ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="STRATFORD"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_stratford_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*103 add revised for Stratford
*******************************Westport******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_westport.dta",clear
duplicates report orig_fid

tostring street_num,gen(address_num)
gen location=address_num+" "+street_nam
ren street_nam street

gen PropertyCity="WESTPORT"

keep fid_build orig_fid location street PropertyCity

ren fid_build FID_Buildingfootprint
duplicates tag FID_Buildingfootprint,gen(dup1)
drop if trim(location)==""&dup1>=1
duplicates drop FID_Buildingfootprint location dup1,force
duplicates drop FID_Buildingfootprint dup1,force
duplicates drop FID_Buildingfootprint,force
drop dup1
ren FID_Buildingfootprint fid_build 


*Westport Specific
replace location=subinstr(location,"APPLETREE TRL","APPLE TREE TRL",1)
replace street=subinstr(street,"APPLETREE TRL","APPLE TREE TRL",1)

replace location=subinstr(location,"BLUEWATER HILL","BLUEWATER HL",1)
replace street=subinstr(street,"BLUEWATER HILL","BLUEWATER HL",1)

replace location=subinstr(location,"BLUEWATER HILL S","BLUEWATER HL S",1)
replace street=subinstr(street,"BLUEWATER HILL S","BLUEWATER HL S",1)

replace location=subinstr(location,"BURNHAM HILL","BURNHAM HL",1)
replace street=subinstr(street,"BURNHAM HILL","BURNHAM HL",1)

replace location=subinstr(location,"COMPO MILL COVE","COMPO MILL CV",1)
replace street=subinstr(street,"COMPO MILL COVE","COMPO MILL CV",1)

replace location=subinstr(location,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)
replace street=subinstr(street,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)

replace location=subinstr(location,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)
replace street=subinstr(street,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)

replace location=subinstr(location,"GREENS FARMS HOL","GREENS FARMS HOLW",1)
replace street=subinstr(street,"GREENS FARMS HOL","GREENS FARMS HOLW",1)

replace location=subinstr(location,"GROVE PT RD","GROVE PT",1)
replace street=subinstr(street,"GROVE PT RD","GROVE PT",1)

replace location=subinstr(location,"HARBOR HILL","HARBOR HL",1)
replace street=subinstr(street,"HARBOR HILL","HARBOR HL",1)

replace location=subinstr(location,"HIAWATHA LN","HIAWATHA LANE EXT",1)
replace street=subinstr(street,"HIAWATHA LN","HIAWATHA LANE EXT",1)

replace location=subinstr(location,"HIDE-AWAY LN","HIDEAWAY LN",1)
replace street=subinstr(street,"HIDE-AWAY LN","HIDEAWAY LN",1)

replace location=subinstr(location,"HORSESHOE CT","HORSESHOE LN",1)
replace street=subinstr(street,"HORSESHOE CT","HORSESHOE LN",1)

replace location=subinstr(location,"JUDY PT LN","JUDY POINT LN",1)
replace street=subinstr(street,"JUDY PT LN","JUDY POINT LN",1)

replace location=subinstr(location,"LAZY BRK LN","LAZY BROOK LN",1)
replace street=subinstr(street,"LAZY BRK LN","LAZY BROOK LN",1)

replace location=subinstr(location,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)
replace street=subinstr(street,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)

replace location=subinstr(location,"MARSH RD","MARSH CT",1)
replace street=subinstr(street,"MARSH RD","MARSH CT",1)

replace location=subinstr(location,"MINUTE MAN HILL","MINUTE MAN HL",1)
replace street=subinstr(street,"MINUTE MAN HILL","MINUTE MAN HL",1)

replace location=subinstr(location,"OAK RDG PK","OAK RIDGE PARK",1)
replace street=subinstr(street,"OAK RDG PK","OAK RIDGE PARK",1)

replace location=subinstr(location,"OWENOKE PK","OWENOKE PARK",1)
replace street=subinstr(street,"OWENOKE PK","OWENOKE PARK",1)

replace location=subinstr(location,"RIVARD CRESCENT","RIVARD CRES",1)
replace street=subinstr(street,"RIVARD CRESCENT","RIVARD CRES",1)

replace location=subinstr(location,"RIVERVIEW RD","RIVER VIEW RD",1)
replace street=subinstr(street,"RIVERVIEW RD","RIVER VIEW RD",1)

replace location=subinstr(location,"ROWLAND CT","ROWLAND PL",1)
replace street=subinstr(street,"ROWLAND CT","ROWLAND PL",1)

replace location=subinstr(location,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)
replace street=subinstr(street,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)

replace location=subinstr(location,"SMOKY LN","SMOKEY LN",1)
replace street=subinstr(street,"SMOKY LN","SMOKEY LN",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"STONY PT W","STONY POINT RD W",1)
replace street=subinstr(street,"STONY PT W","STONY POINT RD W",1)

replace location=subinstr(location,"SURREY DR","SURREY LN",1)
replace street=subinstr(street,"SURREY DR","SURREY LN",1)

replace location=subinstr(location,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)
replace street=subinstr(street,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised1.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="WESTPORT"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_westport_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise
*483 add revised for Westport

*******************************Waterford******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_waterford.dta",clear
duplicates report orig_fid

ren watfrd_c_5 location
ren watfrd_c_8 street

capture drop firstblankpos PropertyStreet
gen firstblankpos=ustrpos(location," ",2)
gen address_num=substr(location,1,firstblankpos-1)
ren circa_wa_6 PropertyCity

keep fid_build orig_fid location street PropertyCity

*Waterford Specific
replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"BEACH ST EAST","BEACH ST E",1)
replace street=subinstr(street,"BEACH ST EAST","BEACH ST E",1)

replace location=subinstr(location,"EAST BISHOP ST","E BISHOP ST",1)
replace street=subinstr(street,"EAST BISHOP ST","E BISHOP ST",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)
replace street=subinstr(street,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)

replace location=subinstr(location,"LEONARD CT","LEONARD RD",1)
replace street=subinstr(street,"LEONARD CT","LEONARD RD",1)

replace location=subinstr(location,"LINDROS LN","LINDROSS LN",1)
replace street=subinstr(street,"LINDROS LN","LINDROSS LN",1)

replace location=subinstr(location,"MAGONK PT RD","MAGONK POINT RD",1)
replace street=subinstr(street,"MAGONK PT RD","MAGONK POINT RD",1)

replace location=subinstr(location,"MILLSTONE RD EAST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD EAST","MILLSTONE RD",1)

replace location=subinstr(location,"MILLSTONE RD WEST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD WEST","MILLSTONE RD",1)

replace location=subinstr(location,"PARKWAY DR","PARKWAY",1)
replace street=subinstr(street,"PARKWAY DR","PARKWAY",1)

replace location=subinstr(location,"SEA MEADOW LN","SEA MEADOWS LN",1)
replace street=subinstr(street,"SEA MEADOW LN","SEA MEADOWS LN",1)

replace location=subinstr(location,"STRAND RD","STRAND",1)
replace street=subinstr(street,"STRAND RD","STRAND",1)

replace location=subinstr(location,"WEST NECK RD","W NECK RD",1)
replace street=subinstr(street,"WEST NECK RD","W NECK RD",1)

replace location=subinstr(location,"WEST STRAND RD","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND RD","W STRAND RD",1)

replace location=subinstr(location,"WEST STRAND","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND","W STRAND RD",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised2.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="Waterford"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_waterford_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise

*******************************Norwalk******************************
use "D:\Work\CIRCA\Circa\GISdata\buildingwadd_norwalk.dta",clear
duplicates report orig_fid

ren streetname street
ren streetnum address_num

ren loccity PropertyCity
keep fid_build orig_fid location street PropertyCity
duplicates drop
duplicates drop orig_fid,force

*Norwalk Specific
replace location=subinstr(location,"ACACIA ST","ACACIA DR",1)
replace street=subinstr(street,"ACACIA ST","ACACIA DR",1)

replace location=subinstr(location,"BROWNE PL","BROWN PL",1)
replace street=subinstr(street,"BROWNE PL","BROWN PL",1)

replace location=subinstr(location,"CAPTAINS WALK RD","CAPTAINS WALK",1)
replace street=subinstr(street,"CAPTAINS WALK RD","CAPTAINS WALK",1)

replace location=subinstr(location,"CIRCLE ST","CIRCLE RD",1)
replace street=subinstr(street,"CIRCLE ST","CIRCLE RD",1)

replace location=subinstr(location,"COVLEE DR","COVELEE DR",1)
replace street=subinstr(street,"COVLEE DR","COVELEE DR",1)

replace location=subinstr(location,"EAST BEACH DR","E BEACH DR",1)
replace street=subinstr(street,"EAST BEACH DR","E BEACH DR",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"HILLSIDE ST","HILLSIDE PL",1)
replace street=subinstr(street,"HILLSIDE ST","HILLSIDE PL",1)

replace location=subinstr(location,"JO'S BARN WY","JO S BARN WAY",1)
replace street=subinstr(street,"JO'S BARN WY","JO S BARN WAY",1)

replace location=subinstr(location,"LITTLE WY","LITTLE WAY",1)
replace street=subinstr(street,"LITTLE WY","LITTLE WAY",1)

replace location=subinstr(location,"NAPLES AVE","NAPLES ST",1)
replace street=subinstr(street,"NAPLES AVE","NAPLES ST",1)

replace location=subinstr(location,"OLD TROLLEY WY","OLD TROLLEY WAY",1)
replace street=subinstr(street,"OLD TROLLEY WY","OLD TROLLEY WAY",1)

replace location=subinstr(location,"PHILLENE RD","PHILLENE DR",1)
replace street=subinstr(street,"PHILLENE RD","PHILLENE DR",1)

replace location=subinstr(location,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)
replace street=subinstr(street,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)

replace location=subinstr(location,"POND RIDGE RD","POND RIDGE LN",1)
replace street=subinstr(street,"POND RIDGE RD","POND RIDGE LN",1)

replace location=subinstr(location,"ROBINS SQ EAST","ROBINS SQ E",1)
replace street=subinstr(street,"ROBINS SQ EAST","ROBINS SQ E",1)

replace location=subinstr(location,"ROBINS SQ SOUTH","ROBINS SQ S",1)
replace street=subinstr(street,"ROBINS SQ SOUTH","ROBINS SQ S",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SELDON ST","SELDON PL",1)
replace street=subinstr(street,"SELDON ST","SELDON PL",1)

replace location=subinstr(location,"SHOREFRONT PK","SHOREFRONT PARK",1)
replace street=subinstr(street,"SHOREFRONT PK","SHOREFRONT PARK",1)

replace location=subinstr(location,"SOUTH BEACH DR","S BEACH DR",1)
replace street=subinstr(street,"SOUTH BEACH DR","S BEACH DR",1)

replace location=subinstr(location,"SOUTH MAIN ST","S MAIN ST",1)
replace street=subinstr(street,"SOUTH MAIN ST","S MAIN ST",1)

replace location=subinstr(location,"SOUTH SMITH ST","S SMITH ST",1)
replace street=subinstr(street,"SOUTH SMITH ST","S SMITH ST",1)

replace location=subinstr(location,"ST JAMES PL","SAINT JAMES PL",1)
replace street=subinstr(street,"ST JAMES PL","SAINT JAMES PL",1)

replace location=subinstr(location,"ST. JOHN ST","SAINT JOHN ST",1)
replace street=subinstr(street,"ST. JOHN ST","SAINT JOHN ST",1)

replace location=subinstr(location,"STEEPLETOP RD","STEEPLE TOP RD",1)
replace street=subinstr(street,"STEEPLETOP RD","STEEPLE TOP RD",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TONETTA CR","TONETTA CIR",1)
replace street=subinstr(street,"TONETTA CR","TONETTA CIR",1)

replace location=subinstr(location,"TOPSAIL RD","TOP SAIL RD",1)
replace street=subinstr(street,"TOPSAIL RD","TOP SAIL RD",1)

replace location=subinstr(location,"WEST MEADOW PL","W MEADOW PL",1)
replace street=subinstr(street,"WEST MEADOW PL","W MEADOW PL",1)

ren location PropertyFullStreetAddress
ren street PropertyStreet
duplicates report PropertyFullStreetAddress PropertyCity 
merge m:1 PropertyFullStreetAddress PropertyCity using"$dta\Ggl_points_toberevised2.dta"
gen revise=(_merge==3)
gen error_norevise=(_merge==2)
drop if _merge==2&PropertyCity!="NORWALK"
drop _merge

duplicates report PropertyFullStreetAddress PropertyCity
sort FID fid_build
duplicates drop fid_build if fid_build!=.,force

save "$dta\buildingsGgl_norwalk_revise.dta",replace
duplicates drop PropertyFullStreetAddress PropertyCity,force
tab revise



**************************************************************************
*       Aggregate buildings to be revised, merge back to shapefile       *
**************************************************************************
use "$dta\buildingsGgl_easthaven_revise.dta",clear
append using "$dta\buildingsGgl_fairfield_revise.dta"
append using "$dta\buildingsGgl_clinton_revise.dta"
append using "$dta\buildingsGgl_groton_revise.dta"
append using "$dta\buildingsGgl_oldlyme_revise.dta"
append using "$dta\buildingsGgl_oldsaybrook_revise.dta"
append using "$dta\buildingsGgl_milford_revise.dta"
append using "$dta\buildingsGgl_stonington_revise.dta"
append using "$dta\buildingsGgl_westbrook_revise.dta"
append using "$dta\buildingsGgl_newlondoneastlyme_revise.dta"
append using "$dta\buildingsGgl_branford_revise.dta"
append using "$dta\buildingsGgl_guilford_revise.dta"
append using "$dta\buildingsGgl_madison_revise.dta"
append using "$dta\buildingsGgl_newhaven_revise.dta"
append using "$dta\buildingsGgl_westhaven_revise.dta"
append using "$dta\buildingsGgl_bridgeport_revise.dta"
append using "$dta\buildingsGgl_stratford_revise.dta"
append using "$dta\buildingsGgl_westport_revise.dta"

tab error_norevise
tab revise
save "$dta\buildingsGgl_towns_revise.dta",replace

/*
use "$dta\buildingsGgl_towns_revise.dta",clear
sort PropertyFullStreetAddress
duplicates report PropertyFullStreetAddress PropertyCity
ren PropertyFullStreetAddress propertyfullstreetaddress
ren PropertyCity propertycity
merge m:m propertyfullstreetaddress propertycity using"$dta\viewshed_prop_ggl.dta"
*/

*Merge addresses to the buildings, generate the to-be-revised list
use "$GIS\buildings_add_rev.dta",clear
merge 1:m fid_build using"$dta\buildingsGgl_towns_revise.dta",keepusing(FID PropertyFullStreetAddress PropertyCity revise)
drop if _merge==2
sort fid_build
replace location=PropertyFullStreetAddress
replace city=PropertyCity
replace fid_point=FID
replace fid_point=. if revise!=1
tab revise
drop FID PropertyFullStreetAddress PropertyCity revise _merge
export delimited using "D:\Work\CIRCA\Circa\GISdata\buildings_add_rev.csv", replace

/* This isn't the full match of addresses
ren city propertycity
ren location propertyfullstreetaddress
merge m:1 propertyfullstreetaddress propertycity using"$dta\viewshed_prop_ggl.dta"

count if _merge==3&propertycity!="STAMFORD"&propertycity!="COS COB"&propertycity!="WATERFORD"&propertycity!= "SOUTHPORT"&propertycity!="OLD GREENWICH"&propertycity!= "GREENWICH"&propertycity!= "NORWALK"&propertycity!="DARIEN"
count if _merge!=1&propertycity!="STAMFORD"&propertycity!="COS COB"&propertycity!="WATERFORD"&propertycity!= "SOUTHPORT"&propertycity!="OLD GREENWICH"&propertycity!= "GREENWICH"&propertycity!= "NORWALK"&propertycity!="DARIEN"
*/
use "$GIS\building_va_rev.dta",clear
gen FID=_n-1
save "$dta\building_va_rev.dta",replace



*The second wave of revision
use "$dta\buildingsGgl_waterford_revise.dta",clear
append using "$dta\buildingsGgl_norwalk_revise.dta"
tab error_norevise
tab revise
save "$dta\buildingsGgl_towns_revise1.dta",replace

*Merge addresses to the buildings, generate the to-be-revised list
use "$GIS\buildings_add_rev1.dta",clear
merge 1:m fid_build using"$dta\buildingsGgl_towns_revise1.dta",keepusing(FID PropertyFullStreetAddress PropertyCity revise)
drop if _merge==2
sort fid_build
replace location=PropertyFullStreetAddress
replace city=PropertyCity
replace fid_point=FID
replace fid_point=. if revise!=1
tab revise
drop FID PropertyFullStreetAddress PropertyCity revise _merge
export delimited using "D:\Work\CIRCA\Circa\GISdata\buildings_add_rev1.csv", replace

use "$GIS\building_va_rev1.dta",clear
gen FID=_n-1
save "$dta\building_va_rev1.dta",replace


*********************
*  Viewshed-revise  *
*********************
*4690-July2019
global viewshed "D:\Work\CIRCA\Circa\ViewshedRev_poly"

clear all
set more off
use "$viewshed\lisview_0.dta",clear
forv n=0 (1) 4690 {
capture append using "$viewshed\lisview_`n'.dta"
}
duplicates drop

ren near_fid FID
*This FID is the fid in the revision shapefile
merge m:1 FID using"$dta\building_va_rev.dta",keepusing(fid_point fid_build location city)
drop if _merge==1
*when near feature is not found, near_fid(orig_fid)=-1,near_dist=-1
drop if near_dist==-1
ren fid_build FID_Buildingfootprint
*This is the fid in the original coastal building shapefile
ren FID orig_fid

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

keep _merge orig_fid FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view fid_point location city
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge

drop orig_fid
ren fid_point FID 
*change the google point fid to FID
merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

duplicates report FID
duplicates tag FID,gen(dup1)
capture drop neg_viewangle
gen neg_viewangle=-total_viewangle
sort FID neg_viewangle FID_Buildingfootprint
*keep the duplicated building with better view
egen N_buildinadd=rank(_n), by(FID)
drop if N_buildinadd>1
drop neg_viewangle dup1 N_buildinadd

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'rev
}
replace PropertyCity=upper(PropertyCity)
save "$dta\Viewshed_rev.dta",replace


*194-Aug2nd2019
global viewshed1 "D:\Work\CIRCA\Circa\ViewshedRev1_poly"

clear all
set more off
use "$viewshed1\lisview_0.dta",clear
forv n=0 (1) 193 {
capture append using "$viewshed1\lisview_`n'.dta"
}
duplicates drop

ren near_fid FID
*This FID is the fid in the revision shapefile
merge m:1 FID using"$dta\building_va_rev1.dta",keepusing(fid_point fid_build location city)
drop if _merge==1
*when near feature is not found, near_fid(orig_fid)=-1,near_dist=-1
drop if near_dist==-1
ren fid_build FID_Buildingfootprint
*This is the fid in the original coastal building shapefile
ren FID orig_fid

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

keep _merge orig_fid FID_Buildingfootprint Lisview_area Lisview_ndist Lisview_mnum total_viewangle major_view fid_point location city
duplicates drop

gen Lisview=1 if _merge==3
replace Lisview=0 if Lisview==.
drop _merge

drop orig_fid
ren fid_point FID 
*change the google point fid to FID
merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

duplicates report FID
duplicates tag FID,gen(dup1)
capture drop neg_viewangle
gen neg_viewangle=-total_viewangle
sort FID neg_viewangle FID_Buildingfootprint
*keep the duplicated building with better view
egen N_buildinadd=rank(_n), by(FID)
drop if N_buildinadd>1
drop neg_viewangle dup1 N_buildinadd

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

foreach v in Lisview_area Lisview_mnum Lisview_ndist total_viewangle major_view Lisview {
ren `v' `v'rev
}
replace PropertyCity=upper(PropertyCity)
save "$dta\Viewshed_rev1.dta",replace

***********************************************************************************
*  Coordinates-building revise(Nearest building or Address matching to town poly) *
***********************************************************************************
*VA area has been fixed by google and town polygons, and these points are eventualy moved to building centroids
use "$GIS\buildingp_rev_coor.dta",clear
ren fid_build FID_Buildingfootprint
merge 1:1 FID_Buildingfootprint using"$dta\Viewshed_rev.dta"
drop if _merge!=3
drop shape* fid_point Lisview_* total_view* major_view Lisviewrev
drop _merge
save "$dta\Coordinates_townrev.dta",replace


use "$GIS\buildingp_rev1_coor.dta",clear
ren fid_build FID_Buildingfootprint
merge 1:1 FID_Buildingfootprint using"$dta\Viewshed_rev1.dta"
drop if _merge!=3
drop shape* fid_point Lisview_* total_view* major_view Lisviewrev
drop _merge
save "$dta\Coordinates_townrev1.dta",replace


use "$GIS\buildingp_vaggl_coor.dta",clear
ren fid_build FID_Buildingfootprint
merge 1:m FID_Buildingfootprint using"$dta\Point_BuildingfootprintGgl.dta",keepusing(FID_point Dist_Buildingfootprint)
drop if _merge==2
ren FID_point FID
drop _merge

*change the google point fid to FID so we can match it with original prop list
merge m:1 FID using"$dta\viewshed_prop_ggl.dta"
drop if _merge==2
drop _merge

ren lat_rev Lat_rev
ren long_rev Long_rev

gen buildingNM_rev=1

ren FID_Buildingfootprint fid_build
merge m:1 FID using"$dta\Coordinates_townrev.dta"
replace buildingNM_rev=0 if _merge==3
*buildingNM_rev - building fixed comes from nearest building matching
gen buildingAM_rev=(_merge==3)
*buildingAM_rev - building fixed comes from address matching
drop _merge
replace Lat_rev=lat_rev if lat_rev!=.
replace Long_rev=long_rev if long_rev!=.
drop lat_rev long_rev

merge m:1 FID using"$dta\Coordinates_townrev1.dta"
replace buildingNM_rev=0 if _merge==3
replace buildingAM_rev=1 if _merge==3
drop _merge
replace Lat_rev=lat_rev if lat_rev!=.
replace Long_rev=long_rev if long_rev!=.
drop lat_rev long_rev


replace FID_Buildingfootprint=fid_build if FID_Buildingfootprint==.
keep FID Lat_* Long_* lat* long* orig_fid FID_Buildingfootprint Dist_Buildingfootprint propertyfullstreetaddress propertycity importparcelid buildingNM* buildingAM*
capture drop latGoogle longGoogle

ren propertyfullstreetaddress PropertyFullStreetAddress
ren propertycity PropertyCity
ren importparcel ImportParcelID
ren latfixed LatFixed
ren longfixed LongFixed
ren latgoogle latGoogle
ren longgoogle longGoogle

replace PropertyFullStreetAddress=trim(PropertyFullStreetAddress)
replace PropertyCity=trim(PropertyCity)
replace PropertyCity=upper(PropertyCity)
save "$dta\viewshedprop_buildingcoor.dta",replace

*creat csv for building revised points for further analysis in ArcGIS
*Can be updated for other towns (3 remaining the very west ones)
use "$dta\propOneunitcoastal.dta",clear
keep ImportParcelID PropertyFullStreetAddress PropertyCity LegalTownship LatFixed LongFixed FIPS State County
merge 1:1 PropertyFullStreetAddress PropertyCity using"$dta\prop_va_oneunitfixgoogle.dta",keepusing(accuracy latitude longitude)
drop if _merge==2
ren latitude latGoogle
ren longitude longGoogle
replace latGoogle=LatFixed if _merge!=3
replace longGoogle=LongFixed if _merge!=3
drop _merge

merge 1:1 PropertyFullStreetAddress PropertyCity using"$dta\viewshedprop_buildingcoor.dta",keepusing(Lat_rev Long_rev)
drop _merge
replace Lat_rev=latGoogle if Lat_rev==.
replace Long_rev=longGoogle if Long_rev==. 
drop if PropertyFullStreetAddress==""
export delimited using "D:\Work\CIRCA\Circa\CT_Property\dta\proponeunit_building_revised.csv", replace



*************************************************
*       Waterfront&Non-VA-imprecise-points      *
*************************************************
use "$dta\proponeunit_building_revise.dta",clear
merge 1:1 PropertyFullStreetAddress PropertyCity using"$dta\viewshedprop_buildingcoor.dta",keepusing(Lat_rev Long_rev)
drop if _merge==3
drop _merge
save "$dta\proponeunit_nonVA.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Clinton

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"SOLS PT RD","SOLS POINT RD",1)
replace street=subinstr(street,"SOLS PT RD","SOLS POINT RD",1)

replace location=subinstr(location,"WEST LOOP RD","W LOOP RD",1)
replace street=subinstr(street,"WEST LOOP RD","W LOOP RD",1)

replace location=subinstr(location,"EAST LOOP RD","E LOOP RD",1)
replace street=subinstr(street,"EAST LOOP RD","E LOOP RD",1)

replace location=subinstr(location,"SHORE RD #A31","SHORE RD",1)
replace street=subinstr(street,"SHORE RD #A31","SHORE RD",1)

replace location=subinstr(location,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)
replace street=subinstr(street,"OSPREY COMMONS SOUTH","OSPREY CMNS S",1)

replace location=subinstr(location,"GROVE WAY","GROVEWAY",1)
replace street=subinstr(street,"GROVE WAY","GROVEWAY",1)

replace location=subinstr(location,"OSPREY COMMONS","OSPREY CMNS",1)
replace street=subinstr(street,"OSPREY COMMONS","OSPREY CMNS",1)

replace location=subinstr(location,"FISK AVE & COMMERCE ST","FISK AVE",1)
replace street=subinstr(street,"FISK AVE & COMMERCE ST","FISK AVE",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace location=subinstr(location,"MORGAN PK","MORGAN PARK",1)
replace street=subinstr(street,"MORGAN PK","MORGAN PARK",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"CARRIAGE DR EXT","CARRIAGE DR",1)
replace street=subinstr(street,"CARRIAGE DR EXT","CARRIAGE DR",1)

replace location=subinstr(location,"DIAMOND DR","DIAMOND RD",1)
replace street=subinstr(street,"DIAMOND DR","DIAMOND RD",1)

replace location=subinstr(location,"EAST SHORE DR","E SHORE DR",1)
replace street=subinstr(street,"EAST SHORE DR","E SHORE DR",1)

replace location=subinstr(location,"GRAYLEDGE RD","GREYLEDGE DR",1)
replace street=subinstr(street,"GRAYLEDGE RD","GREYLEDGE DR",1)

replace location=subinstr(location,"HIDE-A-WAY","HIDE A WAY",1)
replace street=subinstr(street,"HIDE-A-WAY","HIDE A WAY",1)

replace location=subinstr(location,"HIDE-A-WAY EXT","HIDE A WAY",1)
replace street=subinstr(street,"HIDE-A-WAY EXT","HIDE A WAY",1)

replace location=subinstr(location,"HILLTOP VIEW","HILL TOP VW",1)
replace street=subinstr(street,"HILLTOP VIEW","HILL TOP VW",1)

replace location=subinstr(location,"HUNTERS RIDGE","HUNTERS RDG",1)
replace street=subinstr(street,"HUNTERS RIDGE","HUNTERS RDG",1)

replace location=subinstr(location,"JANES LN EXT","JANES LANE EXT",1)
replace street=subinstr(street,"JANES LN EXT","JANES LANE EXT",1)

replace location=subinstr(location,"LAUREL RIDGE CIRCLE","LAUREL RIDGE CIR",1)
replace street=subinstr(street,"LAUREL RIDGE CIRCLE","LAUREL RIDGE CIR",1)

replace location=subinstr(location,"LAUREL RIDGE TR","LAUREL RIDGE TRL",1)
replace street=subinstr(street,"LAUREL RIDGE TR","LAUREL RIDGE TRL",1)

replace location=subinstr(location,"LIBERTY RIDGE","LIBERTY RDG",1)
replace street=subinstr(street,"LIBERTY RIDGE","LIBERTY RDG",1)

replace location=subinstr(location,"LIBERTY VILLAGE","LIBERTY VLG",1)
replace street=subinstr(street,"LIBERTY VILLAGE","LIBERTY VLG",1)

replace location=subinstr(location,"LOCHBOURN DR","LOCHBOURNE DR",1)
replace street=subinstr(street,"LOCHBOURN DR","LOCHBOURNE DR",1)

replace location=subinstr(location,"LOCHWOOD DR","LOCKWOOD DR",1)
replace street=subinstr(street,"LOCHWOOD DR","LOCKWOOD DR",1)

replace location=subinstr(location,"MARYMAC LOOP","MARY MAC LOOP",1)
replace street=subinstr(street,"MARYMAC LOOP","MARY MAC LOOP",1)

replace location=subinstr(location,"NORTH HIGH ST","N HIGH ST",1)
replace street=subinstr(street,"NORTH HIGH ST","N HIGH ST",1)

replace location=subinstr(location,"OAK HILLS DR","OAK HILL DR",1)
replace street=subinstr(street,"OAK HILLS DR","OAK HILL DR",1)

replace location=subinstr(location,"OLD SCHOOLHOUSE RD","OLD SCHOOL HOUSE RD",1)
replace street=subinstr(street,"OLD SCHOOLHOUSE RD","OLD SCHOOL HOUSE RD",1)

replace location=subinstr(location,"OSCELA TRAIL","OSCELA TRL",1)
replace street=subinstr(street,"OSCELA TRAIL","OSCELA TRL",1)

replace location=subinstr(location,"PALMER TERRACE","PALMER TER",1)
replace street=subinstr(street,"PALMER TERRACE","PALMER TER",1)

replace location=subinstr(location,"SASSAFRAS LN","SASSAFRASS LN",1)
replace street=subinstr(street,"SASSAFRAS LN","SASSAFRASS LN",1)

replace location=subinstr(location,"STONE WALL LN","STONEWALL LN",1)
replace street=subinstr(street,"STONE WALL LN","STONEWALL LN",1)

replace location=subinstr(location,"WALKLEY MILL","WALKLEY ML",1)
replace street=subinstr(street,"WALKLEY MILL","WALKLEY ML",1)

replace location=subinstr(location,"WEST SHORE DR","W SHORE DR",1)
replace street=subinstr(street,"WEST SHORE DR","W SHORE DR",1)

replace location=subinstr(location,"WEST WOODS DR","W WOODS DR",1)
replace street=subinstr(street,"WEST WOODS DR","W WOODS DR",1)

replace location=subinstr(location,"WHIP-POOR-WILL LN","WHIPPOORWILL LN",1)
replace street=subinstr(street,"WHIP-POOR-WILL LN","WHIPPOORWILL LN",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_clinton.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Groton specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location," HEIGHTS"," HTS",1)
replace street=subinstr(street," HEIGHTS"," HTS",1)

replace location=subinstr(location," (GLP)","",1)
replace street=subinstr(street," (GLP)","",1)

replace location=subinstr(location," (MYSTIC)","",1)
replace street=subinstr(street," (MYSTIC)","",1)

replace location=subinstr(location," (OLD MYSTIC)","",1)
replace street=subinstr(street," (OLD MYSTIC)","",1)

replace location=subinstr(location," (NOANK)","",1)
replace street=subinstr(street," (NOANK)","",1)

replace location=subinstr(location," (CITY)","",1)
replace street=subinstr(street," (CITY)","",1)

replace location=subinstr(location,"CIR AVE","CIRCLE AVE",1)
replace street=subinstr(street,"CIR AVE","CIRCLE AVE",1)

replace location=subinstr(location,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)
replace street=subinstr(street,"CLUBHOUSE PT RD","CLUBHOUSE POINT RD",1)

replace location=subinstr(location,"EAST SHORE AVE","E SHORE AVE",1)
replace street=subinstr(street,"EAST SHORE AVE","E SHORE AVE",1)

replace location=subinstr(location,"EASTERN PT RD","EASTERN POINT RD",1)
replace street=subinstr(street,"EASTERN PT RD","EASTERN POINT RD",1)

replace location=subinstr(location,"ELDREDGE ST","ELDRIDGE ST",1)
replace street=subinstr(street,"ELDREDGE ST","ELDRIDGE ST",1)

replace location=subinstr(location,"ELM ST SOUTH","ELM ST S",1)
replace street=subinstr(street,"ELM ST SOUTH","ELM ST S",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"GROTON LONG PT RD","GROTON LONG POINT RD",1)
replace street=subinstr(street,"GROTON LONG PT RD","GROTON LONG POINT RD",1)

replace location=subinstr(location,"HALEY CRESCENT","HALEY CRES",1)
replace street=subinstr(street,"HALEY CRESCENT","HALEY CRES",1)

replace location=subinstr(location,"HYROCK TERR","HYROCK TER",1)
replace street=subinstr(street,"HYROCK TERR","HYROCK TER",1)

replace location=subinstr(location,"ISLAND CIR NORTH","ISLAND CIR N",1)
replace street=subinstr(street,"ISLAND CIR NORTH","ISLAND CIR N",1)

replace location=subinstr(location,"ISLAND CIR SOUTH","ISLAND CIR S",1)
replace street=subinstr(street,"ISLAND CIR SOUTH","ISLAND CIR S",1)

replace location=subinstr(location,"JUPITER PT RD","JUPITER POINT RD",1)
replace street=subinstr(street,"JUPITER PT RD","JUPITER POINT RD",1)

replace location=subinstr(location,"NORTH PROSPECT ST","N PROSPECT ST",1)
replace street=subinstr(street,"NORTH PROSPECT ST","N PROSPECT ST",1)

replace location=subinstr(location,"ORCHARD LN","ORCHARD ST",1)
replace street=subinstr(street,"ORCHARD LN","ORCHARD ST",1)

replace location=subinstr(location,"PALMERS COVE DR","PALMERS COVE RD",1)
replace street=subinstr(street,"PALMERS COVE DR","PALMERS COVE RD",1)

replace location=subinstr(location,"POTTER CT","POTTER ST",1)
replace street=subinstr(street,"POTTER CT","POTTER ST",1)

replace location=subinstr(location,"SOUND VIEW RD","SOUNDVIEW RD",1)
replace street=subinstr(street,"SOUND VIEW RD","SOUNDVIEW RD",1)

replace location=subinstr(location,"SOUTH PROSPECT ST","S PROSPECT ST",1)
replace street=subinstr(street,"SOUTH PROSPECT ST","S PROSPECT ST",1)

replace location=subinstr(location,"SOUTH SHORE AVE","S SHORE AVE",1)
replace street=subinstr(street,"SOUTH SHORE AVE","S SHORE AVE",1)

replace location=subinstr(location,"ST JOSEPH CT","SAINT JOSEPH CT",1)
replace street=subinstr(street,"ST JOSEPH CT","SAINT JOSEPH CT",1)

replace location=subinstr(location,"ST PAUL CT","SAINT PAUL CT",1)
replace street=subinstr(street,"ST PAUL CT","SAINT PAUL CT",1)

replace location=subinstr(location,"STRIBL LN","STRIBLE LN",1)
replace street=subinstr(street,"STRIBL LN","STRIBLE LN",1)

replace location=subinstr(location,"TER AVE","TERRACE AVE",1)
replace street=subinstr(street,"TER AVE","TERRACE AVE",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST MYSTIC AVE","W MYSTIC AVE",1)
replace street=subinstr(street,"WEST MYSTIC AVE","W MYSTIC AVE",1)

replace location=subinstr(location,"WEST SHORE AVE","W SHORE AVE",1)
replace street=subinstr(street,"WEST SHORE AVE","W SHORE AVE",1)

replace location=subinstr(location,"WESTVIEW AVE","W VIEW AVE",1)
replace street=subinstr(street,"WESTVIEW AVE","W VIEW AVE",1)

replace location=subinstr(location,"BAKER AVE EXT","BAKER AVENUE EXT",1)
replace street=subinstr(street,"BAKER AVE EXT","BAKER AVENUE EXT",1)

replace location=subinstr(location,"BREEZY KNOLL DR","BREEZY KNLS",1)
replace street=subinstr(street,"BREEZY KNOLL DR","BREEZY KNLS",1)

replace location=subinstr(location,"BROAD ST EXT","BROAD STREET EXT",1)
replace street=subinstr(street,"BROAD ST EXT","BROAD STREET EXT",1)

replace location=subinstr(location,"CAROLE CT","CAROL CT",1)
replace street=subinstr(street,"CAROLE CT","CAROL CT",1)

replace location=subinstr(location,"CHESEBROUGH FARM RD","CHESEBOROUGH FARM RD",1)
replace street=subinstr(street,"CHESEBROUGH FARM RD","CHESEBOROUGH FARM RD",1)

replace location=subinstr(location,"CRYSTAL LNKE RD","CRYSTAL LAKE RD",1)
replace street=subinstr(street,"CRYSTAL LNKE RD","CRYSTAL LAKE RD",1)

replace location=subinstr(location,"ISLAND CIRCLE NORTH","ISLAND CIR N",1)
replace street=subinstr(street,"ISLAND CIRCLE NORTH","ISLAND CIR N",1)

replace location=subinstr(location,"KNOTTS LNNDING CIR","KNOTTS LANDING CIR",1)
replace street=subinstr(street,"KNOTTS LNNDING CIR","KNOTTS LANDING CIR",1)

replace location=subinstr(location,"LARCHMONT TERR","LARCHMONT TER",1)
replace street=subinstr(street,"LARCHMONT TERR","LARCHMONT TER",1)

replace location=subinstr(location,"MARK TRAIL","MARK TRL",1)
replace street=subinstr(street,"MARK TRAIL","MARK TRL",1)

replace location=subinstr(location,"MERIDIAN ST EXT","MERIDIAN STREET EXT",1)
replace street=subinstr(street,"MERIDIAN ST EXT","MERIDIAN STREET EXT",1)

replace location=subinstr(location,"MORGAN POINT","MORGAN PT",1)
replace street=subinstr(street,"MORGAN POINT","MORGAN PT",1)

replace location=subinstr(location,"MOUNTAIN LNUREL RD","MOUNTAIN LAUREL RD",1)
replace street=subinstr(street,"MOUNTAIN LNUREL RD","MOUNTAIN LAUREL RD",1)

replace location=subinstr(location,"NORTH GUNGYWAMP RD","N GUNGYWAMP RD",1)
replace street=subinstr(street,"NORTH GUNGYWAMP RD","N GUNGYWAMP RD",1)

replace location=subinstr(location,"NORTH STONINGTON RD","N STONINGTON RD",1)
replace street=subinstr(street,"NORTH STONINGTON RD","N STONINGTON RD",1)

replace location=subinstr(location,"ORCHARD ST","ORCHARD LN",1)
replace street=subinstr(street,"ORCHARD ST","ORCHARD LN",1)

replace location=subinstr(location,"ORCHARD TERR","ORCHARD TER",1)
replace street=subinstr(street,"ORCHARD TERR","ORCHARD TER",1)

replace location=subinstr(location,"PHILLIPS AVE EXT","PHILLIPS AVE",1)
replace street=subinstr(street,"PHILLIPS AVE EXT","PHILLIPS AVE",1)

replace location=subinstr(location,"PLEASANT VALLEY RD NORTH","PLEASANT VALLEY RD N",1)
replace street=subinstr(street,"PLEASANT VALLEY RD NORTH","PLEASANT VALLEY RD N",1)

replace location=subinstr(location,"PLYMOUTH AVE SOUTH","PLYMOUTH AVE S",1)
replace street=subinstr(street,"PLYMOUTH AVE SOUTH","PLYMOUTH AVE S",1)

replace location=subinstr(location,"PLYMOUTH AVE WEST","PLYMOUTH AVE W",1)
replace street=subinstr(street,"PLYMOUTH AVE WEST","PLYMOUTH AVE W",1)

replace location=subinstr(location,"RUSS SIMS HTS","RUSS SIM HTS",1)
replace street=subinstr(street,"RUSS SIMS HTS","RUSS SIM HTS",1)

replace location=subinstr(location,"SKYVIEW TERR","SKYVIEW TER",1)
replace street=subinstr(street,"SKYVIEW TERR","SKYVIEW TER",1)

replace location=subinstr(location,"SLOCOMB TERR","SLOCOMB TER",1)
replace street=subinstr(street,"SLOCOMB TERR","SLOCOMB TER",1)

replace location=subinstr(location,"SUNNYSIDE PK","SUNNYSIDE PARK",1)
replace street=subinstr(street,"SUNNYSIDE PK","SUNNYSIDE PARK",1)

replace location=subinstr(location,"WEST ELDERKIN AVE","W ELDERKIN AVE",1)
replace street=subinstr(street,"WEST ELDERKIN AVE","W ELDERKIN AVE",1)

replace location=subinstr(location,"WOODLAND DR EAST","WOODLAND DR E",1)
replace street=subinstr(street,"WOODLAND DR EAST","WOODLAND DR E",1)

replace location=subinstr(location,"WOODLAND DR WEST","WOODLAND DR",1)
replace street=subinstr(street,"WOODLAND DR WEST","WOODLAND DR",1)


gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_groton.dta",replace

*******East Haven********
use "$GIS\propbrev_wf_easthaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
ren house_no addressnum

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"TERR","TER",1)
replace street=subinstr(street,"TERR","TER",1)

replace location=subinstr(location,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)
replace street=subinstr(street,"COSEY BEACH AVE EXT","COSEY BEACH AVENUE EXT",1)

replace location=subinstr(location,"PALMETTO TR","PALMETTO TRL",1)
replace street=subinstr(street,"PALMETTO TR","PALMETTO TRL",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)
replace street=subinstr(street,"MANSFIELD GROVE CAMPER","MANSFIELD GROVE RD",1)

replace location=subinstr(location,"COLD SPRING ST","COLD SPRING AVE",1)
replace street=subinstr(street,"COLD SPRING ST","COLD SPRING AVE",1)

replace location=subinstr(location,"SENECA TR","SENECA TRL",1)
replace street=subinstr(street,"SENECA TR","SENECA TRL",1)

replace location=subinstr(location,"WHITMAN AVE","WHITMAN ST",1)
replace street=subinstr(street,"WHITMAN AVE","WHITMAN ST",1)

replace location=subinstr(location,"ATWATER ST EXT","ATWATER STREET EXT",1)
replace street=subinstr(street,"ATWATER ST EXT","ATWATER STREET EXT",1)

replace location=subinstr(location,"WHALERS POINT RD","WHALERS PT",1)
replace street=subinstr(street,"WHALERS POINT RD","WHALERS PT",1)

replace location=subinstr(location,"NORTH ATWATER ST","N ATWATER ST",1)
replace street=subinstr(street,"NORTH ATWATER ST","N ATWATER ST",1)

replace location=subinstr(location,"ELLIOTT ST","ELLIOT ST",1)
replace street=subinstr(street,"ELLIOTT ST","ELLIOT ST",1)

replace location=subinstr(location,"PISCITELLI CIR","PISCETELLI CIR",1)
replace street=subinstr(street,"PISCITELLI CIR","PISCETELLI CIR",1)

replace location=subinstr(location,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)
replace street=subinstr(street,"THREE STONE PILLARS RD","THREE STONE PILLAR RD",1)

replace location=subinstr(location,"ARTHUR RD","ARTHUR CT",1)
replace street=subinstr(street,"ARTHUR RD","ARTHUR CT",1)

replace location=subinstr(location,"FOREST ST EXT","FOREST STREET EXT",1)
replace street=subinstr(street,"FOREST ST EXT","FOREST STREET EXT",1)

replace location=subinstr(location,"FRANCIS ST EXT","FRANCIS STREET EXT",1)
replace street=subinstr(street,"FRANCIS ST EXT","FRANCIS STREET EXT",1)

replace location=subinstr(location,"GRANNISS ST","GRANNIS ST",1)
replace street=subinstr(street,"GRANNISS ST","GRANNIS ST",1)

replace location=subinstr(location,"HOTCHKISS RD EXT","HOTCHKISS ROAD EXT",1)
replace street=subinstr(street,"HOTCHKISS RD EXT","HOTCHKISS ROAD EXT",1)

replace location=subinstr(location,"JEFFRY RD","JEFFREY RD",1)
replace street=subinstr(street,"JEFFRY RD","JEFFREY RD",1)

replace location=subinstr(location,"JOSHUAS TR","JOSHUAS TRL",1)
replace street=subinstr(street,"JOSHUAS TR","JOSHUAS TRL",1)

replace location=subinstr(location,"MT VIEW TER","MOUNTAIN VIEW TER",1)
replace street=subinstr(street,"MT VIEW TER","MOUNTAIN VIEW TER",1)

replace location=subinstr(location,"NORTH HIGH ST","N HIGH ST",1)
replace street=subinstr(street,"NORTH HIGH ST","N HIGH ST",1)

replace location=subinstr(location,"OAKHILL DR","OAK HILL DR",1)
replace street=subinstr(street,"OAKHILL DR","OAK HILL DR",1)

replace location=subinstr(location,"PARDEE PL EXT","PARDEE PLACE EXT",1)
replace street=subinstr(street,"PARDEE PL EXT","PARDEE PLACE EXT",1)

replace location=subinstr(location,"PERSHING AVE","PERSHING ST",1)
replace street=subinstr(street,"PERSHING AVE","PERSHING ST",1)

replace location=subinstr(location,"PROSPECT PL EXT","PROSPECT PLACE EXT",1)
replace street=subinstr(street,"PROSPECT PL EXT","PROSPECT PLACE EXT",1)

replace location=subinstr(location,"ROSE ST EXT","ROSE STREET EXT",1)
replace street=subinstr(street,"ROSE ST EXT","ROSE STREET EXT",1)

replace location=subinstr(location,"SIDNEY ST EXT","SIDNEY STREET EXT",1)
replace street=subinstr(street,"SIDNEY ST EXT","SIDNEY STREET EXT",1)

replace location=subinstr(location,"SOUTH DALE ST","S DALE ST",1)
replace street=subinstr(street,"SOUTH DALE ST","S DALE ST",1)

replace location=subinstr(location,"SOUTH STRONG ST","S STRONG ST",1)
replace street=subinstr(street,"SOUTH STRONG ST","S STRONG ST",1)

replace location=subinstr(location,"ST ANDREW AVE","SAINT ANDREW AVE",1)
replace street=subinstr(street,"ST ANDREW AVE","SAINT ANDREW AVE",1)

replace location=subinstr(location,"ST ANDREW CT","SAINT ANDREW CT",1)
replace street=subinstr(street,"ST ANDREW CT","SAINT ANDREW CT",1)

replace location=subinstr(location,"ST PAUL AVE","SAINT PAUL AVE",1)
replace street=subinstr(street,"ST PAUL AVE","SAINT PAUL AVE",1)

replace location=subinstr(location,"STRONG ST EXT","STRONG STREET EXT",1)
replace street=subinstr(street,"STRONG ST EXT","STRONG STREET EXT",1)

replace location=subinstr(location,"TALMADGE ST","TALMADGE AVE",1)
replace street=subinstr(street,"TALMADGE ST","TALMADGE AVE",1)

replace location=subinstr(location,"THORNTON DR","THORNTON ST",1)
replace street=subinstr(street,"THORNTON DR","THORNTON ST",1)

replace location=subinstr(location,"ARTHUR CT","ARTHUR RD",1)
replace street=subinstr(street,"ARTHUR CT","ARTHUR RD",1)


gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

duplicates report PropertyFullStreetAddress PropertyCity ImportParcelID
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID,force

save "$dta\pointcheck_NONVA_easthaven.dta",replace

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

browse if trim(PropertyStreet)!=trim(street)
order street PropertyStreet
sort street

replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*East Lyme specific
replace location=subinstr(location,"ALEWIFE PW","ALEWIFE PKWY",1)
replace street=subinstr(street,"ALEWIFE PW","ALEWIFE PKWY",1)

replace location=subinstr(location,"ARCADIAN RD GNB","ARCADIA RD",1)
replace street=subinstr(street,"ARCADIAN RD GNB","ARCADIA RD",1)

replace location=subinstr(location,"ATLANTIC ST CB","ATLANTIC ST",1)
replace street=subinstr(street,"ATLANTIC ST CB","ATLANTIC ST",1)

replace location=subinstr(location,"ATTAWAN AVE","ATTAWAN RD",1)
replace street=subinstr(street,"ATTAWAN AVE","ATTAWAN RD",1)

replace location=subinstr(location,"BARRETT DR OGBA","BARRETT DR",1)
replace street=subinstr(street,"BARRETT DR OGBA","BARRETT DR",1)

replace location=subinstr(location,"BAY VIEW RD GNH","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW RD GNH","BAYVIEW RD",1)

replace location=subinstr(location,"BAYVIEW AVE CB","BAYVIEW AVE",1)
replace street=subinstr(street,"BAYVIEW AVE CB","BAYVIEW AVE",1)

replace location=subinstr(location,"BEACH AVE CB","BEACH AVE",1)
replace street=subinstr(street,"BEACH AVE CB","BEACH AVE",1)

replace location=subinstr(location,"BELLAIRE RD BPBC","BELLAIRE RD",1)
replace street=subinstr(street,"BELLAIRE RD BPBC","BELLAIRE RD",1)

replace location=subinstr(location,"BILLOW RD BPBC","BILLOW RD",1)
replace street=subinstr(street,"BILLOW RD BPBC","BILLOW RD",1)

replace location=subinstr(location,"BLACK PT RD","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD","BLACK POINT RD",1)

replace location=subinstr(location,"BLACK PT RD CB","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD CB","BLACK POINT RD",1)

replace location=subinstr(location,"BOND ST BPBC","BOND ST",1)
replace street=subinstr(street,"BOND ST BPBC","BOND ST",1)

replace location=subinstr(location,"BRAINERD RD","BRAINARD RD",1)
replace street=subinstr(street,"BRAINERD RD","BRAINARD RD",1)

replace location=subinstr(location,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)
replace street=subinstr(street,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)

replace location=subinstr(location,"BROCKETT RD GNB","BROCKETT RD",1)
replace street=subinstr(street,"BROCKETT RD GNB","BROCKETT RD",1)

replace location=subinstr(location,"CARPENTER AVE CB","CARPENTER AVE",1)
replace street=subinstr(street,"CARPENTER AVE CB","CARPENTER AVE",1)

replace location=subinstr(location,"CENTRAL AVE CB","CENTRAL AVE",1)
replace street=subinstr(street,"CENTRAL AVE CB","CENTRAL AVE",1)

replace location=subinstr(location,"COLUMBUS AVE CB","COLUMBUS AVE",1)
replace street=subinstr(street,"COLUMBUS AVE CB","COLUMBUS AVE",1)

replace location=subinstr(location,"COTTAGE LN BPBC","COTTAGE LN",1)
replace street=subinstr(street,"COTTAGE LN BPBC","COTTAGE LN",1)

replace location=subinstr(location,"CRAB LN CB","CRAB LN",1)
replace street=subinstr(street,"CRAB LN CB","CRAB LN",1)

replace location=subinstr(location,"CRESCENT AVE CB","CRESCENT AVE",1)
replace street=subinstr(street,"CRESCENT AVE CB","CRESCENT AVE",1)

replace location=subinstr(location,"E SHORE DR BPBC","E SHORE DR",1)
replace street=subinstr(street,"E SHORE DR BPBC","E SHORE DR",1)

replace location=subinstr(location,"EDGE HILL RD GNH","EDGE HILL RD",1)
replace street=subinstr(street,"EDGE HILL RD GNH","EDGE HILL RD",1)

replace location=subinstr(location,"FULLER CT CB","FULLER CT",1)
replace street=subinstr(street,"FULLER CT CB","FULLER CT",1)

replace location=subinstr(location,"GLENWOOD PARK NO","GLENWOOD PARK N",1)
replace street=subinstr(street,"GLENWOOD PARK NO","GLENWOOD PARK N",1)

replace location=subinstr(location,"GLENWOOD PARK SO","GLENWOOD PARK S",1)
replace street=subinstr(street,"GLENWOOD PARK SO","GLENWOOD PARK S",1)

replace location=subinstr(location,"GRISWOLD DR GNH","GRISWOLD DR",1)
replace street=subinstr(street,"GRISWOLD DR GNH","GRISWOLD DR",1)

replace location=subinstr(location,"GRISWOLD RD GNB","GRISWOLD RD",1)
replace street=subinstr(street,"GRISWOLD RD GNB","GRISWOLD RD",1)

replace location=subinstr(location,"GROVE AVE CB","GROVE AVE",1)
replace street=subinstr(street,"GROVE AVE CB","GROVE AVE",1)

replace location=subinstr(location,"GROVEDALE RD GNB","GROVEDALE RD",1)
replace street=subinstr(street,"GROVEDALE RD GNB","GROVEDALE RD",1)

replace location=subinstr(location,"HILLCREST RD GNH","HILLCREST RD",1)
replace street=subinstr(street,"HILLCREST RD GNH","HILLCREST RD",1)

replace location=subinstr(location,"HILLSIDE AVE CB","HILLSIDE AVE",1)
replace street=subinstr(street,"HILLSIDE AVE CB","HILLSIDE AVE",1)

replace location=subinstr(location,"HILLTOP RD GNB","HILLTOP RD",1)
replace street=subinstr(street,"HILLTOP RD GNB","HILLTOP RD",1)

replace location=subinstr(location,"HOPE ST (REAR)","HOPE ST",1)
replace street=subinstr(street,"HOPE ST (REAR)","HOPE ST",1)

replace location=subinstr(location,"INDIAN ROCKS RD","INDIAN ROCK RD",1)
replace street=subinstr(street,"INDIAN ROCKS RD","INDIAN ROCK RD",1)

replace location=subinstr(location,"INDIANOLA RD BPBC","INDIANOLA RD",1)
replace street=subinstr(street,"INDIANOLA RD BPBC","INDIANOLA RD",1)

replace location=subinstr(location,"IRVING PL CB","IRVING PL",1)
replace street=subinstr(street,"IRVING PL CB","IRVING PL",1)

replace location=subinstr(location,"JO-ANNE ST","JO ANNE ST",1)
replace street=subinstr(street,"JO-ANNE ST","JO ANNE ST",1)

replace location=subinstr(location,"LAKE AVE EXT","LAKE AVENUE EXT",1)
replace street=subinstr(street,"LAKE AVE EXT","LAKE AVENUE EXT",1)

replace location=subinstr(location,"LAKE SHORE DR GNB","LAKE SHORE DR",1)
replace street=subinstr(street,"LAKE SHORE DR GNB","LAKE SHORE DR",1)

replace location=subinstr(location,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)
replace street=subinstr(street,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)

replace location=subinstr(location,"LEE FARM DR GNH","LEE FARM DR",1)
replace street=subinstr(street,"LEE FARM DR GNH","LEE FARM DR",1)

replace location=subinstr(location,"MAMACOCK RD GNB","MAMACOCK RD",1)
replace street=subinstr(street,"MAMACOCK RD GNB","MAMACOCK RD",1)

replace location=subinstr(location,"MANWARING RD OGBA","MANWARING RD",1)
replace street=subinstr(street,"MANWARING RD OGBA","MANWARING RD",1)

replace location=subinstr(location,"MARSHFIELD RD GNH","MARSHFIELD RD",1)
replace street=subinstr(street,"MARSHFIELD RD GNH","MARSHFIELD RD",1)

replace location=subinstr(location,"NEHANTIC DR BPBC","NEHANTIC DR",1)
replace street=subinstr(street,"NEHANTIC DR BPBC","NEHANTIC DR",1)

replace location=subinstr(location,"NILES CREEK RD GNB","NILES CREEK RD",1)
replace street=subinstr(street,"NILES CREEK RD GNB","NILES CREEK RD",1)

replace location=subinstr(location,"NORTH AVE CB","NORTH AVE",1)
replace street=subinstr(street,"NORTH AVE CB","NORTH AVE",1)

replace location=subinstr(location,"NORTH DR OGBA","NORTH DR",1)
replace street=subinstr(street,"NORTH DR OGBA","NORTH DR",1)

replace location=subinstr(location,"OAKWOOD RD GNH","OAKWOOD RD",1)
replace street=subinstr(street,"OAKWOOD RD GNH","OAKWOOD RD",1)

replace location=subinstr(location,"OCEAN AVE CB","OCEAN AVE",1)
replace street=subinstr(street,"OCEAN AVE CB","OCEAN AVE",1)

replace location=subinstr(location,"OLD BLACK PT RD","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OSPREY LN GNH","OSPREY LN",1)
replace street=subinstr(street,"OSPREY LN GNH","OSPREY LN",1)

replace location=subinstr(location,"OSPREY RD BPBC","OSPREY RD",1)
replace street=subinstr(street,"OSPREY RD BPBC","OSPREY RD",1)

replace location=subinstr(location,"PALLETTE AVE BPBC","PALLETTE DR",1)
replace street=subinstr(street,"PALLETTE AVE BPBC","PALLETTE DR",1)

replace location=subinstr(location,"PARK CT BPBC","PARK CT",1)
replace street=subinstr(street,"PARK CT BPBC","PARK CT",1)

replace location=subinstr(location,"PARK LN GNH","PARK LN",1)
replace street=subinstr(street,"PARK LN GNH","PARK LN",1)

replace location=subinstr(location,"PARK VIEW DR GNH","PARKVIEW DR",1)
replace street=subinstr(street,"PARK VIEW DR GNH","PARKVIEW DR",1)

replace location=subinstr(location,"PARKWAY NORTH","PARKWAY N",1)
replace street=subinstr(street,"PARKWAY NORTH","PARKWAY N",1)

replace location=subinstr(location,"PARKWAY SOUTH","PARKWAY S",1)
replace street=subinstr(street,"PARKWAY SOUTH","PARKWAY S",1)

replace location=subinstr(location,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)
replace street=subinstr(street,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)

replace location=subinstr(location,"POINT RD GNB","POINT RD",1)
replace street=subinstr(street,"POINT RD GNB","POINT RD",1)

replace location=subinstr(location,"PROSPECT AVE CB","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AVE CB","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)
replace street=subinstr(street,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)

replace location=subinstr(location,"RIDGE TR BPBC","RIDGE TRL",1)
replace street=subinstr(street,"RIDGE TR BPBC","RIDGE TRL",1)

replace location=subinstr(location,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)
replace street=subinstr(street,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)

replace location=subinstr(location,"ROCKBOURNE AVE","ROCKBOURNE LN",1)
replace street=subinstr(street,"ROCKBOURNE AVE","ROCKBOURNE LN",1)

replace location=subinstr(location,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)
replace street=subinstr(street,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)

replace location=subinstr(location,"S LEE RD GNB","S LEE RD",1)
replace street=subinstr(street,"S LEE RD GNB","S LEE RD",1)

replace location=subinstr(location,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)
replace street=subinstr(street,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)

replace location=subinstr(location,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)
replace street=subinstr(street,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)

replace location=subinstr(location,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)
replace street=subinstr(street,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)

replace location=subinstr(location,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)
replace street=subinstr(street,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)

replace location=subinstr(location,"SEA VIEW LN GNH","SEA VIEW LN",1)
replace street=subinstr(street,"SEA VIEW LN GNH","SEA VIEW LN",1)

replace location=subinstr(location,"SHERMAN CT CB","SHERMAN CT",1)
replace street=subinstr(street,"SHERMAN CT CB","SHERMAN CT",1)

replace location=subinstr(location,"SHORE RD OGBA","SHORE RD",1)
replace street=subinstr(street,"SHORE RD OGBA","SHORE RD",1)

replace location=subinstr(location,"SOUTH DR OGBA","SOUTH DR",1)
replace street=subinstr(street,"SOUTH DR OGBA","SOUTH DR",1)

replace location=subinstr(location,"SOUTH TR","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR","SOUTH TRL",1)

replace location=subinstr(location,"SOUTH TR BPBC","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR BPBC","SOUTH TRL",1)

replace location=subinstr(location,"SPENCER AVE CB","SPENCER AVE",1)
replace street=subinstr(street,"SPENCER AVE CB","SPENCER AVE",1)

replace location=subinstr(location,"SPRING GLEN RD GNH","SPRING GLEN RD",1)
replace street=subinstr(street,"SPRING GLEN RD GNH","SPRING GLEN RD",1)

replace location=subinstr(location,"SUNRISE AVE BPBC","SUNRISE AVE",1)
replace street=subinstr(street,"SUNRISE AVE BPBC","SUNRISE AVE",1)

replace location=subinstr(location,"SUNSET AVE BPBC","SUNSET AVE",1)
replace street=subinstr(street,"SUNSET AVE BPBC","SUNSET AVE",1)

replace location=subinstr(location,"TABERNACLE AVE CB","TABERNACLE AVE",1)
replace street=subinstr(street,"TABERNACLE AVE CB","TABERNACLE AVE",1)

replace location=subinstr(location,"TERRACE AVE CB","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE CB","TERRACE AVE",1)

replace location=subinstr(location,"TERRACE AVE OGBA","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE OGBA","TERRACE AVE",1)

replace location=subinstr(location,"UNCAS RD BPBC","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD BPBC","UNCAS RD",1)

replace location=subinstr(location,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)
replace street=subinstr(street,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)

replace location=subinstr(location,"WATERSIDE AVE BPBC","WATERSIDE RD",1)
replace street=subinstr(street,"WATERSIDE AVE BPBC","WATERSIDE RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"WESTOMERE TR","WESTOMERE TER",1)
replace street=subinstr(street,"WESTOMERE TR","WESTOMERE TER",1)

replace location=subinstr(location,"WHITECAP RD BPBC","WHITECAP RD",1)
replace street=subinstr(street,"WHITECAP RD BPBC","WHITECAP RD",1)

replace location=subinstr(location,"WHITTLESEY PL","WHITTLESAY PL",1)
replace street=subinstr(street,"WHITTLESEY PL","WHITTLESAY PL",1)

replace location=subinstr(location,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)
replace street=subinstr(street,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)

replace location=subinstr(location,"WOODLAND DR BPBC","WOODLAND DR",1)
replace street=subinstr(street,"WOODLAND DR BPBC","WOODLAND DR",1)

replace location=subinstr(location,"DARROWS RIDGE RD","DARROWS RDG",1)
replace street=subinstr(street,"DARROWS RIDGE RD","DARROWS RDG",1)

replace location=subinstr(location,"GOLDFINCH TERR","GOLDFINCH TER",1)
replace street=subinstr(street,"GOLDFINCH TERR","GOLDFINCH TER",1)

replace location=subinstr(location,"PLUM HILL","PLUM HL",1)
replace street=subinstr(street,"PLUM HILL","PLUM HL",1)

replace location=subinstr(location,"APPLEWOOD COMMON","APPLEWOOD CMN",1)
replace street=subinstr(street,"APPLEWOOD COMMON","APPLEWOOD CMN",1)

replace location=subinstr(location,"ARBOR CROSSING","ARBOR XING",1)
replace street=subinstr(street,"ARBOR CROSSING","ARBOR XING",1)

replace location=subinstr(location,"BLACK POINT RD CB","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK POINT RD CB","BLACK POINT RD",1)

replace location=subinstr(location,"BRAMBLEBUSH DR","BRAMBLE BUSH DR",1)
replace street=subinstr(street,"BRAMBLEBUSH DR","BRAMBLE BUSH DR",1)

replace location=subinstr(location,"COVE HILL RD (PRIVATE)","COVE HILL RD",1)
replace street=subinstr(street,"COVE HILL RD (PRIVATE)","COVE HILL RD",1)

replace location=subinstr(location,"DARROWS RIDGE RD","DARROWS RDG",1)
replace street=subinstr(street,"DARROWS RIDGE RD","DARROWS RDG",1)

replace location=subinstr(location,"EAST RD","EAST ST",1)
replace street=subinstr(street,"EAST RD","EAST ST",1)

replace location=subinstr(location,"FROGS HOLLOW RD","FROG HOLLOW RD",1)
replace street=subinstr(street,"FROGS HOLLOW RD","FROG HOLLOW RD",1)

replace location=subinstr(location,"GOLDFINCH TERR","GOLDFINCH TER",1)
replace street=subinstr(street,"GOLDFINCH TERR","GOLDFINCH TER",1)

replace location=subinstr(location,"GREEN CLIFF RD","GREENCLIFF DR",1)
replace street=subinstr(street,"GREEN CLIFF RD","GREENCLIFF DR",1)

replace location=subinstr(location,"GREEN VALLEY LKS","GREEN VALLEY LAKE RD",1)
replace street=subinstr(street,"GREEN VALLEY LKS","GREEN VALLEY LAKE RD",1)

replace location=subinstr(location,"HARVEST GLEN","HARVEST GLN",1)
replace street=subinstr(street,"HARVEST GLEN","HARVEST GLN",1)

replace location=subinstr(location,"INDIAN WOODS RD","INDIAN WOOD RD",1)
replace street=subinstr(street,"INDIAN WOODS RD","INDIAN WOOD RD",1)

replace location=subinstr(location,"JUNIPER HILL","JUNIPER HL",1)
replace street=subinstr(street,"JUNIPER HILL","JUNIPER HL",1)

replace location=subinstr(location,"MAYFIELD TERR","MAYFIELD TER",1)
replace street=subinstr(street,"MAYFIELD TERR","MAYFIELD TER",1)

replace location=subinstr(location,"NEHANTIC TR","NEHANTIC TRL",1)
replace street=subinstr(street,"NEHANTIC TR","NEHANTIC TRL",1)

replace location=subinstr(location,"OLD BLACK POINT RD (REAR)","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK POINT RD (REAR)","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OVERBROOK RD","OVER BROOK RD",1)
replace street=subinstr(street,"OVERBROOK RD","OVER BROOK RD",1)

replace location=subinstr(location,"PEAR GROVE","PEAR GRV",1)
replace street=subinstr(street,"PEAR GROVE","PEAR GRV",1)

replace location=subinstr(location,"PLUM HILL","PLUM HL",1)
replace street=subinstr(street,"PLUM HILL","PLUM HL",1)

replace location=subinstr(location,"PUMPKIN GROVE","PUMPKIN GRV",1)
replace street=subinstr(street,"PUMPKIN GROVE","PUMPKIN GRV",1)

replace location=subinstr(location,"RIVER HEAD LN","RIVERHEAD LN",1)
replace street=subinstr(street,"RIVER HEAD LN","RIVERHEAD LN",1)

replace location=subinstr(location,"SOUTH TRL BPBC","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TRL BPBC","SOUTH TRL",1)

replace location=subinstr(location,"STONE RANCH RD (REAR)","STONE RANCH RD",1)
replace street=subinstr(street,"STONE RANCH RD (REAR)","STONE RANCH RD",1)

replace location=subinstr(location,"STONECLIFFE DR","STONE CLIFF DR",1)
replace street=subinstr(street,"STONECLIFFE DR","STONE CLIFF DR",1)

replace location=subinstr(location,"STONEY WOOD DR","STONEYWOOD DR",1)
replace street=subinstr(street,"STONEY WOOD DR","STONEYWOOD DR",1)

replace location=subinstr(location,"SUNRISE TR","SUNRISE TRL",1)
replace street=subinstr(street,"SUNRISE TR","SUNRISE TRL",1)

replace location=subinstr(location,"SYLVAN GLEN","SYLVAN GLEN DR",1)
replace street=subinstr(street,"SYLVAN GLEN","SYLVAN GLEN DR",1)

replace location=subinstr(location,"VALLEY VIEW RD","VALLEY VIEW DR",1)
replace street=subinstr(street,"VALLEY VIEW RD","VALLEY VIEW DR",1)

replace location=subinstr(location,"WALNUT HILL RD(REAR)","WALNUT HILL RD",1)
replace street=subinstr(street,"WALNUT HILL RD(REAR)","WALNUT HILL RD",1)

replace location=subinstr(location,"WESTCHESTER","WESTCHESTER DR",1)
replace street=subinstr(street,"WESTCHESTER","WESTCHESTER DR",1)

replace location=subinstr(location,"WHISTLETOWN RD","WHISTLE TOWN RD",1)
replace street=subinstr(street,"WHISTLETOWN RD","WHISTLE TOWN RD",1)

replace location=subinstr(location,"WINCHESTER CT N","N WINCHESTER CT",1)
replace street=subinstr(street,"WINCHESTER CT N","N WINCHESTER CT",1)

replace location=subinstr(location,"WINCHESTER CT S","S WINCHESTER CT",1)
replace street=subinstr(street,"WINCHESTER CT S","S WINCHESTER CT",1)

replace location=subinstr(location,"WINCHESTER ST","WINCHESTER RD",1)
replace street=subinstr(street,"WINCHESTER ST","WINCHESTER RD",1)

replace location=subinstr(location,"WINTHROP","WINTHROP DR",1)
replace street=subinstr(street,"WINTHROP","WINTHROP DR",1)

replace location=subinstr(location,"N BRIDE BROOK RD","N BRIDEBROOK RD",1) if PropertyStreet=="N BRIDEBROOK RD"
replace street=subinstr(street,"N BRIDE BROOK RD","N BRIDEBROOK RD",1) if PropertyStreet=="N BRIDEBROOK RD"

replace location=subinstr(location,"ATTAWAN RD","ATTAWAN AVE",1) if PropertyStreet=="ATTAWAN AVE"
replace street=subinstr(street,"ATTAWAN RD","ATTAWAN AVE",1) if PropertyStreet=="ATTAWAN AVE"

replace location=subinstr(location,"KENSINGTON DR","UPPER KENSINGTON DR",1) if street=="KENSINGTON DR"&PropertyStreet=="UPPER KENSINGTON DR"
replace street=subinstr(street,"KENSINGTON DR","UPPER KENSINGTON DR",1) if street=="KENSINGTON DR"&PropertyStreet=="UPPER KENSINGTON DR"


gen diff_street=(trim(PropertyStreet)!=trim(street))
gen diff_address=(trim(PropertyFullStreetAddress)!=trim(location))
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_eastlyme.dta",replace

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
replace PropertyStreet=trim(PropertyStreet)
replace street=trim(street)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Fairfield specific
replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"ANVIL RD","ANVILL RD",1)
replace street=subinstr(street,"ANVIL RD","ANVILL RD",1)

replace location=subinstr(location,"ASPETUCK FALLS","ASPETUCK FLS",1)
replace street=subinstr(street,"ASPETUCK FALLS","ASPETUCK FLS",1)

replace location=subinstr(location,"BARRY SCOTT DR","BARRYSCOTT DR",1)
replace street=subinstr(street,"BARRY SCOTT DR","BARRYSCOTT DR",1)

replace location=subinstr(location,"BEACON SQUARE","BEACON SQ",1)
replace street=subinstr(street,"BEACON SQUARE","BEACON SQ",1)

replace location=subinstr(location,"BERKELEY RD","BERKLEY RD",1) if street=="BERKELEY RD"&PropertyStreet=="BERKLEY RD"
replace street=subinstr(street,"BERKELEY RD","BERKLEY RD",1) if street=="BERKELEY RD"&PropertyStreet=="BERKLEY RD"

replace location=subinstr(location,"BERWICK AVE","BRENTWOOD AVE",1) if street=="BERWICK AVE"&PropertyStreet=="BRENTWOOD AVE"
replace street=subinstr(street,"BERWICK AVE","BRENTWOOD AVE",1) if street=="BERWICK AVE"&PropertyStreet=="BRENTWOOD AVE"

replace location=subinstr(location,"BLACK ROCK TURNPIKE","BLACK ROCK TPKE",1)
replace street=subinstr(street,"BLACK ROCK TURNPIKE","BLACK ROCK TPKE",1)

replace location=subinstr(location,"BLUE RIDGE RD","BLUERIDGE RD",1)
replace street=subinstr(street,"BLUE RIDGE RD","BLUERIDGE RD",1)

replace location=subinstr(location,"BOROSKEY RD","BOROSKEY DR",1)
replace street=subinstr(street,"BOROSKEY RD","BOROSKEY DR",1)

replace location=subinstr(location,"BRAMBLEY HEDGE CIR","BRAMBLY HEDGE CIR",1)
replace street=subinstr(street,"BRAMBLEY HEDGE CIR","BRAMBLY HEDGE CIR",1)

replace location=subinstr(location,"BRIDLE TRAIL","BRIDLE TRL",1)
replace street=subinstr(street,"BRIDLE TRAIL","BRIDLE TRL",1)

replace location=subinstr(location,"BROOKLAWN PARKWAY","BROOKLAWN PKWY",1)
replace street=subinstr(street,"BROOKLAWN PARKWAY","BROOKLAWN PKWY",1)

replace location=subinstr(location,"BUCK BOARD LN","BUCKBOARD LN",1)
replace street=subinstr(street,"BUCK BOARD LN","BUCKBOARD LN",1)

replace location=subinstr(location,"BURRWOOD COMMON","BURRWOOD CMN",1)
replace street=subinstr(street,"BURRWOOD COMMON","BURRWOOD CMN",1)

replace location=subinstr(location,"CAPUANO'S COVE","CAPUANO CV",1)
replace street=subinstr(street,"CAPUANO'S COVE","CAPUANO CV",1)

replace location=subinstr(location,"CEDAR WOOD LN","CEDAR WOODS LN",1)
replace street=subinstr(street,"CEDAR WOOD LN","CEDAR WOODS LN",1)

replace location=subinstr(location,"CROSS HIGHWAY","CROSS HWY",1)
replace street=subinstr(street,"CROSS HIGHWAY","CROSS HWY",1)

replace location=subinstr(location,"DAYBREAK RD","DAYBREAK LN",1)
replace street=subinstr(street,"DAYBREAK RD","DAYBREAK LN",1)

replace location=subinstr(location,"DEEP WOOD RD","DEEPWOOD RD",1)
replace street=subinstr(street,"DEEP WOOD RD","DEEPWOOD RD",1)

replace location=subinstr(location,"DEER RUN","DEER RUN RD",1)
replace street=subinstr(street,"DEER RUN","DEER RUN RD",1)

replace location=subinstr(location,"EASTLEA LN","EASTLEA RD",1)
replace street=subinstr(street,"EASTLEA LN","EASTLEA RD",1)

replace location=subinstr(location,"EASTON TURNPIKE","EASTON TPKE",1)
replace street=subinstr(street,"EASTON TURNPIKE","EASTON TPKE",1)

replace location=subinstr(location,"EDGE HILL CT","EDGE HILL RD",1)
replace street=subinstr(street,"EDGE HILL CT","EDGE HILL RD",1)

replace location=subinstr(location,"FAIRWAY GREEN","FAIRWAY GRN",1)
replace street=subinstr(street,"FAIRWAY GREEN","FAIRWAY GRN",1)

replace location=subinstr(location,"FALLOW FIELD LN","FALLOWFIELD LN",1)
replace street=subinstr(street,"FALLOW FIELD LN","FALLOWFIELD LN",1)

replace location=subinstr(location,"FALLOW FIELD RD","FALLOWFIELD RD",1)
replace street=subinstr(street,"FALLOW FIELD RD","FALLOWFIELD RD",1)

replace location=subinstr(location,"FENCEROW DR","FENCE ROW DR",1)
replace street=subinstr(street,"FENCEROW DR","FENCE ROW DR",1)

replace location=subinstr(location,"FIELDCREST DR","FIELDCREST RD",1)
replace street=subinstr(street,"FIELDCREST DR","FIELDCREST RD",1)

replace location=subinstr(location,"FIELDS ROCK RD","FIELD ROCK RD",1)
replace street=subinstr(street,"FIELDS ROCK RD","FIELD ROCK RD",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOGG WOOD CIR","FOGGWOOD CIR",1)
replace street=subinstr(street,"FOGG WOOD CIR","FOGGWOOD CIR",1)

replace location=subinstr(location,"FOGG WOOD RD","FOGGWOOD RD",1)
replace street=subinstr(street,"FOGG WOOD RD","FOGGWOOD RD",1)

replace location=subinstr(location,"FULLING MILL LN","FULLING MILL LN S",1) if street=="FULLING MILL LN"&PropertyStreet=="FULLING MILL LN S"
replace street=subinstr(street,"FULLING MILL LN","FULLING MILL LN S",1) if street=="FULLING MILL LN"&PropertyStreet=="FULLING MILL LN S"

replace location=subinstr(location,"FULLING MILL LN","FULLING MILL LN N",1) if street=="FULLING MILL LN"&PropertyStreet=="FULLING MILL LN N"
replace street=subinstr(street,"FULLING MILL LN","FULLING MILL LN N",1) if street=="FULLING MILL LN"&PropertyStreet=="FULLING MILL LN N"

replace location=subinstr(location,"GILBERT HIGHWAY","GILBERT HWY",1)
replace street=subinstr(street,"GILBERT HIGHWAY","GILBERT HWY",1)

replace location=subinstr(location,"GLENARDEN DR","GLEN ARDEN DR",1)
replace street=subinstr(street,"GLENARDEN DR","GLEN ARDEN DR",1)

replace location=subinstr(location,"GLENARDEN DR SOUTH","GLEN ARDEN DR S",1)
replace street=subinstr(street,"GLENARDEN DR SOUTH","GLEN ARDEN DR S",1)

replace location=subinstr(location,"GOLF VIEW TER","GOLFVIEW TER",1)
replace street=subinstr(street,"GOLF VIEW TER","GOLFVIEW TER",1)

replace location=subinstr(location,"GREEN ACRE LN","GREEN ACRES LN",1)
replace street=subinstr(street,"GREEN ACRE LN","GREEN ACRES LN",1)

replace location=subinstr(location,"GREENBRIER CIR","GREENBRIAR CIR",1)
replace street=subinstr(street,"GREENBRIER CIR","GREENBRIAR CIR",1)

replace location=subinstr(location,"GREENBRIER RD","GREENBRIAR RD",1)
replace street=subinstr(street,"GREENBRIER RD","GREENBRIAR RD",1)

replace location=subinstr(location,"HEMLOCK HILL NORTH","HEMLOCK HILLS RD N",1)
replace street=subinstr(street,"HEMLOCK HILL NORTH","HEMLOCK HILLS RD N",1)

replace location=subinstr(location,"HEMLOCK HILL SOUTH","HEMLOCK HILLS RD S",1)
replace street=subinstr(street,"HEMLOCK HILL SOUTH","HEMLOCK HILLS RD S",1)

replace location=subinstr(location,"HIGH CIR LN","HIGH CIRCLE LN",1)
replace street=subinstr(street,"HIGH CIR LN","HIGH CIRCLE LN",1)

replace location=subinstr(location,"HIGH PT LN","HIGH POINT LN",1)
replace street=subinstr(street,"HIGH PT LN","HIGH POINT LN",1)

replace location=subinstr(location,"HOLLY DALE RD","HOLLYDALE RD",1)
replace street=subinstr(street,"HOLLY DALE RD","HOLLYDALE RD",1)

replace location=subinstr(location,"HOME FAIR DR","HOMEFAIR DR",1)
replace street=subinstr(street,"HOME FAIR DR","HOMEFAIR DR",1)

replace location=subinstr(location,"HOMESTEAD LN","HOMESTEAD RD",1)
replace street=subinstr(street,"HOMESTEAD LN","HOMESTEAD RD",1)

replace location=subinstr(location,"HULLS HIGHWAY","HULLS HWY",1)
replace street=subinstr(street,"HULLS HIGHWAY","HULLS HWY",1)

replace location=subinstr(location,"INDIAN PT RD","INDIAN POINT RD",1)
replace street=subinstr(street,"INDIAN PT RD","INDIAN POINT RD",1)

replace location=subinstr(location,"KINGS HWY","KINGS HWY E",1) if street=="KINGS HWY"&PropertyStreet=="KINGS HWY E"
replace street=subinstr(street,"KINGS HWY","KINGS HWY E",1) if street=="KINGS HWY"&PropertyStreet=="KINGS HWY E"

replace location=subinstr(location,"KINGS HWY WEST","KINGS HWY W",1)
replace street=subinstr(street,"KINGS HWY WEST","KINGS HWY W",1)

replace location=subinstr(location,"KNAPPS HIGHWAY","KNAPPS HWY",1)
replace street=subinstr(street,"KNAPPS HIGHWAY","KNAPPS HWY",1)

replace location=subinstr(location,"KNOLL, THE","THE KNLS",1)
replace street=subinstr(street,"KNOLL, THE","THE KNLS",1)

replace location=subinstr(location,"LANCELOT DR","LANCELOT RD",1)
replace street=subinstr(street,"LANCELOT DR","LANCELOT RD",1)

replace location=subinstr(location,"LAURELBROOK LN","LAUREL BROOK LN",1)
replace street=subinstr(street,"LAURELBROOK LN","LAUREL BROOK LN",1)

replace location=subinstr(location,"LITTLE BROOK RD","LITTLEBROOK RD",1)
replace street=subinstr(street,"LITTLE BROOK RD","LITTLEBROOK RD",1)

replace location=subinstr(location,"LONG MEADOW RD","LONGMEADOW RD",1)
replace street=subinstr(street,"LONG MEADOW RD","LONGMEADOW RD",1)

replace location=subinstr(location,"LOOKOUT DR NORTH","LOOKOUT DR N",1)
replace street=subinstr(street,"LOOKOUT DR NORTH","LOOKOUT DR N",1)

replace location=subinstr(location,"LOOKOUT DR SOUTH","LOOKOUT DR S",1)
replace street=subinstr(street,"LOOKOUT DR SOUTH","LOOKOUT DR S",1)

replace location=subinstr(location,"LUCILLE ST NORTH","LUCILLE ST",1) if street=="LUCILLE ST NORTH"&PropertyStreet=="LUCILLE ST"
replace street=subinstr(street,"LUCILLE ST NORTH","LUCILLE ST",1) if street=="LUCILLE ST NORTH"&PropertyStreet=="LUCILLE ST"

replace location=subinstr(location,"MERRY MEET CIR","MERRY MEET CTR",1)
replace street=subinstr(street,"MERRY MEET CIR","MERRY MEET CTR",1)

replace location=subinstr(location,"MISTY WOOD LN","MISTYWOOD LN",1)
replace street=subinstr(street,"MISTY WOOD LN","MISTYWOOD LN",1)

replace location=subinstr(location,"MOREHOUSE HIGHWAY","MOREHOUSE HWY",1)
replace street=subinstr(street,"MOREHOUSE HIGHWAY","MOREHOUSE HWY",1)

replace location=subinstr(location,"NORTH BENSON RD","N BENSON RD",1)
replace street=subinstr(street,"NORTH BENSON RD","N BENSON RD",1)

replace location=subinstr(location,"NORTH CEDAR RD","N CEDAR RD",1)
replace street=subinstr(street,"NORTH CEDAR RD","N CEDAR RD",1)

replace location=subinstr(location,"NORTH PINE CREEK RD","N PINE CREEK RD",1)
replace street=subinstr(street,"NORTH PINE CREEK RD","N PINE CREEK RD",1)

replace location=subinstr(location,"RIDGE COMMON","RIDGE CMN",1)
replace street=subinstr(street,"RIDGE COMMON","RIDGE CMN",1)

replace location=subinstr(location,"RIDGELEY AVE","RIDGELY AVE",1)
replace street=subinstr(street,"RIDGELEY AVE","RIDGELY AVE",1)

replace location=subinstr(location,"SADDLE VIEW RD","SADDLEVIEW RD",1)
replace street=subinstr(street,"SADDLE VIEW RD","SADDLEVIEW RD",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SHADY BROOK RD","SHADYBROOK RD",1)
replace street=subinstr(street,"SHADY BROOK RD","SHADYBROOK RD",1)

replace location=subinstr(location,"S BENSON COMMON","S BENSON CMNS",1)
replace street=subinstr(street,"S BENSON COMMON","S BENSON CMNS",1)

replace location=subinstr(location,"SOUTHPORT RIDGE","SOUTHPORT RDG",1)
replace street=subinstr(street,"SOUTHPORT RIDGE","SOUTHPORT RDG",1)

replace location=subinstr(location,"ST MARC LN","SAINT MARC LN",1)
replace street=subinstr(street,"ST MARC LN","SAINT MARC LN",1)

replace location=subinstr(location,"STILL MEADOW","STILL MEADOW PL",1)
replace street=subinstr(street,"STILL MEADOW","STILL MEADOW PL",1)

replace location=subinstr(location,"STONELEIGH SQUARE","STONELEIGH SQ",1)
replace street=subinstr(street,"STONELEIGH SQUARE","STONELEIGH SQ",1)

replace location=subinstr(location,"STROLL ROCK COMMON","STROLL ROCK CMN",1)
replace street=subinstr(street,"STROLL ROCK COMMON","STROLL ROCK CMN",1)

replace location=subinstr(location,"STURGES HIGHWAY","STURGES HWY",1)
replace street=subinstr(street,"STURGES HIGHWAY","STURGES HWY",1)

replace location=subinstr(location,"SUGARPLUM LN","SUGAR PLUM LN",1)
replace street=subinstr(street,"SUGARPLUM LN","SUGAR PLUM LN",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TUNXIS HILL CUTOFF","TUNXIS HILL CUT OFF",1)
replace street=subinstr(street,"TUNXIS HILL CUTOFF","TUNXIS HILL CUT OFF",1)

replace location=subinstr(location,"TWIN LNS RD","TWIN LANES RD",1)
replace street=subinstr(street,"TWIN LNS RD","TWIN LANES RD",1)

replace location=subinstr(location,"UNQUOWA RD WEST","UNQUOWA RD W",1)
replace street=subinstr(street,"UNQUOWA RD WEST","UNQUOWA RD W",1)

replace location=subinstr(location,"VALLEY VIEW PL","VALLEYVIEW PL",1)
replace street=subinstr(street,"VALLEY VIEW PL","VALLEYVIEW PL",1)

replace location=subinstr(location,"VALLEY VIEW RD","VALLEYVIEW RD",1)
replace street=subinstr(street,"VALLEY VIEW RD","VALLEYVIEW RD",1)

replace location=subinstr(location,"VERNA FIELD RD","VERNA FIELD DR",1)
replace street=subinstr(street,"VERNA FIELD RD","VERNA FIELD DR",1)

replace location=subinstr(location,"WAREHAM RD","WAREHAM ST",1)
replace street=subinstr(street,"WAREHAM RD","WAREHAM ST",1)

replace location=subinstr(location,"WEST MORGAN AVE","W MORGAN AVE",1)
replace street=subinstr(street,"WEST MORGAN AVE","W MORGAN AVE",1)

replace location=subinstr(location,"WESTLEA LN","WESTLEA RD",1)
replace street=subinstr(street,"WESTLEA LN","WESTLEA RD",1)

replace location=subinstr(location,"WESTPORT TURNPIKE","WESTPORT TPKE",1)
replace street=subinstr(street,"WESTPORT TURNPIKE","WESTPORT TPKE",1)


gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID
save "$dta\pointcheck_NONVA_fairfield.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Guilford Specific
replace location=subinstr(location,"BENTONS KNOLL","BENTONS KNL",1)
replace street=subinstr(street,"BENTONS KNOLL","BENTONS KNL",1)

replace location=subinstr(location,"BIRCH GROVE","BIRCH GRV",1)
replace street=subinstr(street,"BIRCH GROVE","BIRCH GRV",1)

replace location=subinstr(location,"CORN CRIB HILL","CORNCRIB HILL RD",1)
replace street=subinstr(street,"CORN CRIB HILL","CORNCRIB HILL RD",1)

replace location=subinstr(location,"JUNIPER KNOLL","JUNIPER KNLS",1)
replace street=subinstr(street,"JUNIPER KNOLL","JUNIPER KNLS",1)

replace location=subinstr(location,"NO REEVES AVE","N REEVES AVE",1)
replace street=subinstr(street,"NO REEVES AVE","N REEVES AVE",1)

replace location=subinstr(location,"SACHEMS HEAD RD","SACHEM HEAD RD",1)
replace street=subinstr(street,"SACHEMS HEAD RD","SACHEM HEAD RD",1)

replace location=subinstr(location,"SEAVIEW TERR","SEAVIEW TER",1)
replace street=subinstr(street,"SEAVIEW TERR","SEAVIEW TER",1)

replace location=subinstr(location,"SO UNION ST","S UNION ST",1)
replace street=subinstr(street,"SO UNION ST","S UNION ST",1)

replace location=subinstr(location,"AUTUMN RIDGE DR","AUTUMN RIDGE RD",1)
replace street=subinstr(street,"AUTUMN RIDGE DR","AUTUMN RIDGE RD",1)

replace location=subinstr(location,"BOSTON TERR","BOSTON TER",1)
replace street=subinstr(street,"BOSTON TERR","BOSTON TER",1)

replace location=subinstr(location,"BROOK RIDGE LN","BROOKRIDGE LN",1)
replace street=subinstr(street,"BROOK RIDGE LN","BROOKRIDGE LN",1)

replace location=subinstr(location,"CAMBRIDGE WAY","CAMBRIDGE RD",1)
replace street=subinstr(street,"CAMBRIDGE WAY","CAMBRIDGE RD",1)

replace location=subinstr(location,"CHESTNUT GROVE","CHESTNUT GRV",1)
replace street=subinstr(street,"CHESTNUT GROVE","CHESTNUT GRV",1)

replace location=subinstr(location,"CORN CRIB HILL","CORNCRIB HILL RD",1)
replace street=subinstr(street,"CORN CRIB HILL","CORNCRIB HILL RD",1)

replace location=subinstr(location,"COVERED BRIDGE RD","COVERED BRIDGE DR",1)
replace street=subinstr(street,"COVERED BRIDGE RD","COVERED BRIDGE DR",1)

replace location=subinstr(location,"COVEY CROSSING","COVEY XING",1)
replace street=subinstr(street,"COVEY CROSSING","COVEY XING",1)

replace location=subinstr(location,"CRICKET TR","CRICKET TRL",1)
replace street=subinstr(street,"CRICKET TR","CRICKET TRL",1)

replace location=subinstr(location,"EAST BEARHOUSE HILL RD","E BEARHOUSE HILL RD",1)
replace street=subinstr(street,"EAST BEARHOUSE HILL RD","E BEARHOUSE HILL RD",1)

replace location=subinstr(location,"EAST CREEK CIR","E CREEK CIR",1)
replace street=subinstr(street,"EAST CREEK CIR","E CREEK CIR",1)

replace location=subinstr(location,"EAST GATE RD","E GATE RD",1)
replace street=subinstr(street,"EAST GATE RD","E GATE RD",1)

replace location=subinstr(location,"EAST RIVER RD","E RIVER RD",1)
replace street=subinstr(street,"EAST RIVER RD","E RIVER RD",1)

replace location=subinstr(location,"EDGEHILL RD","EDGE HILL RD",1)
replace street=subinstr(street,"EDGEHILL RD","EDGE HILL RD",1)

replace location=subinstr(location,"FOOTES BRIDGE RD","FOOTE BRIDGE RD",1)
replace street=subinstr(street,"FOOTES BRIDGE RD","FOOTE BRIDGE RD",1)

replace location=subinstr(location,"FOX RIDGE RD","FOX RDG",1)
replace street=subinstr(street,"FOX RIDGE RD","FOX RDG",1)

replace location=subinstr(location,"FOXWOOD RD SO","FOXWOOD RD S",1)
replace street=subinstr(street,"FOXWOOD RD SO","FOXWOOD RD S",1)

replace location=subinstr(location,"JOSEPH DR SO","JOSEPH DR S",1)
replace street=subinstr(street,"JOSEPH DR SO","JOSEPH DR S",1)

replace location=subinstr(location,"JUNIPER KNOLL","JUNIPER KNLS",1)
replace street=subinstr(street,"JUNIPER KNOLL","JUNIPER KNLS",1)

replace location=subinstr(location,"LAUREL RIDGE","LAUREL RIDGE RD",1)
replace street=subinstr(street,"LAUREL RIDGE","LAUREL RIDGE RD",1)

replace location=subinstr(location,"LEIGHTON TR","LEIGHTON TRL",1)
replace street=subinstr(street,"LEIGHTON TR","LEIGHTON TRL",1)

replace location=subinstr(location,"LONE PINE TR","LONE PINE TRL",1)
replace street=subinstr(street,"LONE PINE TR","LONE PINE TRL",1)

replace location=subinstr(location,"LONG HILL FARMS","LONG HILL FARM",1)
replace street=subinstr(street,"LONG HILL FARMS","LONG HILL FARM",1)

replace location=subinstr(location,"MAUPAS RD NO","MAUPAS RD N",1)
replace street=subinstr(street,"MAUPAS RD NO","MAUPAS RD N",1)

replace location=subinstr(location,"MILLSTONE DR","MILL STONE DR",1)
replace street=subinstr(street,"MILLSTONE DR","MILL STONE DR",1)

replace location=subinstr(location,"MOUNTAIN TR","MOUNTAIN TRL",1)
replace street=subinstr(street,"MOUNTAIN TR","MOUNTAIN TRL",1)

replace location=subinstr(location,"NO FAIR ST","N FAIR ST",1)
replace street=subinstr(street,"NO FAIR ST","N FAIR ST",1)

replace location=subinstr(location,"NO MADISON RD","N MADISON RD",1)
replace street=subinstr(street,"NO MADISON RD","N MADISON RD",1)

replace location=subinstr(location,"NO MILL CIR","N MILL CIR",1)
replace street=subinstr(street,"NO MILL CIR","N MILL CIR",1)

replace location=subinstr(location,"NO REEVES AVE","N REEVES AVE",1)
replace street=subinstr(street,"NO REEVES AVE","N REEVES AVE",1)

replace location=subinstr(location,"NO RIVER ST","N RIVER ST",1)
replace street=subinstr(street,"NO RIVER ST","N RIVER ST",1)

replace location=subinstr(location,"NUT PLAINS RD WEST","NUT PLAINS RD W",1)
replace street=subinstr(street,"NUT PLAINS RD WEST","NUT PLAINS RD W",1)

replace location=subinstr(location,"OLSEN DR","OLSON RD",1)
replace street=subinstr(street,"OLSEN DR","OLSON RD",1)

replace location=subinstr(location,"RENEES WAY","RENEE S WAY",1)
replace street=subinstr(street,"RENEES WAY","RENEE S WAY",1)

replace location=subinstr(location,"RUSSET DR","RUSSETT DR",1)
replace street=subinstr(street,"RUSSET DR","RUSSETT DR",1)

replace location=subinstr(location,"SACHEMS HEAD RD","SACHEM HEAD RD",1)
replace street=subinstr(street,"SACHEMS HEAD RD","SACHEM HEAD RD",1)

replace location=subinstr(location,"SEAVIEW TERR","SEAVIEW TER",1)
replace street=subinstr(street,"SEAVIEW TERR","SEAVIEW TER",1)

replace location=subinstr(location,"SLEEPY HOLLOW LN","SLEEPY HOLLOW RD",1)
replace street=subinstr(street,"SLEEPY HOLLOW LN","SLEEPY HOLLOW RD",1)

replace location=subinstr(location,"SO FAIR ST","S FAIR ST",1)
replace street=subinstr(street,"SO FAIR ST","S FAIR ST",1)

replace location=subinstr(location,"SO HOOP POLE RD","S HOOP POLE RD",1)
replace street=subinstr(street,"SO HOOP POLE RD","S HOOP POLE RD",1)

replace location=subinstr(location,"SO UNION ST","S UNION ST",1)
replace street=subinstr(street,"SO UNION ST","S UNION ST",1)

replace location=subinstr(location,"STONEHEDGE LN SO","STONEHEDGE LN S",1)
replace street=subinstr(street,"STONEHEDGE LN SO","STONEHEDGE LN S",1)

replace location=subinstr(location,"SUGARBUSH LN","SUGARBUSH DR",1)
replace street=subinstr(street,"SUGARBUSH LN","SUGARBUSH DR",1)

replace location=subinstr(location,"THREE MILE COURSE","THREE MILE CRSE",1)
replace street=subinstr(street,"THREE MILE COURSE","THREE MILE CRSE",1)

replace location=subinstr(location,"TURNBUCKLE LN","THORNBUCKLE LN",1)
replace street=subinstr(street,"TURNBUCKLE LN","THORNBUCKLE LN",1)

replace location=subinstr(location,"VALLEY SHORES DR","VALLEY SHORE DR",1)
replace street=subinstr(street,"VALLEY SHORES DR","VALLEY SHORE DR",1)

replace location=subinstr(location,"WEATHERLY TR","WEATHERLY TRL",1)
replace street=subinstr(street,"WEATHERLY TR","WEATHERLY TRL",1)

replace location=subinstr(location,"WEST LAKE AVE","W LAKE AVE",1)
replace street=subinstr(street,"WEST LAKE AVE","W LAKE AVE",1)

replace location=subinstr(location,"WHISPERING WOODS HILL RD","WHISPERING WOODS HL",1)
replace street=subinstr(street,"WHISPERING WOODS HILL RD","WHISPERING WOODS HL",1)

replace location=subinstr(location,"WHISPERING WOODS RD","WHISPERING WOODS HL",1) if street=="WHISPERING WOODS RD"&PropertyStreet=="WHISPERING WOODS HL"
replace street=subinstr(street,"WHISPERING WOODS RD","WHISPERING WOODS HL",1) if street=="WHISPERING WOODS RD"&PropertyStreet=="WHISPERING WOODS HL"

replace location=subinstr(location,"WHITFIELD ST","OLD WHITFIELD ST",1) if street=="WHITFIELD ST"&PropertyStreet=="OLD WHITFIELD ST"
replace street=subinstr(street,"WHITFIELD ST","OLD WHITFIELD ST",1) if street=="WHITFIELD ST"&PropertyStreet=="OLD WHITFIELD ST"

replace location=subinstr(location,"WHITFIELD ST","NEW WHITFIELD ST",1) if street=="WHITFIELD ST"&PropertyStreet=="NEW WHITFIELD ST"
replace street=subinstr(street,"WHITFIELD ST","NEW WHITFIELD ST",1) if street=="WHITFIELD ST"&PropertyStreet=="NEW WHITFIELD ST"

replace location=subinstr(location,"OLD SACHEM HEAD RD","OLD SACHEMS HEAD RD",1)
replace street=subinstr(street,"OLD SACHEM HEAD RD","OLD SACHEMS HEAD RD",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_guilford.dta",replace

********Milford*******
use "$GIS\propbrev_wf_milford.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street


replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Milford specific
replace location=subinstr(location,"BAYSHORE DR EXT","BAYSHORE DR",1)
replace street=subinstr(street,"BAYSHORE DR EXT","BAYSHORE DR",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY","BROADWAY",1)
replace street=subinstr(street,"BRDWAY","BROADWAY",1)

replace location=subinstr(location,"DEVOLL ST","DEVOL ST",1)
replace street=subinstr(street,"DEVOLL ST","DEVOL ST",1)

replace location=subinstr(location,"DOCK LN","DOCK RD",1)
replace street=subinstr(street,"DOCK LN","DOCK RD",1)

replace location=subinstr(location,"EAST BRDWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BRDWAY","E BROADWAY",1)

replace location=subinstr(location,"EAST BROADWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BROADWAY","E BROADWAY",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"ETTADORE PKWY","ETTADORE PARK",1)
replace street=subinstr(street,"ETTADORE PKWY","ETTADORE PARK",1)

replace location=subinstr(location,"FENWAY NORTH","FENWAY ST N",1)
replace street=subinstr(street,"FENWAY NORTH","FENWAY ST N",1)

replace location=subinstr(location,"FENWAY SOUTH","FENWAY ST S",1)
replace street=subinstr(street,"FENWAY SOUTH","FENWAY ST S",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HILLTOP CIR EAST","HILLTOP CIR E",1)
replace street=subinstr(street,"HILLTOP CIR EAST","HILLTOP CIR E",1)

replace location=subinstr(location,"KINLOCH ST","KINLOCK ST",1)
replace street=subinstr(street,"KINLOCH ST","KINLOCK ST",1)

replace location=subinstr(location,"KINLOCH TER","KINLOCK TER",1)
replace street=subinstr(street,"KINLOCH TER","KINLOCK TER",1)

replace location=subinstr(location,"MANILA AVE","MANILLA AVE",1)
replace street=subinstr(street,"MANILA AVE","MANILLA AVE",1)

replace location=subinstr(location,"MILFORD PT RD","MILFORD POINT RD",1)
replace street=subinstr(street,"MILFORD PT RD","MILFORD POINT RD",1)

replace location=subinstr(location,"MINUTE MAN DR","MINUTEMAN DR",1)
replace street=subinstr(street,"MINUTE MAN DR","MINUTEMAN DR",1)

replace location=subinstr(location,"NORTHMOOR RD","NORTHMOOR ST",1)
replace street=subinstr(street,"NORTHMOOR RD","NORTHMOOR ST",1)

replace location=subinstr(location,"OAKDALE AVE","OAKDALE ST",1)
replace street=subinstr(street,"OAKDALE AVE","OAKDALE ST",1)

replace location=subinstr(location,"OLD PT RD","OLD POINT RD",1)
replace street=subinstr(street,"OLD PT RD","OLD POINT RD",1)

replace location=subinstr(location,"PHELAN PARK DR","PHELAN PARK",1)
replace street=subinstr(street,"PHELAN PARK DR","PHELAN PARK",1)

replace location=subinstr(location,"PT BEACH DR","POINT BEACH DR",1)
replace street=subinstr(street,"PT BEACH DR","POINT BEACH DR",1)

replace location=subinstr(location,"PT LOOKOUT","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT","POINT LOOKOUT",1)

replace location=subinstr(location,"PT LOOKOUT EAST","POINT LOOKOUT",1)
replace street=subinstr(street,"PT LOOKOUT EAST","POINT LOOKOUT",1)

replace location=subinstr(location,"POND PT AVE","POND POINT AVE",1)
replace street=subinstr(street,"POND PT AVE","POND POINT AVE",1)

replace location=subinstr(location,"RIVEREDGE DR","RIVEREDGE ST",1)
replace street=subinstr(street,"RIVEREDGE DR","RIVEREDGE ST",1)

replace location=subinstr(location,"SEA FLOWER RD","SEAFLOWER RD",1)
replace street=subinstr(street,"SEA FLOWER RD","SEAFLOWER RD",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SMITHS PT RD","SMITHS POINT RD",1)
replace street=subinstr(street,"SMITHS PT RD","SMITHS POINT RD",1)

replace location=subinstr(location,"SNOW APPLE LN","SNOWAPPLE LN",1)
replace street=subinstr(street,"SNOW APPLE LN","SNOWAPPLE LN",1)

replace location=subinstr(location,"SPARROW BUSH LN","SPARROWBUSH LN",1)
replace street=subinstr(street,"SPARROW BUSH LN","SPARROWBUSH LN",1)

replace location=subinstr(location,"TER RD","TERRACE RD",1)
replace street=subinstr(street,"TER RD","TERRACE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WELCHS PT RD","WELCHS POINT RD",1)
replace street=subinstr(street,"WELCHS PT RD","WELCHS POINT RD",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST ORLAND ST","W ORLAND ST",1)
replace street=subinstr(street,"WEST ORLAND ST","W ORLAND ST",1)

replace location=subinstr(location,"WEST RIVER ST","W RIVER ST",1)
replace street=subinstr(street,"WEST RIVER ST","W RIVER ST",1)

replace location=subinstr(location,"WEST TOWN ST","W TOWN ST",1)
replace street=subinstr(street,"WEST TOWN ST","W TOWN ST",1)

replace location=subinstr(location,"ASTERRACE RD","ASTER RD",1)
replace street=subinstr(street,"ASTERRACE RD","ASTER RD",1)

replace location=subinstr(location,"BREWSTERRACE RD","BREWSTER RD",1)
replace street=subinstr(street,"BREWSTERRACE RD","BREWSTER RD",1)

replace location=subinstr(location,"APPLE TREE LN","APPLETREE LN",1)
replace street=subinstr(street,"APPLE TREE LN","APPLETREE LN",1)

replace location=subinstr(location,"BEAVER BROOK RD","BEAVERBROOK RD",1)
replace street=subinstr(street,"BEAVER BROOK RD","BEAVERBROOK RD",1)

replace location=subinstr(location,"BERNADINE RD","BERNADINE ST",1)
replace street=subinstr(street,"BERNADINE RD","BERNADINE ST",1)

replace location=subinstr(location,"BON AIR CIR","BONAIR CIR",1)
replace street=subinstr(street,"BON AIR CIR","BONAIR CIR",1)

replace location=subinstr(location,"BOXWOOD CT","BOXWOOD LN",1)
replace street=subinstr(street,"BOXWOOD CT","BOXWOOD LN",1)

replace location=subinstr(location,"CALLAWAY DR","CALLOWAY DR",1)
replace street=subinstr(street,"CALLAWAY DR","CALLOWAY DR",1)

replace location=subinstr(location,"EAST RUTLAND RD","E RUTLAND RD",1)
replace street=subinstr(street,"EAST RUTLAND RD","E RUTLAND RD",1)

replace location=subinstr(location,"FENWAY","FENWAY ST S",1) if street=="FENWAY"&PropertyStreet=="FENWAY ST S"
replace street=subinstr(street,"FENWAY","FENWAY ST S",1) if street=="FENWAY"&PropertyStreet=="FENWAY ST S"

replace location=subinstr(location,"FENWAY","FENWAY ST N",1) if street=="FENWAY"&PropertyStreet=="FENWAY ST N"
replace street=subinstr(street,"FENWAY","FENWAY ST N",1) if street=="FENWAY"&PropertyStreet=="FENWAY ST N"

replace location=subinstr(location,"GREAT MEADOW DR","GREAT MEADOW RD",1)
replace street=subinstr(street,"GREAT MEADOW DR","GREAT MEADOW RD",1)

replace location=subinstr(location,"HACKETT AVE","HACKETT ST",1)
replace street=subinstr(street,"HACKETT AVE","HACKETT ST",1)

replace location=subinstr(location,"HAYSTACK RD","HAY STACK RD",1)
replace street=subinstr(street,"HAYSTACK RD","HAY STACK RD",1)

replace location=subinstr(location,"HUNTERS RUN","HUNTERS RUN RD",1)
replace street=subinstr(street,"HUNTERS RUN","HUNTERS RUN RD",1)

replace location=subinstr(location,"LEXINGTON WAY NORTH","LEXINGTON WAY N",1)
replace street=subinstr(street,"LEXINGTON WAY NORTH","LEXINGTON WAY N",1)

replace location=subinstr(location,"LEXINGTON WAY SOUTH","LEXINGTON WAY S",1)
replace street=subinstr(street,"LEXINGTON WAY SOUTH","LEXINGTON WAY S",1)

replace location=subinstr(location,"MATHEWS ST","MATTHEWS ST",1)
replace street=subinstr(street,"MATHEWS ST","MATTHEWS ST",1)

replace location=subinstr(location,"NORTH RUTLAND RD","N RUTLAND RD",1)
replace street=subinstr(street,"NORTH RUTLAND RD","N RUTLAND RD",1)

replace location=subinstr(location,"OREGON AVE","OREGON AVE N",1) if street=="OREGON AVE"&PropertyStreet=="OREGON AVE N"
replace street=subinstr(street,"OREGON AVE","OREGON AVE N",1) if street=="OREGON AVE"&PropertyStreet=="OREGON AVE N"

replace location=subinstr(location,"OREGON AVE","OREGON AVE S",1) if street=="OREGON AVE"&PropertyStreet=="OREGON AVE S"
replace street=subinstr(street,"OREGON AVE","OREGON AVE S",1) if street=="OREGON AVE"&PropertyStreet=="OREGON AVE S"

replace location=subinstr(location,"POINT LOOKOUT EAST","POINT LOOKOUT",1)
replace street=subinstr(street,"POINT LOOKOUT EAST","POINT LOOKOUT",1)

replace location=subinstr(location,"RIVERVIEW AVE","RIVERVIEW ST",1)
replace street=subinstr(street,"RIVERVIEW AVE","RIVERVIEW ST",1)

replace location=subinstr(location,"RIVERSIDE DR EXT","RIVERSIDE DR",1)
replace street=subinstr(street,"RIVERSIDE DR EXT","RIVERSIDE DR",1)

replace location=subinstr(location,"SAW MILL RD","SAWMILL RD",1)
replace street=subinstr(street,"SAW MILL RD","SAWMILL RD",1)

replace location=subinstr(location,"SHEFFIELD AVE","SHEFFIELD RD",1)
replace street=subinstr(street,"SHEFFIELD AVE","SHEFFIELD RD",1)

replace location=subinstr(location,"SOLOMONS HILL RD","SOLOMON HILL RD",1)
replace street=subinstr(street,"SOLOMONS HILL RD","SOLOMON HILL RD",1)

replace location=subinstr(location,"SOUTH KEREMA AVE","S KEREMA AVE",1)
replace street=subinstr(street,"SOUTH KEREMA AVE","S KEREMA AVE",1)

replace location=subinstr(location,"SOUTH WOODLAND DR","S WOODLAND DR",1)
replace street=subinstr(street,"SOUTH WOODLAND DR","S WOODLAND DR",1)

replace location=subinstr(location,"TALMADGE DR","TALMADGE RD",1)
replace street=subinstr(street,"TALMADGE DR","TALMADGE RD",1)

replace location=subinstr(location,"TERREL DR","TERRELL DR",1)
replace street=subinstr(street,"TERREL DR","TERRELL DR",1)

replace location=subinstr(location,"TUMBLEBROOK DR","TUMBLEBROOK RD",1)
replace street=subinstr(street,"TUMBLEBROOK DR","TUMBLEBROOK RD",1)

replace location=subinstr(location,"WAVERLY AVE","WAVERLY ST",1)
replace street=subinstr(street,"WAVERLY AVE","WAVERLY ST",1)

replace location=subinstr(location,"WELLES DR","WELLS DR",1)
replace street=subinstr(street,"WELLES DR","WELLS DR",1)

replace location=subinstr(location,"WEST CLARK ST","W CLARK ST",1)
replace street=subinstr(street,"WEST CLARK ST","W CLARK ST",1)

replace location=subinstr(location,"WEST RUTLAND RD","W RUTLAND RD",1)
replace street=subinstr(street,"WEST RUTLAND RD","W RUTLAND RD",1)

replace location=subinstr(location,"WEST SHORE DR","W SHORE DR",1)
replace street=subinstr(street,"WEST SHORE DR","W SHORE DR",1)

replace location=subinstr(location,"WHITE OAKS RD","WHITE OAKS TER",1)
replace street=subinstr(street,"WHITE OAKS RD","WHITE OAKS TER",1)

replace location=subinstr(location,"WILEY AVE","WILEY ST",1)
replace street=subinstr(street,"WILEY AVE","WILEY ST",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_milford.dta",replace

********New Haven*******
use "$GIS\propbrev_wf_newhaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*New Haven Specific
replace location=subinstr(location,"BLATCHLEY AV","BLATCHLEY AVE",1)
replace street=subinstr(street,"BLATCHLEY AV","BLATCHLEY AVE",1)

replace location=subinstr(location,"DOUGLASS AV","DOUGLASS AVE",1)
replace street=subinstr(street,"DOUGLASS AV","DOUGLASS AVE",1)

replace location=subinstr(location,"FAIRMONT AV","FAIRMONT AVE",1)
replace street=subinstr(street,"FAIRMONT AV","FAIRMONT AVE",1)

replace location=subinstr(location,"FARREN AV","FARREN AVE",1)
replace street=subinstr(street,"FARREN AV","FARREN AVE",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FLORENCE AV","FLORENCE AVE",1)
replace street=subinstr(street,"FLORENCE AV","FLORENCE AVE",1)

replace location=subinstr(location,"FORBES AV","FORBES AVE",1)
replace street=subinstr(street,"FORBES AV","FORBES AVE",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GIRARD AV","GIRARD AVE",1)
replace street=subinstr(street,"GIRARD AV","GIRARD AVE",1)

replace location=subinstr(location,"GREENWICH AV","GREENWICH AVE",1)
replace street=subinstr(street,"GREENWICH AV","GREENWICH AVE",1)

replace location=subinstr(location,"HALLOCK AV","HALLOCK AVE",1)
replace street=subinstr(street,"HALLOCK AV","HALLOCK AVE",1)

replace location=subinstr(location,"HORSLEY AV","HORSLEY AVE",1)
replace street=subinstr(street,"HORSLEY AV","HORSLEY AVE",1)

replace location=subinstr(location,"HOWARD AV","HOWARD AVE",1)
replace street=subinstr(street,"HOWARD AV","HOWARD AVE",1)

replace location=subinstr(location,"KIMBERLY AV","KIMBERLY AVE",1)
replace street=subinstr(street,"KIMBERLY AV","KIMBERLY AVE",1)

replace location=subinstr(location,"MEADOW VIEW ST","MEADOW VIEW RD",1)
replace street=subinstr(street,"MEADOW VIEW ST","MEADOW VIEW RD",1)

replace location=subinstr(location,"MORRIS AV","MORRIS AVE",1)
replace street=subinstr(street,"MORRIS AV","MORRIS AVE",1)

replace location=subinstr(location,"ORCHARD AV","ORCHARD AVE",1)
replace street=subinstr(street,"ORCHARD AV","ORCHARD AVE",1)

replace location=subinstr(location,"PARK LA","PARK LN",1)
replace street=subinstr(street,"PARK LA","PARK LN",1)

replace location=subinstr(location,"PROSPECT AV","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AV","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPIAC AV","QUINNIPIAC AVE",1)
replace street=subinstr(street,"QUINNIPIAC AV","QUINNIPIAC AVE",1)

replace location=subinstr(location,"SALTONSTALL AV","SALTONSTALL AVE",1)
replace street=subinstr(street,"SALTONSTALL AV","SALTONSTALL AVE",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SHEPARD AV","SHEPARD AVE",1)
replace street=subinstr(street,"SHEPARD AV","SHEPARD AVE",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"SOUTH END RD","S END RD",1)
replace street=subinstr(street,"SOUTH END RD","S END RD",1)

replace location=subinstr(location,"SOUTH WATER ST","S WATER ST",1)
replace street=subinstr(street,"SOUTH WATER ST","S WATER ST",1)

replace location=subinstr(location,"STUYVESANT AV","STUYVESANT AVE",1)
replace street=subinstr(street,"STUYVESANT AV","STUYVESANT AVE",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location," AV"," AVE",1)
replace street=subinstr(street," AV"," AVE",1)

replace location=subinstr(location,"BEAVER HILL LA","BEAVER HILL LN",1)
replace street=subinstr(street,"BEAVER HILL LA","BEAVER HILL LN",1)

replace location=subinstr(location,"BEECHWOOD LA","BEECHWOOD LN",1)
replace street=subinstr(street,"BEECHWOOD LA","BEECHWOOD LN",1)

replace location=subinstr(location," AVEE"," AVE",1)
replace street=subinstr(street," AVEE"," AVE",1)

replace location=subinstr(location,"EAST GRAND AVE","E GRAND AVE",1)
replace street=subinstr(street,"EAST GRAND AVE","E GRAND AVE",1)

replace location=subinstr(location,"EAST PEARL ST","E PEARL ST",1)
replace street=subinstr(street,"EAST PEARL ST","E PEARL ST",1)

replace location=subinstr(location,"EAST ROCK RD","E ROCK RD",1)
replace street=subinstr(street,"EAST ROCK RD","E ROCK RD",1)

replace location=subinstr(location,"EDGEWOOD WY","EDGEWOOD WAY",1)
replace street=subinstr(street,"EDGEWOOD WY","EDGEWOOD WAY",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"GREEN HILL TER","GREENHILL TER",1)
replace street=subinstr(street,"GREEN HILL TER","GREENHILL TER",1)

replace location=subinstr(location,"HIGHVIEW LA","HIGHVIEW LN",1)
replace street=subinstr(street,"HIGHVIEW LA","HIGHVIEW LN",1)

replace location=subinstr(location,"HILLTOP RD","HILLTOP PL",1) if street=="HILLTOP RD"&PropertyStreet=="HILLTOP PL"
replace street=subinstr(street,"HILLTOP RD","HILLTOP PL",1) if street=="HILLTOP RD"&PropertyStreet=="HILLTOP PL"

replace location=subinstr(location,"HUGHES ST EX","HUGHES STREET EXT",1)
replace street=subinstr(street,"HUGHES ST EX","HUGHES STREET EXT",1)

replace location=subinstr(location,"LAKE VIEW TER","LAKEVIEW TER",1)
replace street=subinstr(street,"LAKE VIEW TER","LAKEVIEW TER",1)

replace location=subinstr(location,"LAURA LA","LAURA LN",1)
replace street=subinstr(street,"LAURA LA","LAURA LN",1)

replace location=subinstr(location,"LEGEND LA","LEGEND LN",1)
replace street=subinstr(street,"LEGEND LA","LEGEND LN",1)

replace location=subinstr(location,"MAIN ST ANNEX","MAIN STREET ANX",1)
replace street=subinstr(street,"MAIN ST ANNEX","MAIN STREET ANX",1)

replace location=subinstr(location,"MORTON LA","MORTON LN",1)
replace street=subinstr(street,"MORTON LA","MORTON LN",1)

replace location=subinstr(location,"MOUNTAIN TOP LA","MOUNTAIN TOP LN",1)
replace street=subinstr(street,"MOUNTAIN TOP LA","MOUNTAIN TOP LN",1)

replace location=subinstr(location,"NORTH BANK ST","N BANK ST",1)
replace street=subinstr(street,"NORTH BANK ST","N BANK ST",1)

replace location=subinstr(location,"PARKSIDE DR","PARK SIDE DR",1)
replace street=subinstr(street,"PARKSIDE DR","PARK SIDE DR",1)

replace location=subinstr(location,"PARMELEE AVE","PARMALEE AVE",1)
replace street=subinstr(street,"PARMELEE AVE","PARMALEE AVE",1)

replace location=subinstr(location,"PELHAM LA","PELHAM LN",1)
replace street=subinstr(street,"PELHAM LA","PELHAM LN",1)

replace location=subinstr(location,"ROBIN LA","ROBIN LN",1)
replace street=subinstr(street,"ROBIN LA","ROBIN LN",1)

replace location=subinstr(location,"ROCK VIEW TER","ROCKVIEW TER",1)
replace street=subinstr(street,"ROCK VIEW TER","ROCKVIEW TER",1)

replace location=subinstr(location,"ROOSEVELT ST EX","ROOSEVELT STREET EXT",1)
replace street=subinstr(street,"ROOSEVELT ST EX","ROOSEVELT STREET EXT",1)

replace location=subinstr(location,"SKYVIEW LA","SKYVIEW LN",1)
replace street=subinstr(street,"SKYVIEW LA","SKYVIEW LN",1)

replace location=subinstr(location,"VALLEY PL NORTH","VALLEY PL N",1)
replace street=subinstr(street,"VALLEY PL NORTH","VALLEY PL N",1)

replace location=subinstr(location,"WEST DIVISION ST","W DIVISION ST",1)
replace street=subinstr(street,"WEST DIVISION ST","W DIVISION ST",1)

replace location=subinstr(location,"WEST ELM ST","W ELM ST",1)
replace street=subinstr(street,"WEST ELM ST","W ELM ST",1)

replace location=subinstr(location,"WEST HAZEL ST","W HAZEL ST",1)
replace street=subinstr(street,"WEST HAZEL ST","W HAZEL ST",1)

replace location=subinstr(location,"WEST IVY ST","W IVY ST",1)
replace street=subinstr(street,"WEST IVY ST","W IVY ST",1)

replace location=subinstr(location,"WEST PARK AVE","W PARK AVE",1)
replace street=subinstr(street,"WEST PARK AVE","W PARK AVE",1)

replace location=subinstr(location,"WEST PROSPECT ST","W PROSPECT ST",1)
replace street=subinstr(street,"WEST PROSPECT ST","W PROSPECT ST",1)

replace location=subinstr(location,"WEST READ ST","W READ ST",1)
replace street=subinstr(street,"WEST READ ST","W READ ST",1)

replace location=subinstr(location,"WESTBROOK LA","WESTBROOK LN",1)
replace street=subinstr(street,"WESTBROOK LA","WESTBROOK LN",1)

replace location=subinstr(location,"WEST HILLS RD","W HILLS RD",1)
replace street=subinstr(street,"WEST HILLS RD","W HILLS RD",1)

replace location=subinstr(location,"WEST ROCK AVE","W ROCK AVE",1)
replace street=subinstr(street,"WEST ROCK AVE","W ROCK AVE",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID
save "$dta\pointcheck_NONVA_newhaven.dta",replace

**************Old Lyme****************
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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location,"COURT","CT",1)
replace street=subinstr(street,"COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

*Old Lyme specific
replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"DORY LNNDING","DORY LNDG",1)
replace street=subinstr(street,"DORY LNNDING","DORY LNDG",1)

replace location=subinstr(location,"HATCHETTS PT RD","HATCHETT POINT RD",1)
replace street=subinstr(street,"HATCHETTS PT RD","HATCHETT POINT RD",1)

replace location=subinstr(location,"JOFFRE RD WEST","JOFFRE RD W",1)
replace street=subinstr(street,"JOFFRE RD WEST","JOFFRE RD W",1)

replace location=subinstr(location,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)
replace street=subinstr(street,"JOHNNYCAKE HILL RD","JOHNNY CAKE HILL RD",1)

replace location=subinstr(location,"MEETING HOUSE LN","MEETINGHOUSE LN",1)
replace street=subinstr(street,"MEETING HOUSE LN","MEETINGHOUSE LN",1)

replace location=subinstr(location,"RIVERDALE LNNDING","RIVERDALE LDG",1)
replace street=subinstr(street,"RIVERDALE LNNDING","RIVERDALE LDG",1)

replace location=subinstr(location,"ROBBINS AVE","ROBBIN AVE",1)
replace street=subinstr(street,"ROBBINS AVE","ROBBIN AVE",1)

replace location=subinstr(location,"SANDPIPER PT RD","SANDPIPER POINT RD",1)
replace street=subinstr(street,"SANDPIPER PT RD","SANDPIPER POINT RD",1)

replace location=subinstr(location,"SEA VIEW RD","SEAVIEW RD",1)
replace street=subinstr(street,"SEA VIEW RD","SEAVIEW RD",1)

replace location=subinstr(location,"WEST END DR","W END DR",1)
replace street=subinstr(street,"WEST END DR","W END DR",1)

replace location=subinstr(location,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)
replace street=subinstr(street,"WHITE SANDS BEACH RD","WHITE SAND BEACH RD",1)

replace location=subinstr(location,"APPLE TREE DR","APPLE TREE LN",1)
replace street=subinstr(street,"APPLE TREE DR","APPLE TREE LN",1)

replace location=subinstr(location,"AVE E","AVENUE E",1)
replace street=subinstr(street,"AVE E","AVENUE E",1)

replace location=subinstr(location,"AVE F","AVENUE F",1)
replace street=subinstr(street,"AVE F","AVENUE F",1)

replace location=subinstr(location,"AVE G","AVENUE G",1)
replace street=subinstr(street,"AVE G","AVENUE G",1)

replace location=subinstr(location,"BAYBERRY RIDGE","BAYBERRY RIDGE RD",1)
replace street=subinstr(street,"BAYBERRY RIDGE","BAYBERRY RIDGE RD",1)

replace location=subinstr(location,"BLACKWELL LN","BLACKWELL RD",1)
replace street=subinstr(street,"BLACKWELL LN","BLACKWELL RD",1)

replace location=subinstr(location,"DEER RIDGE","DEER RDG",1)
replace street=subinstr(street,"DEER RIDGE","DEER RDG",1)

replace location=subinstr(location,"GREEN VALLEY LNKES RD","GREEN VALLEY LAKE RD",1)
replace street=subinstr(street,"GREEN VALLEY LNKES RD","GREEN VALLEY LAKE RD",1)

replace location=subinstr(location,"HARTFORD AVE","HARTFORD AVENUE EXT",1) if street=="HARTFORD AVE"&PropertyStreet=="HARTFORD AVENUE EXT"
replace street=subinstr(street,"HARTFORD AVE","HARTFORD AVENUE EXT",1) if street=="HARTFORD AVE"&PropertyStreet=="HARTFORD AVENUE EXT"

replace location=subinstr(location,"HILL CREST RD","HILLCREST RD",1)
replace street=subinstr(street,"HILL CREST RD","HILLCREST RD",1)

replace location=subinstr(location,"HILLWOOD EAST","HILLWOOD RD E",1)
replace street=subinstr(street,"HILLWOOD EAST","HILLWOOD RD E",1)

replace location=subinstr(location,"LADY SLIPPER LN","LADYSLIPPER LN",1)
replace street=subinstr(street,"LADY SLIPPER LN","LADYSLIPPER LN",1)

replace location=subinstr(location,"MARION RD","MARIAN RD",1)
replace street=subinstr(street,"MARION RD","MARIAN RD",1)

replace location=subinstr(location,"MATSON RIDGE","MATSON RDG",1)
replace street=subinstr(street,"MATSON RIDGE","MATSON RDG",1)

replace location=subinstr(location,"MCCULLOCH FARM RD","MCCULLOCH FARM",1)
replace street=subinstr(street,"MCCULLOCH FARM RD","MCCULLOCH FARM",1)

replace location=subinstr(location,"MOSS PT TRL","MOSS POINT TRL",1)
replace street=subinstr(street,"MOSS PT TRL","MOSS POINT TRL",1)

replace location=subinstr(location,"NOTTINGHAM RD","NOTTINGHAM DR",1)
replace street=subinstr(street,"NOTTINGHAM RD","NOTTINGHAM DR",1)

replace location=subinstr(location,"OVERBROOK RD","OVER BROOK RD",1)
replace street=subinstr(street,"OVERBROOK RD","OVER BROOK RD",1)

replace location=subinstr(location,"PEPPERMINT RIDGE","PEPPERMINT RDG",1)
replace street=subinstr(street,"PEPPERMINT RIDGE","PEPPERMINT RDG",1)

replace location=subinstr(location,"PILGRIM LNNDING RD","PILGRIM LANDING RD",1)
replace street=subinstr(street,"PILGRIM LNNDING RD","PILGRIM LANDING RD",1)

replace location=subinstr(location,"PORTLAND AVE","PORTLAND AVENUE EXT",1) if street=="PORTLAND AVE"&PropertyStreet=="PORTLAND AVENUE EXT"
replace street=subinstr(street,"PORTLAND AVE","PORTLAND AVENUE EXT",1) if street=="PORTLAND AVE"&PropertyStreet=="PORTLAND AVENUE EXT"

replace location=subinstr(location,"QUEEN ANNE CT","QUEEN ANNS CT",1)
replace street=subinstr(street,"QUEEN ANNE CT","QUEEN ANNS CT",1)

replace location=subinstr(location,"ROGERS LNKE TRL","ROGERS LAKE TRL",1)
replace street=subinstr(street,"ROGERS LNKE TRL","ROGERS LAKE TRL",1)

replace location=subinstr(location,"SPRUCE AVE","SPRUCE ST",1)
replace street=subinstr(street,"SPRUCE AVE","SPRUCE ST",1)

replace location=subinstr(location,"SQUIRE HILL","SQUIRE HL",1)
replace street=subinstr(street,"SQUIRE HILL","SQUIRE HL",1)

replace location=subinstr(location,"STONELEIGH KNOLL","STONELEIGH KNLS",1)
replace street=subinstr(street,"STONELEIGH KNOLL","STONELEIGH KNLS",1)

replace location=subinstr(location,"THOMAS WAITE DR","THOMAS WAITE RD",1)
replace street=subinstr(street,"THOMAS WAITE DR","THOMAS WAITE RD",1)

replace location=subinstr(location,"WHITE FARMS LN","WHITE FARM LN",1)
replace street=subinstr(street,"WHITE FARMS LN","WHITE FARM LN",1)

replace location=subinstr(location,"WILLS RIDGE","WILLS RDG",1)
replace street=subinstr(street,"WILLS RIDGE","WILLS RDG",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_oldlyme.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Old Saybrook specific
replace location=subinstr(location,"AQUATERRA LA","AQUA TERRA LN",1)
replace street=subinstr(street,"AQUATERRA LA","AQUA TERRA LN",1)

replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"AQUATERRA","AQUA TERRA",1)
replace street=subinstr(street,"AQUATERRA","AQUA TERRA",1)

replace location=subinstr(location,"BARNES RD SOUTH","BARNES RD S",1)
replace street=subinstr(street,"BARNES RD SOUTH","BARNES RD S",1)

replace location=subinstr(location,"BAY VIEW AVE","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW AVE","BAYVIEW RD",1)

replace location=subinstr(location,"BEACH RD EAST","BEACH RD E",1)
replace street=subinstr(street,"BEACH RD EAST","BEACH RD E",1)

replace location=subinstr(location,"BEACH RD WEST","BEACH RD W",1)
replace street=subinstr(street,"BEACH RD WEST","BEACH RD W",1)

replace location=subinstr(location,"BEACH VIEW ST","BEACH VIEW AVE",1)
replace street=subinstr(street,"BEACH VIEW ST","BEACH VIEW AVE",1)

replace location=subinstr(location,"BELAIRE DR","BELAIRE MNR",1)
replace street=subinstr(street,"BELAIRE DR","BELAIRE MNR",1)

replace location=subinstr(location,"BELLEAIRE DR","BELLAIRE DR",1)
replace street=subinstr(street,"BELLEAIRE DR","BELLAIRE DR",1)

replace location=subinstr(location,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)
replace street=subinstr(street,"BOSTON POST RD PL","BOSTON POST ROAD PL",1)

replace location=subinstr(location,"BROOKE ST","BROOK ST",1)
replace street=subinstr(street,"BROOKE ST","BROOK ST",1)

replace location=subinstr(location,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)
replace street=subinstr(street,"CAMBRIDGECT EAST","CAMBRIDGE CT E",1)

replace location=subinstr(location,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)
replace street=subinstr(street,"CAMBRIDGECT WEST","CAMBRIDGE CT W",1)

replace location=subinstr(location,"COVE LNNDING","COVE LNDG",1)
replace street=subinstr(street,"COVE LNNDING","COVE LNDG",1)

replace location=subinstr(location,"CRANTON ST","CRANTON AVE",1)
replace street=subinstr(street,"CRANTON ST","CRANTON AVE",1)

replace location=subinstr(location,"CRICKETCT","CRICKET CT",1)
replace street=subinstr(street,"CRICKETCT","CRICKET CT",1)

replace location=subinstr(location,"CROMWELLCT","CROMWELL CT",1)
replace street=subinstr(street,"CROMWELLCT","CROMWELL CT",1)

replace location=subinstr(location,"CROMWELLCT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELLCT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"CROMWELL CT NORTH","CROMWELL CT N",1)
replace street=subinstr(street,"CROMWELL CT NORTH","CROMWELL CT N",1)

replace location=subinstr(location,"FENCOVECT","FENCOVE CT",1)
replace street=subinstr(street,"FENCOVECT","FENCOVE CT",1)

replace location=subinstr(location,"FERRY PL","FERRY RD",1)
replace street=subinstr(street,"FERRY PL","FERRY RD",1)

replace location=subinstr(location,"JAMESCT","JAMES CT",1)
replace street=subinstr(street,"JAMESCT","JAMES CT",1)

replace location=subinstr(location,"LONDONCT","LONDON CT",1)
replace street=subinstr(street,"LONDONCT","LONDON CT",1)

replace location=subinstr(location,"MAPLECT","MAPLE CT",1)
replace street=subinstr(street,"MAPLECT","MAPLE CT",1)

replace location=subinstr(location,"MAYCT","MAY CT",1)
replace street=subinstr(street,"MAYCT","MAY CT",1)

replace location=subinstr(location,"MILL ROCK RD EAST","MILL ROCK RD E",1)
replace street=subinstr(street,"MILL ROCK RD EAST","MILL ROCK RD E",1)

replace location=subinstr(location,"NORTH COVE CIR","N COVE CIR",1)
replace street=subinstr(street,"NORTH COVE CIR","N COVE CIR",1)

replace location=subinstr(location,"NORTH COVE RD","N COVE RD",1)
replace street=subinstr(street,"NORTH COVE RD","N COVE RD",1)

replace location=subinstr(location,"OYSTER PT AVE EAST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE EAST","OYSTER POINT RD",1)

replace location=subinstr(location,"OYSTER PT AVE WEST","OYSTER POINT RD",1)
replace street=subinstr(street,"OYSTER PT AVE WEST","OYSTER POINT RD",1)

replace location=subinstr(location,"PARKCROFTERS LN","PARK CROFTERS LN",1)
replace street=subinstr(street,"PARKCROFTERS LN","PARK CROFTERS LN",1)

replace location=subinstr(location,"PT RD","POINT RD",1)
replace street=subinstr(street,"PT RD","POINT RD",1)

replace location=subinstr(location,"REEDCT","REED CT",1)
replace street=subinstr(street,"REEDCT","REED CT",1)

replace location=subinstr(location,"RIVER ST WEST","RIVER ST W",1)
replace street=subinstr(street,"RIVER ST WEST","RIVER ST W",1)

replace location=subinstr(location,"SEA BREEZE RD","SEABREEZE RD",1)
replace street=subinstr(street,"SEA BREEZE RD","SEABREEZE RD",1)

replace location=subinstr(location,"SEA CREST RD","SEACREST RD",1)
replace street=subinstr(street,"SEA CREST RD","SEACREST RD",1)

replace location=subinstr(location,"SEA GULL RD","SEAGULL RD",1)
replace street=subinstr(street,"SEA GULL RD","SEAGULL RD",1)

replace location=subinstr(location,"SEA LN-1","SEA LN",1)
replace street=subinstr(street,"SEA LN-1","SEA LN",1)

replace location=subinstr(location,"SEA LN-2","SEA LN",1)
replace street=subinstr(street,"SEA LN-2","SEA LN",1)

replace location=subinstr(location,"SEAVIEW AVE","SEA VIEW AVE",1)
replace street=subinstr(street,"SEAVIEW AVE","SEA VIEW AVE",1)

replace location=subinstr(location,"SHADY RUN AVE","SHADY RUN",1)
replace street=subinstr(street,"SHADY RUN AVE","SHADY RUN",1)

replace location=subinstr(location,"SHORE AVE-2","SHORE AVE",1)
replace street=subinstr(street,"SHORE AVE-2","SHORE AVE",1)

replace location=subinstr(location,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)
replace street=subinstr(street,"SOUND VIEW AVE-1","SOUNDVIEW AVE",1)

replace location=subinstr(location,"SOUTH COVE RD-1","S COVE RD",1)
replace street=subinstr(street,"SOUTH COVE RD-1","S COVE RD",1)

replace location=subinstr(location,"SOUTH VIEW CIR","S VIEW CIR",1)
replace street=subinstr(street,"SOUTH VIEW CIR","S VIEW CIR",1)

replace location=subinstr(location,"TUDORCT EAST","TUDOR CT E",1)
replace street=subinstr(street,"TUDORCT EAST","TUDOR CT E",1)

replace location=subinstr(location,"TUDORCT WEST","TUDOR CT W",1)
replace street=subinstr(street,"TUDORCT WEST","TUDOR CT W",1)

replace location=subinstr(location,"WEST SHORE DR","W SHORE DR",1)
replace street=subinstr(street,"WEST SHORE DR","W SHORE DR",1)

replace location=subinstr(location,"WEST VIEW RD","W VIEW RD",1)
replace street=subinstr(street,"WEST VIEW RD","W VIEW RD",1)

replace location=subinstr(location,"WINDSORCT WEST","WINDSOR CT",1)
replace street=subinstr(street,"WINDSORCT WEST","WINDSOR CT",1)

replace location=subinstr(location,"BRENDA RD","BRENDA LN",1)
replace street=subinstr(street,"BRENDA RD","BRENDA LN",1)

replace location=subinstr(location,"BRIARCLIFF TRL","BRIARCLIFFE TRL",1)
replace street=subinstr(street,"BRIARCLIFF TRL","BRIARCLIFFE TRL",1)

replace location=subinstr(location,"BETHEL HEIGHTS","BETHAL HTS",1)
replace street=subinstr(street,"BETHEL HEIGHTS","BETHAL HTS",1)

replace location=subinstr(location,"CHRISTY HEIGHTS RD","CHRISTY HTS",1)
replace street=subinstr(street,"CHRISTY HEIGHTS RD","CHRISTY HTS",1)

replace location=subinstr(location,"CINNAMON RIDGE","CINNAMON RDG",1)
replace street=subinstr(street,"CINNAMON RIDGE","CINNAMON RDG",1)

replace location=subinstr(location,"CLAPBOARD HILL","CLAPBOARD HILL RD",1)
replace street=subinstr(street,"CLAPBOARD HILL","CLAPBOARD HILL RD",1)

replace location=subinstr(location,"CLIFFE DR","CLIFF DR",1)
replace street=subinstr(street,"CLIFFE DR","CLIFF DR",1)

replace location=subinstr(location,"DEER RUN","DEER RUN RD",1)
replace street=subinstr(street,"DEER RUN","DEER RUN RD",1)

replace location=subinstr(location,"DONNELLEY RD","DONNELLY RD",1)
replace street=subinstr(street,"DONNELLEY RD","DONNELLY RD",1)

replace location=subinstr(location,"DRUMMER TRL","DRUMMERS TRL",1)
replace street=subinstr(street,"DRUMMER TRL","DRUMMERS TRL",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"KITTERIDGE HILL","KITTERIDGE HILL RD",1)
replace street=subinstr(street,"KITTERIDGE HILL","KITTERIDGE HILL RD",1)

replace location=subinstr(location,"MILL ROCK RD WEST","MILL ROCK RD W",1)
replace street=subinstr(street,"MILL ROCK RD WEST","MILL ROCK RD W",1)

replace location=subinstr(location,"NORTH MEADOW RD","N MEADOW RD",1)
replace street=subinstr(street,"NORTH MEADOW RD","N MEADOW RD",1)

replace location=subinstr(location,"OBED HEIGHTS RD","OBED HTS",1)
replace street=subinstr(street,"OBED HEIGHTS RD","OBED HTS",1)

replace location=subinstr(location,"OLD BACK HIGHWAY","OLD BACK HWY",1)
replace street=subinstr(street,"OLD BACK HIGHWAY","OLD BACK HWY",1)

replace location=subinstr(location,"OTTER BROOK DR","OTTERBROOK DR",1)
replace street=subinstr(street,"OTTER BROOK DR","OTTERBROOK DR",1)

replace location=subinstr(location,"RIDGE DR NORTH","RIDGE DR N",1)
replace street=subinstr(street,"RIDGE DR NORTH","RIDGE DR N",1)

replace location=subinstr(location,"RIDGE DR SOUTH","RIDGE DR",1)
replace street=subinstr(street,"RIDGE DR SOUTH","RIDGE DR",1)

replace location=subinstr(location,"SCHOOLHOUSE RD","SCHOOL HOUSE RD",1)
replace street=subinstr(street,"SCHOOLHOUSE RD","SCHOOL HOUSE RD",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SOUTH VIEW TER","S VIEW TER",1)
replace street=subinstr(street,"SOUTH VIEW TER","S VIEW TER",1)

replace location=subinstr(location,"SQUAW BROOK","SQUAW BRK",1)
replace street=subinstr(street,"SQUAW BROOK","SQUAW BRK",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"TROLLEY CROSSING","TROLLEY XING",1)
replace street=subinstr(street,"TROLLEY CROSSING","TROLLEY XING",1)

replace location=subinstr(location,"WATCH HILL","WATCH HILL RD",1)
replace street=subinstr(street,"WATCH HILL","WATCH HILL RD",1)

replace location=subinstr(location,"WEST KING ST","W KING ST",1)
replace street=subinstr(street,"WEST KING ST","W KING ST",1)

replace location=subinstr(location,"WEST VIEW CIR","W VIEW CIR",1)
replace street=subinstr(street,"WEST VIEW CIR","W VIEW CIR",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID
save "$dta\pointcheck_NONVA_oldsaybrook.dta",replace

*******Stonington********
use "$GIS\propbrev_wf_stonington.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Stonington specific
replace location=subinstr(location,"ALLYNS ALLEY","ALLYNS ALY",1)
replace street=subinstr(street,"ALLYNS ALLEY","ALLYNS ALY",1)

replace location=subinstr(location,"BAYBERRY LA","BAYBERRY LN",1)
replace street=subinstr(street,"BAYBERRY LA","BAYBERRY LN",1)

replace location=subinstr(location,"BOULDER AVE EXT","BOULDER AVE",1)
replace street=subinstr(street,"BOULDER AVE EXT","BOULDER AVE",1)

replace location=subinstr(location,"BRD ST","BROAD ST",1)
replace street=subinstr(street,"BRD ST","BROAD ST",1)

replace location=subinstr(location,"BRDWAY AVE","BROADWAY AVE",1)
replace street=subinstr(street,"BRDWAY AVE","BROADWAY AVE",1)

replace location=subinstr(location,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)
replace street=subinstr(street,"BROADWAY AVE EXT","BROADWAY AVENUE EXT",1)

replace location=subinstr(location,"CHAPMAN LA","CHAPMAN LN",1)
replace street=subinstr(street,"CHAPMAN LA","CHAPMAN LN",1)

replace location=subinstr(location,"CHESEBRO LA","CHESEBRO LN",1)
replace street=subinstr(street,"CHESEBRO LA","CHESEBRO LN",1)

replace location=subinstr(location,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)
replace street=subinstr(street,"CHIPPECHAUG TR","CHIPPECHAUG TRL",1)

replace location=subinstr(location,"CHURCH ST M","CHURCH ST",1)
replace street=subinstr(street,"CHURCH ST M","CHURCH ST",1)

replace location=subinstr(location,"DENISON AVE M","DENISON AVE",1)
replace street=subinstr(street,"DENISON AVE M","DENISON AVE",1)

replace location=subinstr(location,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)
replace street=subinstr(street,"ELIHU ISLAND RD","ELIHUE ISLAND RD",1)

replace location=subinstr(location,"ENSIGN LA","ENSIGN LN",1)
replace street=subinstr(street,"ENSIGN LA","ENSIGN LN",1)

replace location=subinstr(location,"LAMBERTS LA","LAMBERTS LN",1)
replace street=subinstr(street,"LAMBERTS LA","LAMBERTS LN",1)

replace location=subinstr(location,"LATIMER PT RD","LATIMER POINT RD",1)
replace street=subinstr(street,"LATIMER PT RD","LATIMER POINT RD",1)

replace location=subinstr(location,"LHIRONDELLE LA","LHIRONDELLE LN",1)
replace street=subinstr(street,"LHIRONDELLE LA","LHIRONDELLE LN",1)

replace location=subinstr(location,"LINDEN LA","LINDEN LN",1)
replace street=subinstr(street,"LINDEN LA","LINDEN LN",1)

replace location=subinstr(location,"LONG WHARF RD","LONG WHARF DR",1)
replace street=subinstr(street,"LONG WHARF RD","LONG WHARF DR",1)

replace location=subinstr(location,"MAPLE ST LP","MAPLE ST",1)
replace street=subinstr(street,"MAPLE ST LP","MAPLE ST",1)

replace location=subinstr(location,"MAPLEWOOD LA","MAPLEWOOD LN",1)
replace street=subinstr(street,"MAPLEWOOD LA","MAPLEWOOD LN",1)

replace location=subinstr(location,"MEADOWBROOK LA","MEADOWBROOK LN",1)
replace street=subinstr(street,"MEADOWBROOK LA","MEADOWBROOK LN",1)

replace location=subinstr(location,"MEADOWLARK LA","MEADOW LARK LN",1)
replace street=subinstr(street,"MEADOWLARK LA","MEADOW LARK LN",1)

replace location=subinstr(location,"MONEY PT RD","MONEY POINT RD",1)
replace street=subinstr(street,"MONEY PT RD","MONEY POINT RD",1)

replace location=subinstr(location,"MYSTIC HILL","MYSTIC HILL RD",1)
replace street=subinstr(street,"MYSTIC HILL","MYSTIC HILL RD",1)

replace location=subinstr(location,"NAUYAUG N","NAUYAUG RD N",1)
replace street=subinstr(street,"NAUYAUG N","NAUYAUG RD N",1)

replace location=subinstr(location,"NAUYAUG PT RD","NAUYAUG POINT RD",1)
replace street=subinstr(street,"NAUYAUG PT RD","NAUYAUG POINT RD",1)

replace location=subinstr(location,"NOYES AVE LP","NOYES AVE",1)
replace street=subinstr(street,"NOYES AVE LP","NOYES AVE",1)

replace location=subinstr(location,"PLOVER LA","PLOVER LN",1)
replace street=subinstr(street,"PLOVER LA","PLOVER LN",1)

replace location=subinstr(location,"RICHMOND LA M","RICHMOND LN",1)
replace street=subinstr(street,"RICHMOND LA M","RICHMOND LN",1)

replace location=subinstr(location,"ROSE LA","ROSE LN",1)
replace street=subinstr(street,"ROSE LA","ROSE LN",1)

replace location=subinstr(location,"SCHOOL ST M","SCHOOL ST",1)
replace street=subinstr(street,"SCHOOL ST M","SCHOOL ST",1)

replace location=subinstr(location,"SEAGULL LA","SEAGULL LN",1)
replace street=subinstr(street,"SEAGULL LA","SEAGULL LN",1)

replace location=subinstr(location,"SUMMIT ST M","SUMMIT ST",1)
replace street=subinstr(street,"SUMMIT ST M","SUMMIT ST",1)

replace location=subinstr(location,"SURREY LA","SURREY LN",1)
replace street=subinstr(street,"SURREY LA","SURREY LN",1)

replace location=subinstr(location,"WILBUR HILL LA","WILBUR HILL LN",1)
replace street=subinstr(street,"WILBUR HILL LA","WILBUR HILL LN",1)

replace location=subinstr(location,"AVERY ST P","AVERY ST",1) if street=="AVERY ST P"&PropertyStreet=="AVERY ST"
replace street=subinstr(street,"AVERY ST P","AVERY ST",1) if street=="AVERY ST P"&PropertyStreet=="AVERY ST"

replace location=subinstr(location," LA"," LN",1)
replace street=subinstr(street," LA"," LN",1)

replace location=subinstr(location,"BRUCKER PTWY","BRUCKER PENTWAY",1)
replace street=subinstr(street,"BRUCKER PTWY","BRUCKER PENTWAY",1)

replace location=subinstr(location,"CAMPGROUND RD","CAMP GROUND RD",1)
replace street=subinstr(street,"CAMPGROUND RD","CAMP GROUND RD",1)

replace location=subinstr(location,"CLIPPER PT RD","CLIPPER POINT RD",1)
replace street=subinstr(street,"CLIPPER PT RD","CLIPPER POINT RD",1)

replace location=subinstr(location,"EDWARDS ST","EDWARD ST",1)
replace street=subinstr(street,"EDWARDS ST","EDWARD ST",1)

replace location=subinstr(location,"ELM RIDGE RD","ELMRIDGE RD",1)
replace street=subinstr(street,"ELM RIDGE RD","ELMRIDGE RD",1)

replace location=subinstr(location,"FELLOWS ST","FELLOWS STREET EXT",1) if street=="FELLOWS ST"&PropertyStreet=="FELLOWS STREET EXT"
replace street=subinstr(street,"FELLOWS ST","FELLOWS STREET EXT",1) if street=="FELLOWS ST"&PropertyStreet=="FELLOWS STREET EXT"

replace location=subinstr(location,"GREEN MEADOW RD","GREENMEADOW RD",1)
replace street=subinstr(street,"GREEN MEADOW RD","GREENMEADOW RD",1)

replace location=subinstr(location,"GUN CLUB RD","GUN CLUB RUN",1)
replace street=subinstr(street,"GUN CLUB RD","GUN CLUB RUN",1)

replace location=subinstr(location,"HILLSIDE AVE EXT","HILLSIDE AVENUE EXT",1)
replace street=subinstr(street,"HILLSIDE AVE EXT","HILLSIDE AVENUE EXT",1)

replace location=subinstr(location,"JERRY BROWNE RD","JERRY BROWN RD",1)
replace street=subinstr(street,"JERRY BROWNE RD","JERRY BROWN RD",1)

replace location=subinstr(location,"LN WAY","LANE WAY",1)
replace street=subinstr(street,"LN WAY","LANE WAY",1)

replace location=subinstr(location,"LINCOLN AVE P","LINCOLN AVE",1) if street=="LINCOLN AVE P"&PropertyStreet=="LINCOLN AVE"
replace street=subinstr(street,"LINCOLN AVE P","LINCOLN AVE",1) if street=="LINCOLN AVE P"&PropertyStreet=="LINCOLN AVE"

replace location=subinstr(location,"LINDSEY LN","LINDSAY LN",1)
replace street=subinstr(street,"LINDSEY LN","LINDSAY LN",1)

replace location=subinstr(location,"LOUDON AVE","LOUDEN ST",1)
replace street=subinstr(street,"LOUDON AVE","LOUDEN ST",1)

replace location=subinstr(location,"MANOR ST","MANOR RD",1)
replace street=subinstr(street,"MANOR ST","MANOR RD",1)

replace location=subinstr(location,"MAYFLOWER AVE","MAY FLOWER AVE",1)
replace street=subinstr(street,"MAYFLOWER AVE","MAY FLOWER AVE",1)

replace location=subinstr(location,"MEADOW LNRK LN","MEADOW LARK LN",1)
replace street=subinstr(street,"MEADOW LNRK LN","MEADOW LARK LN",1)

replace location=subinstr(location,"MINER PTWY","MINER PENTWAY",1)
replace street=subinstr(street,"MINER PTWY","MINER PENTWAY",1)

replace location=subinstr(location,"NEW LONDON TNPK","NEW LONDON TPKE",1)
replace street=subinstr(street,"NEW LONDON TNPK","NEW LONDON TPKE",1)

replace location=subinstr(location,"OAK HILL GARDENS","OAK HILL GDNS",1)
replace street=subinstr(street,"OAK HILL GARDENS","OAK HILL GDNS",1)

replace location=subinstr(location,"OAK LN EXT","OAK LANE EXT",1)
replace street=subinstr(street,"OAK LN EXT","OAK LANE EXT",1)

replace location=subinstr(location,"OLD PEQUOT TR","OLD PEQUOT TRL",1)
replace street=subinstr(street,"OLD PEQUOT TR","OLD PEQUOT TRL",1)

replace location=subinstr(location,"PEQUOT TR","PEQUOT TRL",1)
replace street=subinstr(street,"PEQUOT TR","PEQUOT TRL",1)

replace location=subinstr(location,"PEQUOTSEPOS CTR RD","PEQUOTSEPOS CENTER RD",1)
replace street=subinstr(street,"PEQUOTSEPOS CTR RD","PEQUOTSEPOS CENTER RD",1)

replace location=subinstr(location,"PEQUOTSEPOS RD EXT","PEQUOTSEPOS ROAD EXT",1)
replace street=subinstr(street,"PEQUOTSEPOS RD EXT","PEQUOTSEPOS ROAD EXT",1)

replace location=subinstr(location,"SMITH ST P","SMITH ST",1) if street=="SMITH ST P"&PropertyStreet=="SMITH ST"
replace street=subinstr(street,"SMITH ST P","SMITH ST",1) if street=="SMITH ST P"&PropertyStreet=="SMITH ST"

replace location=subinstr(location,"TIMBER RIDGE DR","TIMBER RIDGE RD",1)
replace street=subinstr(street,"TIMBER RIDGE DR","TIMBER RIDGE RD",1)

replace location=subinstr(location,"TROLLEY CROSSING","TROLLEY XING",1)
replace street=subinstr(street,"TROLLEY CROSSING","TROLLEY XING",1)

replace location=subinstr(location,"WASHINGTON ST P","WASHINGTON ST",1) if street=="WASHINGTON ST P"&PropertyStreet=="WASHINGTON ST"
replace street=subinstr(street,"WASHINGTON ST P","WASHINGTON ST",1) if street=="WASHINGTON ST P"&PropertyStreet=="WASHINGTON ST"

replace location=subinstr(location,"WEQUETEQUOCK PASS","WEQUETEQUOCK PSGE",1)
replace street=subinstr(street,"WEQUETEQUOCK PASS","WEQUETEQUOCK PSGE",1)

replace location=subinstr(location,"WHITE ROCK RD","WHITE ROCK BRIDGE RD",1)
replace street=subinstr(street,"WHITE ROCK RD","WHITE ROCK BRIDGE RD",1)

replace location=subinstr(location,"WILCOX MANOR","WILCOX MNR",1)
replace street=subinstr(street,"WILCOX MANOR","WILCOX MNR",1)

replace location=subinstr(location,"WINCHESTER HILL","WINCHESTER HL",1)
replace street=subinstr(street,"WINCHESTER HILL","WINCHESTER HL",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_stonington.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Waterford Specific
replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"BEACH ST EAST","BEACH ST E",1)
replace street=subinstr(street,"BEACH ST EAST","BEACH ST E",1)

replace location=subinstr(location,"EAST BISHOP ST","E BISHOP ST",1)
replace street=subinstr(street,"EAST BISHOP ST","E BISHOP ST",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)
replace street=subinstr(street,"GLENWOOD AVE EXT","GLENWOOD AVENUE EXT",1)

replace location=subinstr(location,"LEONARD CT","LEONARD RD",1)
replace street=subinstr(street,"LEONARD CT","LEONARD RD",1)

replace location=subinstr(location,"LINDROS LN","LINDROSS LN",1)
replace street=subinstr(street,"LINDROS LN","LINDROSS LN",1)

replace location=subinstr(location,"MAGONK PT RD","MAGONK POINT RD",1)
replace street=subinstr(street,"MAGONK PT RD","MAGONK POINT RD",1)

replace location=subinstr(location,"MILLSTONE RD EAST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD EAST","MILLSTONE RD",1)

replace location=subinstr(location,"MILLSTONE RD WEST","MILLSTONE RD",1)
replace street=subinstr(street,"MILLSTONE RD WEST","MILLSTONE RD",1)

replace location=subinstr(location,"PARKWAY DR","PARKWAY",1)
replace street=subinstr(street,"PARKWAY DR","PARKWAY",1)

replace location=subinstr(location,"SEA MEADOW LN","SEA MEADOWS LN",1)
replace street=subinstr(street,"SEA MEADOW LN","SEA MEADOWS LN",1)

replace location=subinstr(location,"STRAND RD","STRAND",1)
replace street=subinstr(street,"STRAND RD","STRAND",1)

replace location=subinstr(location,"WEST NECK RD","W NECK RD",1)
replace street=subinstr(street,"WEST NECK RD","W NECK RD",1)

replace location=subinstr(location,"WEST STRAND RD","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND RD","W STRAND RD",1)

replace location=subinstr(location,"WEST STRAND","W STRAND RD",1)
replace street=subinstr(street,"WEST STRAND","W STRAND RD",1)

replace location=subinstr(location,"ARROWHEAD TRAIL","ARROWHEAD TRL",1)
replace street=subinstr(street,"ARROWHEAD TRAIL","ARROWHEAD TRL",1)

replace location=subinstr(location,"BEACH ST WEST","BEACH ST W",1)
replace street=subinstr(street,"BEACH ST WEST","BEACH ST W",1)

replace location=subinstr(location,"BESTVIEW RD","BEST VIEW RD",1)
replace street=subinstr(street,"BESTVIEW RD","BEST VIEW RD",1)

replace location=subinstr(location,"BROAD ST EXT","BROAD STREET EXT",1)
replace street=subinstr(street,"BROAD ST EXT","BROAD STREET EXT",1)

replace location=subinstr(location,"BROADVIEW CT","BROAD VIEW CT",1)
replace street=subinstr(street,"BROADVIEW CT","BROAD VIEW CT",1)

replace location=subinstr(location,"CLEMENT ST","CLEMENTS ST",1)
replace street=subinstr(street,"CLEMENT ST","CLEMENTS ST",1)

replace location=subinstr(location,"EAST BROOK DR","E BROOK DR",1)
replace street=subinstr(street,"EAST BROOK DR","E BROOK DR",1)

replace location=subinstr(location,"EAST LAKE DR","E LAKE DR",1)
replace street=subinstr(street,"EAST LAKE DR","E LAKE DR",1)

replace location=subinstr(location,"EAST NECK RD","E NECK RD",1)
replace street=subinstr(street,"EAST NECK RD","E NECK RD",1)

replace location=subinstr(location,"EAST WOOD ST","E WOOD ST",1)
replace street=subinstr(street,"EAST WOOD ST","E WOOD ST",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HARTFORD TURNPIKE","HARTFORD TPKE",1)
replace street=subinstr(street,"HARTFORD TURNPIKE","HARTFORD TPKE",1)

replace location=subinstr(location,"HIGHWAY PT LN","HIGHWAY PT",1)
replace street=subinstr(street,"HIGHWAY PT LN","HIGHWAY PT",1)

replace location=subinstr(location,"HUNTSBROOK RD","HUNTS BROOK RD",1)
replace street=subinstr(street,"HUNTSBROOK RD","HUNTS BROOK RD",1)

replace location=subinstr(location,"KESTRAL LN","KESTREL LN",1)
replace street=subinstr(street,"KESTRAL LN","KESTREL LN",1)

replace location=subinstr(location,"MAGINNIS PARKWAY","MAGINNIS PKWY",1)
replace street=subinstr(street,"MAGINNIS PARKWAY","MAGINNIS PKWY",1)

replace location=subinstr(location,"MANITOCK HILL RD","MANITOCK HL",1)
replace street=subinstr(street,"MANITOCK HILL RD","MANITOCK HL",1)

replace location=subinstr(location,"MOHEGAN AVE PKWY","MOHEGAN AVENUE PKWY",1)
replace street=subinstr(street,"MOHEGAN AVE PKWY","MOHEGAN AVENUE PKWY",1)

replace location=subinstr(location,"NINTH AVE","9TH AVE",1)
replace street=subinstr(street,"NINTH AVE","9TH AVE",1)

replace location=subinstr(location,"NORTH PHILLIPS ST","N PHILLIPS ST",1)
replace street=subinstr(street,"NORTH PHILLIPS ST","N PHILLIPS ST",1)

replace location=subinstr(location,"ROCKRIDGE RD","ROCK RIDGE RD",1)
replace street=subinstr(street,"ROCKRIDGE RD","ROCK RIDGE RD",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SOUTH BARTLETT RD","S BARTLETT RD",1)
replace street=subinstr(street,"SOUTH BARTLETT RD","S BARTLETT RD",1)

replace location=subinstr(location,"TENTH AVE","10TH AVE",1)
replace street=subinstr(street,"TENTH AVE","10TH AVE",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"VAUXHALL ST EXT","VAUXHALL STREET EXT",1)
replace street=subinstr(street,"VAUXHALL ST EXT","VAUXHALL STREET EXT",1)

replace location=subinstr(location,"WILLETTS AVE EXT","WILLETTS AVE",1) if street=="WILLETTS AVE EXT"&PropertyStreet=="WILLETTS AVE"
replace street=subinstr(street,"WILLETTS AVE EXT","WILLETTS AVE",1) if street=="WILLETTS AVE EXT"&PropertyStreet=="WILLETTS AVE"

replace location=subinstr(location,"WOODLAND GROVE","WOODLAND GRV",1)
replace street=subinstr(street,"WOODLAND GROVE","WOODLAND GRV",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_waterford.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Westbrook specific
replace location=subinstr(location,"ROAD","RD",1)
replace street=subinstr(street,"ROAD","RD",1)

replace location=subinstr(location,"AVENUE","AVE",1)
replace street=subinstr(street,"AVENUE","AVE",1)

replace location=subinstr(location,"STREET","ST",1)
replace street=subinstr(street,"STREET","ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location,"DRIVE","DR",1)
replace street=subinstr(street,"DRIVE","DR",1)

replace location=subinstr(location,"POINT","PT",1)
replace street=subinstr(street,"POINT","PT",1)

replace location=subinstr(location,"LANE","LN",1)
replace street=subinstr(street,"LANE","LN",1)

replace location=subinstr(location,"PLACE","PL",1)
replace street=subinstr(street,"PLACE","PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location,"TERRACE","TER",1)
replace street=subinstr(street,"TERRACE","TER",1)

replace location=subinstr(location,"CIRCLE","CIR",1)
replace street=subinstr(street,"CIRCLE","CIR",1)

replace location=subinstr(location,"BOULEVARD","BLVD",1)
replace street=subinstr(street,"BOULEVARD","BLVD",1)

replace location=subinstr(location," COURT","CT",1)
replace street=subinstr(street," COURT","CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Westbrook specific
replace location=subinstr(location,"AVE A","AVENUE A",1)
replace street=subinstr(street,"AVE A","AVENUE A",1)

replace location=subinstr(location,"AVE B","AVENUE B",1)
replace street=subinstr(street,"AVE B","AVENUE B",1)

replace location=subinstr(location,"AVE C","AVENUE C",1)
replace street=subinstr(street,"AVE C","AVENUE C",1)

replace location=subinstr(location,"BRDWAY N","BROADWAY N",1)
replace street=subinstr(street,"BRDWAY N","BROADWAY N",1)

replace location=subinstr(location,"BRDWAY S","BROADWAY S",1)
replace street=subinstr(street,"BRDWAY S","BROADWAY S",1)

replace location=subinstr(location,"CHAPMAN AVE","CHAPMAN DR",1)
replace street=subinstr(street,"CHAPMAN AVE","CHAPMAN DR",1)

replace location=subinstr(location,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)
replace street=subinstr(street,"DOROTHY RD EXT","DOROTHY ROAD EXT",1)

replace location=subinstr(location,"E Z ST","EZ ST",1)
replace street=subinstr(street,"E Z ST","EZ ST",1)

replace location=subinstr(location,"JAKOBS LANDING","JAKOBS LNDG",1)
replace street=subinstr(street,"JAKOBS LANDING","JAKOBS LNDG",1)

replace location=subinstr(location,"LYNNE AVE EXT","LYNNE AVE",1)
replace street=subinstr(street,"LYNNE AVE EXT","LYNNE AVE",1)

replace location=subinstr(location,"MCDONALD DR","MACDONALD DR",1)
replace street=subinstr(street,"MCDONALD DR","MACDONALD DR",1)

replace location=subinstr(location,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)
replace street=subinstr(street,"MEADOWBROOK RD EXT","MEADOWBROOK ROAD EXT",1)

replace location=subinstr(location,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)
replace street=subinstr(street,"MENUNKETESUCK AVE S","MENUNKETESUCK AVE",1)

replace location=subinstr(location,"MOHICAN RD E","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD E","MOHICAN RD",1)

replace location=subinstr(location,"MOHICAN RD W","MOHICAN RD",1)
replace street=subinstr(street,"MOHICAN RD W","MOHICAN RD",1)

replace location=subinstr(location,"MULLER AVE","MULLER DR",1)
replace street=subinstr(street,"MULLER AVE","MULLER DR",1)

replace location=subinstr(location,"OAK VALE RD","OAKVALE RD",1)
replace street=subinstr(street,"OAK VALE RD","OAKVALE RD",1)

replace location=subinstr(location,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)
replace street=subinstr(street,"OLD KELSEY PT RD","OLD KELSEY POINT RD",1)

replace location=subinstr(location,"PILOTS PT DR","PILOTS POINT DR",1)
replace street=subinstr(street,"PILOTS PT DR","PILOTS POINT DR",1)

replace location=subinstr(location,"PTINA RD","POINTINA RD",1)
replace street=subinstr(street,"PTINA RD","POINTINA RD",1)

replace location=subinstr(location,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)
replace street=subinstr(street,"SAGAMORE TER DR","SAGAMORE TERRACE DR",1)

replace location=subinstr(location,"SAGAMORE TER RD E","SAGAMORE TER E",1)
replace street=subinstr(street,"SAGAMORE TER RD E","SAGAMORE TER E",1)

replace location=subinstr(location,"SAGAMORE TER RD S","SAGAMORE TER S",1)
replace street=subinstr(street,"SAGAMORE TER RD S","SAGAMORE TER S",1)

replace location=subinstr(location,"SAGAMORE TER RD W","SAGAMORE TER W",1)
replace street=subinstr(street,"SAGAMORE TER RD W","SAGAMORE TER W",1)

replace location=subinstr(location,"SEASCAPE DR","SEA SCAPE DR",1)
replace street=subinstr(street,"SEASCAPE DR","SEA SCAPE DR",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"STONE HEDGE RD EXT","STONE HEDGE RD",1)
replace street=subinstr(street,"STONE HEDGE RD EXT","STONE HEDGE RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"UNCAS RD W","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD W","UNCAS RD",1)

replace location=subinstr(location,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)
replace street=subinstr(street,"WESTBROOK HTS RD","WESTBROOK HEIGHTS RD",1)

replace location=subinstr(location,"CHAPMAN DR","CHAPMAN AVE",1)
replace street=subinstr(street,"CHAPMAN DR","CHAPMAN AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)
replace street=subinstr(street,"SAGAMORE TER RD","SAGAMORE TERRACE RD",1)

replace location=subinstr(location,"AUTUMN RIDGE RD","AUTUMN RDG",1)
replace street=subinstr(street,"AUTUMN RIDGE RD","AUTUMN RDG",1)

replace location=subinstr(location,"BEECHTREE LN","BEECH TREE LN",1)
replace street=subinstr(street,"BEECHTREE LN","BEECH TREE LN",1)

replace location=subinstr(location,"CHURCH HILL LN","CHURCHILL LN",1)
replace street=subinstr(street,"CHURCH HILL LN","CHURCHILL LN",1)

replace location=subinstr(location,"HORSESHOE DR","HORSE SHOE DR",1)
replace street=subinstr(street,"HORSESHOE DR","HORSE SHOE DR",1)

replace location=subinstr(location,"KENROSE TER","KEN ROSE TER",1)
replace street=subinstr(street,"KENROSE TER","KEN ROSE TER",1)

replace location=subinstr(location,"MEADOW PT RD","MEADOW POINT RD",1)
replace street=subinstr(street,"MEADOW PT RD","MEADOW POINT RD",1)

replace location=subinstr(location,"MEADOWLARK LN","MEADOW LARK LN",1)
replace street=subinstr(street,"MEADOWLARK LN","MEADOW LARK LN",1)

replace location=subinstr(location,"MEADOW LARK LN EXT","MEADOW LARK LANE EXT",1)
replace street=subinstr(street,"MEADOW LARK LN EXT","MEADOW LARK LANE EXT",1)

replace location=subinstr(location,"MEETINGHOUSE LN","MEETING HOUSE LN",1)
replace street=subinstr(street,"MEETINGHOUSE LN","MEETING HOUSE LN",1)

replace location=subinstr(location,"POND CIR","POND CIRCLE RD",1)
replace street=subinstr(street,"POND CIR","POND CIRCLE RD",1)

replace location=subinstr(location,"TIMBERLN DR","TIMBERLANE DR",1)
replace street=subinstr(street,"TIMBERLN DR","TIMBERLANE DR",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_westbrook.dta",replace

********West haven*********
use "$GIS\propbrev_wf_westhaven.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*West Haven Specific
replace location=subinstr(location,"BARBARA LA","BARBARA LN",1)
replace street=subinstr(street,"BARBARA LA","BARBARA LN",1)

replace location=subinstr(location,"BATT LA","BATT LN",1)
replace street=subinstr(street,"BATT LA","BATT LN",1)

replace location=subinstr(location,"BAYCREST AVE","BAYCREST DR",1)
replace street=subinstr(street,"BAYCREST AVE","BAYCREST DR",1)

replace location=subinstr(location,"BELLE CIRCLE","BELLE CIR",1)
replace street=subinstr(street,"BELLE CIRCLE","BELLE CIR",1)

replace location=subinstr(location,"BUNGALOW LA","BUNGALOW LN",1)
replace street=subinstr(street,"BUNGALOW LA","BUNGALOW LN",1)

replace location=subinstr(location,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)
replace street=subinstr(street,"CAPT THOMAS BLVD","CAPTAIN THOMAS BLVD",1)

replace location=subinstr(location,"CHECK PT LN","CHECK POINT LN",1)
replace street=subinstr(street,"CHECK PT LN","CHECK POINT LN",1)

replace location=subinstr(location,"CHERRY LA","CHERRY LN",1)
replace street=subinstr(street,"CHERRY LA","CHERRY LN",1)

replace location=subinstr(location,"CIRCLE ST.","CIRCLE ST",1)
replace street=subinstr(street,"CIRCLE ST.","CIRCLE ST",1)

replace location=subinstr(location,"COLONIAL BLV","COLONIAL BLVD",1)
replace street=subinstr(street,"COLONIAL BLV","COLONIAL BLVD",1)

replace location=subinstr(location,"CONN AVE","CONNECTICUT AVE",1)
replace street=subinstr(street,"CONN AVE","CONNECTICUT AVE",1)

replace location=subinstr(location,"DELAWAN AV","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV","DELAWAN AVE",1)

replace location=subinstr(location,"DELAWAN AV REAR","DELAWAN AVE",1)
replace street=subinstr(street,"DELAWAN AV REAR","DELAWAN AVE",1)

replace location=subinstr(location,"EASY RUDDER LA","EASY RUDDER LN",1)
replace street=subinstr(street,"EASY RUDDER LA","EASY RUDDER LN",1)

replace location=subinstr(location,"FAIR SAILING","FAIR SAILING RD",1)
replace street=subinstr(street,"FAIR SAILING","FAIR SAILING RD",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FIRST AV","1ST AVE",1)
replace street=subinstr(street,"FIRST AV","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)
replace street=subinstr(street,"HIGHLAND AVE EXT","HIGHLAND AVENUE EXT",1)

replace location=subinstr(location,"LAURIE LA","LAURIE LN",1)
replace street=subinstr(street,"LAURIE LA","LAURIE LN",1)

replace location=subinstr(location,"LEONARD ST.","LEONARD ST",1)
replace street=subinstr(street,"LEONARD ST.","LEONARD ST",1)

replace location=subinstr(location,"MAY ST EXT","MAY ST",1)
replace street=subinstr(street,"MAY ST EXT","MAY ST",1)
/*
replace location=subinstr(location,"MOHAWK DR","MOHAWK DRIVE EXT",1)
replace street=subinstr(street,"MOHAWK DR","MOHAWK DRIVE EXT",1)
*/
replace location=subinstr(location,"MORGAN LA","MORGAN LN",1)
replace street=subinstr(street,"MORGAN LA","MORGAN LN",1)

replace location=subinstr(location,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)
replace street=subinstr(street,"MOUNTAIN VIEW","MOUNTAIN VIEW RD",1)

replace location=subinstr(location,"NO UNION AVE","N UNION AVE",1)
replace street=subinstr(street,"NO UNION AVE","N UNION AVE",1)

replace location=subinstr(location,"OSBORN AVE","OSBORNE AVE",1)
replace street=subinstr(street,"OSBORN AVE","OSBORNE AVE",1)

replace location=subinstr(location,"PARK TER AVE","PARK TERRACE AVE",1)
replace street=subinstr(street,"PARK TER AVE","PARK TERRACE AVE",1)

replace location=subinstr(location,"PARKER AVE EAST","PARKER AVE E",1)
replace street=subinstr(street,"PARKER AVE EAST","PARKER AVE E",1)

replace location=subinstr(location,"PARKRIDGE RD","PARK RIDGE RD",1)
replace street=subinstr(street,"PARKRIDGE RD","PARK RIDGE RD",1)

replace location=subinstr(location,"PECK LA","PECK LN",1)
replace street=subinstr(street,"PECK LA","PECK LN",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SECOND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"SECOND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"2ND AVE TER","2ND AVENUE TER",1)
replace street=subinstr(street,"2ND AVE TER","2ND AVENUE TER",1)

replace location=subinstr(location,"SOUNDVIEW ST","SOUND VIEW ST",1)
replace street=subinstr(street,"SOUNDVIEW ST","SOUND VIEW ST",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"THIRD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"THIRD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"3RD AVE EXT","3RD AVENUE EXT",1)
replace street=subinstr(street,"3RD AVE EXT","3RD AVENUE EXT",1)

replace location=subinstr(location,"TYLER AVE","TYLER ST",1)
replace street=subinstr(street,"TYLER AVE","TYLER ST",1)

replace location=subinstr(location,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)
replace street=subinstr(street,"WASHINGTON MANOR R","WASHINGTON MANOR AVE",1)

replace location=subinstr(location,"WINDSOCK RD","WIND SOCK RD",1)
replace street=subinstr(street,"WINDSOCK RD","WIND SOCK RD",1)

replace location=subinstr(location,"WOODY CREST","WOODY CRST",1)
replace street=subinstr(street,"WOODY CREST","WOODY CRST",1)

replace location=subinstr(location,"ALLING ST EXT","ALLING STREET EXT",1)
replace street=subinstr(street,"ALLING ST EXT","ALLING STREET EXT",1)

replace location=subinstr(location,"ALLINGS CROSSING","ALLINGS CROSSING RD",1)
replace street=subinstr(street,"ALLINGS CROSSING","ALLINGS CROSSING RD",1)

replace location=subinstr(location,"BENHAM HILL","BENHAM HILL RD",1)
replace street=subinstr(street,"BENHAM HILL","BENHAM HILL RD",1)

replace location=subinstr(location,"BULL HILL LA","BULL HILL LN",1)
replace street=subinstr(street,"BULL HILL LA","BULL HILL LN",1)

replace location=subinstr(location,"CHASE LA","CHASE LN",1)
replace street=subinstr(street,"CHASE LA","CHASE LN",1)

replace location=subinstr(location,"CHIN CLIFT TRAIL","CHIN CLIFT TRL",1)
replace street=subinstr(street,"CHIN CLIFT TRAIL","CHIN CLIFT TRL",1)

replace location=subinstr(location,"CHRIS-JON CIRCLE","CHRIS JON CIR",1)
replace street=subinstr(street,"CHRIS-JON CIRCLE","CHRIS JON CIR",1)

replace location=subinstr(location,"COLD SPRING","COLD SPRING RD",1)
replace street=subinstr(street,"COLD SPRING","COLD SPRING RD",1)

replace location=subinstr(location,"COVEBROOK RD","COVE BROOK RD",1)
replace street=subinstr(street,"COVEBROOK RD","COVE BROOK RD",1)

replace location=subinstr(location,"DONNA LA","DONNA LN",1)
replace street=subinstr(street,"DONNA LA","DONNA LN",1)

replace location=subinstr(location,"ELLYN ST","ELLYN CT",1)
replace street=subinstr(street,"ELLYN ST","ELLYN CT",1)

replace location=subinstr(location,"FLORENCE ST","FLORENCE AVE",1)
replace street=subinstr(street,"FLORENCE ST","FLORENCE AVE",1)

replace location=subinstr(location,"FOREST HILLS","FOREST HILLS RD",1)
replace street=subinstr(street,"FOREST HILLS","FOREST HILLS RD",1)

replace location=subinstr(location,"FOREST TERRACE","FOREST TER",1)
replace street=subinstr(street,"FOREST TERRACE","FOREST TER",1)

replace location=subinstr(location,"GERTRUDE LA","GERTRUDE LN",1)
replace street=subinstr(street,"GERTRUDE LA","GERTRUDE LN",1)

replace location=subinstr(location,"GREEN HILL","GREEN HILL LN",1)
replace street=subinstr(street,"GREEN HILL","GREEN HILL LN",1)

replace location=subinstr(location,"GREGORY ROAD","GREGORY RD",1)
replace street=subinstr(street,"GREGORY ROAD","GREGORY RD",1)

replace location=subinstr(location,"HIGHMEADOW LA","HIGH MEADOW LN",1)
replace street=subinstr(street,"HIGHMEADOW LA","HIGH MEADOW LN",1)

replace location=subinstr(location,"HILLCREST AV","HILLCREST AVE",1)
replace street=subinstr(street,"HILLCREST AV","HILLCREST AVE",1)

replace location=subinstr(location,"HILLTOP LA","HILLTOP LN",1)
replace street=subinstr(street,"HILLTOP LA","HILLTOP LN",1)

replace location=subinstr(location,"HOMESTEADER LA","HOMESTEADER LN",1)
replace street=subinstr(street,"HOMESTEADER LA","HOMESTEADER LN",1)

replace location=subinstr(location,"IDA LA","IDA LN",1)
replace street=subinstr(street,"IDA LA","IDA LN",1)

replace location=subinstr(location,"ISLAND LA","ISLAND LN",1)
replace street=subinstr(street,"ISLAND LA","ISLAND LN",1)

replace location=subinstr(location,"JUDITH LA","JUDITH LN",1)
replace street=subinstr(street,"JUDITH LA","JUDITH LN",1)

replace location=subinstr(location,"KNIGHT LA","KNIGHT LN",1)
replace street=subinstr(street,"KNIGHT LA","KNIGHT LN",1)

replace location=subinstr(location,"MAIN ST","W MAIN ST",1) if street=="MAIN ST"&PropertyStreet=="W MAIN ST"
replace street=subinstr(street,"MAIN ST","W MAIN ST",1) if street=="MAIN ST"&PropertyStreet=="W MAIN ST"

replace location=subinstr(location,"MARTIN LA","MARTIN LN",1)
replace street=subinstr(street,"MARTIN LA","MARTIN LN",1)

replace location=subinstr(location,"MOHAWK DR","MOHAWK DRIVE EXT",1) if street=="MOHAWK DR"&PropertyStreet=="MOHAWK DRIVE EXT"
replace street=subinstr(street,"MOHAWK DR","MOHAWK DRIVE EXT",1) if street=="MOHAWK DR"&PropertyStreet=="MOHAWK DRIVE EXT"

replace location=subinstr(location,"MORRISSEY LA","MORRISSEY LN",1)
replace street=subinstr(street,"MORRISSEY LA","MORRISSEY LN",1)

replace location=subinstr(location,"MT PLEASANT RD","MOUNT PLEASANT RD",1)
replace street=subinstr(street,"MT PLEASANT RD","MOUNT PLEASANT RD",1)

replace location=subinstr(location,"NO FOREST CIRCLE","N FOREST CIR",1)
replace street=subinstr(street,"NO FOREST CIRCLE","N FOREST CIR",1)

replace location=subinstr(location,"OLEANDER AVE","OLEANDER ST",1)
replace street=subinstr(street,"OLEANDER AVE","OLEANDER ST",1)

replace location=subinstr(location,"OLIVER LA","OLIVER LN",1)
replace street=subinstr(street,"OLIVER LA","OLIVER LN",1)

replace location=subinstr(location,"OXBOW LA","OXBOW LN",1)
replace street=subinstr(street,"OXBOW LA","OXBOW LN",1)

replace location=subinstr(location,"PETER LA","PETER LN",1)
replace street=subinstr(street,"PETER LA","PETER LN",1)

replace location=subinstr(location,"RANGELEY ST","RANGELY ST",1)
replace street=subinstr(street,"RANGELEY ST","RANGELY ST",1)

replace location=subinstr(location,"SAWMILL RD","SAW MILL RD",1)
replace street=subinstr(street,"SAWMILL RD","SAW MILL RD",1)

replace location=subinstr(location,"SHADY LANE","SHADY LN",1)
replace street=subinstr(street,"SHADY LANE","SHADY LN",1)

replace location=subinstr(location,"SHERRY CIRCLE","SHERRY CIR",1)
replace street=subinstr(street,"SHERRY CIRCLE","SHERRY CIR",1)

replace location=subinstr(location,"SIMOS LA","SIMOS LN",1)
replace street=subinstr(street,"SIMOS LA","SIMOS LN",1)

replace location=subinstr(location,"SO FOREST CIRCLE","S FOREST CIR",1)
replace street=subinstr(street,"SO FOREST CIRCLE","S FOREST CIR",1)

replace location=subinstr(location,"SORENSEN RD","SORENSON RD",1)
replace street=subinstr(street,"SORENSEN RD","SORENSON RD",1)

replace location=subinstr(location,"SUNDANCE CIRCLE","SUNDANCE CIR",1)
replace street=subinstr(street,"SUNDANCE CIRCLE","SUNDANCE CIR",1)

replace location=subinstr(location,"SUNFLOWER CR","SUNFLOWER CIR",1)
replace street=subinstr(street,"SUNFLOWER CR","SUNFLOWER CIR",1)

replace location=subinstr(location,"TYROL LA","TYROLL LN",1)
replace street=subinstr(street,"TYROL LA","TYROLL LN",1)

replace location=subinstr(location,"VALLEY BROOK","VALLEY BROOK RD",1)
replace street=subinstr(street,"VALLEY BROOK","VALLEY BROOK RD",1)

replace location=subinstr(location,"W PROSPECT","W PROSPECT ST",1)
replace street=subinstr(street,"W PROSPECT","W PROSPECT ST",1)

replace location=subinstr(location,"WHARTON ST","WHARTON PL",1) if street=="WHARTON ST"&PropertyStreet=="WHARTON PL"
replace street=subinstr(street,"WHARTON ST","WHARTON PL",1) if street=="WHARTON ST"&PropertyStreet=="WHARTON PL"

replace location=subinstr(location,"WHITNEY LA","WHITNEY LN",1)
replace street=subinstr(street,"WHITNEY LA","WHITNEY LN",1)

replace location=subinstr(location,"WOODHILL LA","WOODHILL LN",1)
replace street=subinstr(street,"WOODHILL LA","WOODHILL LN",1)

replace location=subinstr(location,"WOODY LA","WOODY LN",1)
replace street=subinstr(street,"WOODY LA","WOODY LN",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_westhaven.dta",replace

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

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Westport Specific
replace location=subinstr(location,"APPLETREE TRL","APPLE TREE TRL",1)
replace street=subinstr(street,"APPLETREE TRL","APPLE TREE TRL",1)

replace location=subinstr(location,"BLUEWATER HILL","BLUEWATER HL",1)
replace street=subinstr(street,"BLUEWATER HILL","BLUEWATER HL",1)

replace location=subinstr(location,"BLUEWATER HILL S","BLUEWATER HL S",1)
replace street=subinstr(street,"BLUEWATER HILL S","BLUEWATER HL S",1)

replace location=subinstr(location,"BURNHAM HILL","BURNHAM HL",1)
replace street=subinstr(street,"BURNHAM HILL","BURNHAM HL",1)

replace location=subinstr(location,"COMPO MILL COVE","COMPO MILL CV",1)
replace street=subinstr(street,"COMPO MILL COVE","COMPO MILL CV",1)

replace location=subinstr(location,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)
replace street=subinstr(street,"DRIFTWOOD PT RD","DRIFTWOOD POINT RD",1)

replace location=subinstr(location,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)
replace street=subinstr(street,"EDGEWATER CMNS LN","EDGEWATER COMMONS LN",1)

replace location=subinstr(location,"GREENS FARMS HOL","GREENS FARMS HOLW",1)
replace street=subinstr(street,"GREENS FARMS HOL","GREENS FARMS HOLW",1)

replace location=subinstr(location,"GROVE PT RD","GROVE PT",1)
replace street=subinstr(street,"GROVE PT RD","GROVE PT",1)

replace location=subinstr(location,"HARBOR HILL","HARBOR HL",1)
replace street=subinstr(street,"HARBOR HILL","HARBOR HL",1)

replace location=subinstr(location,"HIAWATHA LN","HIAWATHA LANE EXT",1)
replace street=subinstr(street,"HIAWATHA LN","HIAWATHA LANE EXT",1)

replace location=subinstr(location,"HIDE-AWAY LN","HIDEAWAY LN",1)
replace street=subinstr(street,"HIDE-AWAY LN","HIDEAWAY LN",1)

replace location=subinstr(location,"HORSESHOE CT","HORSESHOE LN",1)
replace street=subinstr(street,"HORSESHOE CT","HORSESHOE LN",1)

replace location=subinstr(location,"JUDY PT LN","JUDY POINT LN",1)
replace street=subinstr(street,"JUDY PT LN","JUDY POINT LN",1)

replace location=subinstr(location,"LAZY BRK LN","LAZY BROOK LN",1)
replace street=subinstr(street,"LAZY BRK LN","LAZY BROOK LN",1)

replace location=subinstr(location,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)
replace street=subinstr(street,"MAPLEGROVE AVE","MAPLE GROVE AVE",1)

replace location=subinstr(location,"MARSH RD","MARSH CT",1)
replace street=subinstr(street,"MARSH RD","MARSH CT",1)

replace location=subinstr(location,"MINUTE MAN HILL","MINUTE MAN HL",1)
replace street=subinstr(street,"MINUTE MAN HILL","MINUTE MAN HL",1)

replace location=subinstr(location,"OAK RDG PK","OAK RIDGE PARK",1)
replace street=subinstr(street,"OAK RDG PK","OAK RIDGE PARK",1)

replace location=subinstr(location,"OWENOKE PK","OWENOKE PARK",1)
replace street=subinstr(street,"OWENOKE PK","OWENOKE PARK",1)

replace location=subinstr(location,"RIVARD CRESCENT","RIVARD CRES",1)
replace street=subinstr(street,"RIVARD CRESCENT","RIVARD CRES",1)

replace location=subinstr(location,"RIVERVIEW RD","RIVER VIEW RD",1)
replace street=subinstr(street,"RIVERVIEW RD","RIVER VIEW RD",1)

replace location=subinstr(location,"ROWLAND CT","ROWLAND PL",1)
replace street=subinstr(street,"ROWLAND CT","ROWLAND PL",1)

replace location=subinstr(location,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)
replace street=subinstr(street,"SHERWOOD FARMS LN","SHERWOOD FARMS",1)

replace location=subinstr(location,"SMOKY LN","SMOKEY LN",1)
replace street=subinstr(street,"SMOKY LN","SMOKEY LN",1)

replace location=subinstr(location,"STONY PT RD","STONY POINT RD",1)
replace street=subinstr(street,"STONY PT RD","STONY POINT RD",1)

replace PropertyFullStreetAddress=subinstr(PropertyFullStreetAddress,"STONEY POINT RD","STONY POINT RD",1)
replace PropertyStreet=subinstr(PropertyStreet,"STONEY POINT RD","STONY POINT RD",1)

replace location=subinstr(location,"STONY PT W","STONY POINT RD W",1)
replace street=subinstr(street,"STONY PT W","STONY POINT RD W",1)

replace location=subinstr(location,"SURREY DR","SURREY LN",1)
replace street=subinstr(street,"SURREY DR","SURREY LN",1)

replace location=subinstr(location,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)
replace street=subinstr(street,"VALLEY HGTS RD","VALLEY HEIGHTS RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"BAUER PL EXT","BAUER PLACE EXT",1)
replace street=subinstr(street,"BAUER PL EXT","BAUER PLACE EXT",1)

replace location=subinstr(location,"BERKELEY HILL","BERKELEY HL",1)
replace street=subinstr(street,"BERKELEY HILL","BERKELEY HL",1)

replace location=subinstr(location,"BLIND BRK RD","BLIND BROOK RD",1)
replace street=subinstr(street,"BLIND BRK RD","BLIND BROOK RD",1)

replace location=subinstr(location,"BLIND BRK RD S","BLIND BROOK RD S",1)
replace street=subinstr(street,"BLIND BRK RD S","BLIND BROOK RD S",1)

replace location=subinstr(location,"BONNIE BRK LN","BONNIE BROOK LN",1)
replace street=subinstr(street,"BONNIE BRK LN","BONNIE BROOK LN",1)

replace location=subinstr(location,"BREEZY KNOLL","BREEZY KNLS",1)
replace street=subinstr(street,"BREEZY KNOLL","BREEZY KNLS",1)

replace location=subinstr(location,"BROOKSIDE PK","BROOKSIDE PARK",1)
replace street=subinstr(street,"BROOKSIDE PK","BROOKSIDE PARK",1)

replace location=subinstr(location,"BUSHY RDG RD","BUSHY RIDGE RD",1)
replace street=subinstr(street,"BUSHY RDG RD","BUSHY RIDGE RD",1)

replace location=subinstr(location,"CACCAMO LN EXT","CACCAMO LN",1) if street=="CACCAMO LN EXT"&PropertyStreet=="CACCAMO LN"
replace street=subinstr(street,"CACCAMO LN EXT","CACCAMO LN",1) if street=="CACCAMO LN EXT"&PropertyStreet=="CACCAMO LN"

replace location=subinstr(location,"CALUMET LN","CALUMET RD",1) if street=="CALUMET LN"&PropertyStreet=="CALUMET RD"
replace street=subinstr(street,"CALUMET LN","CALUMET RD",1) if street=="CALUMET LN"&PropertyStreet=="CALUMET RD"

replace location=subinstr(location,"CANTERBURY CL","CANTERBURY CLOSE",1)
replace street=subinstr(street,"CANTERBURY CL","CANTERBURY CLOSE",1)

replace location=subinstr(location,"COVLEE DR","COVELEE DR",1)
replace street=subinstr(street,"COVLEE DR","COVELEE DR",1)

replace location=subinstr(location,"CROSS BRK LN","CROSS BROOK LN",1)
replace street=subinstr(street,"CROSS BRK LN","CROSS BROOK LN",1)

replace location=subinstr(location,"CROW HOL LN","CROW HOLLOW LN",1)
replace street=subinstr(street,"CROW HOL LN","CROW HOLLOW LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"EAST MEADOW RD","E MEADOW RD",1)
replace street=subinstr(street,"EAST MEADOW RD","E MEADOW RD",1)

replace location=subinstr(location,"FEATHER HILL","FEATHER HILL RD",1)
replace street=subinstr(street,"FEATHER HILL","FEATHER HILL RD",1)

replace location=subinstr(location,"FLINTLOCK RDG","FLINTLOCK RIDGE RD",1)
replace street=subinstr(street,"FLINTLOCK RDG","FLINTLOCK RIDGE RD",1)

replace location=subinstr(location,"FRESENIUS RD","FRESCENIUS RD",1)
replace street=subinstr(street,"FRESENIUS RD","FRESCENIUS RD",1)

replace location=subinstr(location,"GAULT PK DR","GAULT PARK DR",1)
replace street=subinstr(street,"GAULT PK DR","GAULT PARK DR",1)

replace location=subinstr(location,"GREAT MARSH CT","GREAT MARSH RD",1)
replace street=subinstr(street,"GREAT MARSH CT","GREAT MARSH RD",1)

replace location=subinstr(location,"HAWTHORNE LANE","HAWTHORNE LN",1)
replace street=subinstr(street,"HAWTHORNE LANE","HAWTHORNE LN",1)

replace location=subinstr(location,"HEATHER HILL","HEATHER HL",1)
replace street=subinstr(street,"HEATHER HILL","HEATHER HL",1)

replace location=subinstr(location,"HEMLOCK HILL","HEMLOCK HILL RD",1)
replace street=subinstr(street,"HEMLOCK HILL","HEMLOCK HILL RD",1)

replace location=subinstr(location,"HIAWATHA LANE EXT","HIAWATHA LN",1) if street=="HIAWATHA LANE EXT"&PropertyStreet=="HIAWATHA LN"
replace street=subinstr(street,"HIAWATHA LANE EXT","HIAWATHA LN",1) if street=="HIAWATHA LANE EXT"&PropertyStreet=="HIAWATHA LN"

replace location=subinstr(location,"HIDDEN HILL","HIDDEN HILL RD",1)
replace street=subinstr(street,"HIDDEN HILL","HIDDEN HILL RD",1)

replace location=subinstr(location,"HIGH PT RD","HIGH POINT RD",1)
replace street=subinstr(street,"HIGH PT RD","HIGH POINT RD",1)

replace location=subinstr(location,"HILLYFIELD LN","HILLY FIELD LN",1)
replace street=subinstr(street,"HILLYFIELD LN","HILLY FIELD LN",1)

replace location=subinstr(location,"INDIAN PT LN","INDIAN POINT LN",1)
replace street=subinstr(street,"INDIAN PT LN","INDIAN POINT LN",1)

replace location=subinstr(location,"IRON GATE HILL","IRON GATE HL",1)
replace street=subinstr(street,"IRON GATE HILL","IRON GATE HL",1)

replace location=subinstr(location,"IVY KNOLL","IVY KNLS",1)
replace street=subinstr(street,"IVY KNOLL","IVY KNLS",1)

replace location=subinstr(location,"JOANN CIR","JOANNE CIR",1)
replace street=subinstr(street,"JOANN CIR","JOANNE CIR",1)

replace location=subinstr(location,"KEENES RD","KEENE RD",1)
replace street=subinstr(street,"KEENES RD","KEENE RD",1)

replace location=subinstr(location,"LOWLYN RD","LOWLYN DR",1)
replace street=subinstr(street,"LOWLYN RD","LOWLYN DR",1)

replace location=subinstr(location,"LYNDALE PK","LYNDALE PARK",1)
replace street=subinstr(street,"LYNDALE PK","LYNDALE PARK",1)

replace location=subinstr(location,"MAPLE GROVE AVE","MAPLEGROVE AVE",1)
replace street=subinstr(street,"MAPLE GROVE AVE","MAPLEGROVE AVE",1)

replace location=subinstr(location,"MEADOW BRK LN","MEADOWBROOK LN",1)
replace street=subinstr(street,"MEADOW BRK LN","MEADOWBROOK LN",1)

replace location=subinstr(location,"MILL BANK RD","MILLBANK RD",1)
replace street=subinstr(street,"MILL BANK RD","MILLBANK RD",1)

replace location=subinstr(location,"NORTH PASTURE RD","N PASTURE RD",1)
replace street=subinstr(street,"NORTH PASTURE RD","N PASTURE RD",1)

replace location=subinstr(location,"NORTH RDG RD","N RIDGE RD",1)
replace street=subinstr(street,"NORTH RDG RD","N RIDGE RD",1)

replace location=subinstr(location,"NORTH SASCO CMN","N SASCO CMN",1)
replace street=subinstr(street,"NORTH SASCO CMN","N SASCO CMN",1)

replace location=subinstr(location,"OAK VIEW CIR","OAKVIEW CIR",1)
replace street=subinstr(street,"OAK VIEW CIR","OAKVIEW CIR",1)

replace location=subinstr(location,"OAK VIEW LN","OAKVIEW LN",1)
replace street=subinstr(street,"OAK VIEW LN","OAKVIEW LN",1)

replace location=subinstr(location,"POPLAR PLAIN RD","POPLAR PLAINS RD",1)
replace street=subinstr(street,"POPLAR PLAIN RD","POPLAR PLAINS RD",1)

replace location=subinstr(location,"PUMPKIN HILL","PUMPKIN HILL RD",1)
replace street=subinstr(street,"PUMPKIN HILL","PUMPKIN HILL RD",1)

replace location=subinstr(location,"RIPPLING BRK LN","RIPPLING BROOK LN",1)
replace street=subinstr(street,"RIPPLING BRK LN","RIPPLING BROOK LN",1)

replace location=subinstr(location,"RIVER KNOLL","RIVER KNL",1)
replace street=subinstr(street,"RIVER KNOLL","RIVER KNL",1)

replace location=subinstr(location,"ROCKY RDG RD","ROCKY RIDGE RD",1)
replace street=subinstr(street,"ROCKY RDG RD","ROCKY RIDGE RD",1)

replace location=subinstr(location,"RODGERS WAY","ROGERS WAY",1)
replace street=subinstr(street,"RODGERS WAY","ROGERS WAY",1)

replace location=subinstr(location,"SAINT JOHN PL","SAINT JOHNS PL",1)
replace street=subinstr(street,"SAINT JOHN PL","SAINT JOHNS PL",1)

replace location=subinstr(location,"SCOT-ALAN LN","SCOT ALAN LN",1)
replace street=subinstr(street,"SCOT-ALAN LN","SCOT ALAN LN",1)

replace location=subinstr(location,"SILENT GROVE N","SILENT GRV",1)
replace street=subinstr(street,"SILENT GROVE N","SILENT GRV",1)

replace location=subinstr(location,"SILVER BRK RD","SILVER BROOK RD",1)
replace street=subinstr(street,"SILVER BRK RD","SILVER BROOK RD",1)

replace location=subinstr(location,"SLEEPY HOL","SLEEPY HOLLOW RD",1)
replace street=subinstr(street,"SLEEPY HOL","SLEEPY HOLLOW RD",1)

replace location=subinstr(location,"STONY BRK RD","STONYBROOK RD",1)
replace street=subinstr(street,"STONY BRK RD","STONYBROOK RD",1)

replace location=subinstr(location,"STURGES CMNS","STURGES COMMONS",1)
replace street=subinstr(street,"STURGES CMNS","STURGES COMMONS",1)

replace location=subinstr(location,"STURGES HOL","STURGES HOLW",1)
replace street=subinstr(street,"STURGES HOL","STURGES HOLW",1)

replace location=subinstr(location,"TERAGRAM PL","TEREGRAM PL",1)
replace street=subinstr(street,"TERAGRAM PL","TEREGRAM PL",1)

replace location=subinstr(location,"WATCH HILL","WATCH HL",1)
replace street=subinstr(street,"WATCH HILL","WATCH HL",1)

replace location=subinstr(location,"WEATHERVANE HILL","WEATHERVANE HL",1)
replace street=subinstr(street,"WEATHERVANE HILL","WEATHERVANE HL",1)

replace location=subinstr(location,"WEDGE WOOD RD","WEDGEWOOD RD",1)
replace street=subinstr(street,"WEDGE WOOD RD","WEDGEWOOD RD",1)

replace location=subinstr(location,"WEST BRANCH RD","W BRANCH RD",1)
replace street=subinstr(street,"WEST BRANCH RD","W BRANCH RD",1)

replace location=subinstr(location,"WEST PARISH RD","W PARISH RD",1)
replace street=subinstr(street,"WEST PARISH RD","W PARISH RD",1)

replace location=subinstr(location,"WHITNEY ST EXT","WHITNEY STREET EXT",1)
replace street=subinstr(street,"WHITNEY ST EXT","WHITNEY STREET EXT",1)

replace location=subinstr(location,"WILLOW WALK RD","WILLOW WALK",1) if street=="WILLOW WALK RD"&PropertyStreet=="WILLOW WALK"
replace street=subinstr(street,"WILLOW WALK RD","WILLOW WALK",1) if street=="WILLOW WALK RD"&PropertyStreet=="WILLOW WALK"

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_westport.dta",replace

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
replace street=trim(street)
replace PropertyStreet=trim(PropertyStreet)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Stratford Specific
replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"WEST BEACH DR","W BEACH DR",1)
replace street=subinstr(street,"WEST BEACH DR","W BEACH DR",1)

replace location=subinstr(location,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)
replace street=subinstr(street,"WEST HILLSIDE AVE","W HILLSIDE AVE",1)

replace location=subinstr(location,"ABRAM ST-N","N ABRAM ST",1)
replace street=subinstr(street,"ABRAM ST-N","N ABRAM ST",1)

replace location=subinstr(location,"ADOLPHSON ST","ADOLPHSON AVE",1)
replace street=subinstr(street,"ADOLPHSON ST","ADOLPHSON AVE",1)

replace location=subinstr(location,"ARROWWOOD PL","ARROWOOD PL",1)
replace street=subinstr(street,"ARROWWOOD PL","ARROWOOD PL",1)

replace location=subinstr(location,"BARNUM TER-EXT","BARNUM TERRACE EXT",1)
replace street=subinstr(street,"BARNUM TER-EXT","BARNUM TERRACE EXT",1)

replace location=subinstr(location,"BEAVER DAM ACC RD","BEAVER DAM ACCESS RD",1)
replace street=subinstr(street,"BEAVER DAM ACC RD","BEAVER DAM ACCESS RD",1)

replace location=subinstr(location,"CLOVER LEA PL","CLOVERLEA PL",1)
replace street=subinstr(street,"CLOVER LEA PL","CLOVERLEA PL",1)

replace location=subinstr(location,"COPPER KETTLE DR","COPPER KETTLE RD",1)
replace street=subinstr(street,"COPPER KETTLE DR","COPPER KETTLE RD",1)

replace location=subinstr(location,"EAST BROADWAY","E BROADWAY",1)
replace street=subinstr(street,"EAST BROADWAY","E BROADWAY",1)

replace location=subinstr(location,"EAST GATE LN","E GATE LN",1)
replace street=subinstr(street,"EAST GATE LN","E GATE LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"EAST PKWY","E PARKWAY DR",1)
replace street=subinstr(street,"EAST PKWY","E PARKWAY DR",1)

replace location=subinstr(location,"GLENRIDGE RD","GLENRIDGE RD E",1) if street=="GLENRIDGE RD"&PropertyStreet=="GLENRIDGE RD E"
replace street=subinstr(street,"GLENRIDGE RD","GLENRIDGE RD E",1) if street=="GLENRIDGE RD"&PropertyStreet=="GLENRIDGE RD E"

replace location=subinstr(location,"GRACE LANE","GRACE LN",1)
replace street=subinstr(street,"GRACE LANE","GRACE LN",1)

replace location=subinstr(location,"GRIFFIN ST","GRIFFEN ST",1)
replace street=subinstr(street,"GRIFFIN ST","GRIFFEN ST",1)

replace location=subinstr(location,"HENRY AVE-EXT","HENRY AVENUE EXT",1)
replace street=subinstr(street,"HENRY AVE-EXT","HENRY AVENUE EXT",1)

replace location=subinstr(location,"HOMECREST AVE","HOMECREST PL",1)
replace street=subinstr(street,"HOMECREST AVE","HOMECREST PL",1)

replace location=subinstr(location,"HOUSATONIC AVE-EXT","HOUSATONIC AVENUE EXT",1)
replace street=subinstr(street,"HOUSATONIC AVE-EXT","HOUSATONIC AVENUE EXT",1)

replace location=subinstr(location,"ISLAND VIEW RD","ISLANDVIEW RD",1)
replace street=subinstr(street,"ISLAND VIEW RD","ISLANDVIEW RD",1)

replace location=subinstr(location,"LAUGHLIN RD-E","LAUGHLIN RD E",1)
replace street=subinstr(street,"LAUGHLIN RD-E","LAUGHLIN RD E",1)

replace location=subinstr(location,"LAUGHLIN RD-W","LAUGHLIN RD W",1)
replace street=subinstr(street,"LAUGHLIN RD-W","LAUGHLIN RD W",1)

replace location=subinstr(location,"LAUGHLIN RD W","LAUGHLIN RD",1) if street=="LAUGHLIN RD W"&PropertyStreet=="LAUGHLIN RD"
replace street=subinstr(street,"LAUGHLIN RD W","LAUGHLIN RD",1) if street=="LAUGHLIN RD W"&PropertyStreet=="LAUGHLIN RD"

replace location=subinstr(location,"MAC ARTHUR DR","MACARTHUR DR",1)
replace street=subinstr(street,"MAC ARTHUR DR","MACARTHUR DR",1)

replace location=subinstr(location,"MARCHANT RD","MARCHANT DR",1)
replace street=subinstr(street,"MARCHANT RD","MARCHANT DR",1)

replace location=subinstr(location,"MT CARMEL BLVD","MOUNT CARMEL BLVD",1)
replace street=subinstr(street,"MT CARMEL BLVD","MOUNT CARMEL BLVD",1)

replace location=subinstr(location,"MT PLEASANT AVE","MOUNT PLEASANT AVE",1)
replace street=subinstr(street,"MT PLEASANT AVE","MOUNT PLEASANT AVE",1)

replace location=subinstr(location,"NORTH ACRE PL","N ACRE PL",1)
replace street=subinstr(street,"NORTH ACRE PL","N ACRE PL",1)

replace location=subinstr(location,"NORTH JOHNSON LN","N JOHNSON LN",1)
replace street=subinstr(street,"NORTH JOHNSON LN","N JOHNSON LN",1)

replace location=subinstr(location,"NORTH PARADE ST","N PARADE ST",1)
replace street=subinstr(street,"NORTH PARADE ST","N PARADE ST",1)

replace location=subinstr(location,"NORTH PASTURE LN","N PASTURE LN",1)
replace street=subinstr(street,"NORTH PASTURE LN","N PASTURE LN",1)

replace location=subinstr(location,"NORTH PETERS LN","N PETERS LN",1)
replace street=subinstr(street,"NORTH PETERS LN","N PETERS LN",1)

replace location=subinstr(location,"OLYMPIA ST","OLYMPIA AVE",1) if street=="OLYMPIA ST"&PropertyStreet=="OLYMPIA AVE"
replace street=subinstr(street,"OLYMPIA ST","OLYMPIA AVE",1) if street=="OLYMPIA ST"&PropertyStreet=="OLYMPIA AVE"

replace location=subinstr(location,"PARKVIEW LN","PARK VIEW LN",1)
replace street=subinstr(street,"PARKVIEW LN","PARK VIEW LN",1)

replace location=subinstr(location,"PAUGASITT DR","PAUGASSIT DR",1)
replace street=subinstr(street,"PAUGASITT DR","PAUGASSIT DR",1)

replace location=subinstr(location,"REITTER ST","REITTER ST W",1) if street=="REITTER ST"&PropertyStreet=="REITTER ST W"
replace street=subinstr(street,"REITTER ST","REITTER ST W",1) if street=="REITTER ST"&PropertyStreet=="REITTER ST W"

replace location=subinstr(location,"RIPTON PARISH LN","RIPTON PARISH",1)
replace street=subinstr(street,"RIPTON PARISH LN","RIPTON PARISH",1)

replace location=subinstr(location,"SECOND HILL LN","2ND HILL LN",1)
replace street=subinstr(street,"SECOND HILL LN","2ND HILL LN",1)

replace location=subinstr(location,"SHERBROOKE RD","SHERBROOK RD",1)
replace street=subinstr(street,"SHERBROOKE RD","SHERBROOK RD",1)

replace location=subinstr(location,"ST ANDREW ST","SAINT ANDREWS ST",1)
replace street=subinstr(street,"ST ANDREW ST","SAINT ANDREWS ST",1)

replace location=subinstr(location,"ST MICHAELS AVE","SAINT MICHAELS AVE",1)
replace street=subinstr(street,"ST MICHAELS AVE","SAINT MICHAELS AVE",1)

replace location=subinstr(location,"SUMMIT ST","SUMMITT ST",1)
replace street=subinstr(street,"SUMMIT ST","SUMMITT ST",1)

replace location=subinstr(location,"VALLEY BROOK TERR","VALLEY BROOK TER",1)
replace street=subinstr(street,"VALLEY BROOK TERR","VALLEY BROOK TER",1)

replace location=subinstr(location,"WEST BROAD ST","W BROAD ST",1)
replace street=subinstr(street,"WEST BROAD ST","W BROAD ST",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_stratford.dta",replace

*******Branford********
use "$GIS\propbrev_wf_branford.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=house_no

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street


replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*Branford Specific
replace location=subinstr(location,"ASH CREEK DR","ASH CREEK RD",1)
replace street=subinstr(street,"ASH CREEK DR","ASH CREEK RD",1)

replace location=subinstr(location,"BAYARDS CROSSING","BAYARDS XING",1)
replace street=subinstr(street,"BAYARDS CROSSING","BAYARDS XING",1)

replace location=subinstr(location,"BAYBERRY LA","BAYBERRY LN",1)
replace street=subinstr(street,"BAYBERRY LA","BAYBERRY LN",1)

replace location=subinstr(location,"BRANDEGEE AVE","BRANDAGEE AVE",1)
replace street=subinstr(street,"BRANDEGEE AVE","BRANDAGEE AVE",1)

replace location=subinstr(location,"BREEZY LA","BREEZY LN",1)
replace street=subinstr(street,"BREEZY LA","BREEZY LN",1)

replace location=subinstr(location,"BRIARWOOD LA","BRIARWOOD LN",1)
replace street=subinstr(street,"BRIARWOOD LA","BRIARWOOD LN",1)

replace location=subinstr(location,"BROCKETTS LA","BROCKETTS LN",1)
replace street=subinstr(street,"BROCKETTS LA","BROCKETTS LN",1)

replace location=subinstr(location,"BROCKETTS PT RD","BROCKETTS POINT RD",1)
replace street=subinstr(street,"BROCKETTS PT RD","BROCKETTS POINT RD",1)

replace location=subinstr(location,"BUENA VIS RD","BUENA VISTA RD",1)
replace street=subinstr(street,"BUENA VIS RD","BUENA VISTA RD",1)

replace location=subinstr(location,"BUNGALOW LA","BUNGALOW LN",1)
replace street=subinstr(street,"BUNGALOW LA","BUNGALOW LN",1)

replace location=subinstr(location,"CAPTAINS LA","CAPTAINS LN",1)
replace street=subinstr(street,"CAPTAINS LA","CAPTAINS LN",1)

replace location=subinstr(location,"CIDER MILL LA","CIDER MILL LN",1)
replace street=subinstr(street,"CIDER MILL LA","CIDER MILL LN",1)

replace location=subinstr(location,"EAST HAYCOCK PT RD","E HAYCOCK POINT RD",1)
replace street=subinstr(street,"EAST HAYCOCK PT RD","E HAYCOCK POINT RD",1)

replace location=subinstr(location,"EDGEWOOD ST","EDGEWOOD RD",1)
replace street=subinstr(street,"EDGEWOOD ST","EDGEWOOD RD",1)

replace location=subinstr(location,"EIGHTH AVE","8TH AVE",1)
replace street=subinstr(street,"EIGHTH AVE","8TH AVE",1)

replace location=subinstr(location,"FERRY LA","FERRY LN",1)
replace street=subinstr(street,"FERRY LA","FERRY LN",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FLYING PT RD","FLYING POINT RD",1)
replace street=subinstr(street,"FLYING PT RD","FLYING POINT RD",1)

replace location=subinstr(location,"FOREST ST EXT","FOREST STREET EXT",1)
replace street=subinstr(street,"FOREST ST EXT","FOREST STREET EXT",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"GOODSELL PT RD","GOODSELL POINT RD",1)
replace street=subinstr(street,"GOODSELL PT RD","GOODSELL POINT RD",1)

replace location=subinstr(location,"GREYLEDGE RD","GRAY LEDGE RD",1)
replace street=subinstr(street,"GREYLEDGE RD","GRAY LEDGE RD",1)

replace location=subinstr(location,"GROVE ST","GROVE STREET EXT",1)
replace street=subinstr(street,"GROVE ST","GROVE STREET EXT",1)

replace location=subinstr(location,"HALLS PT RD","HALLS POINT RD",1)
replace street=subinstr(street,"HALLS PT RD","HALLS POINT RD",1)

replace location=subinstr(location,"HALSTEAD LA","HALSTEAD LN",1)
replace street=subinstr(street,"HALSTEAD LA","HALSTEAD LN",1)

replace location=subinstr(location,"HOLLY LA","HOLLY LN",1)
replace street=subinstr(street,"HOLLY LA","HOLLY LN",1)

replace location=subinstr(location,"INDIAN PT RD","INDIAN POINT RD",1)
replace street=subinstr(street,"INDIAN PT RD","INDIAN POINT RD",1)

replace location=subinstr(location,"ISABEL LA","ISABEL LN",1)
replace street=subinstr(street,"ISABEL LA","ISABEL LN",1)

replace location=subinstr(location,"JOHNSONS PT RD","JOHNSONS POINT RD",1)
replace street=subinstr(street,"JOHNSONS PT RD","JOHNSONS POINT RD",1)

replace location=subinstr(location,"JUNIPER PT RD","JUNIPER POINT RD",1)
replace street=subinstr(street,"JUNIPER PT RD","JUNIPER POINT RD",1)

replace location=subinstr(location,"KATIE-JOE LA","KATIE JOE LN",1)
replace street=subinstr(street,"KATIE-JOE LA","KATIE JOE LN",1)

replace location=subinstr(location,"KELLYCREST RD","KELLY CREST RD",1)
replace street=subinstr(street,"KELLYCREST RD","KELLY CREST RD",1)

replace location=subinstr(location,"KENWOOD LA","KENWOOD LN",1)
replace street=subinstr(street,"KENWOOD LA","KENWOOD LN",1)

replace location=subinstr(location,"KILLAMS PT RD","KILLAMS PT",1)
replace street=subinstr(street,"KILLAMS PT RD","KILLAMS PT",1)

replace location=subinstr(location,"LAKE AVE","LAKE PL",1)
replace street=subinstr(street,"LAKE AVE","LAKE PL",1)

replace location=subinstr(location,"LANPHIERS COVE CAMP","LANPHIERS COVE CP",1)
replace street=subinstr(street,"LANPHIERS COVE CAMP","LANPHIERS COVE CP",1)

replace location=subinstr(location,"LINDEN PT RD","LINDEN POINT RD",1)
replace street=subinstr(street,"LINDEN PT RD","LINDEN POINT RD",1)

replace location=subinstr(location,"LINDSLEY ST","LINSLEY ST",1)
replace street=subinstr(street,"LINDSLEY ST","LINSLEY ST",1)

replace location=subinstr(location,"LITTLE BAY LA","LITTLE BAY LN",1)
replace street=subinstr(street,"LITTLE BAY LA","LITTLE BAY LN",1)

replace location=subinstr(location,"LONG PT RD","LONG POINT RD",1)
replace street=subinstr(street,"LONG PT RD","LONG POINT RD",1)

replace location=subinstr(location,"MARIAN RD","MARION RD",1)
replace street=subinstr(street,"MARIAN RD","MARION RD",1)

replace location=subinstr(location,"NINTH AVE","9TH AVE",1)
replace street=subinstr(street,"NINTH AVE","9TH AVE",1)

replace location=subinstr(location,"PAVILLION DR","PAVILION CT",1)
replace street=subinstr(street,"PAVILLION DR","PAVILION CT",1)

replace location=subinstr(location,"PLEASANT PT RD","PLEASANT POINT RD",1)
replace street=subinstr(street,"PLEASANT PT RD","PLEASANT POINT RD",1)

replace location=subinstr(location,"ROCKLAND PK","ROCKLAND PARK",1)
replace street=subinstr(street,"ROCKLAND PK","ROCKLAND PARK",1)

replace location=subinstr(location,"SECOND AVE","2ND AVE",1)
replace street=subinstr(street,"SECOND AVE","2ND AVE",1)

replace location=subinstr(location,"SEVENTH AVE","7TH AVE",1)
replace street=subinstr(street,"SEVENTH AVE","7TH AVE",1)

replace location=subinstr(location,"SHADY LA","SHADY LN",1)
replace street=subinstr(street,"SHADY LA","SHADY LN",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SO MONTOWESE ST","S MONTOWESE ST",1)
replace street=subinstr(street,"SO MONTOWESE ST","S MONTOWESE ST",1)

replace location=subinstr(location,"SOUND VIEW HGTS","SOUND VIEW HTS",1)
replace street=subinstr(street,"SOUND VIEW HGTS","SOUND VIEW HTS",1)

replace location=subinstr(location,"SPICE BUSH LA","SPICE BUSH LN",1)
replace street=subinstr(street,"SPICE BUSH LA","SPICE BUSH LN",1)

replace location=subinstr(location,"THIMBLE FARMS RD","THIMBLE FARM RD",1)
replace street=subinstr(street,"THIMBLE FARMS RD","THIMBLE FARM RD",1)

replace location=subinstr(location,"THIMBLE ISLANDS RD","THIMBLE ISLAND RD",1)
replace street=subinstr(street,"THIMBLE ISLANDS RD","THIMBLE ISLAND RD",1)

replace location=subinstr(location,"THIRD AVE","3RD AVE",1)
replace street=subinstr(street,"THIRD AVE","3RD AVE",1)

replace location=subinstr(location,"THREE ELM RD","THREE ELMS RD",1)
replace street=subinstr(street,"THREE ELM RD","THREE ELMS RD",1)

replace location=subinstr(location,"UNION AVE","UNION ST",1)
replace street=subinstr(street,"UNION AVE","UNION ST",1)

replace location=subinstr(location,"WEST HAYCOCK PT","W HAYCOCK POINT RD",1)
replace street=subinstr(street,"WEST HAYCOCK PT","W HAYCOCK POINT RD",1)

replace location=subinstr(location,"WEST PT RD","W POINT RD",1)
replace street=subinstr(street,"WEST PT RD","W POINT RD",1)

replace location=subinstr(location,"ABBOTTS LA","ABBOTTS LN",1)
replace street=subinstr(street,"ABBOTTS LA","ABBOTTS LN",1)

replace location=subinstr(location,"APPLE TREE LA","APPLE TREE LN",1)
replace street=subinstr(street,"APPLE TREE LA","APPLE TREE LN",1)

replace location=subinstr(location,"ARROW HEAD LA","ARROWHEAD LN",1)
replace street=subinstr(street,"ARROW HEAD LA","ARROWHEAD LN",1)

replace location=subinstr(location,"BRIGHTWOOD LA","BRIGHTWOOD LN",1)
replace street=subinstr(street,"BRIGHTWOOD LA","BRIGHTWOOD LN",1)

replace location=subinstr(location,"BUTTERMILK LA","BUTTERMILK LN",1)
replace street=subinstr(street,"BUTTERMILK LA","BUTTERMILK LN",1)

replace location=subinstr(location,"CHESTNUT ST","N CHESTNUT ST",1) if street=="CHESTNUT ST"&PropertyStreet=="N CHESTNUT ST"
replace street=subinstr(street,"CHESTNUT ST","N CHESTNUT ST",1) if street=="CHESTNUT ST"&PropertyStreet=="N CHESTNUT ST"

replace location=subinstr(location,"DEBRA LA","DEBRA LN",1)
replace street=subinstr(street,"DEBRA LA","DEBRA LN",1)

replace location=subinstr(location,"DORCHESTER LA","DORCHESTER LN",1)
replace street=subinstr(street,"DORCHESTER LA","DORCHESTER LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"FEATHERBED LA","FEATHERBED LN",1)
replace street=subinstr(street,"FEATHERBED LA","FEATHERBED LN",1)

replace location=subinstr(location,"FERN LA","FERN LN",1)
replace street=subinstr(street,"FERN LA","FERN LN",1)

replace location=subinstr(location,"FIR TREE DR NORTH","FIR TREE DR N",1)
replace street=subinstr(street,"FIR TREE DR NORTH","FIR TREE DR N",1)

replace location=subinstr(location,"FLAT ROCK RD EXT","FLAT ROCK ROAD EXT",1)
replace street=subinstr(street,"FLAT ROCK RD EXT","FLAT ROCK ROAD EXT",1)

replace location=subinstr(location,"FLAX MILL HOLLOW","FLAX MILL HOLW",1)
replace street=subinstr(street,"FLAX MILL HOLLOW","FLAX MILL HOLW",1)

replace location=subinstr(location,"GILBERT LA","GILBERT LN",1)
replace street=subinstr(street,"GILBERT LA","GILBERT LN",1)

replace location=subinstr(location,"GOULD LA","GOULD LN",1)
replace street=subinstr(street,"GOULD LA","GOULD LN",1)

replace location=subinstr(location,"GROVE STREET EXT","GROVE ST",1) if street=="GROVE STREET EXT"&PropertyStreet=="GROVE ST"
replace street=subinstr(street,"GROVE STREET EXT","GROVE ST",1) if street=="GROVE STREET EXT"&PropertyStreet=="GROVE ST"

replace location=subinstr(location,"HAMRE LA","HAMRE LN",1)
replace street=subinstr(street,"HAMRE LA","HAMRE LN",1)

replace location=subinstr(location,"HAY STACK RD","HAYSTACK RD",1)
replace street=subinstr(street,"HAY STACK RD","HAYSTACK RD",1)

replace location=subinstr(location,"HICKORY HILL LA","HICKORY HILL RD",1)
replace street=subinstr(street,"HICKORY HILL LA","HICKORY HILL RD",1)

replace location=subinstr(location,"HUNTING RIDGE FARMS","HUNTING RIDGE FARMS RD",1)
replace street=subinstr(street,"HUNTING RIDGE FARMS","HUNTING RIDGE FARMS RD",1)

replace location=subinstr(location,"IVY ST","N IVY ST",1) if street=="IVY ST"&PropertyStreet=="N IVY ST"
replace street=subinstr(street,"IVY ST","N IVY ST",1) if street=="IVY ST"&PropertyStreet=="N IVY ST"

replace location=subinstr(location,"JACOB LA","JACOB LN",1)
replace street=subinstr(street,"JACOB LA","JACOB LN",1)

replace location=subinstr(location,"JEFFREY LA","JEFFREY LN",1)
replace street=subinstr(street,"JEFFREY LA","JEFFREY LN",1)

replace location=subinstr(location,"LEDGE ROCK LA","LEDGEROCK",1) if street=="LEDGE ROCK LA"&PropertyStreet=="LEDGEROCK"
replace street=subinstr(street,"LEDGE ROCK LA","LEDGEROCK",1) if street=="LEDGE ROCK LA"&PropertyStreet=="LEDGEROCK"

replace location=subinstr(location,"LOMARTRA LA","LOMARTRA LN",1)
replace street=subinstr(street,"LOMARTRA LA","LOMARTRA LN",1)

replace location=subinstr(location,"MEADOW CIR RD","MEADOW CIRCLE RD",1)
replace street=subinstr(street,"MEADOW CIR RD","MEADOW CIRCLE RD",1)

replace location=subinstr(location,"MEDLEY LA","MEDLEY LN",1)
replace street=subinstr(street,"MEDLEY LA","MEDLEY LN",1)

replace location=subinstr(location,"MONTOWESE ST + PI","MONTOWESE ST",1)
replace street=subinstr(street,"MONTOWESE ST + PI","MONTOWESE ST",1)

replace location=subinstr(location,"NO BRANFORD RD","N BRANFORD RD",1)
replace street=subinstr(street,"NO BRANFORD RD","N BRANFORD RD",1)

replace location=subinstr(location,"NO HARBOR ST","N HARBOR ST",1)
replace street=subinstr(street,"NO HARBOR ST","N HARBOR ST",1)

replace location=subinstr(location,"NO MAIN ST","N MAIN ST",1)
replace street=subinstr(street,"NO MAIN ST","N MAIN ST",1)

replace location=subinstr(location,"O NEILL LA","ONEILL LN",1)
replace street=subinstr(street,"O NEILL LA","ONEILL LN",1)

replace location=subinstr(location,"OAK GATE DR","OAKGATE DR",1)
replace street=subinstr(street,"OAK GATE DR","OAKGATE DR",1)

replace location=subinstr(location,"OLD HICKORY LA","OLD HICKORY LN",1)
replace street=subinstr(street,"OLD HICKORY LA","OLD HICKORY LN",1)

replace location=subinstr(location,"OLD QUARRY RD","QUARRY RD",1) if street=="OLD QUARRY RD"&PropertyStreet=="QUARRY RD"
replace street=subinstr(street,"OLD QUARRY RD","QUARRY RD",1) if street=="OLD QUARRY RD"&PropertyStreet=="QUARRY RD"

replace location=subinstr(location,"PARTRIDGE LA","PARTRIDGE LN",1)
replace street=subinstr(street,"PARTRIDGE LA","PARTRIDGE LN",1)

replace location=subinstr(location,"PATRICK LA","PATRICK LN",1)
replace street=subinstr(street,"PATRICK LA","PATRICK LN",1)

replace location=subinstr(location,"PASTURE LA","PASTURE LN",1)
replace street=subinstr(street,"PASTURE LA","PASTURE LN",1)

replace location=subinstr(location,"PEPPERWOOD LA","PEPPERWOOD LN",1)
replace street=subinstr(street,"PEPPERWOOD LA","PEPPERWOOD LN",1)

replace location=subinstr(location,"REYNOLDS LA","REYNOLDS LN",1)
replace street=subinstr(street,"REYNOLDS LA","REYNOLDS LN",1)

replace location=subinstr(location,"RICE TERR","RICE TER",1)
replace street=subinstr(street,"RICE TERR","RICE TER",1)

replace location=subinstr(location,"RIVER WALK","RIVERWALK",1)
replace street=subinstr(street,"RIVER WALK","RIVERWALK",1)

replace location=subinstr(location,"ROCKY LEDGE LA","ROCKY LEDGE LN",1)
replace street=subinstr(street,"ROCKY LEDGE LA","ROCKY LEDGE LN",1)

replace location=subinstr(location,"SO MAIN ST","S MAIN ST",1)
replace street=subinstr(street,"SO MAIN ST","S MAIN ST",1)

replace location=subinstr(location,"SQUIRE LA","SQUIRE LN",1)
replace street=subinstr(street,"SQUIRE LA","SQUIRE LN",1)

replace location=subinstr(location,"STONE WALL LA","STONEWALL LN",1)
replace street=subinstr(street,"STONE WALL LA","STONEWALL LN",1)

replace location=subinstr(location,"SUNRISE COVE CAMP","SUNRISE COVE RD",1) if street=="SUNRISE COVE CAMP"&PropertyStreet=="SUNRISE COVE RD"
replace street=subinstr(street,"SUNRISE COVE CAMP","SUNRISE COVE RD",1) if street=="SUNRISE COVE CAMP"&PropertyStreet=="SUNRISE COVE RD"

replace location=subinstr(location,"SURREY LA","SURREY LN",1)
replace street=subinstr(street,"SURREY LA","SURREY LN",1)

replace location=subinstr(location,"THISTLE MEADOW LA","THISTLE MEADOW LN",1)
replace street=subinstr(street,"THISTLE MEADOW LA","THISTLE MEADOW LN",1)

replace location=subinstr(location,"VALLEY BROOK RD SO","VALLEY BROOK RD S",1)
replace street=subinstr(street,"VALLEY BROOK RD SO","VALLEY BROOK RD S",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"WHITE BIRCH LA","WHITE BIRCH LN",1)
replace street=subinstr(street,"WHITE BIRCH LA","WHITE BIRCH LN",1)

replace location=subinstr(location,"WOODVALE RD EXT","WOODVALE ROAD EXT",1)
replace street=subinstr(street,"WOODVALE RD EXT","WOODVALE ROAD EXT",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_branford.dta",replace

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


gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)

replace firsthash=ustrpos(location,"#",1)
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location," AV"," AVE",1)
replace street=subinstr(street," AV"," AVE",1)

replace location=subinstr(location,"BYWATER LN","BYWATYR LN",1)
replace street=subinstr(street,"BYWATER LN","BYWATYR LN",1)

replace location=subinstr(location,"EAST MAIN ST","E MAIN ST",1)
replace street=subinstr(street,"EAST MAIN ST","E MAIN ST",1)

replace location=subinstr(location,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)
replace street=subinstr(street,"EAST WASHINGTON AVE","E WASHINGTON AVE",1)

replace location=subinstr(location,"FAYERWEATHER TR","FAYERWEATHER TER",1)
replace street=subinstr(street,"FAYERWEATHER TR","FAYERWEATHER TER",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"GARDEN TR","GARDEN TER",1)
replace street=subinstr(street,"GARDEN TR","GARDEN TER",1)

replace location=subinstr(location,"MARINA PARK ST","MARINA PARK CIR",1)
replace street=subinstr(street,"MARINA PARK ST","MARINA PARK CIR",1)

replace location=subinstr(location,"MARTIN TR","MARTIN TER",1)
replace street=subinstr(street,"MARTIN TR","MARTIN TER",1)

replace location=subinstr(location," TR"," TER",1)
replace street=subinstr(street," TR"," TER",1)

replace location=subinstr(location,"OGDEN ST EX","OGDEN STREET EXT",1)
replace street=subinstr(street,"OGDEN ST EX","OGDEN STREET EXT",1)

replace location=subinstr(location,"PEARSALL WY","PEARSALL WAY",1)
replace street=subinstr(street,"PEARSALL WY","PEARSALL WAY",1)

replace location=subinstr(location,"SHERMAN PARK CR","SHERMAN PARK CIR",1)
replace street=subinstr(street,"SHERMAN PARK CR","SHERMAN PARK CIR",1)

replace location=subinstr(location,"SIXTH ST","6TH ST",1)
replace street=subinstr(street,"SIXTH ST","6TH ST",1)

replace location=subinstr(location,"WEST LIBERTY ST","W LIBERTY ST",1)
replace street=subinstr(street,"WEST LIBERTY ST","W LIBERTY ST",1)

replace location=subinstr(location,"ACORN AVE","ACORN ST",1)
replace street=subinstr(street,"ACORN AVE","ACORN ST",1)

replace location=subinstr(location,"ADOLF PL","ADOLPH PL",1)
replace street=subinstr(street,"ADOLF PL","ADOLPH PL",1)

replace location=subinstr(location,"ANTON CR","ANTON CIR",1)
replace street=subinstr(street,"ANTON CR","ANTON CIR",1)

replace location=subinstr(location,"ASIA CR","ASIA CIR",1)
replace street=subinstr(street,"ASIA CR","ASIA CIR",1)

replace location=subinstr(location,"BARBIERI CR","BARBERIE CIR",1)
replace street=subinstr(street,"BARBIERI CR","BARBERIE CIR",1)

replace location=subinstr(location,"BOWE ST","BOWE AVE",1)
replace street=subinstr(street,"BOWE ST","BOWE AVE",1)

replace location=subinstr(location,"BROADWAY NA","BROADWAY",1)
replace street=subinstr(street,"BROADWAY NA","BROADWAY",1)

replace location=subinstr(location,"CLARKE ST","CLARK ST",1)
replace street=subinstr(street,"CLARKE ST","CLARK ST",1)

replace location=subinstr(location,"CLEARVIEW CR","CLEARVIEW CIR",1)
replace street=subinstr(street,"CLEARVIEW CR","CLEARVIEW CIR",1)

replace location=subinstr(location,"COGGSWELL ST","COGSWELL ST",1)
replace street=subinstr(street,"COGGSWELL ST","COGSWELL ST",1)

replace location=subinstr(location,"COLONIAL AVE","COLONIAL AVE N",1) if street=="COLONIAL AVE"&PropertyStreet=="COLONIAL AVE N"
replace street=subinstr(street,"COLONIAL AVE","COLONIAL AVE N",1) if street=="COLONIAL AVE"&PropertyStreet=="COLONIAL AVE N"

replace location=subinstr(location,"DERMAN CR","DERMAN CIR",1)
replace street=subinstr(street,"DERMAN CR","DERMAN CIR",1)

replace location=subinstr(location,"DORA CR","DORA CIR",1)
replace street=subinstr(street,"DORA CR","DORA CIR",1)

replace location=subinstr(location,"EAST EATON ST","E EATON ST",1)
replace street=subinstr(street,"EAST EATON ST","E EATON ST",1)

replace location=subinstr(location,"EAST KENSINGTON PL","E KENSINGTON PL",1)
replace street=subinstr(street,"EAST KENSINGTON PL","E KENSINGTON PL",1)

replace location=subinstr(location,"EAST PASADENA PL","E PASADENA PL",1)
replace street=subinstr(street,"EAST PASADENA PL","E PASADENA PL",1)

replace location=subinstr(location,"EAST THORME ST","E THORME ST",1)
replace street=subinstr(street,"EAST THORME ST","E THORME ST",1)

replace location=subinstr(location,"ERIKA CR","ERIKA CIR",1)
replace street=subinstr(street,"ERIKA CR","ERIKA CIR",1)

replace location=subinstr(location,"EVERS EXT ST","EVERS STREET EXT",1) 
replace street=subinstr(street,"EVERS EXT ST","EVERS STREET EXT",1) 

replace location=subinstr(location,"EVERS ST","EVERS STREET EXT",1) if street=="EVERS ST"&PropertyStreet=="EVERS STREET EXT"
replace street=subinstr(street,"EVERS ST","EVERS STREET EXT",1) if street=="EVERS ST"&PropertyStreet=="EVERS STREET EXT"

replace location=subinstr(location,"FAIRVIEW EXT AVE","FAIRVIEW AVENUE EXT",1)
replace street=subinstr(street,"FAIRVIEW EXT AVE","FAIRVIEW AVENUE EXT",1)

replace location=subinstr(location,"FRANCES ST","FRANCIS ST",1)
replace street=subinstr(street,"FRANCES ST","FRANCIS ST",1)

replace location=subinstr(location,"GEDULDIG AVE","GEDULDIG ST",1)
replace street=subinstr(street,"GEDULDIG AVE","GEDULDIG ST",1)

replace location=subinstr(location,"GLEN CR","GLEN CIR",1)
replace street=subinstr(street,"GLEN CR","GLEN CIR",1)

replace location=subinstr(location,"GLENVALE CR","GLENVALE CIR",1)
replace street=subinstr(street,"GLENVALE CR","GLENVALE CIR",1)

replace location=subinstr(location,"GRIFFIN CR","GRIFFIN CIR",1)
replace street=subinstr(street,"GRIFFIN CR","GRIFFIN CIR",1)

replace location=subinstr(location,"HART ST","HART STREET EXT",1) if street=="HART ST"&PropertyStreet=="HART STREET EXT"
replace street=subinstr(street,"HART ST","HART STREET EXT",1) if street=="HART ST"&PropertyStreet=="HART STREET EXT"

replace location=subinstr(location,"HOLLAND HILL CR","HOLLAND HILL CIR",1)
replace street=subinstr(street,"HOLLAND HILL CR","HOLLAND HILL CIR",1)

replace location=subinstr(location,"HUNTINGTON TP","HUNTINGTON TPKE",1)
replace street=subinstr(street,"HUNTINGTON TP","HUNTINGTON TPKE",1)

replace location=subinstr(location,"IWANICKI CR","IWANICKI CIR",1)
replace street=subinstr(street,"IWANICKI CR","IWANICKI CIR",1)

replace location=subinstr(location,"JILIJAM PL","JILLIJAM PL",1)
replace street=subinstr(street,"JILIJAM PL","JILLIJAM PL",1)

replace location=subinstr(location,"LINCOLN BV","LINCOLN BLVD",1)
replace street=subinstr(street,"LINCOLN BV","LINCOLN BLVD",1)

replace location=subinstr(location,"LOFTUS CR","LOFTUS CIR",1)
replace street=subinstr(street,"LOFTUS CR","LOFTUS CIR",1)

replace location=subinstr(location,"MCKINLEY AVE","W MCKINLEY AVE",1) if street=="MCKINLEY AVE"&PropertyStreet=="W MCKINLEY AVE"
replace street=subinstr(street,"MCKINLEY AVE","W MCKINLEY AVE",1) if street=="MCKINLEY AVE"&PropertyStreet=="W MCKINLEY AVE"

replace location=subinstr(location,"MELBORNE ST","MELBOURNE ST",1)
replace street=subinstr(street,"MELBORNE ST","MELBOURNE ST",1)

replace location=subinstr(location,"NORMAN EXT ST","NORMAN STREET EXT",1)
replace street=subinstr(street,"NORMAN EXT ST","NORMAN STREET EXT",1)

replace location=subinstr(location,"NORTH ANTHONY ST","N ANTHONY ST",1)
replace street=subinstr(street,"NORTH ANTHONY ST","N ANTHONY ST",1)

replace location=subinstr(location,"NORTH BISHOP AVE","N BISHOP AVE",1)
replace street=subinstr(street,"NORTH BISHOP AVE","N BISHOP AVE",1)

replace location=subinstr(location,"NORTH QUARRY ST","N QUARRY ST",1)
replace street=subinstr(street,"NORTH QUARRY ST","N QUARRY ST",1)

replace location=subinstr(location,"NORTH RIDGEFIELD AVE","N RIDGEFIELD AVE",1)
replace street=subinstr(street,"NORTH RIDGEFIELD AVE","N RIDGEFIELD AVE",1)

replace location=subinstr(location,"NORTH SUMMERFIELD AVE","N SUMMERFIELD AVE",1)
replace street=subinstr(street,"NORTH SUMMERFIELD AVE","N SUMMERFIELD AVE",1)

replace location=subinstr(location,"NUTMEG CR","NUTMEG CIR",1)
replace street=subinstr(street,"NUTMEG CR","NUTMEG CIR",1)

replace location=subinstr(location,"OLSON CT","OLSEN CT",1)
replace street=subinstr(street,"OLSON CT","OLSEN CT",1)

replace location=subinstr(location,"OMAN ST","OMAN PL",1)
replace street=subinstr(street,"OMAN ST","OMAN PL",1)

replace location=subinstr(location,"OMEGA ST","OMEGA AVE",1)
replace street=subinstr(street,"OMEGA ST","OMEGA AVE",1)

replace location=subinstr(location,"PEARL HARBOR CR","PEARL HARBOR CIR",1)
replace street=subinstr(street,"PEARL HARBOR CR","PEARL HARBOR CIR",1)

replace location=subinstr(location,"PINEPOINT DR","PINE POINT DR",1)
replace street=subinstr(street,"PINEPOINT DR","PINE POINT DR",1)

replace location=subinstr(location,"QUERIDA AVE","QUERIDA ST",1)
replace street=subinstr(street,"QUERIDA AVE","QUERIDA ST",1)

replace location=subinstr(location,"RODGERSON CR","ROGERSON CIR",1)
replace street=subinstr(street,"RODGERSON CR","ROGERSON CIR",1)

replace location=subinstr(location,"RONALD CR","RONALD CIR",1)
replace street=subinstr(street,"RONALD CR","RONALD CIR",1)

replace location=subinstr(location,"ROOSTER RIVER BV","ROOSTER RIVER BLVD",1)
replace street=subinstr(street,"ROOSTER RIVER BV","ROOSTER RIVER BLVD",1)

replace location=subinstr(location,"SCOTT AVE","SCOTT ST",1) if street=="SCOTT AVE"&PropertyStreet=="SCOTT ST"
replace street=subinstr(street,"SCOTT AVE","SCOTT ST",1) if street=="SCOTT AVE"&PropertyStreet=="SCOTT ST"

replace location=subinstr(location,"SEAVER CR","SEAVER CIR",1)
replace street=subinstr(street,"SEAVER CR","SEAVER CIR",1)

replace location=subinstr(location,"ST ANDREW ST","SAINT ANDREWS ST",1)
replace street=subinstr(street,"ST ANDREW ST","SAINT ANDREWS ST",1)

replace location=subinstr(location,"ST MATHIAS ST","SAINT MATHIAS ST",1)
replace street=subinstr(street,"ST MATHIAS ST","SAINT MATHIAS ST",1)

replace location=subinstr(location,"ST NICHOLAS DR","SAINT NICHOLAS DR",1)
replace street=subinstr(street,"ST NICHOLAS DR","SAINT NICHOLAS DR",1)

replace location=subinstr(location,"SUNSHINE CR","SUNSHINE CIR",1)
replace street=subinstr(street,"SUNSHINE CR","SUNSHINE CIR",1)

replace location=subinstr(location,"TARINELLI CR","TARINELLI CIR",1)
replace street=subinstr(street,"TARINELLI CR","TARINELLI CIR",1)

replace location=subinstr(location,"TESINY CR","TESINY CIR",1)
replace street=subinstr(street,"TESINY CR","TESINY CIR",1)

replace location=subinstr(location,"TINA CR","TINA CIR",1)
replace street=subinstr(street,"TINA CR","TINA CIR",1)

replace location=subinstr(location,"TULLY CR","TULLY CIR",1)
replace street=subinstr(street,"TULLY CR","TULLY CIR",1)

replace location=subinstr(location,"VALLEY CR","VALLEY CIR",1)
replace street=subinstr(street,"VALLEY CR","VALLEY CIR",1)

replace location=subinstr(location,"VANGARD ST","VANGUARD ST",1)
replace street=subinstr(street,"VANGARD ST","VANGUARD ST",1)

replace location=subinstr(location,"WEST JACKSON AVE","W JACKSON AVE",1)
replace street=subinstr(street,"WEST JACKSON AVE","W JACKSON AVE",1)

replace location=subinstr(location,"WEST MORGAN AVE","W MORGAN AVE",1)
replace street=subinstr(street,"WEST MORGAN AVE","W MORGAN AVE",1)

replace location=subinstr(location,"WEST PK","WEST PKWY",1)
replace street=subinstr(street,"WEST PK","WEST PKWY",1)

replace location=subinstr(location,"WEST TAFT AVE","W TAFT AVE",1)
replace street=subinstr(street,"WEST TAFT AVE","W TAFT AVE",1)

replace location=subinstr(location,"WICKLIFFE CR","WICKLIFFE CIR",1)
replace street=subinstr(street,"WICKLIFFE CR","WICKLIFFE CIR",1)

replace location=subinstr(location,"WILLIAMSBURG DR","WILLIAMSBURG RD",1)
replace street=subinstr(street,"WILLIAMSBURG DR","WILLIAMSBURG RD",1)

replace location=subinstr(location,"WOODBINE CR","WOODBINE CIR",1)
replace street=subinstr(street,"WOODBINE CR","WOODBINE CIR",1)

replace location=subinstr(location,"WOODLAWN AVE","WOODLAWN AVENUE EXT",1) if street=="WOODLAWN AVE"&PropertyStreet=="WOODLAWN AVENUE EXT"
replace street=subinstr(street,"WOODLAWN AVE","WOODLAWN AVENUE EXT",1) if street=="WOODLAWN AVE"&PropertyStreet=="WOODLAWN AVENUE EXT"

replace location=subinstr(location,"WOODLAWN EXT AVE","WOODLAWN AVENUE EXT",1)
replace street=subinstr(street,"WOODLAWN EXT AVE","WOODLAWN AVENUE EXT",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_bridgeport.dta",replace

*******New London********
use "$GIS\propbrev_wffix_newlondon.dta",clear
ren siteaddres location
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen street=substr(location,firstblank1+1,.)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""
replace street=trim(street)
replace PropertyStreet=trim(PropertyStreet)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

replace location=subinstr(location," ROAD"," RD",1)
replace street=subinstr(street," ROAD"," RD",1)

replace location=subinstr(location," AVENUE"," AVE",1)
replace street=subinstr(street," AVENUE"," AVE",1)

replace location=subinstr(location," STREET"," ST",1)
replace street=subinstr(street," STREET"," ST",1)

replace location=subinstr(location,"SOUTH PINE","S PINE",1)
replace street=subinstr(street,"SOUTH PINE","S PINE",1)

replace location=subinstr(location," DRIVE"," DR",1)
replace street=subinstr(street," DRIVE"," DR",1)

replace location=subinstr(location," POINT"," PT",1)
replace street=subinstr(street," POINT"," PT",1)

replace location=subinstr(location," LANE"," LN",1)
replace street=subinstr(street," LANE"," LN",1)

replace location=subinstr(location," PLACE"," PL",1)
replace street=subinstr(street," PLACE"," PL",1)

replace location=subinstr(location,"SOUTH GATE","S GATE",1)
replace street=subinstr(street,"SOUTH GATE","S GATE",1)

replace location=subinstr(location," TERRACE"," TER",1)
replace street=subinstr(street," TERRACE"," TER",1)

replace location=subinstr(location," CIRCLE"," CIR",1)
replace street=subinstr(street," CIRCLE"," CIR",1)

replace location=subinstr(location," BOULEVARD"," BLVD",1)
replace street=subinstr(street," BOULEVARD"," BLVD",1)

replace location=subinstr(location," COURT"," CT",1)
replace street=subinstr(street," COURT"," CT",1)

replace location=subinstr(location,"EAST PAULDING ST","E PAULDING ST",1)
replace street=subinstr(street,"EAST PAULDING ST","E PAULDING ST",1)

replace location=subinstr(location,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)
replace street=subinstr(street,"SUNNIE HOLME DR","SUNNIEHOLME DR",1)

replace location=subinstr(location,"SOUTH BENSON","S BENSON",1)
replace street=subinstr(street,"SOUTH BENSON","S BENSON",1)

replace location=subinstr(location,"KINGS HIGHWAY","KINGS HWY",1)
replace street=subinstr(street,"KINGS HIGHWAY","KINGS HWY",1)

replace location=subinstr(location,"FIFTH AVE","5TH AVE",1)
replace street=subinstr(street,"FIFTH AVE","5TH AVE",1)

replace location=subinstr(location," TRAIL"," TRL",1)
replace street=subinstr(street," TRAIL"," TRL",1)

replace location=subinstr(location," VISTA"," VIS",1)
replace street=subinstr(street," VISTA"," VIS",1)

*New London East Lyme specific
replace location=subinstr(location,"ALEWIFE PW","ALEWIFE PKWY",1)
replace street=subinstr(street,"ALEWIFE PW","ALEWIFE PKWY",1)

replace location=subinstr(location,"ARCADIAN RD GNB","ARCADIA RD",1)
replace street=subinstr(street,"ARCADIAN RD GNB","ARCADIA RD",1)

replace location=subinstr(location,"ATLANTIC ST CB","ATLANTIC ST",1)
replace street=subinstr(street,"ATLANTIC ST CB","ATLANTIC ST",1)

replace location=subinstr(location,"ATTAWAN AVE","ATTAWAN RD",1)
replace street=subinstr(street,"ATTAWAN AVE","ATTAWAN RD",1)

replace location=subinstr(location,"BARRETT DR OGBA","BARRETT DR",1)
replace street=subinstr(street,"BARRETT DR OGBA","BARRETT DR",1)

replace location=subinstr(location,"BAY VIEW RD GNH","BAYVIEW RD",1)
replace street=subinstr(street,"BAY VIEW RD GNH","BAYVIEW RD",1)

replace location=subinstr(location,"BAYVIEW AVE CB","BAYVIEW AVE",1)
replace street=subinstr(street,"BAYVIEW AVE CB","BAYVIEW AVE",1)

replace location=subinstr(location,"BEACH AVE CB","BEACH AVE",1)
replace street=subinstr(street,"BEACH AVE CB","BEACH AVE",1)

replace location=subinstr(location,"BELLAIRE RD BPBC","BELLAIRE RD",1)
replace street=subinstr(street,"BELLAIRE RD BPBC","BELLAIRE RD",1)

replace location=subinstr(location,"BILLOW RD BPBC","BILLOW RD",1)
replace street=subinstr(street,"BILLOW RD BPBC","BILLOW RD",1)

replace location=subinstr(location,"BLACK PT RD","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD","BLACK POINT RD",1)

replace location=subinstr(location,"BLACK PT RD CB","BLACK POINT RD",1)
replace street=subinstr(street,"BLACK PT RD CB","BLACK POINT RD",1)

replace location=subinstr(location,"BOND ST BPBC","BOND ST",1)
replace street=subinstr(street,"BOND ST BPBC","BOND ST",1)

replace location=subinstr(location,"BRAINERD RD","BRAINARD RD",1)
replace street=subinstr(street,"BRAINERD RD","BRAINARD RD",1)

replace location=subinstr(location,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)
replace street=subinstr(street,"BRIGHTWATER RD BPBC","BRIGHTWATER RD",1)

replace location=subinstr(location,"BROCKETT RD GNB","BROCKETT RD",1)
replace street=subinstr(street,"BROCKETT RD GNB","BROCKETT RD",1)

replace location=subinstr(location,"CARPENTER AVE CB","CARPENTER AVE",1)
replace street=subinstr(street,"CARPENTER AVE CB","CARPENTER AVE",1)

replace location=subinstr(location,"CENTRAL AVE CB","CENTRAL AVE",1)
replace street=subinstr(street,"CENTRAL AVE CB","CENTRAL AVE",1)

replace location=subinstr(location,"COLUMBUS AVE CB","COLUMBUS AVE",1)
replace street=subinstr(street,"COLUMBUS AVE CB","COLUMBUS AVE",1)

replace location=subinstr(location,"COTTAGE LN BPBC","COTTAGE LN",1)
replace street=subinstr(street,"COTTAGE LN BPBC","COTTAGE LN",1)

replace location=subinstr(location,"CRAB LN CB","CRAB LN",1)
replace street=subinstr(street,"CRAB LN CB","CRAB LN",1)

replace location=subinstr(location,"CRESCENT AVE CB","CRESCENT AVE",1)
replace street=subinstr(street,"CRESCENT AVE CB","CRESCENT AVE",1)

replace location=subinstr(location,"E SHORE DR BPBC","E SHORE DR",1)
replace street=subinstr(street,"E SHORE DR BPBC","E SHORE DR",1)

replace location=subinstr(location,"EDGE HILL RD GNH","EDGE HILL RD",1)
replace street=subinstr(street,"EDGE HILL RD GNH","EDGE HILL RD",1)

replace location=subinstr(location,"FULLER CT CB","FULLER CT",1)
replace street=subinstr(street,"FULLER CT CB","FULLER CT",1)

replace location=subinstr(location,"GLENWOOD PARK NO","GLENWOOD PARK N",1)
replace street=subinstr(street,"GLENWOOD PARK NO","GLENWOOD PARK N",1)

replace location=subinstr(location,"GLENWOOD PARK SO","GLENWOOD PARK S",1)
replace street=subinstr(street,"GLENWOOD PARK SO","GLENWOOD PARK S",1)

replace location=subinstr(location,"GRISWOLD DR GNH","GRISWOLD DR",1)
replace street=subinstr(street,"GRISWOLD DR GNH","GRISWOLD DR",1)

replace location=subinstr(location,"GRISWOLD RD GNB","GRISWOLD RD",1)
replace street=subinstr(street,"GRISWOLD RD GNB","GRISWOLD RD",1)

replace location=subinstr(location,"GROVE AVE CB","GROVE AVE",1)
replace street=subinstr(street,"GROVE AVE CB","GROVE AVE",1)

replace location=subinstr(location,"GROVEDALE RD GNB","GROVEDALE RD",1)
replace street=subinstr(street,"GROVEDALE RD GNB","GROVEDALE RD",1)

replace location=subinstr(location,"HILLCREST RD GNH","HILLCREST RD",1)
replace street=subinstr(street,"HILLCREST RD GNH","HILLCREST RD",1)

replace location=subinstr(location,"HILLSIDE AVE CB","HILLSIDE AVE",1)
replace street=subinstr(street,"HILLSIDE AVE CB","HILLSIDE AVE",1)

replace location=subinstr(location,"HILLTOP RD GNB","HILLTOP RD",1)
replace street=subinstr(street,"HILLTOP RD GNB","HILLTOP RD",1)

replace location=subinstr(location,"HOPE ST (REAR)","HOPE ST",1)
replace street=subinstr(street,"HOPE ST (REAR)","HOPE ST",1)

replace location=subinstr(location,"INDIAN ROCKS RD","INDIAN ROCK RD",1)
replace street=subinstr(street,"INDIAN ROCKS RD","INDIAN ROCK RD",1)

replace location=subinstr(location,"INDIANOLA RD BPBC","INDIANOLA RD",1)
replace street=subinstr(street,"INDIANOLA RD BPBC","INDIANOLA RD",1)

replace location=subinstr(location,"IRVING PL CB","IRVING PL",1)
replace street=subinstr(street,"IRVING PL CB","IRVING PL",1)

replace location=subinstr(location,"JO-ANNE ST","JO ANNE ST",1)
replace street=subinstr(street,"JO-ANNE ST","JO ANNE ST",1)

replace location=subinstr(location,"LAKE AVE EXT","LAKE AVENUE EXT",1)
replace street=subinstr(street,"LAKE AVE EXT","LAKE AVENUE EXT",1)

replace location=subinstr(location,"LAKE SHORE DR GNB","LAKE SHORE DR",1)
replace street=subinstr(street,"LAKE SHORE DR GNB","LAKE SHORE DR",1)

replace location=subinstr(location,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)
replace street=subinstr(street,"LAKEVIEW HGTS RD","LAKE VIEW HTS",1)

replace location=subinstr(location,"LEE FARM DR GNH","LEE FARM DR",1)
replace street=subinstr(street,"LEE FARM DR GNH","LEE FARM DR",1)

replace location=subinstr(location,"MAMACOCK RD GNB","MAMACOCK RD",1)
replace street=subinstr(street,"MAMACOCK RD GNB","MAMACOCK RD",1)

replace location=subinstr(location,"MANWARING RD OGBA","MANWARING RD",1)
replace street=subinstr(street,"MANWARING RD OGBA","MANWARING RD",1)

replace location=subinstr(location,"MARSHFIELD RD GNH","MARSHFIELD RD",1)
replace street=subinstr(street,"MARSHFIELD RD GNH","MARSHFIELD RD",1)

replace location=subinstr(location,"NEHANTIC DR BPBC","NEHANTIC DR",1)
replace street=subinstr(street,"NEHANTIC DR BPBC","NEHANTIC DR",1)

replace location=subinstr(location,"NILES CREEK RD GNB","NILES CREEK RD",1)
replace street=subinstr(street,"NILES CREEK RD GNB","NILES CREEK RD",1)

replace location=subinstr(location,"NORTH AVE CB","NORTH AVE",1)
replace street=subinstr(street,"NORTH AVE CB","NORTH AVE",1)

replace location=subinstr(location,"NORTH DR OGBA","NORTH DR",1)
replace street=subinstr(street,"NORTH DR OGBA","NORTH DR",1)

replace location=subinstr(location,"OAKWOOD RD GNH","OAKWOOD RD",1)
replace street=subinstr(street,"OAKWOOD RD GNH","OAKWOOD RD",1)

replace location=subinstr(location,"OCEAN AVE CB","OCEAN AVE",1)
replace street=subinstr(street,"OCEAN AVE CB","OCEAN AVE",1)

replace location=subinstr(location,"OLD BLACK PT RD","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)
replace street=subinstr(street,"OLD BLACK PT RD (REAR)","OLD BLACK POINT RD",1)

replace location=subinstr(location,"OSPREY LN GNH","OSPREY LN",1)
replace street=subinstr(street,"OSPREY LN GNH","OSPREY LN",1)

replace location=subinstr(location,"OSPREY RD BPBC","OSPREY RD",1)
replace street=subinstr(street,"OSPREY RD BPBC","OSPREY RD",1)

replace location=subinstr(location,"PALLETTE AVE BPBC","PALLETTE DR",1)
replace street=subinstr(street,"PALLETTE AVE BPBC","PALLETTE DR",1)

replace location=subinstr(location,"PARK CT BPBC","PARK CT",1)
replace street=subinstr(street,"PARK CT BPBC","PARK CT",1)

replace location=subinstr(location,"PARK LN GNH","PARK LN",1)
replace street=subinstr(street,"PARK LN GNH","PARK LN",1)

replace location=subinstr(location,"PARK VIEW DR GNH","PARKVIEW DR",1)
replace street=subinstr(street,"PARK VIEW DR GNH","PARKVIEW DR",1)

replace location=subinstr(location,"PARKWAY NORTH","PARKWAY N",1)
replace street=subinstr(street,"PARKWAY NORTH","PARKWAY N",1)

replace location=subinstr(location,"PARKWAY SOUTH","PARKWAY S",1)
replace street=subinstr(street,"PARKWAY SOUTH","PARKWAY S",1)

replace location=subinstr(location,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)
replace street=subinstr(street,"PLEASANT DR EXT","PLEASANT DRIVE EXT",1)

replace location=subinstr(location,"POINT RD GNB","POINT RD",1)
replace street=subinstr(street,"POINT RD GNB","POINT RD",1)

replace location=subinstr(location,"PROSPECT AVE CB","PROSPECT AVE",1)
replace street=subinstr(street,"PROSPECT AVE CB","PROSPECT AVE",1)

replace location=subinstr(location,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)
replace street=subinstr(street,"QUINNIPEAG AVE","QUINNEPEAG AVE",1)

replace location=subinstr(location,"RIDGE TR BPBC","RIDGE TRL",1)
replace street=subinstr(street,"RIDGE TR BPBC","RIDGE TRL",1)

replace location=subinstr(location,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)
replace street=subinstr(street,"RIDGEWOOD RD GNB","RIDGEWOOD RD",1)

replace location=subinstr(location,"ROCKBOURNE AVE","ROCKBOURNE LN",1)
replace street=subinstr(street,"ROCKBOURNE AVE","ROCKBOURNE LN",1)

replace location=subinstr(location,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)
replace street=subinstr(street,"S BEECHWOOD RD GNH","S BEECHWOOD RD",1)

replace location=subinstr(location,"S LEE RD GNB","S LEE RD",1)
replace street=subinstr(street,"S LEE RD GNB","S LEE RD",1)

replace location=subinstr(location,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)
replace street=subinstr(street,"S WASHINGTON AVE CB","S WASHINGTON AVE",1)

replace location=subinstr(location,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)
replace street=subinstr(street,"SALTAIRE AVE BPBC","SALTAIRE AVE",1)

replace location=subinstr(location,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)
replace street=subinstr(street,"SEA BREEZE AVE BPBC","SEA BREEZE AVE",1)

replace location=subinstr(location,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)
replace street=subinstr(street,"SEA VIEW AVE BPBC","SEA VIEW AVE",1)

replace location=subinstr(location,"SEA VIEW LN GNH","SEA VIEW LN",1)
replace street=subinstr(street,"SEA VIEW LN GNH","SEA VIEW LN",1)

replace location=subinstr(location,"SHERMAN CT CB","SHERMAN CT",1)
replace street=subinstr(street,"SHERMAN CT CB","SHERMAN CT",1)

replace location=subinstr(location,"SHORE RD OGBA","SHORE RD",1)
replace street=subinstr(street,"SHORE RD OGBA","SHORE RD",1)

replace location=subinstr(location,"SOUTH DR OGBA","SOUTH DR",1)
replace street=subinstr(street,"SOUTH DR OGBA","SOUTH DR",1)

replace location=subinstr(location,"SOUTH TR","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR","SOUTH TRL",1)

replace location=subinstr(location,"SOUTH TR BPBC","SOUTH TRL",1)
replace street=subinstr(street,"SOUTH TR BPBC","SOUTH TRL",1)

replace location=subinstr(location,"SPENCER AVE CB","SPENCER AVE",1)
replace street=subinstr(street,"SPENCER AVE CB","SPENCER AVE",1)

replace location=subinstr(location,"SPRING GLEN RD GNH","SPRING GLEN RD",1)
replace street=subinstr(street,"SPRING GLEN RD GNH","SPRING GLEN RD",1)

replace location=subinstr(location,"SUNRISE AVE BPBC","SUNRISE AVE",1)
replace street=subinstr(street,"SUNRISE AVE BPBC","SUNRISE AVE",1)

replace location=subinstr(location,"SUNSET AVE BPBC","SUNSET AVE",1)
replace street=subinstr(street,"SUNSET AVE BPBC","SUNSET AVE",1)

replace location=subinstr(location,"TABERNACLE AVE CB","TABERNACLE AVE",1)
replace street=subinstr(street,"TABERNACLE AVE CB","TABERNACLE AVE",1)

replace location=subinstr(location,"TERRACE AVE CB","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE CB","TERRACE AVE",1)

replace location=subinstr(location,"TERRACE AVE OGBA","TERRACE AVE",1)
replace street=subinstr(street,"TERRACE AVE OGBA","TERRACE AVE",1)

replace location=subinstr(location,"UNCAS RD BPBC","UNCAS RD",1)
replace street=subinstr(street,"UNCAS RD BPBC","UNCAS RD",1)

replace location=subinstr(location,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)
replace street=subinstr(street,"W PATTAGANSETT RD GNB","W PATTAGANSETT RD",1)

replace location=subinstr(location,"WATERSIDE AVE BPBC","WATERSIDE RD",1)
replace street=subinstr(street,"WATERSIDE AVE BPBC","WATERSIDE RD",1)

replace location=subinstr(location,"WEST END AVE","W END AVE",1)
replace street=subinstr(street,"WEST END AVE","W END AVE",1)

replace location=subinstr(location,"WESTOMERE TR","WESTOMERE TER",1)
replace street=subinstr(street,"WESTOMERE TR","WESTOMERE TER",1)

replace location=subinstr(location,"WHITECAP RD BPBC","WHITECAP RD",1)
replace street=subinstr(street,"WHITECAP RD BPBC","WHITECAP RD",1)

replace location=subinstr(location,"WHITTLESEY PL","WHITTLESAY PL",1)
replace street=subinstr(street,"WHITTLESEY PL","WHITTLESAY PL",1)

replace location=subinstr(location,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)
replace street=subinstr(street,"WOODBRIDGE RD GNH","WOODBRIDGE RD",1)

replace location=subinstr(location,"WOODLAND DR BPBC","WOODLAND DR",1)
replace street=subinstr(street,"WOODLAND DR BPBC","WOODLAND DR",1)

replace location=subinstr(location,"DAVIS FARM WAY","DAVIS FARMS WAY",1)
replace street=subinstr(street,"DAVIS FARM WAY","DAVIS FARMS WAY",1)

replace location=subinstr(location,"FAIRE HARBOUR PL","FAIR HARBOUR PL",1)
replace street=subinstr(street,"FAIRE HARBOUR PL","FAIR HARBOUR PL",1)

replace location=subinstr(location,"FIRST AVE","1ST AVE",1)
replace street=subinstr(street,"FIRST AVE","1ST AVE",1)

replace location=subinstr(location,"FOURTH AVE","4TH AVE",1)
replace street=subinstr(street,"FOURTH AVE","4TH AVE",1)

replace location=subinstr(location,"GREENES ALLEY","GREENS ALY",1)
replace street=subinstr(street,"GREENES ALLEY","GREENS ALY",1)

replace location=subinstr(location,"RAYMOND ST EXT","RAYMOND STREET EXT",1)
replace street=subinstr(street,"RAYMOND ST EXT","RAYMOND STREET EXT",1)

replace location=subinstr(location,"SIXTH AVE","6TH AVE",1)
replace street=subinstr(street,"SIXTH AVE","6TH AVE",1)

replace location=subinstr(location,"SOUTH LEDYARD ST","S LEDYARD ST",1)
replace street=subinstr(street,"SOUTH LEDYARD ST","S LEDYARD ST",1)

replace location=subinstr(location,"WEST COIT ST","W COIT ST",1)
replace street=subinstr(street,"WEST COIT ST","W COIT ST",1)

replace location=subinstr(location,"WEST HIGH ST","W HIGH ST",1)
replace street=subinstr(street,"WEST HIGH ST","W HIGH ST",1)

replace location=subinstr(location,"WEST PLEASANT ST","W PLEASANT ST",1)
replace street=subinstr(street,"WEST PLEASANT ST","W PLEASANT ST",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_newlondon.dta",replace

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

gen firsthash=ustrpos(street,"#",1)
replace street=substr(street,1,firsthash-2) if firsthash>=1
replace street=trim(street)

replace firsthash=ustrpos(location,"#",1)
replace location=substr(location,1,firsthash-2) if firsthash>=1
replace location=trim(location)

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Norwalk Specific
replace location=subinstr(location,"ACACIA ST","ACACIA DR",1)
replace street=subinstr(street,"ACACIA ST","ACACIA DR",1)

replace location=subinstr(location,"BROWNE PL","BROWN PL",1)
replace street=subinstr(street,"BROWNE PL","BROWN PL",1)

replace location=subinstr(location,"CAPTAINS WALK RD","CAPTAINS WALK",1)
replace street=subinstr(street,"CAPTAINS WALK RD","CAPTAINS WALK",1)

replace location=subinstr(location,"CIRCLE ST","CIRCLE RD",1)
replace street=subinstr(street,"CIRCLE ST","CIRCLE RD",1)

replace location=subinstr(location,"COVLEE DR","COVELEE DR",1)
replace street=subinstr(street,"COVLEE DR","COVELEE DR",1)

replace location=subinstr(location,"EAST BEACH DR","E BEACH DR",1)
replace street=subinstr(street,"EAST BEACH DR","E BEACH DR",1)

replace location=subinstr(location,"FIFTH ST","5TH ST",1)
replace street=subinstr(street,"FIFTH ST","5TH ST",1)

replace location=subinstr(location,"FIRST ST","1ST ST",1)
replace street=subinstr(street,"FIRST ST","1ST ST",1)

replace location=subinstr(location,"FOURTH ST","4TH ST",1)
replace street=subinstr(street,"FOURTH ST","4TH ST",1)

replace location=subinstr(location,"HILLSIDE ST","HILLSIDE PL",1)
replace street=subinstr(street,"HILLSIDE ST","HILLSIDE PL",1)

replace location=subinstr(location,"JO'S BARN WY","JO S BARN WAY",1)
replace street=subinstr(street,"JO'S BARN WY","JO S BARN WAY",1)

replace location=subinstr(location,"LITTLE WY","LITTLE WAY",1)
replace street=subinstr(street,"LITTLE WY","LITTLE WAY",1)

replace location=subinstr(location,"NAPLES AVE","NAPLES ST",1)
replace street=subinstr(street,"NAPLES AVE","NAPLES ST",1)

replace location=subinstr(location,"OLD TROLLEY WY","OLD TROLLEY WAY",1)
replace street=subinstr(street,"OLD TROLLEY WY","OLD TROLLEY WAY",1)

replace location=subinstr(location,"PHILLENE RD","PHILLENE DR",1)
replace street=subinstr(street,"PHILLENE RD","PHILLENE DR",1)

replace location=subinstr(location,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)
replace street=subinstr(street,"PINE HILL AVE EXT","PINE HILL AVENUE EXT",1)

replace location=subinstr(location,"POND RIDGE RD","POND RIDGE LN",1)
replace street=subinstr(street,"POND RIDGE RD","POND RIDGE LN",1)

replace location=subinstr(location,"ROBINS SQ EAST","ROBINS SQ E",1)
replace street=subinstr(street,"ROBINS SQ EAST","ROBINS SQ E",1)

replace location=subinstr(location,"ROBINS SQ SOUTH","ROBINS SQ S",1)
replace street=subinstr(street,"ROBINS SQ SOUTH","ROBINS SQ S",1)

replace location=subinstr(location,"SECOND ST","2ND ST",1)
replace street=subinstr(street,"SECOND ST","2ND ST",1)

replace location=subinstr(location,"SELDON ST","SELDON PL",1)
replace street=subinstr(street,"SELDON ST","SELDON PL",1)

replace location=subinstr(location,"SHOREFRONT PK","SHOREFRONT PARK",1)
replace street=subinstr(street,"SHOREFRONT PK","SHOREFRONT PARK",1)

replace location=subinstr(location,"SOUTH BEACH DR","S BEACH DR",1)
replace street=subinstr(street,"SOUTH BEACH DR","S BEACH DR",1)

replace location=subinstr(location,"SOUTH MAIN ST","S MAIN ST",1)
replace street=subinstr(street,"SOUTH MAIN ST","S MAIN ST",1)

replace location=subinstr(location,"SOUTH SMITH ST","S SMITH ST",1)
replace street=subinstr(street,"SOUTH SMITH ST","S SMITH ST",1)

replace location=subinstr(location,"ST JAMES PL","SAINT JAMES PL",1)
replace street=subinstr(street,"ST JAMES PL","SAINT JAMES PL",1)

replace location=subinstr(location,"ST. JOHN ST","SAINT JOHN ST",1)
replace street=subinstr(street,"ST. JOHN ST","SAINT JOHN ST",1)

replace location=subinstr(location,"STEEPLETOP RD","STEEPLE TOP RD",1)
replace street=subinstr(street,"STEEPLETOP RD","STEEPLE TOP RD",1)

replace location=subinstr(location,"THIRD ST","3RD ST",1)
replace street=subinstr(street,"THIRD ST","3RD ST",1)

replace location=subinstr(location,"TONETTA CR","TONETTA CIR",1)
replace street=subinstr(street,"TONETTA CR","TONETTA CIR",1)

replace location=subinstr(location,"TOPSAIL RD","TOP SAIL RD",1)
replace street=subinstr(street,"TOPSAIL RD","TOP SAIL RD",1)

replace location=subinstr(location,"WEST MEADOW PL","W MEADOW PL",1)
replace street=subinstr(street,"WEST MEADOW PL","W MEADOW PL",1)

replace location=subinstr(location,"1 PLATT ST","PLATT ST",1)
replace street=subinstr(street,"1 PLATT ST","PLATT ST",1)

replace location=subinstr(location,"1/2 BENEDICT ST","BENEDICT ST",1)
replace street=subinstr(street,"1/2 BENEDICT ST","BENEDICT ST",1)

replace location=subinstr(location,"1/2 BETTSWOOD RD","BETTSWOOD RD",1)
replace street=subinstr(street,"1/2 BETTSWOOD RD","BETTSWOOD RD",1)

replace location=subinstr(location,"1/2 CHESTNUT HILL RD","CHESTNUT HILL RD",1)
replace street=subinstr(street,"1/2 CHESTNUT HILL RD","CHESTNUT HILL RD",1)

replace location=subinstr(location,"1/2 EAST ROCKS RD","1/2 E ROCKS RD",1)
replace street=subinstr(street,"1/2 EAST ROCKS RD","1/2 E ROCKS RD",1)

replace location=subinstr(location,"1/2 KEELER AVE","KEELER AVE",1)
replace street=subinstr(street,"1/2 KEELER AVE","KEELER AVE",1)

replace location=subinstr(location,"1/2 NORTH BRIDGE ST","1/2 N BRIDGE ST",1)
replace street=subinstr(street,"1/2 NORTH BRIDGE ST","1/2 N BRIDGE ST",1)

replace location=subinstr(location,"1/2 NORTH SEIR HILL RD","1/2 N SEIR HILL RD",1)
replace street=subinstr(street,"1/2 NORTH SEIR HILL RD","1/2 N SEIR HILL RD",1)

replace location=subinstr(location,"1/2 SCRIBNER AVE","SCRIBNER AVE",1)
replace street=subinstr(street,"1/2 SCRIBNER AVE","SCRIBNER AVE",1)

replace location=subinstr(location,"1/2 STEVENS ST","STEVENS ST",1)
replace street=subinstr(street,"1/2 STEVENS ST","STEVENS ST",1)

replace location=subinstr(location,"1/2 ROXBURY RD","ROXBURY RD",1)
replace street=subinstr(street,"1/2 ROXBURY RD","ROXBURY RD",1)

replace location=subinstr(location,"WEST NORWALK RD","W NORWALK RD",1)
replace street=subinstr(street,"WEST NORWALK RD","W NORWALK RD",1)

replace location=subinstr(location," WEST ROCKS RD"," W ROCKS RD",1)
replace street=subinstr(street," WEST ROCKS RD"," W ROCKS RD",1)

replace location=subinstr(location,"A BLAKE ST","BLAKE ST",1)
replace street=subinstr(street,"A BLAKE ST","BLAKE ST",1)

replace location=subinstr(location,"A FRANCE ST","FRANCE ST",1)
replace street=subinstr(street,"A FRANCE ST","FRANCE ST",1)

replace location=subinstr(location,"A LACEY LN","LACEY LN",1)
replace street=subinstr(street,"A LACEY LN","LACEY LN",1)

replace location=subinstr(location,"A LITTLE FOX LN","LITTLE FOX LN",1)
replace street=subinstr(street,"A LITTLE FOX LN","LITTLE FOX LN",1)

replace location=subinstr(location,"A WILSON AVE","WILSON AVE",1)
replace street=subinstr(street,"A WILSON AVE","WILSON AVE",1)

replace location=subinstr(location," WY"," WAY",1)
replace street=subinstr(street," WY"," WAY",1)

replace location=subinstr(location,"B BETMARLEA RD","BETMARLEA RD",1)
replace street=subinstr(street,"B BETMARLEA RD","BETMARLEA RD",1)

replace location=subinstr(location,"B BLAKE ST","BLAKE ST",1)
replace street=subinstr(street,"B BLAKE ST","BLAKE ST",1)

replace location=subinstr(location,"B FRANCE ST","FRANCE ST",1)
replace street=subinstr(street,"B FRANCE ST","FRANCE ST",1)

replace location=subinstr(location,"B W NORWALK RD","W NORWALK RD",1)
replace street=subinstr(street,"B W NORWALK RD","W NORWALK RD",1)

replace location=subinstr(location,"BISSELL RD","BISSELL LN",1)
replace street=subinstr(street,"BISSELL RD","BISSELL LN",1)

replace location=subinstr(location,"BOXWOOD RD","BOX WOOD RD",1)
replace street=subinstr(street,"BOXWOOD RD","BOX WOOD RD",1)

replace location=subinstr(location,"BRIERWOOD RD","BRIARWOOD RD",1)
replace street=subinstr(street,"BRIERWOOD RD","BRIARWOOD RD",1)

replace location=subinstr(location,"BUMBLE BEE LN","BUMBLEBEE LN",1)
replace street=subinstr(street,"BUMBLE BEE LN","BUMBLEBEE LN",1)

replace location=subinstr(location,"CENTER AVE EXT","CENTER AVENUE EXT",1)
replace street=subinstr(street,"CENTER AVE EXT","CENTER AVENUE EXT",1)

replace location=subinstr(location,"COVELEE DR","COVLEE DR",1)
replace street=subinstr(street,"COVELEE DR","COVLEE DR",1)

replace location=subinstr(location,"EAST MEADOW LN","E MEADOW LN",1)
replace street=subinstr(street,"EAST MEADOW LN","E MEADOW LN",1)

replace location=subinstr(location,"EAST ROCKS RD","E ROCKS RD",1)
replace street=subinstr(street,"EAST ROCKS RD","E ROCKS RD",1)

replace location=subinstr(location,"FAIRVIEW ST","FAIRVIEW PL",1)
replace street=subinstr(street,"FAIRVIEW ST","FAIRVIEW PL",1)

replace location=subinstr(location,"FRESHWATER LANE","FRESHWATER LN",1)
replace street=subinstr(street,"FRESHWATER LANE","FRESHWATER LN",1)

replace location=subinstr(location,"FULLMAR LN","FULMAR LN",1)
replace street=subinstr(street,"FULLMAR LN","FULMAR LN",1)

replace location=subinstr(location,"GREEN HILL RD","GREENHILL RD",1)
replace street=subinstr(street,"GREEN HILL RD","GREENHILL RD",1)

replace location=subinstr(location,"GREY SQUIRREL DR","GRAY SQUIRREL DR",1)
replace street=subinstr(street,"GREY SQUIRREL DR","GRAY SQUIRREL DR",1)

replace location=subinstr(location,"HILLY FIELDS LN","HILLY FIELD LN",1)
replace street=subinstr(street,"HILLY FIELDS LN","HILLY FIELD LN",1)

replace location=subinstr(location,"HOLLOW SPRING ROAD","HOLLOW SPRING RD",1)
replace street=subinstr(street,"HOLLOW SPRING ROAD","HOLLOW SPRING RD",1)

replace location=subinstr(location,"HUCKLEBERRY DR NORTH","HUCKLEBERRY DR N",1)
replace street=subinstr(street,"HUCKLEBERRY DR NORTH","HUCKLEBERRY DR N",1)

replace location=subinstr(location,"HUCKLEBERRY DR SOUTH","HUCKLEBERRY DR S",1)
replace street=subinstr(street,"HUCKLEBERRY DR SOUTH","HUCKLEBERRY DR S",1)

replace location=subinstr(location,"INDIAN HILL ST","INDIAN HILL RD",1)
replace street=subinstr(street,"INDIAN HILL ST","INDIAN HILL RD",1)

replace location=subinstr(location,"JENNIE JENKS ST","JENNY JENKS RD",1)
replace street=subinstr(street,"JENNIE JENKS ST","JENNY JENKS RD",1)

replace location=subinstr(location,"JOEMAR ROAD","JOMAR RD",1)
replace street=subinstr(street,"JOEMAR ROAD","JOMAR RD",1)

replace location=subinstr(location,"KENSETT RIDGE","KENSETT RDG",1)
replace street=subinstr(street,"KENSETT RIDGE","KENSETT RDG",1)

replace location=subinstr(location,"KINGS HIGHWAY SOUTH","KINGS HWY S",1)
replace street=subinstr(street,"KINGS HIGHWAY SOUTH","KINGS HWY S",1)

replace location=subinstr(location,"KNOB HILL RD","KNOBHILL RD",1)
replace street=subinstr(street,"KNOB HILL RD","KNOBHILL RD",1)

replace location=subinstr(location,"LAGANA LANE","LAGANA LN",1)
replace street=subinstr(street,"LAGANA LANE","LAGANA LN",1)

replace location=subinstr(location,"LAKEVIEW DR EAST","LAKEVIEW DR E",1)
replace street=subinstr(street,"LAKEVIEW DR EAST","LAKEVIEW DR E",1)

replace location=subinstr(location,"LOUNSBURY AVE","LOUNDSBURY AVE",1)
replace street=subinstr(street,"LOUNSBURY AVE","LOUNDSBURY AVE",1)

replace location=subinstr(location,"LUFBERRY AVE","LUFBERRY LN",1)
replace street=subinstr(street,"LUFBERRY AVE","LUFBERRY LN",1)

replace location=subinstr(location,"MELBOURNE RD","MELBOURNE RD EXT",1) if street=="MELBOURNE RD"&PropertyStreet=="MELBOURNE RD EXT"
replace street=subinstr(street,"MELBOURNE RD","MELBOURNE RD EXT",1) if street=="MELBOURNE RD"&PropertyStreet=="MELBOURNE RD EXT"

replace location=subinstr(location,"MYRTLE ST EXT","MYRTLE STREET EXT",1)
replace street=subinstr(street,"MYRTLE ST EXT","MYRTLE STREET EXT",1)

replace location=subinstr(location,"NOAH'S LN","NOAHS LN",1)
replace street=subinstr(street,"NOAH'S LN","NOAHS LN",1)

replace location=subinstr(location,"NOAH'S LN EXT","NOAHS LANE EXT",1)
replace street=subinstr(street,"NOAH'S LN EXT","NOAHS LANE EXT",1)

replace location=subinstr(location,"NOAHS LN EXT","NOAHS LANE EXT",1)
replace street=subinstr(street,"NOAHS LN EXT","NOAHS LANE EXT",1)

replace location=subinstr(location,"NOLAN ST","NOLAN STREET EXT",1) if street=="NOLAN ST"&PropertyStreet=="NOLAN STREET EXT"
replace street=subinstr(street,"NOLAN ST","NOLAN STREET EXT",1) if street=="NOLAN ST"&PropertyStreet=="NOLAN STREET EXT"

replace location=subinstr(location,"NORTH BRIDGE ST","N BRIDGE ST",1)
replace street=subinstr(street,"NORTH BRIDGE ST","N BRIDGE ST",1)

replace location=subinstr(location,"NORTH SEIR HILL RD","N SEIR HILL RD",1)
replace street=subinstr(street,"NORTH SEIR HILL RD","N SEIR HILL RD",1)

replace location=subinstr(location,"NORTH TAYLOR AVE","N TAYLOR AVE",1)
replace street=subinstr(street,"NORTH TAYLOR AVE","N TAYLOR AVE",1)

replace location=subinstr(location,"O'BRIEN ST","OBRIEN ST",1)
replace street=subinstr(street,"O'BRIEN ST","OBRIEN ST",1)

replace location=subinstr(location,"O'DONNELL RD","ODONNELL RD",1)
replace street=subinstr(street,"O'DONNELL RD","ODONNELL RD",1)

replace location=subinstr(location,"OAK HILL AVE","OAKHILL AVE",1)
replace street=subinstr(street,"OAK HILL AVE","OAKHILL AVE",1)

replace location=subinstr(location,"OHIO AVE EXT","OHIO AVENUE EXT",1)
replace street=subinstr(street,"OHIO AVE EXT","OHIO AVENUE EXT",1)

replace location=subinstr(location,"PARK HILL AVE","PARKHILL AVE",1)
replace street=subinstr(street,"PARK HILL AVE","PARKHILL AVE",1)

replace location=subinstr(location,"PARTRICK RD","PARTRICK AVE",1) if street=="PARTRICK RD"&PropertyStreet=="PARTRICK AVE"
replace street=subinstr(street,"PARTRICK RD","PARTRICK AVE",1) if street=="PARTRICK RD"&PropertyStreet=="PARTRICK AVE"

replace location=subinstr(location,"PONUS AVE EXT","PONUS AVENUE EXT",1)
replace street=subinstr(street,"PONUS AVE EXT","PONUS AVENUE EXT",1)

replace location=subinstr(location,"PURDY RD EAST","PURDY RD E",1)
replace street=subinstr(street,"PURDY RD EAST","PURDY RD E",1)

replace location=subinstr(location,"SILVERLEDGE RD","SILVER LEDGE RD",1)
replace street=subinstr(street,"SILVERLEDGE RD","SILVER LEDGE RD",1)

replace location=subinstr(location,"SILVERMINE RIDGE","SILVERMINE RDG",1)
replace street=subinstr(street,"SILVERMINE RIDGE","SILVERMINE RDG",1)

replace location=subinstr(location,"SINGINGWOODS CT","SINGING WOODS CT",1)
replace street=subinstr(street,"SINGINGWOODS CT","SINGING WOODS CT",1)

replace location=subinstr(location,"SINGINGWOODS RD","SINGING WOODS RD",1)
replace street=subinstr(street,"SINGINGWOODS RD","SINGING WOODS RD",1)

replace location=subinstr(location,"SLEEPY HOLLOW DR","SLEEPYHOLLOW DR",1)
replace street=subinstr(street,"SLEEPY HOLLOW DR","SLEEPYHOLLOW DR",1)

replace location=subinstr(location,"SOSSE COURT","SOSSE CT",1)
replace street=subinstr(street,"SOSSE COURT","SOSSE CT",1)

replace location=subinstr(location,"ST. JAMES PL","SAINT JAMES PL",1)
replace street=subinstr(street,"ST. JAMES PL","SAINT JAMES PL",1)

replace location=subinstr(location,"ST. MARY'S LN","SAINT MARYS LN",1)
replace street=subinstr(street,"ST. MARY'S LN","SAINT MARYS LN",1)

replace location=subinstr(location,"STONECROP RD NORTH","STONECROP RD",1)
replace street=subinstr(street,"STONECROP RD NORTH","STONECROP RD",1)

replace location=subinstr(location,"STONECROP RD SOUTH","STONECROP RD",1)
replace street=subinstr(street,"STONECROP RD SOUTH","STONECROP RD",1)

replace location=subinstr(location,"STONY BROOK RD","STONYBROOK RD",1)
replace street=subinstr(street,"STONY BROOK RD","STONYBROOK RD",1)

replace location=subinstr(location,"STUDIO LN SOUTH","STUDIO LN S",1)
replace street=subinstr(street,"STUDIO LN SOUTH","STUDIO LN S",1)

replace location=subinstr(location,"SYLVAN ROAD NORTH","SYLVAN RD N",1)
replace street=subinstr(street,"SYLVAN ROAD NORTH","SYLVAN RD N",1)

replace location=subinstr(location,"TOMMY'S LN","TOMMYS LN",1)
replace street=subinstr(street,"TOMMY'S LN","TOMMYS LN",1)

replace location=subinstr(location,"TOPPING LANE","TOPPING LN",1)
replace street=subinstr(street,"TOPPING LANE","TOPPING LN",1)

replace location=subinstr(location,"TRYON AVE","TRYON RD",1)
replace street=subinstr(street,"TRYON AVE","TRYON RD",1)

replace location=subinstr(location,"VALLEY VIEW CT","VALLEY VIEW RD",1)
replace street=subinstr(street,"VALLEY VIEW CT","VALLEY VIEW RD",1)

replace location=subinstr(location,"WEATHER BELL DR","WEATHERBELL DR",1)
replace street=subinstr(street,"WEATHER BELL DR","WEATHERBELL DR",1)

replace location=subinstr(location,"WEST CEDAR ST","W CEDAR ST",1)
replace street=subinstr(street,"WEST CEDAR ST","W CEDAR ST",1)

replace location=subinstr(location,"WEST COUCH ST","W COUCH ST",1)
replace street=subinstr(street,"WEST COUCH ST","W COUCH ST",1)

replace location=subinstr(location,"WEST LAKE CT","W LAKE CT",1)
replace street=subinstr(street,"WEST LAKE CT","W LAKE CT",1)

replace location=subinstr(location,"WEST MAIN ST","W MAIN ST",1)
replace street=subinstr(street,"WEST MAIN ST","W MAIN ST",1)

replace location=subinstr(location,"WEST ROCKS RD","W ROCKS RD",1)
replace street=subinstr(street,"WEST ROCKS RD","W ROCKS RD",1)

replace location=subinstr(location,"WESTEND RD","W END RD",1)
replace street=subinstr(street,"WESTEND RD","W END RD",1)

replace location=subinstr(location,"WESTVIEW LN","W VIEW LN",1)
replace street=subinstr(street,"WESTVIEW LN","W VIEW LN",1)

replace location=subinstr(location,"WHITE OAK SHADE ROAD","WHITE OAK SHADE RD",1)
replace street=subinstr(street,"WHITE OAK SHADE ROAD","WHITE OAK SHADE RD",1)

replace location=subinstr(location,"WILD GOOSE LN","WILDGOOSE LN",1)
replace street=subinstr(street,"WILD GOOSE LN","WILDGOOSE LN",1)

replace location=subinstr(location,"WOOD ACRES RD","WOODACRE RD",1)
replace street=subinstr(street,"WOOD ACRES RD","WOODACRE RD",1)

replace location=subinstr(location,"WOODCHUCK CT WEST","WOODCHUCK CT W",1)
replace street=subinstr(street,"WOODCHUCK CT WEST","WOODCHUCK CT W",1)

replace location=subinstr(location,"WOODS END RD","WOODS END LN",1)
replace street=subinstr(street,"WOODS END RD","WOODS END LN",1)

replace location=subinstr(location,"W VIEW LN","WESTVIEW LN",1)
replace street=subinstr(street,"W VIEW LN","WESTVIEW LN",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_norwalk.dta",replace

*******Madison********
use "$GIS\propbrev_wf_madison.dta",clear
ren propertyfu PropertyFullStreetAddress

gen firstblankpos=ustrpos(PropertyFullStreetAddress," ",2)
gen PropertyStreet=substr(PropertyFullStreetAddress,firstblankpos+1,.)
gen PropertyStreetNum=substr(PropertyFullStreetAddress,1,firstblankpos)

gen firstblank1=ustrpos(location," ",2)
gen addressnum=substr(location,1,firstblankpos)

drop if street==""|addressnum==""

browse if PropertyStreet!=street
order street PropertyStreet
sort street

*Madison Specific
replace location=subinstr(location,"DEER RUN","DEER RUN RD",1)
replace street=subinstr(street,"DEER RUN","DEER RUN RD",1)

replace location=subinstr(location,"EAST WHARF RD","E WHARF RD",1)
replace street=subinstr(street,"EAST WHARF RD","E WHARF RD",1)

replace location=subinstr(location,"LANTERN HILL RD","LANTERN HL",1)
replace street=subinstr(street,"LANTERN HILL RD","LANTERN HL",1)

replace location=subinstr(location,"MEETINGHOUSE LN","MEETING HOUSE LN",1)
replace street=subinstr(street,"MEETINGHOUSE LN","MEETING HOUSE LN",1)

replace location=subinstr(location,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)
replace street=subinstr(street,"MIDDLE BEACH RD WEST","MIDDLE BEACH RD W",1)

replace location=subinstr(location,"OVERSHORES DR EAST","OVERSHORES E",1)
replace street=subinstr(street,"OVERSHORES DR EAST","OVERSHORES E",1)

replace location=subinstr(location,"OVERSHORES DR WEST","OVERSHORES W",1)
replace street=subinstr(street,"OVERSHORES DR WEST","OVERSHORES W",1)

replace location=subinstr(location,"PENT RD #5","PENT RD",1)
replace street=subinstr(street,"PENT RD #5","PENT RD",1)

replace location=subinstr(location,"STERLING PARK DR","STERLING PARK",1)
replace street=subinstr(street,"STERLING PARK DR","STERLING PARK",1)

replace location=subinstr(location,"WEST WHARF RD","W WHARF RD",1)
replace street=subinstr(street,"WEST WHARF RD","W WHARF RD",1)

replace location=subinstr(location,"AMBER TR","AMBER TRL",1)
replace street=subinstr(street,"AMBER TR","AMBER TRL",1)

replace location=subinstr(location,"BEECH WOODS DR","BEECHWOOD DR",1)
replace street=subinstr(street,"BEECH WOODS DR","BEECHWOOD DR",1)

replace location=subinstr(location,"CARMEL COURT","CARMEL CT",1)
replace street=subinstr(street,"CARMEL COURT","CARMEL CT",1)

replace location=subinstr(location,"CEDAR CROFT DR","CEDARCROFT DR",1)
replace street=subinstr(street,"CEDAR CROFT DR","CEDARCROFT DR",1)

replace location=subinstr(location,"COPSE HILL TR","COPSE HILL TRL",1)
replace street=subinstr(street,"COPSE HILL TR","COPSE HILL TRL",1)

replace location=subinstr(location,"DEERFIELD LN","DEER FIELD LN",1)
replace street=subinstr(street,"DEERFIELD LN","DEER FIELD LN",1)

replace location=subinstr(location,"EAGLE MEADOW DR","EAGLE MEADOW RD",1)
replace street=subinstr(street,"EAGLE MEADOW DR","EAGLE MEADOW RD",1)

replace location=subinstr(location,"EASTWOOD RD","EASTWOOD DR",1)
replace street=subinstr(street,"EASTWOOD RD","EASTWOOD DR",1)

replace location=subinstr(location,"FIVE FIELD RD","FIVE FIELDS RD",1)
replace street=subinstr(street,"FIVE FIELD RD","FIVE FIELDS RD",1)

replace location=subinstr(location,"HORSEPOND RD","HORSE POND RD",1)
replace street=subinstr(street,"HORSEPOND RD","HORSE POND RD",1)

replace location=subinstr(location,"HUNTERS TR","HUNTERS TRL",1)
replace street=subinstr(street,"HUNTERS TR","HUNTERS TRL",1)

replace location=subinstr(location,"INDIAN TR","INDIAN TRL",1)
replace street=subinstr(street,"INDIAN TR","INDIAN TRL",1)

replace location=subinstr(location,"INDIGO TR","INDIGO TRL",1)
replace street=subinstr(street,"INDIGO TR","INDIGO TRL",1)

replace location=subinstr(location,"JONATHANS LANDING","JONATHANS LNDG",1)
replace street=subinstr(street,"JONATHANS LANDING","JONATHANS LNDG",1)

replace location=subinstr(location,"JOSHUA TR","JOSHUA TRL",1)
replace street=subinstr(street,"JOSHUA TR","JOSHUA TRL",1)

replace location=subinstr(location,"MATTEO COURT","MATTEO CT",1)
replace street=subinstr(street,"MATTEO COURT","MATTEO CT",1)

replace location=subinstr(location,"MATTHEW COURT","MATTHEW CT",1)
replace street=subinstr(street,"MATTHEW COURT","MATTHEW CT",1)

replace location=subinstr(location,"OLD FARM RD","OLD FARMS RD",1)
replace street=subinstr(street,"OLD FARM RD","OLD FARMS RD",1)

replace location=subinstr(location,"OLD ROUTE 79","OLD 79",1)
replace street=subinstr(street,"OLD ROUTE 79","OLD 79",1)

replace location=subinstr(location,"OLD SCHOOL HOUSE RD","OLD SCHOOLHOUSE RD",1)
replace street=subinstr(street,"OLD SCHOOL HOUSE RD","OLD SCHOOLHOUSE RD",1)

replace location=subinstr(location,"PEPPERWOOD COURT","PEPPERWOOD CT",1)
replace street=subinstr(street,"PEPPERWOOD COURT","PEPPERWOOD CT",1)

replace location=subinstr(location,"SANDELWOOD DR","SANDLEWOOD DR",1)
replace street=subinstr(street,"SANDELWOOD DR","SANDLEWOOD DR",1)

replace location=subinstr(location,"SHEPHERDS TR","SHEPHERDS TRL",1)
replace street=subinstr(street,"SHEPHERDS TR","SHEPHERDS TRL",1)

replace location=subinstr(location,"SILO HILL","SILO HL",1)
replace street=subinstr(street,"SILO HILL","SILO HL",1)

replace location=subinstr(location,"SPORTSMANS HILL RD","SPORTSMAN HILL RD",1)
replace street=subinstr(street,"SPORTSMANS HILL RD","SPORTSMAN HILL RD",1)

replace location=subinstr(location,"ST FRANCIS WOODS RD","SAINT FRANCIS WOODS RD",1)
replace street=subinstr(street,"ST FRANCIS WOODS RD","SAINT FRANCIS WOODS RD",1)

replace location=subinstr(location,"ST JAMES COURT","SAINT JAMES CT",1)
replace street=subinstr(street,"ST JAMES COURT","SAINT JAMES CT",1)

replace location=subinstr(location,"STANTON COURT","STANTON CT",1)
replace street=subinstr(street,"STANTON COURT","STANTON CT",1)

replace location=subinstr(location,"STEPHANIE COURT","STEPHANIE CT",1)
replace street=subinstr(street,"STEPHANIE COURT","STEPHANIE CT",1)

replace location=subinstr(location,"STEPPINGSTONE LN","STEPPING STONE LN",1)
replace street=subinstr(street,"STEPPINGSTONE LN","STEPPING STONE LN",1)

replace location=subinstr(location,"WHITE OAK LN","WHITE OAKS LN",1)
replace street=subinstr(street,"WHITE OAK LN","WHITE OAKS LN",1)

replace location=subinstr(location,"WINDSOR COURT","WINDSOR CT",1)
replace street=subinstr(street,"WINDSOR COURT","WINDSOR CT",1)

gen diff_street=(trim(PropertyStreet)!=street)
gen diff_address=(trim(PropertyFullStreetAddress)!=location)
tab diff_street
tab diff_address

ren propertyci PropertyCity
ren legaltowns LegalTownship
keep PropertyStreet PropertyFullStreetAddress PropertyCity importparc fips state LegalTownship PropertyStreetNum diff_street diff_address
ren importparc ImportParcelID

save "$dta\pointcheck_NONVA_madison.dta",replace

*******************Aggregate Checking whether address matches************************
use "$dta\pointcheck_NONVA_clinton.dta",clear
append using "$dta\pointcheck_NONVA_groton.dta"
append using "$dta\pointcheck_NONVA_easthaven.dta"
append using "$dta\pointcheck_NONVA_eastlyme.dta"
append using "$dta\pointcheck_NONVA_fairfield.dta"
append using "$dta\pointcheck_NONVA_guilford.dta"
append using "$dta\pointcheck_NONVA_milford.dta"
append using "$dta\pointcheck_NONVA_newhaven.dta"
append using "$dta\pointcheck_NONVA_oldlyme.dta"
append using "$dta\pointcheck_NONVA_oldsaybrook.dta"
append using "$dta\pointcheck_NONVA_stonington.dta"
append using "$dta\pointcheck_NONVA_waterford.dta"
append using "$dta\pointcheck_NONVA_westbrook.dta"
append using "$dta\pointcheck_NONVA_westhaven.dta"
append using "$dta\pointcheck_NONVA_westport.dta"
append using "$dta\pointcheck_NONVA_stratford.dta"
append using "$dta\pointcheck_NONVA_branford.dta"
append using "$dta\pointcheck_NONVA_bridgeport.dta"
append using "$dta\pointcheck_NONVA_newlondon.dta"
append using "$dta\pointcheck_NONVA_norwalk.dta"
append using "$dta\pointcheck_NONVA_madison.dta"
duplicates drop
duplicates drop PropertyFullStreetAddress PropertyCity ImportParcelID,force
save "$dta\pointcheck_NONVA.dta",replace

merge 1:1 PropertyFullStreetAddress PropertyCity ImportParcelID using"$dta\proponeunit_nonVA.dta"
keep if _merge==3
tab LegalTownship if diff_address==1
