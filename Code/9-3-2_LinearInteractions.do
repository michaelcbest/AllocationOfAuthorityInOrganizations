*1. Load the Data
use "${usedata}/UsingData.dta", clear
drop if time > date("01Jul2016","DMY") /*outliers that mess up the pics*/
keep if Fiscal_Year == "2015-16"

merge m:1 OfficeID using "${tempdir}/BudgetShares.dta", ///
	keep(1 3) ///
	nogen

ren Rules0 Autonomy0

*2. Build the Interactions
foreach y in "1415" "1516" {
	gen IIncBUniverse`y' = bShareUniverse`y' * Incentives0
	gen IAutBUniverse`y' = bShareUniverse`y' * Autonomy0
	gen IBotBUniverse`y' = bShareUniverse`y' * Both0
}

*3. Run the regressions
estimates clear
*3.1. One-at-a-time
foreach y in "1415" "1516" {

	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' ///
		IBotBUniverse`y' NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) 
	estimates store regUniverse`y'_none

	randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y') ///
		reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y' ///
			NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
			[aweight=ExpInCtrl] , cl(CostCenter)), ///
		treatvars(Incentives0 Autonomy0 Both0) ///
		calc1(replace IIncBUniverse`y' = bShareUniverse`y' * Incentives0) ///
		calc2(replace IAutBUniverse`y' = bShareUniverse`y' * Autonomy0) ///
		calc3(replace IBotBUniverse`y' = bShareUniverse`y' * Both0) ///
		strata(strata) ///
		groupvar(CostCenter) ///
		reps(${RIreps}) ///
		seed(${seed})
	mat pRI = e(RCoef)
	mat pRI = pRI[1..6,6]
	matrix rownames pRI = _:
	matrix pRI = pRI'
	estadd matrix pRI , replace : regUniverse`y'_none
	mat pAll = e(REqn)
	estadd scalar pAll = pAll[1,6], replace : regUniverse`y'_none
	estadd local itemctrl "None" , replace : regUniverse`y'_none
	estimates restore regUniverse`y'_none
	estimates save "${tempdir}/TableE4_Universe`y'_none", replace


	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' ///
		IBotBUniverse`y' NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC ///
		i.strata [aweight=ExpInCtrl], cl(CostCenter)
	estimates store regUniverse`y'_attr

	randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y') ///
		reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y'  ///
			NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC ///
			i.strata [aweight=ExpInCtrl], cl(CostCenter)), ///
		treatvars(Incentives0 Autonomy0 Both0) ///
		calc1(replace IIncBUniverse`y' = bShareUniverse`y' * Incentives0) ///
		calc2(replace IAutBUniverse`y' = bShareUniverse`y' * Autonomy0) ///
		calc3(replace IBotBUniverse`y' = bShareUniverse`y' * Both0) ///
		strata(strata) ///
		groupvar(CostCenter) ///
		reps(${RIreps}) ///
		seed(${seed})
	mat pRI = e(RCoef)
	mat pRI = pRI[1..6,6]
	matrix rownames pRI = _:
	matrix pRI = pRI'
	estadd matrix pRI , replace : regUniverse`y'_attr
	mat pAll = e(REqn)
	estadd scalar pAll = pAll[1,6], replace : regUniverse`y'_attr
	estadd local itemctrl "Attribs" , replace : regUniverse`y'_attr
	estimates restore regUniverse`y'_attr
	estimates save "${tempdir}/TableE4_Universe`y'_attr", replace

	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' ///
		IBotBUniverse`y' lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) 
	estimates store regUniverse`y'_scal

	randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y') ///
		reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y'  ///
			lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
			[aweight=ExpInCtrl] , cl(CostCenter) ), ///
		treatvars(Incentives0 Autonomy0 Both0) ///
		calc1(replace IIncBUniverse`y' = bShareUniverse`y' * Incentives0) ///
		calc2(replace IAutBUniverse`y' = bShareUniverse`y' * Autonomy0) ///
		calc3(replace IBotBUniverse`y' = bShareUniverse`y' * Both0) ///
		strata(strata) ///
		groupvar(CostCenter) ///
		reps(${RIreps}) ///
		seed(${seed})
	mat pRI = e(RCoef)
	mat pRI = pRI[1..6,6]
	matrix rownames pRI = _:
	matrix pRI = pRI'
	estadd matrix pRI , replace : regUniverse`y'_scal
	mat pAll = e(REqn)
	estadd scalar pAll = pAll[1,6], replace : regUniverse`y'_scal
	estadd local itemctrl "Scalar" , replace : regUniverse`y'_scal
	estimates restore regUniverse`y'_scal
	estimates save "${tempdir}/TableE4_Universe`y'_scal", replace

	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' ///
		IBotBUniverse`y' NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
	estimates store regUniverse`y'_cors

	randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y') ///
		reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse`y' IAutBUniverse`y' IBotBUniverse`y' ///
			NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
		treatvars(Incentives0 Autonomy0 Both0) ///
		calc1(replace IIncBUniverse`y' = bShareUniverse`y' * Incentives0) ///
		calc2(replace IAutBUniverse`y' = bShareUniverse`y' * Autonomy0) ///
		calc3(replace IBotBUniverse`y' = bShareUniverse`y' * Both0) ///
		strata(strata) ///
		groupvar(CostCenter) ///
		reps(${RIreps}) ///
		seed(${seed})
	mat pRI = e(RCoef)
	mat pRI = pRI[1..6,6]
	matrix rownames pRI = _:
	matrix pRI = pRI'
	estadd matrix pRI , replace : regUniverse`y'_cors
	mat pAll = e(REqn)
	estadd scalar pAll = pAll[1,6], replace : regUniverse`y'_cors
	estadd local itemctrl "Coarse" , replace : regUniverse`y'_cors
	estimates restore regUniverse`y'_cors
	estimates save "${tempdir}/TableE4_Universe`y'_cors", replace
	
}

*3.2. both years together

reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
	IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
	NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store regUniverse_none

randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516) ///
	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
		IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
		NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Autonomy0 Both0) ///
	calc1(replace IIncBUniverse1415 = bShareUniverse1415 * Incentives0) ///
	calc2(replace IAutBUniverse1415 = bShareUniverse1415 * Autonomy0) ///
	calc3(replace IBotBUniverse1415 = bShareUniverse1415 * Both0) ///
	calc4(replace IIncBUniverse1516 = bShareUniverse1516 * Incentives0) ///
	calc5(replace IAutBUniverse1516 = bShareUniverse1516 * Autonomy0) ///
	calc6(replace IBotBUniverse1516 = bShareUniverse1516 * Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : regUniverse_none
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : regUniverse_none
estadd local itemctrl "None" , replace : regUniverse_none
estimates restore regUniverse_none
estimates save "${tempdir}/TableE4_Universe_none", replace


reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
	IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
	NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC ///
	i.strata [aweight=ExpInCtrl], cl(CostCenter)
estimates store regUniverse_attr

randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516) ///
	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
		IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC ///
		i.strata [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Autonomy0 Both0) ///
	calc1(replace IIncBUniverse1415 = bShareUniverse1415 * Incentives0) ///
	calc2(replace IAutBUniverse1415 = bShareUniverse1415 * Autonomy0) ///
	calc3(replace IBotBUniverse1415 = bShareUniverse1415 * Both0) ///
	calc4(replace IIncBUniverse1516 = bShareUniverse1516 * Incentives0) ///
	calc5(replace IAutBUniverse1516 = bShareUniverse1516 * Autonomy0) ///
	calc6(replace IBotBUniverse1516 = bShareUniverse1516 * Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : regUniverse_attr
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : regUniverse_attr
estadd local itemctrl "Attribs" , replace : regUniverse_attr
estimates restore regUniverse_attr
estimates save "${tempdir}/TableE4_Universe_attr", replace

reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
	IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
	lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store regUniverse_scal

randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516) ///
	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
		IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) ), ///
	treatvars(Incentives0 Autonomy0 Both0) ///
	calc1(replace IIncBUniverse1415 = bShareUniverse1415 * Incentives0) ///
	calc2(replace IAutBUniverse1415 = bShareUniverse1415 * Autonomy0) ///
	calc3(replace IBotBUniverse1415 = bShareUniverse1415 * Both0) ///
	calc4(replace IIncBUniverse1516 = bShareUniverse1516 * Incentives0) ///
	calc5(replace IAutBUniverse1516 = bShareUniverse1516 * Autonomy0) ///
	calc6(replace IBotBUniverse1516 = bShareUniverse1516 * Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : regUniverse_scal
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : regUniverse_scal
estadd local itemctrl "Scalar" , replace : regUniverse_scal
estimates restore regUniverse_scal
estimates save "${tempdir}/TableE4_Universe_scal", replace

reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
	IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store regUniverse_cors

randcmd((Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516) ///
	reg lUnitPrice Incentives0 Autonomy0 Both0 IIncBUniverse1415 IAutBUniverse1415 ///
		IBotBUniverse1415 IIncBUniverse1516 IAutBUniverse1516 IBotBUniverse1516 ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Autonomy0 Both0) ///
	calc1(replace IIncBUniverse1415 = bShareUniverse1415 * Incentives0) ///
	calc2(replace IAutBUniverse1415 = bShareUniverse1415 * Autonomy0) ///
	calc3(replace IBotBUniverse1415 = bShareUniverse1415 * Both0) ///
	calc4(replace IIncBUniverse1516 = bShareUniverse1516 * Incentives0) ///
	calc5(replace IAutBUniverse1516 = bShareUniverse1516 * Autonomy0) ///
	calc6(replace IBotBUniverse1516 = bShareUniverse1516 * Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : regUniverse_cors
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : regUniverse_cors
estadd local itemctrl "Coarse" , replace : regUniverse_cors
estimates restore regUniverse_cors
estimates save "${tempdir}/TableE4_Universe_cors", replace
