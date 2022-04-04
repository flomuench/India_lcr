***********************************************************************
* 			lcr India paper: import and merge with firm patent data						
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import the list of patents											  
*	2)		document unique identifier
*	3) 		visualise over time evolution of patents
* 	4) 		collapse the data on company-year-level	
*	5) 		by company over time evolution of patents
*	6) 		collapse to patent count pre & post treatment
*	7) 		merge cross-section lcr_raw.dta file with patents
*	8) 		merge with firm characteristics + avg, min, max patent level complexity for each firm
*	9) 		
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

set graphics on
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
* 	PART 3: collapse the data on company-year-level						
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
*xtgraph onepatent
*xtgraph solarpatent


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
rename onepatent0 pre_total_patent
rename onepatent1 post_total_patent

lab var pre_solar_patent "solar patents 1982-2011"
lab var post_solar_patent "solar patents 2012-2021"

lab var pre_not_solar_patent "non-solar patents 1982-2011"
lab var post_not_solar_patent "non-solar patents 2012-2021"

lab var pre_total_patent "total patents 1982-2011"
lab var post_total_patent "total patents 2012-2021"


***********************************************************************
* 	PART 6: save file of pre-post treatment in raw folder		  						
***********************************************************************
* change directory to raw
cd "$lcr_raw"

rename companyname_correct company_name

save "patents_pre_post", replace


***********************************************************************
* 	PART 7: merge cross-section lcr_raw.dta file with patents			  						
***********************************************************************
	* companyname_correct is the common unique identifier
	* import lcr_raw.dta
use "${lcr_raw}/lcr_raw", clear
merge m:1 company_name using patents_pre_post /* results should indicate 27 firms merged */
drop _merge

save "lcr_raw", replace

***********************************************************************
* 	PART 8: merge with firm characteristics + avg, min, max patent level complexity for each firm		  						
***********************************************************************
use "solar_components_updated_HS", clear

rename companyname_correct company_name

	* create some descriptive statistics
cd "$lcr_descriptives"

		* solar patents by ipc group
gr hbar (count) , over(ipcgroups, sort(1)) ///
	blabel(total) ///
	title("{bf:Solar patents by IPC group category}") ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("number of patents") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipcgroup, replace)
gr export solarpatents_ipcgroup.png, replace

		* solar patents by ipc component
gr hbar (count) , over(ipcsubgroupscomponents, sort(1)) ///
	blabel(total) ///
	title("{bf:Solar patents by IPC component category}") ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("number of patents") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipccomponent, replace)
gr export solarpatents_ipccomponent.png, replace


		* histogram of product complexity
histogram pc_avg_17_19
kdensity pc_avg_17_19

		* average product complexity by ipc group
gr hbar pc_avg_17_19, over(ipcgroups, sort(1)) ///
	blabel(total, format(%9.2g)) ///
	title("{bf:Solar patents product complexity by IPC group category}") ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("product complexity") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipcgroup_pci, replace)
gr export solarpatents_ipcgroup_pci.png, replace
		
		* average product complexity by ipc component group
gr hbar pc_avg_17_19, over(ipcsubgroupscomponents, sort(1)) ///
	blabel(total, format(%9.2g)) ///
	title("{bf:Solar patents product complexity by IPC component category}") ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("product complexity") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipccomponent_pci, replace)
gr export solarpatents_ipccomponent_pci.png, replace

		* average product complexity by company
gr hbar pc_avg_17_19, over(company_name, sort(1)) ///
	blabel(total, format(%9.2g)) ///
	title("{bf:Solar patents mean product complexity by company}") ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("product complexity") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_byfirm_pci, replace)
gr export solarpatents_byfirm_pci.png, replace

/*
	* patents by company
levelsof company_name, local(company)
foreach x of local company {
	gr hbar (count) if company_name == "`x'", over(ipcgroups) ///
	blabel(total) ///
	subtitle("filed by `x'", size(small)) ///
	ytitle("number of patents") ///
	name(`x', replace)
}
levelsof company_name, local(company)
graph combine `company', ///
	title("{bf:Solar patents by IPC group category}") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(byfirm_solarpatents_ipcgroup, replace)
gr export byfirm_solarpatents_ipcgroup.png, replace
*/

	* create average patent complexity value

egen min_pci = min(pc_avg_17_19), by(company_name)
egen max_pci = max(pc_avg_17_19), by(company_name)
egen avg_pci = mean(pc_avg_17_19), by(company_name)

lab var min_pci "min pci of solar patents"
lab var max_pci "max pci of solar patents"
lab var avg_pci "mean pci of solar patents"

rename min_pci pat_min_pci
rename max_pci pat_max_pci
rename avg_pci pat_avg_pci


collapse (first) pat_min_pci pat_max_pci pat_avg_pci, by(company_name)

save "firm_pci", replace

use "${lcr_raw}/lcr_raw", clear
merge 1:1 company_name using "firm_pci"
drop _merge
save "lcr_raw", replace


***********************************************************************
* 	PART 9: 			* merge lob complexity		  						
***********************************************************************
cd "$lcr_raw"
import excel "cross_section_sumpatents_complexity", firstrow clear

rename pc_2017 lob_pc_2017 
rename pc_2018 lob_pc_2018
rename pc_2019 lob_pc_2019
rename pc_avg lob_pc_avg

rename companyname_correct company_name


keep company_name HS6_HS07 HS6_HS07 hs_description lob_pc_2017 lob_pc_2018 lob_pc_2019 lob_pc_avg

keep in 1/127 

save "cross_section_lob_complexity", replace

use "${lcr_raw}/lcr_raw", clear
merge 1:1 company_name using "cross_section_lob_complexity"
gen benonly = (_merge == 2)
tab benonly
label var benonly "NTPC not SECI auctions"
drop _merge
lab var HS6_HS07 "hs code line of business"



***********************************************************************
* 	PART 10: replace the existing lcr_raw.dta file		  						
***********************************************************************
set graphics off
save "lcr_raw", replace


