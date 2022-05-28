
use "${rawdata}/BudgetReleases.dta", clear
tempfile treatments
preserve
	use "${usedata}/UsingData.dta", clear
	keep CostCenterCode Treatment  District
	duplicates drop
	isid CostCenterCode
	ren CostCenterCode Cost_Center
	save `treatments'
restore
merge m:1 Cost_Center using `treatments', keep(3)
gen ObjectClass = substr(GL_CODE,1,3)
keep if inlist(ObjectClass,"A03","A09","A13") //keep only "our" object codes

*3. collapse to month x cc
gen Month = mofd(Created_on)
format Month %tm
tab Month Fiscal_Year
collapse (sum) Amount, by(Month Fiscal_Year Cost_Center Treatment Department District)
drop if Month == 655 & Fiscal_Year == 2013
drop if Month == 678 & Fiscal_Year == 2015
encode Cost_Center, gen(CC_code)
drop Cost_Center
encode Department, gen(dept)
drop Department
xtset CC_code Month
tsfill, full
replace Amount = 0 if Amount == .
bys CC_code: egen dept2 = mean(dept)
replace dept = dept2 if dept == .
drop dept2
bys CC_code: egen dist2 = mean(District)
replace District = dist2 if District == .
drop dist2
bys CC_code: egen treat2 = mean(Treatment)
replace Treatment = treat2 if Treatment == .
drop treat2
bys Month: egen year2 = mean(Fiscal_Year)
replace Fiscal_Year = year2 if Fiscal_Year == .
drop year2

*4. plot monthly amounts pictures

global colorT1 = "gs10"
global colorT2 = "black"
global colorT3 = "gs5"
global colorT4 = "black"


*5. Budget So Far pictures
bys CC_code Fiscal_Year: egen TotBudget = total(Amount)
gen ShareMonth = Amount / TotBudget
bys CC_code Fiscal_Year (Month): gen BudgetSoFar = sum(Amount)
replace BudgetSoFar = BudgetSoFar / TotBudget 
sum ShareMonth
sum BudgetSoFar

preserve
	collapse (mean) BudgetSoFar, by(Month Treatment Fiscal_Year)
	twoway (line BudgetSoFar Month if Treatment == 4 & Fiscal_Year == 2013, lcolor("${colorT4}") lpattern(dot)) ///
		(line BudgetSoFar Month if Treatment == 1 & Fiscal_Year == 2013, lcolor("${colorT1}") lpattern(dash)) ///
		(line BudgetSoFar Month if Treatment == 2 & Fiscal_Year == 2013, lcolor("${colorT2}")) ///
		(line BudgetSoFar Month if Treatment == 3 & Fiscal_Year == 2013, lcolor("${colorT3}") lpattern(shortdash_dot)) ///
		(line BudgetSoFar Month if Treatment == 4 & Fiscal_Year == 2014, lcolor("${colorT4}") lpattern(dot)) ///
		(line BudgetSoFar Month if Treatment == 1 & Fiscal_Year == 2014, lcolor("${colorT1}") lpattern(dash)) ///
		(line BudgetSoFar Month if Treatment == 2 & Fiscal_Year == 2014, lcolor("${colorT2}")) ///
		(line BudgetSoFar Month if Treatment == 3 & Fiscal_Year == 2014, lcolor("${colorT3}") lpattern(shortdash_dot)) ///
		(line BudgetSoFar Month if Treatment == 4 & Fiscal_Year == 2015, lcolor("${colorT4}") lpattern(dot)) ///
		(line BudgetSoFar Month if Treatment == 1 & Fiscal_Year == 2015, lcolor("${colorT1}") lpattern(dash)) ///
		(line BudgetSoFar Month if Treatment == 2 & Fiscal_Year == 2015, lcolor("${colorT2}")) ///
		(line BudgetSoFar Month if Treatment == 3 & Fiscal_Year == 2015, lcolor("${colorT3}") lpattern(shortdash_dot)) ///
		(line BudgetSoFar Month if Treatment == 4 & Fiscal_Year == 2016, lcolor("${colorT4}") lpattern(dot)) ///
		(line BudgetSoFar Month if Treatment == 1 & Fiscal_Year == 2016, lcolor("${colorT1}") lpattern(dash)) ///
		(line BudgetSoFar Month if Treatment == 2 & Fiscal_Year == 2016, lcolor("${colorT2}")) ///
		(line BudgetSoFar Month if Treatment == 3 & Fiscal_Year == 2016, lcolor("${colorT3}") lpattern(shortdash_dot)) ///
		(line BudgetSoFar Month if Treatment == 4 & Fiscal_Year == 2017, lcolor("${colorT4}") lpattern(dot)) ///
		(line BudgetSoFar Month if Treatment == 1 & Fiscal_Year == 2017, lcolor("${colorT1}") lpattern(dash)) ///
		(line BudgetSoFar Month if Treatment == 2 & Fiscal_Year == 2017, lcolor("${colorT2}")) ///
		(line BudgetSoFar Month if Treatment == 3 & Fiscal_Year == 2017, lcolor("${colorT3}") lpattern(shortdash_dot)) ///
		(pcarrowi 0.01 666 0.01 677, color(gs6)) ///
		(pcarrowi 0.01 677 0.01 666, color(gs6)), ///
		legend(label(1 "Control")) ///
		legend(label(2 "Incentives")) ///
		legend(label(3 "Autonomy")) ///
		legend(label(4 "Both")) ///
		legend(order(1 3 2 4)) ///
		legend(rows(1)) ///
		graphregion(color(white)) ///
		xlabel(642(6)702, format(%tmy/n) grid) ///
		xline(653.5 665.5 677.5 689.5 701.5, lcolor(gs6)) ///
		ytitle("Share of Budget So Far This Year") ///
		text(0.04 671.5 "Treatment Year", color(gs6) size(small))
		graph export "${picsdir}/FigureA4A.pdf", replace
		graph export "${picsdir}/FigureA4A.eps", replace
restore

gen calmonth = month(dofm(Month))
forvalues m = 1/12 {
	forvalues t = 1/3 {
		gen T`t'_M`m'_P = (Treatment == `t' & calmonth == `m' & Fiscal_Year == 2015)
	}
}

*Do DD and get coefficients
gen PostTreat1 = (Fiscal_Year == 2015 & Treatment == 1)
gen PostTreat2 = (Fiscal_Year == 2015 & Treatment == 2)
gen PostTreat3 = (Fiscal_Year == 2015 & Treatment == 3)
areg BudgetSoFar PostTreat* ibn.Month, absorb(CC_code)
global T1Text = "Incentives DD: " + string(_b[PostTreat1],"%9.3f") + " (" + string(_se[PostTreat1],"%9.4f") + ")"
global T2Text = "Autonomy DD: " + string(_b[PostTreat2],"%9.3f") + " (" + string(_se[PostTreat2],"%9.4f") + ")"
global T3Text = "Both DD: " + string(_b[PostTreat3],"%9.3f") + " (" + string(_se[PostTreat3],"%9.4f") + ")"

*Do monthly regression
areg BudgetSoFar T*_M*_P ibn.Month, absorb(CC_code)

*Draw picture
regsave T*_M*_P, ci
split var, parse("_")
ren var1 Treatment
ren var2 Month
destring Month, replace ignore("M")
replace Month = Month + 12 if Month < 7
replace Month = Month - 0.2 if Treatment == "T2"
replace Month = Month + 0.2 if Treatment == "T3"
sort Treatment Month
twoway (rcap ci_upper ci_lower Month if Treatment == "T1", lcolor("${colorT1}%50")) ///
	(rcap ci_upper ci_lower Month if Treatment == "T3", color("${colorT3}%50")) ///
	(rcap ci_upper ci_lower Month if Treatment == "T2", color("${colorT2}%50")) ///
	(scatter coef Month if Treatment == "T1", mcolor("${colorT1}") msymbol(s)) ///
	(scatter coef Month if Treatment == "T3", mcolor("${colorT3}") msymbol(d)) ///
	(scatter coef Month if Treatment == "T2", mcolor("${colorT2}")), ///
	graphregion(color(white)) ///
	xlabel(7 "Jul" 8 "Aug" 9 "Sep" 10 "Oct" 11 "Nov" 12 "Dec" 13 "Jan" 14 "Feb" 15 "Mar" 16 "Apr" 17 "May" 18 "Jun") ///
	xtitle("") ///
	yline(0, lcolor(gs6)) ///
	text(.155 11.5 "${T2Text}", placement(w)) ///
	text(.135 11.5 "${T1Text}", placement(w)) ///
	text(.115 11.5 "${T3Text}", placement(w)) ///
	legend(order(6 4 5)) ///
	legend(label(6 "Autonomy")) ///
	legend(label(4 "Incentives")) ///
	legend(label(5 "Both")) ///
	legend(rows(1))
graph export "${picsdir}/FigureA4B.pdf", replace
graph export "${picsdir}/FigureA4B.eps", replace
