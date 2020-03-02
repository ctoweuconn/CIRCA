

/* file order for building estimation dataset
1- CT_Ztrax_Rawdata_Process.do 
2- CT_Ztrax_AssessmentProcessing.do 
3- CT_Ztrax_AttributeProcessing.do 
4- CT_Ztrax_Buildcoastalsample.do 
5- CT_Ztrax_TransactionProcessing.do 
6- CT_Ztrax_AggTransAssess.do
7- CT_Ztrax_Fixpoints_townpoly.do
8- CT_Ztrax_GISsetups.do
9- CT_Ztrax_GIS_data_aggregate.do
10- CT_Ztrax_AggGeoandClean.do
*/

*Analysis is conducted in CT_Ztrax_Analysis.do
*Simulations for retreating senarios are shown in Simulation_Retreat.do

/* Data from Zillow are initially restricted to CT data and all processing 
  is done on a local copy. All preloading of the property data are done with
  CT_Zitra_Rawdata_Process.do. 
  Restrictions of the data should be done
 as far from the cleaning as possible so not to exclude parcels too soon.
*/

* GIS attribute files (used in CT_Ztrax_GIS_data_aggregate.do) are processed through ArcGIS 10.5 functions (showing in python files).



