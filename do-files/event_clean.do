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
drop company_name companyname bidder
rename company_name2 company_name

***********************************************************************
* 	PART 3: order
***********************************************************************
order solarpatent, a(year)
order won_no_lcr won_lcr total_auctions_no_lcr total_auctions_lcr, a(solarpatent)
order part_jnnsm_1, a(solarpatent)

***********************************************************************
* 	PART 4: extend the panel for stable variables
***********************************************************************
local stable_vars "lob ultimateparent subsidiary indian international soe_india manufacturer manufacturer_solar energy_focus part_jnnsm_1 webaddress city subsidiary state founded"
foreach var of local stable_vars {
	egen `var'1 = min(`var'), by(company_name)
	drop `var'
	rename `var'1 `var'
}

***********************************************************************
* 	PART 5: create age variable
***********************************************************************
drop age_at_bid

gen age = year - founded, a(year)


***********************************************************************
* 	PART 6: panel nsm participation variable
***********************************************************************
bysort company_name year: gen nsm_1 = (part_jnnsm_1 == 1) if year == 2011 | year == 2012, a(part_jnnsm_1)
label var nsm_1 "=1 if part. in nsm-1 in 2011 or 2012"

***********************************************************************
* 	PART 6: create treatment dummies
***********************************************************************
format %-9.0g total_auctions*
*** I: considering the whole NSM period 
* create lcr won annual indicator
bysort company_name year: gen d_lcrwon_nsm_panel = (nsm_1 == 1 | won_lcr > 0 & won_lcr<.), a(solarpatent)
lab var d_lcrwon_nsm_panel "=1 in year firm won LCR auction in NSM 1 or 2"

* create lcr part annual indicator
bysort company_name year: gen d_lcrpart_nsm_panel = (nsm_1 == 1 | total_auctions_lcr > 0 & total_auctions_lcr<.), a(solarpatent)
lab var d_lcrpart_nsm_panel "=1 in year firm part. in LCR auction in NSM 1 or 2"

* create ever participated in LCR auction
egen max_lcr_auction = max(total_auctions_lcr), by(company_name)
order max_lcr_auction, a(total_auctions_lcr)
bysort company_name: gen lcr_participant = (max_lcr_auction > 0) if max_lcr_auction != ., b(total_auctions_lcr)
drop max_lcr_auction

* create ever won a LCR auction (23 firms)
egen max_lcr_won = max(won_lcr), by(company_name)
order max_lcr_won, a(won_lcr)
bysort company_name: gen lcr_winner = (max_lcr_won > 0) if max_lcr_won != ., b(won_lcr)
drop max_lcr_won


* create ever won an open auction (56 firms)
egen max_open_won = max(won_no_lcr), by(company_name)
order max_open_won, a(won_no_lcr)
bysort company_name: gen open_winner = (max_open_won > 0) if max_open_won != ., b(won_no_lcr)
drop max_open_won


	* A: Treated: LCR win. Counterfactual: open auction winner (only).
		* treated vs. never treated
bysort company_name: gen d_winner = (lcr_winner == 1), a(won_lcr)
bysort company_name: replace d_winner = . if open_winner == 0 & lcr_participant == 0 // put open auction participants missing (never won)
bysort company_name: replace d_winner = . if lcr_winner == 0 & lcr_participant == 1 // put lcr auction participants missing (never won)
			* reduces sample by 40%.
			* 23 firms in treatment, 45 in control.
		
	* B: Treated: LCR participant. Counterfactual: open auction participant (only).
		* Variable exist --> lcr_participant
		

*** cohort dummy g
			* NSM batch I: 2011-2012
			* LCR batch II: 2013-2017

* idea
	* cohort 1: batch 1
	* cohort 2: 2013


*** considering only the counterfactual period




***********************************************************************
* 	PART: save dataset	  						
***********************************************************************
save "${lcr_final}/event_study_final", replace
erase "${lcr_final}/event_study_raw"