***********************************************************************
* 	LCR India - propensity score matching (psm) variable choice 	  
***********************************************************************
*																	    
*	PURPOSE: identify variables to include in psm
*																	  
*																	  
*	OUTLINE:														  
*	1) set the scene
*	2) iteratively test-up - all observations
*	3) iteratively test-up	- excluding patent_outlier
*	4) iteratively test-up	- only winners
*	5) iteratively test-up	- won lcr vs. did not win lcr, w/o outlier Barat, Sunedison
*	6) explore pre-matching balance in selected variables
*											      
*	Author:  	Florian Münch, Fabian Scheifele						  
*	ID variable: 	company_name		  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear
	
	* set the directory to propensity matching folder
cd "$lcr_psm"

***********************************************************************
* 	PART 2: iteratively test-up - all observations
***********************************************************************
{
	* include variables that simultaneously
		*1: influence LCR participation choice
			* Indian company, Indian city or state as HQ
			* total auction participation
		*2: propensity to file solar patent (outcome)
			* ever patented other patent
			* other, non solar patents
			* size of company: total_revenue & total_employees
			* level of economic complexity of company lob
			* lob
			* subsidiary
cd "$final_figures"
			* (1-3) indian
_eststo indian, r: logit lcr i.indian , vce(robust)
*_eststo india_state, r: logit lcr i.hq_indian_state , vce(robust)
_eststo india_capital, r: logit lcr i.capital , vce(robust)

		* (4) pre patented
_eststo patentor, r: logit lcr i.indian i.patentor , vce(robust)
		
		* (5) pre amount of other patents
_eststo otherprepatents, r: logit lcr i.indian ihs_pre_not_solar_patent , vce(robust)

		* (6) pre solar patents
_eststo solarprepatents, r: logit lcr i.indian pre_solar_patent , vce(robust)

		* (7) total_revenue
_eststo size1, r: logit lcr i.indian ihs_total_revenue, vce(robust)

		* (8) total_employees
_eststo size2, r: logit lcr i.indian log_total_employees , vce(robust)
*_eststo size2, r: logit lcr total_revenue empl , vce(robust)

		* (9) sector
_eststo lob, r: logit lcr i.indian i.sector , vce(robust)

		* (10) sector - electronics
_eststo electronics, r: logit lcr i.indian i.electronics , vce(robust)
	
		* (11) soe
_eststo soe, r: logit lcr i.indian i.electronics i.soe_india , vce(robust)

		* (12) age
_eststo age, r: logit lcr i.indian i.electronics age , vce(robust)

		* (13) energy focus
_eststo energy, r: logit lcr i.indian i.electronics i.energy_focus , vce(robust)

		* (14) manufacturer
_eststo manuf, r: logit lcr i.indian i.manufacturer , vce(robust)
* high correlation manufacturer electronics (0.8)

		* (15) solar manufacturer
_eststo manuf_solar, r: logit lcr i.indian i.manufacturer i.manufacturer_solar , vce(robust)

		* (16) subsidiary
_eststo subsidiary, r: logit lcr i.indian i.manufacturer_solar subsidiary , vce(robust)

		* (17) phase 1 participation NSM
_eststo phase, r: logit lcr i.indian i.manufacturer_solar i.part_jnnsm_1 , vce(robust)

		* (18) all
_eststo all, r: logit lcr i.indian /*i.patentor*/ ihs_pre_not_solar_patent pre_solar_patent ihs_total_revenue log_total_employees sector i.soe_india age i.energy_focus i.manufacturer /*i.manufacturer_solar*/ i.subsidiary i.part_jnnsm_1 , vce(robust)
		* (19) final specification
_eststo final, r: logit lcr i.indian pre_solar_patent ihs_total_revenue log_total_employees i.manufacturer_solar i.part_jnnsm_1, vce(robust)

local regressions indian /*india_state*/ india_capital /*patentor*/ otherprepatents solarprepatents size1 size2 lob electronics soe age energy manuf subsidiary phase all final
esttab `regressions' using variable_choice2_all.csv, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" /*"HQ Indian state"*/ "HQ in Delhi" /*"Pre Patentor"*/ "pre-LCR patents" "pre-LCR solar patents""pre-LCR sales" "pre-LCR employees" "Sector" "Electronics" "SOE" "Age" "Energy focus" "Manufacturer" "Subsidiary" "Phase 1" "All" "Final") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")


* tex table for paper 
local regressions indian /*india_state*/ india_capital /*patentor*/ otherprepatents solarprepatents size1 size2 lob electronics soe age energy manuf subsidiary phase all final
esttab `regressions' using variable_choice_all.tex, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" /*"HQ Indian state"*/ "HQ in Delhi" /*"Pre Patentor"*/ "pre-LCR patents" "pre-LCR solar patents""pre-LCR sales" "pre-LCR employees" "Sector" "Electronics" "SOE" "Age" "Energy focus" "Manufacturer" "Subsidiary" "Phase 1" "All" "Final") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")	
}
***********************************************************************
* 	PART 3: iteratively test-up	- excluding patent_outlier
***********************************************************************
{
			* (1-3) indian
_eststo indian, r: logit lcr i.indian if patent_outlier == 0, vce(robust)
*_eststo india_state, r: logit lcr i.hq_indian_state if patent_outlier == 0, vce(robust)
_eststo india_capital, r: logit lcr i.capital if patent_outlier == 0, vce(robust)

		* (4) pre patented
_eststo patentor, r: logit lcr i.indian i.patentor if patent_outlier == 0, vce(robust)
		
		* (5) pre amount of other patents
_eststo otherprepatents, r: logit lcr i.indian ihs_pre_not_solar_patent if patent_outlier == 0, vce(robust)

		* (6) pre solar patents
_eststo solarprepatents, r: logit lcr i.indian pre_solar_patent if patent_outlier == 0, vce(robust)

		* (7) total_revenue
_eststo size1, r: logit lcr i.indian ihs_total_revenue if patent_outlier == 0, vce(robust)

		* (8) total_employees
_eststo size2, r: logit lcr i.indian log_total_employees if patent_outlier == 0, vce(robust)
*_eststo size2, r: logit lcr total_revenue empl if patent_outlier == 0, vce(robust)

		* (9) sector
_eststo lob, r: logit lcr i.indian i.sector if patent_outlier == 0, vce(robust)

		* (10) sector - electronics
_eststo electronics, r: logit lcr i.indian i.electronics if patent_outlier == 0, vce(robust)
	
		* (11) soe
_eststo soe, r: logit lcr i.indian i.electronics i.soe_india if patent_outlier == 0, vce(robust)

		* (12) age
_eststo age, r: logit lcr i.indian i.electronics age if patent_outlier == 0, vce(robust)

		* (13) energy focus
_eststo energy, r: logit lcr i.indian i.electronics i.energy_focus if patent_outlier == 0, vce(robust)

		* (14) manufacturer
_eststo manuf, r: logit lcr i.indian i.manufacturer if patent_outlier == 0, vce(robust)
* high correlation manufacturer electronics (0.8)

		* (15) solar manufacturer
_eststo manuf_solar, r: logit lcr i.indian i.manufacturer i.manufacturer_solar if patent_outlier == 0, vce(robust)

		* (16) subsidiary
_eststo subsidiary, r: logit lcr i.indian i.manufacturer_solar subsidiary if patent_outlier == 0, vce(robust)

		* (17) phase 1 participation NSM
_eststo phase, r: logit lcr i.indian i.manufacturer_solar i.part_jnnsm_1 if patent_outlier == 0, vce(robust)

		* (18) all
_eststo all, r: logit lcr i.indian /*i.patentor*/ ihs_pre_not_solar_patent pre_solar_patent ihs_total_revenue log_total_employees sector i.soe_india age i.energy_focus i.manufacturer /*i.manufacturer_solar*/ i.subsidiary i.part_jnnsm_1 if patent_outlier == 0, vce(robust)

local regressions indian /*india_state*/ india_capital /*patentor*/ otherprepatents solarprepatents size1 size2 lob electronics soe age energy manuf subsidiary phase all
esttab `regressions' using variable_choice2_nooutlier.csv, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" /*"HQ Indian state"*/ "HQ in Delhi" /*"Pre Patentor"*/ "pre-LCR patents" "pre-LCR solar patents" "pre-LCR sales" "pre-LCR employees" "Sector" "Electronics" "SOE" "Age" "Energy focus" "Manufacturer" "Subsidiary" "Phase 1" "All") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
}
***********************************************************************
* 	PART 4: iteratively test-up	- only winners
***********************************************************************
{
		* (1-3) indian
_eststo indian, r: logit lcr i.indian if won_total == 1, vce(robust)
*_eststo india_state, r: logit lcr i.hq_indian_state if won_total == 1, vce(robust)
_eststo india_capital, r: logit lcr i.capital if won_total == 1, vce(robust)

		* (4) pre patented
_eststo patentor, r: logit lcr i.indian i.patentor if won_total == 1, vce(robust)
		
		* (5) pre amount of other patents
_eststo otherprepatents, r: logit lcr i.indian ihs_pre_not_solar_patent if won_total == 1, vce(robust)

		* (6) pre solar patents
_eststo solarprepatents, r: logit lcr i.indian pre_solar_patent if won_total == 1, vce(robust)

		* (7) total_revenue
_eststo size1, r: logit lcr i.indian ihs_total_revenue if won_total == 1, vce(robust)

		* (8) total_employees
_eststo size2, r: logit lcr i.indian log_total_employees if won_total == 1, vce(robust)
*_eststo size2, r: logit lcr total_revenue empl if won_total == 1, vce(robust)

		* (9) sector
_eststo lob, r: logit lcr i.indian i.sector if won_total == 1, vce(robust)

		* (10) sector - electronics
_eststo electronics, r: logit lcr i.indian i.electronics if won_total == 1, vce(robust)
	
		* (11) soe
_eststo soe, r: logit lcr i.indian i.electronics i.soe_india if won_total == 1, vce(robust)

		* (12) age
_eststo age, r: logit lcr i.indian i.electronics age if won_total == 1, vce(robust)

		* (13) energy focus
_eststo energy, r: logit lcr i.indian i.electronics i.energy_focus if won_total == 1, vce(robust)

		* (14) manufacturer
_eststo manuf, r: logit lcr i.indian i.manufacturer if won_total == 1, vce(robust)
* high correlation manufacturer electronics (0.8)

		* (15) solar manufacturer
_eststo manuf_solar, r: logit lcr i.indian i.manufacturer i.manufacturer_solar if won_total == 1, vce(robust)

		* (16) subsidiary
_eststo subsidiary, r: logit lcr i.indian i.manufacturer_solar subsidiary if won_total == 1, vce(robust)

		* (17) phase 1 participation NSM
_eststo phase, r: logit lcr i.indian i.manufacturer_solar i.part_jnnsm_1 if won_total == 1, vce(robust)

		* (18) all
_eststo all, r: logit lcr i.indian /*i.patentor*/ ihs_pre_not_solar_patent pre_solar_patent ihs_total_revenue log_total_employees sector i.soe_india age i.energy_focus i.manufacturer /*i.manufacturer_solar*/ i.subsidiary i.part_jnnsm_1 if won_total == 1, vce(robust)

local regressions indian /*india_state*/ india_capital /*patentor*/ otherprepatents solarprepatents size1 size2 lob electronics soe age energy manuf subsidiary phase all
esttab `regressions' using variable_choice2_won_total.csv, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" /*"HQ Indian state"*/ "HQ in Delhi" /*"Pre Patentor"*/ "pre-LCR patents" "pre-LCR solar patents" "pre-LCR sales" "pre-LCR employees" "Sector" "Electronics" "SOE" "Age" "Energy focus" "Manufacturer" "Subsidiary" "Phase 1" "All") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
}
***********************************************************************
* 	PART 5: iteratively test-up	- won lcr vs. did not win lcr, w/o outlier Barat, Sunedison
***********************************************************************
{
		* (1-3) indian
_eststo indian, r: logit lcr_won i.indian if patent_outlier == 0, vce(robust)
*_eststo india_state, r: logit lcr_won i.hq_indian_state if patent_outlier == 0, vce(robust)
_eststo india_capital, r: logit lcr_won i.capital if patent_outlier == 0, vce(robust)

		* (4) pre patented
_eststo patentor, r: logit lcr_won i.indian i.patentor if patent_outlier == 0, vce(robust)
		
		* (5) pre amount of other patents
_eststo otherprepatents, r: logit lcr_won i.indian ihs_pre_not_solar_patent if patent_outlier == 0, vce(robust)

		* (6) total_revenue
_eststo size1, r: logit lcr_won i.indian ihs_total_revenue if patent_outlier == 0, vce(robust)

		* (7) total_employees
_eststo size2, r: logit lcr_won i.indian log_total_employees if patent_outlier == 0, vce(robust)
*_eststo size2, r: logit lcr_won total_revenue empl if patent_outlier == 0, vce(robust)

		* (8) sector
_eststo lob, r: logit lcr_won i.indian i.sector if patent_outlier == 0, vce(robust)

		* (9) sector - electronics
_eststo electronics, r: logit lcr_won i.indian i.electronics if patent_outlier == 0, vce(robust)
	
		* (10) soe
_eststo soe, r: logit lcr_won i.indian i.electronics i.soe_india if patent_outlier == 0, vce(robust)

		* (11) age
_eststo age, r: logit lcr_won i.indian i.electronics age if patent_outlier == 0, vce(robust)

		* (12) energy focus
_eststo energy, r: logit lcr_won i.indian i.electronics i.energy_focus if patent_outlier == 0, vce(robust)

		* (13) manufacturer
_eststo manuf, r: logit lcr_won i.indian i.manufacturer if patent_outlier == 0, vce(robust)
* high correlation manufacturer electronics (0.8)

		* (14) solar manufacturer
_eststo manuf_solar, r: logit lcr_won i.indian i.manufacturer i.manufacturer_solar if patent_outlier == 0, vce(robust)

		* (15) subsidiary
_eststo subsidiary, r: logit lcr_won i.indian i.manufacturer_solar subsidiary if patent_outlier == 0, vce(robust)

		* (14) all
_eststo all, r: logit lcr_won i.indian /*i.patentor*/ ihs_pre_not_solar_patent ihs_sales total_employees sector i.soe_india age i.energy_focus i.manufacturer i.manufacturer_solar i.subsidiary if patent_outlier == 0, vce(robust)


local regressions indian /*india_state*/ india_capital /*patentor*/ otherprepatents size1 size2 lob electronics soe age energy manuf manuf_solar subsidiary all
esttab `regressions' using variable_choice3.csv, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" /*"HQ Indian state"*/ "HQ in Delhi" /*"Pre Patentor"*/ "pre-LCR patents" "pre-LCR sales" "pre-LCR employees" "Sector" "Electronics" "SOE" "Age" "Energy focus" "Manufacturer" "Solar manufacturer" "Subsidiary" "All") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
}	
***********************************************************************
* 	PART 6:  explore pre-matching balance in selected variables 			
***********************************************************************
{
	* put variables for matching into a local
local matching_var log_total_employees ihs_total_revenue pre_solar_patent indian manufacturer part_jnnsm_1

set graphics on

	* pre-matching table 1 / balance table
iebaltab `matching_var', grpvar(lcr) savetex(baltab_lcr_pre) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
	
	* pre-matching standardised bias
pstest `matching_var', raw rubin treated(lcr) graph ///
		title(Standardized bias LCR vs. no LCR firms) ///
		subtitle(Pre-matching) ///
		note(Standardised bias should between [-25%-25%]., size(small)) ///
		name(pre_bias, replace)
gr export pre_bias.png, replace

set graphics off
}
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_final}/lcr_final", replace
