*Load the estimates
estimates clear
estimates use "${tempdir}/TableE3_ScalarVariety_eq1"
estimates store b1
estimates use "${tempdir}/TableE3_ScalarVariety_eq2"
estimates store b2
estimates use "${tempdir}/TableE3_ScalarVariety_eq3"
estimates store b3
estimates use "${tempdir}/TableE3_CoarseVariety_eq1"
estimates store b4
estimates use "${tempdir}/TableE3_CoarseVariety_eq2"
estimates store b5
estimates use "${tempdir}/TableE3_CoarseVariety_eq3"
estimates store b6
estimates use "${tempdir}/TableE3_PriceNoCtrl_eq1"
estimates store b7
estimates use "${tempdir}/TableE3_PriceNoCtrl_eq2"
estimates store b8
estimates use "${tempdir}/TableE3_PriceNoCtrl_eq3"
estimates store b9
estimates use "${tempdir}/TableE3_PriceAttribCtrl_eq1"
estimates store b10
estimates use "${tempdir}/TableE3_PriceAttribCtrl_eq2"
estimates store b11
estimates use "${tempdir}/TableE3_PriceAttribCtrl_eq3"
estimates store b12
estimates use "${tempdir}/TableE3_PriceScalarCtrl_eq1"
estimates store b13
estimates use "${tempdir}/TableE3_PriceScalarCtrl_eq2"
estimates store b14
estimates use "${tempdir}/TableE3_PriceScalarCtrl_eq3"
estimates store b15
estimates use "${tempdir}/TableE3_PriceCoarseCtrl_eq1"
estimates store b16
estimates use "${tempdir}/TableE3_PriceCoarseCtrl_eq2"
estimates store b17
estimates use "${tempdir}/TableE3_PriceCoarseCtrl_eq3"
estimates store b18


*Table
esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18 ///
  using "${tabsdir}/TableE3.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ) ///
  order(Rules0 Incentives0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Variety" "Unit Price", ///
	pattern(1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 ) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both" ///
	AutTime "Autonomy $ \times $ Time" ///
	IncTime "Incentives $ \times $ Time" ///
	BotTime "Both $ \times $ Times" ///
	AutOrder "Autonomy $ \times $ Order" ///
	IncOrder "Incentives $ \times $ Order" ///
	BotOrder "Both $ \times $ Order", ///
		elist(Incentives0 \addlinespace ///
			Rules0 \addlinespace ///
			Both0 \addlinespace ///
			AutTime \addlinespace ///
			IncTime \addlinespace ///
			BotTime \addlinespace ///
			AutOrder \addlinespace ///
			IncOrder \addlinespace)) ///
  collabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  fragment ///
  varwidth(21)
 
*Show the table on screen
  esttab b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 b17 b18, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Rules0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ) ///
  order(Rules0 Incentives0 Both0 AutTime IncTime BotTime AutOrder IncOrder BotOrder ) ///
  nostar ///
  mlabels(none) ///
  mgroups("Variety" "Unit Price", ///
	pattern(1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 ) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span ///
	erepeat(\cmidrule(lr){@span})) ///
  varlabels(Incentives0 "Incentives" ///
	Rules0 "Autonomy" ///
	Both0 "Both" ///
	AutTime "Autonomy $ \times $ Time" ///
	IncTime "Incentives $ \times $ Time" ///
	BotTime "Both $ \times $ Times" ///
	AutOrder "Autonomy $ \times $ Order" ///
	IncOrder "Incentives $ \times $ Order" ///
	BotOrder "Both $ \times $ Order", ///
		elist(Incentives0 \addlinespace ///
			Rules0 \addlinespace ///
			Both0 \addlinespace ///
			AutTime \addlinespace ///
			IncTime \addlinespace ///
			BotTime \addlinespace ///
			AutOrder \addlinespace ///
			IncOrder \addlinespace)) ///
  collabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  varwidth(21)
  
