
estimates clear
estimates use "${tempdir}/DD_Prices_NoCtrl"
estimates store b1
estimates use "${tempdir}/DD_Prices_AttrCtrl"
estimates store b2
estimates use "${tempdir}/DD_Prices_ScalCtrl"
estimates store b3
estimates use "${tempdir}/DD_Variety_Scalar"
estimates store b4
estimates use "${tempdir}/DD_Prices_CoarseCtrl"
estimates store b5
estimates use "${tempdir}/DD_Variety_Coarse"
estimates store b6
estimates use "${tempdir}/DD_Prices_MLCtrl"
estimates store b7
estimates use "${tempdir}/DD_Variety_ML"
estimates store b8
estimates dir

	
*Table For Paper 
esttab b4 b6 b8 b1 b2 b3 b5 b7 ///
  using "${tabsdir}/TableE2.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(AutonomyY2 BothY2  ) ///
  order(AutonomyY2 BothY2) ///
  nostar ///
  mgroups("Variety" "Unit Price" , ///
	pattern(1 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(AutonomyY2 "Autonomy $\times$ Year 2" ///
	BothY2 "Both $\times$ Year 2", ///
		elist(AutonomyY2 \addlinespace ///
			BothY2 \addlinespace )) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll pAutBot N, ///
    labels("Item Variety Measure" "p(All = 0)" "p(Autonomy = Both)" /// 
	 "Observations") ///
	fmt(3 3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
  
esttab b4 b6 b8 b1 b2 b3 b5 b7, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(AutonomyY2 BothY2  ) ///
  order(AutonomyY2 BothY2) ///
  nostar ///
  mgroups("Variety" "Unit Price" , ///
	pattern(1 0 0 1 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(AutonomyY2 "Autonomy $\times$ Year 2" ///
	BothY2 "Both $\times$ Year 2", ///
		elist(AutonomyY2 \addlinespace ///
			BothY2 \addlinespace )) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll pAutBot N, ///
    labels("Item Variety Measure" "p(All = 0)" "p(Autonomy = Both)" /// 
	 "Observations") ///
	fmt(3 3 3 %8.0fc)) 
	
