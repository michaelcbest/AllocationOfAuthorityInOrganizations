
use "${usedata}/UsingData.dta", clear

keep lUnitPrice lPriceHat NewItemID
keep if inlist(NewItemID,992,994,622,989)

*===============*
*	PAPER		*
*===============*

drop if (lUnitPrice > 0.85 | lPriceHat > 0.85) & NewItemID == 992

twoway (scatter lPriceHat lUnitPrice if lPriceHat < .199 | lPriceHat > .24, ///
		mcolor(gs10%40) msymbol(oh)) ///
	(scatter lPriceHat lUnitPrice if lPriceHat >= .199 & lPriceHat <= .24, ///
		mcolor(gs1%40) msymbol(oh)) ///
	(pcarrowi 0.45 -0.3 0.23 -0.352, color(gs7)) ///
	(pcarrowi 0.42 0.475 0.24 0.59, color(gs7)) ///
	if NewItemID == 992, ///
	graphregion(color(white)) ///
	xtitle("Price Paid Per Sheet of Paper (Rs.)") ///
	xlabel(-0.288 "0.75" 0 "1" 0.223 "1.25" 0.405 "1.5" 0.56 "1.75" 0.693 "2" 0.811 "2.25", ///
	 grid) ///
	ytitle("Standardized Price of Paper (Rs.)") ///
	ylabel(-0.288 "0.75" 0 "1" 0.223 "1.25" 0.405 "1.5" 0.56 "1.75" 0.693 "2" 0.811 "2.25") ///
	legend(off) ///
	text(0.55 -0.16 "High performer: Pays Rs 0.70", size(small)) ///
	text(0.5 -0.195 "for paper worth Rs 1.25", size(small)) ///
	text(0.51 0.485 "Poor performer: Pays Rs 1.80", size(small)) ///
	text(0.46 0.45 "for paper worth Rs 1.25", size(small)) 
graph export "${picsdir}/FigureA1B.pdf", replace
graph export "${picsdir}/FigureA1B.eps", replace
	

*===============*
*	REGISTER	*
*===============*

drop if (lUnitPrice > 7.5 | lPriceHat > 7.5) & NewItemID == 994

twoway (scatter lPriceHat lUnitPrice if lPriceHat < 4.8995 | lPriceHat > 5.0556, ///
		mcolor(gs10%40) msymbol(oh)) ///
	(scatter lPriceHat lUnitPrice if lPriceHat >= 4.8995 & lPriceHat <= 5.0556, ///
		mcolor(gs1%40) msymbol(oh)) ///
	(pcarrowi 5.8 3.75 5.075 4.075, color(gs7)) ///
	(pcarrowi 4.2 6.9 4.977 6.555, color(gs7)) ///
	if NewItemID == 994, ///
	graphregion(color(white)) ///
	xtitle("Price Paid Per Register (Rs.)") ///
	xlabel(3.218 "25" 3.912 "50" 4.605 "100" 5.298 "200" 6.215 "500" 7.003 "1,100", ///) 
	 grid) ///
	ytitle("Standardized Price of Register (Rs.)") ///
	ylabel(3.218 "25" 3.912 "50" 4.605 "100" 5.298 "200" 6.215 "500" 7.003 "1,100") ///
	legend(off) ///
	text(6.05 3.83 "High performer: Pays Rs 60", size(small)) ///
	text(5.9 3.75 "for register worth Rs 150", size(small)) ///
	text(4.1 6.8 "Poor performer: Pays Rs 700", size(small)) ///
	text(3.95 6.685 "for register worth Rs 150", size(small)) 
graph export "${picsdir}/FigureA1C.pdf", replace
graph export "${picsdir}/FigureA1C.eps", replace


*===========*
*	TONER	*
*===========*

drop if (lUnitPrice > 9.5 | lPriceHat > 9.5) & NewItemID == 622

twoway (scatter lPriceHat lUnitPrice if lPriceHat < 7.985 | lPriceHat > 8.24, ///
		mcolor(gs10%40) msymbol(oh)) ///
	(scatter lPriceHat lUnitPrice if lPriceHat >= 7.985 & lPriceHat <= 8.24, ///
		mcolor(gs1%40) msymbol(oh)) ///
	(pcarrowi 9.65 9 8.21 9.35, color(gs7)) ///
	(pcarrowi 9.4 6.75 8.22 7.34, color(gs7)) ///
	if NewItemID == 622, ///
	graphregion(color(white)) ///
	xtitle("Price Paid Per Toner (Rs.)") ///
	xlabel(5.704 "300" 6.215 "500" 6.908 "1,000" 7.601 "2,000" 8.517 "5,000" 9.210 "10,000", ///) 
	 grid) ///
	ytitle("Standardized Price of Toner (Rs.)") ///
	ylabel(5.704 "300" 6.215 "500" 6.908 "1,000" 7.601 "2,000" 8.517 "5,000" 9.210 "10,000") ///
	legend(off) ///
	text(9.7 6.5 "High performer: Pays Rs 1550", size(small)) ///
	text(9.49 6.38 "for toner worth Rs 3500", size(small)) ///
	text(10 9 "Poor performer: Pays Rs 11000", size(small)) ///
	text(9.79 8.865 "for toner worth Rs 3500", size(small)) 
graph export "${picsdir}/FigureA1D.pdf", replace
graph export "${picsdir}/FigureA1D.eps", replace


*===========*
*	PEN		*
*===========*

drop if (lUnitPrice <= 1 | lPriceHat <= 1) & NewItemID == 989
drop if (lUnitPrice > 6 | lPriceHat > 6) & NewItemID == 989

twoway (scatter lPriceHat lUnitPrice if lPriceHat < 3.075 | lPriceHat > 3.278, ///
		mcolor(gs10%40) msymbol(oh)) ///
	(scatter lPriceHat lUnitPrice if lPriceHat >= 3.075 & lPriceHat <= 3.278, ///
		mcolor(gs1%40) msymbol(oh)) ///
	(pcarrowi 4.5 0.5 3.24 1.25, color(gs7)) ///
	(pcarrowi 1.8 5.3 3.05 4.8, color(gs7)) ///
	if NewItemID == 989, ///
	graphregion(color(white)) ///
	xtitle("Price Paid Per Pen (Rs.)") ///
	xlabel(1.099 "3" 1.609 "5" 2.303 "10" 3.219 "25" 3.912 "50" 4.605 "100" 5.298 "200" 5.991 "400", ///
	 grid) ///
	ytitle("Standardized Price of Pen (Rs.)") ///
	ylabel(1.099 "3" 1.609 "5" 2.303 "10" 3.219 "25" 3.912 "50" 4.605 "100" 5.298 "200" 5.991 "400") ///
	legend(off) ///
	text(4.9 1.275 "High performer: Pays Rs 3.50", size(small)) ///
	text(4.65 0.975 "for pen worth Rs 25", size(small)) ///
	text(1.6 5.2 "Poor performer: Pays Rs 115", size(small)) ///
	text(1.35 4.95 "for pen worth Rs 25", size(small)) 
graph export "${picsdir}/FigureA1A.pdf", replace
graph export "${picsdir}/FigureA1A.eps", replace
