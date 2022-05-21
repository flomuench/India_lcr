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
local matching_var5 ihs_pre_not_solar_patent soe_india indian manufacturer

	*
set graphics on

	*make additional local with all variable (not only the ones used for matching)
local bias_table ihs_pre_not_solar_patent soe_india indian part_jnnsm_1 manufacturer manufacturer_solar pre_solar_patent patentor age energy_focus  subsidiary
***********************************************************************
* 	PART 2:  Nearest neighbor matching with replacement
**********************************************************************

		* nn = 1-3
forvalues x = 1(1)3 {
	psmatch2 lcr, outcome(post_solar_patent) pscore(pscore_all) neighbor(`x')

		* pre-matching standardised bias
	pstest `bias_table' if patent_outlier == 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms: `x'- nearest neighbor) ///
			subtitle(Post vs. pre-matching) ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Standardised bias should between [-25%-25%]., size(small)) ///
			name(post_bias_nn`x', replace)
	gr export post_bias_nn`x'.png, replace


	* table 1 / balance table post matching
iebaltab `bias_table' if patent_outlier == 0 & _weight != ., grpvar(lcr) save(baltab_lcr_post_nn`x') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

}


***********************************************************************
* 	PART 3:  Radius/caliper matching
***********************************************************************
cd "$final_figures"
	
	* sample = all
local i = 0
foreach x in 0.05 0.1 {
	local ++i
	
		* caliper matching
psmatch2 lcr, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_all)

		* pre-matching standardised bias
	pstest `bias_table' if _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Sample = all. Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_all_radius`i', replace)
	gr export bias_all_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `bias_table' if _weight != ., grpvar(lcr) save(baltab_post_all_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}	
	
	* sample = won
local i = 0
foreach x in 0.05 0.1 {
	local ++i
	
		* caliper matching
psmatch2 lcr if won_total > 0, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_won)

		* pre-matching standardised bias
	pstest `bias_table' if won_total > 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(won = all. Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_won_radius`i', replace)
	gr export bias_won_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `bias_table' if won_total > 0 & _weight != ., grpvar(lcr) save(baltab_post_all_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}		
	
	* sample = no outliers
local i = 0
foreach x in 0.05 0.1 {
	local ++i
	
		* caliper matching
	psmatch2 lcr if patent_outlier == 0, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_nooutliers)

		* pre-matching standardised bias
	pstest `bias_table' if patent_outlier == 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_nooutliers_radius`i', replace)
	gr export bias_nooutliers_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `bias_table' if patent_outlier == 0 & _weight != ., grpvar(lcr) save(baltab_post_nooutliers_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}

***********************************************************************
* 	PART 4:  Kernel matching
**********************************************************************
cd "$lcr_psm"
*
local i = 0
foreach x in 0.1 0.25 0.5 {
	local ++i
		* kernel matching with varying bandwith
	psmatch2 lcr, kernel outcome(post_solar_patent) pscore(pscore_all) k(epan) bw(`x')

			* pre-matching standardised bias
	pstest `bias_table' if patent_outlier == 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching: epalechnikov kernel with bw = `x') ///
			ylabel(-60(5)60 labs(vsmall)) ///
			note(Standardised bias should between [-25%-25%]., size(small)) ///
			name(post_bias_kernel`i', replace)
	gr export post_bias_kernel`i'.png, replace

	* table 1 / balance table post matching
	iebaltab `bias_table' if patent_outlier == 0 & _weight != ., grpvar(lcr) save(baltab_lcr_post_kernel`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off

	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
