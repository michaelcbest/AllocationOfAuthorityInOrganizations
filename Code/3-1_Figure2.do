use "${usedata}/UsingData.dta", clear

*Code the Item Names for the Figure
capture drop ItemName
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
replace ItemName = "Pipe" if NewItemID == 3507
replace ItemName = "Wiper" if NewItemID == 938
replace ItemName = "Stamp Pad" if NewItemID == 1030

gen exp = exp(lUnitPrice) * exp(lQuantity)

*Number of people who buy each item
egen NPBs = tag(NewItemID CostCenterCode)

*Create data to plot
collapse (mean) avg_price = lUnitPrice avg_qual = lPriceHat ///
	(median) med_price = lUnitPrice med_qual = lPriceHat ///
	(p10) p10_price = lUnitPrice p10_qual = lPriceHat ///
	(p25) p25_price = lUnitPrice p25_qual = lPriceHat ///
	(p75) p75_price = lUnitPrice p75_qual = lPriceHat ///
	(p90) p90_price = lUnitPrice p90_qual = lPriceHat ///
	(count) N = Treatment ///
	(sum) exp NPBs, ///
	by(NewItemID ItemName)
	
*Draw
egen Order = rank(exp), unique
gen qualpos = Order + 0.2
gen pricepos = Order - 0.2
labmask Order, values(ItemName)
gen NPos = 13.1
gen NLabs = string(N,"%9.0fc")
gen ExpPos = 18.5
gen ExpLabs = string(exp,"%11.0fc")
gen PBPos = 21.5
gen PBLabs = string(NPBs,"%9.0fc")
gen whitex1 = 10.1
gen whitex2 = 21.3
gen whiteOrder = Order
replace whiteOrder = 25.1 if whiteOrder == 25
replace whiteOrder = 12.9 if whiteOrder == 13
replace whiteOrder = 12.1 if whiteOrder == 12
replace whiteOrder = 0.9 if whiteOrder == 1


twoway (scatter Order NPos, msymbol(none)) ///
	(rarea whitex1 whitex2 whiteOrder, horizontal sort color(white)) ///
	(scatter Order NPos, mlabel(NLabs) mlabpos(9) msymbol(none) mlabcolor(black) mlabsize(vsmall)) ///
	(scatter Order ExpPos, mlabel(ExpLabs) mlabpos(9) msymbol(none) mlabcolor(black) mlabsize(vsmall)) ///
	(scatter Order PBPos, mlabel(PBLabs) mlabpos(9) msymbol(none) mlabcolor(black) mlabsize(vsmall)) ///
	(rbar p25_price p75_price pricepos, horizontal barwidth(0.3) lcolor(gs3%25) fcolor(none)) ///
	(rbar p25_price p75_price pricepos, horizontal barwidth(0.3) color(gs3%25)) ///
	(rbar p25_qual p75_qual qualpos, horizontal barwidth(0.3) color(gs9%25)) ///
	(rcap p10_price p90_price pricepos, horizontal color(gs3%35)) ///
	(rcap p10_qual p90_qual qualpos, horizontal color(gs9%35)) ///
	(scatter pricepos med_price, mcolor(gs3%50) msymbol(+)) ///
	(scatter qualpos med_qual, mcolor(gs9%50) msymbol(+)) ///
	(scatter pricepos avg_price, mcolor(gs3%50) msymbol(smcircle_hollow)) ///
	(scatter qualpos avg_qual, mcolor(gs9%50) msymbol(smcircle_hollow)), ///
		graphregion(color(white)) ///
		legend(order(6 9 11 13 7 8)) ///
		legend(label(6 "p25-p75")) ///
		legend(label(9 "p10-p90")) ///
		legend(label(11 "Median")) ///
		legend(label(13 "Mean")) ///
		legend(label(8 "Stdized P")) ///
		legend(label(7 "log Unit Price")) ///
		legend(cols(4)) ///
		legend(rows(2)) ///
		legend(holes(5)) ///
		legend(size(vsmall)) ///
		ylabel(1(1)25, valuelabel angle(horizontal) labsize(small)) ///
		xlabel(-5(2.5)10, grid labsize(small)) ///
		xsc(r(-5 12)) ///
		text(25.85 10.35 "{bf:Observations}", size(1.75)) ///
		text(25.85 15.9 "{bf:Expenditure (Rs.)}", size(1.75)) ///
		text(25.85 20.3 "{bf:Offices}", size(1.75)) ///
		xsize(8.5) ///
		ysize(11) 

graph export "${picsdir}/Figure2.pdf", replace
graph export "${picsdir}/Figure2.eps", replace
