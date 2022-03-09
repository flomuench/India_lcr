***********************************************************************
* 			matching quality - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: assess the quality of the matching in terms of reducing
*	standardised bias between treated & matched controls
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
cd "$lcr_psm"

	* put variables for matching into a local
local matching_var hq_indian_state total_won patentor pre_not_solar_patent sales employees total_plant_price_lifetime

	*
set graphics on

***********************************************************************
* 	PART 2:  Nearest neighbor matching with replacement
***********************************************************************
		* nn = 1-3
forvalues x = 1(1)3 {
	psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) neighbor(`x')

		* pre-matching standardised bias
	pstest `matching_var' if patent_outlier == 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching) ///
			note(Standardised bias should between [-25%-25%]., size(small)) ///
			name(post_bias_nn`x', replace)
	gr export post_bias_nn`x'.png, replace


	* table 1 / balance table post matching
iebaltab `matching_var' if patent_outlier == 0 & _weight != ., grpvar(lcr) save(baltab_lcr_post_nn`x') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

}


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
