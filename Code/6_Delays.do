
*Load the data
use "${usedata}/UsingData.dta", clear

*Create delay variables
gen delay_DelToApp = DocumentDate-time
gen delay_DelToSub = TokenDay - time
gen delay_SubToApp = DocumentDate - TokenDay
assert delay_DelToApp == delay_DelToSub + delay_SubToApp | TokenDay == .
foreach var of varlist delay_DelToApp delay_DelToSub delay_SubToApp {
	replace `var' = . if `var' < 0 | `var' > 365
}
gen Year2Delivery = (time > date("30Jun2015","DMY"))
gen Y2DelInc = Year2Delivery * Incentives0
gen Y2DelAut = Year2Delivery * Rules0
gen Y2DelBot = Year2Delivery * Both0

gen DeliveryMonth = mofd(time)
gen DeliveryMofY = month(time)
format DeliveryMonth %tm
gen moAg=month(DocumentDate)
gen moAg6=moAg==6

gen exp=exp(lUnitPrice)*exp(lQuantity)
gen lexp=ln(exp+1)

cap drop _merge
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .

*===============================================================*
*	1. TREATMENT EFFECTS ON DISTRIBUTION OF DELAYS (Figure 7a)	*
*===============================================================*

*Create regression variables and run regression
local ests = ""

forvalues k=0(30)240 {
	capture drop delta_DelToApp_`k'
	gen delta_DelToApp_`k'= (delay_DelToApp > `k' & delay_DelToApp != .)
	su delta_DelToApp_`k' if Treat==4 & Year2Delivery == 0, meanonly
	gen rdelta_DelToApp_`k' = delta_DelToApp_`k' / `r(mean)'
	capture drop Cdelta_DelToApp_`k'
	gen Cdelta_DelToApp_`k' = (delay_DelToApp <= `k' & Treatment == 4 & Year2Delivery == 0)
	reg rdelta_DelToApp_`k' i.NewItemID i.strata Rules0 Incentives0 Both0 if  ///
			Year2Delivery == 1 & delay_DelToApp != . [aweight=ExpInCtrl]
	estimates store delay_DelToApp_`k'
	local ests = "`ests'" + " delay_DelToApp_`k'"
	di "`ests'"
}
*create the cdfs to overlay
capture drop N
gen N = 1 if Treatment == 4 & Year2Delivery == 0 & delay_DelToApp != .
tempfile cdfs
preserve
	collapse (sum) Cdelta_DelToApp* N
	reshape long Cdelta_DelToApp_, i(N) j(delay)
	gen DeliveryCDF = Cdelta_DelToApp_ / N
	keep delay *CDF
	save `cdfs'
restore

global colorT1 = "gs10"
global colorT2 = "black"
global colorT3 = "gs5"
global colorT4 = "15 157 88"

*Seemingly unrelated regressions to get correct standard errors
**Set y axis scales
global DelToAppScale = ""
di "`ests'"
suest `ests'
preserve
	regsave *Incentives0 *Rules0 *Both0, ci nose
	split var, parse(":")
	drop var
	ren var2 var
	destring var1, ignore("delay_DToApSubmn") replace
	ren var1 delay
	*Pictures
	merge m:1 delay using `cdfs'
	gen delaypicpos = delay
	replace delaypicpos = delay - 5 if var == "Rules0"
	replace delaypicpos = delay + 5 if var == "Both0"
	twoway (area DeliveryCDF delay if var == "Rules0", ///
				yaxis(2) ///
				color(gs12%50)) ///
		(rcap ci_upper ci_lower delaypicpos if var == "Rules0", ///
			yaxis(1) ///
			color("${colorT2}%50")) ///
		(rcap ci_upper ci_lower delaypicpos if var == "Incentives0", ///
			yaxis(1) ///
			color("${colorT1}%50")) ///
		(rcap ci_upper ci_lower delaypicpos if var == "Both0", ///
			yaxis(1) ///
			color("${colorT3}%50")) ///
		(scatter coef delaypicpos if var == "Rules0", ///
			yaxis(1) ///
			color("${colorT2}")) ///
		(scatter coef delaypicpos if var == "Incentives0", ///
			yaxis(1) ///
			color("${colorT1}") ///
			msymbol(s)) ///
		(scatter coef delaypicpos if var == "Both0", ///
			yaxis(1) ///
			color("${colorT3}") ///
			msymbol(d)), ///
		yscale(alt axis(1)) ///
		ylabel(-.75(.25)0.5, axis(1) angle(horizontal)) ///
		yline(0, axis(1) lcolor(black)) ///
		yscale(alt axis(2)) ///
		ylabel(0(.2)1, axis(2) angle(horizontal)) ///
		xlabel(0(30)240) ///
		graphregion(color(white)) ///
		xtitle("Delay Duration (days)") ///
		ytitle("Treatment Effect on 1 - F(Delay)", axis(1)) ///
		ytitle("Control Group F(Delay)", axis(2)) ///
		legend(order(5 6 7)) ///
		legend(rows(1)) ///
		legend(label(5 "Autonomy")) ///
		legend(label(6 "Incentives")) ///
		legend(label(7 "Both"))
	graph export "${picsdir}/Figure7A.pdf", replace
	graph export "${picsdir}/Figure7A.eps", replace
restore

*=======================================================================*
*	2. HETEROGENEITY OF DELAY EFFECT IN AUTONOMY BY AG TYPE (Figure 7B)	*
*=======================================================================*

*Heterogeneity by AG Type
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

gen Incentives0Bad = Incentives0 * agD_l48
gen Incentives0Good = Incentives0 * (1 - agD_l48)
for var Rules0 Both0: gen XBad = X * agD_l22
for var Rules0 Both0: gen XGood = X * (1 - agD_l22)

estimates clear
local ests = ""
forvalues k=0(30)240 {
	reg rdelta_DelToApp_`k' i.NewItemID i.strata Rules0B Incentives0B Both0B ///
		Rules0G Incentives0G Both0G if Year2Delivery == 1 ///
		[aweight=ExpInCtrl], noc
	estimates store delay_DelToApp_`k'
	local ests = "`ests'" + " delay_DelToApp_`k'"
	di "`ests'"
}
*Seemingly unrelated regressions to get correct standard errors
di "`ests'"
suest `ests'
preserve
	regsave *Incentives0Bad *Incentives0Good *Rules0Bad *Rules0Good *Both0Bad *Both0Good, ci nose
	split var, parse(":")
	drop var
	ren var2 var
	destring var1, ignore("delay_DToApSubmn") replace
	ren var1 delay
	gen delaypicpos = delay
	replace delaypicpos = delay - 3 if var == "Rules0Good"
	replace delaypicpos = delay + 3 if var == "Rules0Bad"
	*Pictures
	twoway (rcap ci_upper ci_lower delaypicpos if var == "Rules0Good", ///
			color("gs8%50")) ///
		(rcap ci_upper ci_lower delaypicpos if var == "Rules0Bad", ///
			color("black%50")) ///
		(scatter coef delaypicpos if var == "Rules0Good", ///
			color("gs8") ///
			msymbol(s)) ///
		(scatter coef delaypicpos if var == "Rules0Bad", ///
			color("black")), ///
		ylabel(-.4(.1).4, angle(horizontal)) ///
		yline(0, lcolor(black)) ///
		xlabel(0(30)240, grid) ///
		graphregion(color(white)) ///
		xtitle("Delay Duration (days)") ///
		ytitle("Treatment Effect on 1 - F(Delay)") ///
		legend(order(3 4)) ///
		legend(label(3 "Good AG")) ///
		legend(label(4 "Bad AG")) ///
		legend(ring(0) pos(7))
	graph export "${picsdir}/Figure7B.pdf", replace
	graph export "${picsdir}/Figure7B.eps", replace
restore

*================================================*
*	3. HOLDUP AT THE END OF THE YEAR (figure 8A) *
*================================================*

egen MonTreat =  group(DeliveryMonth Treatment) if Treatment != 4, label
replace MonTreat = 0 if MonTreat == .
tempfile labels
preserve
	keep MonTreat
	duplicates drop
	decode MonTreat, gen(MonTreatLabel)
	save `labels'
restore
tempfile holdupcdf
preserve
	keep if Year2Delivery == 1 & inlist(Treatment,2,4)
	collapse (mean) moAg6, by(DeliveryMonth Treatment)
	ren moAg6 RawProb
	save `holdupcdf'
restore
reg moAg6 ib0.MonTreat ibn.DeliveryMonth i.NewItemID i.strata if ///
	Year2Delivery == 1 & time < date("01Jul2016","DMY") [aweight=ExpInCtrl], noc
	
preserve
	regsave, nose ci
	split var, parse(".")
	keep if var2 == "MonTreat"
	drop var var2
	destring var1, ignore("bn") replace
	ren var1 MonTreat
	merge 1:1 MonTreat using `labels', keep(1 3) nogen
	split MonTreatLabel, parse(" ")
	destring MonTreatLabel1, replace
	ren MonTreatLabel1 DeliveryMonth
	format DeliveryMonth %tm
	destring MonTreatLabel2, replace
	ren MonTreatLabel2 Treatment
	merge m:1 DeliveryMonth Treatment using `holdupcdf'
	gen barmonth = DeliveryMonth
	replace barmonth = DeliveryMonth - 0.2 if Treatment == 2
	replace barmonth = DeliveryMonth + 0.2 if Treatment == 4
	drop if DeliveryMonth > 677
	
	twoway (bar Raw barmonth if Treatment == 2, ///
				yaxis(2) ///
				color("black%50") ///
				barwidth(0.4)) ///
		(bar Raw barmonth if Treatment == 4, ///
			yaxis(2) ///
			color("gs8%50") ///
			barwidth(0.4)) ///
		(rcap ci_upper ci_lower DeliveryMonth if Treatment == 2, ///
			yaxis(1) ///
			color(gs8)) ///
		(scatter coef DeliveryMonth if Treatment == 2, ///
			yaxis(1) ///
			color("black")), ///
		ylabel(-.2(.1).3, angle(horizontal) axis(2)) ///
		yscale(alt axis(1)) ///
		ylabel(-.4(.1).4, angle(horizontal)) ///
		ysc(r(-.46 .42)) ///
		yscale(alt axis(2)) ///
		ylabel(0(.2)1, axis(2) angle(horizontal)) ///
		ytitle("Treatment Effect on Pr(Approved in June)", axis(1)) ///
		graphregion(color(white)) ///
		xtitle("Month") ///
		ytitle("Delivery Date Distributions", axis(2)) ///
		legend(off) ///
		yline(0, lcolor(black))
	graph export "${picsdir}/Figure8A.pdf", replace
	graph export "${picsdir}/Figure8A.eps", replace
restore

*===========================*
*	4. HOLDUP BY AG TYPE	*
*===========================*

*Regression version
capture drop MonTreat
egen MonTreat =  group(DeliveryMonth Treatment) if Treatment != 4, label(MonTreat, replace)
replace MonTreat = 0 if MonTreat == .
tempfile labels
preserve
	keep MonTreat
	duplicates drop
	decode MonTreat, gen(MonTreatLabel)
	save `labels'
restore
reg moAg6 ib0.MonTreat ibn.DeliveryMonth i.NewItemID i.strata if ///
	Year2Delivery == 1 & time < date("01Jul2016","DMY") & agD_l22 == 0 [aweight=ExpInCtrl], noc
regsave using "${tempdir}/HoldupAGGood.dta", nose ci replace
reg moAg6 ib0.MonTreat ibn.DeliveryMonth i.NewItemID i.strata if ///
	Year2Delivery == 1 & time < date("01Jul2016","DMY") & agD_l22 == 1 [aweight=ExpInCtrl], noc
regsave using "${tempdir}/HoldupAGBad.dta", nose ci replace

preserve
	use "${tempdir}/HoldupAGGood.dta", clear
	gen Bad = 0
	append using "${tempdir}/HoldupAGBad.dta"
	replace Bad = 1 if Bad == .
	split var, parse(".")
	keep if var2 == "MonTreat"
	drop var var2
	destring var1, ignore("bn") replace
	ren var1 MonTreat
	merge m:1 MonTreat using `labels', keep(1 3) nogen
	split MonTreatLabel, parse(" ")
	destring MonTreatLabel1, replace
	ren MonTreatLabel1 DeliveryMonth
	format DeliveryMonth %tm
	destring MonTreatLabel2, replace
	ren MonTreatLabel2 Treatment
	gen picpos = DeliveryMonth
	replace picpos = DeliveryMonth - 0.1 if Bad == 0
	replace picpos = DeliveryMonth + 0.1 if Bad == 1
	format picpos %tm
	twoway (rcap ci_upper ci_lower picpos if Treatment == 2 & Bad == 0, ///
			color("gs8%50")) ///
		(rcap ci_upper ci_lower picpos if Treatment == 2 & Bad == 1, ///
			color("black%50")) ///
		(scatter coef picpos if Treatment == 2 & Bad == 0, ///
			color("gs8") ///
			msymbol(s)) ///
		(scatter coef picpos if Treatment == 2 & Bad == 1, ///
			color("black")), ///
		ylabel(-.4(.1).4, angle(horizontal)) ///
		ysc(r(-.46 .42)) ///
		ytitle("Treatment Effect on Pr(Approved in June)") ///
		graphregion(color(white)) ///
		xtitle("Month") ///
		legend(order(3 4)) ///
		legend(label(3 "Good AG")) ///
		legend(label(4 "Bad AG")) ///
		yline(0, lcolor(black))
	graph export "${picsdir}/Figure8B.pdf", replace
	graph export "${picsdir}/Figure8B.eps", replace
restore

*=======================================================*
*	5. DECOMPOSITION OF DELAYS FOR AUTONOMY (Figure A9)	*
*=======================================================*

*Create regression variables and run regression
local ests_DelToSub = ""
local ests_SubToApp = ""

forvalues k=0(30)240 {
	capture drop delta_DelToSub_`k'
	gen delta_DelToSub_`k'= (delay_DelToSub > `k' & delay_DelToSub != .)
	su delta_DelToSub_`k' if Treat==4 & Year2Delivery == 0, meanonly
	gen rdelta_DelToSub_`k' = delta_DelToSub_`k' / `r(mean)'
	capture drop Cdelta_DelToSub_`k'
	gen Cdelta_DelToSub_`k' = (delay_DelToSub <= `k' & Treatment == 4 & Year2Delivery == 0)
	reg rdelta_DelToSub_`k' i.NewItemID i.strata Rules0 Incentives0 Both0 if  ///
			Year2Delivery == 1 & delay_DelToSub != . [aweight=ExpInCtrl]
	estimates store delay_DelToSub_`k'
	local ests_DelToSub = "`ests_DelToSub'" + " delay_DelToSub_`k'"
	di "`ests_DelToSub'"
}
forvalues k=0(5)100 {
	capture drop delta_SubToApp_`k'
	gen delta_SubToApp_`k'= (delay_SubToApp > `k' & delay_SubToApp != .)
	sum delta_SubToApp_`k' if Treat == 4 & Year2Delivery == 0, meanonly
	gen rdelta_SubToApp_`k' = delta_SubToApp_`k' / `r(mean)'
	capture drop Cdelta_SubToApp_`k'
	gen Cdelta_SubToApp_`k' = (delay_SubToApp <= `k' & Treatment == 4 & Year2Delivery == 0)
	reg delta_SubToApp_`k' i.NewItemID i.strata Rules0 Incentives0 Both0 if Year2Delivery == 1 & delay_SubToApp != . ///
					[aweight=ExpInCtrl]
	estimates store delay_SubToApp_`k'
	local ests_SubToApp = "`ests_SubToApp'" + " delay_SubToApp_`k'"
	di "`ests_SubToApp'"
}


*create the cdfs to overlay
foreach v in "DelToSub" "SubToApp" {
	capture drop N_`v'
	gen N_`v' = 1 if Treatment == 4 & Year2Delivery == 0 & delay_`v' != .
	tempfile cdfs`v'
	preserve
		collapse (sum) Cdelta_`v'* N_`v'
		reshape long Cdelta_`v'_, i(N_`v') j(delay)
		gen DeliveryCDF = Cdelta_`v'_ / N_`v'
		keep delay *CDF
		save `cdfs`v''
	restore
}
*Seemingly unrelated regressions to get correct standard errors
**Set y axis scales
di "`ests_DelToSub'"
suest `ests_DelToSub'
preserve
	regsave *Incentives0 *Rules0 *Both0, ci nose
	split var, parse(":")
	drop var
	ren var2 var
	destring var1, ignore("delay_DToApSubmn") replace
	ren var1 delay
	*Pictures
	merge m:1 delay using `cdfsDelToSub'
	twoway (area DeliveryCDF delay if var == "Rules0", ///
				yaxis(2) ///
				color(gs12%50)) ///
		(rcap ci_upper ci_lower delay if var == "Rules0", ///
			yaxis(1) ///
			color(gs8)) ///
		(scatter coef delay if var == "Rules0", ///
			yaxis(1) ///
			color("black")), ///
		yscale(alt axis(1)) ///
		ylabel(-.75(.25)0.5, axis(1) angle(horizontal)) ///
		yline(0, axis(1) lcolor(black)) ///
		yscale(alt axis(2)) ///
		ylabel(0(.2)1, axis(2) angle(horizontal)) ///
		xlabel(0(30)240) ///
		graphregion(color(white)) ///
		xtitle("Delay Between Delivery and Document Submission (days)") ///
		ytitle("Treatment Effect on 1 - F(Delay)", axis(1)) ///
		ytitle("Control Group F(Delay)", axis(2)) ///
		legend(off)
	graph export "${picsdir}/FigureA9A.pdf", replace
	graph export "${picsdir}/FigureA9A.eps", replace
restore
di "`ests_SubToApp'"
suest `ests_SubToApp'
preserve
	regsave *Incentives0 *Rules0 *Both0, ci nose
	split var, parse(":")
	drop var
	ren var2 var
	destring var1, ignore("delay_DToApSubmn") replace
	ren var1 delay
	*Pictures
	merge m:1 delay using `cdfsSubToApp'
	twoway (area DeliveryCDF delay if var == "Rules0", ///
				yaxis(2) ///
				color(gs12%50)) ///
		(rcap ci_upper ci_lower delay if var == "Rules0", ///
			yaxis(1) ///
			color(gs8)) ///
		(scatter coef delay if var == "Rules0", ///
			yaxis(1) ///
			color("black")), ///
		yscale(alt axis(1)) ///
		ylabel(-.15(.025).025, axis(1) angle(horizontal)) ///
		yline(0, axis(1) lcolor(black)) ///
		yscale(alt axis(2)) ///
		ylabel(0(.2)1, axis(2) angle(horizontal)) ///
		xlabel(0(10)100) ///
		graphregion(color(white)) ///
		xtitle("Delay Between Document Submission and Approval (days)") ///
		ytitle("Treatment Effect on 1 - F(Delay)", axis(1)) ///
		ytitle("Control Group F(Delay)", axis(2)) ///
		legend(off)
	graph export "${picsdir}/FigureA9B.pdf", replace
	graph export "${picsdir}/FigureA9B.eps", replace
restore
