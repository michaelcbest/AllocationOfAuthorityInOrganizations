
* Item ID 936 - Duster or Cleaning Cloth

use 		"${rawdata}/POPSData/NewItemID936.dta", clear
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
drop 		if UnitPrice < 0.05
drop		if UnitPrice > 500

global 		Attributes = "MATERIAL SIZE TYPE WITH_HANDLE"
global 		NumberOfAttributes = 4

global 		IVar = "MATERIAL SIZE TYPE WITH_HANDLE Unit"
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

MATERIAL
***/

di "Before Cleaning"
tab MATERIAL InReg

replace MATERIAL = "CLOTH" if MATERIAL == "WOOL"
replace MATERIAL = "FOAM" if MATERIAL == "PLASTIC"
replace MATERIAL = "" if MATERIAL == "FLALIEN"

di "After Cleaning"
tab MATERIAL InReg

/***
####SIZE
***/

di "Before Cleaning"
tab SIZE InReg

replace SIZE = "" if SIZE == "0"
replace SIZE = "0.5 M2" if SIZE == "1 M"
replace SIZE = "0.836 M2" if SIZE == "1 YARD BY 1 YARD"
replace SIZE = "12.54 M2" if SIZE == `"1 YARD X 15 YARD"'
replace SIZE = "0.209 M2" if SIZE == "1.5 X 1.5 FEET"
replace SIZE = "5 M2" if SIZE == "10 M"
replace SIZE = "5.5 M2" if SIZE == "11METER"
replace SIZE = "0.0144 M2" if SIZE == "12 CM X 12 CM"
replace SIZE = "0.0929 M2" if SIZE == "12 INCHES  X 12 INCHES"
replace SIZE = "0.0929 M2" if SIZE == "12 INCHES X 12 INCHES"
replace SIZE = "6 M2" if SIZE == "12 METER"
replace SIZE = "7.5 M2" if SIZE == "15METER"
replace SIZE = "0.0256 M2" if SIZE == "16 CM X 16 CM"
replace SIZE = "0.1652 M2" if SIZE == "16 INCHES X 16 INCHES"
replace SIZE = "8 M2" if SIZE == "16 METER"
replace SIZE = "0.0432 M2" if SIZE == "18 CM X 24 CM"
replace SIZE = "0.2787 M2" if SIZE == "18 INCH X 24 INCH"
replace SIZE = "0.1394 M2" if SIZE == "1FEET X 1.5FEET"
replace SIZE = "0.3716 M2" if SIZE == "2 FEET * 2 FEET"
replace SIZE = "1 M2" if SIZE == "2 METER"
replace SIZE = "0.4645 M2" if SIZE == "2.5 FEET * 2 FEET"
replace SIZE = "0.3871 M2" if SIZE == "20 INCH X 30 INCH"
replace SIZE = "0.2581 M2" if SIZE == "20 INCHES X 20 INCHES"
replace SIZE = "10 M2" if SIZE == "20 METER"
replace SIZE = "0.449 M2" if SIZE == "24 INCH X 29 INCH"
replace SIZE = "12.5 M2" if SIZE == "25 METERS"
replace SIZE = "" if SIZE == "27 X 20"
replace SIZE = "0.0448 M2" if SIZE == "28 CM X 16 CM"
replace SIZE = "0.3968 M2" if SIZE == "28 INCH X 22 INCH"
replace SIZE = "0.4181 M2" if SIZE == "3 FEET X 1.5"
replace SIZE = "0.09 M2" if SIZE == "30 CM X 30 CM"
replace SIZE = "0.18 M2" if SIZE == "30 CM X 60 CM"
replace SIZE = "15 M2" if SIZE == "30METER"
replace SIZE = "0.3484 M2" if SIZE == "30X18 INCH"
replace SIZE = "0.0103 M2" if SIZE == `"4" X 4""'
replace SIZE = "0.24 M2" if SIZE == "40 CM X 60 CM"
replace SIZE = "1.2464 M2" if SIZE == "42 INCH X 46 INCH"
replace SIZE = "0.35 M2" if SIZE == "50 CM X 70 CM"
replace SIZE = "3.4839 M2" if SIZE == "60 INCH X 90 INCH"
replace SIZE = "0.0077 M2" if SIZE == "6INCHX2INCH"
replace SIZE = "3 M2" if SIZE == "6METER"
replace SIZE = "0.0077 M2" if SIZE == "6X2INCH"
replace SIZE = "0.0206 M2" if SIZE == `"8" X 4" INCHES"'
replace SIZE = "3.7161 M2" if SIZE == "8FT X 5 FT"
replace SIZE = "5.2258 M2" if SIZE == "2.5 X 2.5 GUZZ"
replace SIZE = "0.5226 M2" if SIZE == "30 INCH X 27 INCH"
replace SIZE = "0.8361 M2" if SIZE == "3FEETX3FEET"

replace SIZE = "UNDER 0.0144" if inlist(SIZE,"0.0077 M2","0.0103 M2","0.0144 M2")
replace SIZE = "0.0206-0.0256" if inlist(SIZE,"0.0206 M2","0.0256 M2")
replace SIZE = "0.04-0.05" if inlist(SIZE,"0.0432 M2","0.0448 M2")
replace SIZE = "0.09-0.1" if inlist(SIZE,"0.09 M2","0.0929 M2")
replace SIZE = "0.12-0.17" if inlist(SIZE,"0.1394 M2","0.1652 M2")
replace SIZE = "0.18-0.26" if inlist(SIZE,"0.18 M2","0.209 M2","0.24 M2","0.2581 M2")
replace SIZE = "0.34-0.35" if inlist(SIZE,"0.3484 M2","0.35 M2")
replace SIZE = "0.38-0.42" if inlist(SIZE,"0.3871 M2","0.3968 M2","0.4181 M2")
replace SIZE = "0.43-0.47" if inlist(SIZE,"0.449 M2","0.4645 M2")
replace SIZE = "0.5-1.5" if inlist(SIZE,"0.5 M2","0.836 M2","1 M2","1.2464 M2","0.5226 M2","0.8361 M2")
replace SIZE = "OVER 1.5" if inlist(SIZE,"10 M2","12.5 M2","12.54 M2","15 M2","3 M2","3.489 M2")
replace SIZE = "OVER 1.5" if inlist(SIZE,"3.7161 M2","5 M2","5.5 M2","6 M2","7.5 M2","8 M2","5.2258 M2")

replace SIZE = "" if inlist(SIZE,"NO BRAND","SMALL SIZE")
replace SIZE = subinstr(SIZE,".","_",.)

di "After Cleaning"
tab SIZE InReg

/***
####TYPE
***/

di "Before Cleaning"
tab TYPE InReg

replace TYPE = "WHITE BOARD DUSTER" if TYPE == "BLACK BOARD"
replace TYPE = "WHITE BOARD DUSTER" if TYPE == "SIMPLE FOAM DUSTER"
replace TYPE = "SIMPLE CLOTH DUSTER" if TYPE == "PHILALEN CLOTH DUSTER"

replace TYPE = "" if inlist(TYPE,"FOR SAMPLING","LEGAL")

di "After Cleaning"
tab TYPE InReg

/***
####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
   
replace Unit = "Pack of 12" if Unit == "Dozen"
replace Unit = "Pack" if inlist(Unit,"Pack of 10","Pack of 2","Pack of 24","Pack of 4","Pack of 5")
replace Unit = "Length" if inlist(Unit,"Meter","Yard")

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

