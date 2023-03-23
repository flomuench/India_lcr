***********************************************************************
* 		LCR India - match quality									  	  
***********************************************************************
*																	    
*	PURPOSE: bias reduction: visualisation + balance table post-matching
*	  
*	OUTLINE:														  
*	1)		set the scene
*	2)		Bias reduction + post-matching balance table - all
*	3)		Bias reduction + post-matching balance table - winner
*	4)		Bias reduction + post-matching balance table - no outliers
*	5) 		Prefered specification bias reduction
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
cd "$final_figures"

	* put variables for matching into a local
local matching_var log_total_employees ihs_total_revenue pre_solar_patent indian manufacturer part_jnnsm_1

	* turn visualisation on
set graphics on

	*make additional local with all variable (not only the ones used for matching)
local bias_table ihs_pre_not_solar_patent soe_india indian part_jnnsm_1 manufacturer manufacturer_solar pre_solar_patent patentor age energy_focus  subsidiary

***********************************************************************
* 	PART 2:  Bias reduction + post-matching balance table - all
***********************************************************************
local i = 0
foreach x in 0.05 0.1 {
	local ++i
	
		* caliper matching
psmatch2 lcr, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_all)

		* pre-matching standardised bias
	pstest `matching_var' if _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Sample = all. Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_all_radius`i', replace)
	gr export bias_all_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `matching_var' [iweight=_weight], grpvar(lcr) savetex(baltab_post_all_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}	
	
***********************************************************************
* 	PART 3:  Bias reduction + post-matching balance table - winner
***********************************************************************
local i = 0
foreach x in 0.05 0.1 {
	local ++i
	
		* caliper matching
psmatch2 lcr if won_total > 0, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_won)

		* pre-matching standardised bias
	pstest `matching_var' if won_total > 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(won = all. Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_won_radius`i', replace)
	gr export bias_won_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `matching_var' if won_total > 0 [iweight=_weight], grpvar(lcr) savetex(baltab_post_won_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}		

***********************************************************************
* 	PART 4:  Bias reduction + post-matching balance table - no outliers
***********************************************************************
local i = 0
foreach x in 0.05 /* 0.1 for some reason does not converge */ {
	local ++i
	
		* caliper matching
	psmatch2 lcr if patent_outlier == 0, radius caliper(`x') outcome(post_solar_patent) pscore(pscore_nooutliers)

		* pre-matching standardised bias
	pstest `matching_var' if patent_outlier == 0 & _weight != ., both rubin treated(lcr) graph ///
			title(Standardized bias LCR vs. no LCR firms) ///
			subtitle(Post vs. pre-matching on caliper = `x') ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_nooutliers_radius`i', replace)
	gr export bias_nooutliers_radius`i'.png, replace

		* table 1 / balance table post matching
	iebaltab `matching_var' if patent_outlier == 0 [iweight=_weight], grpvar(lcr) savetex(baltab_post_nooutliers_radius`i') replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
}

**********************************************************************
* 	PART 5:  Prefered specification bias reduction
***********************************************************************
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_all)

		* pre-matching standardised bias
	pstest `matching_var' if _weight != ., both rubin treated(lcr) graph ///
			ylabel(-60(5)60, labs(vsmall)) ///
			note(Sample = all firms. Standardised bias should between [-25%-25%]., size(small)) ///
			yline (-25 25) ///
			name(bias_caliper01_all_paper, replace)
	gr export bias_caliper01_all_paper.png, replace
