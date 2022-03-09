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
*	Author:  	Florian Muench 							  
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*
*	information about automatically exporting att from psmatch2: https://stackoverflow.com/questions/59950622/export-att-result-after-psmatch2-command										  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_rt"

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
scalar t = r(att)/ r(seatt)
mat n1 = ( r(att) \ t )
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
scalar t = r(att)/ r(seatt)
mat n2 = ( r(att) \ t )
tab _weight lcr, missing
	/*
mean in control group down to .54
SE down to .68 & t-stat up to .48
35 observations from control used
	*/

		* 3 nn
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) neighbor(3)
scalar t = r(att)/ r(seatt)
mat n3 = ( r(att) \ t )

mat nn = n1, n2, n3
mat colnames nn = "nn = 1" "nn = 2" "nn = 3"
mat rownames nn = att t

		* puts results from nn1-nn3 into one output
esttab matrix(nn, fmt(%9.2fc)) using nnmatching.csv, replace ///
	title("Results for nearest neighbor with replacement") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
	

	* without replacement
sort random
psmatch2 lcr if patent_outliers == 0, outcome(post_solar_patent) pscore(pscore) noreplacement descending
/* almost identical with nn1 with replacement */

	
	
***********************************************************************
* 	PART 3:  Radius matching
***********************************************************************
		* caliper 0.1
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore)
br if _support == 0
*we loose azure & today in the LCR group
scalar t = r(att)/ r(seatt)
mat c01 = ( r(att) \ t )
		*
		* caliper 0.25
psmatch2 lcr if patent_outliers == 0, radius caliper(0.25) outcome(post_solar_patent) pscore(pscore)
* azure & today are kept but effect remain insignificant due to high variance in SE
scalar t = r(att)/ r(seatt)
mat c025 = ( r(att) \ t )

		* caliper 0.5
psmatch2 lcr if patent_outliers == 0, radius caliper(0.5) outcome(post_solar_patent) pscore(pscore)
scalar t = r(att)/ r(seatt)
mat c05 = ( r(att) \ t )

mat radius = c01, c025, c05
mat colnames radius = "caliper = 0.1" "caliper = 0.25" "caliper = 0.5"
mat rownames radius = att t


esttab matrix(radius, fmt(%9.2fc)) using radiusmatching.csv, replace ///
	title("Results for radius matching") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")

***********************************************************************
* 	PART 4:  Kernel matching
***********************************************************************

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.1)
scalar t = r(att)/ r(seatt)
mat kbw01 = ( r(att) \ t )

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.25)
scalar t = r(att)/ r(seatt)
mat kbw025 = ( r(att) \ t )


psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore) k(epan) bw(0.5)
scalar t = r(att)/ r(seatt)
mat kbw05 = ( r(att) \ t )


mat kernel = kbw01, kbw025, kbw05
mat colnames kernel = "BW = 0.1" "BW = 0.25" "BW = 0.5"
mat rownames kernel = att t


esttab matrix(kernel, fmt(%9.2fc)) using kernelmatching.csv, replace ///
	title("Results for kernel matching") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")


***********************************************************************
* 	PART 5:  Put it all into one table
***********************************************************************


mat matching_all = nn, radius, kernel

esttab matrix(matching_all, fmt(%-9.2fc)) using matching_all.csv, replace ///
	title("Overview results with different matching algorithms") ///
	mtitles("NN" "Radius" "Kernel") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
	
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace

