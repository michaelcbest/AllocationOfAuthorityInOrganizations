
* Calculator - ItemID1001

use 		"${rawdata}/POPSData/NewItemID1001.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

replace 	DeliveryDate = 20072 if DeliveryDate == 52944
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
drop 		if UnitPrice < 250
drop		if UnitPrice > 2150

global 		Attributes = "BRAND_AND_MODEL NUMBER_OF_DIGITS TYPE_OF_CALCULATOR"
global 		NumberOfAttributes = 3
gen BRAND_AND_MODEL = ""

global 		IVar = "BRAND_AND_MODEL NUMBER_OF_DIGITS TYPE_OF_CALCULATOR"
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

BRAND_AND_MODEL
***/

di "Before Cleaning"
tab BRAND InReg
tab BRAND_B InReg
tab MODEL InReg

*Clean Brand
replace BRAND = "CITIZEN" if BRAND == "CITIZEN CT-962"
replace MODEL = "478" if BRAND_B == "CASIO 478"
replace BRAND_B = "CASIO" if BRAND_B == "CASIO 478"
replace BRAND_B = "CITIZEN" if BRAND_B == "CT-912"
replace BRAND_B = "CASIO" if BRAND_B == "MJ-120-D CASIO"
drop BRAND_B
replace BRAND = "CITIZEN" if inlist(MODEL,`"CT-500"',`"CT-512"',`"CT-712"',`"CT9911"') & BRAND == ""
replace BRAND = "CASIO" if inlist(MODEL,`"DJ-220-D"',`"MJ-120-T"') & BRAND == ""

replace MODEL = "304" if MODEL == "CASIO 304"
replace MODEL = "3104" if MODEL == "CASIO-3104"
replace BRAND = "CITIZEN" if MODEL == "CT -912D"
replace MODEL = "CT 912D" if MODEL == "CT -912D"
replace BRAND = "CITIZEN" if MODEL == "CT 600J"
replace BRAND = "CITIZEN" if MODEL == "CT 9966"
replace MODEL = "CT 8814L" if MODEL == "CT- 8814L"
replace MODEL = "CT 8814N" if MODEL == "CT- 8814N"
replace BRAND = "CITIZEN" if MODEL == "CT-500"
replace MODEL = "CT 500" if MODEL == "CT-500"
replace BRAND = "CITIZEN" if MODEL == "CT-512"
replace MODEL = "CT 512" if MODEL == "CT-512"
replace MODEL = "CT 612" if MODEL == "CT-612"
replace MODEL = "CT 688L" if MODEL == "CT-688L"
replace BRAND = "CITIZEN" if MODEL == "CT-712"
replace MODEL = "CT 712" if MODEL == "CT-712"
replace MODEL = subinstr(MODEL,"CT-","CT ",1)
replace BRAND = "CITIZEN" if MODEL == "CT 7700"
replace BRAND = "CITIZEN" if MODEL == "CT 8214"
replace BRAND = "CITIZEN" if MODEL == "CT 9300"
replace BRAND = "CITIZEN" if MODEL == "CT 9914C"
replace BRAND = "CITIZEN" if MODEL == "CT 9914D"
replace BRAND = "CITIZEN" if MODEL == "CT86011"
replace MODEL = "CT 86011" if MODEL == "CT86011"
replace BRAND = "CITIZEN" if MODEL == "CT99001"
replace MODEL = "CT 99001" if MODEL == "CT99001"
replace BRAND = "CITIZEN" if MODEL == "CT9911"
replace MODEL = "CT 9911" if MODEL == "CT9911"
replace BRAND = "CITIZEN" if MODEL == "SDC-812"
replace BRAND = "CASIO" if inlist(MODEL,"DJ-120","DJ-220-D","DL-1624")
replace BRAND = "CASIO" if inlist(MODEL,"MJ-120-T","MJ-120D")


*BRAND & MODEL
replace BRAND_AND_MODEL = BRAND + `"; "' + MODEL
replace BRAND_AND_MODEL = "" if BRAND_AND_MODEL == `"; "'
drop BRAND MODEL

replace BRAND_AND = `"CASIO; 3XX"' if inlist(BRAND_AND,`"CASIO; 304"',`"CASIO; 3104"')
replace BRAND_AND = `"CASIO; 3XX"' if inlist(BRAND_AND,`"CASIO; 478"',`"CASIO; DJ 312"')
replace BRAND_AND = `"CASIO; XXXX"' if inlist(BRAND_AND,`"CASIO; DJ2214S"',`"CASIO; DL-1624"')
replace BRAND_AND = `"CASIO; XXXX"' if inlist(BRAND_AND,`"CASIO; DS-6133"',`"CASIO; KK800A"')
replace BRAND_AND = `"CASIO; MJ-1XX"' if inlist(BRAND_AND,`"CASIO; MJ-100D"',`"CASIO; MJ-120-C"')
replace BRAND_AND = `"CASIO; MJ-1XX"' if inlist(BRAND_AND,`"CASIO; MJ-120-T"',`"CASIO; MJ-120D"')
replace BRAND_AND = `"CITIZEN; CT XXX"' if inlist(BRAND_AND,`"CITIZEN; CT 600J"',`"CITIZEN; CT 612"')
replace BRAND_AND = `"CITIZEN; CT XXX"' if inlist(BRAND_AND,`"CITIZEN; CT 688L"',`"CITIZEN; CT 660M"')
replace BRAND_AND = `"CITIZEN; CT XXX"' if inlist(BRAND_AND,`"CITIZEN; CT 712"',`"CITIZEN; CT 760"')
replace BRAND_AND = `"CITIZEN; CT XXX"' if inlist(BRAND_AND,`"CITIZEN; CT 912D"',`"CITIZEN; SDC-812"')
replace BRAND_AND = `"CITIZEN; CT 8XXXX"' if inlist(BRAND_AND,`"CITIZEN; CT 7700"',`"CITIZEN; CT 8214"')
replace BRAND_AND = `"CITIZEN; CT 8XXXX"' if inlist(BRAND_AND,`"CITIZEN; CT 86011"',`"CITIZEN; CT 8814L"')
replace BRAND_AND = `"CITIZEN; CT 8XXXX"' if inlist(BRAND_AND,`"CITIZEN; CT 8814N"',`"CITIZEN; CT 912D"')
replace BRAND_AND = `"CITIZEN; CT 8XXXX"' if BRAND_AND == `"CITIZEN; CT 9300"'
replace BRAND_AND = `"CITIZEN; CT 99XX"' if inlist(BRAND_AND,`"CITIZEN; CT 99001"',`"CITIZEN; CT 9911"')
replace BRAND_AND = `"CITIZEN; CT 99XX"' if BRAND_AND == `"CITIZEN; CT 9914C"'
replace BRAND_AND = `"CITIZEN; CT 99XX"' if inlist(BRAND_AND,`"CITIZEN; CT 9914D"',`"CITIZEN; CT 9966"')
replace BRAND_AND = `""' if inlist(BRAND_AND,`"CANON; "',`"HP; "',`"KENKO; "')
*/
di "After Cleaning"
tab BRAND_AND InReg

/***
####NUMBER_OF_DIGITS
***/

di "Before Cleaning"
tab NUMBER_OF_DIGITS InReg

replace NUMBER_OF_DIGITS = "12" if NUMBER_OF_DIGITS == "1" | NUMBER_OF_DIGITS == "30"

di "After Cleaning"
tab NUMBER_OF_DIGITS InReg

/***
####TYPE_OF_CALCULATOR
***/

di "Before Cleaning"
tab TYPE InReg

replace TYPE = "SCIENTIFIC" if TYPE == "GRAPHIC"

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

