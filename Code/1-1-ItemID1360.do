
* ITEMID 1360: Floor mop OR Broom OR Softgrass broom (phool jharoo) OR Bambino sticks (bansee jharoo)

use 		"${rawdata}/POPSData/NewItemID1360.dta", clear
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
drop 		if UnitPrice> 500
drop		if UnitPrice <= .05

global 		Attributes = "BRAND HANDLE_LENGTH HANDLE_MATERIAL TYPE"	
global 		NumberOfAttributes = 4

global 		IVar = "BRAND HANDLE_MATERIAL TYPE Unit"
global 		NVar = "HANDLE_LENGTH"

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

####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
replace		Unit = "Kilogram" if Unit == "Kg"
replace		Unit = "Count/Single" if Unit == "Pack of 2"
replace		Unit = "Dozen" if Unit == "Pack of 24"
di "After Cleaning"
tab Unit InReg

/***
####BRAND
***/

di "Before Cleaning"
tab BRAND InReg
qui levelsof	BRAND, local(brands)
foreach		brand in `brands'	{
			di _n "`brand'"
			count if BRAND == "`brand'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace BRAND = "" if BRAND == "`brand'"
			}
}
di "After Cleaning"
tab BRAND InReg

/***
####HANDLE_LENGTH
***/

di "Before Cleaning"
tab HANDLE_LENGTH InReg
replace HANDLE_LENGTH = "0" if HANDLE_LENGTH == "NO HANDLE"
replace HANDLE_LENGTH = subinstr(HANDLE_LENGTH,"FEET","",.)
replace HANDLE_LENGTH = subinstr(HANDLE_LENGTH,"FOOT","",.)
replace HANDLE_LENGTH = strtrim(HANDLE_LENGTH)
replace HANDLE_LENGTH = "3" if HANDLE_LENGTH == "STANDARD SIZE"
destring HANDLE_LENGTH, replace
di "After Cleaning"
summ HANDLE_LENGTH, det

/***
####HANDLE_MATERIAL
***/

di "Before Cleaning"
tab HANDLE_MATERIAL InReg

/***
####TYPE
***/

di "Before Cleaning"
tab TYPE InReg

replace 	TYPE ="BAMBINO STICK/ BANSEE JHAROO" if TYPE =="BANSI JHAROO"
replace 	TYPE ="PHOOL JHAAROO" if TYPE =="NARIAL JHAROO" | TYPE =="PHOOL JHAROO"
replace		TYPE = "MOP CLOTH" if TYPE == "COTTON MOP"
replace		TYPE = "COBWEB BRUSH" if TYPE == "DUSTING"
replace		TYPE = "COBWEB BRUSH" if TYPE == `"JALA/WEB CLEANING BRUSH"'
replace		TYPE = "MOP CLOTH" if TYPE == "REFILL MOP"
qui levelsof	TYPE, local(btypes)
foreach		btype in `btypes'	{
			di _n "`btype'"
			count if TYPE == "`btype'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace TYPE = "" if TYPE == "`btype'"
			}
}

di "After Cleaning"
tab TYPE InReg

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

