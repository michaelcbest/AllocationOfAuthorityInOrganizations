*Question 4: Percentage of time spent on tasks to reduce amount cost center pays for goods wanted
use "${rawdata}/MechanismsSurvey.dta", clear

drop m1j_desc m3e_desc m4e_desc m5e_desc m6j_desc
drop if TreatmentAssig > 4
egen strata = group(DepartmentId DistrictId)
keep if InUsingData == 1

gen option = _n in 1/5
di "`c(alpha)'"
tokenize "`c(alpha)'"
forval j = 1/5 {
     label define alphabet `j' "``j''", add
}

label values option alphabet
decode option, gen(option2)
drop option 
rename option2 option  

egen totalm4 = rowtotal(m4*)

foreach j in `c(alpha)' {
  if "`j'" <= "e" {
	gen share_m4`j' = m4`j' / totalm4 
	}
} 

egen process=std((m4c+m4d))
egen process3 = std((share_m4c + share_m4d))
reg process3 ib4.TreatmentAssig [aweight=N], noc

*************************************
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

**Treatment Effects  
foreach j in `c(alpha)' {
  if "`j'" <= "e" {
	*reg share_m4`j' ibn.TreatmentAssig [aweight=N], noc 
	reg m4`j' ibn.TreatmentAssig [aweight=N], noc 
	replace b_control = _b[4.TreatmentAssig] if option == "`j'"
	replace b_incentives = _b[1.TreatmentAssig] if option == "`j'"
	replace b_autonomy = _b[2.TreatmentAssig] if option == "`j'"
	replace b_both = _b[3.TreatmentAssig] if option == "`j'"
	replace lb_incentives = _b[1.TreatmentAssig] - invttail(e(df_r),0.025)*_se[1.TreatmentAssig] if option == "`j'"
	replace ub_incentives = _b[1.TreatmentAssig] + invttail(e(df_r),0.025)*_se[1.TreatmentAssig] if option == "`j'"
	replace lb_autonomy = _b[2.TreatmentAssig] - invttail(e(df_r),0.025)*_se[2.TreatmentAssig] if option == "`j'"
	replace ub_autonomy = _b[2.TreatmentAssig] + invttail(e(df_r),0.025)*_se[2.TreatmentAssig] if option == "`j'"
	replace lb_both = _b[3.TreatmentAssig] - invttail(e(df_r),0.025)*_se[3.TreatmentAssig] if option == "`j'"
	replace ub_both = _b[3.TreatmentAssig] + invttail(e(df_r),0.025)*_se[3.TreatmentAssig] if option == "`j'"
	}
} 

encode option, gen(option2)
drop option 
rename option2 option

**Treatment effects plot
egen test = rank(b_control), unique
gen optionold = option
replace option = 6 - test
drop test
gen optionboth = option + 0.25
gen optionautonomy = option - 0.25
gen optioncontrol = option + 0.45
gen optionline = option + 0.04


global colorT1 = "gs10"
global colorT2 = "black"
global colorT3 = "gs5"
global colorT4 = "black"

twoway (scatter optionline b_control, ///
	mcolor("black") msymbol(|) msize(12) mlwidth(thick)) ///
	(rcap ub_incentives lb_incentives option, horizontal color("gs12") msize(small) lwidth(medthin)) ///
	(scatter option b_incentives, mcolor("gs12") msize(small) msymbol(T)) ///
	(rcap ub_autonomy lb_autonomy optionautonomy, horizontal color("black") msize(small) lwidth(medthin)) ///
	(scatter optionautonomy b_autonomy, mcolor("black") msize(small) msymbol(S)) ///
	(rcap ub_both lb_both optionboth, horizontal color("gs6") msize(small) lwidth(medthin)) ///
	(scatter optionboth b_both, mcolor("gs6") msize(small) msymbol(D)) ///
	(scatter optioncontrol b_control, mcolor("black") msize(small)), ///
	graphregion(color(white)) ///
	ylabel(3.7 "Surveying the market and/or" ///
		4 "asking colleagues/other POs to" ///
		4.3 "learn the lowest price available" ///
		2.85 "Negotiating with our regular" ///
		3.15 "vendors to lower their price" ///
		1.85 "Negotiating quicker" ///
		2.15 "approvals with AG office" ///
		0.85 "Instructing my staff" ///
		1.15 "and monitoring them" ///
		5 "Other things", ///
		angle(horizontal) ///
		labsize(medsmall) ///
		noticks ///
		nogrid) ///
	xlabel(, labsize(medsmall)) ///
	xtitle("", size(vsmall)) ///
	ytitle("") ///
	legend(order(5 3 7 8)) ///
	legend(label(3 "Incentives")) ///
	legend(label(5 "Autonomy")) ///
	legend(label(7 "Both")) ///
	legend(label(8 "Control")) ///
	legend(size(medsmall)) ///
	legend(position(5) ring(0)) ///
	legend(row(2)) ///
	yscale(reverse)

graph export "${picsdir}/FigureA12A.pdf", replace		
graph export "${picsdir}/FigureA12A.eps", replace		


*Question 6: Important characteristics of vendors when deciding which vendor(s) to buy from
use "${rawdata}/MechanismsSurvey.dta", clear

drop m1j_desc m3e_desc m4e_desc m5e_desc m6j_desc
drop if TreatmentAssig > 4
egen strata = group(DepartmentId DistrictId)
keep if InUsingData == 1

gen option = _n in 1/10
di "`c(alpha)'"
tokenize "`c(alpha)'"
forval j = 1/10 {
     label define alphabet `j' "``j''", add
}

label values option alphabet
decode option, gen(option2)
drop option 
rename option2 option  

egen totalm6 = rowtotal(m6*)

foreach j in `c(alpha)' {
  if "`j'" <= "j" {
	gen share_m6`j' = m6`j' / totalm6 
	}
} 

*************************************
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

**Treatment Effects  
foreach j in `c(alpha)' {
  if "`j'" <= "j" {
	reg m6`j' ibn.TreatmentAssig [aweight=N], noc 
	replace b_control = _b[4.TreatmentAssig] if option == "`j'"
	replace b_incentives = _b[1.TreatmentAssig] if option == "`j'"
	replace b_autonomy = _b[2.TreatmentAssig] if option == "`j'"
	replace b_both = _b[3.TreatmentAssig] if option == "`j'"
	replace lb_incentives = _b[1.TreatmentAssig] - invttail(e(df_r),0.025)*_se[1.TreatmentAssig] if option == "`j'"
	replace ub_incentives = _b[1.TreatmentAssig] + invttail(e(df_r),0.025)*_se[1.TreatmentAssig] if option == "`j'"
	replace lb_autonomy = _b[2.TreatmentAssig] - invttail(e(df_r),0.025)*_se[2.TreatmentAssig] if option == "`j'"
	replace ub_autonomy = _b[2.TreatmentAssig] + invttail(e(df_r),0.025)*_se[2.TreatmentAssig] if option == "`j'"
	replace lb_both = _b[3.TreatmentAssig] - invttail(e(df_r),0.025)*_se[3.TreatmentAssig] if option == "`j'"
	replace ub_both = _b[3.TreatmentAssig] + invttail(e(df_r),0.025)*_se[3.TreatmentAssig] if option == "`j'"
	}
} 

encode option, gen(option2)
drop option 
rename option2 option

**Treatment effects plot
egen test = rank(b_control), unique
gen optionold = option
replace option = 11 - test
drop test
gen optionboth = option + 0.25
gen optionautonomy = option - 0.25
gen optioncontrol = option + 0.45
gen optionline = option + 0.04

twoway (scatter optionline b_control, ///
		mcolor("black") msymbol(|) msize(vhuge) mlwidth(medthick)) ///
	(rcap ub_incentives lb_incentives option, horizontal color("gs12") msize(vsmall) lwidth(thin)) ///
	(scatter option b_incentives, mcolor("gs12") msize(vsmall) msymbol(T)) ///
	(rcap ub_autonomy lb_autonomy optionautonomy, horizontal color("black") msize(vsmall) lwidth(thin)) ///
	(scatter optionautonomy b_autonomy, mcolor("black") msize(vsmall) msymbol(S)) ///
	(rcap ub_both lb_both optionboth, horizontal color("gs6") msize(vsmall) lwidth(thin)) ///
	(scatter optionboth b_both, mcolor("gs6") msize(vsmall) msymbol(D)) ///
	(scatter optioncontrol b_control, mcolor("black") msize(vsmall)), ///
	graphregion(color(white)) ///
	ylabel(2.8 "Is willing to negotiate on price or" ///
		3.2 "provides goods at low prices" ///
		1 "Provides high quality goods" ///
		8 "Helps me get my bills passed at AG/DAO" ///
		6.8 "Provides me with goods on credit" ///
		7.2 "or provides credit for goods" ///
		5 "Delivers goods to my office" ///
		9 "I have a personal relationship with the vendor" ///
		3.8 "Provides me with all necessary" ///
		4.2 "documents for pre/post audit" ///
		5.8 "Purchasing from the vendor doesn’t" /// 
		6.2 "take up much of my time" ///
		2 "Provides goods quickly without delays" ///
		10 "Other", ///
		angle(horizontal) ///
		labsize(small) ///
		noticks ///
		nogrid) ///
	xlabel(, labsize(small) grid) ///
	xtitle("") ///
	ytitle("") ///
	legend(order(5 3 7 8)) ///
	legend(label(3 "Incentives")) ///
	legend(label(5 "Autonomy")) ///
	legend(label(7 "Both")) ///
	legend(label(8 "Control")) ///
	legend(size(small)) ///
	legend(position(4) ring(0)) ///
	legend(cols(1)) ///
	yscale(reverse)

graph export "${picsdir}/FigureA12B.pdf", replace		
graph export "${picsdir}/FigureA12B.eps", replace		


