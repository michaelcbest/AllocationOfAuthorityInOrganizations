use "${usedata}/UsingData.dta", clear
drop if time > date("01Jul2016","DMY") /*outliers that mess up the pics*/
keep if Fiscal_Year == "2015-16"

merge 1:1 RequestID DeliveryID using  "${rawdata}/DiceGameData.dta", ///
	keep(1 3) nogen
drop if DiceScoreOffice == .

*2.Interactions with Dice Game Score
gen InteractIncentives = Incentives0 * DiceScoreOffice
gen InteractAutonomy = Rules0 * DiceScoreOffice
gen InteractBoth = Both0 * DiceScoreOffice

*No Item Variety Controls
estimates clear

reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
	InteractBoth NewItemID#c.lQuantity i.NewItemID NCC i.strata DiceScoreOffice ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg1

randcmd((Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
	reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
		InteractBoth NewItemID#c.lQuantity i.NewItemID NCC i.strata DiceScoreOffice ///
		[aweight=ExpInCtrl] , cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace InteractIncentives = Incentives0 * DiceScoreOffice) ///
	calc2(replace InteractAutonomy = Rules0 * DiceScoreOffice) ///
	calc3(replace InteractBoth = Both0 * DiceScoreOffice) ///
	strata(strata) ///
	groupvar(CostCenter) ///
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

*Attribute Variety Controls

reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
	InteractBoth NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC ///
	i.strata DiceScoreOffice [aweight=ExpInCtrl], cl(CostCenter)
estimates store reg2

randcmd((Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
	reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
		InteractBoth NewItemID#c.lQuantity i.NewItemID i.($ivars) $nvars NCC DiceScoreOffice ///
		i.strata [aweight=ExpInCtrl], cl(CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace InteractIncentives = Incentives0 * DiceScoreOffice) ///
	calc2(replace InteractAutonomy = Rules0 * DiceScoreOffice) ///
	calc3(replace InteractBoth = Both0 * DiceScoreOffice) ///
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

*Scalar Variety Controls

reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
	InteractBoth lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata DiceScoreOffice ///
	[aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg3

randcmd((Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
	reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
		InteractBoth lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata DiceScoreOffice ///
		[aweight=ExpInCtrl] , cl(CostCenter) ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace InteractIncentives = Incentives0 * DiceScoreOffice) ///
	calc2(replace InteractAutonomy = Rules0 * DiceScoreOffice) ///
	calc3(replace InteractBoth = Both0 * DiceScoreOffice) ///
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

*Coarse Variety Controls

reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
	InteractBoth NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
	i.NewItemID NCC i.strata DiceScoreOffice [aweight=ExpInCtrl] , cl(CostCenter) 
estimates store reg4

randcmd((Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
	reg lUnitPrice Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy ///
		InteractBoth NewItemID#c.lQuantity NewItemID#i.qual NewItemID##i.sizeL ///
		i.NewItemID NCC i.strata DiceScoreOffice [aweight=ExpInCtrl] , cl(CostCenter)  ), ///
	treatvars(Incentives0 Rules0 Both0) ///
	calc1(replace InteractIncentives = Incentives0 * DiceScoreOffice) ///
	calc2(replace InteractAutonomy = Rules0 * DiceScoreOffice) ///
	calc3(replace InteractBoth = Both0 * DiceScoreOffice) ///
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
estadd local itemctrl "Coarse" , replace : reg4

* table
esttab reg1 reg2 reg3 reg4 ///
  using "${tabsdir}/TableA4.tex", ///
  cells(b(nostar fmt(4)) se(par fmt(4)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
  nostar ///
  order(Rules0 Incentives0 Both0 InteractAutonomy InteractIncentives InteractBoth) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both" ///
	InteractIncentives "Incentives $\times$ Dice Score" ///
	InteractAutonomy "Autonomy $\times$ Dice Score" ///
	InteractBoth "Both $\times$ Dice Score", ///
		elist(Rules0 \addlinespace ///
		Incentives0 \addlinespace ///
		Both0 \addlinespace ///
		InteractAutonomy \addlinespace ///
		InteractIncentives \addlinespace)) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All Interactions = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  varwidth(21)
  
 * table on screen
esttab reg1 reg2 reg3 reg4, ///
  cells(b(nostar fmt(4)) se(par fmt(4)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0 InteractIncentives InteractAutonomy InteractBoth) ///
  nostar ///
  order(Rules0 Incentives0 Both0 InteractAutonomy InteractIncentives InteractBoth) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both" ///
	InteractIncentives "Incentives $\times$ Dice Score" ///
	InteractAutonomy "Autonomy $\times$ Dice Score" ///
	InteractBoth "Both $\times$ Dice Score", ///
		elist(Rules0 \addlinespace ///
		Incentives0 \addlinespace ///
		Both0 \addlinespace ///
		InteractAutonomy \addlinespace ///
		InteractIncentives \addlinespace)) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All Interactions = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) 

