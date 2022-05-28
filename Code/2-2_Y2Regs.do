*===============================================================================*
*																				*
*		THIS DO FILE RUNS REGRESSIONS OF THE ATE IN YEAR 2						*
*																				*
*===============================================================================*

estimates clear

*1. Price on Treatment. No variety controls
reg lUnitPrice Incentives0 Rules0 Both0 NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b1
randcmd((Incentives0 Rules0 Both0) ///
	reg lUnitPrice Incentives0 Rules0 Both0 NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Rules0) reg lUnitPrice IncRules Rules0 Both0 NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice IncBoth Rules0 Both0 NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice Incentives0 RulesBoth Both0 NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : b1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b1
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b1
estadd scalar pBotAut = pEqual[6,6], replace : b1
estadd scalar pBotInc = pEqual[5,6], replace : b1
estadd local itemctrl "None" , replace : b1
estimates restore b1
estimates save "${tempdir}/Y2_Prices_NoCtrl", replace

*2. Price on Treatment. Attribute controls
reg lUnitPrice Incentives0 Rules0 Both0 ///
	NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store b2
randcmd((Incentives0 Rules0 Both0) ///
	reg lUnitPrice Incentives0 Rules0 Both0 ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Rules0) reg lUnitPrice IncRules Rules0 Both0 ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg lUnitPrice IncBoth Rules0 Both0 ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg lUnitPrice Incentives0 RulesBoth Both0 ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0)  ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : b2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b2
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b2
estadd scalar pBotAut = pEqual[6,6], replace : b2
estadd scalar pBotInc = pEqual[5,6], replace : b2
estadd local itemctrl "Attribs" , replace : b2
estimates restore b2
estimates save "${tempdir}/Y2_Prices_AttrCtrl", replace

*3. Price on Treatment. Scalar variety Control	
reg lUnitPrice Incentives0 Rules0 Both0 lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b3
randcmd((Incentives0 Rules0 Both0) ///
	reg lUnitPrice Incentives0 Rules0 Both0 ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Rules0) reg lUnitPrice IncRules Rules0 Both0 ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice IncBoth Rules0 Both0 ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice Incentives0 RulesBoth Both0 ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b3
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b3
estadd scalar pBotAut = pEqual[6,6], replace : b3
estadd scalar pBotInc = pEqual[5,6], replace : b3
estadd local itemctrl "Scalar" , replace : b3
estimates restore b3
estimates save "${tempdir}/Y2_Prices_ScalCtrl", replace

*4. Scalar Item Type on Treatment.	
reg lPriceHat Incentives0 Rules0 Both0 i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b4
randcmd((Incentives0 Rules0 Both0) ///
	reg lPriceHat Incentives0 Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Rules0) reg lPriceHat IncRules Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lPriceHat IncBoth Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lPriceHat Incentives0 RulesBoth Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b4
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b4
estadd scalar pBotAut = pEqual[6,6], replace : b4
estadd scalar pBotInc = pEqual[5,6], replace : b4
estadd local itemctrl "Scalar" , replace : b4
estimates restore b4
estimates save "${tempdir}/Y2_Variety_Scalar", replace

*5. Price on Treatment. Coarse Item Type Control	
reg lUnitPrice Incentives0 Rules0 Both0 ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b5
randcmd((Incentives0 Rules0 Both0) ///
	reg lUnitPrice Incentives0 Rules0 Both0 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Rules0) reg lUnitPrice IncRules Rules0 Both0 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice IncBoth Rules0 Both0 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg lUnitPrice Incentives0 RulesBoth Both0 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b5
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b5
estadd scalar pBotAut = pEqual[6,6], replace : b5
estadd scalar pBotInc = pEqual[5,6], replace : b5
estadd local itemctrl "Coarse" , replace : b5
estimates restore b5
estimates save "${tempdir}/Y2_Prices_CoarseCtrl", replace

*6. Coarse Item Type on Treatment.	
reg qual Incentives0 Rules0 Both0 NewItemID#c.lQuantity NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)
estimates store b6
randcmd((Incentives0 Rules0 Both0) ///
	reg qual Incentives0 Rules0 Both0 NewItemID#c.lQuantity NewItemID#i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Rules0) reg qual IncRules Rules0 Both0 NewItemID#c.lQuantity NewItemID#i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg qual IncBoth Rules0 Both0 NewItemID#c.lQuantity NewItemID#i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Both0) reg qual Incentives0 RulesBoth Both0 NewItemID#c.lQuantity NewItemID#i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b6
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b6
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b6
estadd scalar pBotAut = pEqual[6,6], replace : b6
estadd scalar pBotInc = pEqual[5,6], replace : b6
estadd local itemctrl "Coarse" , replace : b6
estimates restore b6
estimates save "${tempdir}/Y2_Variety_Coarse", replace


*7. Price on Treatment. ML controls
reg lUnitPrice Incentives0 Rules0 Both0 rf_pred_lprice NewItemID#c.lQuantity ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter) 
estimates store b7
randcmd((Incentives0 Rules0 Both0) ///
	reg lUnitPrice Incentives0 Rules0 Both0 ///
		rf_pred_lprice NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Rules0) reg lUnitPrice IncRules Rules0 Both0 ///
		rf_pred_lprice NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg lUnitPrice IncBoth Rules0 Both0 ///
		rf_pred_lprice NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg lUnitPrice Incentives0 RulesBoth Both0 ///
		rf_pred_lprice NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b7
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b7
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b7
estadd scalar pBotAut = pEqual[6,6], replace : b7
estadd scalar pBotInc = pEqual[5,6], replace : b7
estadd local itemctrl "ML" , replace : b7
estadd local thesamp "Baseline", replace: b7
estadd local wts "Old", replace: b7
estimates restore b7
estimates save "${tempdir}/Y2_Prices_MLCtrl", replace


*8. ML Item variety on lhs
reg rf_pred_lprice Incentives0 Rules0 Both0 NewItemID#c.lQuantity ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter) 
estimates store b8
randcmd((Incentives0 Rules0 Both0) ///
	reg rf_pred_lprice Incentives0 Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter)) ///
	((Rules0) reg rf_pred_lprice IncRules Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg rf_pred_lprice IncBoth Rules0 Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter)) ///
	((Both0) reg rf_pred_lprice Incentives0 RulesBoth Both0 ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncRules = Incentives0 + Rules0) ///
	calc2(replace IncBoth = Incentives0 + Both0) ///
	calc3(replace RulesBoth = Rules0 + Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b8
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b8
mat pEqual = e(RCoef)
estadd scalar pIncAut = pEqual[4,6], replace : b8
estadd scalar pBotAut = pEqual[6,6], replace : b8
estadd scalar pBotInc = pEqual[5,6], replace : b8
estadd local itemctrl "ML" , replace : b8
estimates restore b8
estimates save "${tempdir}/Y2_Variety_ML", replace
