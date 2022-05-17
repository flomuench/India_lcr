***********************************************************************
* 			common support assessment - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: evaluate whether there is common support or positive 				  							  
*	density along the propensity score distribution  
*																	  
*	OUTLINE:														  
*
*																	  								      
*	Author:  	Florian Muench & Fabian Scheifele						  
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

***********************************************************************
* 	PART 2:  Evaluation of common support			
***********************************************************************
	* criteria/techniques for decision of common support
			* min-max
			* trimming
			* threshold amount q (density at x > q)
			
	* visualisation 
			* attention: definition of bin size
set graphics on
foreach sample in all won nooutliers {
	forvalues binwidth = 5(5)20 {
			* depending on sample change pscore
		psgraph , treated(lcr) pscore(pscore_`sample') bin(`binwidth') ///
			title(Number of bins = `binwidth') ///
			subtitle(sample = `sample') ///
			xlabel(0(.05)1) ///
			name(common_support_`sample'`binwidth', replace)
		}
	gr combine common_support_`sample'5 common_support_`sample'10 common_support_`sample'15 common_support_`sample'20, ///
		title("{bf:Is there common support for LCR & non-LCR firms?}") ///
		name(common_support_`sample', replace)
cd "$final_figures"
gr export common_support_`sample'.png, replace
}


	* range of propensity score in both groups
foreach sample in all won nooutliers {
bysort lcr: sum pscore_`sample'
/* LCR = 1 min: 0 ; max.: .95 
   LCR = 0 min: 0 ; max.: .72
*/
}

	* density distribution of propensity score in both groups
kdensity pscore_all if lcr == 1 & patent_outliers == 0, addplot(kdensity pscore_all if lcr == 0 & patent_outliers == 0)	///
	legend(ring(0) pos(2) label(1 "participated LCR") label(2 "no LCR")) ///
	title("Propensity score density by LCR participation") ///
	xlabel(0(.05)1) ///
	name(common_support_density, replace)
gr export common_support_density.png, replace

	
	* eye-balling the firms & their pscores
local matching_var5 ihs_pre_not_solar_patent soe_india indian manufacturer part_jnnsm_1
	* sample in all won nooutliers 
	sort pscore_all
	br company_name pscore_all lcr pre_solar_patent post_solar_patent `matching_var5'

***********************************************************************
* 	PART 2: who are the firms that fall outside the common support?	
***********************************************************************
br company_name pscore_all solar_patentor pre_solar_patent post_solar_patent total_auctions total_auctions_lcr if pscore_all > 0.72 & lcr == 1
	/* 
tata --> .86
azure --> .95
today
bharat	
	*/
	
gr hbar pscore_all if pscore_all > .6 & pscore_all != ., over(company_name) ///
		by(lcr, title("{bf:Firms with propensity score > 0.6}") subtitle("Potential matches by LCR")) ///
		blabel(total, format(%9.2fc)) ///
		ytitle(pscore_all) ///
		name(pscore_all_lcr, replace)
gr export pscore_all_lcr.png, replace

br company_name pscore_all solar_patentor pre_solar_patent post_solar_patent total_auctions total_auctions_lcr if common_support == 0 & lcr == 1
/*
company_name
azure ---> highly important
bharat --> dropped before because outlier
bosch --> dropped before because outlier
harsha --> not so relevant
today --> not relevant
*/


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off

	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace




* Archive
/*
* psgraph
* MODEL ALCOHOL CONSUMPTION
logistic mbsmoke alcohol deadkids foreign rcs_* mhisp i.medu2 mmarried mrace i.prenatal

* LOG ODDS OF SMOKING
predict logodds, xb

* GET A SENSE OF .25 SD OF LINEAR PROPENSITY SCORE
summarize logodds
*/
