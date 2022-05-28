
* File Cover  - ItemID1009

use 		"${rawdata}/POPSData/NewItemID1009.dta", clear
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
drop 		if UnitPrice < 0.1
drop		if UnitPrice > 1000

global 		Attributes = "BRAND CLIP_A COUNTRY_OF_ORIGIN COVER_MATERIAL CUSTOMIZED_PRINTING FILE_TYPE SIZE"	
global 		NumberOfAttributes = 7

global 		IVar = "BRAND CLIP_A COUNTRY_OF_ORIGIN COVER_MATERIAL CUSTOMIZED_PRINTING FILE_TYPE SIZE"
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

gen 		InReg = (inlist(Treatment,4,5) & TrimmedSample == 1)

/***
###Cleaning Attributes 

1-Some attribute values are duplicated with slightly different spelling 
2-Others are infrequent. 
3-Others only occur in groups 1-3
This part of code groups the attribute values. 

####BRAND
***/

di			"Before Cleaning"
tab			BRAND InReg

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
####CLIP_A
***/

di			"Before Cleaning"
tab			CLIP_A InReg

replace 	CLIP_A = "YES" if INNER_CLIP_TYPE != "NO" & INNER_CLIP_TYPE != ""
drop		INNER_CLIP_TYPE

di			"After Cleaning"
tab			CLIP_A InReg

/***
###COUNTRY_OF_ORIGIN
***/

di "Before Cleaning"
tab COUNTRY_OF_ORIGIN InReg

replace COUNTRY_OF_ORIGIN = "CHINA" if COUNTRY_OF_ORIGIN == "TAIWAN"
replace COUNTRY_OF_ORIGIN = "JAPAN" if COUNTRY_OF_ORIGIN == "IMPORTED"

di "After Cleaning"
tab COUNTRY_OF_ORIGIN InReg

/***
###COVER_MATERIAL
***/

di "Before Cleaning"
tab COVER_MATERIAL InReg

replace COVER_MATERIAL = "ART CARD" if COVER_MATERIAL == "ART"
replace COVER_MATERIAL = "SOFT COVER" if COVER_MATERIAL == "CLOTH"
replace COVER_MATERIAL = "FILE COVER" if COVER_MATERIAL == "FILE FOLDER"
replace COVER_MATERIAL = "LAMINATED" if inlist(COVER_MATERIAL,"CUSTOM","FLYING","GLAZED","LAMINETED","PRINTED")
replace COVER_MATERIAL = "VIP FILE COVER" if COVER_MATERIAL == "LEATHER"
replace COVER_MATERIAL = "ART CARD" if COVER_MATERIAL == "PAPER"
replace COVER_MATERIAL = "REXINE" if COVER_MATERIAL == "PVC"
replace COVER_MATERIAL = "REXINE" if COVER_MATERIAL == "REXENE"

di "After Cleaning"
tab COVER_MATERIAL InReg

/***
###CUSTOMIZED_PRINTING
***/

di "Before Cleaning"
tab CUSTOMIZED_PRINTING InReg

replace CUSTOMIZED_PRINTING = "COLORED" if CUSTOMIZED_PRINTING == "GOLDEN"

/***
###FILE_TYPE
***/

di "Before Cleaning"
tab FILE_TYPE InReg

replace FILE_TYPE = "FOLDER" if FILE_TYPE == "BINDER"
replace FILE_TYPE = "FLAPPER" if FILE_TYPE == "BUTTON FILE COVER"
replace FILE_TYPE = "GATTA" if FILE_TYPE == "CLOTH"
replace FILE_TYPE = "FILE BOARD" if FILE_TYPE == "DUPLEX BOARD"
replace FILE_TYPE = "FILE COVER" if FILE_TYPE == "ENVELOPE"
replace FILE_TYPE = "FOLDER" if FILE_TYPE == "FILE FOLDER"
replace FILE_TYPE = "HARD COVER" if FILE_TYPE == "FLYING"
replace FILE_TYPE = "PLASTIC" if FILE_TYPE == `"PLASTIC FILE COVER / DOCUMENT ENVELOPE"'
replace FILE_TYPE = "GATTA" if FILE_TYPE == "SOFT COVER"
replace FILE_TYPE = "PLASTIC" if FILE_TYPE == "TRANSPARENT"
qui levelsof	FILE_TYPE, local(types)
foreach		type in `types'	{
			di _n `"`type'"'
			count if FILE_TYPE == `"`type'"' & InReg == 1
			if	`r(N)' < 2	{			  
			  replace FILE_TYPE = "" if FILE_TYPE == `"`type'"'
			}
}

di "After Cleaning"
tab FILE_TYPE InReg


/***
####SIZE
***/

di			"Before Cleaning"
tab			SIZE InReg

replace SIZE = `"10 X 14"' if SIZE == `"10" X 14""'
replace SIZE = `"10 X 15"' if SIZE == `"10X15"'
replace SIZE = `"11 X 15"' if SIZE == `"11X5"'
replace SIZE = `"12 X 18"' if SIZE == `"12X18"'
replace SIZE = `"12 X 20"' if SIZE == `"12X2"'
replace SIZE = `"9 X 13"' if SIZE == `"13"X9""'
replace SIZE = `"8 X 13"' if SIZE == `"13*8"'
replace SIZE = `"10 X 13"' if SIZE == `"13X10"'
replace SIZE = `"7 X 13"' if SIZE == `"13X7"'
replace SIZE = `"10 X 14"' if SIZE == `"14" X 10""'
replace SIZE = `"14 X 22"' if SIZE == `"14" X 22""'
replace SIZE = `"9 X 14"' if SIZE == `"14X9"'
replace SIZE = `"9 X 15"' if SIZE == `"15" X 9""'
replace SIZE = `"10 X 15"' if SIZE == `"15"X10""'
replace SIZE = `"10 X 20"' if SIZE == `"20" X 10""'
replace SIZE = `"14 X 22"' if SIZE == `"22" X 14""'
replace SIZE = `"6 X 9"' if SIZE == `"6X9"'
replace SIZE = `"8 X 14"' if SIZE == `"8X14"'
replace SIZE = `"9.5 X 14"' if SIZE == `"91/2X14"'
replace SIZE = "" if SIZE == `"23"X3""'
replace SIZE = "" if SIZE == `"27X4"'

replace SIZE = "LARGE SIZE" if inlist(SIZE,"10 X 13","10 X 14","10 X 15","10 X 20","11 X 15","12 X 18","12 X 20","14 X 22")
replace SIZE = "A4" if inlist(SIZE,"6 X 9","7 X 13","LETTER","F4")
replace SIZE = "LEGAL" if inlist(SIZE,"8 X 13","8 X 14","9 X 13","9 X 14","9 X 15","9.5 X 14","STANDARD SIZE")

di		"After Cleaning"
tab		SIZE InReg

/***
####Unit
***/

di			"Before Cleaning"
tab			Unit InReg
   
replace 	Unit = "" if inlist(Unit,"Bottle of 10 ML","Packet","Packet 900 Gram")
replace		Unit = subinstr(Unit,"Set of ","",.)
replace 	Unit="1"	if  Unit=="Count/Single"
replace		Unit = "1" if Unit == "Single Copy"
replace		Unit = "12" if Unit == "Dozen"
replace 	Unit = "50" if Unit == "Pack of 50 Films"
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
