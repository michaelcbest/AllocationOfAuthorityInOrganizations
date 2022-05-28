*===============================================================================*
*																				*
*	THIS DO FILE BUILDS THE ANALYSIS DATASETS FROM THE RAW DATA					*
*																				*
*===============================================================================*

* 1. Build datasets of minimally cleaned item purchases from raw POPS data
do "${code}/1-1_ItemData.do"

* 2. Build Analysis dataset for baseline results.
do "${code}/1-2_UsingData.do"

* 3. Build data out of finance department's admin data on spending
do "${code}/1-3_AdminFinanceData.do"

* 4. Calculate our proxy for monitor's type: Share of approvals in June
do "${code}/1-4_JuneSpikes.do"

* 5. Dataset of who the PO is responsible for each purchase
do "${code}/1-5_WhoIsPO.do"

