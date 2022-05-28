
* ITEMID 929: Soap Or Detergent

use 		"${rawdata}/POPSData/NewItemID929.dta", clear
local 		ItemID = NewItemID
ren			GroupFinal Treatment

drop 		if UnitPrice==.
drop		if RequestID == -1904473573758599200 & DeliveryID == -1904473512122727700 //THIS IS PHENYL. SHOULDN'T BE HERE
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
drop 		if UnitPrice < .02
drop		if UnitPrice > 175

capture drop STATE
rename		STATE_SOLID_LIQUID_OR_POWDER STATE

global 		Attributes = "ANTISEPTIC BRAND STATE TYPE_OF_SOAP"	
global 		NumberOfAttributes = 4

global 		IVar = "ANTISEPTIC BRAND STATE TYPE_OF_SOAP Unit"
global 		NVar = "BarSize BottleSize PacketSize"

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

gen BarSize = Unit if substr(Unit,1,3) == "Bar"
replace Unit = "Bar" if substr(Unit,1,3) == "Bar"
replace BarSize = subinstr(BarSize,"Bar","",.)
replace BarSize = subinstr(BarSize,"Gram","",.)
replace BarSize = subinstr(BarSize,"grams","",.)
replace BarSize = subinstr(BarSize,"gm","",.)
replace BarSize = subinstr(BarSize,"of","",.)
destring BarSize, replace ignore(" ")

replace BarSize = 0 if BarSize == .

gen BottleSize = Unit if substr(Unit,1,6) == "Bottle"
replace Unit = "Bottle" if substr(Unit,1,6) == "Bottle"
replace BottleSize = subinstr(BottleSize,"Bottle","",.)
replace BottleSize = subinstr(BottleSize,"Litre","",.)
destring BottleSize, replace ignore(" ")
replace BottleSize = 0 if BottleSize == .

gen PacketSize = Unit if substr(Unit,1,6) == "Packet" | inlist(Unit,"Gram","Kg","Kilogram","kg")
replace Unit = "Packet" if substr(Unit,1,6) == "Packet" | inlist(Unit,"Gram","Kg","Kilogram","kg")
replace PacketSize = "1" if PacketSize == "Gram"
replace PacketSize = "1000" if inlist(PacketSize,"Kg","Kilogram","kg")
replace PacketSize = subinstr(PacketSize,"Packet ","",.)
replace PacketSize = subinstr(PacketSize,"of ","",.)
replace PacketSize = strofreal(real(substr(PacketSize,1,length(PacketSize)-9))*1000) if substr(PacketSize,-8,8) == "Kilogram"
replace PacketSize = subinstr(PacketSize,"Gram","",.)
replace PacketSize = subinstr(PacketSize,"gram","",.)
replace PacketSize = "" if PacketSize == "Packet"
destring PacketSize, replace ignore(" ")
replace PacketSize = 0 if PacketSize == .

replace Unit = "Count/Single" if Unit == "Dozen"
replace Unit = "Packet" if Unit == "Pack of 6"
replace Unit = "Packet" if Unit == "Ream 480"
di "After Cleaning"
tab Unit InReg

/***
####Antiseptic
***/

di "Before Cleaning"
tab ANTISEPTIC InReg


/***
####BRAND
***/

di "Before Cleaning"
tab BRAND InReg
replace BRAND = "SURF EXCEL" if BRAND == "" & MAKE_B == "SURF_EXCEL"
replace BRAND = "LIFEBOY" if BRAND == "" & MAKE_B == "LIFEBOUY"
replace BRAND = "LEMON MAX" if BRAND == "MAX"
replace BRAND = "LUX" if BRAND == `"VIM POWDER AND LUX SOAP"'
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
####STATE_SOLID_LIQUID
***/

di "Before Cleaning"
tab STATE InReg

/***
####TYPE_OF_SOAP
***/

di "Before Cleaning"
tab TYPE InReg
replace TYPE = "BATHROOM CLEANING" if TYPE == "BLEACH"
replace TYPE = `"LAUNDRY SOAP / SURF / DETERGENT"' if TYPE == "CLOTH CLAENING"
replace TYPE = `"DISH WASHING POWDER"' if TYPE == `"DISH WASH POWDER AND BATH SOAP"'
replace TYPE = `"DISH-WASHING SOAP"' if TYPE == `"DISH WASHING LIQUIED"'
replace TYPE = "HOME CLEANER" if TYPE == "GLASS CLEANER"
replace TYPE = "" if TYPE == "NEEL"
replace TYPE = "" if TYPE == "SHAMPOO"
replace TYPE = "DISH-WASHING SOAP" if TYPE == "FOR HONEY BEE"
replace TYPE = `"LAUNDRY SOAP \ SURF \ DETERGENT"' if TYPE == `"LAUNDRY SOAP / SURF / DETERGENT"'
replace TYPE = "SURF" if substr(TYPE,1,4) == "SURF"
di "After Cleaning"
tab TYPE InReg

codebook 	$Attributes

foreach 	var of varlist $Attributes {
capture 	gen m`var' = (`var' == .)
capture 	gen m`var' = (`var' == "")
} 

egen 		NMissing = rowtotal(m*)
drop 		if NMissing == $NumberOfAttributes

gen mBarSize = (BarSize == 0)
gen mBottleSize = (BottleSize == 0)
gen mPacketSize = (PacketSize == 0)
	
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

