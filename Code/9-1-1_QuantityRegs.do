							
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

use "${usedata}/UsingData.dta", clear
drop if Year2 == 0

estimates clear
/*
*1. Quantity on Treatment. No quality controls
reg lQuantity Incentives0 Rules0 Both0 i.NewItemID NCC i.strata ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b1
randcmd((Incentives0 Rules0 Both0) ///
	reg lQuantity Incentives0 Rules0 Both0 i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "None" , replace : b1
estimates restore b1
estimates save "${tempdir}/TableE1_NoCtrl", replace

*2. Quantity on Treatment. Attribute controls
reg lQuantity Incentives0 Rules0 Both0 ///
	i.NewItemID i.($ivars) $nvars NCC i.strata ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store b2
randcmd((Incentives0 Rules0 Both0) ///
	reg lQuantity Incentives0 Rules0 Both0 ///
		i.NewItemID i.($ivars) $nvars NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0)  ///
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
estadd local itemctrl "Attribs" , replace : b2
estimates restore b2
estimates save "${tempdir}/TableE1_AttrCtrl", replace

*3. Quantity on Treatment. Scalar Item Control	
reg lQuantity Incentives0 Rules0 Both0 lPriceHat ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b3
randcmd((Incentives0 Rules0 Both0) ///
	reg lQuantity Incentives0 Rules0 Both0 ///
		lPriceHat i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "Scalar" , replace : b3
estimates restore b3
estimates save "${tempdir}/TableE1_ScalCtrl", replace

*4. Quantity on Treatment. Coarse Item Type Control	
reg lQuantity Incentives0 Rules0 Both0 ///
	NewItemID#i.qual NewItemID#i.sizeL i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b4
randcmd((Incentives0 Rules0 Both0) ///
	reg lQuantity Incentives0 Rules0 Both0 ///
		NewItemID#i.qual NewItemID#i.sizeL i.NewItemID ///
		NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "Coarse" , replace : b4
estimates restore b4
estimates save "${tempdir}/TableE1_CoarseCtrl", replace

*6. "Value" on Treatment. Priced with scalar control
gen lpq = lQuantity + lPriceHat
reg lpq Incentives0 Rules0 Both0 ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store b6
randcmd((Incentives0 Rules0 Both0) ///
	reg lpq Incentives0 Rules0 Both0 ///
		 i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "Scalar" , replace : b6
estimates restore b6
estimates save "${tempdir}/TableE1_Value_ScalCtrl", replace

*5. Quantity on Treatment. ML Item Type Control
reg lQuantity Incentives0 Rules0 Both0 rf_pred_lprice ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter) 
estimates store b5
randcmd((Incentives0 Rules0 Both0) ///
	reg lQuantity Incentives0 Rules0 Both0 ///
		rf_pred_lprice i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "ML" , replace : b5
estimates restore b5
estimates save "${tempdir}/TableE1_MLCtrl", replace
*/
*7. "Value" on Treatment. Priced with ML control
capture drop lpq
gen lpq = lQuantity + rf_pred_lprice
reg lpq Incentives0 Rules0 Both0 ///
	i.NewItemID NCC i.strata [aweight=ExpInCtrl], cl(CostCenter) 
estimates store b7
randcmd((Incentives0 Rules0 Both0) ///
	reg lpq Incentives0 Rules0 Both0 ///
		 i.NewItemID NCC i.strata ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
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
estadd local itemctrl "ML" , replace : b7
estimates restore b7
estimates save "${tempdir}/TableE1_Value_MLCtrl", replace

