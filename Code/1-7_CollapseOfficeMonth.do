*1. Prepare the data

use "${usedata}/UsingData.dta", clear
capture drop DeliveryDate
ren time DeliveryDate
gen control = (GroupFinal == 4)
drop if DeliveryDate > date("01Jul2016","DMY")
drop if DeliveryDate < date("01Jun2015","DMY")
keep if Fiscal_Year == "2015-16"
gen month = mofd(DeliveryDate)
gen AmountCF = exp(lPriceHat) * exp(lQuantity)
merge m:1 District using "${usedata}/JuneSpikes.dta", nogen
replace agJune = 0 if agJune == .

tempfile itemdictionary
preserve
	keep NewItemID ItemName
	drop if NewItemID == .
	duplicates drop
	sort NewItemID
	gen ItemNumber = _n
	isid NewItemID
	ren NewItemID ItemIDDict
	isid ItemNumber
	save `itemdictionary'
restore

*2. Collapse by Month
collapse (sum) AmountCF (count) N=lUnitPrice, ///
		by(NewItemID OfficeID Treatment District agJune strata month)
fillin NewItemID OfficeID month
replace AmountCF = 0 if AmountCF == .
replace N = 0 if N == .
bys OfficeID: egen T = mode(Treatment), maxmode
replace Treatment = T if Treatment == .
drop T
bys OfficeID: egen D = mode(District), maxmode
replace District = D if District == .
drop D
bys OfficeID: egen A = mode(agJune), maxmode
replace agJune = A if agJune == .
drop A
bys OfficeID: egen S = mode(strata), maxmode
replace strata = S if strata == .
drop S
drop _fillin
reshape wide AmountCF N, i(OfficeID month) j(NewItemID)
gen ItemNumber = _n 
merge 1:1 ItemNumber using `itemdictionary', assert(1 3) keep(1 3) nogen
replace ItemNumber = . if ItemName == ""
save "${usedata}/OfficeMonth.dta", replace
