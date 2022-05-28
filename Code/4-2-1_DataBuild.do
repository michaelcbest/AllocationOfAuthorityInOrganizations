*1. BASIC DATASET
use "${usedata}/UsingData.dta", clear
drop DeliveryDate
ren time DeliveryDate

drop if DeliveryDate > date("01Jul2016","DMY") /*outliers that mess up the pics*/
keep if Fiscal_Year == "2015-16"
ren lPriceHat ScalarItemType //Can't have "Hat" in the variable name, it'll get dropped

*2. JUNE SHARES
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .
*keep if agJune <= 0.9
*keep if agJune > 0.1 & agJune < 0.62

*3. RHS
gen InteractIncentives = Incentives0 * agJune
gen InteractAutonomy = Rules0 * agJune
gen InteractBoth = Both0 * agJune

global rhsbasic = "NCCs "
global rhscoarse = "NCCs "

*Good dummies and good-specific quantity
foreach i in $items {
	gen i`i' = (NewItemID == `i')
	gen lQ`i' = i`i' * lQuantity
	global rhsbasic = "${rhsbasic}" + "i`i' lQ`i' " 
	gen qual`i' = i`i' * qual
	gen sizeL`i' = i`i' & sizeL
	global rhscoarse = "${rhscoarse}" + "i`i' lQ`i' qual`i' sizeL`i' "
}

*randomization strata
tab strata, gen(st) //generates 69 stratum dummies.
return list
forvalues s = 2/69 {
	global rhsbasic = "${rhsbasic}" + "st`s' "
}

*4. POINTS TO ESTIMATE HETEROGENEOUS TREATMENT EFFECT AT
gen xpoints = (_n+9)/100 in 1/54
