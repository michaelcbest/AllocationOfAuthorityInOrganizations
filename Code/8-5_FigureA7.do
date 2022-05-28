
*Our data for the treated guys
tempfile ourdata
use "${usedata}/UsingData.dta", clear
keep CostCenterCode Treatment
duplicates drop
isid CostCenterCode
save `ourdata'

*BER data has all the cost centers in it
tempfile treatmentshares
use "${rawdata}/BudgetExpenditureReport.dta", clear
keep Cost_center Districts
ren Cost_center CostCenterCode
duplicates drop
merge m:1 CostCenterCode using `ourdata'
gen AutonomyShare = inlist(Treatment,2,3)
collapse (mean) AutonomyShare, by(Districts)
save `treatmentshares'

use "${usedata}/UsingData.dta", clear

decode District, gen(Districts)
merge m:1 Districts using `treatmentshares', keep(3) assert(2 3) nogen


/***************************************\
*	2. DO THE DID AND MAKE TABLE/FIGS	*
\***************************************/

keep if Treatment == 4 //look within the control group
summ AutonomyShare
gen Interact = Year2 * ((AutonomyShare - `r(min)')/(`r(max)' - `r(min)'))
summ Interact

*3. Scalar Control	
areg lUnitPrice Year2 Interact ///
	lPriceHat i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CCID)
estimates store b3
estadd local itemctrl "Scalar" , replace : b3
global DD_coef = _b[Interact]
global DD_se = _se[Interact]
global DD_text = "{&beta}{subscript:DD} = " + string(${DD_coef},"%9.2f") + " (" + string(${DD_se},"%9.3f") + ")"

	
*Less parametrically
levelsof AutonomyShare, local(shares)
gen counter = _n
gen Share = .
gen Est = .
gen SE = .

local c = 1
foreach s in `shares' {
	reg lUnitPrice Year2 lPriceHat i.NewItemID NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl] if AutonomyShare > `s' - .01 & AutonomyShare < `s' + .01, cl(CCID)
	replace Share = `s' if counter == `c'
	replace Est = _b[Year2] if counter == `c'
	replace SE = _se[Year2] if counter == `c'
	local c = `c' + 1
}
gen CIUB = Est + (1.96 * SE)
gen CILB = Est - (1.96 * SE)
tempfile frequencies
preserve
	collapse (count) freq = lUnitPrice, by(AutonomyShare)
	ren AutonomyShare DistAutonomyShare
	save `frequencies'
restore
merge 1:1 _n using `frequencies'

global colorT4 = "black"
twoway (histogram AutonomyShare, color(gs13)) ///
		(rcap CIUB CILB Share, color("${colorT4}%30") yaxis(2)) ///
		(connected Est Share, color("${colorT4}") yaxis(2)), ///
		graphregion(color(white)) ///
		xtitle("Share of Offices Treated With Autonomy") ///
		ytitle("Control Group's Year-2 Price Increase", axis(2)) ///
		ytitle("Frequency", axis(1)) ///
		legend(off) ///
		text(80 .065 "${DD_text}")
graph export "${picsdir}/FigureA7.pdf", replace
graph export "${picsdir}/FigureA7.eps", replace
