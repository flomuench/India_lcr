***********************************************************************
* 	LCR India - common support
***********************************************************************
*																	    
*	PURPOSE: evaluate whether there is common support
*																	  
*	OUTLINE:														  
*	1) set the scene
*	2) figure 18 - evaluation of common support
*	3) firms off common support
*
*	Author:  	Florian Münch, Fabian Scheifele				  
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$final_figures"

***********************************************************************
* 	PART 2:  Evaluation of common support - Figure 18	
***********************************************************************
	* criteria/techniques for decision of common support
			* min-max
			* trimming
			* threshold amount q (density at x > q)
			
	* Figure 18
			* vary bin size 
set graphics on
foreach sample in all won nooutliers {
	forvalues binwidth = 5(5)20 {
			* depending on sample change pscore
		psgraph , treated(lcr) pscore(pscore_`sample') bin(`binwidth') ///
			subtitle(bin width = `binwidth') ///
			xlabel(0(.1)1) ///
			legend(label(1 "LCR auctions") label(2 "Open auctions") pos(6) rows(1)) ///
			name(common_support_`sample'`binwidth', replace)
		}
	grc1leg common_support_`sample'5 common_support_`sample'10 common_support_`sample'15 common_support_`sample'20, ///
		legendfrom(common_support_`sample'5) pos(6) span ///
		name(common_support_`sample', replace)
gr export common_support_`sample'.png, replace
}


	* range of propensity score in both groups
foreach sample in all won nooutliers {
bysort lcr: sum pscore_`sample'
/* LCR = 1 min: 0 ; max.: .95 
   LCR = 0 min: 0 ; max.: .72
*/
}

	* change directory to bundled psm 
cd "$lcr_psm"

	* density distribution of propensity score in both groups
kdensity pscore_all if lcr == 1 & patent_outliers == 0, addplot(kdensity pscore_all if lcr == 0 & patent_outliers == 0)	///
	legend(ring(0) pos(2) label(1 "participated LCR") label(2 "no LCR")) ///
	title("Propensity score density by LCR participation") ///
	xlabel(0(.05)1) ///
	name(common_support_density, replace)
gr export common_support_density.png, replace

	
	* eye-balling the firms & their pscores
local matching_var ihs_pre_not_solar_patent soe_india indian manufacturer part_jnnsm_1
	
	* sample in all won nooutliers 
	sort pscore_all
	br company_name pscore_all lcr pre_solar_patent post_solar_patent `matching_var'

***********************************************************************
* 	PART 3: firms off common support	
***********************************************************************
foreach sample in `sample' all won nooutliers {
gr hbar pscore_`sample' if pscore_`sample' > .6 & pscore_`sample' != ., over(company_name) ///
		by(lcr, title("{bf:Firms with propensity score > 0.6}") subtitle("Potential matches by LCR") note(sample = `sample')) ///
		blabel(total, format(%9.2fc)) ///
		ytitle(pscore_`sample') ///
		name(pscore_`sample'_lcr, replace)
gr export pscore_`sample'_lcr.png, replace
}

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off
save "${lcr_final}/lcr_final", replace


