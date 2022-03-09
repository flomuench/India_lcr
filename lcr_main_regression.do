***********************************************************************
* 			main regression - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: estimation of effect of LCR on solar patents based
*	on matching
*	  
*	OUTLINE:														  
*
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
use "${lcr_intermediate}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_psm"

***********************************************************************
* 	PART 2:  Nearest neighbor matching
***********************************************************************
	* nn-matching is default in psmatch2 hence requires no option (default)
	
	* make sure the sort order is random (but replicable as sort seed set)
gen random = runiform(0,1)
sort random
	
	* with replacement
		* no common support, only nearest neighbor
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore)
sort _id
br company_name post_solar_patent lcr pscore common_support _pscore-_pdif
	/*
azure, tata & today are matched with mahindra
	*/
codebook _n1 
/* suggests only 21 obs from treatment, hence total of 32 + 21 = 53 obs used.
	lots of sample/variation gets lost */
	
		* 2 nn
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) neighbor(2)
tab _weight lcr, missing
	/*
mean in control group down to .54
SE down to .68 & t-stat up to .48
35 observations from control used
	*/

		* 3 nn
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) neighbor(3)

	

	* without replacement
sort random
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) noreplacement descending
/* almost identical with nn1 with replacement */

	
	
***********************************************************************
* 	PART 3:  Radius matching
***********************************************************************
		* caliper 0.2
psmatch2 lcr if patent_outliers == 0, radius caliper(0.2) outcome(post_solar_patent) pscore(pscore)
br if _support == 0
/*
we loose azure & today in the LCR group
*/
		*
		* caliper 0.25
psmatch2 lcr if patent_outliers == 0, radius caliper(0.25) outcome(post_solar_patent) pscore(pscore)
* azure & today are kept but effect remain insignificant due to high variance in SE

		* caliper 0.5
psmatch2 lcr if patent_outliers == 0, radius caliper(0.5) outcome(post_solar_patent) pscore(pscore)

***********************************************************************
* 	PART 4:  Kernel matching
***********************************************************************

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.1)

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.25)

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.5)
