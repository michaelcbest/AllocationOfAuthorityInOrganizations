use "${usedata}/UsingData.dta", clear
keep if Fiscal_Year == "2014-15" & GroupFinal == 4
gen moAg=month(DocumentDate)
gen agJune = (moAg == 6)
gen moDel = month(time)
gen delJune = (moDel == 6)	
collapse (mean) agJune delJune, by(District)
list
save "${usedata}/JuneSpikes.dta", replace
