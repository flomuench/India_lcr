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
order won_no_lcr won_lcr quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr total_auctions_no_lcr total_auctions_lcr, a(solarpatent)
format %-9.0g won_no_lcr won_lcr quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr total_auctions_no_lcr total_auctions_lcr
order quantity_allocated_mw_lcr, a(won_lcr)
order quantity_allocated_mw_no_lcr, a(won_no_lcr)

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

*** I: considering the whole NSM period: Batch I (2011-2012) + Batch II  (2013-2017)

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
replace d_winner = 0 if d_winner != . & year < 2011
			* reduces sample by 40%.
			* 23 firms in treatment, 45 in control.
		
	* B: Treated: LCR participant. Counterfactual: open auction participant (only).
		* Variable exist --> lcr_participant

		
*** considering only the counterfactual period: Batch II (2013-2017)

		
***********************************************************************
* 	PART 7: create cohort dummies
***********************************************************************
/* 
resource/reference: 
	1:
	2: min 44-45 Sant'Anna presentation: "create a new column with group indicator that is time-invariant" https://www.youtube.com/watch?v=VLviaylakAo
*/

* cohort defined as by first year they enter an lcr auction
gen first_treat1 = ., a(year)
replace first_treat1 = 2011  if d_lcrwon_nsm_panel == 1 & year == 2011							 // 5 firms
replace first_treat1 = 2012  if d_lcrwon_nsm_panel == 1 & year == 2012 & first_treat1[_n-1] == . // no new firms in 2012
replace first_treat1 = 2013  if d_lcrwon_nsm_panel == 1 & year == 2013 & first_treat1[_n-2] == . // 13 firms
replace first_treat1 = 2015  if d_lcrwon_nsm_panel == 1 & year == 2015 & first_treat1[_n-4] == . // 1 firm
replace first_treat1 = 2016  if d_lcrwon_nsm_panel == 1 & year == 2016 & first_treat1[_n-3] == . // 6 firms
replace first_treat1 = 2017  if d_lcrwon_nsm_panel == 1 & year == 2017 & first_treat1 == .		 // 1 firm

egen first_treat0 = min(first_treat1), by(company_name)
order first_treat0, a(first_treat1)
drop first_treat1
rename first_treat0 first_treat1
replace first_treat1 = 0 if first_treat1 == .


* cohort grouped into early, middle, late adopters
gen first_treat2 = ., a(first_treat1)
replace first_treat2 = 2011 if d_lcrwon_nsm_panel == 1 & year == 2011 | d_lcrwon_nsm_panel == 1 & year == 2012
replace first_treat2 = 2013 if d_lcrwon_nsm_panel == 1 & year == 2013 & first_treat2[_n-1] == .
replace first_treat2 = 2015 if d_lcrwon_nsm_panel == 1 & year == 2015 & first_treat2[_n-3] == .
replace first_treat2 = 2015 if d_lcrwon_nsm_panel == 1 & year == 2016 & first_treat2[_n-3] == .
replace first_treat2 = 2015 if d_lcrwon_nsm_panel == 1 & year == 2017 & first_treat2 == .

egen first_treat0 = min(first_treat2), by(company_name)
order first_treat0, a(first_treat2)
drop first_treat2
rename first_treat0 first_treat2
replace first_treat2 = 0 if first_treat2 == .



***********************************************************************
* 	PART 8: create period index time to treat
***********************************************************************
gen ttt_2011 = year - 2010, a(year)
lab var ttt_2011 "time to treatment, base year = 2010"
gen ttt_2013 = year - 2012, a(year)
lab var ttt_2011 "time to treatment, base year = 2012"


***********************************************************************
* 	PART 9: Create pre-treatment controls
***********************************************************************
/* technical note:
	- for revenue, take either year before policy (2010, 2012) or earliest available
	- for employees, we could only find data without time stamp and thus took the latest obs.
	*/

* revenue
	* take year before policy = 2010
egen latest_available_year = min(year) if total_revenue != ., by(company_name)
replace latest_available_year = . if latest_available_year != year
bysort company_name: gen total_revenue_latest_year = total_revenue if latest_available_year != .

forvalues year = 2010(2)2012 {
	bysort company_name year: gen revenue_`year' = total_revenue if year == `year', a(total_revenue)
	* replace with latest available year 
	bysort company_name: replace revenue_`year' = total_revenue_latest_year if latest_available_year != . & revenue_`year' == .
	egen rev_`year' = min(revenue_`year'), by(company_name)
	drop revenue_`year'
	rename rev_`year' revenue_`year'
}

* patents
egen solar_patent_2010 = sum(solarpatent) if year <= 2010, by(company_name)
egen pre_solar_patent_2010 = max(solar_patent_2010), by(company_name)
egen solar_patent_2012 = sum(solarpatent) if year <= 2012, by(company_name)
egen pre_solar_patent_2012 = max(solar_patent_2012), by(company_name)



***********************************************************************
* 	PART: save dataset	  						
***********************************************************************
save "${lcr_final}/event_study_final", replace
erase "${lcr_final}/event_study_raw"