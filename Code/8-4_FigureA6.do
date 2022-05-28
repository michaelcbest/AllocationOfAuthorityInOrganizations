tempfile ourccs
use "${usedata}/UsingData.dta", clear
keep CostCenterCode Treatment
duplicates drop
isid CostCenterCode
save `ourccs'

use "${rawdata}/ZRPmaster", clear
keep if Fiscal_Year == "2015-16"
rename Cost_center CostCenterCode 
merge m:1 CostCenterCode using `ourccs', keep(1 3)
gen AnalysisData = (_merge == 3)
drop _merge 

gen Treated = inlist(Treatment,1,2,3)
gen TreatedinAnalysis = Treated * AnalysisData

duplicates drop User_Name CostCenterCode, force
collapse (count) ccperusername = Treated (sum) ccperusernameAD=AnalysisData treatedperuserAD=TreatedinAnalysis, by(User_Name)

gen shareAD = ccperusernameAD / ccperusername
gen sharetreatanalysis = treatedperuserAD / ccperusername

hist sharetreatanalysis if shareAD > 0, bin(50) freq /// 
	graphregion(color(white)) ///
	lcolor(gs8) ///
	fcolor(gs11) ///
	xtitle("Share of Treated Public Bodies per AG Username")
graph export "${picsdir}/FigureA6.pdf", replace
graph export "${picsdir}/FigureA6.eps", replace
