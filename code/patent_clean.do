***********************************************************************
* 			LCR India: clean patent data sets
***********************************************************************
*	PURPOSE: clean (e.g. remove duplicates) patent data
*															  
*	OUTLINE:														  
* 	1: clean firmpatent_inter (list with all scraped patents)
*
*
*	Author: Florian Münch, Fabian Scheifele													  
*	ID variable:
* 		company = companyname_correct
*		patent  = applicationnumber (contains duplicates)			  									  
*	Requires:	firmpatent_inter.dta, solarpatents.dta
*	Creates:	firmpatent_inter.dta, solarpatents.dta						  
*																	  
***********************************************************************
* 	PART 1: clean firmpatent_inter (list of all patents)	  						
***********************************************************************
use "${lcr_intermediate}/firmpatent_inter", clear

	* remove patents without year
drop if year_publication == .
drop id inventiontitle
rename companyname_correct company_name

	* search for duplicate patents
			* in terms of abstract (most detailed information we have)
order title abstract, a(applicantname)
format title abstract %-30s
duplicates report abstract /* 8307 unique values but also 141 dups */
duplicates tag abstract if abstract!="", gen(dup_abstract)
sort company_name abstract, stable
*br if dup_abstract > 0

			* in terms of abstract & title
duplicates report abstract title /* only 12 observations, 6 pairs */
duplicates tag abstract title, gen(dup_abstit)
*br if dup_abstit > 0

			* drop those obs that seem to be real duplicates
drop if company_name == "bosch" & title == "COOLING APPLIANCE AND FAN ASSEMBLY THEREFOR" & applicationnumber == "1437/KOL/2010"
drop if company_name == "bosch" & title == "PNEUMATICALLY ADJUSTABLE CONTINUOUSLY VARIABLE TRANSMISSION" & applicationdatedv == "22/12/2017"
drop if company_name == "larsen" & title == "ELECTRONICALLY CONTROLLED UNDER VOLTAGE RELEASE DEVICE USED WITH CIRCUIT BREAKERS" & applicationnumber == "01188/MUM/2003"


	* change format of abstract from strl (not possible for merger) to strmax = str2045
gen len=length(abstract) // Figure out longest length
summ len 
recast str2045 abstract, force  // Convert to a fixed-length string If the longest is less than 2045, use that number instead of 2045; 51 values changed

*recode application numbers that were wrongly formatted from numeric to string
sort applicantname applicationdatedv abstract, stable

replace applicationnumber = "201611021203" in 146 
replace applicationnumber = "201711029640" in 148 
replace applicationnumber = "201631008727" in 674
replace applicationnumber = "201731010190" in 1221
replace applicationnumber = "201631036247" in 1342
replace applicationnumber = "201631018414" in 1688
replace applicationnumber = "201631010691" in 1772
replace applicationnumber = "201631018702" in 2055
replace applicationnumber = "201631018664" in 2056
replace applicationnumber = "201617029992" in 3076
replace applicationnumber = "201617028179" in 4191
replace applicationnumber = "201617028368" in 4320
replace applicationnumber = "201631008053" in 6484
replace applicationnumber = "201821001314" in 6525
replace applicationnumber = "201821012505" in 6661
replace applicationnumber = "201821012449" in 6662

replace applicationnumber = "201721010875" in 7365
replace applicationnumber = "201721011263" in 7617
replace applicationnumber = "201621011432" in 7957
replace applicationnumber = "201821012338" in 8021

replace applicationnumber = "201721000963" in 8086
replace applicationnumber = "201721000974" in 8087
replace applicationnumber = "201621008431" in 8089
replace applicationnumber = "201823024372" in 8105

replace applicationnumber = "201611000087" in 8115
replace applicationnumber = "201711039247" in 8163
replace applicationnumber = "201811007323" in 8164

replace applicationnumber = "201717007777" in 8205
replace applicationnumber = "201644008379" in 8206
replace applicationnumber = "201617042169" in 8209
replace applicationnumber = "201717001511" in 8210

replace applicationnumber = "201617017645" in 8216
replace applicationnumber = "201717002678" in 8217
replace applicationnumber = "201717015140" in 8219


replace applicationnumber = "202027029328" in 8238
replace applicationnumber = "202027017145" in 8263
replace applicationnumber = "201641012912" in 8295
replace applicationnumber = "201621009073" in 8305
replace applicationnumber = "201621009838" in 8315
replace applicationnumber = "201641002970" in 8328
replace applicationnumber = "201641003401" in 8339
replace applicationnumber = "201731038895" in 8405




save "${lcr_intermediate}/firmpatent_inter", replace


***********************************************************************
* 	PART 2: clean solarpatents	  						
***********************************************************************
use "${lcr_intermediate}/solarpatents", clear

	* change format of abstract from strl (not possible for merger) to strmax = str2045
gen len=length(abstract)
summ len 
recast str2045 abstract, force

rename solarpatentx solarpatent
	* a few company names require change for merger
		* bharat heavy electricals
		* bosch
		* larsen toubro 
		* ntpc
		* sunedision
		
format applicationnumber %21s		


save "${lcr_intermediate}/solarpatents", replace
