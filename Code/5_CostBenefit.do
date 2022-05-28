
*===========================================================*
*	1. How much did the performance pay honoraria cost?		*
*===========================================================*

/* Create stata dataset of the pay grades in 2016 */
import excel using "${rawdata}/Pay Scales.xlsx", ///
	clear ///
	firstrow
drop Min2017 Incr2017 Max2017
gen Salary = Min2016 + ((Stages/2)*Incr2016)
keep BPS Salary
save "${tempdir}/Salaries.dta", replace

*Cost: All people who got an honorarium
use "${rawdata}/PECData.dta", clear
**merge in pay scales
ren UserID UserId
merge m:1 UserId using "${rawdata}/Users.dta", ///
	keep(1 3) nogen ///
	keepusing(SanctionedGradeId BPS)
merge m:1 SanctionedGradeId using "${rawdata}/SanctionedGrade.dta", nogen ///
	keep(1 3)
drop SanctionedGradeId
ren Value PayGrade
label var PayGrade "Grade in the Civil Service Pay Scale"
tab PayGrade BPS, m
***Where Pay Scale is missing use the BPS variable where possible.
replace PayGrade = "17" if PayGrade == "" & BPS == 3
replace PayGrade = "18" if PayGrade == "" & BPS == 5
replace PayGrade = "18" if PayGrade == "" & BPS == 6
replace PayGrade = "19" if PayGrade == "" & BPS == 7
replace PayGrade = "20" if PayGrade == "" & BPS == 9
replace PayGrade = "22" if PayGrade == "" & BPS == 14
drop BPS
destring PayGrade, force gen(BPS) ignore("+SpecialPay ")
tab PayGrade BPS, m
merge m:1 BPS using "${tempdir}/Salaries.dta", nogen keep(1 3)
***for people who we don't have a salary for, use the average salary
summ Salary
replace Salary = `r(mean)' if Salary == .
**Add up
gen Payment = 0
replace Payment = Salary if Group == "GOLD"
replace Payment = 0.5 * Salary if Group == "SILVER"
replace Payment = 0.25 * Salary if Group == "BRONZE"

summ Payment if PEC == "Final 2015-16" | PEC == "Midterm 2015-16"
gen Cost1OfPEC = `r(sum)'
gen NPayments = `r(N)'
keep Cost1OfPEC NPayments
drop in 2/l
save "${tempdir}/Cost1.dta", replace


*===================================================*
*	2. How much did the eligible offices spend?		*
*===================================================*

*budget variables
tempfile budgets
use "${usedata}/BERccyear", clear
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
		keepusing(CostCenterCode OfficeID Treatment District) ///
		assert(1 3) ///
		keep(3) ///
		nogen
duplicates drop
isid CostCenterCode
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .

collapse (sum) ExpenditureAnalysis1516, ///
	by(OfficeID Treatment District agJune)
	
	
*=======================================*
*	3. Picture of overall cost-benefit	*
*=======================================*

*summarize the data to grab the overall amounts	
tabstat ExpenditureAnalysis1516, by(Treatment) stats(N mean sum sd) format(%9.0f)
return list
summ ExpenditureAnalysis1516 if Treatment == 1
global IncExp = `r(sum)'
summ ExpenditureAnalysis1516 if Treatment == 2
global AutExp = `r(sum)'
summ ExpenditureAnalysis1516 if Treatment == 3
global BotExp = `r(sum)'
**grab cost amount
preserve
	use "${tempdir}/Cost1.dta", clear
	summ Cost1OfPEC
	global Cost = `r(mean)' / 2 //half of the total cost is because of incentives and the other because of both (in expectation)
restore


*Make picture
preserve
	clear
	set obs 9
	gen var = ""
	replace var = "Incentives" in 1/3
	replace var = "Autonomy" in 4/6
	replace var = "Both" in 7/9
	gen est = ""
	replace est = "ci_lb" in 1
	replace est = "ci_lb" in 4
	replace est = "ci_lb" in 7
	replace est = "ci_ub" in 3
	replace est = "ci_ub" in 6
	replace est = "ci_ub" in 9
	replace est = "point" in 2
	replace est = "point" in 5
	replace est = "point" in 8
	gen coef = 0.022 if est == "point" & var == "Incentives"
	replace coef = 0.022 - (1.96 * 0.033) if est == "ci_lb" & var == "Incentives"
	replace coef = 0.022 + (1.96 * 0.033) if est == "ci_ub" & var == "Incentives"
	replace coef = 0.08 if est == "point" & var == "Autonomy"
	replace coef = 0.08 - (1.96 * 0.031) if est == "ci_lb" & var == "Autonomy"
	replace coef = 0.08 + (1.96 * 0.031) if est == "ci_ub" & var == "Autonomy"
	replace coef = 0.072 if est == "point" & var == "Both"
	replace coef = 0.072 - (1.96 * 0.033) if est == "ci_lb" & var == "Both"
	replace coef = 0.072 + (1.96 * 0.033) if est == "ci_ub" & var == "Both"
	gen saved = ${IncExp} * (coef/(1-coef)) / 1000000 if var == "Incentives" & est == "point"
	replace saved = (${IncExp} / 1000000) * (1/((1-0.022)^2)) * coef if var == "Incentives" & est != "point"
	replace saved = ${AutExp} * (coef/(1-coef)) / 1000000 if var == "Autonomy" & est == "point"
	replace saved = (${AutExp} / 1000000) * (1/((1-0.08)^2)) * coef if var == "Autonomy" & est != "point"
	replace saved = ${BotExp} * (coef/(1-coef)) / 1000000 if var == "Both" & est == "point"
	replace saved = (${BotExp} / 1000000) * (1/((1-0.072)^2)) * coef if var == "Both" & est != "point"	
	gen netben = saved - (${Cost}/1000000) if inlist(var,"Incentives","Both")
	replace netben = saved if var == "Autonomy"
	reshape wide coef saved netben, i(var) j(est) string
	gen xcoef = 1
	replace xcoef = 2 if var == "Incentives"
	replace xcoef = 3.5 if var == "Both"
	gen xnetben = xcoef + 0.3
	****benchmarks
	set obs 5
	replace var = "Hospital" in 4
	replace var = "School" in 5
	replace xcoef = -1 in 4
	replace xcoef = 0 in 5
	gen benchmark = 26.25 in 4
	replace benchmark = 26.4 in 5

	twoway (rcap savedci_ub savedci_lb xcoef if var == "Incentives", ///
				color("gs6") lpattern(dash)) ///
			(rcap netbenci_ub netbenci_lb xcoef if var == "Autonomy", ///
				color("gs6") lwidth(medthick)) ///
			(rcap netbenci_ub netbenci_lb xnetben if var == "Incentives", ///
				color("gs6") lwidth(medthick)) ///
			(rcap savedci_ub savedci_lb xcoef if var == "Both", ///
				color("gs6") lpattern(dash)) ///
			(rcap netbenci_ub netbenci_lb xnetben if var == "Both", ///
				color("gs6") lwidth(medthick)) ///
			(scatter netbenpoint xnetben if var == "Incentives", ///
				msymbol(oh) color("gs6") ) ///
			(scatter savedpoint xcoef if var == "Incentives", ///
				msymbol(oh) color("gs6") ) ///
			(scatter netbenpoint xcoef if var == "Autonomy", ///
				msymbol(oh) color("gs6") ) ///
			(scatter netbenpoint xnetben if var == "Both", ///
				msymbol(oh) color("gs6") ) ///
			(scatter savedpoint xcoef if var == "Both", ///
				msymbol(oh) color("gs6") ) ///
			(pcarrowi -7.6 2 -10.3 2.3, color(gs7)) ///
			(bar benchmark xcoef if var == "Hospital", ///
			fcolor(gs11) lcolor(black) barwidth(0.7) ) ///
			(bar benchmark xcoef if var == "School", ///
			fcolor(gs14) lcolor(black) barwidth(0.7) ) , ///
			xlabel(1 "Autonomy" 2.4 "Incentives" 3.65 "Both", noticks) ///
			xtitle("") ///
			legend(off) ///
			xsc(r(0.5 4.5)) ///
			graphregion(color(white)) ///
			xsize(7) ///
			ysize(8) ///
			ytitle("Savings (Rs. Million)") ///
			text(12.4 2.35 "95% CI:", placement(e) size(small)) ///
			text(11.2 2.35 "510% RoR", placement(e) size(small)) ///
			text(1.8 2.35 "Point Est:", placement(e) size(small)) ///
			text(0.6 2.35 "45% RoR", placement(e) size(small)) ///
			text(16.5 3.85 "95% CI:", placement(e) size(small)) ///
			text(15.3 3.85 "637% RoR", placement(e) size(small)) ///
			text(7.5 3.85 "Point Est:", placement(e) size(small)) ///
			text(6.3 3.85 "261% RoR", placement(e) size(small)) ///
			text(-6.5 1.95 "Gross Savings", placement(w) size(small) color("gs6")) ///
			text(-9.1 2.4 "Net Savings", placement(e) size(small) color("gs6")) ///
			text(-9.1 2.125 "Cost: 2.65", color(gs7) size(small) placement(w)) ///
			text(13 -1 "150 Hospital Beds", color(black) size(medsmall) orientation(vertical)) ///
			text(13 0 "10 Schools", color(black) size(medsmall) orientation(vertical)) ///
			ylabel(-10(5)30)
	graph export "${picsdir}/Figure4.pdf", replace
	graph export "${picsdir}/Figure4.eps", replace

restore

	
*===========================================================*
*	4. Picture of cost-benefit as a function of agJune		*
*===========================================================*

*4.1 Spending
collapse (sum) ExpenditureAnalysis1516, by(Treatment District agJune)

*4.2 Costs
tempfile districtcosts
preserve
	use "${usedata}/UsingData.dta", clear
	keep RequestID DeliveryID OfficeID Treatment District
	merge 1:1 RequestID DeliveryID using "${usedata}/WhoIsDDO.dta", nogen keep(1 3)
	rename UserID UserId
	merge m:1 UserId using "${rawdata}/UsersWithDemographics.dta", ///
		nogen ///
		keepusing(Role BPS PayGrade)
	tab PayGrade BPS, m
	***Where PayGrade is missing use the BPS variable where possible.
	replace PayGrade = "17" if PayGrade == "" & BPS == 3
	replace PayGrade = "18" if PayGrade == "" & BPS == 5
	replace PayGrade = "18" if PayGrade == "" & BPS == 6
	replace PayGrade = "19" if PayGrade == "" & BPS == 7
	replace PayGrade = "20" if PayGrade == "" & BPS == 9
	replace PayGrade = "22" if PayGrade == "" & BPS == 14
	drop BPS
	destring PayGrade, force gen(BPS) ignore("+SpecialPay ")
	collapse (max) BPS, by(OfficeID District Treatment)
	merge m:1 BPS using "${tempdir}/Salaries.dta", nogen keep(1 3)
	***for people who we don't have a salary for, use the average salary
	summ Salary
	replace Salary = `r(mean)' if Salary == .
	collapse (sum) Salary, by(District Treatment)
	save `districtcosts'
restore
merge 1:1 District Treatment using `districtcosts', nogen keep(3)
***Divide the cost in proportion to the salary bill in each district * treatment
***cost is (my salary bill / total salary bill) * 2.65 million Rupees
summ Salary if Treatment == 1
gen Cost = (Salary / `r(sum)') * 2.65 if Treatment == 1
summ Salary if Treatment == 3
replace Cost = (Salary / `r(sum)') * 2.65 if Treatment == 3
replace Cost = 0 if Treatment == 2

*4.3 Treatment Effects
tempfile treatmenteffects
preserve
	use "${tempdir}/SemiParEsts.dta", clear
	keep xpoints TE1 TE2 TE3 semhat1 semhat2 semhat3 semhat4 TE1_ciub TE2_ciub ///
		TE3_ciub TE1_cilb TE2_cilb TE3_cilb
	drop if xpoints == .
	ren xpoints agJuneRound
	save `treatmenteffects'
restore
gen agJuneRound = round(agJune,0.01)
merge m:1 agJuneRound using `treatmenteffects', keep(3) nogen
gen TE = TE1 if Treatment == 1
replace TE = TE2 if Treatment == 2
replace TE = TE3 if Treatment == 3
drop TE1 TE2 TE3
gen TEse = semhat1 + semhat4 if Treatment == 1
replace TEse = semhat2 + semhat4 if Treatment == 2
replace TEse = semhat3 + semhat4 if Treatment == 3
drop semhat1 semhat2 semhat3 semhat4
gen TE_cilb = TE1_cilb if Treatment == 1
replace TE_cilb = TE2_cilb if Treatment == 2
replace TE_cilb = TE3_cilb if Treatment == 3
drop TE1_cilb TE2_cilb TE3_cilb
gen TE_ciub = TE1_ciub if Treatment == 1
replace TE_ciub = TE2_ciub if Treatment == 2
replace TE_ciub = TE3_ciub if Treatment == 3
drop TE1_ciub TE2_ciub TE3_ciub
**90% CIs instead of 95%
replace TE_ciub = TE + (1.645*TEse)
replace TE_cilb = TE - (1.645*TEse)

*4.4 Calculate gross and net savings
gen saved = (ExpenditureAnalysis1516 / 1000000) * (-TE/(1+TE))
gen saved_ciub = saved + (1.96 * ((ExpenditureAnalysis1516 / 1000000) * (1/((1+TE)^2))*TEse))
*gen saved_cilb = (-ExpenditureAnalysis1516 / 1000000) * (1/((1+TE)^2)) * TE_cilb 
gen saved_cilb = saved - (1.96 * ((ExpenditureAnalysis1516 / 1000000) * (1/((1+TE)^2))*TEse))
gen netben = saved - Cost
gen netben_ciub = saved_ciub - Cost
gen netben_cilb = saved_cilb - Cost
*gen lnetben = ln(1000000*netben)
*gen lnetben_ciub = (1/(1000000*netben)) * netben_ciub
*gen lnetben_cilb = (1/(1000000*netben)) * netben_cilb
gen ror = (netben / Cost) * 100
gen ror_ciub = (netben_ciub / Cost) * 100
gen ror_cilb = (netben_cilb / Cost) * 100
sort Treatment agJune
by Treatment: gen cumBen = sum(netben)

*4.5 Draw Pictures
global colorT1 = "2 136 209"
global colorT2 = "245 124 0"
global colorT3 = "103 58 183"
sort Treatment agJune

**Cumulative net savings
graph twoway (line cumBen agJune if Treatment == 1, ///
			lcolor("gs10") lwidth(medthick) lpattern(dash)) ///
		(line cumBen agJune if Treatment == 2, ///
			lcolor("black") lwidth(medthick)) ///
		(line cumBen agJune if Treatment == 3, ///
			lcolor("gs5") lwidth(medthick) lpattern(shortdash_dot)), ///
		graphregion(color(white)) ///
		ytitle("Cumulative Net Savings (Rs Million)") ///
		xtitle("AG June Share") ///
		legend(order(2 1 3)) ///
		legend(label(1 "Incentives")) ///
		legend(label(2 "Autonomy")) ///
		legend(label(3 "Both")) ///
		legend(rows(1)) ///
		ylabel(0(2.5)10)
graph export "${picsdir}/Figure6.pdf", replace
graph export "${picsdir}/Figure6.eps", replace
