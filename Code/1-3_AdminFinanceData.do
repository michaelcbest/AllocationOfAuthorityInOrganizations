*************************************************************
* take the BER dataset and collapse to cost-center x year	*
*************************************************************

use "${rawdata}/BudgetExpenditureReport.dta", clear 

gen ObjectHead = substr(GL_Desc, 1, 3)
tab ObjectHead, m
gen ObjectCode = substr(GL_Desc, 1, 6)

*Merge in the object codes that are in our universe.
tempfile univ
preserve
	import excel using "${rawdata}/Object Codes for POPS.xlsx", clear firstrow
	keep Object_Code
	ren Object_Code ObjectCode
	duplicates drop
	drop if ObjectCode == ""
	isid ObjectCode
	save `univ'
restore
merge m:1 ObjectCode using `univ', gen(InUniverse) keep(1 3)

*Merge in the object codes that show up in our data.
tempfile analysis
preserve
	use "${rawdata}/POPSZRPMerge.dta", clear
	merge 1:1 DeliveryID RequestID using "${usedata}/UsingData.dta", ///
		keepusing(DeliveryID RequestID) keep(3)
	keep ObjectCode
	duplicates drop
	drop if ObjectCode == ""
	isid ObjectCode
	save `analysis'
restore
merge m:1 ObjectCode using `analysis', gen(InAnalysis)

*Collapse by Object Head
tempfile objecthead
preserve
	keep if inlist(ObjectHead,"A03","A09","A13")
	collapse (sum) OriginalBudgetReleased BudgetReleased FinalBudget TotalActualExpenditure, by(Cost_center Fiscal_Year ObjectHead)
	reshape wide BudgetReleased OriginalBudgetReleased FinalBudget TotalActualExpenditure, i(Fiscal_Year Cost_center) j(ObjectHead) string
	isid Cost_center Fiscal_Year
	save `objecthead'
restore

*Collapse Generic Universe
tempfile generic
preserve
	keep if InUniverse == 3
	collapse (sum) OriginalBudgetReleasedUniverse = OriginalBudgetReleased BudgetReleasedUniverse = BudgetReleased ///
		FinalBudgetUniverse = FinalBudget TotalActualExpenditureUniverse = TotalActualExpenditure, by(Cost_center Fiscal_Year)
	save `generic'
restore

*Collapse Analysis Sample Goods
tempfile analysis1
preserve
	keep if InAnalysis == 3
	collapse (sum) OriginalBudgetReleasedAnalysis = OriginalBudgetReleased BudgetReleasedAnalysis = BudgetReleased ///
		FinalBudgetAnalysis = FinalBudget TotalActualExpenditureAnalysis = TotalActualExpenditure, by(Cost_center Fiscal_Year)
	save `analysis1'
restore

*Collapse by Complement of Universe
tempfile genericnot
preserve
	keep if inlist(ObjectHead,"A03","A09","A12","A13")
	keep if InUniverse != 3
	collapse (sum) OriginalBudgetReleasedSpecific = OriginalBudgetReleased BudgetReleasedSpecific = BudgetReleased ///
		FinalBudgetSpecific = FinalBudget TotalActualExpenditureSpecific = TotalActualExpenditure, by(Cost_center Fiscal_Year)
	save `genericnot'
restore

*Collapse by Fiscal Year and Cost Center and merge
collapse (sum) OriginalBudgetReleasedAll = OriginalBudgetReleased BudgetReleasedAll=BudgetReleased ///
	FinalBudgetAll = FinalBudget TotalActualExpenditureAll = TotalActualExpenditure, by(Cost_center Fiscal_Year)
merge 1:1 Cost_center Fiscal_Year using `objecthead', nogen
merge 1:1 Cost_center Fiscal_Year using `generic', nogen
merge 1:1 Cost_center Fiscal_Year using `analysis1', nogen
merge 1:1 Cost_center Fiscal_Year using `genericnot', nogen

order Fiscal_Year Cost_center
sort Cost_center Fiscal_Year

save "${usedata}/BERccyear.dta", replace 






 
