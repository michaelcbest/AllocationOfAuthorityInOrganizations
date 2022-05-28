
*4. Build the tables

estimates clear
**Load all the estimates
foreach y in "1415" "1516" {
	estimates use "${tempdir}/TableE4_Universe`y'_none"
	estimates store regUniverse`y'_none
	estimates use "${tempdir}/TableE4_Universe`y'_attr"
	estimates store regUniverse`y'_attr
	estimates use "${tempdir}/TableE4_Universe`y'_scal"
	estimates store regUniverse`y'_scal
	estimates use "${tempdir}/TableE4_Universe`y'_cors"
	estimates store regUniverse`y'_cors
}

estimates use "${tempdir}/TableE4_Universe_none"
estimates store regUniverse_none
estimates use "${tempdir}/TableE4_Universe_attr"
estimates store regUniverse_attr
estimates use "${tempdir}/TableE4_Universe_scal"
estimates store regUniverse_scal
estimates use "${tempdir}/TableE4_Universe_cors"
estimates store regUniverse_cors

	
**Universe Budget Shares
esttab regUniverse1415_none regUniverse1415_attr regUniverse1415_scal regUniverse1415_cors ///
	regUniverse1516_none regUniverse1516_attr regUniverse1516_scal regUniverse1516_cors ///
	regUniverse_none regUniverse_attr regUniverse_scal regUniverse_cors ///
  using "${tabsdir}/TableE4.tex", ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Autonomy0 Both0 IAutBUniverse1415 IAutBUniverse1516 IIncBUniverse1415 ///
	IIncBUniverse1516 IBotBUniverse1415 IBotBUniverse1516) ///
  nostar ///
  order(Autonomy0 Incentives0 Both0 IAutBUniverse1415 IIncBUniverse1415 IBotBUniverse1415 ///
	IAutBUniverse1516 IIncBUniverse1516 IBotBUniverse1516) ///
  varlabels(Incentives0 "Incentives" ///
	Autonomy0 "Autonomy" ///
	Both0 "Both" ///
	IAutBUniverse1415 "Autonomy $\times$ Generic Budget Share 14--15" ///
	IIncBUniverse1415 "Incentives $\times$ Generic Budget Share 14--15" ///
	IBotBUniverse1415 "Both $\times$ Generic Budget Share 14--15" ///
	IAutBUniverse1516 "Autonomy $\times$ Generic Budget Share 15--16" ///
	IIncBUniverse1516 "Incentives $\times$ Generic Budget Share 15--16" ///
	IBotBUniverse1516 "Both $\times$ Generic Budget Share 15--16", ///
		elist(Autonomy0 \addlinespace ///
		Incentives0 \addlinespace ///
		Both0 \addlinespace ///
		IAutBUniverse1415 \addlinespace ///
		IIncBUniverse1415 \addlinespace ///
		IBotBUniverse1415 \addlinespace ///
		IAutBUniverse1516 \addlinespace ///
		IIncBUniverse1516 \addlinespace)) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All Interactions = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) ///
  booktabs ///
  replace ///
  varwidth(21)
  

esttab regUniverse1415_none regUniverse1415_attr regUniverse1415_scal regUniverse1415_cors ///
	regUniverse1516_none regUniverse1516_attr regUniverse1516_scal regUniverse1516_cors ///
	regUniverse_none regUniverse_attr regUniverse_scal regUniverse_cors, ///
  cells(b(nostar fmt(3)) se(par fmt(3)) pRI(par([ ]) fmt(3))) ///
  keep(Incentives0 Autonomy0 Both0 IAutBUniverse1415 IAutBUniverse1516 IIncBUniverse1415 ///
	IIncBUniverse1516 IBotBUniverse1415 IBotBUniverse1516) ///
  nostar ///
  order(Autonomy0 Incentives0 Both0 IAutBUniverse1415 IIncBUniverse1415 IBotBUniverse1415 ///
	IAutBUniverse1516 IIncBUniverse1516 IBotBUniverse1516) ///
  varlabels(Incentives0 "Incentives" ///
	Autonomy0 "Autonomy" ///
	Both0 "Both" ///
	IAutBUniverse1415 "Autonomy $\times$ Generic Budget Share 14--15" ///
	IIncBUniverse1415 "Incentives $\times$ Generic Budget Share 14--15" ///
	IBotBUniverse1415 "Both $\times$ Generic Budget Share 14--15" ///
	IAutBUniverse1516 "Autonomy $\times$ Generic Budget Share 15--16" ///
	IIncBUniverse1516 "Incentives $\times$ Generic Budget Share 15--16" ///
	IBotBUniverse1516 "Both $\times$ Generic Budget Share 15--16", ///
		elist(Autonomy0 \addlinespace ///
		Incentives0 \addlinespace ///
		Both0 \addlinespace ///
		IAutBUniverse1415 \addlinespace ///
		IIncBUniverse1415 \addlinespace ///
		IBotBUniverse1415 \addlinespace ///
		IAutBUniverse1516 \addlinespace ///
		IIncBUniverse1516 \addlinespace)) ///
  collabels(none) ///
  mlabels(none) ///
  stats(itemctrl pAll N, ///
    labels("Item Variety Control" "p(All Interactions = 0)" "Observations") ///
	fmt(3 3 %8.0fc)) 
