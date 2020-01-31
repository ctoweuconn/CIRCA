# Viewshed_analysis.py
# Created on: 2019-Oct-31th
# Set the necessary product code
# import arcinfo

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
outputroot="D:\Work\CIRCA\Circa\\ViewshedScenario2050_poly\\"
temp="D:\Work\CIRCA\Circa\\ViewshedScenario2050_poly\\temp\\"
root="D:\Work\CIRCA\Circa\GISdata\\"

# Local variables:
Viewshed_p_shp = root+"buildingp_va_scenario2050.shp"
Viewshed_poly_shp=root+"building_va_scenario2050.shp"
LIS_spoly_shp = "D:\Work\CIRCA\Circa\GISdata\\LIS_spolyfix.shp"
coast2012LIS = "E:\LiDAR\CoastCTLidar.gdb\coast2012LIS_scenario2050"

# Make a layer from the feature class
arcpy.Delete_management("lyr0", "")
arcpy.MakeFeatureLayer_management(Viewshed_poly_shp,"lyr0")
StartTime0=time.clock()
 
arcpy.Delete_management("lyr0", "")
arcpy.Delete_management("lyr", "")
arcpy.MakeFeatureLayer_management(Viewshed_p_shp, "lyr") 
for n in range(0,5603):
   StartTime2 = time.clock()

   Vshed_n_tif = "D:\Work\CIRCA\Circa\\ViewshedScenario2050_A\\Vshed_"+str(n)+".tif"
   VSpoly_n=temp+"VSpoly_"+str(n)+".shp"
   VSselect_n= temp+"VSselect_"+str(n)+".shp"   
   LISview_n = outputroot+"LISview_"+str(n)+".shp"
   LISview_pt_n= outputroot+"LISview_pt_"+str(n)+".shp"
   
   # Select one feature
   arcpy.SelectLayerByAttribute_management("lyr", "New_SELECTION", '"fid" = '+str(n))
   
   # Process: Raster to Polygon
   arcpy.RasterToPolygon_conversion(Vshed_n_tif, VSpoly_n, "NO_SIMPLIFY", "Value")

   # Process: Select
   arcpy.Select_analysis(VSpoly_n, VSselect_n, '"gridcode" =1')

   # Process: Intersect
   arcpy.Intersect_analysis(LIS_spoly_shp+" #;"+VSselect_n+" #", LISview_n, "ALL", "", "INPUT")
   
   arcpy.Delete_management("lyr1", "")
   arcpy.MakeFeatureLayer_management(LISview_n, "lyr1") 
   count= arcpy.GetCount_management("lyr1")
   
   print 'row count is: '+str(count)
   # Process: Get Count
   
   if str(count) == "0":
    # Process: Delete
    arcpy.Delete_management(VSpoly_n, "")
    arcpy.Delete_management(VSselect_n, "")
    arcpy.Delete_management(LISview_n, "")
    arcpy.Delete_management("in_memory", "workspace")

   else:
    # Process: Near
    arcpy.Near_analysis(LISview_n, "lyr", "", "NO_LOCATION", "ANGLE", "GEODESIC")
    # Process: Add Geometry Attributes
    arcpy.AddGeometryAttributes_management(LISview_n, "AREA_GEODESIC;PERIMETER_LENGTH_GEODESIC", "FEET_US", "SQUARE_FEET_US", "GEOGCS['GCS_North_American_1983',DATUM['D_North_American_1983',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]")
    # Process: Feature To Point
    arcpy.FeatureToPoint_management(LISview_n, LISview_pt_n, "CENTROID")
    # Process: Near (2)
    arcpy.Near_analysis(LISview_pt_n, "lyr", "", "NO_LOCATION", "NO_ANGLE", "GEODESIC")
    # Process: Delete
    arcpy.Delete_management(VSpoly_n, "")
    arcpy.Delete_management(VSselect_n, "")
    arcpy.Delete_management("in_memory", "workspace")
   
   StopTime1 = time.clock()
   elapsedTime1=(StopTime1-StartTime2)
   print 'Time for operating feature '+str(n)+' is: '+ str(round(elapsedTime1, 1))+ ' seconds'

StopTime2 = time.clock()
elapsedTime2=(StopTime2-StartTime0)/60
print 'Time for operating '+str(n)+'features is: '+ str(round(elapsedTime2, 1))+ ' minites'
