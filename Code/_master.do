clear 		all
set			more off
set			matsize 7500
capture		log close

*===============================================================================*
*																				*
*	THIS DO FILE BUILDS THE DATA AND RUNS THE ANALYSIS TO REPLICATE				*
*		BANDIERA, BEST, KHAN & PRAT, QJE 2021, THE ALLOCATION OF AUTHORITY		*
*			IN ORGANIZATIONS: A FIELD EXPERIMENT WITH BUREAUCRATS				*
*																				*
*	TO RUN IT, MAKE SURE YOU HAVE DOWNLOADED ALL THE DATA AND CODE FILES		*
*		AND MAKE SURE THE MACROS IN LINES 23-29 ARE POINTING TO THE 			*
*		DOWNLOADED FOLDERS														*
*																				*
*	NOTE THAT THE CODE RUNS 1000 RANDOMIZATION INFERENCE REPLICATIONS FOR MANY	*
*		PARTS OF THE ANALYSIS. THIS CAN TAKE A LONG TIME. TO DO FEWER 			*
*		REPLICATIONS, SET THE MACRO RIREPS ON LINE 34 TO A SMALLER NUMBER.		*
*																				*
*===============================================================================*

* set paths
global wd "/Users/michaelbest/Dropbox/PunjabProcurement/ReplicationPackage"
global code "${wd}/Code"
global rawdata "${wd}/RawData"
global usedata "${wd}/AnalysisData"
global picsdir "${wd}/Pictures"
global tabsdir "${wd}/Tables"
global tempdir "${wd}/Temp"

* macros
global items = "4834 921 938 1001 2762 999 943 1030 936 5107 1009 20433 998" ///
					+ " 1032 622 991 929 3906 1360 3346 994 992 989 927 3507"
global RIreps = 1000
global seed = 20190516

* 1. build datasets.
do "${code}/1_BuildData.do"

* 2. Baseline Analysis (Tables 2 and E.2)
do "${code}/2_BaselineAnalysis.do"

* 3. Summary Statistics (Figure 2, Table 1, and Figure A1)
do "${code}/3_SummStats.do"

* 4. Heterogeneity by Monitor Type (Figure 5, figure F1, tables F1--F5)
do "${code}/4_HeterogeneityMonitorType.do"

* 5. Cost-Benefit Analysis (Figure 4, figure 6)
do "${code}/5_CostBenefit.do"

* 6. Delays (Figure 7, figure 8, figure A9)
do "${code}/6_Delays.do"

* 7. Time Use (Figure 9 and table 3)
do "${code}/7_TimeUse.do"

* 8. Appendix A
do "${code}/8_AppendixA.do"

* 9. Appendix E
do "${code}/9_AppendixE.do"

* 10. Misc
do "${code}/10_Misc.do"


