
*Load the data
use "${usedata}/UsingData.dta", clear
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .
keep if Fiscal_Year == "2015-16"

*we do DID for all levels of agJune between the 25th and 75th pctile
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

gen AGLevel = .
foreach t in "Aut" "Inc" "Bot" {
	foreach g in "good" "bad" {
			gen b`t'_AG`g' = .
			gen se`t'_AG`g' = .
			gen p`t'_AG`g' = .
	}
}

local lev "11 14 20 22 28 36 38 39 41 42 44 48 50 52 54 60 61"
*local lev "14 20"
local i = 1
foreach v of local lev {
	
	replace AGLevel = `v' in `i'
	
	**Autonomy
	reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##i.agD_l`v' ///
		i.Incentives0##i.agD_l28 i.Both0##i.agD_l22 if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)
	replace bAut_AGgood = _b[1.Rules0] in `i'
	replace seAut_AGgood = _se[1.Rules0]  in `i'
	replace bAut_AGbad = _b[1.Rules0#1.agD_l`v'] in `i'
	replace seAut_AGbad = _se[1.Rules0#1.agD_l`v'] in `i'

	randcmd ((1.Rules0 1.Rules0#1.agD_l`v') /// 
		reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Incentives0##i.agD_l28 ///
			i.Rules0##i.agD_l`v' i.Both0##i.agD_l22 if Rules0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
		strata(strata) ///
		groupvar(CostCenterCode) ///
		reps(${RIreps}) ///
		seed(${seed}) 
	replace pAut_AGgood = e(RCoef)[1,6] in `i'
	replace pAut_AGbad = e(RCoef)[2,6] in `i'
	
	**Incentives
	reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l`v' i.Both0##i.agD_l22 if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)
	replace bInc_AGgood = _b[1.Incentives0] in `i'
	replace seInc_AGgood = _se[1.Incentives0]  in `i'
	replace bInc_AGbad = _b[1.Incentives0#1.agD_l`v'] in `i'
	replace seInc_AGbad = _se[1.Incentives0#1.agD_l`v'] in `i'

	randcmd ((1.Incentives0 1.Incentives0#1.agD_l`v') /// 
		reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Incentives0##i.agD_l`v' ///
			i.Rules0##i.agD_l22 i.Both0##i.agD_l22 if Incentives0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
		strata(strata) ///
		groupvar(CostCenterCode) ///
		reps(${RIreps}) ///
		seed(${seed}) 
	replace pInc_AGgood = e(RCoef)[1,6] in `i'
	replace pInc_AGbad = e(RCoef)[2,6] in `i'
	
	**Combined
	reg lUnitPrice  i.NewItemID##c.lQ NCC  i.strata lPriceHat i.Rules0##i.agD_l22 ///
		i.Incentives0##i.agD_l28 i.Both0##i.agD_l`v' if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)
	replace bBot_AGgood = _b[1.Both0] in `i'
	replace seBot_AGgood = _se[1.Both0]  in `i'
	replace bBot_AGbad = _b[1.Both0#1.agD_l`v'] in `i'
	replace seBot_AGbad = _se[1.Both0#1.agD_l`v'] in `i'

	randcmd ((1.Both0 1.Both0#1.agD_l`v') /// 
		reg lUnitPrice i.NewItemID##c.lQ NCC i.strata lPriceHat i.Incentives0##i.agD_l28 ///
			i.Rules0##i.agD_l22 i.Both0##i.agD_l`v' if Both0 == 1 | (Rules0 == 0 & Incentives0 == 0 & Both0 == 0) [aweight=ExpInCtrl], cl(CostCenter)), ///
		treatvars(Incentives0 Rules0 Both0) ///
		strata(strata) ///
		groupvar(CostCenterCode) ///
		reps(${RIreps}) ///
		seed(${seed}) 
	replace pBot_AGgood = e(RCoef)[1,6] in `i'
	replace pBot_AGbad = e(RCoef)[2,6] in `i'

	local i = `i' + 1
}
		
keep AGLevel b* se* p*

gen CIlbAut_AGgood = bAut_AGgood - (invttail(11771,0.025)*seAut_AGgood)
gen CIlbAut_AGbad = bAut_AGbad - (invttail(11771,0.025)*seAut_AGgood)
gen CIubAut_AGgood = bAut_AGgood + (invttail(11771,0.025)*seAut_AGgood)
gen CIubAut_AGbad = bAut_AGbad + (invttail(11771,0.025)*seAut_AGgood)

gen CIlbInc_AGgood = bInc_AGgood - (invttail(11771,0.025)*seInc_AGgood)
gen CIlbInc_AGbad = bInc_AGbad - (invttail(11771,0.025)*seInc_AGgood)
gen CIubInc_AGgood = bInc_AGgood + (invttail(11771,0.025)*seInc_AGgood)
gen CIubInc_AGbad = bInc_AGbad + (invttail(11771,0.025)*seInc_AGgood)

gen CIlbBot_AGgood = bBot_AGgood - (invttail(11771,0.025)*seBot_AGgood)
gen CIlbBot_AGbad = bBot_AGbad - (invttail(11771,0.025)*seBot_AGgood)
gen CIubBot_AGgood = bBot_AGgood + (invttail(11771,0.025)*seBot_AGgood)
gen CIubBot_AGbad = bBot_AGbad + (invttail(11771,0.025)*seBot_AGgood)
	
save "${tempdir}/WhosABadAG.dta", replace

twoway (connected pAut_AGbad AGLevel, color(gs11) msymbol(X) yaxis(2)) ///
	(rcap CIubAut_AGbad CIlbAut_AGbad AGLevel, color("gs7") yaxis(1)) ///
	(connected bAut_AGbad AGLevel, color("black") msymbol("Oh") yaxis(1)) ///
	if AGLevel < 62, ///
	graphregion(color(white)) ///
	ytitle("RI P Value", axis(2)) ///
	ytitle("Autonomy x Bad AG DD Treatment Effect", axis(1)) ///
	xtitle("AG June Share Threshold (%)") ///
	yscale(axis(2) alt) ///
	yscale(axis(1) alt) ///
	legend(off) ///
	ylabel(0(0.25)1, axis(2) grid) ///
	yline(0.05, axis(2) lcolor(gs11) lpattern(dash)) ///
	yline(0, axis(1) lcolor(black%70)) ///
	xsize(10) ///
	ysize(4)
graph export "${picsdir}/FigureF1A.pdf", replace
graph export "${picsdir}/FigureF1A.eps", replace
	
twoway (connected pBot_AGbad AGLevel, color(gs11) msymbol(X) yaxis(2)) ///
	(rcap CIubBot_AGbad CIlbBot_AGbad AGLevel, color("gs7") yaxis(1)) ///
	(connected bBot_AGbad AGLevel, color("black") msymbol("Oh") yaxis(1)) ///
	if AGLevel < 62, ///
	graphregion(color(white)) ///
	ytitle("RI P Value", axis(2)) ///
	ytitle("Combined x Bad AG DD Treatment Effect", axis(1)) ///
	xtitle("AG June Share Threshold (%)") ///
	yscale(axis(2) alt) ///
	yscale(axis(1) alt) ///
	legend(off) ///
	ylabel(0(0.25)1, axis(2) grid) ///
	yline(0.05, axis(2) lcolor(gs11) lpattern(dash)) ///
	yline(0, axis(1) lcolor(black%70)) ///
	xsize(10) ///
	ysize(4)
graph export "${picsdir}/FigureF1C.pdf", replace
graph export "${picsdir}/FigureF1C.eps", replace

twoway (connected pInc_AGbad AGLevel, color(gs11) msymbol(X) yaxis(2)) ///
	(rcap CIubInc_AGbad CIlbInc_AGbad AGLevel, color("gs7") yaxis(1)) ///
	(connected bInc_AGbad AGLevel, color("black") msymbol("Oh") yaxis(1)) ///
	if AGLevel < 62, ///
	graphregion(color(white)) ///
	ytitle("RI P Value", axis(2)) ///
	ytitle("Incentives x Bad AG DD Treatment Effect", axis(1)) ///
	xtitle("AG June Share Threshold (%)") ///
	yscale(axis(2) alt) ///
	yscale(axis(1) alt) ///
	legend(off) ///
	ylabel(0(0.25)1, axis(2) grid) ///
	yline(0.05, axis(2) lcolor(gs11) lpattern(dash)) ///
	yline(0, axis(1) lcolor(black%70)) ///
	xsize(10) ///
	ysize(4)
graph export "${picsdir}/FigureF1B.pdf", replace
graph export "${picsdir}/FigureF1B.eps", replace




