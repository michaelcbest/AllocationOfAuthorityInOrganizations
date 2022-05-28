*===============================================================================*
*		Clean the item dataset so that it can be used in the regression			*
*		Called from: 1-1-3-BuildRegData.do										*
*		Input: 																	*
*			RegAttributes_Item`item'											*
*			Item`item'															*
*		Output:																	*
*			RegData`item'														*
*===============================================================================*

use "${tempdir}/RegAttributes_Item${item}.dta", clear

global nvars = RegNVars
global ivars = RegIVars

use "${tempdir}/Item${item}.dta", clear

capture confirm variable NMissing
if !_rc {
	di "NMissing exists"
}
else {
	di "NMissing doesn't exist"
	gen NMissing = 0
}

keep ${nvars} ${ivars} NewItemID lUnitPrice lQuantity time* DocumentDate CostCenterCode TrimmedSample Treatment Department District RequestID DeliveryID NMissing

foreach var of varlist $ivars {
  decode `var', gen(`var'_str)
  drop `var'
  ren `var'_str `var'
}

foreach var of varlist $nvars $ivars {
  ren `var' `var'_It${item}
}

decode Department, gen(dept)
drop Department
ren dept Department

decode District, gen(dist)
drop District
ren dist District

compress

save "${tempdir}/RegData${item}.dta", replace
