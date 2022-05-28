*budget variables
use "${usedata}/BERccyear", clear
keep Cost_center Fiscal_Year FinalBudget* 
rename FinalBudget* *
drop Specific A03 A09 A13 Analysis
replace Fiscal_Year = "1516" if Fiscal_Year == "2015-16"
replace Fiscal_Year = "1415" if Fiscal_Year == "2014-15"
reshape wide All Universe, i(Cost_center) j(Fiscal_Year) string
rename Cost_center CostCenterCode
foreach v in All Universe {
	foreach y in 1415 1516 {
		replace `v'`y' = 0 if `v'`y' == .
	}
}
isid  CostCenterCode
merge 1:m CostCenterCode using "${usedata}/UsingData.dta", ///
		keepusing(CostCenterCode OfficeID) ///
		assert(1 3) ///
		keep(3) ///
		nogen
duplicates drop
isid CostCenterCode
collapse (sum) All1415 All1516 Universe1415 Universe1516, by(OfficeID)
*Compute budget shares
foreach y in "1415" "1516" {
	gen bShareUniverse`y' = Universe`y' / All`y'
}
foreach y in "1415" "1516" {
	label var bShareUniverse`y'	"POPS Universe"
}

save "${tempdir}/BudgetShares.dta", replace
