
* Towel - ItemID927

use 		"${rawdata}/POPSData/NewItemID927.dta", clear
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
drop 		if UnitPrice < 20
drop		if UnitPrice > 1200

global 		Attributes = "SIZE TOWEL_MATERIAL TYPE_OF_TOWEL"
global 		NumberOfAttributes = 3

global 		IVar = "TOWEL_MATERIAL TYPE_OF_TOWEL Unit"
global 		NVar = "SIZE"


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

1-Some attribute values are duplicated with slightly different spellings 
2-Others are infrequent. 
3-Others only occur in groups 1-3
This part of code groups the attribute values. 

SIZE
***/

di "Before Cleaning"
tab SIZE InReg

split SIZE, parse("X")
replace SIZE1 = "48" if SIZE1 == "4FEET"
replace SIZE1 = "72" if SIZE1 == "6"
replace SIZE1 = "" if SIZE1 == "LARGE SIZE"
replace SIZE1 = "" if SIZE1 == "NO"
replace SIZE1 = "36" if SIZE1 == `"36" "'
replace SIZE1 = "36" if SIZE1 == `"1GUZZ WIDTH "'
replace SIZE1 = subinstr(SIZE1," INCHES","",.)
replace SIZE1 = strtrim(SIZE1)
destring SIZE1, replace
replace SIZE2 = "18" if SIZE2 == `" 18""'
replace SIZE2 = "24" if SIZE2 == "2FEET"
replace SIZE2 = "48" if SIZE2 == "4FEET"
replace SIZE2 = "24" if SIZE2 ==  `" 2 FEET LENGTH"'
replace SIZE2 = subinstr(SIZE2," INCHES","",.)
replace SIZE2 = strtrim(SIZE2)
destring SIZE2, replace

drop SIZE
gen SIZE = SIZE1 * SIZE2
drop SIZE1 SIZE2

di "After Cleaning"
summ SIZE


/***
####TOWEL_MATERIAL
***/

di "Before Cleaning"
tab TOWEL_MATERIAL InReg

replace TOWEL_MATERIAL = "" if TOWEL_MATERIAL == "NO"

di "After Cleaning"
tab TOWEL_MATERIAL InReg


/***
####TYPE_OF_TOWEL
***/

di "Before Cleaning"
tab TYPE_OF_TOWEL InReg

replace TYPE = "" if inlist(TYPE,"DISPOSABLE TOWEL","NO")
replace TYPE = "FLOOR TOWEL" if TYPE == "FOOT TOWEL"

di "After Cleaning"
tab TYPE InReg


/***
####UNIT
***/

di "Before Cleaning"
tab Unit InReg

gen mUnit = 0
replace Unit = "Packet" if Unit != "Count/Single"

di "After Cleaning"
tab Unit InReg


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
			encode 	`var', gen(`var'_enc)
			drop 		`var'
			ren 	`var'_enc `var'
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

