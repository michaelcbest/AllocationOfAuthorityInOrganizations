
* ITEMID 1032: Photocopy or Photocopy Charges

use 		"${rawdata}/POPSData/NewItemID1032.dta", clear
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
drop if UnitPrice < 1
drop if UnitPrice > 100

global 		Attributes = "COLOR DOUBLE_SIDED ON_GENERATOR PAPER_QUALITY_GSM SIZE WITH_BINDING"	
global 		NumberOfAttributes = 6

global 		IVar = "COLOR DOUBLE_SIDED ON_GENERATOR SIZE WITH_BINDING PAPER_QUALITY_GSM"
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

####COLOR
No Changes Needed
***/
di "Before Cleaning"
tab COLOR InReg

/***
####DOUBLE_SIDED
No changes needed.
***/
di "Before Cleaning"
tab DOUBLE_SIDED InReg

/***
####ON_GENERATOR
No changes needed.
***/
di "Before Cleaning"
tab ON_GENERATOR InReg

/***
####PAPER_QUALITY_GSM
***/ 
di "Before Cleaning"
tab PAPER_QUALITY InReg
replace 	PAPER_QUALITY_GSM = "80" if PAPER_QUALITY_GSM == "FINE" 
replace 	PAPER_QUALITY_GSM = "70" if PAPER_QUALITY_GSM == "DIF." 
replace 	PAPER_QUALITY_GSM = "70" if PAPER_QUALITY_GSM == "NORMAL" 
replace		PAPER_QUALITY_GSM = "80" if PAPER_QUALITY == "100"
replace		PAPER_QUALITY = "70" if PAPER_QUALITY == "75"
replace		PAPER_QUALITY = "80" if PAPER_QUALITY == "85"
di "After Cleaning"
tab PAPER_QUALITY InReg

/***
####SIZE
***/ 

di "Before Cleaning"
tab SIZE InReg
replace 	SIZE = "A0" if SIZE == "30 X 40 INCHES"
replace 	SIZE = "A1" if SIZE == "20 X 30 INCHES"
replace 	SIZE = "A3" if SIZE == "A3+"
replace 	SIZE = "A5" if SIZE == "B5" | SIZE == "EXECUTIVE"
replace 	SIZE = "A0" if SIZE == "ARCH E1"
replace 	SIZE = "A3" if SIZE == "B3" | SIZE == "TABLOID" | SIZE == "LEDGER"
replace 	SIZE = "A4" if SIZE == "LETTER SIZE" | SIZE == "FOLIO"
replace 	SIZE = "A5" if SIZE == "LEGAL"
replace 	SIZE = "A4" if SIZE == "MIXED"
replace 	SIZE = "" if SIZE == "B10" | SIZE == "A0" | SIZE == "A1" | SIZE == "A6"
di "After Cleaning"
tab SIZE InReg

/***
####WITH_BINDING
***/ 

di "Before Cleaning"
tab 		WITH_BINDING InReg
replace 	WITH_BINDING = "TAPE BINDING" if WITH_BINDING == "X-RAY BINDING"
di "After Cleaning"
tab 		WITH_BINDING InReg

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

