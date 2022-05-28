* ITEMID 622: Toner

use 		"${rawdata}/POPSData/NewItemID622.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

replace		DeliveryDate = DocumentDate if RequestID == 185069
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


global 		Attributes = "MODEL REFILL_OR_NEW_CARTRIDGE"	
global 		NumberOfAttributes = 2

global 		IVar = "MODEL REFILL_OR_NEW_CARTRIDGE"
global 		NVar = ""

foreach 	var of varlist $Attributes {
label 		var `var' "`var'"
}

drop 		if UnitPrice < 100
drop		if UnitPrice > 30000

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

####MODEL
***/

di			"Before Cleaning"
tab			MODEL InReg
tab			MACHIENE_MODEL_A InReg

replace		MODEL = MACHIENE_MODEL_A if MODEL == "" & MACHIENE_MODEL_A != ""
drop 		MACHIENE_MODEL_A
replace		MODEL = "BIZHUB" if inlist(MODEL,"BIZHUB 164","BIZHUB 211","BIZHUB 363")
replace 	MODEL = "CANON" if MODEL == "CANON 2900-B"
replace 	MODEL = "CANON" if MODEL == "CANON 6670"
replace		MODEL = "CANON IR" if inlist(MODEL,"CANON IR 2016","CANON IR 2318","CANON IR 3530","CANON IR-2520")
replace		MODEL = "CANON L" if inlist(MODEL,"CANON L-140","CANON L-220","CANON L2318")
replace		MODEL = "CANON LBP" if inlist(MODEL,"CANON LBP 2900","CANON LBP 3370")
replace 	MODEL = "CANON" if MODEL == "CANON SLB 6670 PM"
replace		MODEL = "" if MODEL == "DELL"
replace		MODEL = "EPSON/GESTETNER" if inlist(MODEL,"DSM725","E STUDIO 352","EPSON","GESTETNER","GESTETNER 725")
replace 	MODEL = "EPSON/GESTETNER" if MODEL == "E STUDIO MODEL 166"
replace		MODEL = "HP 1005" if MODEL == "HP 1000"
replace		MODEL = "HP 1018" if MODEL == "HP 1012"
replace		MODEL = "HP 12-A" if MODEL == "HP 11A"
replace		MODEL = "HP 12-A" if MODEL == "HP 13-A"
replace		MODEL = "HP 1320" if MODEL == "HP 1350W"
replace		MODEL = "HP 15XX" if inlist(MODEL,"HP 1500","HP 1505","HP 1522")
replace		MODEL = "HP 2015" if MODEL == "HP 2015 LASER JET"
replace		MODEL = "HP 2015" if MODEL == "HP LSER JET P-2015"
replace		MODEL = "HP 2035" if MODEL == "HP 2025"
replace		MODEL = "HP 2055" if MODEL == "HP 2050"
replace		MODEL = "HP [2100-2600)" if inlist(MODEL,"HP 2100","HP 2200","HP 2250","HP 2300-DN","HP LASER 2300N","HP 2350")
replace		MODEL = "HP [2100-2600)" if inlist(MODEL,"HP 2420","HP 2507","HP 2550","HP 2571")
replace		MODEL = "HP [2100-2600)" if MODEL == "HP LASERJET M2727 NF"
replace		MODEL = "HP 35-A" if MODEL == "HP 27-A"
replace		MODEL = "HP 3XXX" if inlist(MODEL,"HP 3005","HP 3015","HP 3030","HP 3055","HP 3125")
replace 	MODEL = "HP 35-A" if MODEL == "HP 38-A"
replace		MODEL = "HP [4000,.)" if inlist(MODEL,"HP 4000","HP 4015N","HP 4100","HP 4500","HP 7000","HP 7213","HP D4550")
replace 	MODEL = "HP [4000,.)" if MODEL == "HP 500"
replace		MODEL = "HP 400" if MODEL == "HP 401"
replace		MODEL = "HP 49-A" if MODEL == "HP 42A"
replace		MODEL = "HP 85-A" if MODEL == "HP 83 A"
replace		MODEL = "HP 1005" if MODEL == "HP 920"
replace		MODEL = "HP 92-A" if MODEL == "HP 96-A"
replace		MODEL = "HP 92-A" if MODEL == "HP 97" | MODEL == "HP MFP125"
replace		MODEL = "HP 1102" if MODEL == "HP LASER JET P1102"
replace		MODEL = "HP 1320" if MODEL == "HP M1319"
replace		MODEL = "HP 1102" if MODEL == "HP- P1102"
replace		MODEL = "HP 1010" if MODEL == "HP1012"
replace		MODEL = "HP 1005" if MODEL == "HP 1005"
replace		MODEL = "KONICA" if inlist(MODEL,"KONICA 1350","KONICA 350","KONICA 3530","KONICA 8020","KONICA MINOLTA 215","KONICA MINOLTA 216","KONICA MINOLTA 300","KINOCA MINOLTA 7216","KONICA MINOLTA 7220")
replace		MODEL = "KONICA" if MODEL == `"KONICA MINOLTA 350 COPIER"'
replace 	MODEL = "KYOCERA" if inlist(MODEL,"KYOCERA 1635","KYOCERA TK-20")
replace		MODEL = "HP 1020" if MODEL == "LASER JET 1020"
replace 	MODEL = "HP 3XXX" if MODEL == "LASER JET 3250"
replace		MODEL = "LEXMARK" if inlist(MODEL,"LEXMARK E-250","LEXMARK E166")
replace		MODEL = "XEROX" if MODEL == "MS4500"
replace		MODEL = "CANON IR" if MODEL == "NPG51"
replace		MODEL = "PANASONIC" if MODEL == "PANASONIC 8020"
replace		MODEL = "PANASONIC" if MODEL == "PANASONIC 8106"
replace		MODEL = "PANASONIC KX-FL" if inlist(MODEL,"PANASONIC FL-220","PANASONIC FL422","PANASONIC KX 542","PANASONIC KX-4983","PANASONIC KX-FL 422")
replace		MODEL = "" if MODEL == "PM 4580"
replace		MODEL = "RICOH" if inlist(MODEL,"RICHO","RICHO MP2501","RICOH 2220D","RICOH 4500","RICOH 5000")
replace		MODEL = "SAMSUNG ML 2XXX" if inlist(MODEL,"SAMSUNG 2250","SAMSUNG 2550","SAMSUNG 2850","SAMSUNG ML 2550","SAMSUNG ML-2200","SAMSUNG ML-2571","SAMSUNG ML2165","SAMSUNG ML2250")
replace		MODEL = "SAMSUNG" if inlist(MODEL,"SAMSUNG MI350","SAMSUNG ML1660","SAMSUNG ML 1660","SAMSUNG ML-3050","SAMSUNG ML4550")
replace		MODEL = "KYOCERA" if MODEL == "TASKALFA221"
replace		MODEL = "TONER TK-20" if MODEL == "TONNER TK 20"
replace		MODEL = "TOSHIBA <300" if inlist(MODEL,"TOSHIBA STUDIO 161","TOSHIBA STUDIO 163","TOSHIBA 161","TOSHIBA 181","TOSHIBA 232","TOSHIBA 250","TOSHIBA 282")
replace		MODEL = "TOSHIBA 452" if MODEL == "TOSHIBA 425"
replace		MODEL = "TOSHIBA 352" if MODEL == "TOSHIBA 350"
replace		MODEL = "TOSHIBA" if inlist(MODEL,"TOSHIBA 1640","TOSHIBA 1800","TOSHIBA 2030","TOSHIBA 2060","TOSHIBA 2310","TOSHIBA 2500","TOSHIBA 3520","TOSHIBA 3560")
replace		MODEL = "TOSHIBA" if inlist(MODEL,"TOSHIBA T-1810D")
replace		MODEL = "XEROX 31XX" if inlist(MODEL,"XEROX 3125","XEROX 3130","XEROX 3150")
replace 	MODEL = "" if substr(MODEL,1,5) == "SHARP"
di "After Cleaning"
tab MODEL InReg


/***
####REFILL_OR_NEW_CARTRIDGE
***/

di "Before Cleaning"
tab REFILL InReg
drop if REFILL == "NEW BLADE FOR TONER" // This isn't toner, it's a part of the photocopier/printer
replace REFILL = "DRUM REPLACMENT" if REFILL == "NEW TONER DRUM"
di "After Cleaning"
tab REFILL InReg

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

