***********************************************************************
* 			LCR India: clean patent data sets
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
* 	1: clean firmpatent_inter (list with all scraped patents)
*																	 																      *
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
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
sort company_name abstract
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
		


save "${lcr_intermediate}/solarpatents", replace
