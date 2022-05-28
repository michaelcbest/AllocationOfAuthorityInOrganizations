*	REGRESS PRICES ON EFFORT INSTRUMENTED BY TREATMENT *

* 1. Build Data *

use "${usedata}/UsingWithMechanisms.dta", clear

** Make the Variable Total Time Spent on Procurement **
drop m1j_desc m3e_desc m4e_desc m5e_desc m6j_desc

gen option = _n in 1/3
di "`c(alpha)'"
tokenize "`c(alpha)'"
forval j = 1/3 {
     label define alphabet `j' "``j''", add
}

label values option alphabet
decode option, gen(option2)
drop option 
rename option2 option  

egen totalm7 = rowtotal(m7*)

foreach j in `c(alpha)' {
  if "`j'" <= "c" {
	gen share_m7`j' = m7`j' / totalm7 
	}
} 

gen ProcTime = (share_m7a * m8a) + (share_m7b * m8b) + (share_m7c * m8c) 

** Define Bad AG
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

* 2. Run Regressions *
* 1 treatment at a time. Make the same table we had before, but stack them on top of eachother in LyX *

** Autonomy **

estimates clear	

*** Good AG: IV ***
ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Rules0) [aweight=ExpInCtrl] if agD_l22 == 0 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)
estimates store b5
estat firststage
matrix t = r(singleresults)
estadd scalar fsF = t[1,4], replace : b5
randcmd((ProcTime) ///
	ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Rules0) [aweight=ExpInCtrl] if agD_l22 == 0 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = ProcTime
estadd matrix pRI , replace: b5
estimates restore b5
estimates save "${tempdir}/Table3_AutIVGood", replace

*** Good AG: First Stage ***
reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l22 == 0 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter) 
estimates store b6
randcmd((Rules0) reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l22 == 0 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = Rules0
estadd matrix pRI , replace: b6
estimates restore b6
estimates save "${tempdir}/Table3_AutSt1Good", replace
	
*** Bad AG: IV ***
ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Rules0) [aweight=ExpInCtrl] if agD_l22 == 1 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)
estimates store b8
estat firststage
matrix t = r(singleresults)
estadd scalar fsF = t[1,4], replace : b8
randcmd((ProcTime) ///
	ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Rules0) [aweight=ExpInCtrl] if agD_l22 == 1 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = ProcTime
estadd matrix pRI , replace: b8
estimates restore b8
estimates save "${tempdir}/Table3_AutIVBad", replace

*** Bad AG: First Stage ***
reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l22 == 1 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter) 
estimates store b9
randcmd((Rules0) reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l22 == 1 & (Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = Rules0
estadd matrix pRI , replace: b9
estimates restore b9
estimates save "${tempdir}/Table3_AutSt1Bad", replace

** Incentives **

estimates clear	

*** Good AG: IV ***
ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Incentives0) [aweight=ExpInCtrl] if agD_l48 == 0 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)
estimates store b5
estat firststage
matrix t = r(singleresults)
estadd scalar fsF = t[1,4], replace : b5
randcmd((ProcTime) ///
	ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Incentives0) [aweight=ExpInCtrl] if agD_l48 == 0 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = ProcTime
estadd matrix pRI , replace: b5
estimates restore b5
estimates save "${tempdir}/Table3_IncIVGood", replace

*** Good AG: First Stage ***
reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l48 == 0 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter) 
estimates store b6
randcmd((Incentives0) reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l48 == 0 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = Incentives0
estadd matrix pRI , replace: b6
estimates restore b6
estimates save "${tempdir}/Table3_IncSt1Good", replace
	
*** Bad AG: IV ***
ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Incentives0) [aweight=ExpInCtrl] if agD_l48 == 1 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)
estimates store b8
estat firststage
matrix t = r(singleresults)
estadd scalar fsF = t[1,4], replace : b8
randcmd((ProcTime) ///
	ivregress 2sls lUnitPrice ///
		lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		(ProcTime = Incentives0) [aweight=ExpInCtrl] if agD_l48 == 1 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
	treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = ProcTime
estadd matrix pRI , replace: b8
estimates restore b8
estimates save "${tempdir}/Table3_IncIVBad", replace

*** Bad AG: First Stage ***
reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l48 == 1 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter) 
estimates store b9
randcmd((Incentives0) reg ProcTime lPriceHat NewItemID#c.lQuantity i.NewItemID NCC i.strata ///
		Both0 Incentives0 Rules0 [aweight=ExpInCtrl] if agD_l48 == 1 & (Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0)), ///
		vce(cluster CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
	strata(strata) ///
	groupvar(CostCenterCode) ///
	reps(${RIreps}) ///
	seed(${seed}) 
**add pvalues
mat pRI = e(RCoef)
mat pRI = pRI[1,6]
matrix colnames pRI = Incentives0
estadd matrix pRI , replace: b9
estimates restore b9
estimates save "${tempdir}/Table3_IncSt1Bad", replace


estimates clear
*AUTONOMY BAD AG FIRST STAGE
estimates use "${tempdir}/Table3_AutSt1Bad"
estimates store b1
*Incentives good AG first stage
estimates use "${tempdir}/Table3_IncSt1Good"
estimates store b2
*Autonomy bad AG IV
estimates use "${tempdir}/Table3_AutIVBad"
estadd scalar fsF = `e(fsF)', replace : b1
estimates store b3
estadd scalar fsF = ., replace : b3
*Incentives good AG IV
estimates use "${tempdir}/Table3_IncIVGood"
estadd scalar fsF = `e(fsF)', replace : b2
estimates store b4
estadd scalar fsF = ., replace : b4
*Autonomy good AG lack of first stage
estimates use "${tempdir}/Table3_AutSt1Good"
estimates store b5
*Incentives bad AG lack of first stage
estimates use "${tempdir}/Table3_IncSt1Bad"
estimates store b6
*Autonomy good AG IV
estimates use "${tempdir}/Table3_AutIVGood"
estadd scalar fsF = `e(fsF)', replace : b5
*Incentives bad AG IV
estimates use "${tempdir}/Table3_IncIVBad"
estadd scalar fsF = `e(fsF)', replace : b6

esttab b1 b2 b3 b4 b5 b6, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(ProcTime Rules0 Incentives0) ///
  order(ProcTime Rules0 Incentives0) ///
  nostar ///
  mlabels("Bad AG" "Good AG" "Autonomy" "Incentives" "Good AG" "Bad AG") ///
  mgroups("First Stage" "Quantification" "Placebo" , ///
	pattern(1 0 1 0 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Rules0 "Autonomy" ///
	Incentives0 "Incentives" ///
	ProcTime "Time Spent on Procurement", ///
		elist(Rules0 \addlinespace ///
			ProcTime \addlinespace )) ///
  collabels(none) ///
  stats(fsF N, ///
    labels("First-stage F statistic" "Observations") ///
	fmt(2 %8.0fc))
	
esttab b1 b2 b3 b4 b5 b6 ///
  using "${tabsdir}/Table3.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(ProcTime Rules0 Incentives0) ///
  order(ProcTime Rules0 Incentives0) ///
  nostar ///
  mlabels("Bad AG" "Good AG" "Autonomy" "Incentives" "Good AG" "Bad AG") ///
  mgroups("First Stage" "Quantification" "Placebo" , ///
	pattern(1 0 1 0 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Rules0 "Autonomy" ///
	Incentives0 "Incentives" ///
	ProcTime "Time Spent on Procurement", ///
		elist(Rules0 \addlinespace ///
			ProcTime \addlinespace )) ///
  collabels(none) ///
  stats(fsF N, ///
    labels("First-stage F statistic" "Observations") ///
	fmt(2 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
