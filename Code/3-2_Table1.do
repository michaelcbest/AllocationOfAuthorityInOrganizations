*===========================*
*	1.Prepare the dataset	*
*===========================*

*budget variables
tempfile budgets
use "${usedata}/BERccyear.dta", clear
keep Cost_center Fiscal_Year FinalBudget* 
rename FinalBudget* *
drop Specific
replace Fiscal_Year = "1516" if Fiscal_Year == "2015-16"
replace Fiscal_Year = "1415" if Fiscal_Year == "2014-15"
reshape wide All A03 A09 A13 Universe Analysis, ///
		i(Cost_center) j(Fiscal_Year) string
rename Cost_center CostCenterCode
foreach v in All A03 A09 A13 Universe Analysis {
	foreach y in 1415 1516 {
		replace `v'`y' = 0 if `v'`y' == .
	}
}
isid  CostCenterCode
merge 1:m CostCenterCode using "${usedata}/UsingData.dta", ///
		keepusing(CostCenterCode OfficeID) ///
		assert(1 3) ///
		keep(3) ///
		nogen
duplicates drop
isid CostCenterCode
collapse (sum) All1415 All1516 A031415 A031516 A091415 A091516 A131415 ///
	A131516 Universe1415 Universe1516 Analysis1415 Analysis1516, ///
	by(OfficeID)
save `budgets'

use "${usedata}/UsingData.dta", clear
merge m:1 District using "${usedata}/JuneSpikes.dta"
replace agJune = 0 if agJune == .
collapse (mean) NCCs Treatment Department District agJune, by(OfficeID)
isid OfficeID
merge 1:1 OfficeID using `budgets', assert(3) keep(3) nogen

*Compute budget shares
foreach v in A03 A09 A13 Universe Analysis {
	foreach y in "1415" "1516" {
		gen bShare`v'`y' = `v'`y' / All`y'
	}
}
foreach y in "1415" "1516" {
	label var bShareA03`y'		"Operating Expenses"
	label var bShareA09`y'		"Physical Assets"
	label var bShareA13`y'		"Repairs \& Maintenance"
	label var bShareUniverse`y'	"POPS Universe"
	label var bShareAnalysis`y'	"Analysis Sample"
}

tempfile nactive
preserve
	use "${usedata}/UsingData.dta", clear
	keep CostCenterCode OfficeID NCCs
	duplicates drop
	collapse (count) NActiveCCs = NCCs, by(OfficeID)
	save `nactive'
restore
merge 1:1 OfficeID using `nactive', assert(3) keep(3) nogen

label var NCCs "Number of Accounting Entities"
label var NActiveCCs "Number of Public Bodies"
label var District "District"
label var Department "Department"
label var agJune "Share of June Approvals"

* DDO characteristics
tempfile ddos
preserve
	
	** list of DDOs
	use "${usedata}/UsingData.dta", clear
	keep RequestID DeliveryID time OfficeID Treatment
	merge 1:1 RequestID DeliveryID using "${usedata}/WhoIsDDO.dta", keep(3) assert(1 3)
	gen dt = abs(time - 20270) // 20270 is 2015-07-01, first day of year 2.
	bys OfficeID: egen closest = min(dt)
	keep if closest == dt
	duplicates drop OfficeID closest UserID, force
	keep OfficeID Treatment UserID
	
	** DDO characteristics
	ren UserID UserId
	merge m:1 UserId using "${rawdata}/UsersWithDemographics.dta", ///
		keep(3) assert(2 3) ///
		keepusing(PayGrade Gender DateOfBirth EducationLevel ComputerLiteracy) ///
		nogen
	*** age
	gen age = (clock("2015.07.01 00:00:00", "YMDhms") - DateOfBirth) / (1000*60*60*24*365.25)
	summ age if age > 25
	replace age = `r(mean)' if age <= 25
	label var age "Age"
	drop DateOfBirth
	*** gender
	replace Gender = "Male" if Gender == "1"
	tab Gender
	encode Gender, gen(dMale)
	replace dMale = dMale - 1
	drop Gender
	label var dMale "Male"
	*** Education
	gen Bachelors = inlist(EducationLevel,"Bachelors (2 Years)","Bachelors (3 Years)","Bachelors (4 Years)","Intermediate","Matriculate","Other") if EducationLevel != ""
	label var Bachelors "Bachelors Degree"
	gen Masters = inlist(EducationLevel,"M-Phill","MBBS","Masters","Masters (One Year)","Masters (Two Years)")  if EducationLevel != ""
	label var Masters "Masters Degree"
	gen PhD = (EducationLevel == "Ph.D") if EducationLevel != ""
	label var PhD "Ph.D Degree"
	drop EducationLevel
	*** Pay Grade
	gen Pay1618 = inlist(PayGrade,"16","17","18","18 + Special Pay") if PayGrade != ""
	label var Pay1618 "Pay Grade $\leq$ 18"
	gen Pay19 = inlist(PayGrade,"19") if PayGrade != ""
	label var Pay19 "Pay Grade 19"
	gen Pay20 = inlist(PayGrade,"20","22 + Special Pay") if PayGrade != ""
	label var Pay20 "Pay Grade $\geq$ 20"
	drop PayGrade
	
	save `ddos'
restore
merge 1:1 OfficeID using `ddos', nogen assert(1 3) keep(1 3)

* Number of DDOs
tempfile nddos
preserve
	
	** list of DDOs
	use "${usedata}/UsingData.dta", clear
	keep RequestID DeliveryID time OfficeID Treatment
	merge 1:1 RequestID DeliveryID using "${usedata}/WhoIsDDO.dta", keep(3) assert(1 3)
	keep OfficeID UserID
	duplicates drop
	collapse (count) NDDOs = UserID, by(OfficeID)
	label var NDDOs "\# POs During Experiment"
	isid OfficeID
	save `nddos'
	
restore
merge 1:1 OfficeID using `nddos', nogen assert(1 3) keep(1 3)

*===========================================*
*	2.Perform Balance checks and tabulate	*
*===========================================*

gen Incentives = (Treatment == 1)
gen Autonomy = (Treatment == 2)
gen Both = (Treatment == 3)

*Make a Pretty Table for the Paper and split it in three for the slides.
global ovars "NActiveCCs NCCs agJune NDDOs"
global dvars "age dMale Bachelors Masters PhD Pay1618 Pay19 Pay20"
global y1Sharevars "bShareA031415 bShareA091415 bShareA131415 bShareUniverse1415 bShareAnalysis1415"
global y2Sharevars "bShareA031516 bShareA091516 bShareA131516 bShareUniverse1516 bShareAnalysis1516"

capture	file close myfile
file open myfile using "${tabsdir}/Table1.tex", write replace

file		write myfile "\begin{longtable}{lccccc}" _n
file		write myfile "\caption{Balance Across Treatment Arms \label{tab:Balance}} \\" _n
file		write myfile "\toprule" _n
file		write myfile "& \textbf{Control} & \multicolumn{3}{c}{\textbf{Regression Coefficients}} & \textbf{Joint Test} \\ " _n
file		write myfile "\cmidrule(lr){3-5}" _n
file		write myfile " & \textbf{mean/sd} & \textbf{Incentives} & \textbf{Autonomy} & \textbf{Both} & \textbf{All = 0} \\ " _n
file		write myfile "\midrule" _n
file		write myfile "\endfirsthead" _n
file		write myfile "\multicolumn{6}{c}{\tablename\ \thetable\ -- \textit{Continued from previous page}} \\ " _n
file		write myfile "\toprule" _n
file		write myfile "& \textbf{Control} & \multicolumn{3}{c}{\textbf{Regression Coefficients}} & \textbf{Joint Test} \\ " _n
file		write myfile "\cmidrule(lr){3-5}" _n
file		write myfile " & \textbf{mean/sd} & \textbf{Incentives} & \textbf{Autonomy} & \textbf{Both} & \textbf{All = 0} \\ " _n
file		write myfile "\midrule" _n
file		write myfile "\endhead" _n
file		write myfile "\bottomrule \multicolumn{6}{r}{\textit{Continued on next page}} \\ " _n
file		write myfile "\endfoot" _n
file 		write myfile "\bottomrule" _n
file 		write myfile "\endlastfoot" _n

file write myfile " \multicolumn{6}{l}{\textit{Office Characteristics}} \\ " _n
foreach v in $ovars {
	global v `v'
	noisily do "${code}/3-2-1_GatherNumbers.do"

	*Table
	**Coefficients
	file write myfile " & $" %9.2f (${Cmean}) "$"
	file write myfile " & $" %9.3f (${coef2}) "$"
	file write myfile " & $" %9.3f (${coef1}) "$"
	file write myfile " & $" %9.3f (${coef3}) "$"
	file write myfile " & $" %9.3f (${F}) "$ \\ " _n
	**Ses
	file write myfile " $\quad$ ${name} " 
	file write myfile " & \{$" %9.3f (${Csd}) "$\} "
	file write myfile " & ($" %9.3f (${se2}) "$)${sestars2}"
	file write myfile " & ($" %9.3f (${se1}) "$)${sestars1}"
	file write myfile " & ($" %9.3f (${se3}) "$)${sestars3}"
	file write myfile " & [$" %9.3f (${Fp}) "$]${starsFp}"
	file write myfile " \\ " _n
	**RI p values
	file write myfile " & & [$" %9.3f (${pRI2}) "$]${sestarsRI2}"
	file write myfile " & [$" %9.3f (${pRI1}) "$]${sestarsRI1}"
	file write myfile " & [$" %9.3f (${pRI3}) "$]${sestarsRI3}"
	file write myfile " & [$" %9.3f (${FpRI}) "$]${starsFpRI}"
	file write myfile " \\ [0.5em] " _n
}
*Chi-2 tests for district and department
**district
preserve
	***create dataset of counts
	collapse (count) N = OfficeID, by(District Treatment)
	egen districtcode = group(District)
	drop District
	xtset Treatment districtcode
	tsfill
	replace N = 0 if N == .
	reshape wide N, i(districtcode) j(Treatment)
	drop if N4 == 0 | N4 == .
	***create counterfactual distribution for each treatment
	forvalues t = 1/3 {
		summ N4
		local Ncontrol = `r(sum)'
		summ N`t'
		local N`t' = `r(sum)'
		gen N`t'_cf = N4 * (`N`t'' / `Ncontrol')
	}
	***Chi-2 tests
	forvalues t = 1/3 {
		chitest N`t' N`t'_cf
		global p`t' = ${S_4}
		if ${p`t'} < 0.01 {
			global sestarsRI`t' = "$^{***}$"
		}
		else if ${p`t'} < 0.05 {
			global sestarsRI`t' = "$^{**}$"
		}
		else if ${p`t'} < 0.1 {
			global sestarsRI`t' = "$^{*}$"
		}
		else {
			global sestarsRI`t' = " "
		}
	}
	gen N0 = N1 + N2 + N3
	summ N4
	local Ncontrol = `r(sum)'
	summ N0
	local N0 = `r(sum)'
	gen N0_cf = N4 * (`N0' / `Ncontrol')
	chitest N0 N0_cf
	global p0 = ${S_4}
	if ${p0} < 0.01 {
		global sestarsRI0 = "$^{***}$"
	}
	else if ${p0} < 0.05 {
		global sestarsRI0 = "$^{**}$"
	}
	else if ${p0} < 0.1 {
		global sestarsRI0 = "$^{*}$"
	}
	else {
		global sestarsRI0 = " "
	}
restore
file write myfile " $\quad$ District ($\chi^{2}$ p-val) & " 
foreach t in 2 1 3 {
	file write myfile " & [ $" %9.3f (${p`t'}) "$]${sestarsRI`t'}"
}
file write myfile " & [ $" %9.3f (${p0}) "$]${sestarsRI0} \\ [0.5em]" _n
**department
preserve
	***create dataset of counts
	collapse (count) N = OfficeID, by(Department Treatment)
	egen departmentcode = group(Department)
	drop Department
	xtset Treatment departmentcode
	tsfill
	replace N = 0 if N == .
	reshape wide N, i(departmentcode) j(Treatment)
	drop if N4 == 0 | N4 == .
	***create counterfactual distribution for each treatment
	forvalues t = 1/3 {
		summ N4
		local Ncontrol = `r(sum)'
		summ N`t'
		local N`t' = `r(sum)'
		gen N`t'_cf = N4 * (`N`t'' / `Ncontrol')
	}
	***Chi-2 tests
	forvalues t = 1/3 {
		chitest N`t' N`t'_cf
		global p`t' = ${S_4}
		if ${p`t'} < 0.01 {
			global sestarsRI`t' = "$^{***}$"
		}
		else if ${p`t'} < 0.05 {
			global sestarsRI`t' = "$^{**}$"
		}
		else if ${p`t'} < 0.1 {
			global sestarsRI`t' = "$^{*}$"
		}
		else {
			global sestarsRI`t' = " "
		}
	}
	gen N0 = N1 + N2 + N3
	summ N4
	local Ncontrol = `r(sum)'
	summ N0
	local N0 = `r(sum)'
	gen N0_cf = N4 * (`N0' / `Ncontrol')
	chitest N0 N0_cf
	global p0 = ${S_4}
	if ${p0} < 0.01 {
		global sestarsRI0 = "$^{***}$"
	}
	else if ${p0} < 0.05 {
		global sestarsRI0 = "$^{**}$"
	}
	else if ${p0} < 0.1 {
		global sestarsRI0 = "$^{*}$"
	}
	else {
		global sestarsRI0 = " "
	}
restore
file write myfile " $\quad$ Department ($\chi^{2}$ p-val) & " 
foreach t in 2 1 3 {
	file write myfile " & [ $" %9.3f (${p`t'}) "$]${sestarsRI`t'}"
}
file write myfile " & [ $" %9.3f (${p0}) "$]${sestarsRI0} \\ [0.5em]" _n
file write myfile " \multicolumn{6}{l}{\textit{Procurement Officer Characteristics}} \\ " _n
foreach v in $dvars {
	global v `v'
	noisily do "${code}/3-2-1_GatherNumbers.do"

	*Table
	**Coefficients
	file write myfile " & $" %9.2f (${Cmean}) "$"
	file write myfile " & $" %9.3f (${coef2}) "$"
	file write myfile " & $" %9.3f (${coef1}) "$"
	file write myfile " & $" %9.3f (${coef3}) "$"
	file write myfile " & $" %9.3f (${F}) "$ \\ " _n
	**Ses
	file write myfile " $\quad$ ${name} " 
	file write myfile " & \{$" %9.3f (${Csd}) "$\} "
	file write myfile " & ($" %9.3f (${se2}) "$)${sestars2}"
	file write myfile " & ($" %9.3f (${se1}) "$)${sestars1}"
	file write myfile " & ($" %9.3f (${se3}) "$)${sestars3}"
	file write myfile " & [$" %9.3f (${Fp}) "$]${starsFp}"
	file write myfile " \\ " _n
	**RI p values
	file write myfile " & & [$" %9.3f (${pRI2}) "$]${sestarsRI2}"
	file write myfile " & [$" %9.3f (${pRI1}) "$]${sestarsRI1}"
	file write myfile " & [$" %9.3f (${pRI3}) "$]${sestarsRI3}"
	file write myfile " & [$" %9.3f (${FpRI}) "$]${starsFpRI}"
	file write myfile " \\ [0.5em] " _n
}
file write myfile " \multicolumn{6}{l}{\textit{Year-1 Budget Shares}} \\ " _n
foreach v in $y1Sharevars {
	global v `v'
	noisily do "${code}/3-2-1_GatherNumbers.do"

	*Table
	**Coefficients
	file write myfile " & $" %9.2f (${Cmean}) "$"
	file write myfile " & $" %9.3f (${coef2}) "$"
	file write myfile " & $" %9.3f (${coef1}) "$"
	file write myfile " & $" %9.3f (${coef3}) "$"
	file write myfile " & $" %9.3f (${F}) "$ \\ " _n
	**Ses
	file write myfile " $\quad$ ${name} " 
	file write myfile " & \{$" %9.3f (${Csd}) "$\} "
	file write myfile " & ($" %9.3f (${se2}) "$)${sestars2}"
	file write myfile " & ($" %9.3f (${se1}) "$)${sestars1}"
	file write myfile " & ($" %9.3f (${se3}) "$)${sestars3}"
	file write myfile " & [$" %9.3f (${Fp}) "$]${starsFp}"
	file write myfile " \\ " _n
	**RI p values
	file write myfile " & & [$" %9.3f (${pRI2}) "$]${sestarsRI2}"
	file write myfile " & [$" %9.3f (${pRI1}) "$]${sestarsRI1}"
	file write myfile " & [$" %9.3f (${pRI3}) "$]${sestarsRI3}"
	file write myfile " & [$" %9.3f (${FpRI}) "$]${starsFpRI}"
	file write myfile " \\ [0.5em] " _n
}
file write myfile " \multicolumn{6}{l}{\textit{Year-2 Budget Shares}} \\ " _n
foreach v in $y2Sharevars {
	global v `v'
	noisily do "${code}/3-2-1_GatherNumbers.do"

	*Table
	**Coefficients
	file write myfile " & $" %9.2f (${Cmean}) "$"
	file write myfile " & $" %9.3f (${coef2}) "$"
	file write myfile " & $" %9.3f (${coef1}) "$"
	file write myfile " & $" %9.3f (${coef3}) "$"
	file write myfile " & $" %9.3f (${F}) "$ \\ " _n
	**Ses
	file write myfile " $\quad$ ${name} " 
	file write myfile " & \{$" %9.3f (${Csd}) "$\} "
	file write myfile " & ($" %9.3f (${se2}) "$)${sestars2}"
	file write myfile " & ($" %9.3f (${se1}) "$)${sestars1}"
	file write myfile " & ($" %9.3f (${se3}) "$)${sestars3}"
	file write myfile " & [$" %9.3f (${Fp}) "$]${starsFp}"
	file write myfile " \\ " _n
	**RI p values
	file write myfile " & & [$" %9.3f (${pRI2}) "$]${sestarsRI2}"
	file write myfile " & [$" %9.3f (${pRI1}) "$]${sestarsRI1}"
	file write myfile " & [$" %9.3f (${pRI3}) "$]${sestarsRI3}"
	file write myfile " & [$" %9.3f (${FpRI}) "$]${starsFpRI}"
	file write myfile " \\ [0.5em] " _n
}
file write myfile " \midrule " _n
file write myfile " Number of Offices "
count if Treatment == 4
file write myfile " & " %7.0f (`r(N)')
count if Treatment == 2
file write myfile " & " %7.0f (`r(N)')
count if Treatment == 1
file write myfile " & " %7.0f (`r(N)')
count if Treatment == 3
file write myfile " & " %7.0f (`r(N)')
file write myfile " & \\ " _n
file		write myfile " \end{longtable}" _n
file		close myfile
