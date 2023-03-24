***********************************************************************
* 			LCR India: clean panel database			
***********************************************************************
*
*	PURPOSE: clean panel dataset			  								  
*				  												  
*	OUTLINE:		
*	1)		import dataset
*	2)		drop unnecessary variables
*	3)		order variables in dataset
*	4)		replace missing patent values with zeros
*	5)		
*												  
*	Author: Florian Münch, Fabian Scheifele									  
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
drop companyname bidder

***********************************************************************
* 	PART 3: order
***********************************************************************
order solarpatent, a(year)
order won_no_lcr won_lcr quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr total_auctions_no_lcr total_auctions_lcr, a(solarpatent)
format %-9.0g won_no_lcr won_lcr quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr total_auctions_no_lcr total_auctions_lcr
order quantity_allocated_mw_lcr, a(won_lcr)
order quantity_allocated_mw_no_lcr, a(won_no_lcr)

order part_jnnsm_1, a(solarpatent)

***********************************************************************
* 	PART 4: replace missing patent values with zeros
***********************************************************************
local patents solarpatent not_solar_patent // modcell_patent
foreach var of local patents {
		replace `var' = 0 if `var' == .
	}

***********************************************************************
* 	PART 5: extend the panel for stable variables
***********************************************************************
local stable_vars "lob ultimateparent subsidiary indian international soe_india manufacturer manufacturer_solar energy_focus part_jnnsm_1 webaddress city subsidiary state founded"
foreach var of local stable_vars {
	egen `var'1 = min(`var'), by(company_name)
	drop `var'
	rename `var'1 `var'
}

***********************************************************************
* 	PART: save dataset	  						
***********************************************************************
save "${lcr_final}/event_study_inter", replace
