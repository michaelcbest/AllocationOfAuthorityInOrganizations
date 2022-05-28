* Diff in diff (table F1)
do "${code}/4-1_TableF1.do"

* semi parametric
do "${code}/4-2-1_DataBuild.do"
global rhs = "${rhsbasic}" + "ScalarItemType "
global label = "Scalar"
do "${code}/4-2-2_Regs.do"
do "${code}/4-2-3_Figure5.do"

* whos a bad AG dd
do "${code}/4-3_FigureF1.do"

* robustness to alternative measures of AG type*
do "${code}/4-4_TableF2.do"

* robustness to confounders
do "${code}/4-5_TableF3.do"

* no effects on variety (table F4)
do "${code}/4-6_TableF4.do"

* no effects on quantity (table F5)
do "${code}/4-7_TableF5.do"


