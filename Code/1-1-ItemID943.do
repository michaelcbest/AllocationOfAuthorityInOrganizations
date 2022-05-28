
* Lock - ItemID943

use 		"${rawdata}/POPSData/NewItemID943.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

drop		if Unit == "metre" //This seems to be a wire or a coil or something, not a lock
replace 	DeliveryDate = 20032 if DeliveryDate == 52904
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
drop		if UnitPrice > 3000

global 		Attributes = "BRAND_AND_MODEL COUNTRY_OF_ORIGIN DIGITAL FITTING_CHARGES LOCK_SIZE MATERIAL TYPE"
global 		NumberOfAttributes = 7

global 		IVar = "BRAND_AND_MODEL COUNTRY_OF_ORIGIN DIGITAL FITTING_CHARGES LOCK_SIZE MATERIAL TYPE Unit"
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
tab BRAND_AND InReg

replace BRAND_AND = "CHINA" if BRAND_AND == "IMPORTED"
qui levelsof BRAND_AND, local(brands)
foreach		brand in `brands'	{
			di _n `"`brand'"'
			count if BRAND_AND == `"`brand'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace BRAND_AND = "" if BRAND_AND == `"`brand'"'
			}
}

di "After Cleaning"
tab BRAND_AND InReg

/***
####COUNTRY_OF_ORIGIN
***/

di "Before Cleaning"
tab COUNTRY_OF_ORIGIN InReg

replace COUNTRY_OF_ORIGIN = "" if inlist(COUNTRY_OF_ORIGIN,"JAPAN","KOREA","TAIWAN")

di "After Cleaning"
tab COUNTRY_OF_ORIGIN InReg

/***
####LOCK_SIZE
***/

di "Before Cleaning"
tab LOCK_SIZE InReg

replace LOCK_SIZE = "1 INCH" if inlist(LOCK_SIZE,"30MM","38 MM","40 MM","3/4 INCH")
replace LOCK_SIZE = "1/2 INCH" if inlist(LOCK_SIZE,"3/8 INCH","5/16 INCH","7/16 INCH")
replace LOCK_SIZE = "1/4 INCH" if inlist(LOCK_SIZE,"3/16 INCH","13 MM")
replace LOCK_SIZE = "2.5 INCH" if inlist(LOCK_SIZE,`"2.5 INCH WIDE AND 4 INCH LENGTH"',`"2.5"X2.5""')
replace LOCK_SIZE = "3 INCH" if LOCK_SIZE == `"3 INCH-60MM"' | LOCK_SIZE == `"3X2.5INCH"'
replace LOCK_SIZE = "3.5 INCH" if LOCK_SIZE == "4 INCH"
replace LOCK_SIZE = "63MM" if LOCK_SIZE == "64 MM"
replace LOCK_SIZE = "3 INCH" if LOCK_SIZE == "70 MM"
replace LOCK_SIZE = "LARGE" if LOCK_SIZE == "8 INCH"
replace LOCK_SIZE = "" if LOCK_SIZE == `"D 300 SMC"'
replace LOCK_SIZE = "1 INCH" if LOCK_SIZE == "SMALL"

di "After Cleaning"
tab LOCK_SIZE InReg

/***
####MATERIAL
***/

di "Before Cleaning"
tab MATERIAL InReg

replace MATERIAL = "STEEL" if MATERIAL == "PLATINUM"
replace MATERIAL = "ALUMINIUM" if MATERIAL == "ZINC"
replace MATERIAL = "" if inlist(MATERIAL,"PLASTIC","WOODEN")

di "After Cleaning"
tab MATERIAL InReg

/***
####TYPE
***/

di "Before Cleaning"
tab TYPE InReg

replace TYPE = `"CUPBOARD/ALMIRAH LOC"' if TYPE == `"ALMARI LOCK"'
replace TYPE = `"CUPBOARD/ALMIRAH LOC"' if TYPE == "DRAWER LOCK"
replace TYPE = `"CUPBOARD/ALMIRAH LOC"' if TYPE == "GLASS LOCK"
replace TYPE = "HANDLE LOCK" if TYPE == "OUTER HANDLE"
replace TYPE = "CHINA LOCK" if TYPE == "PADLOCK"
qui levelsof TYPE, local(types)
foreach		type in `types'	{
			di _n `"`type'"'
			count if TYPE == `"`type'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace TYPE = "" if TYPE == `"`type'"'
			}
}


di "After Cleaning"
tab TYPE InReg

/***
####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
   
replace Unit = "Pack" if Unit == "Pack of 10" | Unit == "Pack of 5" | Unit == "Dozen"

gen mUnit = 0

di			"After Cleaning"
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

