	
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

use "${usedata}/UsingWithMechanisms.dta", clear

* Construct Alternatives to show robustness to.


** Bad AG. Our measure
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

** include interaction with average delay 
gen delta=DocumentDate-time
replace delta=. if delta<0|delta>365|Year2==1
bys District : egen agInco=mean(delta)
*gen agIM=agInco<=88

** late submission share
gen mo=month(time)
gen lateSub=mo==6|mo==5
bys CostCenter Year2: egen slateSub=mean(lateSub)

** PO type
egen CC=group(CostCenterCode)
iis CC
xtreg lUnitPrice  i.NewItemID##c.lQ lPriceHat    if Year2==0  , fe
predict FE0, u
bys CC:egen h=max(FE0)
replace FE0=h if FE0==.
gen highPO=FE0<=0


keep if Year2 == 1

* Run Regressions

** Our measure
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg1

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
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
estimates restore reg1
estimates save "${tempdir}/TableF3_Reg1", replace

** late submissions
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##c.slateSub ///
	i.Incentives0##c.slateSub i.Both0##c.slateSub ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.slateSub 1.Incentives0#c.slateSub 1.Both0#c.slateSub) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##c.slateSub ///
		i.Incentives0##c.slateSub i.Both0##c.slateSub ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
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
estimates restore reg2
estimates save "${tempdir}/TableF3_Reg2", replace

** late submissions and our measure
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##c.slateSub ///
	i.Incentives0##c.slateSub i.Both0##c.slateSub i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg3

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.slateSub 1.Incentives0#c.slateSub ///
		1.Both0#c.slateSub 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##c.slateSub ///
		i.Incentives0##c.slateSub i.Both0##c.slateSub i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg3
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg3
estimates restore reg3
estimates save "${tempdir}/TableF3_Reg3", replace

** average delay
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##c.agInco ///
	i.Incentives0##c.agInco i.Both0##c.agInco ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg4

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.agInco 1.Incentives0#c.agInco 1.Both0#c.agInco) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##c.agInco ///
		i.Incentives0##c.agInco i.Both0##c.agInco ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..6,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg4
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg4
estadd local altmes "Av Delay" , replace : reg4
estimates restore reg4
estimates save "${tempdir}/TableF3_Reg4", replace

** average delay and our measure
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##c.agInco ///
	i.Incentives0##c.agInco i.Both0##c.agInco i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg5

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#c.agInco 1.Incentives0#c.agInco ///
		1.Both0#c.agInco 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##c.agInco ///
		i.Incentives0##c.agInco i.Both0##c.agInco i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg5
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg5
estimates restore reg5
estimates save "${tempdir}/TableF3_Reg5", replace


** high PO
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##i.highPO ///
	i.Incentives0##i.highPO i.Both0##i.highPO ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg6

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.highPO 1.Incentives0#1.highPO 1.Both0#1.highPO) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##i.highPO ///
		i.Incentives0##i.highPO i.Both0##i.highPO ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
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
estimates restore reg6
estimates save "${tempdir}/TableF3_Reg6", replace

** high PO and our measure
reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##i.highPO ///
	i.Incentives0##i.highPO i.Both0##i.highPO i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
	[aweight=ExpInCtrl], cl(CostCenter)
estimates store reg7

randcmd((1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.highPO 1.Incentives0#1.highPO ///
		1.Both0#1.highPO 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 1.Both0#1.agD_l22) ///
	reg lUnitPrice i.NewItemID##c.lQ NCC  i.strata lPriceHat  i.Rules0##i.highPO ///
		i.Incentives0##i.highPO i.Both0##i.highPO i.Rules0##i.agD_l22 ///
	i.Incentives0##i.agD_l48 i.Both0##i.agD_l22 ///
		[aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
mat pRI = e(RCoef)
mat pRI = pRI[1..9,6]
matrix rownames pRI = _:
matrix pRI = pRI'
estadd matrix pRI , replace : reg7
mat pAll = e(REqn)
estadd scalar pAll = pAll[1,6], replace : reg7
estimates restore reg7
estimates save "${tempdir}/TableF3_Reg7", replace


* Build Table

estimates clear
estimates use "${tempdir}/TableF3_Reg1"
estimates store reg1
estimates use "${tempdir}/TableF3_Reg2"
estimates store reg2
estimates use "${tempdir}/TableF3_Reg3"
estimates store reg3
estimates use "${tempdir}/TableF3_Reg4"
estimates store reg4
estimates use "${tempdir}/TableF3_Reg5"
estimates store reg5
estimates use "${tempdir}/TableF3_Reg6"
estimates store reg6
estimates use "${tempdir}/TableF3_Reg7"
estimates store reg7

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22 1.Rules0#c.slateSub 1.Incentives0 ///
	1.Incentives0#1.agD_l48 1.Incentives0#c.slateSub 1.Both0 ///
	1.Both0#1.agD_l22 1.Both0#c.slateSub ) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 ///
	1.Both0#1.agD_l22 1.Rules0#c.slateSub 1.Incentives0#c.slateSub 1.Both0#c.slateSub ///
	1.Rules0#c.agInco 1.Incentives0#c.agInco 1.Both0#c.agInco 1.Rules0#1.highPO ///
	1.Incentives0#1.highPO 1.Both0#1.highPO) ///
  rename(1.Rules0#c.agInco 1.Rules0#c.slateSub ///
		1.Incentives0#c.agInco 1.Incentives0#c.slateSub ///
		1.Both0#c.agInco 1.Both0#c.slateSub ///
		1.Rules0#1.highPO 1.Rules0#c.slateSub) ///
  nostar ///
  mlabels(none) ///
  mgroups(" " "Late Submissions" "Average Delay" "Good PO" , ///
	pattern(1 1 0 1 0 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG" ///
	1.Rules0#c.slateSub "Autonomy $ \times $ Alternative Measure" ///
	1.Incentives0#c.slateSub "Incentives $ \times $ Alternative Measure" ///
	1.Both0#c.slateSub "Combined $ \times $ Alternative Measure", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace ///
			1.Rules0#c.slateSub \addlinespace ///
			1.Incentives0#c.slateSub \addlinespace ///
			1.Both0#c.slateSub \addlinespace )) ///
  collabels(none) ///
  stats( pAll N , ///
    labels("p(All = 0)" "Observations") ///
	fmt(3 %8.0fc))
	
esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 ///
  using "${tabsdir}/TableF3.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(1.Rules0 1.Rules0#1.agD_l22 1.Rules0#c.slateSub 1.Incentives0 ///
	1.Incentives0#1.agD_l48 1.Incentives0#c.slateSub 1.Both0 ///
	1.Both0#1.agD_l22 1.Both0#c.slateSub ) ///
  order(1.Rules0 1.Incentives0 1.Both0 1.Rules0#1.agD_l22 1.Incentives0#1.agD_l48 ///
	1.Both0#1.agD_l22 1.Rules0#c.slateSub 1.Incentives0#c.slateSub 1.Both0#c.slateSub ///
	1.Rules0#c.agInco 1.Incentives0#c.agInco 1.Both0#c.agInco 1.Rules0#1.highPO ///
	1.Incentives0#1.highPO 1.Both0#1.highPO) ///
  rename(1.Rules0#c.agInco 1.Rules0#c.slateSub ///
		1.Incentives0#c.agInco 1.Incentives0#c.slateSub ///
		1.Both0#c.agInco 1.Both0#c.slateSub ///
		1.Rules0#1.highPO 1.Rules0#c.slateSub ) ///
  nostar ///
  mlabels(none) ///
  mgroups(" " "Late Submissions" "Average Delay" "Good PO" , ///
	pattern(1 1 0 1 0 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(1.Rules0 "Autonomy" ///
	1.Incentives0 "Incentives" ///
	1.Both0 "Combined" ///
	1.Rules0#1.agD_l22 "Autonomy $ \times $ Bad AG" ///
	1.Incentives0#1.agD_l48 "Incentives $ \times $ Bad AG" ///
	1.Both0#1.agD_l22 "Combined $ \times $ Bad AG" ///
	1.Rules0#c.slateSub "Autonomy $ \times $ Alternative Measure" ///
	1.Incentives0#c.slateSub "Incentives $ \times $ Alternative Measure" ///
	1.Both0#c.slateSub "Combined $ \times $ Alternative Measure", ///
		elist(1.Rules0 \addlinespace ///
			1.Incentives0 \addlinespace ///
			1.Both0 \addlinespace ///
			1.Rules0#1.agD_l22 \addlinespace ///
			1.Incentives0#1.agD_l48 \addlinespace ///
			1.Both0#1.agD_l22 \addlinespace ///
			1.Rules0#c.slateSub \addlinespace ///
			1.Incentives0#c.slateSub \addlinespace ///
			1.Both0#c.slateSub \addlinespace )) ///
  collabels(none) ///
  stats( pAll N , ///
    labels("p(All = 0)" "Observations") ///
	fmt(3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
  
