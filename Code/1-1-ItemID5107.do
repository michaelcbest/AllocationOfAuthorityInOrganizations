*Floor Cleaner  - ItemID5107
use 		"${rawdata}/POPSData/NewItemID5107.dta", clear
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
drop 		if UnitPrice < 0.015
drop		if UnitPrice > 20

global 		Attributes = "ACID_CLEANERTIZAAB BRAND ENVIRONMENT_FRIENDLY MAKE SCENTED STATE"
global 		NumberOfAttributes = 6

global 		IVar = "ACID_CLEANERTIZAAB BRAND ENVIRONMENT_FRIENDLY MAKE SCENTED STATE"
global 		NVar = "Unit"

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
//ON

gen 		InReg = (inlist(Treatment,4,5) & TrimmedSample == 1)

/***
###Cleaning Attributes 

1-Some attribute values are duplicated with slightly different spelling 
2-Others are infrequent. 
3-Others only occur in groups 1-3
This part of code groups the attribute values. 

ACID_CLEANERTIZAAB 
***/

di "Before Cleaning"
tab ACID InReg

qui levelsof	ACID, local(acids)
foreach		acid in `acids'	{
			di _n `"`acid'"'
			count if ACID == `"`acid'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace ACID = "" if ACID == `"`acid'"'
			}
}

di "After Cleaning"
tab ACID InReg

/***
####BRAND
***/

di			"Before Cleaning"
tab			BRAND InReg

replace BRAND = "FINIS" if BRAND == "FINIX"
replace BRAND = "POWER PLUS" if BRAND == "POWER CLEANER"
qui levelsof	BRAND, local(brands)
foreach		brand in `brands'	{
			di _n `"`brand'"'
			count if BRAND == `"`brand'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace BRAND = "" if BRAND == `"`brand'"'
			}
}
      
di			"After Cleaning"
tab			BRAND InReg

/***
####MAKE
***/

di			"Before Cleaning"
tab			MAKE InReg

qui levelsof	MAKE, local(makes)
foreach		make in `makes'	{
			di _n `"`make'"'
			count if MAKE == `"`make'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace MAKE = "" if MAKE == `"`make'"'
			}
}

di			"After Cleaning"
tab			MAKE InReg

/***
###STATE
***/

di "Before Cleaning"
tab STATE STATE_SOLID, m
tab STATE InReg

replace STATE = STATE_SOLID if STATE_SOLID != "" & STATE == ""

replace STATE = "" if STATE == "CLOTH'"
replace STATE = "SOLID" if inlist(STATE,"POWDER","TABLETS","SOLID BALLS")
replace STATE = "LIQUID" if STATE == "SPRAY"

di "After Cleaning"
tab STATE InReg

/***
####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
   
replace		Unit = subinstr(Unit,"Bottle of ","",.)
replace		Unit = subinstr(Unit,"Bottle ","",.)
replace 	Unit = "" if inlist(Unit,`"Pack Of 50 Tablets"',`"Pack of 100 Tablets"',`"Pack of 12 balls"')
replace		Unit = "" if inlist(Unit,`"Pack of 15 Tablet"',`"Packet of 12 Tablets"',`"Can of 30 Liters"')
replace 	Unit = subinstr(Unit,"Packet ","",.)
replace 	Unit = "1" if Unit == "Kilogram"
replace		Unit = subinstr(Unit," Kilogram","",.)
replace		Unit = "1" if Unit == "Litre"
replace		Unit = subinstr(Unit," Litre","",.)
replace		Unit = subinstr(Unit," litre","",.)
replace		Unit = subinstr(Unit," Liter","",.)
replace		Unit = "4.55" if Unit == "Gallon"
replace		Unit = "0.25" if Unit == "250 ML"
replace		Unit = "2.75" if Unit == `"2.75 liters"'
replace		Unit = "0.4" if Unit == `"400 ml'"'
replace		Unit = "0.6" if Unit == `"600ml"'
replace		Unit = "1" if Unit == "Liter"
destring	Unit, replace
replace		Unit = 5 if Unit > 5

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

