
*Load the data
use "${usedata}/UsingData.dta", clear
merge m:1 District using "${usedata}/JuneSpikes.dta", nogen
replace agJune = 0 if agJune == .
keep if Fiscal_Year == "2015-16"

** Bad AG measure
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

gen InteractIncentives = Incentives0 * agJune
gen InteractAutonomy = Rules0 * agJune
gen InteractBoth = Both0 * agJune

* Variety interaction regressions
estimates clear

** Scalar
reg lPriceHat i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg1
randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 ///
		1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg lPriceHat i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter) ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg1
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg1
estadd local itemctrl "Scalar" , replace : reg1
estimates restore reg1
estimates save "${tempdir}/TableF4_Reg1", replace


** Coarse
reg qual i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 NewItemID##i.sizeL ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2
randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 ///
		1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg qual i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 NewItemID##i.sizeL ///
		[aweight=ExpInCtrl], cl(CostCenter) ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg2
estadd local itemctrl "Coarse" , replace : reg2
estimates restore reg2
estimates save "${tempdir}/TableF4_Reg2", replace


** ML
reg rf_pred_lprice i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg3
randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 ///
		1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg rf_pred_lprice i.NewItemID##c.lQ NCC i.strata i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter) ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estadd local itemctrl "ML" , replace : reg3
estimates restore reg3
estimates save "${tempdir}/TableF4_Reg3", replace


* Table

estimates clear
estimates use "${tempdir}/TableF4_Reg1"
estimates store reg1
estimates use "${tempdir}/TableF4_Reg2"
estimates store reg2
estimates use "${tempdir}/TableF4_Reg3"
estimates store reg3


esttab reg1 reg2 reg3, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22 1.Incentives0 ///
	1.Incentives0#1.agD_l48 1.Both0 ///
	1.Both0#1.agD_l22 ) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 ///
	1.Both0#1.agD_l22 ) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Variety Measure" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))
	

esttab reg1 reg2 reg3 ///
  using "${tabsdir}/TableF4.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22 1.Incentives0 ///
	1.Incentives0#1.agD_l48 1.Both0 ///
	1.Both0#1.agD_l22 ) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 ///
	1.Both0#1.agD_l22 ) ///
  nostar ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Variety Measure" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)

