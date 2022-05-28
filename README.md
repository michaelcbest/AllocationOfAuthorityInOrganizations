# AllocationOfAuthorityInOrganizations

This repository contains the replication package for Bandiera, Best, Khan &amp; Prat, "The Allocation of Authority in Organizations: A Field Experiment with Bureaucrats", _The Quarterly Journal of Economics_, Vol 136, Issue 4, November 2021, pages 2195-2242.
[https://doi.org/10.1093/qje/qjab029](https://doi.org/10.1093/qje/qjab029)

The data (and this code) can be downloaded at [https://doi.org/10.7910/DVN/OJQWO2](https://doi.org/10.7910/DVN/OJQWO2)

To replicate the results, make sure you have downloaded all the data and code files. Then open Code/_master.do and make sure the macros in lines 23-29 are pointing to the downloaded folders.

Note that the code runs 1,000 randomization inference replications for many parts of the analysis. This can take a long time. To do fewer replications, set the macro `RIreps` on line 34 to s amaller number.
