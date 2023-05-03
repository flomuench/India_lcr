***********************************************************************
* 		India LCR - generate variables								  	  
***********************************************************************
*																	    
*	PURPOSE: generate derived variables				  
*																	  
*	OUTLINE:														  
*	1)		import data
* 	2) 		generate pre-post difference in solar patents
* 	3) 		encode factor variables
*	4) 		dummy for LCR auction participation
*	5) 		dummy for solar patent
*	6)		dummy for any patent 
*   7) 		dummy for Indian companies
*	8) 		dummy for company HQ main city in India
*	9) 		dummy HQ in capital
*	10)		dummy patent outliers
*	11)		dummy electronics
*	12)		ihs-and log-transform sales & employees variables
*								      
*	Author: Florian Muench, Fabian Scheifele				  
*	ID varialble: 	company_name		  					  
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  import data			
***********************************************************************
use "${lcr_intermediate}/lcr_inter", clear

***********************************************************************
* 	PART 2: outcome variable for DiD		  										  
***********************************************************************
gen dif_solar_patents = post_solar_patent-pre_solar_patent
lab var dif_solar_patents "Pre-Post diff. solar patents"
gen dif_modcell_patents = post_modcell_patent - pre_modcell_patent
*br company_name dif_solar_patents post_solar_patent pre_solar_patent


kdensity dif_solar_patents
sum dif_solar_patents
scalar patent_dif_variance = r(sd)^2
display patent_dif_variance /* variance about 10x mean */

***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
foreach x in city state subsidiary lob  {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}

***********************************************************************
* 	PART 4: dummy for LCR auction participation
***********************************************************************
		* dummy for at least 1x LCR
gen lcr = (total_auctions_lcr > 0 & total_auctions_lcr <.), b(total_auctions_lcr)
label var lcr "participated (or not) in LCR auction"
lab def local_content 1 "participated in LCR" 0 "did not participate in LCR"
lab val lcr local_content

		* dummy for only LCR
gen lcr_only = (total_auctions_lcr == total_auctions) if total_auctions != . , a(total_auctions_lcr)
lab def just_lcr 1 "only participated in LCR" 0 "LCR & no LCR"
lab val lcr_only just_lcr

		* dummy for both LCR & no LCR 
gen lcr_both = (total_auctions_lcr > 0 & total_auctions_lcr < . & total_auctions_no_lcr > 0 & total_auctions_no_lcr < .)
lab var lcr_both "firm participated in lcr & no lcr auctions"

		* won LCR
gen lcr_won = (won_lcr > 0 & won_lcr < .)
lab var lcr_won "firm won LCR auction or not"

lab def lcr_wons 1 "Won LCR auction" 0 "Did not win LCR auction"
lab val lcr_won lcr_wons

		*LCR vs. non-LCR winners
gen winner_types= .
replace winner_types=1 if won_lcr>0	& won_lcr < .
replace winner_types=0 if won_no_lcr>0	& lcr_won==0
lab var winner_types "Dummy distinguising LCR and open winners"
lab def winners 1 "Won at least 1 LCR auction" 0 "Won only open auctions"
lab val winner_types winners
		
***********************************************************************
* 	PART 5: dummy for solar patent
***********************************************************************
gen solarpatents = pre_solar_patent + post_solar_patent
lab var solarpatents "pre + post solar patents"

gen solar_patentor = (solarpatents > 0 & solarpatents <.), b(solarpatents)
lab var solar_patentor "At least one solar patent"
lab def yesno 1 "Yes" 0 "No"
lab val solar_patentor yesno

gen post_solar_patentor = 0
replace post_solar_patentor =1 if post_solar_patent>0 & post_solar_patent<.
lab var post_solar_patentor "At least one solar patent after LCR introduction"
lab val post_solar_patentor yesno

gen pre_solar_patentor = 0
replace pre_solar_patentor =1 if pre_solar_patent>0 & pre_solar_patent<.
lab var pre_solar_patentor "At least one solar patent prior to LCR introduction"
lab val pre_solar_patentor yesno

gen diff_solar_patentor = post_solar_patentor - pre_solar_patentor
lab var diff_solar_patentor "Solar patentor status changed after after LCR"

***********************************************************************
* 	PART 6: dummy for any patent
***********************************************************************
gen total_patents = pre_total_patent + post_total_patent
lab var total_patents "pre + post total patents"

gen patentor = (pre_total_patent > 0 & pre_total_patent <.), b(pre_total_patent)
lab var patentor "filed patent before 2012"
lab val patentor yesno

	* create ihs of total pre not solar patents
ihstrans pre_not_solar_patent
lab var ihs_pre_not_solar_patent "not solar patents, ihs transformed"

***********************************************************************
* 	PART 7: dummy for Indian companies
***********************************************************************
*gen indian = (international < 1)

lab def national 1 "indian" 0 "international"
lab val indian national

***********************************************************************
* 	PART 8: dummy HQ in capital
***********************************************************************
gen capital = (city == 21)
lab var capital "HQ in Delhi"

***********************************************************************
* 	PART 9: dummy patent outliers
***********************************************************************
gen patent_outliers = 0
replace patent_outliers = 1 if company_name == "bosch" | company_name == "sunedison" /* | company_name == "bharat" | company_name == "larsen" */

***********************************************************************
* 	PART 10: electronics
***********************************************************************
gen electronics = 0
replace electronics = 1 if sector == 6
lab var electronics "electronics sector"
lab def electro 1 "Firm in electronics sector" 0 "other sector"
lab val electronics electro

***********************************************************************
* 	PART 11: transform sales & employees variables
***********************************************************************
	* sales: ihs transformation used given both zeros and extreme values
ihstrans total_revenue
lab var ihs_total_revenue "ihs transf. pre-LCR sales"
kdensity ihs_total_revenue

ihstrans post_revenue
lab var ihs_post_revenue "ihs transf. post-LCR sales"
kdensity ihs_post_revenue

	* Create difference in Sales for Difference in Differences Analysis
gen diff_revenue = post_revenue-total_revenue
lab var diff_revenue "Difference in Revenues pre- vs. post-LCR"

	* employees: log-transformation given no zeros but extreme values
gen log_total_employees = log(total_employees)
kdensity log_total_employees

***********************************************************************
* 	PART 12: Create variables to display share of LCR auctions	  					  			
***********************************************************************
*Share of LCR particitation among total
gen share_lcr_part = total_auctions_lcr/total_auctions

*Share of LCR wins among total wins
gen share_lcr_won = won_lcr/won_total

 *Share of LCR MW wanted among total wanted
gen share_lcr_mw_wanted = quantity_wanted_mw_lcr/ quantity_wanted_mw_total

 *Share of LCR MW allocated among total allocated
gen share_lcr_mw_allocated = quantity_allocated_mw_lcr/ quantity_allocated_mw_total

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* save dta file
save "${lcr_final}/lcr_final", replace
