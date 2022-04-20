***********************************************************************
* 		generate variables - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: generate relevant variables for analysis & visualisation				  							  
*																	  
*	OUTLINE:														  
*	1) 
* 	2) 
* 	3) 
*	4) 
*	5) 
*	6) 
*   7) 
*	8) 
*	9) 
*
*																	  															      
*	Author:  	Florian Muench, Fabian Scheifele							  
*	ID varialcre: 			  					  
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_intermediate}/lcr_inter", clear


***********************************************************************
* 	PART 2: outcome variable for DiD		  										  
***********************************************************************
gen dif_solar_patents = post_solar_patent-pre_solar_patent
*br company_name dif_solar_patents post_solar_patent pre_solar_patent

***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
foreach x in city state subsidiary lob  {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}

***********************************************************************
* 	PART 3: create dummy for firm having participated in LCR auction		  										  
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

***********************************************************************
* 	PART 4: create dummy for firm having filed a solar patent
***********************************************************************
gen solarpatents = pre_solar_patent + post_solar_patent
lab var solarpatents "pre + post solar patents"

gen solar_patentor = (solarpatents > 0 & solarpatents <.), b(solarpatents)

***********************************************************************
* 	PART 5: create dummy for firm having filed a patent
***********************************************************************
gen total_patents = pre_total_patent + post_total_patent
lab var total_patents "pre + post total patents"

gen patentor = (pre_total_patent > 0 & pre_total_patent <.), b(pre_total_patent)
lab var patentor "filed patent before 2012"

	* create ihs of total pre not solar patents
ihstrans pre_not_solar_patent


***********************************************************************
* 	PART 6: create dummy for Indian companies
***********************************************************************
*gen indian = (international < 1)

lab def national 1 "indian" 0 "international"
lab val indian national


***********************************************************************
* 	PART 7: create dummy for company HQ main city in India
***********************************************************************

/*
gen hq_indian_state = .
replace hq_indian_state = 1 if state1 != .
local not_indian 5 11 19 9 6 16 15
foreach x of local not_indian  {
	replace hq_indian_state = 0 if state1 == `x'
}
*/

	* dummy for delhi
gen capital = (city == 21)
lab var capital "HQ in Delhi"


***********************************************************************
* 	PART 8: create dummy patent outliers
***********************************************************************
cd "$lcr_descriptives"
set graphics on

	* graph 
graph box total_patents, mark(1, mlab(company_name)) ///
	title("Identification of outliers in terms of total patents") ///
	name(outlier_patents, replace)
gr export outlier_patents.png, replace

graph box solarpatents, mark(1, mlab(company_name)) ///
	title("Identification of outliers in terms of solar patents") ///
	name(outlier_solarpatents, replace)
gr export outlier_solarpatents.png, replace
	
	* define dummy for outliers
gen patent_outliers = 0
replace patent_outliers = 1 if company_name == "bosch" /* | company_name == "bharat" | company_name == "larsen" */

***********************************************************************
* 	PART 9: electronics vs. rest sector dummy
***********************************************************************
gen electronics = 0
replace electronics = 1 if sector == 6


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off 

	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
