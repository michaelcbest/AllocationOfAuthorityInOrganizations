/* Compile the sample summaries into a single dataset for use later */
clear
foreach item in $items {
	append using "${tempdir}/RegAttributes_Item`item'.dta"
}
drop AllIVars AllNVars RegIVars RegNVars
ren ItemID NewItemID
gen Expenditure = NObs * mValue
gen ExpenditureControl = NObsControl * mValueControl
egen temp = total(Expenditure)
gen ExpShare = Expenditure / temp
drop temp
egen temp = total(ExpenditureControl)
gen ExpShareControl = ExpenditureControl / temp
drop temp
save "${tempdir}/ItemSummaries.dta", replace
