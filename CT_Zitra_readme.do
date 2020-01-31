
/* file order for building estimation dataset
1- CT_Zitra_Rawdata_Process.do 
2- CT_Zitra_AssessmentProcessing.do 
3- CT_Zitra_AttributeProcessing.do 
4- CT_Zitra_Buildcoastalsample.do 
5- CT_Zitra_TransactionProcessing.do 
6- CT_Zitra_AggTransAssess.do
7- CT_Zitra_GISsetups.do
*/

* Data from Zillow are simply restricted to CT data and all processing
* is done on a local copy. Restrictions of the data should be done
* as far from the cleaning as possible so not to exclude parcels too soon.

* All preloading of the property data are done with CT_Zitra_Rawdata_Process.do. 
* GIS attributes are processed through ArcGIS 10.5 functions (showing in python files).


