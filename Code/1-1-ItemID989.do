
* Ball Point or Marker or Fountain Pen or Ink Pen - ItemID989

use 		"${rawdata}/POPSData/NewItemID989.dta", clear
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

global 		Attributes = "COLOR MODEL PEN_TYPE THICKNESS_MM"	
global 		NumberOfAttributes = 4

global 		IVar = "COLOR MODEL PEN_TYPE Unit"
global 		NVar = "THICKNESS_MM"

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

Some attribute values are duplicated with slightly different spelling while others
are infrequent. This part of code group the attribute values. 

####COLOR
***/

di "Before Cleaning"
tab COLOR InReg

replace 	COLOR = "BLACK" if COLOR == "BLACK......"
replace 	COLOR = "BLUE" if COLOR == "NO COLOR"
replace 	COLOR = "DIFFERENT COLORS" if COLOR == "RED,BLUE,BLACK" | COLOR == "YELLOW,GREEN,PINK"

di "After Cleaning"
tab COLOR InReg

/***
####MODEL
***/

di "Before Cleaning"
tab MODEL InReg

replace 	MODEL = "CRYSTAL" if MODEL == "BALL POINT CRYSTAL"
replace 	MODEL = "DOLLAR CLIPPER" if MODEL == "DOLLAR BALL POINT"
replace 	MODEL = "DOLLAR ALL MARK" if MODEL == "DR.BOARD"
replace 	MODEL = "DOLLAR POINTER SOFTLINER" if MODEL == "DOLLER GEL"
replace 	MODEL = "DUX" if MODEL == "DUX GEL PEN"
replace 	MODEL = "FINELINER" if MODEL == "FINEST FINE LINER" | MODEL == "MERCURY FINELINER" | MODEL == "PIANO FINELINER"
replace 	MODEL = "MERCURY HANDY" if MODEL == "HANDY"
replace 	MODEL = "MERCURY" if MODEL == "MERCURY POWER"
replace 	PEN_TYPE = "FOUNTAIN PEN / INK PEN" if MODEL == "FOUNTAIN"
replace 	PEN_TYPE = "GEL PEN" if MODEL == "EXPERT GEL BROAD PEN"
replace 	MODEL = "LOCAL" if MODEL == "NAFEES" | MODEL == "FOUNTAIN" 
replace 	MODEL = "IMPORTED" if MODEL == "PARKER" | MODEL == "EXPERT GEL BROAD PEN"
replace 	MODEL = "PIANO POINT" if MODEL == "PIANO GRIP" | MODEL == "PIANO SWITCH"
replace 	MODEL = "UNIBALL EYE" if MODEL == "UNIBALL EYE FINE"
replace 	MODEL = "UNIBALL SIGNO" if MODEL == "SIGNO" | MODEL == "UNIBALL CRYSTAL"
replace 	MODEL = "SIGNATURE BALL POINT" if MODEL == "SIGNATURE GEL"
replace 	MODEL = "UNI BALL POINT" if MODEL == "UNI BALL VISION ELITE"
replace		MODEL = "PICASSO GRIP" if MODEL == "PICASSO"
replace 	MODEL = "SIGNATURE BALL POINT" if MODEL == `"SIGNATURE FLIT BALL (SFB)"'

qui levelsof MODEL, local(models)
foreach		model in `models'	{
			di _n `"`model'"'
			count if MODEL == `"`model'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace MODEL = "" if MODEL == `"`model'"'
			}
}

di "After Cleaning"
tab MODEL InReg

/***
####PEN_TYPE
***/

drop 		if PEN_TYPE == "BOARD MARKER INK" | PEN_TYPE == "CORRECTION PEN" | PEN_TYPE == "CALIGRAPHY" | PEN_TYPE == "HIGHLIGHTER"
replace 	PEN_TYPE = "ERASABLE / WHITE BOARD MARKER" if PEN_TYPE == "BOARD MARKER"
replace		PEN_TYPE = "BALL POINT" if PEN_TYPE == "ROLLERBALL PEN"
replace 	PEN_TYPE = "MARKER" if PEN_TYPE == "SHINING MARKER"

di "After Cleaning"
tab PEN_TYPE InReg


/***
####THICKNESS_MM
***/

destring 	THICKNESS_MM, replace ignore("MM")


/***
####Unit
***/

di "Before Cleaning"
tab			Unit InReg
replace		Unit = "Packet" if Unit == "Bottle of 25 ML"
replace		Unit = "Count / Single" if Unit == "Count/Single"
replace 	Unit = "Pack of 12" if Unit == "Dozen"
replace		Unit = "Larger Pack" if Unit == "Pack of 100"
replace		Unit = "Larger Pack" if Unit == "Pack of 1000"
replace		Unit = "Larger Pack" if Unit == "Pack of 1500"
replace		Unit = "Larger Pack" if Unit == "Pack of 16"
replace		Unit = "Larger Pack" if Unit == "Pack of 20"
replace		Unit = "Larger Pack" if Unit == "Pack of 24"
replace		Unit = "Larger Pack" if Unit == "Pack of 300"
replace		Unit = "Larger Pack" if Unit == "Pack of 40"
replace		Unit = "Larger Pack" if Unit == "Pack of 50"
replace		Unit = "Larger Pack" if Unit == "Pack of 500"
replace		Unit = "Larger Pack" if Unit == "Set of 100"
replace		Unit = "Pack of 3" if Unit == "Pack of 4"
replace		Unit = "Pack of 5" if Unit == "Pack of 6"
replace		Unit = "Pack of 10" if Unit == "Pack of 8"

di "After Cleaning"
tab	Unit InReg

/***
###Reassigning Attributes from Treatment to Control

Changing attribute values of model so that values in group 1-3 have corresponding value in control group
***/

tab 		COLOR InReg	
tab 		MODEL InReg

replace 	MODEL = "IMPORTED" if MODEL == "BLUE NEEDLE HP" | MODEL == "PELIKAN 4001" | MODEL == "PILOT HI-TECH"
replace 	MODEL = "PICASSO CLOUD" if MODEL == "PICCASSO"
replace 	MODEL = "UNIBALL SIGNO" if MODEL == "UNI BALL POINT" 
replace 	MODEL = "SINGATURE" if MODEL == "SIGNATURE BALL POINT" | MODEL == "SIGNATURE FLIT BALL (SFB)" | MODEL == "SIGNATURE BLU"
replace 	MODEL = "UNIBALL EYE" if MODEL == "ROLLER BALL"
replace 	MODEL = "00_MISSING" if MODEL == "IMPORTED" | MODEL == "LOCAL"
	
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
						global		NVar_reg = "${NVar_reg}" + "`var'"
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

replace		DeliveryDate = 52944 - 32872 if DeliveryDate == 52944
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
foreach		var in $NVar {
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
foreach		var in $NVar_reg {
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

