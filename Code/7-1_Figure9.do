
/*----------------------------------------------------*/
   /* [>   Total Time Spent on Procurement   <] */ 
/*----------------------------------------------------*/

*Make the Variable Total Time Spent on Procurement
use "${rawdata}/MechanismsSurvey.dta", clear

drop m1j_desc m3e_desc m4e_desc m5e_desc m6j_desc
drop if TreatmentAssig > 4
keep if InUsingData == 1
egen strata = group(DepartmentId DistrictId)

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

*Creating variables to fill in later* 									
gen b_control = .					
gen b_incentives = .				
gen b_autonomy = . 					
gen b_both = .						
									
gen lb_incentives = . 				
gen ub_incentives = . 				
gen lb_autonomy = . 				
gen ub_autonomy = . 				
gen lb_both = . 					
gen ub_both = .						
**************************************

*Treatment Effects  
summ ProcTime if TreatmentAssig == 4
global ctrlmean = `r(mean)'
reg ProcTime ib4.TreatmentAssig i.strata [aweight = N], r
replace b_control = ${ctrlmean} in 1
replace b_incentives = _b[1.TreatmentAssig] + ${ctrlmean} in 1
replace b_autonomy = _b[2.TreatmentAssig] + ${ctrlmean} in 1
replace b_both = _b[3.TreatmentAssig] + ${ctrlmean} in 1
replace lb_incentives = _b[1.TreatmentAssig] + ${ctrlmean} - invttail(e(df_r),0.025)*_se[1.TreatmentAssig] in 1
replace ub_incentives = _b[1.TreatmentAssig] + ${ctrlmean} + invttail(e(df_r),0.025)*_se[1.TreatmentAssig] in 1
replace lb_autonomy = _b[2.TreatmentAssig] + ${ctrlmean} - invttail(e(df_r),0.025)*_se[2.TreatmentAssig] in 1
replace ub_autonomy = _b[2.TreatmentAssig] + ${ctrlmean} + invttail(e(df_r),0.025)*_se[2.TreatmentAssig] in 1
replace lb_both = _b[3.TreatmentAssig] + ${ctrlmean} - invttail(e(df_r),0.025)*_se[3.TreatmentAssig] in 1
replace ub_both = _b[3.TreatmentAssig] + ${ctrlmean} + invttail(e(df_r),0.025)*_se[3.TreatmentAssig] in 1

*Treatment effects plot
keep b_* lb_* ub_*
gen i = 1
keep in 1
reshape long b_ lb_ ub_, i(i) j(Treatment) string
gen treat = 0
replace treat = 1 if Treatment == "autonomy"
replace treat = 2 if Treatment == "incentives"
replace treat = 3 if Treatment == "both"
sort treat

twoway (bar b_ treat, color("gs6%50") barwidth(0.75)) ///
	(rcap ub_ lb_ treat, color(gs5)), ///
	graphregion(color(white)) ///
	xlabel(0 "Control" 1 "Autonomy" 2 "Incentives" 3 "Combined") ///
	xtitle("") ///
	ysc(r(0 60)) ///
	legend(off) ///
	ylabel(0(10)60) ///
	yline(${ctrlmean}, lcolor("gs4"))

graph export "${picsdir}/Figure9.pdf", replace
graph export "${picsdir}/Figure9.eps", replace
