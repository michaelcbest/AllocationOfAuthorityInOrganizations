
/*Prepare Analysis Data*/
tempfile analysis
use "${usedata}/UsingData.dta", clear
keep RequestID DeliveryID time OfficeID
sort OfficeID time
isid RequestID DeliveryID
save `analysis'

/*Prepare User Tenures*/
**Note. Stacking the two datasets since they're not identical.
tempfile usertenure
use "${rawdata}/UserTenures.dta", clear
drop if Role != 2
keep UserID OfficeID JoiningDate TransferDate
format %td JoiningDate TransferDate
duplicates drop
gen Source = "UserTenure"
save `usertenure'

tempfile allusers
use "${rawdata}/UserTransferHistory.dta", clear
keep UserId OfficeId JoiningDate TransferDate
gen Join = dofc(JoiningDate)
format %td Join
drop JoiningDate
ren Join JoiningDate
gen Trans = dofc(TransferDate)
format %td Trans
drop TransferDate
ren Trans TransferDate
ren UserId UserID
drop if OfficeId == .
ren OfficeId OfficeID
duplicates drop
append using `usertenure'
duplicates drop
replace JoiningDate = 19840 if JoiningDate == .
replace TransferDate = 20840 if TransferDate == .
replace Source = "UserTransferHistory" if Source == ""
save `allusers'

/*Range Join to bring UserIDs into the using data*/
rangejoin time JoiningDate TransferDate using `analysis', by(OfficeID) 
duplicates 	drop

drop 		if RequestID == . | DeliveryID == . 
duplicates tag RequestID DeliveryID, gen(dup)
gen transfer = (Source == "UserTransferHistory")
bysort RequestID DeliveryID: egen maxtransfer = max(transfer)
bysort RequestID DeliveryID: egen mintransfer = min(transfer)
drop if dup > 0 & maxtransfer == 1 & mintransfer == 0 & Source == "UserTransferHistory"
drop dup transfer maxtransfer mintransfer

/* Deal with Duplicates (somewhat arbitrarily) */
duplicates drop RequestID DeliveryID UserID, force
//In the 58 remaining duplicates, keep the guy who has been in charge the longest
gen tenure = TransferDate - JoiningDate
bys RequestID DeliveryID: egen longest = max(tenure)
keep if tenure == longest

isid RequestID DeliveryID
keep RequestID DeliveryID UserID
save "${usedata}/WhoIsDDO.dta", replace
