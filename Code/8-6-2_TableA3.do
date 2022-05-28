use "${tempdir}/AttritionBillData.dta", clear


/*
8 regressions in each table:
{all generics vs analysis only} x {year 2 only vs both years} x {raw vs expenditure-weighted}

2 tables: POPSShare and AnalysisShare

Predictors:
-Object Code / Object Head /Object group (the 3-digit thing)
-Amount
-Date

reg1: allgeneric, both years, no weights
reg2: allgeneric, both years, exp weights
reg3: allgeneric, year 2, no weights
reg4: allgeneric, year 2, exp weights
reg5: analysisOCs, both years, no weights
reg6: analysisOCs, both years, exp weights
reg7: analysisOCs, year 2, no weights
reg8: analysisOCs, year 2, exp weights
*/

*Create variables
gen MajObj = substr(ObjectCode,1,3)
replace MajObj = "Operating Expenses" if MajObj == "A03"
replace MajObj = "Physical Assets" if MajObj == "A09"
replace MajObj = "Repairs" if MajObj == "A13"
encode MajObj, gen(MajorObj)
gen MinObj = substr(ObjectCode,1,4)
replace MinObj = "OpEx: Communications" if MinObj == "A032"
replace MinObj = "OpEx: Utilities" if MinObj == "A033"
replace MinObj = "OpEx: Occupancy Costs" if MinObj == "A034"
replace MinObj = "OpEx: General" if MinObj == "A039"
replace MinObj = "Assets: Commodity Purchases" if MinObj == "A093"
replace MinObj = "Assets: Other Stocks \& Stores" if MinObj == "A094"
replace MinObj = "Assets: Transport" if MinObj == "A095"
replace MinObj = "Assets: Plant \& Machinery" if MinObj == "A096"
replace MinObj = "Assets: Furniture \& Fixture" if MinObj == "A097"
replace MinObj = "Repair: Machinery" if MinObj == "A131"
replace MinObj = "Repair: Furniture" if MinObj == "A132"
replace MinObj = "Repair: Buildings" if MinObj == "A133"
replace MinObj = "Repair: Computers" if MinObj == "A137"
encode MinObj, gen(MinorObj)
replace ObjectCode = "OpEx: Elextronic Communication" if ObjectCode == "A03204"
replace ObjectCode = "OpEx: Courier" if ObjectCode == "A03205"
replace ObjectCode = "OpEx: Electricity" if ObjectCode == "A03304"
replace ObjectCode = "OpEx: Other Utilities" if ObjectCode == "A03305"
replace ObjectCode = "OpEx: Other Utilities" if ObjectCode == "A03370"
replace ObjectCode = "OpEx: Rent not on Building" if ObjectCode == "A03405"
replace ObjectCode = "OpEx: Rent of Machine" if ObjectCode == "A03408"
replace ObjectCode = "OpEx: Stationery" if ObjectCode == "A03901"
replace ObjectCode = "OpEx: Printing" if ObjectCode == "A03902"
replace ObjectCode = "OpEx: Newspapers" if ObjectCode == "A03905"
replace ObjectCode = "OpEx: Advertising" if ObjectCode == "A03907"
replace ObjectCode = "OpEx: Payments for Services" if ObjectCode == "A03919"
replace ObjectCode = "OpEx: Medicines" if ObjectCode == "A03927"
replace ObjectCode = "OpEx: Other Stores" if ObjectCode == "A03942"
replace ObjectCode = "OpEx: Other Stores: Computer/Stationery" if ObjectCode == "A03955"
replace ObjectCode = "OpEx: Other" if ObjectCode == "A03970"
replace ObjectCode = "Assets: Fertilizer" if ObjectCode == "A09302"
replace ObjectCode = "Assets: Other Commodity" if ObjectCode == "A09370"
replace ObjectCode = "Assets: Lab Equipment" if ObjectCode == "A09404"
replace ObjectCode = "Assets: Generic Consumables" if ObjectCode == "A09408"
replace ObjectCode = "Assets: General Utility Chemicals" if ObjectCode == "A09411"
replace ObjectCode = "Assets: Specific Utility Chemicals" if ObjectCode == "A09412"
replace ObjectCode = "Assets: Insecticides" if ObjectCode == "A09414"
replace ObjectCode = "Assets: Other Stocks and Stores" if ObjectCode == "A09470"
replace ObjectCode = "Assets: Purchase of Transport" if ObjectCode == "A09501"
replace ObjectCode = "Assets: Purchase of Plant \& Machinery" if ObjectCode == "A09601"
replace ObjectCode = "Assets: Purchase of Furniture \& Fixture" if ObjectCode == "A09701"
replace ObjectCode = "Repairs: Machinery \& Equipment" if ObjectCode == "A13101"
replace ObjectCode = "Repairs: Furniture \& Fixtures" if ObjectCode == "A13201"
replace ObjectCode = "Repairs: Other Building" if ObjectCode == "A13370"
replace ObjectCode = "Repairs: Computer Hardware" if ObjectCode == "A13701"
replace ObjectCode = "Repairs: Computer Software" if ObjectCode == "A13702"
replace ObjectCode = "Repairs: IT Equipment" if ObjectCode == "A13703"
encode ObjectCode, gen(DetailObj)

gen Date = date(Document_Date,"DMY")
format Date %td
gen Date2 = Date^2
label var Date2 "Date$^{2}$"
*gen Date3 = Date^3
*label var Date3 "Date$^{3}$"
gen Amount = abs(BillAmount)
gen lAmount = ln(abs(BillAmount))
label var lAmount "log Amount"
gen lAmount2 = lAmount^2
label var lAmount2 "log(Amount)$^{2}$"
*gen lAmount3 = lAmount^3
*label var lAmount3 "log(Amount)$^{3}$"
label define treatments 1 "Incentives" 2 "Autonomy" 3 "Both" 4 "Control"
label values Treatment treatments

*===========================================================*
*	1. how well does everything predict? No Interactions	*
*===========================================================*

estimates clear

reg POPSShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if Fiscal_Year == "2014-15", cl(CostCenterCode)
estimates store e1
estadd local yrs "Year 1" , replace : e1
estadd local shr "POPS" , replace : e1

reg POPSShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if Fiscal_Year =="2015-16", cl(CostCenterCode)
estimates store e2
estadd local yrs "Year 2" , replace : e2
estadd local shr "POPS" , replace : e2

reg POPSShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if AnalysisOC == 1 & Fiscal_Year == "2014-15", cl(CostCenterCode)
estimates store e5
estadd local yrs "Year 1" , replace : e5
estadd local shr "POPS" , replace : e5

reg POPSShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 ///
	if Fiscal_Year =="2015-16" & AnalysisOC == 1, cl(CostCenterCode)
estimates store e6
estadd local yrs "Year 2" , replace : e6
estadd local shr "POPS" , replace : e6

reg AnalysisShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if Fiscal_Year == "2014-15", cl(CostCenterCode)
estimates store e3
estadd local yrs "Year 1" , replace : e3
estadd local shr "Analysis" , replace : e3

reg AnalysisShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if Fiscal_Year =="2015-16", cl(CostCenterCode)
estimates store e4
estadd local yrs "Year 2" , replace : e4
estadd local shr "Analysis" , replace : e4

reg AnalysisShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 if AnalysisOC == 1 & Fiscal_Year == "2014-15", cl(CostCenterCode)
estimates store e7
estadd local yrs "Year 1" , replace : e7
estadd local shr "Analysis" , replace : e7

reg AnalysisShare i.strata ib4.Treatment i.DetailObj Date Date2 ///
	lAmount lAmount2 ///
	if Fiscal_Year =="2015-16" & AnalysisOC == 1, cl(CostCenterCode)
estimates store e8
estadd local yrs "Year 2" , replace : e8
estadd local shr "Analysis" , replace : e8

*Table

****Table
esttab e1 e2 e3 e4 e5 e6 e7 e8 ///
	using "${tabsdir}/TableA3.tex", ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	drop(*.strata 4.Treatment) ///
	mlabels(none) ///
	mgroups("All Generics" "Analysis Objects", ///
		pattern(1 0 0 0 1 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
	stats(N r2 yrs shr, ///
		labels("Observations" "$ R^{2}$" "Year" "Reporting Share") ///
		fmt(%8.0fc %9.2f)) ///
	label ///
	booktabs ///
	replace ///
	longtable ///
	collabels(none) ///
	title("Balance of Attrition of Items \label{tab:Attrition}")

	
****Table
esttab e1 e2 e3 e4 e5 e6 e7 e8, ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	drop(*.strata 4.Treatment) ///
	mlabels(none) ///
	mgroups("All Generics" "Analysis Objects", ///
		pattern(1 0 0 0 1 0 0 0) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
	stats(N r2 yrs shr, ///
		labels("Observations" "$ R^{2}$" "Year" "Reporting Share") ///
		fmt(%8.0fc %9.2f)) ///
	label ///
	collabels(none) ///
	title("Balance of Attrition of Items \label{tab:Attrition}")


