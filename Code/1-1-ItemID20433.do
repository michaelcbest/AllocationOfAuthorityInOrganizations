*Sign Board Or Banner - ItemID20433

use 		"${rawdata}/POPSData/NewItemID20433.dta", clear
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
replace		DeliveryDate = 19746 if DeliveryDate == 52617
drop 		if UnitPrice < 35
drop		if UnitPrice > 15000

gen 		AREA = . 
global 		Attributes = "FRAME_TYPE MATERIAL NUMBER_OF_COLORS NUMBER_OF_RINGS PRINT_ON_BOTH_SIDES AREA WITH_ROPE WITH_STAND WITH_STICK"	
global 		NumberOfAttributes = 9

global 		IVar = "FRAME_TYPE MATERIAL PRINT_ON_BOTH_SIDES WITH_ROPE WITH_STAND WITH_STICK WITH_WOODEN_FRAME"
global 		NVar = "NUMBER_OF_COLORS NUMBER_OF_RINGS AREA"

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

####FRAME_TYPE
***/

di			"Before Cleaning"
tab			FRAME_TYPE InReg

replace 	FRAME_TYPE = "WOODEN FRAME" if FRAME_TYPE == "PANAFLEX"
replace 	FRAME_TYPE = "IRON FRAME" if FRAME_TYPE == "STEEL FRAME" | FRAME_TYPE == "ALUMINIUM"
replace 	FRAME_TYPE = "WOODEN FRAME" if FRAME_TYPE == "PLASTIC"
      
di			"After Cleaning"
tab			FRAME_TYPE

/***
####MATERIAL
***/

di			"Before Cleaning"
tab			MATERIAL InReg

replace 	MATERIAL = "IRON" if MATERIAL == "GI SHEET" | MATERIAL == "STEEL" | MATERIAL == "GLASS"
replace		MATERIAL = "PLASTIC" if MATERIAL == "REXINE"
 
di			"After Cleaning"
tab			MATERIAL InReg

/***
###PRINT_ON_BOTH_SIDES
***/

di 			"Before Cleaning"
tab			PRINT_ON_BOTH_SIDES InReg

replace		PRINT_ON_BOTH_SIDES = "NO" if PRINT_ON_BOTH_SIDES == "."

di			"After Cleaning"
tab			PRINT_ON_BOTH_SIDES InReg


/***
####NUMBER_OF_COLORS
***/

di			"Before Cleaning"
tab			NUMBER_OF_COLORS InReg

replace 	NUMBER_OF_COLORS = "4" if NUMBER_OF_COLORS == "MULTI"
destring 	NUMBER_OF_COLORS, replace	

di			"After Cleaning"
summ		NUMBER_OF_COLORS, det

/***
####NUMBER_OF_RINGS
***/

di			"Before Cleaning"
tab			NUMBER_OF_RINGS InReg

replace		NUMBER_OF_RINGS = "" if NUMBER_OF_RINGS == `"6FEETX3FEET"'
destring 	NUMBER_OF_RINGS, replace	

di			"After Cleaning"
summ		NUMBER_OF_RINGS, det

/***
####AREA
***/

di			"Before Cleaning"
tab			SIZE InReg

gen 		LENGTH = substr(SIZE,1,strpos(SIZE,"X"))
replace 	LENGTH = subinstr(LENGTH,"X","",.)
replace 	LENGTH = subinstr(LENGTH,"FEET","",.)
replace 	LENGTH = subinstr(LENGTH,"FEE","",.)

gen 		WIDTH = substr(SIZE,strpos(SIZE,"X"),.)
replace 	WIDTH = subinstr(WIDTH,"X","",.)
replace 	WIDTH = subinstr(WIDTH,"FEET","",.)

replace 	LENGTH = "6.5" if SIZE == "2METERX4METER" | SIZE == "4METERX2METER"
replace 	WIDTH = "13" if SIZE == "2METERX4METER" | SIZE == "4METERX2METER"

replace 	LENGTH = "0.6" if SIZE == "8INCH X 11INCH"
replace 	WIDTH = "1" if SIZE == "8INCH X 11INCH"

replace 	LENGTH = "16.4" if SIZE == "5METERX1METER"
replace 	WIDTH = "3.3" if SIZE == "5METERX1METER"

replace 	LENGTH = "16.4" if SIZE == "5 METER LONG AND 2.5 METER WIDE"
replace 	WIDTH = "8.2" if SIZE == "5 METER LONG AND 2.5 METER WIDE"

replace 	LENGTH = "3" if SIZE == "15 FEET"
replace 	WIDTH = "5" if SIZE == "15 FEET"

replace 	LENGTH = "3.3" if SIZE == "1METERX4METER"
replace 	WIDTH = "13" if SIZE == "1METERX4METER"

replace 	LENGTH = "9.9" if SIZE == "3METERX1METER"
replace 	WIDTH = "3.2" if SIZE == "3METERX1METER"

replace 	LENGTH = "13.1" if SIZE == "4METERX205METER"
replace 	WIDTH = "672.5" if SIZE == "4METERX205METER"

replace 	LENGTH = "14" if SIZE == "14FEETX6FEET , 4FEETX6FEET"
replace 	WIDTH = "6" if SIZE == "14FEETX6FEET , 4FEETX6FEET"

destring 	LENGTH, replace ignore(`"""')
destring 	WIDTH, replace ignore(`"""')

replace		AREA =  LENGTH * WIDTH
replace 	AREA = 0 if AREA == . 

drop 		SIZE LENGTH WIDTH
di			"After Cleaning"
summ		AREA, det


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

