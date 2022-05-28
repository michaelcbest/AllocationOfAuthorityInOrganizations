  
estimates clear
estimates use "${tempdir}/Y2_Prices_NoCtrl"
estimates store b1
estimates use "${tempdir}/Y2_Prices_AttrCtrl"
estimates store b2
estimates use "${tempdir}/Y2_Prices_ScalCtrl"
estimates store b3
estimates use "${tempdir}/Y2_Variety_Scalar"
estimates store b4
estimates use "${tempdir}/Y2_Prices_CoarseCtrl"
estimates store b5
estimates use "${tempdir}/Y2_Variety_Coarse"
estimates store b6
estimates use "${tempdir}/Y2_Prices_MLCtrl"
estimates store b7
estimates use "${tempdir}/Y2_Variety_ML"
estimates store b8


esttab b4 b6 b8 b1 b2 b3 b5 b7, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0  ) ///
  order(Rules0 Incentives0 Both0 ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Variety" "Unit Price" , ///
	pattern(1 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both", ///
		elist(Incentives0 \addlinespace ///
			Rules0 \addlinespace ///
			Both0 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll pIncAut pBotAut pBotInc N, ///
    labels("Item Variety Measure" "p(All = 0)" "p(Autonomy = Incentives)" ///
		"p(Autonomy = Both)" "p(Incentives = Both)" "Observations") ///
	fmt(3 3 3 3 3 %8.0fc))

*Table2: Regressions of prices and variety on treatments
esttab b4 b6 b8 b1 b2 b3 b5 b7  ///
  using "${tabsdir}/Table2.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0  ) ///
  order(Rules0 Incentives0 Both0 ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Variety" "Unit Price" , ///
	pattern(1 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both", ///
		elist(Incentives0 \addlinespace ///
			Rules0 \addlinespace ///
			Both0 \addlinespace )) ///
  collabels(none) ///
  stats(itemctrl pAll pIncAut pBotAut pBotInc N, ///
    labels("Item Variety Measure" "p(All = 0)" "p(Autonomy = Incentives)" ///
		"p(Autonomy = Both)" "p(Incentives = Both)" "Observations") ///
	fmt(3 3 3 3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
