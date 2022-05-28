
use "${usedata}/OfficeMonth.dta", clear

/*AG type interaction */

gen Incentives0 = (Treatment == 1)
gen Autonomy0 = (Treatment == 2)
gen Both0 = (Treatment == 3)

** Bad AG. Our measure
gen x=agJune*100
gen agJuneC=int(x)
levelsof agJuneC, local (lev)
foreach j of local lev {
gen agD_l`j'=agJune>(`j'/100)&agJune!=.
}

gen InteractIncentives = Incentives0 * agD_l48
gen InteractAutonomy = Autonomy0 * agD_l22
gen InteractBoth = Both0 * agD_l22

mvreg AmountCF622 AmountCF921 AmountCF927 AmountCF929 AmountCF936 AmountCF938 AmountCF943 ///
	AmountCF989 AmountCF991 AmountCF992 AmountCF994 AmountCF998 AmountCF999 AmountCF1001 ///
	AmountCF1009 AmountCF1030 AmountCF1032 AmountCF1360 AmountCF2762 AmountCF3346 ///
	AmountCF3507 AmountCF3906 AmountCF4834 AmountCF5107 AmountCF20433 = ///
	Incentives0 Autonomy0 Both0 InteractIncentives InteractAutonomy InteractBoth ///
	i.strata i.month
	
capture		file close myfile
file 		open myfile using "${tabsdir}/TableF5.tex", write replace

file		write myfile "\begin{tabular}{lccccccccc}" _n
file		write myfile "\toprule" _n
file		write myfile "\multirow{2}{*}{\textbf{Item}} & \multicolumn{3}{c}{\textbf{Linear Term}} & & \multicolumn{3}{c}{\textbf{Bad AG Interaction}} & \textbf{Linear} & \textbf{Interactions} \\ " _n
file		write myfile " & \textbf{Autonomy} & \textbf{Incentives} & \textbf{Both} & & \textbf{Autonomy} & \textbf{Incentives} & \textbf{Both} & \textbf{All = 0} & \textbf{All = 0} \\ " _n
file		write myfile "\midrule" _n

levelsof ItemName
forvalues i = 1/25 {
	sort ItemNumber
	local itemname = ItemName[`i']
	local n = ItemIDDict[`i']
	file write myfile " \multirow{2}{*}{`itemname'} "
	*Linear Terms
	file write myfile " & " %6.1f (_b[AmountCF`n':Autonomy0])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Autonomy0]/_se[AmountCF`n':Autonomy0]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Autonomy0]/_se[AmountCF`n':Autonomy0]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Autonomy0]/_se[AmountCF`n':Autonomy0]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	file write myfile " & " %6.1f (_b[AmountCF`n':Incentives0])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Incentives0]/_se[AmountCF`n':Incentives0]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Incentives0]/_se[AmountCF`n':Incentives0]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Incentives0]/_se[AmountCF`n':Incentives0]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	file write myfile " & " %6.1f (_b[AmountCF`n':Both0])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Both0]/_se[AmountCF`n':Both0]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Both0]/_se[AmountCF`n':Both0]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':Both0]/_se[AmountCF`n':Both0]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	file write myfile " & " 
	*Interactions
	file write myfile " & " %6.1f (_b[AmountCF`n':InteractAutonomy])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractAutonomy]/_se[AmountCF`n':InteractAutonomy]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractAutonomy]/_se[AmountCF`n':InteractAutonomy]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractAutonomy]/_se[AmountCF`n':InteractAutonomy]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	file write myfile " & " %6.1f (_b[AmountCF`n':InteractIncentives])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractIncentives]/_se[AmountCF`n':InteractIncentives]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractIncentives]/_se[AmountCF`n':InteractIncentives]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractIncentives]/_se[AmountCF`n':InteractIncentives]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	file write myfile " & " %6.1f (_b[AmountCF`n':InteractBoth])
	if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractBoth]/_se[AmountCF`n':InteractBoth]))) < 0.01 {
		file write myfile "$^{***}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractBoth]/_se[AmountCF`n':InteractBoth]))) < 0.05 {
		file write myfile "$^{**}$"
	}
	else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':InteractBoth]/_se[AmountCF`n':InteractBoth]))) < 0.1 {
		file write myfile "$^{*}$"
	}
	*F tests
	test [AmountCF`n']Incentives0 [AmountCF`n']Autonomy0 [AmountCF`n']Both0
	file write myfile " & " %6.2f (`r(F)')
	local FpLinear = `r(p)'
	test [AmountCF`n']InteractIncentives [AmountCF`n']InteractAutonomy [AmountCF`n']InteractBoth
	file write myfile " & " %6.2f (`r(F)')
	local FpInteract = `r(p)'
	file write myfile " \\ " _n
	*Linear Terms
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':Autonomy0]) "\right) $ "
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':Incentives0]) "\right) $ "
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':Both0]) "\right) $ & "
	*Interactions
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':InteractAutonomy]) "\right) $ "
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':InteractIncentives]) "\right) $ "
	file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':InteractBoth]) "\right) $ "
	*F tests
	file write myfile " & $ \left[" %6.3f (`FpLinear') "\right] $ "
	file write myfile " & $ \left[" %6.3f (`FpInteract') "\right] $ "
	file write myfile " \\ [0.25em] " _n
}
file 		write myfile " \midrule " _n
file 		write myfile " \multirow{2}{*}{Joint F-Test} "
test Autonomy0
file write myfile " & " %6.2f (`r(F)')
local FpAutonomy = `r(p)'
test Incentives0
file write myfile " & " %6.2f (`r(F)')
local FpIncentives = `r(p)'
test Both0
file write myfile " & " %6.2f (`r(F)')
local FpBoth = `r(p)'
test InteractAutonomy
file write myfile " & & " %6.2f (`r(F)')
local FpInteractAutonomy = `r(p)'
test InteractIncentives
file write myfile " & " %6.2f (`r(F)')
local FpInteractIncentives = `r(p)'
test InteractBoth
file write myfile " & " %6.2f (`r(F)')
local FpInteractBoth = `r(p)'
test Autonomy0 Incentives0 Both0
file write myfile " & " %6.2f (`r(F)')
local FpLinear = `r(p)'
test InteractAutonomy InteractIncentives InteractBoth
file write myfile " & " %6.2f (`r(F)')
local FpInteract = `r(p)'
file write myfile " \\ " _n
file write myfile " & $ \left[" %6.3f (`FpAutonomy') " \right] $ "
file write myfile " & $ \left[" %6.3f (`FpIncentives') " \right] $ "
file write myfile " & $ \left[" %6.3f (`FpBoth') " \right] $ "
file write myfile " & & $ \left[" %6.3f (`FpInteractAutonomy') " \right] $ "
file write myfile " & $ \left[" %6.3f (`FpInteractIncentives') " \right] $ "
file write myfile " & $ \left[" %6.3f (`FpInteractBoth') " \right] $ "
file write myfile " & $ \left[" %6.3f (`FpLinear') "\right] $ "
file write myfile " & $ \left[" %6.3f (`FpInteract') "\right] $ \\ [0.25em]"  _n
file		write myfile " \bottomrule " _n
file		write myfile " \end{tabular}" _n
file		close myfile

