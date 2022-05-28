*Load the data
use "${usedata}/UsingData.dta", clear
merge m:1 District using "${usedata}/JuneSpikes.dta", nogen
replace agJune = 0 if agJune == .
keep if Fiscal_Year == "2015-16"


*we do DID for all levels of agJune between the 25th and 75th pctile
*we find significant DID at .22, which matches the semiparametric estimates
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

* 2. RUN REGRESSIONS	*
estimates clear

** Autonomy **

*** No controls ***

reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg1

randcmd ((1.Rules0 1.Rules0#1.agD_l22) /// 
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Rules0##i.agD_l22 ///
		if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg1
estadd local itemctrl "None" , replace : reg1
estimates restore reg1
estimates save "${tempdir}/TabF1_AutReg1", replace

*** Attibutes ***

reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	i.($ivars) $nvars if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((1.Rules0 1.Rules0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
		i.($ivars) $nvars if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg2
estadd local itemctrl "Attribs" , replace : reg2
estimates restore reg2
estimates save "${tempdir}/TabF1_AutReg2", replace

*** Scalar ***

reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata ///
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg3

randcmd((1.Rules0 1.Rules0#1.agD_l22) ///
	reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata /// 
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estadd local itemctrl "Scalar" , replace : reg3
estimates restore reg3
estimates save "${tempdir}/TabF1_AutReg3", replace

*** Coarse ***

reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata ///
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg4

randcmd((1.Rules0 1.Rules0#1.agD_l22) ///
	reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata /// 
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg4
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg4
estadd local itemctrl "Coarse" , replace : reg4
estimates restore reg4
estimates save "${tempdir}/TabF1_AutReg4", replace

*** ML ***

reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata ///
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg5

randcmd((1.Rules0 1.Rules0#1.agD_l22) ///
	reg lUnitPrice i.Rules0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata /// 
	if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg5
estadd local itemctrl "ML" , replace : reg5
estimates restore reg5
estimates save "${tempdir}/TabF1_AutReg5", replace


** Incentives **

*** No controls ***

reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg1

randcmd ((1.Incentives0 1.Incentives0#1.agD_l48) /// 
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Incentives0##i.agD_l48 ///
		if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg1
estadd local itemctrl "None" , replace : reg1
estimates restore reg1
estimates save "${tempdir}/TabF1_IncReg1", replace

*** Attibutes ***

reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	i.($ivars) $nvars if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((1.Incentives0 1.Incentives0#1.agD_l48) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata i.Incentives0##i.agD_l48 ///
		i.($ivars) $nvars if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg2
estadd local itemctrl "Attribs" , replace : reg2
estimates restore reg2
estimates save "${tempdir}/TabF1_IncReg2", replace

*** Scalar ***

reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata ///
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg3

randcmd((1.Incentives0 1.Incentives0#1.agD_l48) ///
	reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata /// 
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estadd local itemctrl "Scalar" , replace : reg3
estimates restore reg3
estimates save "${tempdir}/TabF1_IncReg3", replace

*** Coarse ***

reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata ///
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg4

randcmd((1.Incentives0 1.Incentives0#1.agD_l48) ///
	reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata /// 
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg4
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg4
estadd local itemctrl "Coarse" , replace : reg4
estimates restore reg4
estimates save "${tempdir}/TabF1_IncReg4", replace

*** ML ***

reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata ///
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg5

randcmd((1.Incentives0 1.Incentives0#1.agD_l48) ///
	reg lUnitPrice i.Incentives0##i.agD_l48 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata /// 
	if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg5
estadd local itemctrl "ML" , replace : reg5
estimates restore reg5
estimates save "${tempdir}/TabF1_IncReg5", replace


** Combined **

*** No controls ***

reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg1

randcmd ((1.Both0 1.Both0#1.agD_l22) /// 
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Both0##i.agD_l22 ///
		if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg1
estadd local itemctrl "None" , replace : reg1
estimates restore reg1
estimates save "${tempdir}/TabF1_BotReg1", replace

*** Attibutes ***

reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	i.($ivars) $nvars if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((1.Both0 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.strata i.Both0##i.agD_l22 ///
		i.($ivars) $nvars if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg2
estadd local itemctrl "Attribs" , replace : reg2
estimates restore reg2
estimates save "${tempdir}/TabF1_BotReg2", replace

*** Scalar ***

reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata ///
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg3

randcmd((1.Both0 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	lPriceHat i.NewItemID NCC i.strata /// 
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estadd local itemctrl "Scalar" , replace : reg3
estimates restore reg3
estimates save "${tempdir}/TabF1_BotReg3", replace

*** Coarse ***

reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata ///
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg4

randcmd((1.Both0 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	NewItemID#i.qual NewItemID##i.sizeL i.NewItemID NCC i.strata /// 
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg4
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg4
estadd local itemctrl "Coarse" , replace : reg4
estimates restore reg4
estimates save "${tempdir}/TabF1_BotReg4", replace

*** ML ***

reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata ///
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg5

randcmd((1.Both0 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.Both0##i.agD_l22 i.NewItemID##c.lQuantity NCC i.strata ///
	rf_pred_lprice i.NewItemID NCC i.strata /// 
	if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..2,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg5
estadd local itemctrl "ML" , replace : reg5
estimates restore reg5
estimates save "${tempdir}/TabF1_BotReg5", replace



* 2. Tables *

estimates clear
estimates use "${tempdir}/TabF1_AutReg1"
estimates store reg1
estimates use "${tempdir}/TabF1_AutReg2"
estimates store reg2
estimates use "${tempdir}/TabF1_AutReg3"
estimates store reg3
estimates use "${tempdir}/TabF1_AutReg4"
estimates store reg4
estimates use "${tempdir}/TabF1_AutReg5"
estimates store reg5

esttab reg1 reg2 reg3 reg4 reg5, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG", ///
		elist(1.Rules0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))
	
esttab reg1 reg2 reg3 reg4 reg5 ///
  using "${tabsdir}/TabF1_Autonomy.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG", ///
		elist(1.Rules0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)

estimates clear
estimates use "${tempdir}/TabF1_IncReg1"
estimates store reg1
estimates use "${tempdir}/TabF1_IncReg2"
estimates store reg2
estimates use "${tempdir}/TabF1_IncReg3"
estimates store reg3
estimates use "${tempdir}/TabF1_IncReg4"
estimates store reg4
estimates use "${tempdir}/TabF1_IncReg5"
estimates store reg5

esttab reg1 reg2 reg3 reg4 reg5, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Incentives0 1.Incentives0#1.agD_l48) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Incentives0 "Incentives" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG", ///
		elist(1.Incentives0 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))
	
esttab reg1 reg2 reg3 reg4 reg5 ///
  using "${tabsdir}/TabF1_Incentives.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Incentives0 1.Incentives0#1.agD_l48) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Incentives0 "Incentives" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG", ///
		elist(1.Incentives0 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
  

estimates clear
estimates use "${tempdir}/TabF1_BotReg1"
estimates store reg1
estimates use "${tempdir}/TabF1_BotReg2"
estimates store reg2
estimates use "${tempdir}/TabF1_BotReg3"
estimates store reg3
estimates use "${tempdir}/TabF1_BotReg4"
estimates store reg4
estimates use "${tempdir}/TabF1_BotReg5"
estimates store reg5

esttab reg1 reg2 reg3 reg4 reg5, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Both0 1.Both0#1.agD_l22) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Both0 "Combined" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG", ///
		elist(1.Both0 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))
	
esttab reg1 reg2 reg3 reg4 reg5 ///
  using "${tabsdir}/TabF1_Combined.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Both0 1.Both0#1.agD_l22) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Both0 "Combined" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG", ///
		elist(1.Both0 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
