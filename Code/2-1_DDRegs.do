estimates clear
xtset CCID
//generate interactions of treatments with year 2
gen IncentivesY2 = Incentives0 * Year2
gen AutonomyY2 = Rules0 * Year2
gen BothY2 = Both0 * Year2
gen AutBothY2 = AutonomyY2 + BothY2

*1. Price on Treatment. No quality controls
xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)
estimates store b1
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutBothY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b1
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b1
estadd local itemctrl "None" , replace : b1
estimates restore b1
estimates save "${tempdir}/DD_Prices_NoCtrl", replace
	
*2. Price on Treatment. Attribute controls
timer on 1
xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
	NewItemID#c.lQuantity i.NewItemID $ivarsareg $nvars NewItemID#c.time ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)
estimates store b2
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID $ivarsareg $nvars NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutBothY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID $ivarsareg $nvars NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
timer off 1
timer list 1
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b2
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b2
estadd local itemctrl "Attribs" , replace : b2
estimates restore b2
estimates save "${tempdir}/DD_Prices_AttrCtrl", replace

*3. Price on Treatment. Scalar  Control	
xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
	lPriceHat i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CCID)
estimates store b3
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		lPriceHat i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutBothY2 BothY2 Year2 ///
		lPriceHat i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b3
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b3
estadd local itemctrl "Scalar" , replace : b3
estimates restore b3
estimates save "${tempdir}/DD_Prices_ScalCtrl", replace

*4. Scalar Item Variety on Treatment.	
xi:areg lPriceHat IncentivesY2 AutonomyY2 BothY2 Year2 ///
	 NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)
estimates store b4
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lPriceHat IncentivesY2 AutonomyY2 BothY2 Year2 ///
		 NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lPriceHat IncentivesY2 AutBothY2 BothY2 Year2 ///
		 NewItemID#c.lQuantity i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b4
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b4
estadd local itemctrl "Scalar" , replace : b4
estimates restore b4
estimates save "${tempdir}/DD_Variety_Scalar", replace

*5. Price on Treatment. Coarse variety controls
xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NewItemID#c.time ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)
estimates store b5
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutBothY2 BothY2 Year2 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b5
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b5
estadd local itemctrl "Coarse" , replace : b5
estimates restore b5
estimates save "${tempdir}/DD_Prices_CoarseCtrl", replace

*6. Coarse variety on Treatment.	
xi:areg qual IncentivesY2 AutonomyY2 BothY2 Year2 ///
	NewItemID#c.lQuantity i.NewItemID NewItemID#i.sizeL NewItemID#c.time ///
	[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)
estimates store b6
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg qual IncentivesY2 AutonomyY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID NewItemID#i.sizeL NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg qual IncentivesY2 AutBothY2 BothY2 Year2 ///
		NewItemID#c.lQuantity i.NewItemID NewItemID#i.sizeL NewItemID#c.time ///
		[aweight=ExpInCtrl] , a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b6
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b6
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b6
estadd local itemctrl "Coarse" , replace : b6
estimates restore b6
estimates save "${tempdir}/DD_Variety_Coarse", replace


*1. Price on Treatment. ML controls
xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
	rf_pred_lprice i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
	[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)
estimates store b7
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		rf_pred_lprice i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg lUnitPrice IncentivesY2 AutBothY2 BothY2 Year2 ///
		rf_pred_lprice i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b7
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b7
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b7
estadd local itemctrl "ML" , replace : b7
estadd local thesamp "Baseline", replace: b7
estadd local wts "Old", replace: b7
estimates restore b7
estimates save "${tempdir}/DD_Prices_MLCtrl", replace


*19. ML variety on treatment
xi:areg rf_pred_lprice IncentivesY2 AutonomyY2 BothY2 Year2 ///
	 i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
	[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)
estimates store b8
randcmd ((IncentivesY2 AutonomyY2 BothY2) ///
	xi:areg rf_pred_lprice IncentivesY2 AutonomyY2 BothY2 Year2 ///
		i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)) ///
	((BothY2) ///
	xi:areg rf_pred_lprice IncentivesY2 AutBothY2 BothY2 Year2 ///
		i.NewItemID NewItemID#c.time NewItemID#c.lQuantity ///
		[aweight=ExpInCtrl], a(CostCenterCode) cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncentivesY2 = Incentives0 * Year2) ///
	calc2(replace AutonomyY2 = Rules0 * Year2) ///
	calc3(replace BothY2 = Both0 * Year2) ///
	calc4(replace AutBothY2 = AutonomyY2 + BothY2) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1..3,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI : b8
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b8
mat pEqual = e(RCoef)
estadd scalar pAutBot = pEqual[4,6], replace : b8
estadd local itemctrl "ML" , replace : b8
estadd local thesamp "Baseline", replace: b8
estadd local wts "Old", replace: b8
estimates restore b8
estimates save "${tempdir}/DD_Variety_ML", replace
