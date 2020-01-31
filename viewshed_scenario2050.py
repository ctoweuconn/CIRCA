# Viewshed_analysis.py
# Created on: 2019-10-22 # 

#import system modules
import arcpy
from arcpy import env
from arcpy.sa import *
import os
import time
import sys

#Check SA extension license
arcpy.CheckOutExtension("Spatial")

env.workspace = "C:\Users\starf\Documents\ArcGIS\Default.gdb"
outputroot="D:\Work\CIRCA\Circa\\ViewshedScenario2050_A\\"
#temp="D:\\UConn2\\Circa\\ViewshedGgl_poly\\temp\\"
temp1="D:\\UConn2\\Circa\\ViewshedScenario2050_A\\temp\\"
root="D:\Work\CIRCA\Circa\GISdata\\"

# Local variables:
#Viewshed_p_shp = "D:\\UConn2\\Circa\\GISdata\\buildingp_va_ggl.shp"
Viewshed_poly_shp=root+"building_va_scenario2050.shp"
LIS_spoly_shp = root+"LIS_spolyfix.shp"
coast2012LIS = "E:\LiDAR\CoastCTLidar.gdb\coast2012LIS_scenario2050"


# Make a layer from the feature class

arcpy.Delete_management("lyr0", "")
arcpy.MakeFeatureLayer_management(Viewshed_poly_shp,"lyr0")
StartTime0=time.clock()
 
for n in range(0,5603):
	arcpy.env.extent = "MAXOF"
	VSras_n_tif = outputroot+"Vshed_"+str(n)+".tif"
	StartTime1 = time.clock()
	arcpy.Delete_management(VSras_n_tif,"")
  	arcpy.Delete_management("Building_P_"+str(n),"")
	arcpy.Delete_management("BuildingP_buffer_"+str(n),"")
	arcpy.Delete_management("Building_buffer_"+str(n),"")
	arcpy.Delete_management("Building_bfed_"+str(n),"")
	arcpy.Delete_management("Obs_buffer_"+str(n),"")
	arcpy.Delete_management("LiDAR_bufferclip_"+str(n),"")
	arcpy.Delete_management("LiDAR_obsclip_"+str(n),"")
	arcpy.Delete_management("LiDAR_buildingclip_"+str(n),"")
	#arcpy.Delete_management("Buildingsub_"+str(n),"")
	#arcpy.Delete_management("New_VSRas_"+str(n),"")
	
    # Select one feature
	arcpy.SelectLayerByAttribute_management("lyr0", "New_SELECTION", '"fid" = '+str(n))
	
	# Process: Feature To Point
	arcpy.FeatureToPoint_management("lyr0", "Building_P_"+str(n), "CENTROID")
	
    # Creat a 5feet buffer of the building footprint, so that the process is robust to errors (the remnant outline) from 5by5 cell segmentation
	arcpy.Buffer_analysis("lyr0", "Building_buffer_"+str(n), "5 Feet", "FULL", "ROUND", "NONE", "", "GEODESIC")
	
	#Creat union of the 5ft buffer and the building footprint 
	arcpy.Union_analysis(["lyr0","Building_buffer_"+str(n)],"Building_bfed_"+str(n),"",0.0003)
	
	# Process: Buffer-mimic the entire region within 1 mile 
	arcpy.Buffer_analysis("Building_P_"+str(n), "BuildingP_buffer_"+str(n), "1 Miles", "FULL", "ROUND", "NONE", "", "GEODESIC")

	# Process: Buffer-creat an observer-a 4 ft(about 5/sqrt(2)) radius pillar-actually one cell of the raster 
	arcpy.Buffer_analysis("Building_P_"+str(n), "Obs_buffer_"+str(n), "4 feet", "FULL", "ROUND", "NONE", "", "GEODESIC")

	
	# Process: Clip
	arcpy.Clip_management(coast2012LIS, "", "LiDAR_bufferclip_"+str(n), "BuildingP_buffer_"+str(n), "-3.402823e+038", "ClippingGeometry", "NO_MAINTAIN_EXTENT")
	
	# Process: Clip - the observer clip of surface
	arcpy.Clip_management(coast2012LIS, "", "LiDAR_obsclip_"+str(n), "Obs_buffer_"+str(n), "-3.402823e+038", "ClippingGeometry", "NO_MAINTAIN_EXTENT")
	
	# Process: Clip - the buffered building clip 
	arcpy.Clip_management(coast2012LIS, "", "LiDAR_buildingclip_"+str(n), "Building_bfed_"+str(n), "-3.402823e+038", "ClippingGeometry", "NO_MAINTAIN_EXTENT")

	
	# Process: Raster Calculator lower building by 10 meters
	OutRas = Raster("LiDAR_buildingclip_"+str(n))-10

	# Process: Raster Calculator replace
	OutRas1 = Con(IsNull(OutRas),"LiDAR_bufferclip_"+str(n),OutRas)

	# Process: Raster Calculator lower pillar by 4 meters (6 meters less than the other parts of building being lowered)
	OutRas2 = Raster("LiDAR_obsclip_"+str(n))-4

	# Process: Raster Calculator replace
	OutRas3 = Con(IsNull(OutRas2),OutRas1,OutRas2)


	
	# Process: Viewshed
	outViewshed = Viewshed(OutRas3,"Building_P_"+str(n),"1", "FLAT_EARTH", ".13")
	outViewshed.save(VSras_n_tif)

    #Delete temp files
  	
	arcpy.Delete_management("Building_P_"+str(n),"")
	arcpy.Delete_management("BuildingP_buffer_"+str(n),"")
	arcpy.Delete_management("Building_buffer_"+str(n),"")
	arcpy.Delete_management("Building_bfed_"+str(n),"")
	arcpy.Delete_management("Obs_buffer_"+str(n),"")
	arcpy.Delete_management("LiDAR_bufferclip_"+str(n),"")
	arcpy.Delete_management("LiDAR_obsclip_"+str(n),"")
	arcpy.Delete_management("LiDAR_buildingclip_"+str(n),"")
	
	#arcpy.Delete_management("Buildingsub_"+str(n),"")
	#arcpy.Delete_management("New_VSRas_"+str(n),"")
	
 
	StopTime0 = time.clock()
	elapsedTime0=(StopTime0-StartTime1)
	print 'Time for operating feature '+str(n)+' is: '+ str(round(elapsedTime0, 1))+ ' seconds'
