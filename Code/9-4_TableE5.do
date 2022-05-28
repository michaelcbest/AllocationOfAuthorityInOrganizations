
use "${usedata}/OfficeMonth.dta", clear

*3. No interactions, monthly

mvreg AmountCF622 AmountCF921 AmountCF927 AmountCF929 AmountCF936 AmountCF938 AmountCF943 ///
	AmountCF989 AmountCF991 AmountCF992 AmountCF994 AmountCF998 AmountCF999 AmountCF1001 ///
	AmountCF1009 AmountCF1030 AmountCF1032 AmountCF1360 AmountCF2762 AmountCF3346 ///
	AmountCF3507 AmountCF3906 AmountCF4834 AmountCF5107 AmountCF20433 = ib4.Treatment i.strata i.month
	
capture		file close myfile
file 		open myfile using "${tabsdir}/TableE5.tex", write replace

file		write myfile "\begin{tabular}{lcccc}" _n
file		write myfile "\toprule" _n
file		write myfile "\multirow{2}{*}{\textbf{Item}} & \multicolumn{3}{c}{\textbf{Treatment Effect}} & \textbf{Joint Test} \\ " _n
file		write myfile " & \textbf{Autonomy} & \textbf{Incentives} & \textbf{Both} & \textbf{All = 0} \\ " _n
file		write myfile "\midrule" _n

levelsof ItemName
forvalues i = 1/25 {
	sort ItemNumber
	local itemname = ItemName[`i']
	local n = ItemIDDict[`i']
	file write myfile " \multirow{2}{*}{`itemname'} "
	foreach t in 2 1 3 {
		file write myfile " & " %6.1f (_b[AmountCF`n':`t'.Treatment])
		if (2 * ttail(e(df_r),abs(_b[AmountCF`n':`t'.Treatment]/_se[AmountCF`n':`t'.Treatment]))) < 0.01 {
			file write myfile "$^{***}$"
		}
		else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':`t'.Treatment]/_se[AmountCF`n':`t'.Treatment]))) < 0.05 {
			file write myfile "$^{**}$"
		}
		else if (2 * ttail(e(df_r),abs(_b[AmountCF`n':`t'.Treatment]/_se[AmountCF`n':`t'.Treatment]))) < 0.1 {
			file write myfile "$^{*}$"
		}
	}
	test [AmountCF`n']1.Treatment [AmountCF`n']2.Treatment [AmountCF`n']3.Treatment
	file write myfile " & " %6.2f (`r(F)')
	local Fp = `r(p)'
	file write myfile " \\ " _n
	foreach t in 2 1 3 {
		file write myfile " & $ \left(" %6.2f (_se[AmountCF`n':`t'.Treatment]) "\right) $ "
	}
	file write myfile " & $ \left[" %6.3f (`Fp') "\right] $ "
	file write myfile " \\ [0.25em] " _n
}
file 		write myfile " \midrule " _n
file 		write myfile " \multirow{2}{*}{Joint F-Test} "
foreach t in 2 1 3 {
	test `t'.Treatment
	file write myfile " & " %6.2f (`r(F)')
	local Fp`t' = `r(p)'
}
test 2.Treatment 1.Treatment 3.Treatment
file write myfile " & " %6.2f (`r(F)')
local Fp = `r(p)'
file write myfile " \\ " _n
foreach t in 2 1 3 {
	file write myfile " & $ \left[" %6.3f (`Fp`t'') " \right] $ "
}
file write myfile " & $ \left[" %6.3f (`Fp') "\right] $ \\ [0.25em]" _n
file		write myfile " \bottomrule " _n
file		write myfile " \end{tabular}" _n
file		close myfile
