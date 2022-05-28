
use "${rawdata}/AttritionData.dta", clear

*How much of this thing is in the analysis sample?
gen Expenditure = exp(lUnitPrice) * exp(lQuantity)
gen AnalysisExpenditure = Expenditure * InAnalysis
bys MBZRPID: egen AnalysisAmount = total(AnalysisExpenditure)

*How much of this thins is in POPS?
bys MBZRPID: egen POPSAmount = total(Expenditure)

assert AnalysisAmount <= POPSAmount

*Collapse to the ZRP level
keep Fiscal_Year CostCenterCode DocumentNumber ObjectCode BillAmount ///
	Document_Date MBZRPID ObjectHead InPOPS Department District Group Treatment ///
	OriginalGroup GroupFinal AnalysisOC AnalysisAmount POPSAmount
bys CostCenterCode: egen mytreat = mean(Treatment)
replace Treatment = mytreat
drop mytreat
	
/*Code to check how many unique values per MBZRPID
egen cc = tag(MBZRPID POPSAmount)
tab cc
bys MBZRPID: egen ccs = total(cc)
tab ccs
drop cc*
*/
duplicates drop
isid MBZRPID
count

gen AnalysisShare = AnalysisAmount / BillAmount
summ AnalysisShare
count if AnalysisShare > 1
replace AnalysisShare = 1 if AnalysisShare > 1
gen POPSShare = POPSAmount / BillAmount
summ POPSShare
count if POPSShare > 1
replace POPSShare = 1 if POPSShare > 1

gen AllPOPS = (POPSShare > 0.99)
gen AllAnalysis = (AnalysisShare > 0.99)

gen SomePOPS = (POPSShare > 0)
gen SomeAnalysis = (AnalysisShare > 0 )

egen strata = group(Department District)

save "${tempdir}/AttritionBillData.dta", replace
