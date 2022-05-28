
* Figure A.10 Panel B
use "${usedata}/JuneSpikes.dta", clear

twoway (line agJune agJune, lcolor(gs5)) ///
	(scatter agJune delJune, ///
		mcolor(gs2) msymbol(Oh)), ///
	graphregion(color(white)) ///
	xtitle("Share of Purchases in June") ///
	ytitle("Share of Approvals in June") ///
	xlab(,grid) ///
	text(0.89 0.95 "45{superscript:o} line", color(gs5)) ///
	legend(off)
graph export "${picsdir}/FigureA10B.pdf", replace
graph export "${picsdir}/FigureA10B.eps", replace
	
* Figure A.10 Panel A

**in POPS
use "${usedata}/UsingData.dta", clear

***Collapse to district * time
keep if Fiscal_Year == "2014-15" & GroupFinal == 4
drop if DocumentDate < date("01Jul2014","DMY")
gen moAg = mofd(DocumentDate)
format %tm moAg 
gen woAg = wofd(DocumentDate)
format %tw woAg
gen exp = exp(lUnitPrice) * exp(lQuantity)

merge m:1 District using "${usedata}/JuneSpikes.dta"
gen HiRush = (agJune > 0.4)
collapse (count) N = RequestID (sum) exp, by(HiRush moAg)
bys HiRush: egen NTotal = sum(N)
bys HiRush: egen ExpTotal = sum(exp)
gen Nfrac = N / NTotal
gen ExpFrac = exp / ExpTotal

twoway (line Nfrac moAg if HiRush == 0, lcolor(gs8) lwidth(medthick) lpattern(dash)) ///
	(line Nfrac moAg if HiRush == 1, lcolor(black) lwidth(medthick)), ///
		xtitle("Month") ///
		ytitle("Share of Purchases") ///
		legend(label(1 "Low June Share")) ///
		legend(label(2 "High June Share")) ///
		graphregion(color(white))
graph export "${picsdir}/FigureA10A.pdf", replace
graph export "${picsdir}/FigureA10A.eps", replace

