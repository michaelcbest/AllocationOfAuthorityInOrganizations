count
drop if Treatment > 4 //drop treatments 5 and 6 (the POPS experiment)
count

label var NewItemID "Item ID"
label var lUnitPrice "log Unit Price"
label var lQuantity "log Quantity"
label var time "Date"
label var Department "Department"
label var District "District"
label var lPriceHat "Fitted Value"

drop if TrimmedSample == 0
drop TrimmedSample
		
label define treatments 1 "Incentives" 2 "Rules" 3 "Both" 4 "Control"

label values GroupFinal treatments
gen Incentives0 = (GroupFinal == 1)
label var Incentives0 "Incentives"
gen Rules0 = (GroupFinal == 2)
label var Rules0 "Rules"
gen Both0 = (GroupFinal == 3)
label var Both0 "Both"

capture drop time2 time3 
drop if time < date("01May2014","DMY") //Drop if before FY 2014-15

tab RandYear Year2
tab Source Year2
keep if Source == "2014-15" // drop the POPS experiment of 2015-16 and the very early pilot orgs pre 2014
		
/* Make weights */
***Make Expenditure Weight in control group in year 1
gen tmp = exp(lUnitPrice) * exp(lQuantity) if GroupFinal == 4 & Year2 == 1 //In-sample expenditure shares by control group in year 2
bys NewItemID: egen ExpInCtrl = sum(tmp)
egen TotSpend = sum(tmp)
gen c = 1
bys NewItemID: egen TotPur=sum(c)
replace ExpInCtrl = ExpInCtrl / (TotSpend*TotPur)
drop tmp TotSpend c TotPur
