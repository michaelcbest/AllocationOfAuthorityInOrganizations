
* Register  - ItemID994

use 		"${rawdata}/POPSData/NewItemID994.dta", clear
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
drop if lUnitPrice > 10
drop if lUnitPrice < 1

global 		Attributes = "BINDING BRAND COLORED_PAGES CUSTOMIZED_PRINTING NUMBER_OF_PAGES PAGE_SIZE PAGE_WEIGHT_GSM TYPE_OF_REGISTER"	
global 		NumberOfAttributes = 8

global 		IVar = "BINDING BRAND COLORED_PAGES CUSTOMIZED_PRINTING PAGE_SIZE PAGE_WEIGHT_GSM TYPE_OF_REGISTER Unit"
global 		NVar = "NUMBER_OF_PAGES"

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
   
replace 	Unit="1"	if  Unit=="Count/Single"
replace 	Unit="1"	if  Unit=="Count / Single"
replace 	Unit="1"	if  Unit=="Single Copy"
replace		Unit="1"	if 	Unit=="Booklet 100 Pages"
replace		Unit = "Pack of 12"	if	Unit == "Dozen"
replace Unit = "Pack 4-9" if inlist(Unit,"Pack of 4","Pack of 5","Pack of 6")
replace Unit = "Pack 4-9" if inlist(Unit,"Pack of 8","Pack of 9")
replace Unit = "Pack of 12" if Unit == "Pack of 10" | Unit == "Pack of 20"

gen mUnit = 0

di			"After Cleaning"
tab Unit InReg


/***
####Binding
***/

di			"Before Cleaning"
tab			BINDING InReg

replace		BINDING = "" if BINDING == "PLAIN REGISTER" // Plain register is a type of register, not a type of binding
replace		BINDING = "" if BINDING == "TABLE DIARY" // Plain register is a type of register, not a type of binding

di			"After Cleaning"
tab			BINDING InReg

/***
####Brand
***/

di			"Before Cleaning"
tab			BRAND InReg

replace BRAND = "FRIENDS" if BRAND == `"FRIENDS PRINTING PRESS"'

qui levelsof	BRAND, local(brands)
foreach		brand in `brands'	{
			di _n "`brand'"
			count if BRAND == "`brand'" & InReg == 1
			if	`r(N)' < 2	{			  
			  replace BRAND = "" if BRAND == "`brand'"
			}
}
di			"After Cleaning"
tab			BRAND InReg

/***
####COLORED_PAGES
***/

di "Before Cleaning"
tab COLORED_PAGES InReg

replace COLORED_PAGES = "" if COLORED_PAGES == "-"
replace 	COLORED_PAGES="YES"	if  COLORED_PAGES=="LIGHT BLUE"
replace 	COLORED_PAGES="YES"	if  COLORED_PAGES=="MASTER"
replace 	COLORED_PAGES="NO"	if  COLORED_PAGES=="WHITE"

di "After Cleaning"
tab COLORED_PAGES InReg

/***
####CUSTOMIZED_PRINTING
***/

di "Before Cleaning"
tab CUSTOMIZED_PRINTING InReg
replace 	CUSTOMIZED_PRINTING=""		if  CUSTOMIZED_PRINTING=="-"
replace 	CUSTOMIZED_PRINTING="NO"	if  CUSTOMIZED_PRINTING=="NO."
di "After Cleaning"
tab CUSTOMIZED_PRINTING InReg

/***
####NUMBER OF PAGES
***/

di "Before Cleaning"
tab NUMBER_OF_PAGES InReg
replace 	NUMBER_OF_PAGES=subinstr(NUMBER_OF_PAGES,"PAGES","", .)
replace 	NUMBER_OF_PAGES=subinstr(NUMBER_OF_PAGES,"PAGE","", .)
replace 	NUMBER_OF_PAGES=strtrim(NUMBER_OF_PAGES)
replace 	NUMBER_OF_PAGES=""	if  NUMBER_OF_PAGES=="NOT APPLICABLE"
destring 	NUMBER_OF_PAGES, replace
di "After Cleaning"
summ NUMBER_OF_PAGES, det

/***
####PAGE QUALITY / PAGE WEIGHT
***/

di "Before Cleaning"
tab PAGE_QUALITY
tab PAGE_WEIGHT_GSM

*tidy PAGE_QUALITY
replace PAGE_QUALITY = "" if PAGE_QUALITY == "FINE"
replace PAGE_QUALITY = "" if PAGE_QUALITY == "NORMAL"
replace PAGE_QUALITY = "" if PAGE_QUALITY == "ROUGH"
replace PAGE_QUALITY = subinstr(PAGE_QUALITY,"GSM","",.)
replace PAGE_QUALITY = subinstr(PAGE_QUALITY,"GRAM","",.)
replace PAGE_QUALITY = subinstr(PAGE_QUALITY,"GM","",.)
replace PAGE_QUALITY = strtrim(PAGE_QUALITY)

*tidy PAGE_WEIGHT_GSM
replace PAGE_WEIGHT_GSM = subinstr(PAGE_WEIGHT_GSM,"GRAM","",.)
replace PAGE_WEIGHT_GSM = subinstr(PAGE_WEIGHT_GSM,"GM","",.)
replace PAGE_WEIGHT_GSM = strtrim(PAGE_WEIGHT_GSM)

*Where they contradict eachother, take the maximum
replace PAGE_WEIGHT_GSM = PAGE_QUALITY if PAGE_QUALITY == "68" & PAGE_WEIGHT_GSM == "35"
replace PAGE_WEIGHT_GSM = PAGE_QUALITY if PAGE_QUALITY == "80" & PAGE_WEIGHT_GSM == "60"
replace PAGE_WEIGHT_GSM = PAGE_QUALITY if PAGE_QUALITY == "80" & PAGE_WEIGHT_GSM == "70"

*Fill in missings in page weight with page quality
replace PAGE_WEIGHT_GSM = PAGE_QUALITY if PAGE_WEIGHT_GSM == "" & PAGE_QUALITY != ""
drop PAGE_QUALITY

replace PAGE_WEIGHT_GSM = "20" if PAGE_WEIGHT_GSM == "12"
replace PAGE_WEIGHT_GSM = "20" if PAGE_WEIGHT_GSM == "35"

di "After Cleaning"
tab PAGE_WEIGHT_GSM InReg

/***
####PAGE SIZE
***/

di "Before Cleaning"
tab PAGE_SIZE InReg

*Tidy Page Sizes
replace PAGE_SIZE = `"12" X 15""' if PAGE_SIZE == "1.25FEETX1FEET"
replace PAGE_SIZE = `"6" X 10""' if PAGE_SIZE == `"10" X 6""'
replace PAGE_SIZE = `"8" X 10""' if PAGE_SIZE == `"10" X 8""'
replace PAGE_SIZE = `"7" X 10""' if PAGE_SIZE == `"10"X7""'
replace PAGE_SIZE = `"8.5" X 11""' if PAGE_SIZE == `"11 X 8.5 INCHES"'
replace PAGE_SIZE = `"7" X 11""' if PAGE_SIZE == `"11" X 7""'
replace PAGE_SIZE = `"8" X 11""' if PAGE_SIZE == `"11" X 8""'
replace PAGE_SIZE = `"7.5" X 12""' if PAGE_SIZE == `"12 X 7.5 INCHES"'
replace PAGE_SIZE = `"5" X 12""' if PAGE_SIZE == `"12"X5""'
replace PAGE_SIZE = `"3" X 5""' if PAGE_SIZE == "12.5 CM LENGTH X 9.5 CM WIDTH"
replace PAGE_SIZE = `"7.5" X 12.5""' if PAGE_SIZE == `"12.5 X 7.5 INCHES"'
replace PAGE_SIZE = `"11" X 12""' if PAGE_SIZE == "12X11"
replace PAGE_SIZE = `"8" X 12""' if PAGE_SIZE == "12X8"
replace PAGE_SIZE = `"8" X 12""' if PAGE_SIZE == "12X8 INCHES"
replace PAGE_SIZE = `"8" X 13""' if PAGE_SIZE == `"13" X 8""'
replace PAGE_SIZE = `"8.5" X 13.5""' if PAGE_SIZE == "13.5 X 8.5 INCHES"
replace PAGE_SIZE = `"8" X 13""' if PAGE_SIZE == `"13X8"'
replace PAGE_SIZE = `"10" X 15""' if PAGE_SIZE == `"15 X 10"'
replace PAGE_SIZE = `"12" X 15""' if PAGE_SIZE == `"15" X 12 ""'
replace PAGE_SIZE = `"8" X 16""' if PAGE_SIZE == `"16 X 8"'
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"17 INCH X 13 INCH"'
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"17" X 13""'
replace PAGE_SIZE = `"8" X 16""' if PAGE_SIZE == `"16" X 8""'
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"17" X 13""'
replace PAGE_SIZE = `"A2"' if PAGE_SIZE == "17X27/8 INCH"
replace PAGE_SIZE = `"7" X 17""' if PAGE_SIZE == "17X7 INCH"
replace PAGE_SIZE = `"13" X 18""' if PAGE_SIZE == `"18"X13""'
replace PAGE_SIZE = `"13" X 18""' if PAGE_SIZE == `"18X13"'
replace PAGE_SIZE = `"12" X 24""' if PAGE_SIZE == `"24X12"'
replace PAGE_SIZE = `"2" X 3""' if PAGE_SIZE == `"3" X 2""'
replace PAGE_SIZE = `"3" X 5""' if PAGE_SIZE == `"3X5"'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"4X6"'
replace PAGE_SIZE = `"5" X 13""' if PAGE_SIZE == `"5"X13""'
replace PAGE_SIZE = `"3" X 5""' if PAGE_SIZE == `"5X3"'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"6" X 4""'
replace PAGE_SIZE = `"3" X 6""' if PAGE_SIZE == `"6"X3""'
replace PAGE_SIZE = `"6" X 12""' if PAGE_SIZE == `"6X12"'
replace PAGE_SIZE = `"7" X 10.5""' if PAGE_SIZE == `"7 X 10.5""'
replace PAGE_SIZE = `"6" X 7""' if PAGE_SIZE == `"7 X 6 INCHES"'
replace PAGE_SIZE = `"7" X 12""' if PAGE_SIZE == `"7"X12""'
replace PAGE_SIZE = `"7" X 14""' if PAGE_SIZE == `"7"X14""'
replace PAGE_SIZE = `"8" X 10""' if PAGE_SIZE == `"8 X 10 INCHES"'
replace PAGE_SIZE = `"6.5" X 8""' if PAGE_SIZE == `"8 X 6.5 INCHES"'
replace PAGE_SIZE = `"5" X 8""' if PAGE_SIZE == `"8" X 5""'
replace PAGE_SIZE = `"8" X 13""' if PAGE_SIZE == `"8"X13""'
replace PAGE_SIZE = `"4" X 8""' if PAGE_SIZE == `"8"X4""'
replace PAGE_SIZE = `"8.5" X 11""' if PAGE_SIZE == `"8.5"X11""'
replace PAGE_SIZE = `"7" X 8""' if PAGE_SIZE == `"8X7 INCHES"'
replace PAGE_SIZE = `"7" X 9""' if PAGE_SIZE == `"9"X7""'
replace PAGE_SIZE = "A4" if PAGE_SIZE == "COPY SIZE"
replace PAGE_SIZE = `"7" X 10.5""' if PAGE_SIZE == "EXECUTIVE"
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == "LARGE SIZE"
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == "LARGE SIZW"
replace PAGE_SIZE = `"A4"' if PAGE_SIZE == "MEDIUM"
replace PAGE_SIZE = `"A4"' if PAGE_SIZE == "NORMAL"
replace PAGE_SIZE = `"A4"' if PAGE_SIZE == "STANDARD"
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == "TABLOID"
replace PAGE_SIZE = `"5" X 8""' if PAGE_SIZE == "SMALL"
replace PAGE_SIZE = `"6" X 13""' if PAGE_SIZE == `"13"X6"INCH"'
replace PAGE_SIZE = `"14" X 18""' if PAGE_SIZE == `"18X14 INCH"'
replace PAGE_SIZE = `"15" X 18""' if PAGE_SIZE == `"18X15"'
replace PAGE_SIZE = `"13" X 22""' if PAGE_SIZE == `"22X13 ICHES"'
replace PAGE_SIZE = `"3.5" X 5""' if PAGE_SIZE == `"5 X 3.5 INCHES"'
replace PAGE_SIZE = `"6" X 9""' if PAGE_SIZE == `"9X6 INCH"'

*Reassign if singular
replace PAGE_SIZE = `"10" X 14""' if PAGE_SIZE == `"11" X 12""'
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"12" X 24""'
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"13" X 18""'
replace PAGE_SIZE = `"13" X 22""' if inlist(PAGE_SIZE,`"14" X 18""',`"15" X 18""',`"15"X20""')
replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == `"20" X 20""'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"3" X 5""'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"3.5" X 5""'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"3" X 6""'
replace PAGE_SIZE = `"4" X 6""' if PAGE_SIZE == `"4" X 8""'
replace PAGE_SIZE = `"6" X 10""' if PAGE_SIZE == `"5" X 12""'
replace PAGE_SIZE = `"6" X 10""' if PAGE_SIZE == `"5" X 13""'
replace PAGE_SIZE = `"7" X 10""' if inlist(PAGE_SIZE,`"6" X 13""',`"5"X14""')
replace PAGE_SIZE = `"7" X 10""' if PAGE_SIZE == `"6" X 12""'
replace PAGE_SIZE = `"5" X 8""' if PAGE_SIZE == `"6" X 7""'
replace PAGE_SIZE = `"5" X 8""' if PAGE_SIZE == `"6.5" X 8""'
replace PAGE_SIZE = `"6" X 10""' if PAGE_SIZE == `"6" X 9""'
replace PAGE_SIZE = `"12" X 15""' if PAGE_SIZE == `"12 X 16 INCHES"'
replace PAGE_SIZE = `"7" X 11""' if PAGE_SIZE == `"7" X 12""'
replace PAGE_SIZE = `"7.5" X 12.5""' if PAGE_SIZE == `"7.5" X 12""'
replace PAGE_SIZE = "LEGAL" if PAGE_SIZE == `"7" X 14""'
replace PAGE_SIZE = `"8" X 14""' if PAGE_SIZE == `"7" X 17""'
replace PAGE_SIZE = `"6" X 10""' if PAGE_SIZE == `"7" X 8""'
replace PAGE_SIZE = `"7" X 10""' if PAGE_SIZE == `"7" X 9""'
*replace PAGE_SIZE = "A4" if PAGE_SIZE == `"7.5" X 12""'
*replace PAGE_SIZE = "A4" if PAGE_SIZE == `"8" X 11""'
*replace PAGE_SIZE = "LETTER" if PAGE_SIZE == `"8" X 12""'
*replace PAGE_SIZE = "LEGAL" if PAGE_SIZE == `"8" X 13""'
replace PAGE_SIZE = `"8" X 16""' if PAGE_SIZE == `"8" X 18""'
replace PAGE_SIZE = "LETTER" if PAGE_SIZE == `"8.5" X 11""'
replace PAGE_SIZE = "LEGAL" if PAGE_SIZE == `"8.5" X 13.5""'
replace PAGE_SIZE = "LEGAL" if PAGE_SIZE == `"9" X 13""'
*replace PAGE_SIZE = `"13" X 17""' if PAGE_SIZE == "A2"
replace PAGE_SIZE = `"12" X 15""' if PAGE_SIZE == "A3"
replace PAGE_SIZE = `"5" X 8""' if PAGE_SIZE == "A5"
replace PAGE_SIZE = `"2" X 3""' if PAGE_SIZE == "A7"
replace PAGE_SIZE = `"2" X 3""' if PAGE_SIZE == "A9"
*replace PAGE_SIZE = `"10" X 14""' if PAGE_SIZE == "B4"
*replace PAGE_SIZE = "LEGAL" if PAGE_SIZE == "F4"

di "After Cleaning"
tab PAGE_SIZE InReg

/***
####Type of Register
***/

di "Before Cleaning"
tab TYPE_OF_REGISTER InReg

replace TYPE_OF_REGISTER = "LINE REGISTER" if TYPE_OF_REGISTER == "" & TYPE_OF_REGISTER_A == "LINING"
replace TYPE_OF_REGISTER = "SIMPLE" if TYPE_OF_REGISTER == "" & TYPE_OF_REGISTER_A == "SIMPLE"
drop TYPE_OF_REGISTER_A

replace TYPE = "" if TYPE == "-"
replace TYPE = "RECEIPT BOOK" if TYPE == "ACKNOWLWDGMENT FORMS"
replace TYPE = "DIARY REGISTER" if TYPE == "ADDRESS REGISTER"
replace TYPE = "BUDGET REGISTER" if TYPE == "ALLOTMENT"
replace TYPE = "BUDGET REGISTER" if TYPE == "ACCOUNTS"
replace TYPE = "DATA REGISTER" if TYPE == "ANALYSIS"
replace TYPE = "RECEIPT BOOK" if TYPE == "AQUUITTANCE ROLL"
replace TYPE = "ATTENDANCE REGISTER" if TYPE == "ATTENDENCE"
replace TYPE = "ADMISSION REGISTER" if TYPE == "BIRTH REGISTER"
replace TYPE = "SIMPLE" if TYPE == "BOOKLET"
replace TYPE = "VEHICLE LOG BOOK" if TYPE == "BULLDOZER LOG BOOK"
replace TYPE = "FEE DEMAND REGISTER" if TYPE == "CHARACTER CERTIFICATE"
replace TYPE = "CASH BOOK" if TYPE == "CHEQUE REGISTER"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "CHILD HEALTH REGISTER"
replace TYPE = "PAD" if TYPE == "CHIT PAD"
replace TYPE = "STOCK REGISTER" if TYPE == "CLASSIFIED REGISTERS"
replace TYPE = "CASH BOOK" if TYPE == "COLLEGE FUNDS REGISTER"
replace TYPE = "STOCK REGISTER" if TYPE == "CROP REGISTER"
replace TYPE = "" if TYPE == "CTS"
replace TYPE = "DATA REGISTER" if TYPE == "DACK REGISTER (LOCAL)"
replace TYPE = "ATTENDANCE REGISTER" if TYPE == "DAY BOOK"
replace TYPE = "FEE DEMAND REGISTER" if TYPE == "DEMAND REGISTERS"
replace TYPE = "CASH BOOK" if TYPE == "DEPOSIT REGISTER"
replace TYPE = "DIARY REGISTER" if TYPE == "DIARY / DISPATCH"
replace TYPE = "RECEIPT BOOK" if TYPE == "DISCHARGE SLIP REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "DOCK REGISTER"
replace TYPE = "LETTER PAD" if TYPE == "DRAFING PAD"
replace TYPE = "ATTENDANCE REGISTER" if TYPE == "DUTY"
replace TYPE = "ADMISSION REGISTER" if TYPE == "ENTRY"
replace TYPE = "ADMISSION REGISTER" if TYPE == "ENTRY DATE REGISTER"
replace TYPE = "CASH BOOK" if TYPE == "FEE CHALLAN BOOK"
replace TYPE = "DATA REGISTER" if TYPE == "FIELD NOTE BOOK"
replace TYPE = "DATA REGISTER" if TYPE == "FIELD REGISTER"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "FORM-II REGISTER"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "FORM-27 REGISTER"
replace TYPE = "CASH BOOK" if TYPE == "FUND"
replace TYPE = "ADMISSION REGISTER" if TYPE == "GATE PASS"
replace TYPE = "RULLED REGISTER" if TYPE == "GENERAL USE"
replace TYPE = "STOCK REGISTER" if TYPE == "GROSSRY REGISTER"
replace TYPE = "DIARY REGISTER" if TYPE == "HISTERY SHEET REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "INVESTIGATION PADS"
replace TYPE = "DATA REGISTER" if TYPE == "LAB REPORT"
replace TYPE = "DATA REGISTER" if TYPE == "LABORATORY"
replace TYPE = "ADMISSION REGISTER" if TYPE == "LEAVE REGISTER"
replace TYPE = "CASH BOOK" if TYPE == "LEDGER"
replace TYPE = "LETTER PAD" if TYPE == "LETTER PAD (PRINTED)"
replace TYPE = "STOCK REGISTER" if TYPE == "LIBRARY USE-BOOK INFO ENTERING"
replace TYPE = "ADMISSION REGISTER" if TYPE == "LOG BOOK"
replace TYPE = "DATA REGISTER" if TYPE == "MEASUREMENT BOOK"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "MEDICINE REQUEST PAD"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "MEDICAL LEGAL EXAMINATION"
replace TYPE = "DATA REGISTER" if TYPE == "MILK RECORD REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "MOTHER HEALTH REGISTER"
replace TYPE = "PAD" if TYPE == "NOTE BOOK"
replace TYPE = "PAD" if TYPE == "NOTE PAD"
replace TYPE = "PAD" if TYPE == "NOTING SHEET"
replace TYPE = "DIARY REGISTER" if TYPE == "OT REGISTER"
replace TYPE = "OPD TICKET REGISTER" if TYPE == "PASS BOOK"
replace TYPE = "STOCK REGISTER" if TYPE == "PEON REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "PLANTS BOOK"
replace TYPE = "PAD" if TYPE == "POST IT PAD"
replace TYPE = "DATA REGISTER" if TYPE == "POSTMORTEM REGISTER"
replace TYPE = "RECEIPT BOOK" if TYPE == "PRESCRIPTION PAD"
replace TYPE = "SIMPLE" if TYPE == "RAVI RO REGISTER"
replace TYPE = "RECEIPT BOOK" if TYPE == "RECEIPT"
replace TYPE = "DATA REGISTER" if TYPE == "RECOARD REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "RECORD"
replace TYPE = "SIMPLE" if TYPE == "REGISTER"
replace TYPE = "SIMPLE" if TYPE == "REGISTER # 2"
replace TYPE = "SIMPLE" if TYPE == "REGISTERD CARD"
replace TYPE = "DATA REGISTER" if TYPE == "REPAIR BOOK"
replace TYPE = "DATA REGISTER" if TYPE == "RESULTS"
replace TYPE = "CASH BOOK" if TYPE == "SALARY REGISTER"
replace TYPE = "CASH BOOK" if TYPE == "SALE"
replace TYPE = "RECEIPT BOOK" if TYPE == "SERVICE STAMP"
replace TYPE = "ATTENDANCE REGISTER" if TYPE == "STAFF ATTENDANCE REGISTER"
replace TYPE = "RECEIPT BOOK" if TYPE == "STAMP REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "STENO REGISTER"
replace TYPE = "STOCK REGISTER" if TYPE == "STOK REGISTER"
replace TYPE = "ATTENDANCE REGISTER" if TYPE == "STUDENT REGISTER"
replace TYPE = "DATA REGISTER" if TYPE == "SUMMARY"
replace TYPE = "DIARY REGISTER" if TYPE == "TABLE DAIRY"
replace TYPE = "DIARY REGISTER" if TYPE == "TABLE DIARY"
replace TYPE = "DIARY REGISTER" if TYPE == "TELEPHONE REGISTER"
replace TYPE = "BUDGET REGISTER" if TYPE == "TENDER"
replace TYPE = "STOCK REGISTER" if TYPE == "WORK ORDER BOOK"

di "After Cleaning"
tab TYPE InReg
	
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
foreach		var of varlist $NVar_reg {
			global		NRHS = "${NRHS}" + " " + "`var'" + " m" + "`var'"
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

