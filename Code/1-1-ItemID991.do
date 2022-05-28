
* ITEMID 991: Envelope
use 		"${rawdata}/POPSData/NewItemID991.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

drop if lUnitPrice == .
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
drop if UnitPrice < .015
drop if UnitPrice > 450

gen 		AREA = . 
global 		Attributes = "MATERIAL PRINTED AREA WITH_ZIP"	
global 		NumberOfAttributes = 4

global 		IVar = "MATERIAL PRINTED WITH_ZIP"
global 		NVar = "AREA Unit"

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
}
else {
gen 		TrimmedSample = 1
}

gen 		InReg = (inlist(Treatment,4,5) & TrimmedSample == 1)

/***
###Cleaning Attributes 

Some attribute values are duplicated with slightly different spelling while others
are infrequent. This part of code group the attribute values. 

####MATERIAL
***/

di "Before Cleaning"
tab MATERIAL InReg
replace 	MATERIAL = "BROWN PAPER" if MATERIAL == "BROWN PAPER WITH CLOTH INSIDE"
replace 	MATERIAL = "ENVELOP KHAKI" if MATERIAL == "EARTHEN COLOR" 
replace 	MATERIAL = "WHITE RECYCLED PAPER" if MATERIAL == "WHITE & BROWN"
replace 	MATERIAL = "PLASTIC" if MATERIAL == "POLYETHENE" | MATERIAL == "CARD"
replace 	MATERIAL = "GOLDEN PAPER" if MATERIAL == "PLASTIC"
di "After Cleaning"
tab MATERIAL InReg

/***
####PRINTED
***/

di "Before Cleaning"
tab PRINTED InReg
replace 	PRINTED = "MONOGRAM PRINT" if PRINTED == "CUSTOMIZED PRINTING ON BOTH SIDES"
di "After Cleaning"
tab PRINTED InReg


/***
####SIZE
***/

di "Before Cleaning"
tab SIZE InReg
quietly 	replace 	SIZE = subinstr(SIZE,`"""',"",.)
quietly 	replace 	SIZE = subinstr(SIZE,"'","",.)

gen 		LENGTH = substr(SIZE,1,strpos(SIZE," "))
gen 		WIDTH = substr(SIZE,strpos(SIZE,"X "),.)
replace 	WIDTH = subinstr(WIDTH,"X ","",.)

replace 	LENGTH = "12" if SIZE =="12X15" 
replace 	WIDTH = "15" if SIZE =="12X15" 

replace 	LENGTH = "5" if SIZE == "3X5 & 5X8"
replace 	WIDTH = "8" if SIZE == "3X5 & 5X8"

replace 	LENGTH = "4" if SIZE == "4X9"
replace 	WIDTH = "9" if SIZE == "4X9"

replace 	LENGTH = "3.7" if SIZE == "9.5 CM X 7.5 CM"
replace 	WIDTH = "3" if SIZE == "9.5 CM X 7.5 CM"

replace 	LENGTH = "8.27" if SIZE == "A4"
replace 	WIDTH = "11.69" if SIZE == "A4"

replace 	LENGTH = "5.83" if SIZE == "A5"
replace 	WIDTH = "8.27" if SIZE == "A5"

replace 	LENGTH = "9" if SIZE == "C4 (9 IN X 13 IN)"
replace 	WIDTH = "13" if SIZE == "C4 (9 IN X 13 IN)"

replace 	LENGTH = "8.5" if SIZE == "DOC SIZE"
replace 	WIDTH = "11" if SIZE == "DOC SIZE"

replace 	LENGTH = "10" if SIZE == "FILE"
replace 	WIDTH = "12" if SIZE == "FILE"

replace 	LENGTH = "10" if SIZE == "LARGE SIZE"
replace 	WIDTH = "12" if SIZE == "LARGE SIZE"

replace 	LENGTH = "8.5" if SIZE == "LEGAL"
replace 	WIDTH = "14" if SIZE == "LEGAL"

replace 	LENGTH = "6" if SIZE == "MEDIUM SIZE"
replace 	WIDTH = "8" if SIZE == "MEDIUM SIZE"

replace 	LENGTH = "14.5" if SIZE == "POST"
replace 	WIDTH = "18.5" if SIZE == "POST"

replace 	LENGTH = "4" if SIZE == "SMALL SIZE"
replace 	WIDTH = "6" if SIZE == "SMALL SIZE"

destring 	LENGTH, replace
destring 	WIDTH, replace

replace 	AREA = LENGTH * WIDTH

drop 		SIZE LENGTH WIDTH
di "After Cleaning"
summ AREA, det


/***
####WITH_ZIP
***/

di "Before Cleaning"
tab WITH_ZIP InReg

/***
####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
   
replace		Unit = subinstr(Unit,"Pack of ","",.)
replace		Unit = subinstr(Unit," Envelopes","",.)
replace 	Unit="1"	if  Unit=="Count/Single"
destring	Unit, replace

gen mUnit = 0

di			"After Cleaning"
summ		Unit, det
	
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
foreach		var of varlist $NVar {
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

foreach 		var of varlist Department District Unit $Attributes {
			capture confirm string var `var'
			if _rc==0 {
			encode 	`var', gen(`var'_coded)
			drop 		`var'
			ren 	`var'_coded `var'
			}
}

gen 		time2 = DeliveryDate*DeliveryDate
gen 		time3 = DeliveryDate*time2
rename 		DeliveryDate time

*Build the RHS of the regression for the numeric variables
global		NRHS = ""
foreach		var of varlist $NVar_reg {
			global		NRHS = "${NRHS}" + " " + "`var'" + " m" + "`var'"
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
