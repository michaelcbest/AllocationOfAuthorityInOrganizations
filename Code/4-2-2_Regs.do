

*0. Benchmark: Treatment effects linear in agJune
reg lUnitPrice Incentives0 Rules0 Both0 ///
	InteractIncentives InteractAutonomy InteractBoth ///
	${rhs} [aweight=ExpInCtrl], cl(CostCenter) noc

qui gen LinTE1 = _b[Incentives0] + (xpoints * _b[InteractIncentives])
qui gen LinTE2 = _b[Rules0] + (xpoints * _b[InteractAutonomy])
qui gen LinTE3 = _b[Both0] + (xpoints * _b[InteractBoth])

*1. get expectations conditional on agJune and Treatment
**price. nonparametric.
forvalues t = 1/4 {
	di "Non parametric regression of price on agJune in treatment group `t'"
	qui npregress kernel lUnitPrice agJune if Treatment == `t', ///
		estimator(constant) ///
		predict(yhat`t') ///
		noderivatives
}
qui gen yhat = lUnitPrice
forvalues t = 1/4 {
	qui replace yhat = yhat - yhat`t' if Treatment == `t'
}
**RHS
global rhsresids = ""
foreach v of varlist $rhs {
	di "Linear regression of `v' on Treatment dummies and interactions with agJune"
	qui reg `v' Incentives0 Rules0 Both0 agJune InteractIncentives InteractAutonomy InteractBoth
	qui predict `v'Hat, residuals
	global rhsresids = "${rhsresids}" + "`v'Hat "
}

*2. OLS of y - E[y|Z,T] on X - E[X|Z,T]
qui reg yhat ${rhsresids} [aweight=ExpInCtrl], cl(CostCenter)

*3. regress y - X \^theta on Z and T
**make y - X \^theta
qui gen yres = lUnitPrice
foreach v of varlist $rhs {
	di "make X \^theta for variable `v'"
	qui gen `v'Theta = `v' * _b[`v'Hat]
	qui replace yres = yres - `v'Theta
}
**regressions
forvalues t = 1/4 {
	qui lpoly yres agJune if Treatment == `t' [aweight=ExpInCtrl], ///
		gen(mhat`t') at(xpoints) se(semhat`t') nograph degree(0) bwidth(0.07)
}

*4. Treatment effect functions
forvalues t = 1/3 {
	qui gen TE`t' = mhat`t' - mhat4
	qui gen TE`t'_ciub = TE`t' + (1.96 * (semhat`t' + semhat4))
	qui gen TE`t'_cilb = TE`t' - (1.96 * (semhat`t' + semhat4))
}

qui gen BdA = mhat3 - mhat2
qui gen BdA_ciub = BdA + (1.96 * (semhat3 + semhat2))
qui gen BdA_cilb = BdA - (1.96 * (semhat3 + semhat2))

qui gen BdI = mhat3 - mhat1
qui gen BdI_ciub = BdI + (1.96 * (semhat3 + semhat1))
qui gen BdI_cilb = BdI - (1.96 * (semhat3 + semhat1))

qui gen AdI = mhat2 - mhat1
qui gen AdI_ciub = AdI + (1.96 * (semhat1 + semhat2))
qui gen AdI_cilb = AdI - (1.96 * (semhat1 + semhat2))

*Save the estimates
*keep xpoints-LinTE3 mhat1-AdI_cilb
*drop if xpoints == .
compress
save "${tempdir}/SemiParEsts.dta", replace

