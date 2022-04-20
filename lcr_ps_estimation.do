***********************************************************************
* 			propensity score estimation - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: decide whether to apply a logit or a probit model			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) logit
* 	2) probit
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_psm"

	* put variables for matching into a local
local matching_var indian patentor pre_not_solar_patent sales employees soe age energy_focus manufacturer manufacturer_solar subsidiary
local matching_var2 indian pre_not_solar_patent soe manufacturer manufacturer_solar
local matching_var3 indian pre_not_solar_patent soe manufacturer
local matching_var4 indian pre_not_solar_patent soe manufacturer sales employees age
local matching_var5 ihs_pre_not_solar_patent soe_india indian manufacturer

***********************************************************************
* 	PART 1:  set the scene  - counterfactual: did not participate in LCR	
***********************************************************************
	* estimate propensity (score) to participate in treatment
logit lcr `matching_var5' if patent_outliers == 0, vce(robust)
predict pscore if patent_outlier == 0, p
sum pscore, d
label var pscore "estimated propensity score to participate in LCR auctions"


***********************************************************************
* 	PART 2:  counterfactual: did not win LCR
***********************************************************************
logit lcr_won `matching_var5' if patent_outliers == 0, vce(robust)
predict pscore2 if patent_outlier == 0, p
sum pscore2, d
label var pscore2 "estimated propensity score to win LCR auction"


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace

