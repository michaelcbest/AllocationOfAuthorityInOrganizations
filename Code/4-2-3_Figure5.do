* Load DD results
estimates clear
**autonomy
estimates use "${tempdir}/TabF1_AutReg3"
global b_AutGood = _b[1.Rules0]
global se_AutGood = _se[1.Rules0]
global p_AutGood = e(pRI)[1,1]
global b_AutBad = _b[1.Rules0#1.agD_l22]
global se_AutBad = _se[1.Rules0#1.agD_l22]
global p_AutBad = e(pRI)[1,2]
**incentives
estimates clear
estimates use "${tempdir}/TabF1_IncReg3"
global b_IncGood = _b[1.Incentives0]
global se_IncGood = _se[1.Incentives0]
global p_IncGood = e(pRI)[1,1]
global b_IncBad = _b[1.Incentives0#1.agD_l48]
global se_IncBad = _se[1.Incentives0#1.agD_l48]
global p_IncBad = e(pRI)[1,2]

*Load Semi-parametric results
use "${tempdir}/SemiParEsts.dta", clear

global colorT1 = "gs8"
global colorT2 = "black"
global AutGoodPoint = "{&eta}{sup:Aut} = " + strofreal(${b_AutGood},"%04.3f")
global AutGoodSE = "(" + strofreal(${se_AutGood},"%04.3f") + ") [" + strofreal(${p_AutGood},"%04.3f") + "]"
global AutBadPoint = "{&zeta}{sup:Aut} = " + strofreal(${b_AutBad},"%04.3f")
global AutBadSE = "(" + strofreal(${se_AutBad},"%04.3f") + ") [" + strofreal(${p_AutBad},"%04.3f") + "]"
global IncGoodPoint = "{&eta}{sup:Inc} = " + strofreal(${b_IncGood},"%04.3f")
global IncGoodSE = "(" + strofreal(${se_IncGood},"%04.3f") + ") [" + strofreal(${p_IncGood},"%04.3f") + "]"
global IncBadPoint = "{&zeta}{sup:Inc} = " + strofreal(${b_IncBad},"%04.3f")
global IncBadSE = "(" + strofreal(${se_IncBad},"%04.3f") + ") [" + strofreal(${p_IncBad},"%04.3f") + "]"


graph twoway (rarea TE1_ciub TE1_cilb xpoints, ///
		color("${colorT1}") color(*.2) color(%10) lcolor(white)) ///
		(rarea TE2_ciub TE2_cilb xpoints, ///
			color("${colorT2}") color(*.2) color(%10) lcolor(white)) ///
		(line TE1 xpoints, ///
			lcolor("${colorT1}") ///
			lpattern(dash) ///
			lwidth(medthick)) ///
		(line TE2 xpoints, ///
			lcolor("${colorT2}") ///
			lwidth(medthick)) ///
		(pcarrowi 0.1975 0.1325 0.1975 0.1, color("gs12") lpattern(dash)) ///
		(pcarrowi 0.1975 0.1865 0.1975 0.22, color("gs12")) ///
		(pcarrowi 0.1975 0.25 0.1975 0.22, color("gs8")) ///
		(pcarrowi 0.1975 0.3065 0.1975 0.63, color("gs8")) ///
		(pcarrowi 0.1575 0.385 0.1575 0.1, color("gs4")) ///
		(pcarrowi 0.1575 0.44 0.1575 0.48, color("gs4")) ///
		(pcarrowi 0.1575 0.51 0.1575 0.48, color("black")) ///
		(pcarrowi 0.1575 0.562 0.1575 0.63, color("black")), ///
		graphregion(color(white)) ///
		ytitle("Treatment Effect") ///
		xtitle("AG June Share") ///
		legend(off) ///
		ylabel(-.3(.05).2) ///
		yline(0, lcolor(black)) ///
		xline(0.22 0.48, lpattern(dash) lcolor(gs7)) ///
		text(0.2 0.1325 "${AutGoodPoint}", placement(e) size(small)) ///
		text(0.18 0.1475 "${AutGoodSE}", placement(e) size(vsmall)) ///
		text(0.2 0.25 "${AutBadPoint}", placement(e) size(small)) ///
		text(0.18 0.265 "${AutBadSE}", placement(e) size(vsmall)) ///
		text(0.16 0.385 "${IncGoodPoint}", placement(e) size(small)) ///
		text(0.14 0.4 "${IncGoodSE}", placement(e) size(vsmall)) ///
		text(0.16 0.51 "${IncBadPoint}", placement(e) size(small)) ///
		text(0.14 0.525 "${IncBadSE}", placement(e) size(vsmall)) ///
		text(0.06 0.585 "Incentives", color("${colorT1}")) ///
		text(-.15 0.585 "Autonomy", color("${colorT2}")) ///
		xsize(6.65) ///
		ysize(4)
			
graph export "${picsdir}/Figure5.pdf", replace
graph export "${picsdir}/Figure5.eps", replace
	
