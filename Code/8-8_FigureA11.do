use "${usedata}/UsingData.dta", clear
	
drop if time > date("01Jul2016","DMY") /*outliers that mess up the pics*/
keep if Fiscal_Year == "2014-15"
merge 1:1 RequestID DeliveryID using  "${rawdata}/DiceGameData.dta", ///
	keep(1 3) nogen
keep if inlist(Treatment,2,4)

*Distribution of Dice Scores in this subsample
preserve
	keep OfficeID DiceScoreOffice
	duplicates drop 
	isid OfficeID
	drop if DiceScoreOffice == .
	merge 1:1 _n using "${rawdata}/FairDiceTotalDistribution.dta", nogen
	replace FairProb = FairProb / 100
	twoway (histogram DiceScoreOffice, frac discrete color(gs13)) ///
		(line FairProb Total if Total > 115 & Total < 232, lcolor(black) lpattern(dash)) ///
		(kdensity DiceScoreOffice, lcolor(black) lwidth(medthick)), ///
			xlabel(125(25)225) ///
			xtitle("Dice Score") ///
			legend(label(1 "Data")) ///
			legend(label(2 "Theoretical Density")) ///
			legend(label(3 "Kernel Density")) ///
			legend(order(2 1 3)) ///
			legend(cols(3)) ///
			graphregion(color(white))
	graph export "${picsdir}/FigureA11A.pdf", replace
	graph export "${picsdir}/FigureA11A.eps", replace
restore
	
	
*SET UP THINGS FOR ROBINSON NONPARAMETRICS
ren lPriceHat ScalarItemType //Can't have "Hat" in the variable name, it'll get dropped

**RHS
global rhsbasic = "NCCs "

**Good dummies and good-specific quantity
foreach i in $items {
	gen i`i' = (NewItemID == `i')
	gen lQ`i' = i`i' * lQuantity
	global rhsbasic = "${rhsbasic}" + "i`i' lQ`i' " 
}

**randomization strata
tab strata, gen(st) //generates 61 stratum dummies.
return list
forvalues s = 2/61 {
	global rhsbasic = "${rhsbasic}" + "st`s' "
}

**POINTS TO FORM PREDICTIONS AT
gen xpoints = .
summ DiceScoreOffice, det
replace xpoints = `r(p5)' + (((_n-1)/100) * (`r(p95)' - `r(p5)') ) in 1/101
summ xpoints

*===========*
*ESTIMATE	*
*===========*

**semipar Robinson (1988)

***1. get expectations conditional on Dice Game Score
di "Non parametric regression of price on Dice Score"
qui npregress kernel lUnitPrice DiceScoreOffice, ///
	estimator(constant) ///
	predict(yhatpred) ///
	noderivatives
qui gen yhat = lUnitPrice
qui replace yhat = yhat - yhatpred

****RHS
global rhsresids = ""
global rhs = "${rhsbasic}" + "ScalarItemType "
foreach v of varlist $rhs {
	di "Linear regression of `v' on Dice Score"
	qui reg `v' DiceScoreOffice
	qui predict `v'Hat, residuals
	global rhsresids = "${rhsresids}" + "`v'Hat "
}

***2. OLS of y - E[y|Z,T] on X - E[X|Z,T]
qui reg yhat ${rhsresids} [aweight=ExpInCtrl], cl(CostCenter)

***3. regress y - X \^theta on Z and T
*****make y - X \^theta
qui gen yres = lUnitPrice
foreach v of varlist $rhs {
	di "make X \^theta for variable `v'"
	qui gen `v'Theta = `v' * _b[`v'Hat]
	qui replace yres = yres - `v'Theta
}
****regression
qui lpoly yres DiceScoreOffice [aweight=ExpInCtrl], ///
gen(pred_scalar) at(xpoints) se(sepred_scalar) nograph degree(0)
summ pred_scalar
replace pred_scalar = pred_scalar - `r(mean)'

***4. Pictures of the results
gen ciub_scalar = pred_scalar + (1.96 * sepred_scalar)
gen cilb_scalar = pred_scalar - (1.96 * sepred_scalar)

		
twoway (rarea ciub_scalar cilb_scalar xpoints, color(gs14)) ///
	(line pred_scalar xpoints, color(black)), ///
		graphregion(color(white)) ///
		xtitle("Dice Score") ///
		ytitle("Average Residual Price") ///
		legend(off) ///
		xlabel(125(25)225)
graph export "${picsdir}/FigureA11B.pdf", replace
graph export "${picsdir}/FigureA11B.eps", replace
