					
/*******************\
*	Build the RHS	*
\*******************/
									
global nvars = ""
global ivars = ""
global ivarsareg = ""
foreach item in $items {
  use "${tempdir}/RegAttributes_Item`item'.dta", clear
  local nvarsitem = RegNVars
  global nvars_It`item' = ""
  foreach var in `nvarsitem' {
    global nvars = "${nvars}" + " " + "`var'_It`item'"
	global nvars_It`item' = "${nvars_It`item'}" + " " + "`var'_It`item'"
  }
  local ivarsitem = RegIVars
  global ivars_It`item' = ""
  foreach var in `ivarsitem' {
    global ivars = "${ivars}" + " " + "`var'_It`item'"
	global ivarsareg = "${ivarsareg}" + " " + "i.`var'_It`item'"
	global ivars_It`item' = "${ivars_It`item'}" + " " + "`var'_It`item'"
  }
}


/***********************\
*	BUILD THE DATASET	*
\***********************/

use "${tempdir}/RegDataFull.dta", clear
do "${code}/1-2-1-DataPrep.do"
		
* Item Variety Measures
** Scalar Measure
reg lUnitPrice NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NewItemID#c.time if ///
	inlist(Treatment,4,5) & TrimmedSample == 1
predict lPriceHat, xb
do "${code}/1-2-2-DataClean.do"
** Coarse Measure
do "${code}/1-2-3-CoarseVariety.do"
** Machine Learning
merge 1:1 DeliveryID RequestID using "${rawdata}/RFOutputs.dta", keep(1 3) nogen
replace rf_pred_lprice = lPriceHat if rf_pred_lprice == .

* Tidy up
tempfile ccnobs
preserve
	collapse (count) CCNobs = RequestID, by(CostCenterCode Year2)
	reshape wide CCNobs, i(CostCenterCode) j(Year2)
	replace CCNobs0 = 0 if CCNobs0 == .
	replace CCNobs1 = 0 if CCNobs1 == .
	save `ccnobs'
restore
merge m:1 CostCenterCode using `ccnobs', nogen

* Merge in Admin Data dates

ren DocumentDate DocumentDateOld
merge 1:1 DeliveryID RequestID using "${rawdata}/POPSZRPMerge.dta", ///
	keepusing(BillDate PaymentDate DocumentDate RequisitionDate DeliveryDate ///
	Fiscal_Year Posting_Date ObjectCode BillAmount TokenDate_POPS) ///
	keep(1 3) ///
	nogen
drop Posting_Date
gen TokenDay = dofc(TokenDate_POPS)
format TokenDay %td
drop TokenDate_POPS
*ren time DeliveryDate
capture drop Year2
gen Year2 = (Fiscal_Year == "2015-16")

* Tidy up
egen CCID = group(CostCenterCode)

gen IncRules = Incentives0 + Rules0
gen IncBoth = Incentives0 + Both0
gen RulesBoth = Rules0 + Both0
compress

* Save
save "${usedata}/UsingData.dta", replace
