
/*******************************\
*	PREPARE THE ITEM DATASETS	*
\*******************************/

foreach item in $items {
  global item = "`item'"
  do "${code}/1-1-3-CleanItemData.do"
}

/***********************\
*	STACK THE ITEMS 	*
\***********************/

clear
foreach item in $items {
  append using "${tempdir}/RegData`item'.dta"
}

gen temp = _n
gen MBPurchaseID = string(temp)
drop temp
save "${tempdir}/RegDataFull.dta", replace
