	global name: variable label ${v}
	*Regression
	reg ${v} ib4.Treatment, robust
	forvalues t = 1/3 {
		global coef`t' = _b[`t'.Treatment]
		global se`t' = _se[`t'.Treatment]
		matrix A = r(table)
		global p`t' = A[4,`t']
		if ${p`t'} < 0.01 {
			global sestars`t' = "$^{***}$"
		}
		else if ${p`t'} < 0.05 {
			global sestars`t' = "$^{**}$"
		}
		else if ${p`t'} < 0.1 {
			global sestars`t' = "$^{*}$"
		}
		else {
			global sestars`t' = " "
		}
	}
	*Joint Test
	test 1.Treatment 2.Treatment 3.Treatment
	global F = `r(F)'
	global Fp = `r(p)'
	if ${Fp} < 0.01 {
		global starsFp = "$^{***}$"
	}
	else if ${Fp} < 0.05 {
		global starsFp = "$^{**}$"
	}
	else if ${Fp} < 0.1 {
		global starsFp = "$^{*}$"
	}
	else {
		global starsFp = " "
	}
	*RI
	randcmd((Incentives Autonomy Both) ///
	reg ${v} Incentives Autonomy Both, robust), ///
	treatvars(Incentives Autonomy Both) ///
	reps(${RIreps}) ///
	seed(${seed})
	matrix pRI = e(RCoef)
	forvalues t = 1/3 {
		global pRI`t' = pRI[`t',6]
		if ${pRI`t'} < 0.01 {
			global sestarsRI`t' = "$^{***}$"
		}
		else if ${pRI`t'} < 0.05 {
			global sestarsRI`t' = "$^{**}$"
		}
		else if ${pRI`t'} < 0.1 {
			global sestarsRI`t' = "$^{*}$"
		}
		else {
			global sestarsRI`t' = " "
		}
	}
	matrix pRIEqn = e(REqn)
	global FpRI = pRIEqn[1,6]
	if ${FpRI} < 0.01 {
		global starsFpRI = "$^{***}$"
	}
	else if ${FpRI} < 0.05 {
		global starsFpRI = "$^{**}$"
	}
	else if ${FpRI} < 0.1 {
		global starsFpRI = "$^{*}$"
	}
	else {
		global starsFpRI = " "
	}
	*Control group
	summ ${v} if Treatment == 4
	global Cmean = `r(mean)'
	global Csd = `r(sd)'
	summ ${v}
	global NObs = `r(N)'
