
/*******************\
*	Build the RHS	*
\*******************/
									
global nvars = ""
global ivars = ""
global ivarsareg = ""
foreach item in $items {
  use "${tempdir}/RegAttributes_Item`item'.dta", clear
  local nvarsitem = RegNVars
  global nvars_It`item' = ""
  foreach var in `nvarsitem' {
    global nvars = "${nvars}" + " " + "`var'_It`item'"
	global nvars_It`item' = "${nvars_It`item'}" + " " + "`var'_It`item'"
  }
  local ivarsitem = RegIVars
  global ivars_It`item' = ""
  foreach var in `ivarsitem' {
    global ivars = "${ivars}" + " " + "`var'_It`item'"
	global ivarsareg = "${ivarsareg}" + " " + "i.`var'_It`item'"
	global ivars_It`item' = "${ivars_It`item'}" + " " + "`var'_It`item'"
  }
}

*Load the data
use "${usedata}/UsingData.dta", clear
drop if Year2 == 0
gen timeScaled = (time - 20270) / 365
gen AutTime = Rules0 * timeScaled
gen IncTime = Incentives0 * timeScaled
gen BotTime = Both0 * timeScaled
bys CostCenterCode: egen Order = rank(time)
bys CostCenterCode: gen NPurchases = _N
replace Order = Order / NPurchases
gen AutOrder = Rules0 * Order
gen IncOrder = Incentives0 * Order
gen BotOrder = Both0 * Order

* Run the regressions

estimates clear

*1. Scalar Item Type on Treatment.	
reg lPriceHat Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b1
reg lPriceHat Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b2
reg lPriceHat Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b3
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg lPriceHat Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg lPriceHat Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg lPriceHat Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b1
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b2
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b1
estadd scalar pAll = pAll[2,6], replace : b2
estadd scalar pAll = pAll[3,6], replace : b3
estadd local itemctrl "Scalar" , replace : b1
estadd local itemctrl "Scalar" , replace : b2
estadd local itemctrl "Scalar" , replace : b3
estimates restore b1
estimates save "${tempdir}/TableE3_ScalarVariety_eq1", replace
estimates restore b2
estimates save "${tempdir}/TableE3_ScalarVariety_eq2", replace
estimates restore b3
estimates save "${tempdir}/TableE3_ScalarVariety_eq3", replace

*2. Coarse Item Type on Treatment.	
reg qual Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	NewItemID#c.lQuantity NewItemID#i.sizeL i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter)
estimates store b4
reg qual Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity NewItemID#i.sizeL i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter)
estimates store b5
reg qual Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity NewItemID#i.sizeL i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter)
estimates store b6
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg qual Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		NewItemID#c.lQuantity NewItemID#i.sizeL ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg qual Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity NewItemID#i.sizeL ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg qual Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity NewItemID#i.sizeL ///
		i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b4
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b5
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b6
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b4
estadd scalar pAll = pAll[2,6], replace : b5
estadd scalar pAll = pAll[3,6], replace : b6
estadd local itemctrl "Coarse" , replace : b4
estadd local itemctrl "Coarse" , replace : b5
estadd local itemctrl "Coarse" , replace : b6
estimates restore b4
estimates save "${tempdir}/TableE3_CoarseVariety_eq1", replace
estimates restore b5
estimates save "${tempdir}/TableE3_CoarseVariety_eq2", replace
estimates restore b6
estimates save "${tempdir}/TableE3_CoarseVariety_eq3", replace

*3. Price on Treatment. No quality controls
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b7
reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b8
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b9
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b7
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b8
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b9
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b7
estadd scalar pAll = pAll[2,6], replace : b8
estadd scalar pAll = pAll[3,6], replace : b9
estadd local itemctrl "None" , replace : b7
estadd local itemctrl "None" , replace : b8
estadd local itemctrl "None" , replace : b9
estimates restore b7
estimates save "${tempdir}/TableE3_PriceNoCtrl_eq1", replace
estimates restore b8
estimates save "${tempdir}/TableE3_PriceNoCtrl_eq2", replace
estimates restore b9
estimates save "${tempdir}/TableE3_PriceNoCtrl_eq3", replace

*4. Price on Treatment. Attribute controls
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store b10
reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store b11
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store b12
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0)  ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b10
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b11
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b12
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b10
estadd scalar pAll = pAll[2,6], replace : b11
estadd scalar pAll = pAll[3,6], replace : b12
estadd local itemctrl "Attribs" , replace : b10
estadd local itemctrl "Attribs" , replace : b11
estadd local itemctrl "Attribs" , replace : b12
estimates restore b10
estimates save "${tempdir}/TableE3_PriceAttribCtrl_eq1", replace
estimates restore b11
estimates save "${tempdir}/TableE3_PriceAttribCtrl_eq2", replace
estimates restore b12
estimates save "${tempdir}/TableE3_PriceAttribCtrl_eq3", replace

*5. Price on Treatment. Scalar Item Control	
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b13
reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b14
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b15
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b13
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b14
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b15
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b13
estadd scalar pAll = pAll[2,6], replace : b14
estadd scalar pAll = pAll[3,6], replace : b15
estadd local itemctrl "Scalar" , replace : b13
estadd local itemctrl "Scalar" , replace : b14
estadd local itemctrl "Scalar" , replace : b15
estimates restore b13
estimates save "${tempdir}/TableE3_PriceScalarCtrl_eq1", replace
estimates restore b14
estimates save "${tempdir}/TableE3_PriceScalarCtrl_eq2", replace
estimates restore b15
estimates save "${tempdir}/TableE3_PriceScalarCtrl_eq3", replace

*6. Price on Treatment. Coarse Item Type Control	
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b16
reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b17
reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
	NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b18
randcmd((Incentives0 Rules0 Both0 AutTime IncTime BotTime) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)) ///
	((Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder) ///
	reg lUnitPrice Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ///
		NewItemID#c.lQuantity NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace IncTime = Incentives0 * timeScaled) ///
	calc2(replace AutTime = Rules0 * timeScaled) ///
	calc3(replace BotTime = Both0 * timeScaled) ///
	calc4(replace IncOrder = Incentives0 * Order) ///
	calc5(replace AutOrder = Rules0 * Order) ///
	calc6(replace BotOrder = Both0 * Order) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRIAll = e(RCoef)
mat pRI = pRIAll[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b16
mat pRI = pRIAll[7..12,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b17
mat pRI = pRIAll[13..21,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace: b18
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : b16
estadd scalar pAll = pAll[2,6], replace : b17
estadd scalar pAll = pAll[3,6], replace : b18
estadd local itemctrl "Coarse" , replace : b16
estadd local itemctrl "Coarse" , replace : b17
estadd local itemctrl "Coarse" , replace : b18
estimates restore b16
estimates save "${tempdir}/TableE3_PriceCoarseCtrl_eq1", replace
estimates restore b17
estimates save "${tempdir}/TableE3_PriceCoarseCtrl_eq2", replace
estimates restore b18
estimates save "${tempdir}/TableE3_PriceCoarseCtrl_eq3", replace
