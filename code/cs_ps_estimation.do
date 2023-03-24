***********************************************************************
* 		LCR India - propensity score (PS) estimation
***********************************************************************
*																	    
*	PURPOSE: estimate PS for weighted DiD
*																	  
*																	  
*	OUTLINE:														  
*	1) set the scene
* 	2) estimate PS for LCR participation
*	3) estimate PS for LCR win
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

	* put variables for matching into a local
local matching_var log_total_employees ihs_total_revenue pre_solar_patent indian manufacturer_solar part_jnnsm_1

***********************************************************************
* 	PART 2:  estimate PS for LCR participation
***********************************************************************
	* sample: all
_eststo all_score, r: logit lcr `matching_var', vce(robust)
predict pscore_all, p
sum pscore_all, d
label var pscore_all "estimated propensity score to participate in LCR auctions, all firms"
cd "$final_figures"
esttab all_score using firststage.tex, replace ///
	title("Predicting participation in LCR auctions") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("Estimates are based on a Logit model with robust standard errors in parentheses.")


	* sample: only firms that won at least one auction
cd "$lcr_psm"
logit lcr `matching_var' if won_total > 0, vce(robust)
predict pscore_won if won_total > 0, p
sum pscore_won, d
label var pscore_won "estimated propensity score to participate in LCR auctions, won only"

	* excluding outliers Bosch/Sunedison: 
logit lcr `matching_var' if patent_outliers == 0, vce(robust)
predict pscore_nooutliers if patent_outliers == 0, p
sum pscore_nooutliers, d
label var pscore_nooutliers "estimated propensity score to participate in LCR auctions, no outliers"

	* excluding positive/negative sales outliers Bharat,NTPC,larsen:
gen sales_outliers = 0
replace sales_outliers = 1 if company_name == "bharat"
replace sales_outliers = 1 if company_name == "larsen"
replace sales_outliers = 1 if company_name == "ntpc"
label var sales_outliers "outliers in terms of sales pre-post difference"

logit lcr `matching_var' if sales_outliers == 0, vce(robust)
predict pscore_nosalesoutliers if sales_outliers == 0, p
sum pscore_nosalesoutliers, d
label var pscore_nosalesoutliers "estimated propensity score to participate in LCR auctions, no sales outliers"

***********************************************************************
* 	PART 3:  estimate propensity to win LCR auction
***********************************************************************
logit lcr_won `matching_var', vce(robust)
predict pscore_win, p
sum pscore_win, d
label var pscore_win "estimated propensity score to win LCR auction"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_final}/lcr_final", replace

