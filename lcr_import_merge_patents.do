***********************************************************************
* 			lcr India paper: import and merge with firm patent data						
***********************************************************************
*																	   
*	PURPOSE: import the GIZ-API contact list as prepared					  								  
*	by Teo			  
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the list of patents		  						
***********************************************************************
cd "$lcr_raw"

use "${lcr_raw}/firmpatent", clear

***********************************************************************
* 	PART 2: document unique identifier  						
***********************************************************************
	* id or companyname_correct?
gen id_dif = (id == companyname_correct), a(companyname_correct)
codebook id_dif /* suggest different in 315 cases */

***********************************************************************
* 	PART 3: over time evolution of patents 	  						
***********************************************************************
	* change directory to output folder for descriptive stats
cd "$lcr_descriptives"

	* create a dummy for not a solar patent
gen not_solar_patent = (solarpatent < 1)

	* create a one to count each patent
gen onepatent = 1

sort year_application
graph bar (sum) solarpatent not_solar_patent, over(year_application, label(labs(tiny))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Annual solar patent applications in India: 1982-2021}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "Solar patents") label(2 "All other patents") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(patent_evolution, replace)
gr export patent_evolution.png, replace



***********************************************************************
* 	PART 3: collapse the data 	  						
***********************************************************************


	* check missing values for company/year
codebook companyname_correct
codebook year_* /* 122 missing year values for both year of publication or application */
tab solarpatent if year_publication == . /* no solar patent are concerned */

drop if year_publication == .

	* collapse data to company-year panel
collapse (sum) solarpatent not_solar_patent onepatent, by(companyname_correct year_application)

	* collapse into pre-treatment period (1982-2011) or post-treatment period (2012-2020)
gen post = (year_application > 2011 & year_application < .)
	
	* check whether time periods are correctly divided
tab year_application if post == 1 /* 224 patents before treatment */
tab year_application if post == 0 /* 262 patents after after treatment */

***********************************************************************
* 	PART 4: by company over time evolution of patents 	  						
***********************************************************************

encode companyname_correct, gen(firm)
xtset firm year_application
xtgraph onepatent
xtgraph solarpatent


***********************************************************************
* 	PART 5: collapse to patent count pre & post treatment	  						
***********************************************************************

collapse (sum) solarpatent not_solar_patent onepatent, by(companyname_correct post)
reshape wide solarpatent not_solar_patent onepatent, i(companyname_correct) j(post)
foreach x in solarpatent0 not_solar_patent0 onepatent0 {
	replace `x' = 0 if `x' == .
}
rename solarpatent0 pre_solar_patent
rename solarpatent1 post_solar_patent
rename not_solar_patent0 pre_not_solar_patent
rename not_solar_patent1 post_not_solar_patent
rename onepatent0 pre_total_patents
rename onepatent1 post_total_patents

***********************************************************************
* 	PART 4: descriptive statistics about pre-post (solar) patents 	  						
***********************************************************************
	* 
local prepostsolar pre_solar_patent post_solar_patent
local prepostother pre_not_solar_patent post_not_solar_patent
local preposttotal pre_total_patents post_total_patents

	* all together
graph bar (sum)  `prepostsolar' `prepostother'

	* solar only
graph bar (sum)  `prepostsolar' 

***********************************************************************
* 	PART 2: save list of lcrtered firms in lcrtration raw 			  						
***********************************************************************
save "lcr_raw", replace
