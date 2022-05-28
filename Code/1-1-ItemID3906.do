
*ITEMID 3906: Light Bulb

use 		"${rawdata}/POPSData/NewItemID3906.dta", clear
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
drop 		if UnitPrice> 8000
drop		if UnitPrice <= 50

global 		Attributes = "BRAND TYPE_OF_BULB WATT WITH_FITTING WITH_HOLDER_OR_PATTI"	
global 		NumberOfAttributes = 5

global 		IVar = "BRAND TYPE_OF_BULB WATT WITH_FITTING WITH_HOLDER_OR_PATTI Unit"
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

####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
replace		Unit = "Count/Single" if Unit == "Single/Count"
di "After Cleaning"
tab Unit InReg

/***
####BRAND
***/

di "Before Cleaning"
tab BRAND InReg

replace WATT = "100 WATT" if BRAND == "100 WATT" & WATT == "500 WATTS"
replace BRAND = "PAK LAND" if BRAND == "PAK-LITE"
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
####TYPE_OF_BULB
***/

di "Before Cleaning"
tab TYPE InReg
replace TYPE = "FILAMENT BULB" if TYPE == "FLAMENT BULB"
replace TYPE = "TUBE LIGHT" if TYPE == "FLUORESCENT"
replace TYPE = "FILAMENT BULB" if TYPE == "INCANDASCENT"
replace TYPE = "TUBE LIGHT" if TYPE == "TUBE ROD"
replace TYPE = "BEAM LIGHT" if TYPE == "HEAD LIGHT BULB"
replace TYPE = "SEARCH LIGHT" if TYPE == "FLOOD LIGHT"
qui levelsof	TYPE, local(types)
foreach		type in `types'	{
			di _n "`type'"
			count if TYPE == "`type'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace TYPE = "" if TYPE == "`type'"
			}
}
di "After Cleaning"
tab TYPE InReg

/***
####WATT
***/

di "Before Cleaning"
tab WATT InReg
replace WATT = "24 WATT" if WATT == "24 VOLT"
replace WATT = "24 WATT" if WATT == "24 VOLTS"
replace WATT = "240 WATT" if WATT == "240 VOLT"
replace WATT = "250 WATT" if WATT == "250 W"
replace WATT = "400 WATT" if WATT == "400 W"
replace WATT = "500 WATT" if WATT == "500 WATTS"
replace WATT = "[0,20) WATT" if inlist(WATT,"10 W","11 WATT","12 WATT","13 WATT","14 WATT","15 WATT","15 VOLTS","18 WATT")
replace WATT = "[0,20) WATT" if inlist(WATT,"2 WATT","6 WATT","7 WATT","7 WAT")
replace WATT = "[200,) WATT" if inlist(WATT,"1000 WATT","1800 WATT","200 WATT","220 WATT","240 WATT","250 WATT","400 WATT","500 WATT")
replace WATT = "[101,200) WATT" if inlist(WATT,"125 WATT","140 WATTS","150 WATT")
replace WATT = "23 WATT" if WATT == "20 WATT"
replace WATT = "23 WATT" if WATT == "22 WATT"
replace WATT = "25 WATT" if WATT == "26 WATT"
replace WATT = "25 WATT" if WATT == "28 WATT"
replace WATT = "32 WATT" if WATT == "30 WATT"
replace WATT = "32 WATT" if WATT == "35 WATT"
replace WATT = "40 WATT" if WATT == "36 WATT"
replace WATT = "40 WATT" if WATT == "42 WATTS"
replace WATT = "[50,80) WATT" if inlist(WATT,"50 WATT","52 WATT","55 W","60 WATT","65 WATT","80 WATT")
di "After Cleaning"
tab WATT InReg

/***
####WITH_FITTING
***/

di "Before Cleaning"
tab WITH_FITTING InReg
replace WITH_FITTING = "NO" if WITH_FITTING == "NILL"
di "After Cleaning"
tab WITH_FITTING InReg

/***
####WITH_HOLDER_OF_PATTI
***/

di "Before Cleaning"
tab WITH_HOLDER InReg
replace WITH_HOLDER = "NO" if WITH_HOLDER == "NILL"
di "After Cleaning"
tab WITH_HOLDER InReg

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

