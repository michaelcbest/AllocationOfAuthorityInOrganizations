
*Pipe - ItemID 3507
use 		"${rawdata}/POPSData/NewItemID3507.dta", clear
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
drop 		if UnitPrice <= .01
drop		if UnitPrice > 75

global 		Attributes = "DAIMETER MANUFACTURER MATERIAL SIZE TYPE_OF_PIPE"
global 		NumberOfAttributes = 5

global 		IVar = "MANUFACTURER MATERIAL SIZE TYPE_OF_PIPE Unit"
global 		NVar = "DAIMETER"

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

1-Some attribute values are duplicated with slightly different spellings 
2-Others are infrequent. 
3-Others only occur in groups 1-3
This part of code groups the attribute values. 

DIAMETER
***/

di "Before Cleaning"
tab DAIMETER InReg

replace DAIMETER = subinstr(DAIMETER,"INCHES","INCH",.)
replace DAIMETER = "" if DAIMETER == "16-MTR (50-FEET)"
replace DAIMETER = "1 INCH" if DAIMETER == `"1" X 1" INCH"'
replace DAIMETER = "1.5 INCH" if DAIMETER == `"1-1/2 INCH"'
replace DAIMETER = "1.25 INCH" if DAIMETER == `"1-1/4 INCH"'
replace DAIMETER = "0.5 INCH" if DAIMETER == `"1/2 INCH"'
replace DAIMETER = "0.25 INCH" if DAIMETER == `"1/4 INCH"'
replace DAIMETER = "0.125 INCH" if DAIMETER == `"1/8 INCH"'
replace DAIMETER = "" if DAIMETER == "120 FEET"
replace DAIMETER = "2.5 INCH" if DAIMETER == "2-1/2 INCH"
replace DAIMETER = "0.1 INCH" if DAIMETER == "2.5 MM"
replace DAIMETER = "1 INCH" if DAIMETER == "2.5. CM]"
replace DAIMETER = "" if DAIMETER == "20 FEET"
replace DAIMETER = "" if DAIMETER == "240"
replace DAIMETER = "1 INCH" if DAIMETER == "25MM"
replace DAIMETER = "0.75 INCH" if DAIMETER == "3/4 INCH"
replace DAIMETER = "0.375 INCH" if DAIMETER == "3/8 INCH"
replace DAIMETER = "1.25 INCH" if DAIMETER == "32MM"
replace DAIMETER = "0.675 INCH" if DAIMETER == "5/8"
replace DAIMETER = "7" if DAIMETER == "7 INCHE"
replace DAIMETER = "0.3 INCH" if DAIMETER == "8MM"
replace DAIMETER = "" if DAIMETER == "NA"
replace DAIMETER = "" if DAIMETER == `"PART NO.130-03-71220 FOR KOMATSU BULLDOZER D50-A17"'
replace DAIMETER = "0.3 INCH" if DAIMETER == `"0.75 CM"'
replace DAIMETER = "0.6 INCH" if DAIMETER == `"0,6 INCH"'
replace DAIMETER = "0.2 INCH" if DAIMETER == `"4MM"'
replace DAIMETER = "2 INCH" if DAIMETER == `"6CM"'
replace DAIMETER = trim(subinstr(DAIMETER,"INCH","",.))
destring DAIMETER, replace

di "After Cleaning"
summ DAIMETER


/***
####MANUFACTURER
***/

di "Before Cleaning"
tab MANUFACTURER InReg

replace MANUFACTURER = "CHINA" if inlist(MANUFACTURER,"FOREIGN","IMPORTED","INTERNATIONAL")
replace MANUFACTURER = "CHINA" if inlist(MANUFACTURER,"JAPAN","LOK TAIWAN","NISSAN")
replace MANUFACTURER = "CHINA" if inlist(MANUFACTURER,"KOREA","TAIWAN")
replace MANUFACTURER = "PAKISTAN PIPES" if substr(MANUFACTURER,2,14) == `"PAKISTAN PIPES"'
replace MANUFACTURER = "PVC" if MANUFACTURER == "ROYAL PVC"
replace MANUFACTURER = "TARBALLA" if MANUFACTURER == "TURBELA"
replace MANUFACTURER = "BBJ PIPES" if MANUFACTURER == `"BBJ"'
qui levelsof MANUFACTURER, local(manufacturers)
foreach		manufacturer in `manufacturers'	{
			di _n `"`manufacturer'"'
			count if MANUFACTURER == `"`manufacturer'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace MANUFACTURER = "" if MANUFACTURER == `"`manufacturer'"'
			}
}

di "After Cleaning"
tab MANUFACTURER InReg


/***
####MATERIAL
***/

di "Before Cleaning"
tab MATERIAL InReg

replace MATERIAL = "STEEL" if inlist(MATERIAL,"CARBOL STEEL (CS)","STAINLESS STEEL")
replace MATERIAL = "JASTI" if MATERIAL == "GALVINIZED IRON (GI)"
replace MATERIAL = "PLASTIC" if MATERIAL == "NILON"
replace MATERIAL = "PLASTIC" if MATERIAL == "PLASTIC AND STEEL"
replace MATERIAL = "RUBBER" if MATERIAL == "SILICONE"
replace MATERIAL = "IRON" if inlist(MATERIAL,"COPPER","STAINLESS STEEL","STEEL")
replace MATERIAL = "PVC" if MATERIAL == "HDPE"

qui levelsof MATERIAL, local(materials)
foreach		material in `materials'	{
			di _n `"`material'"'
			count if MATERIAL == `"`material'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace MATERIAL = "" if MATERIAL == `"`material'"'
			}
}

di "After Cleaning"
tab MATERIAL InReg

/***
####SIZE
***/

di "Before Cleaning"
tab SIZE InReg

replace SIZE = "1.5-4 FEET" if SIZE == "1.5 FEET"
replace SIZE = "1.5-4 FEET" if SIZE == "2 FEET"
replace SIZE = "1.5-4 FEET" if SIZE == "3 FEET"
replace SIZE = "1.5-4 FEET" if SIZE == "1 YARD"
replace SIZE = "0_75 INCH" if SIZE == `"3/4""'
replace SIZE = "1.5-4 FEET" if SIZE == "4 FEET"
replace SIZE = "6-20 FEET" if inlist(SIZE,"8FEET","9 FEET","10 FEET")
replace SIZE = "6-20 FEET" if inlist(SIZE,"12 FEET","13 FEET","6 FEET")
replace SIZE = "6-20 FEET" if inlist(SIZE,"15 FEET","16 FEET","20 FEET")
replace SIZE = "21-99 FEET" if inlist(SIZE,"26FEET","30 FEET","32 FEET")
replace SIZE = "21-99 FEET" if inlist(SIZE,"34FEET","35 FEET","40 FEET")
replace SIZE = "21-99 FEET" if inlist(SIZE,"60 FEET","70 FEET")
replace SIZE = "21-99 FEET" if inlist(SIZE,"46 FEET","50 FEET","80 FEET")
replace SIZE = "100 FEET" if SIZE == "123 FEET"
replace SIZE = "100 FEET" if SIZE == "32M"
replace SIZE = "140 FEET" if SIZE == "150 FEET"
replace SIZE = "250 FEET" if inlist(SIZE,"210 FEET","240 FEET","270 FEET")
replace SIZE = "300 FEET and up" if inlist(SIZE,"300 FEET","300 FT","350 FEET")
replace SIZE = "300 FEET and up" if inlist(SIZE,"356 FEET","400 FEET")
replace SIZE = "" if inlist(SIZE,"16 GUAGE","18 WSG","1X6","200")
replace SIZE = "" if inlist(SIZE,"22 GUAGE","3-3/4","7 SUTER","4X4")
replace SIZE = "1.5 INCHES" if SIZE == "1-1/2 INCHES" | SIZE == "40MM"
replace SIZE = "" if inlist(SIZE,"1/2 MM","3MM")
replace SIZE = "4 INCHES" if SIZE == "5 INCHES"
replace SIZE = "1 FEET" if SIZE == "8 INCHES"
replace SIZE = "" if SIZE == "NA"

di "After Cleaning"
tab SIZE InReg

/***
####UNIT
***/

di "Before Cleaning"
tab Unit InReg

gen mUnit = 0
replace Unit = "Feet" if inlist(Unit,"Inch","Pipe of length 6 inches")
replace Unit = "Feet" if inlist(Unit,"Yard","pipe of length 1 feet")
replace mUnit = 1 if Unit == "Kilogram"
replace Unit = "" if Unit == "Kilogram"
replace mUnit = 1 if Unit == "Millimeter"
replace Unit = "" if Unit == "Millimeter"

di "After Cleaning"
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
