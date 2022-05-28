
*Prepare usingdata
use "${usedata}/UsingData.dta", clear

*merge in mechanism questions
ren OfficeID OfficeId
merge m:1 OfficeId using "${rawdata}/MechanismsSurvey.dta", ///
	keep(1 3) ///
	nogen
ren OfficeId OfficeID

*Merge in budget variables
tempfile budgets
preserve
	use "${usedata}/BERccyear.dta", clear
	keep Cost_center Fiscal_Year FinalBudget* ///
		TotalActualExpenditure* 
	rename FinalBudget* Final*
	rename TotalActualExpenditure*  Expenditure*
	replace Fiscal_Year = "1516" if Fiscal_Year == "2015-16"
	replace Fiscal_Year = "1415" if Fiscal_Year == "2014-15"
	reshape wide FinalAll ExpenditureAll FinalA03 ///
		ExpenditureA03 FinalA09 ExpenditureA09 FinalA13 ///
		ExpenditureA13 FinalUniverse ExpenditureUniverse ///
		FinalAnalysis ExpenditureAnalysis FinalSpecific ExpenditureSpecific, ///
			i(Cost_center) j(Fiscal_Year) string
	rename Cost_center CostCenterCode
	foreach v in FinalAll ExpenditureAll FinalA03 ///
		ExpenditureA03 FinalA09 ExpenditureA09 FinalA13 ///
		ExpenditureA13 FinalUniverse ExpenditureUniverse ///
		FinalAnalysis ExpenditureAnalysis FinalSpecific ExpenditureSpecific {
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

	collapse (sum) FinalAll1415 ///
		ExpenditureAll1415 FinalA031415 ExpenditureA031415 ///
		FinalA091415 ExpenditureA091415 ///
		FinalA131415 ExpenditureA131415 FinalUniverse1415 ///
		ExpenditureUniverse1415 FinalAnalysis1415 ///
		ExpenditureAnalysis1415 FinalAll1516 ExpenditureAll1516 ///
		FinalA031516 ExpenditureA031516 ///
		FinalA091516 FinalA131516 ExpenditureA131516 ///
		FinalUniverse1516 ExpenditureUniverse1516 ///
		FinalAnalysis1516 ExpenditureAnalysis1516 ExpenditureA091516 ///
		FinalSpecific1415 ExpenditureSpecific1415 FinalSpecific1516 ///
		ExpenditureSpecific1516, ///
		by(OfficeID)
	save `budgets'
restore
merge m:1 OfficeID using `budgets', assert(3) keep(3) nogen
label var FinalAll1415 					"Budget: Total Nonsalary"
label var FinalAll1516 					"Budget: Total Nonsalary"
label var ExpenditureAll1415 			"Expenditure: Total Nonsalary"
label var ExpenditureAll1516 			"Expenditure: Total Nonsalary"
label var FinalA031415 					"Budget: Operating Expenses"
label var FinalA031516 					"Budget: Operating Expenses"
label var ExpenditureA031415 			"Expenditure: Operating Expenses"
label var ExpenditureA031516 			"Expenditure: Operating Expenses"
label var FinalA091415 					"Budget: Physical Assets"
label var FinalA091516 					"Budget: Physical Assets"
label var ExpenditureA091415 			"Expenditure: Physical Assets"
label var ExpenditureA091516 			"Expenditure: Physical Assets"
label var FinalA131415 					"Budget: Repairs \& Maintenance"
label var FinalA131516 					"Budget: Repairs \& Maintenance"
label var ExpenditureA131415 			"Expenditure: Repairs \& Maintenance"
label var ExpenditureA131516 			"Expenditure: Repairs \& Maintenance"
label var FinalUniverse1415 			"Budget: Accounting Codes Potentially Including Generic Goods"
label var FinalUniverse1516 			"Budget: Accounting Codes Potentially Including Generic Goods"
label var ExpenditureUniverse1415		"Expenditure: Accounting Codes Potentially Including Generic Goods"
label var ExpenditureUniverse1516		"Expenditure: Accounting Codes Potentially Including Generic Goods"
label var FinalAnalysis1415 			"Budget: Analysis Sample Accounting Codes"
label var FinalAnalysis1516 			"Budget: Analysis Sample Accounting Codes"
label var ExpenditureAnalysis1415 		"Expenditure: Analysis Sample Accounting Codes"
label var ExpenditureAnalysis1516 		"Expenditure: Analysis Sample Accounting Codes"
label var FinalSpecific1415				"Budget: Non-Generic Procurement"
label var FinalSpecific1516				"Budget: Non-Generic Procurement"
label var ExpenditureSpecific1415		"Expenditure: Non-Generic Procurement"
label var ExpenditureSpecific1516		"Expenditure: Non-Generic Procurement"


*Merge in the june spikes
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .

save "${usedata}/UsingWithMechanisms.dta", replace
