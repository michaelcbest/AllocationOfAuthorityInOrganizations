			
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
use "${usedata}/UsingWithMechanisms.dta", clear

* Build Year-1 based measures
capture drop _merge
gen month=month(time)
gen delta=DocumentDate-time
replace delta=. if delta<0|delta>1000

tempfile dd
preserve
	keep if Year2==0
	keep if Treatment == 4 | Treatment == 2

	collapse delta, by (District month)
	gen ddfye=6-(month)  if month>0&month<7
	 
	replace ddfye = 11-(month-7)  if month>6
	tab month ddfye
	gen beta=.
	gen nu=.
	levelsof District, local(D)
	foreach d of local D {
		reg delta ddfye if District==`d'

		replace beta = _b[ddfye]  if District==`d'

		replace nu = delta -beta*ddfye if  District==`d'
	}
	bys District: egen mDelta=mean(delta)
	collapse beta mDelta nu, by(District)
	save `dd', replace
restore
merge  m:1  District using `dd', assert(3)


keep if Fiscal_Year == "2015-16"

* Measure 1
*Take answers to "reasons why DDO cant save" Q1 in endline
*Use district average of all scores given to AG and speed related issues for control group (weighted average by number of purchases)

drop m1j*
egen s1=rsum(m1*)
gen ww=(m1a+m1b+m1f+m1g)/s1 
replace ww=. if Treatment!=4
bys District: egen wt=median(ww)

su wt if agJune>0.22
su wt if agJune<=0.22

corr wt agJune if Year2==1 /*correlated with our measure*/

			
/*******************\
*	Run Regressions	*
\*******************/

/*** No controls ***

reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
	i.Both0##c.wt i.strata ib4.Treatment##c.wt [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg1

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
	reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
		i.Both0##c.wt i.strata ib4.Treatment##c.wt [aweight=ExpInCtrl], cl(CostCenter)), ///
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
estadd local itemctrl "None" , replace : reg1
estimates restore reg1
estimates save "${tempdir}/TableF2_Reg1", replace

*** Attibutes ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
	i.Both0##c.wt i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
		i.Both0##c.wt i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg2
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg2
estadd local itemctrl "Attribs" , replace : reg2
estimates restore reg2
estimates save "${tempdir}/TableF2_Reg2", replace

*** Scalar ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
	i.Both0##c.wt i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg3

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
		i.Both0##c.wt i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estadd local itemctrl "Scalar" , replace : reg3
estimates restore reg3
estimates save "${tempdir}/TableF2_Reg3", replace

*** Coarse ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
	i.Both0##c.wt i.strata NewItemID#i.qual NewItemID##i.sizeL ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg4

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
		i.Both0##c.wt i.strata NewItemID#i.qual NewItemID##i.sizeL ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg4
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg4
estadd local itemctrl "Coarse" , replace : reg4
estimates restore reg4
estimates save "${tempdir}/TableF2_Reg4", replace

*** ML ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
	i.Both0##c.wt i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg5

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.wt i.Incentives0##c.wt ///
		i.Both0##c.wt i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg5
estadd local itemctrl "ML" , replace : reg5
estimates restore reg5
estimates save "${tempdir}/TableF2_Reg5", replace


** reweighted mean delay mDelta

*** No controls ***

reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
	i.Both0##c.mDelta i.strata ib4.Treatment##c.mDelta [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg6

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.mDelta 1.Incentives0#c.mDelta 1.Both0#c.mDelta) ///
	reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
		i.Both0##c.mDelta i.strata ib4.Treatment##c.mDelta [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg6
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg6
estadd local itemctrl "None" , replace : reg6
estimates restore reg6
estimates save "${tempdir}/TableF2_Reg6", replace

*** Attibutes ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
	i.Both0##c.mDelta i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg7

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.mDelta 1.Incentives0#c.mDelta 1.Both0#c.mDelta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
		i.Both0##c.mDelta i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg7
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg7
estadd local itemctrl "Attribs" , replace : reg7
estimates restore reg7
estimates save "${tempdir}/TableF2_Reg7", replace

*** Scalar ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
	i.Both0##c.mDelta i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg8

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.mDelta 1.Incentives0#c.mDelta 1.Both0#c.mDelta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
		i.Both0##c.mDelta i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg8
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg8
estadd local itemctrl "Scalar" , replace : reg8
estimates restore reg8
estimates save "${tempdir}/TableF2_Reg8", replace

*** Coarse ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
	i.Both0##c.mDelta i.strata NewItemID#i.qual NewItemID##i.sizeL ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg9

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.mDelta 1.Incentives0#c.mDelta 1.Both0#c.mDelta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
		i.Both0##c.mDelta i.strata NewItemID#i.qual NewItemID##i.sizeL ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg9
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg9
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg9
estadd local itemctrl "Coarse" , replace : reg9
estimates restore reg9
estimates save "${tempdir}/TableF2_Reg9", replace

*** ML ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
	i.Both0##c.mDelta i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg10

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.mDelta 1.Incentives0#c.mDelta 1.Both0#c.mDelta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.mDelta i.Incentives0##c.mDelta ///
		i.Both0##c.mDelta i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg10
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg10
estadd local itemctrl "ML" , replace : reg10
estimates restore reg10
estimates save "${tempdir}/TableF2_Reg10", replace


** slope of delay wrt months

*** No controls ***

reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
	i.Both0##c.beta i.strata ib4.Treatment##c.beta [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg11

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.beta 1.Incentives0#c.beta 1.Both0#c.beta) ///
	reg lUnitPrice  i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
		i.Both0##c.beta i.strata ib4.Treatment##c.beta [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg11
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg11
estadd local itemctrl "None" , replace : reg11
estimates restore reg11
estimates save "${tempdir}/TableF2_Reg11", replace

*** Attibutes ***/

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
	i.Both0##c.beta i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg12

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.beta 1.Incentives0#c.beta 1.Both0#c.beta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
		i.Both0##c.beta i.strata i.($ivars) $nvars [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg12
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg12
estadd local itemctrl "Attribs" , replace : reg12
estimates restore reg12
estimates save "${tempdir}/TableF2_Reg12", replace

*** Scalar ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
	i.Both0##c.beta i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg13

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.beta 1.Incentives0#c.beta 1.Both0#c.beta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
		i.Both0##c.beta i.strata lPriceHat [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg13
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg13
estadd local itemctrl "Scalar" , replace : reg13
estimates restore reg13
estimates save "${tempdir}/TableF2_Reg13", replace

*** Coarse ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
	i.Both0##c.beta i.strata NewItemID#i.qual NewItemID##i.sizeL ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg14

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.beta 1.Incentives0#c.beta 1.Both0#c.beta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
		i.Both0##c.beta i.strata NewItemID#i.qual NewItemID##i.sizeL ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg14
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg14
mat pEqual = e(RCoef)
estadd scalar pIncAutApp = pEqual[7,6], replace : reg14
estadd local itemctrl "Coarse" , replace : reg14
estimates restore reg14
estimates save "${tempdir}/TableF2_Reg14", replace

*** ML ***

reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
	i.Both0##c.beta i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg15

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.beta 1.Incentives0#c.beta 1.Both0#c.beta) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC i.Rules0##c.beta i.Incentives0##c.beta ///
		i.Both0##c.beta i.strata rf_pred_lprice [aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenter) ///
	reps(${RIreps}) ///
	seed(${seed})
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg15
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg15
estadd local itemctrl "ML" , replace : reg15
estimates restore reg15
estimates save "${tempdir}/TableF2_Reg15", replace


* Build Table


estimates clear
estimates use "${tempdir}/TableF2_Reg1"
estimates store reg1
estimates use "${tempdir}/TableF2_Reg2"
estimates store reg2
estimates use "${tempdir}/TableF2_Reg3"
estimates store reg3
estimates use "${tempdir}/TableF2_Reg4"
estimates store reg4
estimates use "${tempdir}/TableF2_Reg5"
estimates store reg5
estimates use "${tempdir}/TableF2_Reg6"
estimates store reg6
estimates use "${tempdir}/TableF2_Reg7"
estimates store reg7
estimates use "${tempdir}/TableF2_Reg8"
estimates store reg8
estimates use "${tempdir}/TableF2_Reg9"
estimates store reg9
estimates use "${tempdir}/TableF2_Reg10"
estimates store reg10
estimates use "${tempdir}/TableF2_Reg11"
estimates store reg11
estimates use "${tempdir}/TableF2_Reg12"
estimates store reg12
estimates use "${tempdir}/TableF2_Reg13"
estimates store reg13
estimates use "${tempdir}/TableF2_Reg14"
estimates store reg14
estimates use "${tempdir}/TableF2_Reg15"
estimates store reg15

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12 reg13 reg14 reg15, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#c.wt 1.Incentives0 1.Incentives0#c.wt 1.Both0 1.Both0#c.wt) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
  nostar ///
  mgroups("Survey Responses" "Weighted Delays" "Delay Acceleration" , ///
	pattern(1 0 0 0 0 1 0 0 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#c.wt "Autonomy $ \times $ AG Misalignment" ///
	1.Incentives0#c.wt "Incentives $ \times $ AG Misalignment" ///
	1.Both0#c.wt "Combined $ \times $ AG Misalignment", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#c.wt \addlinespace ///
			1.Incentives0#c.wt \addlinespace ///
			1.Both0#c.wt \addlinespace )) ///
  rename(1.Rules0#c.mDelta 1.Rules0#c.wt ///
	1.Rules0#c.beta 1.Rules0#c.wt ///
	1.Incentives0#c.mDelta 1.Incentives0#c.wt ///
	1.Incentives0#c.beta 1.Incentives0#c.wt ///
	1.Both0#c.mDelta 1.Both0#c.wt ///
	1.Both0#c.beta 1.Both0#c.wt) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))
	
	
	
esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12 reg13 reg14 reg15 ///
  using "${tabsdir}/TableF2.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#c.wt 1.Incentives0 1.Incentives0#c.wt 1.Both0 1.Both0#c.wt) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.wt 1.Incentives0#c.wt 1.Both0#c.wt) ///
  nostar ///
  mgroups("Survey Responses" "Weighted Delays" "Delay Acceleration" , ///
	pattern(1 0 0 0 0 1 0 0 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  mlabels(none) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#c.wt "Autonomy $ \times $ AG Misalignment" ///
	1.Incentives0#c.wt "Incentives $ \times $ AG Misalignment" ///
	1.Both0#c.wt "Combined $ \times $ AG Misalignment", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#c.wt \addlinespace ///
			1.Incentives0#c.wt \addlinespace ///
			1.Both0#c.wt \addlinespace )) ///
  rename(1.Rules0#c.mDelta 1.Rules0#c.wt ///
	1.Rules0#c.beta 1.Rules0#c.wt ///
	1.Incentives0#c.mDelta 1.Incentives0#c.wt ///
	1.Incentives0#c.beta 1.Incentives0#c.wt ///
	1.Both0#c.mDelta 1.Both0#c.wt ///
	1.Both0#c.beta 1.Both0#c.wt) ///
  collabels(none) ///
  stats(itemctrl pAll N , ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
