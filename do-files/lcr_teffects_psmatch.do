***********************************************************************
* 			robustness check 1 - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: use teffects psmatch to estimate effect of LCR on patents
*	  
*	OUTLINE: 												  
*
*
*																	  															      
*	Author:  	Florian Muench 							  
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_rt"

***********************************************************************
* 	PART 2:  
***********************************************************************
	* nn1
			* counterfactual = participated
teffects psmatch (post_solar_patent) (lcr ihs_pre_not_solar_patent soe_india indian manufacturer, logit), vce(robust) nneighbor(1) ///
			osample(outside) gen(match)
predict ps0 ps1, ps
predict y0 y1, po

			* counterfactual = won
teffects psmatch (post_solar_patent) (lcr_won ihs_pre_not_solar_patent soe_india indian manufacturer, logit), vce(robust) nneighbor(1)
