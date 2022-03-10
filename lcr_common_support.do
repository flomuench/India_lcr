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

***********************************************************************
* 	PART 2:  Evaluation of common support			
***********************************************************************
	* criteria/techniques for decision of common support
			* min-max
			* trimming
			* threshold amount q (density at x > q)
			
			
	* option 1: min-max
		* visualisation 
			* attention: definition of bin size
set graphics on
forvalues x = 5(5)20 {
	psgraph , treated(lcr) pscore(pscore) bin(`x') ///
		title(Number of bins = `x') ///
		xlabel(0(.05)1) ///
		name(common_support`x', replace)
}

gr combine common_support5 common_support10 common_support15 common_support20, ///
		title("{bf:Is there common support for LCR & non-LCR firms?}") ///
		subtitle(Min-max criterion: common support between [0.15-0.8]) ///
		name(common_support, replace)
gr export common_support.png, replace


	* range of propensity score in both groups
bysort lcr: sum pscore 
/* LCR = 1 min: 0 ; max.: .95 
   LCR = 0 min: 0 ; max.: .72
*/
	
	* density distribution of propensity score in both groups
kdensity pscore if lcr == 1 & patent_outliers == 0, addplot(kdensity pscore if lcr == 0 & patent_outliers == 0)	///
	legend(ring(0) pos(2) label(1 "participated LCR") label(2 "no LCR")) ///
	title("Propensity score density by LCR participation") ///
	xlabel(0(.05)1) ///
	name(common_support_density, replace)
gr export common_support_density.png, replace

	
***********************************************************************
* 	PART 2:  generate dummy for observations within common support		
***********************************************************************
gen common_support = (pscore >= 0.15 & pscore <= 0.8)
label var common_support "=1 for firms within CS"


***********************************************************************
* 	PART 3: who are the firms that fall outside the common support?	
***********************************************************************
br company_name pscore solar_patentor pre_solar_patent post_solar_patent total_auctions total_lcr if pscore > 0.72 & lcr == 1
	/* 
tata --> .86
azure --> .95
today
bharat	
	*/
	
gr hbar pscore if pscore > .6 & pscore != ., over(company_name) ///
		by(lcr, title("{bf:Firms with propensity score > 0.6}") subtitle("Potential matches by LCR")) ///
		blabel(total, format(%9.2fc)) ///
		ytitle(pscore) ///
		name(pscore_lcr, replace)
gr export pscore_lcr.png, replace

br company_name pscore solar_patentor pre_solar_patent post_solar_patent total_auctions total_lcr if common_support == 0 & lcr == 1
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