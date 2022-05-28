
/*  Deal with all the missing values resulting from stacking  */
foreach var of varlist $ivars {
  replace `var' = "000_OTHERVAR" if `var' == ""
  encode `var', gen(`var'2)
  drop `var'
  ren `var'2 `var'
}

foreach var of varlist $nvars {
  replace `var' = 0 if `var' == .
}

encode Department, gen(dept)
drop Department
ren dept Department

encode District, gen(dist)
drop District
ren dist District

gen strata= Department*100 + District //make a variable to indicate strata

replace time = date("21oct2014","DMY") if time == date("21oct2104","DMY")
gen Year2 = time > date("30jun2015","DMY")
gen dYear = yofd(time)
drop if time == .

/* Merge in the randomization wave */

tempfile assignments
preserve
  use "${rawdata}/TreatmentAssignments.dta", clear
  drop if CostCenterID == .
  egen NCCs = count(Source), by(UserID)
  keep CostCenterCode NCCs GroupFinal OfficeID Source
  label var NCCs "Number of CCs in Office"
  label var GroupFinal "Treatment Group"
  label var Source "Randomization Round that this cost center entered the sample"
  label var CostCenterCode "Cost Center Code"
  label var OfficeID "Office ID Code"
  gen tmp = 9999
	replace tmp = 2013 if Source == "Pre 2014-15"
	replace tmp = 2014 if Source == "2014-15"
	replace tmp = 2015 if Source == "2015-16"
	bys OfficeID: egen RandYear = min(tmp)
	drop tmp
  tab RandYear, m
  label var RandYear "Randomization Round that this office entered the sample"
  save `assignments'
restore
merge m:1 CostCenterCode using `assignments', nogen keep(1 3)

/* Names for the items */
gen ItemName = ""
replace ItemName = "Pencil" if NewItemID == 4834
replace ItemName = "Ice Block" if NewItemID == 921
replace ItemName = "Calculator" if NewItemID == 1001
replace ItemName = "Coal" if NewItemID == 2762
replace ItemName = "Staples" if NewItemID == 999
replace ItemName = "Lock" if NewItemID == 943
replace ItemName = "Stamp Pad" if NewItemID == 1030
replace ItemName = "Duster" if NewItemID == 936
replace ItemName = "Floor Cleaner" if NewItemID == 5107
replace ItemName = "File Cover" if NewItemID == 1009
replace ItemName = "Sign Board/Banner" if NewItemID == 20433
replace ItemName = "Stapler" if NewItemID == 998
replace ItemName = "Photocopying" if NewItemID == 1032
replace ItemName = "Toner" if NewItemID == 622
replace ItemName = "Envelope" if NewItemID == 991
replace ItemName = "Light Bulb" if NewItemID == 3906
replace ItemName = "Broom" if NewItemID == 1360
replace ItemName = "Newspaper" if NewItemID == 3346
replace ItemName = "Register" if NewItemID == 994
replace ItemName = "Printer Paper" if NewItemID == 992
replace ItemName = "Pen" if NewItemID == 989
replace ItemName = "Towel" if NewItemID == 927
replace ItemName = "Soap" if NewItemID == 929
replace ItemName = "Wiper" if NewItemID == 938
replace ItemName = "Pipe" if NewItemID == 3507

gen mon = mofd(time)
format mon %tm
egen CCId = group(CostCenterCode)


