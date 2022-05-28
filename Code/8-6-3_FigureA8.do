use "${tempdir}/AttritionBillData.dta", clear

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
gen Amount = abs(BillAmount)
gen lAmount = ln(abs(BillAmount))
label var lAmount "log Amount"
gen lAmount2 = lAmount^2
label var lAmount2 "log(Amount)$^{2}$"
label define treatments 1 "Incentives" 2 "Autonomy" 3 "Both" 4 "Control"
label values Treatment treatments

encode CostCenterCode, gen(CC)
keep if Treatment != . //the guys who make it into the final analysis sample

*===========================================*
*	2. Object, Amount and Date Controls		*
*===========================================*

estimates clear
*POPS Share
***Year 1
areg POPSShare i.DetailObj lAmount lAmount2 Date Date2 if Fiscal_Year == "2014-15" & AnalysisOC == 1, absorb(CC)
predict FE_PanelA, d
replace FE_PanelA = FE_PanelA + _b[_cons]

***Year 2
areg POPSShare i.DetailObj lAmount lAmount2 Date Date2 if Fiscal_Year == "2015-16" & AnalysisOC == 1, absorb(CC)
predict FE_PanelB, d
replace FE_PanelB = FE_PanelB + _b[_cons]

*Analysis Share
***Year 1
areg AnalysisShare i.DetailObj lAmount lAmount2 Date Date2 if Fiscal_Year == "2014-15" & AnalysisOC == 1, absorb(CC)
predict FE_PanelC, d
replace FE_PanelC = FE_PanelC + _b[_cons]

***Year 2
areg AnalysisShare i.DetailObj lAmount lAmount2 Date Date2 if Fiscal_Year == "2015-16" & AnalysisOC == 1, absorb(CC)
predict FE_PanelD, d
replace FE_PanelD = FE_PanelD + _b[_cons]


*===========================================*
*	3. DRAW PICTURES OF THE DISTRIBUTIONS	*
*===========================================*

collapse (mean) FE*, by(CC CostCenterCode Treatment)
gen Incentives = 0 if Treatment == 4
replace Incentives = 1 if Treatment == 1
gen Autonomy = 0 if Treatment == 4
replace Autonomy = 1 if Treatment == 2
gen Both = 0 if Treatment == 4
replace Both = 1 if Treatment == 3

global colorT1 = "gs10"
global colorT2 = "black"
global colorT3 = "gs5"
global colorT4 = "black"

foreach p in "A" "B" "C" "D" {
	ksmirnov FE_Panel`p', by(Incentives) exact
	global IncentivesText = "Incentives. K-S P-val=" + string(`r(p_exact)',"%9.3f")
	ksmirnov FE_Panel`p', by(Autonomy) exact
	global AutonomyText = "Autonomy. K-S P-val=" + string(`r(p_exact)',"%9.3f")
	ksmirnov FE_Panel`p', by(Both) exact
	global BothText = "Both. K-S P-val=" + string(`r(p_exact)',"%9.3f")

	twoway (kdensity FE_Panel`p' if Treatment == 4, lcolor("${colorT4}") lpattern(dot)) ///
		(kdensity FE_Panel`p' if Treatment == 1, lcolor("${colorT1}") lpattern(dash)) ///
		(kdensity FE_Panel`p' if Treatment == 2, lcolor("${colorT2}")) ///
		(kdensity FE_Panel`p' if Treatment == 3, lcolor("${colorT3}") lpattern(shortdash_dot)), ///
		graphregion(color(white)) ///
		legend(order(1 3 2 4)) ///
		legend(label(1 "Control")) ///
		legend(label(3 "${AutonomyText}")) ///
		legend(label(2 "${IncentivesText}")) ///
		legend(label(4 "${BothText}")) ///
		legend(cols(2)) ///
		xtitle("PO Fixed Effect") ///
		ytitle("")
	graph export "${picsdir}/FigureA8`p'.pdf", replace
	graph export "${picsdir}/FigureA8`p'.eps", replace
	
}
