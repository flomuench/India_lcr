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
local matching_var india_capital patentor otherprepatents size1 size2 lob soe age energy manuf manuf_solar subsidiary all


***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
	* estimate propensity (score) to participate in treatment
logit lcr `matching_var' if patent_outliers == 0, vce(robust)
predict pscore, p
sum pscore, d
label var pscore "estimated propensity score to participate in LCR auctions"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace

