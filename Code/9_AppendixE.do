* 1. Order sizes are unaffected (table E1)
do "${code}/9-1-1_QuantityRegs.do"
do "${code}/9-1-2_TableE1.do"

* 2. Dynamic treatment effects (table E3)
do "${code}/9-2-1_DynamicTERegs.do"
do "${code}/9-2-2_TableE3.do"

* 3. Heterogeneity by Budget Share of Generic Goods (table E4)
do "${code}/9-3-1_MakeBudgetShares.do"
do "${code}/9-3-2_LinearInteractions.do"
do "${code}/9-3-3_TableE4.do"

* 4. Treatment Effects on Demand for Goods (Table E.5)
do "${code}/9-4_TableE5.do"

* 5. Treatment effects on the timing of deliveries and expenditures (Figure E.1)
do "${code}/9-5_FigureE1.do"
