
* ITEMID 3346: Newspaper

use 		"${rawdata}/POPSData/NewItemID3346.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

drop 		if UnitPrice==.
count
global NObs = `r(N)'
summ UnitPrice, meanonly
global mPrice = `r(mean)'
count if Treatment == 4
global NObsControl = `r(N)'
summ UnitPrice if Treatment == 4, meanonly
global mPriceControl = `r(mean)'
gen Value = UnitPrice * Quantity
summ Quantity, meanonly
global mQuantity = `r(mean)'
summ Quantity if Treatment == 4, meanonly
global mQuantityControl = `r(mean)'
summ Value, meanonly
global mValue = `r(mean)'
summ Value if Treatment == 4, meanonly
global mValueControl = `r(mean)'
drop 		if UnitPrice>100
drop		if UnitPrice <=5

global 		Attributes = "NAME_OF_NEWSPAPER"	
global 		NumberOfAttributes = 1

global 		IVar = "NAME_OF_NEWSPAPER"
global 		NVar = ""

foreach 	var of varlist $Attributes {
label 		var `var' "`var'"
}

count
local 		totalobs = `r(N)'
_pctile		lUnitPrice, percentiles(1 99)
local 		lp = `r(r1)'
local 		up = `r(r2)'

count 		if lUnitPrice > `lp' & lUnitPrice <= `up'

if 			`r(N)' > (0.95 * `totalobs') {
			gen TrimmedSample = (lUnitPrice > `lp' & lUnitPrice <= `up')
}
else {
_pctile		lUnitPrice, percentiles(0.5 99.5)
local 		lp = `r(r1)'
local 		up = `r(r2)'

count 		if lUnitPrice > `lp' & lUnitPrice <= `up'
if 			`r(N)' > 0.95 * `totalobs' {
gen			TrimmedSample = (lUnitPrice > `lp' & lUnitPrice <= `up')
}
else {
gen TrimmedSample = 1
}
}

gen 		InReg = (inlist(Treatment,4,5) & TrimmedSample == 1)

/***
###Cleaning Attributes 

1-Some attribute values are duplicated with slightly different spelling 
2-Others are infrequent. 
3-Others only occur in groups 1-3
This part of code groups the attribute values. 

####Name of Newspaper
***/

di			"Before Cleaning"
tab			NAME InReg
replace 	NAME = "DAWN" if NAME == "DAWN SUNDAY"
replace 	NAME = "TIMES" if NAME == "PAKISTAN TIMES"
replace		NAME = "TRIBUNE" if NAME == "TURBAN"
replace		NAME = "4 Dailies" if NAME == `"DAWN,JANG,NAWA E WAQAT,THE NEWS"'
replace		NAME = "2 Dailies" if NAME == `"DUNIA AND EXPRESS"'
replace		NAME = "2 Dailies" if NAME == `"DAILY DUNIA AND EXPRESS"'
replace		NAME = "3 Dailies" if NAME == `"EXPRESS, JANG AND NAWAEWAQT"'
replace		NAME = "2 Dailies" if NAME == `"JANG AND DAWN"'
replace		NAME = "2 Dailies" if NAME == `"JANG AND DUNYA"'
replace		NAME = "2 Dailies" if NAME == `"JANG AND NAWA E WAQT"'
replace		NAME = "3 Dailies" if NAME == `"JANG NAWA WAQT DUNYA"'
replace		NAME = "2 Dailies" if NAME == `"JANG, EXPRESS"'
replace		NAME = "4 Dailies" if NAME == `"JANG, EXPRESS, DAWN, NAWE WAQT"'
replace		NAME = "3 Dailies" if NAME == `"JANG,EXPRESS,THE NATION"'
replace		NAME = "3 Dailies" if NAME == `"NAWA E WAQAT, EXPRESS, DAWN"'
replace		NAME = "2 Dailies" if NAME == `"NAWA E WAQT AND DAWN"'
replace		NAME = "2 Dailies" if NAME == `"NAWA E WAQT AND DUNYA"'
replace		NAME = "2 Dailies" if NAME == `"ROZNAMA JHAN & DAWN"'
replace		NAME = "3 Dailies" if NAME == `"THE NATION,JANG,KHABRIAN"'
replace		NAME = "THE NATION" if NAME == "NATION"
replace		NAME = "ROZNAMA PAKISTAN" if NAME == "PAKISTAN"
replace		NAME = "EXPRESS" if NAME == "TRIBUNE"
qui levelsof	NAME, local(names)
foreach		name in `names'	{
			di _n "`name'"
			count if NAME == "`name'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace NAME = "" if NAME == "`name'"
			}
}

di "After Cleaning"
tab NAME InReg

	
codebook 	$Attributes

foreach 	var of varlist $Attributes {
capture 	gen m`var' = (`var' == .)
capture 	gen m`var' = (`var' == "")
} 

egen 		NMissing = rowtotal(m*)
drop 		if NMissing == $NumberOfAttributes
	
/***
Dropping variables that have fewer than 20 observations from the regression
***/

global		IVar_reg = ""
foreach		var of varlist $IVar {
di			"`var'"
count		if `var' != ""
			if			`r(N)' >= 20	{
						global		IVar_reg = "${IVar_reg}" + " " + "`var'"
			}
}

global		NVar_reg = ""
capture foreach		var of varlist $NVar {
di			"`var'"
count		if `var' != .
			if			`r(N)' >= 20	{
						global		NVar_reg = "${NVar_reg}" + " " + "`var'"
			}
}

/***

Repacing the missing values with the newly defined category "MISSING" for categorical variables 
and 0 for numeric variables. 

***/

foreach 	var of varlist $Attributes {

			capture confirm string var `var'
			if _rc==0 {
			replace `var' = "00_MISSING" if `var' == "" | `var' == " " |`var' == "	" | `var' == ","
			}
			else {
			replace `var' = 0 if `var' == . 
			}
			tab 	`var', m
}
		

/***
Encoding the variables so that they can be treated as categorical variable in regression. 
***/

foreach 		var of varlist Department District $IVar_reg {
			capture confirm string var `var'
			if _rc==0 {
			encode 	`var', gen(`var'_coded)
			drop 		`var'
			ren 	`var'_coded `var'
			}
}
rename 		DeliveryDate time

*Build the RHS of the regression for the numeric variables
global		NRHS = ""
if			strlen("${NVar_reg}") > 1 {
foreach		var of varlist $NVar_reg {
			global		NRHS = "${NRHS}" + " " + "`var'" + " m" + "`var'"
}
}

save 			"${tempdir}/Item`ItemID'.dta", replace

/*				Save the variables used into a dataset. 		*/

clear
set			obs 1
*local		ItemID = 989
gen			ItemID = `ItemID'

global		IVarList = ""
foreach		var in $IVar {
			*global 		IVarList = "${IVarList}" + " " + "`var'" + "_Item`ItemID'"
			global 		IVarList = "${IVarList}" + " " + "`var'"
}
gen			AllIVars = "${IVarList}"

global		NVarList = ""
capture foreach		var in $NVar {
			*global 		NVarList = "${NVarList}" + " " + "`var'" + "_Item`ItemID'"
			global 		NVarList = "${NVarList}" + " " + "`var'"
}
gen			AllNVars = "${NVarList}"


global		IVarList_reg = ""
foreach		var in $IVar_reg {
			*global 		IVarList_reg = "${IVarList_reg}" + " " + "`var'" + "_Item`ItemID'"
			global 		IVarList_reg = "${IVarList_reg}" + " " + "`var'"
}
gen			RegIVars = "${IVarList_reg}"

global		NVarList_reg = ""
capture foreach		var in $NVar_reg {
			*global 		NVarList_reg = "${NVarList_reg}" + " " + "`var'" + "_Item`ItemID' " + "m`var'_Item`ItemID'"
			global 		NVarList_reg = "${NVarList_reg}" + " " + "`var'" + " " + "m`var'"
}
gen			RegNVars = "${NVarList_reg}"
gen 		NObs = ${NObs}
gen			mPrice = ${mPrice}
gen 		NObsControl = ${NObsControl}
gen			mPriceControl = ${mPriceControl}
gen     mQuantity = ${mQuantity}
gen     mQuantityControl = ${mQuantityControl}
gen     mValue = ${mValue}
gen     mValueControl = ${mValueControl}
gen 		NumberOfAttributes = ${NumberOfAttributes}

save		"${tempdir}/RegAttributes_Item`ItemID'.dta", replace

