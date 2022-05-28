use "${rawdata}/MechanismsSurvey.dta", clear

drop m1j_desc m3e_desc m4e_desc m5e_desc m6j_desc
drop if TreatmentAssig > 4
egen strata = group(DepartmentId DistrictId)

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

*************************************
*Creating variables to fill in later* 									
gen totalcount = .
gen verycount = . 
gen somewhatcount = . 
gen notcount = .  

gen sharevery_control = . 
gen sharesomewhat_control = . 
gen sharenot_control = . 

foreach j in `c(alpha)' {
  if "`j'" <= "e" {

  	count if inlist(m3`j',1,2,3) & TreatmentAssig == 4 
  	replace totalcount = r(N) if option == "`j'"
  	count if inlist(m3`j',1) & TreatmentAssig == 4 
  	replace verycount = r(N) if option == "`j'"
  	count if inlist(m3`j',2) & TreatmentAssig == 4 
  	replace somewhatcount = r(N) if option == "`j'"
  	count if inlist(m3`j',3) & TreatmentAssig == 4 
  	replace notcount = r(N) if option == "`j'"
  	
  	replace sharevery_control = verycount / totalcount if option == "`j'"
  	replace sharesomewhat_control = somewhatcount / totalcount if option == "`j'"
  	replace sharenot_control = notcount / totalcount if option == "`j'"
	}
}

encode option, gen(option2)
drop option 
rename option2 option

gen optionvery = option + 0.2 
gen optionsomewhat = option
gen optionnot = option - 0.2

**People in the control group
twoway (bar sharevery_control optionvery, horizontal barw(0.2) color("black")) ///
	(bar sharesomewhat_control optionsomewhat, horizontal barw(0.2) color("gs6")) ///
	(bar sharenot_control optionnot, horizontal barw(0.2) color("gs12") ///
	graphregion(color(white)) ///
	ylabel(1 "If documentation is not proper and complete" ///
		2 "If the price we procure at is too high" ///
		3.2 "If the quality of the goods we buy is not good -" /// 
		3 "i.e. not durable or not fit for purpose" ///
		4.2 "If the vendor we select is not adequate –" ///
		4 "either unreliable, or provides poor" ///
		3.8 "quality after sales service" ///
		5.1 "Other procurement-related issues that" ///
		4.9 "could damage my career", ///
		angle(horizontal) ///
		labsize(vsmall) ///
		noticks ///
		nogrid) ///
	xlabel(0(0.2)1, labsize(vsmall)) ///
	xtitle("Share", size(vsmall)) ///
	ytitle("") ///
	title("Please Rate How Damaging Each of the Following Could Be For Your Career Prospects", size(medsmall) span) ///
	legend(order(1 2 3)) ///
	legend(label(1 "Very Damaging")) ///
	legend(label(2 "Somewhat Damaging")) ///
	legend(label(3 "Not Damaging")) ///
	legend(size(vsmall)))

graph export "${picsdir}/FigureA2.pdf", replace			
graph export "${picsdir}/FigureA2.eps", replace			
