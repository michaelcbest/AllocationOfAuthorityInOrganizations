
global ciLevel = 90

*Load the data
use "${usedata}/UsingData.dta", clear
keep if Fiscal_Year == "2015-16"


* Run the quantile regressions

*gen lpratio=lUnitPrice/lPriceHat
forvalues q = 5(5)95 {
	capture noisily qreg lUnitPrice Incentives0 Rules0 Both0 NewItemID#c.lQuantity ///
		i.NewItemID NCC i.strata lPriceHat [pweight=ExpInCtrl], ///
			vce(robust) ///
			quantile(`q') ///
			iterate(10000)
	capture noisily regsave Incentives0 Rules0 Both0 using "${tempdir}/QTE_q`q'.dta", ci replace
} 

*Put all the results into pictures
use "${tempdir}/QTE_q5.dta", clear
gen Quantile = 5
forvalues q = 10(5)95 {
	append using "${tempdir}/QTE_q`q'.dta"
	replace Quantile = `q' if Quantile == .
}
twoway (rarea ci_upper ci_lower Quantile if var == "Incentives0", ///
			color(gs13%50)) ///
	(line coef Quantile if var == "Incentives0", ///
		color("black") ///
		lwidth(medthick)), ///
	graphregion(color(white)) ///
	legend(off) ///
	xtitle("Percentile") ///
	ytitle("Treatment Effect") ///
	ylabel(-0.15(.025).05) ///
	xlabel(0(10)100, grid) ///
	ysc(r(-0.1513)) ///
	yline(0, lcolor(black) lwidth(medium))
graph export "${picsdir}/Figure10B.pdf", replace
graph export "${picsdir}/Figure10B.eps", replace
twoway (rarea ci_upper ci_lower Quantile if var == "Rules0", ///
			color(gs13%50)) ///
	(line coef Quantile if var == "Rules0", ///
		color("black") ///
		lwidth(medthick)), ///
	graphregion(color(white)) ///
	legend(off) ///
	xtitle("Percentile") ///
	ytitle("Treatment Effect") ///
	ylabel(-0.15(.025).05) ///
	xlabel(0(10)100, grid) ///
	ysc(r(-0.1513)) ///
	yline(0, lcolor(black) lwidth(medium))
graph export "${picsdir}/Figure10A.pdf", replace
graph export "${picsdir}/Figure10A.eps", replace
twoway (rarea ci_upper ci_lower Quantile if var == "Both0", ///
			color(gs13%50)) ///
	(line coef Quantile if var == "Both0", ///
		color("black") ///
		lwidth(medthick)), ///
	graphregion(color(white)) ///
	legend(off) ///
	xtitle("Percentile") ///
	ytitle("Treatment Effect") ///
	ylabel(-0.15(.025).05) ///
	xlabel(0(10)100, grid) ///
	ysc(r(-0.1513)) ///
	yline(0, lcolor(black) lwidth(medium))
graph export "${picsdir}/Figure10C.pdf", replace
graph export "${picsdir}/Figure10C.eps", replace
