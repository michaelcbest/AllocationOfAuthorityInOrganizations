*###############################################################################*
*																				*
*		THIS DO FILE MAKES SUMMARY STATISTICS PICTURES AND TABLES				*
*																				*
*		INPUT FILES:															*
*			UsingData.dta														*
*			BERccyear.dta														*
*																				*
*		OUTPUT PICTURES:														*
*			Figure2.pdf															*
*			Figure2.eps															*
*																				*
*		OUTPUT TABLES:															*
*																				*
*###############################################################################*

*===============================*
*	POPS ITEMS FIGURE: Figure 2	*
*===============================*

do "${code}/3-1_Figure2.do"


*===========================*
*	BALANCE TABLE: Table 1	*
*===========================*

do "${code}/3-2_Table1.do"

*=================================*
*	PRICE SCATTERPLOTS: FIGURE A1 *
*=================================*

do "${code}/3-3_FigureA1.do"

