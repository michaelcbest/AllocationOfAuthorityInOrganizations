
*Load the data
use "${rawdata}/MechanismsSurvey.dta", clear

drop m1j_desc
drop if TreatmentAssig > 4
egen strata = group(DepartmentId DistrictId)

*Question 1: Potential Reasons POs don't achieve good value for money
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

egen totalm1 = rowtotal(m1*)

foreach j in `c(alpha)' {
  if "`j'" <= "j" {
	gen share_m1`j' = m1`j' / totalm1 
	}
}

gen control = . 					
foreach j in `c(alpha)' {
  if "`j'" <= "j" {
	sum share_m1`j' if TreatmentAssig == 4 
	replace control = r(mean) if option == "`j'"
	}
}
replace control = control * 100


encode option, gen(option2)
drop option 
rename option2 option

**People in the control group
egen test = rank(control), unique
gen optionControl = 11 - test
drop test
twoway bar control optionControl, ///
	horizontal ///
	graphregion(color(white)) ///
	color("gs6") fintensity(inten70) ///
	ylabel(6.8 "Few vendors are willing" ///
		7.2 "to wait for delayed payment" ///
		5.8 "Vendors charge higher" ///
		6.2 "prices for delayed payment" ///
		8.8 "POs have nothing to gain" ///
		9.2 "by improving value for money" ///
		7.8 "POs are worried that changing" ///
		8.2 "vendors might raise red flags" ///
		0.8 "Budgets are released late"  ///
		1.2 "so POs cannot plan" ///
		2.8 "AG rules are not clear. Approval requires" ///
		3.2 "inside connections or speed money" ///
		1.8 "POs do not have enough petty" ///
		2.2 "cash to make purchases quickly" ///
		3.8 "Not enough training on" /// 
		4.2 "procurement procedures" ///
		4.8 "Offices cannot roll their budget" ///
		5.2 "over into the following year" ///
		10 "Other", ///
		angle(horizontal) ///
		labsize(small) ///
		noticks ///
		nogrid) ///
	xlabel(, labsize(small) grid) ///
	barwidth(0.8) ///
	xtitle("% of Points", size(small)) ///
	ytitle("") ///
	title("Potential Reasons Why POs Don’t Achieve Good Value for Money?", size(medsmall) span) ///
	legend(off)	///
	yscale(reverse)

graph export "${picsdir}/FigureA3.pdf", replace	
graph export "${picsdir}/FigureA3.eps", replace	
