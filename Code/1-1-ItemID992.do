
* ITEMID 992: Printing Paper

use 		"${rawdata}/POPSData/NewItemID992.dta", clear
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
drop 		if UnitPrice < .6
drop 		if UnitPrice>50

global 		Attributes = "BRAND COLOURED_PAGES SIZE WEIGHT_PER_SHEET"	
global 		NumberOfAttributes = 4

global 		IVar = "BRAND COLOURED_PAGES SIZE WEIGHT_PER_SHEET Unit"
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
replace Unit = subinstr(Unit," of "," ",.)
replace Unit = "Count/Single" if Unit == "1"
replace Unit = "Count/Single" if Unit == "Single Sheet"
replace Unit = "Ream 500" if Unit == "Packet"
replace Unit = "Ream (1-200]" if Unit == "Pack/Pad 100 Forms"
replace Unit = "Ream (1-200]" if Unit == "Ream 100"
replace Unit = "Ream (1-200]" if Unit == "Ream 25"
replace Unit = "Ream (1-200]" if Unit == "Ream 30"
replace Unit = "Ream (1-200]" if Unit == "Ream 50 pages"
replace Unit = "Ream (1-200]" if Unit == "ream 24"
replace Unit = "Ream (1-200]" if Unit == "Ream 150"
replace Unit = "Ream (1-200]" if Unit == "Ream 200"
replace Unit = "Ream 250" if Unit == "Ream 260" | Unit == "Ream 300 pages"
replace Unit = "Ream 440 pages" if Unit == "Ream 450"
replace Unit = "Ream (500-)" if Unit == "Ream 1000"
replace Unit = "Ream (500-)" if Unit == "Ream 550 pages"
replace Unit = "Ream (500-)" if Unit == "Ream 600"
replace Unit = "Ream (500-)" if Unit == "Ream 1500"

di "After Cleaning"
tab Unit InReg

/***
####Brand
***/

di			"Before Cleaning"
tab			BRAND InReg


replace 	BRAND="BRILLIANT LASER COPY" if BRAND=="BLC COMPANY"
replace 	BRAND = "COPYMATE" if BRAND == "COPY MATE PLUS"

qui levelsof	BRAND, local(brands)
foreach		brand in `brands'	{
			di _n "`brand'"
			count if BRAND == "`brand'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace BRAND = "" if BRAND == "`brand'"
			}
}
di			"After Cleaning"
tab			BRAND InReg, m

/***
####COLOURED_PAGES
***/

di "Before Cleaning"
tab COLOURED_PAGES InReg

replace 	COLOURED_PAGES="NO" if COLOURED_PAGES=="WHITE"

di "After Cleaning"
tab COLOURED_PAGES InReg

/***
####PAGE SIZE
***/

di "Before Cleaning"
tab SIZE InReg

*Tidy Page Sizes
replace SIZE = `"F4 (8.3 IN X 13.0 IN)"' if SIZE == `"13" X 8.5""'
replace SIZE = `"F4 (8.3 IN X 13.0 IN)"' if SIZE == `"13X9"'
replace SIZE = "LEGAL" if SIZE == `"15 X 9 INCHES"'
replace SIZE = `"A5 (5.8 IN X 8.3 IN)"' if SIZE == `"6.5" X 8.5""'
replace SIZE = `"LETTER (8.5 IN X 11.0 IN)"' if SIZE == `"8 X 11 INCHES"'
replace SIZE = `"FOLIO (8.5 IN X 13.5 IN)"' if SIZE == `"8" X 13.5""'
replace SIZE = `"FOLIO (8.5 IN X 13.5 IN)"' if SIZE == `"8.5" X 13""'
replace SIZE = "LARGE SIZE" if SIZE == `"A0 (33.1 IN X 46.8 IN)"'
replace SIZE = "LARGE SIZE" if SIZE == `"A1 (23.4 IN X 33.1 IN)"'
replace SIZE = "LARGE SIZE" if SIZE == `"A3 (11.7 IN X 16.5 IN)"'
replace SIZE = "" if SIZE == `"A9 (1.5 IN X 2.1 IN)"'
replace SIZE = "LARGE SIZE" if SIZE == `"B0 (39.4 IN X 55.7 IN)"'
replace SIZE = "LARGE SIZE" if SIZE == `"B2 (19.7 IN X 27.8 IN)"'
replace SIZE = `"LEGAL (8.5 IN X 14.0 IN)"' if SIZE == `"B4 (9.8 IN X 13.9 IN)"'
replace SIZE = `"A5 (5.8 IN X 8.3 IN)"' if SIZE == `"B6 (4.9 IN X 6.9 IN)"'
replace SIZE = "LARGE SIZE" if SIZE == `"FOOLSCAP, DOUBLE (17" X 27")"'
replace SIZE = `"A5 (5.8 IN X 8.3 IN)"' if SIZE == `"JUNIOR LEGAL (8.0 IN X 5.0 IN)"'
replace SIZE = `"LEGAL (8.5 IN X 14.0 IN)"' if SIZE == "LEGAL"

di "After Cleaning"
tab SIZE InReg

/***
####WEIGHT_PER_SHEET
***/

di "Before Cleaning"
tab WEIGHT InReg
replace WEIGHT = "100 GM" if WEIGHT == "100GRAMS"
replace WEIGHT = "100 GM" if WEIGHT == "120 GM"
replace WEIGHT = "100 GM" if WEIGHT == "140 GM"
replace WEIGHT = "UNDER 45 GM" if WEIGHT == "25 GM"
replace WEIGHT = "100 GM" if WEIGHT == "300 GM"
replace WEIGHT = "UNDER 45 GM" if WEIGHT == "35 GM"
replace WEIGHT = "UNDER 45 GM" if WEIGHT == "40 GM"
replace WEIGHT = "100 GM" if WEIGHT == "400 GM"
replace WEIGHT = "UNDER 45 GM" if WEIGHT == "45 GM"
replace WEIGHT = "UNDER 45 GM" if WEIGHT == "5 GM"
replace WEIGHT = "56 GM" if WEIGHT == "50 GM"
replace WEIGHT = "56 GM" if WEIGHT == "55GM"
replace WEIGHT = "70 GM" if WEIGHT == "72GRAM"
replace WEIGHT = "80 GM" if WEIGHT == "85 GRAMS"
di "After Cleaning"
tab WEIGHT InReg

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

gen 		time2 = DeliveryDate*DeliveryDate
gen 		time3 = DeliveryDate*time2
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

