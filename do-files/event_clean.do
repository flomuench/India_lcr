***********************************************************************
* 			lcr India paper: clean panel database			
***********************************************************************														  
*	PURPOSE: clean panel dataset			  								  
*				  
*																	  
*	OUTLINE:														  
*	Author: Florian, Fabian  														  
*	ID variable: company_name, year	  									  
*	Requires:	event_study_raw
*	Creates:	event_study_final

***********************************************************************
* 	PART 1: import panel data set					
***********************************************************************
use "${lcr_final}/event_study_raw", clear


***********************************************************************
* 	PART 2: drop unnecessary variables
***********************************************************************
drop company_name companyname bidder _merge
rename company_name2 company_name


***********************************************************************
* 	PART 2: extend the panel for stable variables
***********************************************************************
local stable_vars "lob ultimateparent subsidiary indian international soe_india manufacturer manufacturer_solar energy_focus part_jnnsm_1 webaddress city subsidiary state founded"
foreach var of local stable_vars {
	egen `var'1 = min(`var'), by(company_name)
	drop `var'
	rename `var'1 `var'
}

***********************************************************************
* 	PART 3: create age variable
***********************************************************************
drop age_at_bid

gen age = year - founded, a(year)

***********************************************************************
* 	PART 4: create g - treatment cohort dummy
***********************************************************************


***********************************************************************
* 	PART: save dataset	  						
***********************************************************************
save "${lcr_final}/event_study_final", replace
erase "${lcr_final}/event_study_raw"