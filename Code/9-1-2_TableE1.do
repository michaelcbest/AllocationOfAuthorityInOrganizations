
  
estimates clear
estimates use "${tempdir}/TableE1_NoCtrl"
estimates store b1
estimates use "${tempdir}/TableE1_AttrCtrl"
estimates store b2
estimates use "${tempdir}/TableE1_ScalCtrl"
estimates store b3
estimates use "${tempdir}/TableE1_CoarseCtrl"
estimates store b4
estimates use "${tempdir}/TableE1_MLCtrl"
estimates store b5
estimates use "${tempdir}/TableE1_Value_ScalCtrl"
estimates store b6
estimates use "${tempdir}/TableE1_Value_MLCtrl"
estimates store b7

esttab b1 b2 b3 b4 b5 b6 b7, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0  ) ///
  order(Rules0 Incentives0 Both0 ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Quantity" "CF Value" , ///
	pattern(1 0 0 0 0 1 0) ///
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
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc))

*Table: Regressions of quantity on treatments with different item variety controls
esttab b1 b2 b3 b4 b5 b6 b7 ///
  using "${tabsdir}/TableE1.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0  ) ///
  order(Rules0 Incentives0 Both0 ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Quantity" "CF Value" , ///
	pattern(1 0 0 0 0 1 0) ///
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
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
  
