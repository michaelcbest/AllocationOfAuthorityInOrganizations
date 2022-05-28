
use "${usedata}/UsingData.dta", clear
gen Year2Delivery = (time > date("30Jun2015","DMY") & time <= date("30Jun2016","DMY"))
keep if Year2Delivery == 1
gen DeliveryMonth = mofd(time)
gen DeliveryMofY = month(time)
format DeliveryMonth %tm
gen moAg=month(DocumentDate)
gen moAg6=moAg==6

gen exp=exp(lUnitPrice)*exp(lQuantity)
gen lexp=ln(exp)

*=======================*
*	2. RUN REGRESSIONS	*
*=======================*
local ests_nitems 	= "" //list of regressions of number of deliveries
local ests_exp 		= "" //list of regressions of expenditure
local ests_lexp		= "" //list of regressions of log expenditure
forvalues k=666/677 {
	gen Delivery`k' = (DeliveryMonth == `k')
	*number of deliveries
	reg Delivery`k' i.NewItemID i.strata Rules0 Incentives0 Both0
	estimates store nitems_`k'
	local ests_nitems = "`ests_nitems'" + " nitems_`k'"
	*expenditure
	reg Delivery`k' i.NewItemID i.strata Rules0 Incentives0 Both0 [aweight=exp]
	estimates store exp_`k'
	local ests_exp = "`ests_exp'" + " exp_`k'"
	*log expenditure
	reg Delivery`k' i.NewItemID i.strata Rules0 Incentives0 Both0 [aweight=lexp]
	estimates store lexp_`k'
	local ests_lexp = "`ests_lexp'" + " lexp_`k'"
}


*=======================*
*	3.PDFs to overlay	*
*=======================*

capture drop NDeliveryMonth 
gen NDeliveryMonth = lexp if Treatment == 4 & Year2Delivery == 1
tempfile pdfs
preserve
	keep if Treatment == 4 & DeliveryMonth >= 666 & DeliveryMonth <= 677
	collapse (count) nitems = time (sum) exp lexp, by(DeliveryMonth)
	foreach v of varlist nitems lexp {
		sum `v'
		gen `v'PDF = `v' / `r(sum)'
		drop `v'
	}
	save `pdfs'
restore


*===============================================*
*	4. SUEST to get correct standard errors,	*
*		get p-values for pictures, and			*
*		draw pictures							*
*===============================================*

*Macros for pictures
global ytitle1_nitems "Treatment Effect on pr(Delivery This Month)"
global ytitle1_lexp "Treatment Effect on log Expenditure Share"
global ytitle2_nitems "Control Group Delivery Distribution"
global ytitle2_lexp "Control Group log Expenditure Distribution"

tokenize "`c(ALPHA)'"
local panel = 1
foreach o in "nitems" "lexp" {
	*Seemingly unrelated regressions to get correct standard errors
	suest `ests_`o'', vce(cluster CCID)
	*p-values
	test Incentives0
	global pInc = string(`r(p)',"%05.3f")
	test Rules0
	global pAut = string(`r(p)',"%05.3f")
	test Both0
	global pBot = string(`r(p)',"%05.3f")
	test Incentives0 Rules0 Both0
	global pAll = string(`r(p)',"%05.3f")
	*draw picture
	preserve
		regsave *Incentives0 *Rules0 *Both0, ci nose
		split var, parse(":")
		drop var
		ren var2 var
		destring var1, ignore("nitemslxp_a") replace
		ren var1 DeliveryMonth
		format DeliveryMonth %tm
		merge m:1 DeliveryMonth using `pdfs'
		gen xpos = DeliveryMonth
		format xpos %tm
		replace xpos = DeliveryMonth - 0.175 if var == "Rules0"
		replace xpos = DeliveryMonth + 0.175 if var == "Both0"
		twoway (bar `o'PDF DeliveryMonth if var == "Incentives0", ///
					yaxis(2) ///
					color(gs13%40)) ///
			(rcap ci_upper ci_lower xpos if var == "Rules0", ///
				yaxis(1) ///
				color("black%70") ///
				msize(small)) ///
			(rcap ci_upper ci_lower xpos if var == "Incentives0", ///
				yaxis(1) ///
				color("gs12%70") ///
				lpattern(dash) ///
				msize(small)) ///
			(rcap ci_upper ci_lower xpos if var == "Both0", ///
				yaxis(1) ///
				color("gs6%70") ///
				lpattern(shortdash_dot) ///
				msize(small)) ///
			(scatter coef xpos if var == "Rules0", ///
				yaxis(1) ///
				color("black") ///
				msize(vsmall)) ///
			(scatter coef xpos if var == "Incentives0", ///
				yaxis(1) ///
				color("gs12") ///
				msymbol(s) ///
				msize(vsmall)) ///
			(scatter coef xpos if var == "Both0", ///
				yaxis(1) ///
				color("gs6") ///
				msymbol(d) ///
				msize(vsmall)), ///
			yscale(alt axis(1)) ///
			ylabel(-.1(.025).1, axis(1) angle(horizontal)) ///
			yscale(alt axis(2)) ///
			ylabel(0(.025).2, axis(2) angle(horizontal)) ///
			graphregion(color(white)) ///
			xtitle("Month") ///
			ytitle("${ytitle1_`o'}", axis(1)) ///
			ytitle("${ytitle2_`o'}", axis(2)) ///
			legend(order(2 3 4)) ///
			legend(label(2 "Autonomy")) ///
			legend(label(3 "Incentives")) ///
			legend(label(4 "Both")) ///
			legend(cols(1)) ///
			legend(position(4) ring(0)) ///
			yline(0, lcolor(black)) ///
			text(.1 677.5 "Autonomy  Incentives   Both       All", placement(w)) ///
			text(.09 668.3 "{&chi}{superscript:2} p-value:") ///
			text(.09 670.85 "${pAut}") ///
			text(.09 673.4 "${pInc}") ///
			text(.09 675.3 "${pBot}") ///
			text(.09 677 "${pAll}")
		graph export "${picsdir}/FigureE1``panel''.pdf", replace
		local panel = `panel' + 1
	restore
}
