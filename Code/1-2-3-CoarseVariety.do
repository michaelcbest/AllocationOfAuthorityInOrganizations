
foreach var of varlist Unit_It* {

	gen New`var' = `var'
	replace New`var' = . if New`var' == 0
	replace New`var' = . if New`var' == 1

}

*STEP 1 CODE PACK SIZE, GENERATE sizeL=1 for larger sizes defined as >median or as close as possible to that
gen NewUnit_It622=1 if NewItemID==622
gen NewUnit_It998=1 if NewItemID==998
gen NewUnit_It1001=1 if NewItemID==1001
gen NewUnit_It1032=1 if NewItemID==1032
gen NewUnit_It3346=1 if NewItemID==3346
gen NewUnit_It20433=1 if NewItemID==20433

gen Unit=.
levelsof NewItemID, local(levels)
foreach l of local levels{
replace Unit= NewUnit_It`l' if NewItemID==`l'
}
gen sizeL=0
replace sizeL=1 if  Unit>2&(NewItemID==938|NewItemID==936|NewItemID==989|NewItemID==4834|NewItemID==5107)
replace sizeL=1 if  Unit==4&(NewItemID==999|NewItemID==929|NewItemID==1360)
replace sizeL=1 if  Unit>=12 & NewItemID==1009
replace sizeL=1 if  Unit>=100 & NewItemID==991

*STEP 2 "quality" dummy = 1 for all options that lead to higher prices- brand is never significant once everything else is controlled for
gen qual=0
replace qual=1 if  (TYPE_OF_CALCULATOR_It1001==4|TYPE_OF_CALCULATOR_It1001==6)
replace qual=1  if (SIZE_It1030==4|SIZE_It1030==5)
replace qual=1  if (COUNTRY_OF_ORIGIN_It943==4|MATERIAL_It943==3|TYPE_It943==3|TYPE_It943==7|TYPE_It943==8)
replace qual=1  if ACID_CLEANERTIZAAB_It5107==4
replace qual=1  if CLIP_A_It1009==3|COVER_MATERIAL_It1009==3|CUSTOMIZED_PRINTING_It1009==6|FILE_TYPE_It1009==3
replace qual=1  if MATERIAL_It20433==6|FRAME_TYPE_It20433==3|NUMBER_OF_RINGS_It20433==6|NUMBER_OF_COLORS_It20433==4|[AREA_It20433>21&AREA_It20433<999]
replace qual=1  if SIZE_It998==3|SIZE_It998==4
replace qual=1  if DOUBLE_SIDED_It1032==5|ON_GENERATOR_It1032==5|SIZE_It1032==3|WITH_BINDING_It1032==4|WITH_BINDING_It1032==5
replace qual=1  if REFILL_OR_NEW_CARTRIDGE_It622==5
replace qual=1  if (AREA_It991>55&AREA_It991<999)|MATERIAL_It991==8
replace qual=1  if	WATT_It3906==7|WATT_It3906==9|WATT_It3906==10|WATT_It3906==13|TYPE_OF_BULB_It3906==3|TYPE_OF_BULB_It3906==4|TYPE_OF_BULB_It3906==7|TYPE_OF_BULB_It3906==9
replace qual=1  if TYPE_It1360>5&TYPE_It1360<9
replace qual=1  if (PAGE_WEIGHT_GSM_It994>70&PAGE_WEIGHT_GSM_It994<999)|(NUMBER_OF_PAGES_It994>100&NUMBER_OF_PAGES_It994<999)|CUSTOMIZED_PRINTING_It994==4
replace qual=1  if WEIGHT_PER_SHEET_It992==13|WEIGHT_PER_SHEET_It992==14|SIZE_It992==5|SIZE_It992==7|SIZE_It992==8
replace qual=1  if (PEN_TYPE_It989>3&PEN_TYPE_It989<=10)|(THICKNESS_MM_It989>.7&THICKNESS_MM_It989<=5)|(COLOR_It989==3|COLOR_It989==4)
replace qual=1 if TYPE_OF_TOWEL_It927==3
replace qual=1 if (NAME_OF_NEWSPAPER_It3346>5&NAME_OF_NEWSPAPER_It3346<8)|NAME_OF_NEWSPAPER_It3346==12|NAME_OF_NEWSPAPER_It3346==13|NAME_OF_NEWSPAPER_It3346==22|NAME_OF_NEWSPAPER_It3346==24|NAME_OF_NEWSPAPER_It3346==25

egen NewItemIDQ=group(NewItemID qual)
