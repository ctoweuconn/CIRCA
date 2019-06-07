
/* file order for building estimation dataset
1- CT_Zitra_HistoricAssessmentIDFix.do 
2- CT_Zitra_CurrentAssessmentProcessing.do 
3- CT_Zitra_HistoricAssessmentProcessing.do 
4- CT_Zitra_TransactionProcessing.do 
5- CT_Zitra_EstimationSample.do 
*/

* Data from Zillow are simply restricted to CT data and all processing
* is done on a local copy. Restrictions of the data should be done
* as far from the cleaning as possible so not to exclude parcels too soon.

* All preloading of the data are done with CT_Zitra_PropertyAgg.do


