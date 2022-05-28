*===============================================================================*
*																				*
*	THIS DO FILE TAKES THE RAW ITEM PURCHASE DATA FROM POPS AND CLEANS 			*
*		AND COMPILES IT INTO AN ANALYSIS DATASET OF PURCHASES					*
*																				*
*===============================================================================*

* 1. clean the item attributes
foreach item in $items {
  global item = "`item'"
  do "${code}/1-1-ItemID`item'.do"
}

* 2. Compile the item summaries
do "${code}/1-1-2-CompileSummaries.do"

* 3. Build Full Regression Dataset from cleaned POPS datasets
do "${code}/1-1-3-BuildRegData.do"

