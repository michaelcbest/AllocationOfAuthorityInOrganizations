*===============================================================================*
*																				*
*	THIS DO FILE PERFORMS THE BASELINE ANALYSIS IN TABLES 2 AND E.2				*
*																				*
*===============================================================================*

use "${usedata}/UsingData.dta", clear

* 1. Run the DD Regressions (Table E.2)
*do "${code}/2-1_DDRegs.do"

tab Year2
drop if Year2 == 0
tab Year2

* 2. Run the Year-2 Regressions (Table 2)
do "${code}/2-2_Y2Regs.do"

* 3. Build Table E.2
do "${code}/2-3_TableE2.do"

* 4. Build Table 2 
do "${code}/2-4_Table2.do"
