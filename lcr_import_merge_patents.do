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

drop if year_publication == . /* remove firms without patent */
drop id inventiontitle
rename companyname_correct company_name

***********************************************************************
* 	PART 2: identify duplicates & unique identifier						
***********************************************************************
		* search for duplicate patents
			* in terms of abstract (most detailed information we have)
order title abstract, a(applicantname)
format title abstract %-30s
duplicates report abstract /* 8307 unique values but also 141 dups */
duplicates tag abstract if abstract!="", gen(dup_abstract)
sort company_name abstract
*br if dup_abstract > 0

			* in terms of abstract & title
duplicates report abstract title /* only 12 observations, 6 pairs */
duplicates tag abstract title, gen(dup_abstit)
*br if dup_abstit > 0

			* drop those obs that seem to be real duplicates
drop if company_name == "bosch" & title == "COOLING APPLIANCE AND FAN ASSEMBLY THEREFOR" & applicationnumber == "1437/KOL/2010"
drop if company_name == "bosch" & title == "PNEUMATICALLY ADJUSTABLE CONTINUOUSLY VARIABLE TRANSMISSION" & applicationdatedv == "22/12/2017"
drop if company_name == "larsen" & title == "ELECTRONICALLY CONTROLLED UNDER VOLTAGE RELEASE DEVICE USED WITH CIRCUIT BREAKERS" & applicationnumber == "01188/MUM/2003"


***********************************************************************
* 	PART 3: merge with solar patents/ipc groups from Shubbak 2020 						
***********************************************************************
	* change format of abstract from strl (not possible for merger) to strmax = str2045
// Figure out longest length
gen len=length(abstract)
summ len
// Convert to a fixed-length string
recast str2045 abstract, force  // If the longest is less than 2045, use that number instead of 2045; 51 values changed

	* create a temporary firm patent file
preserve
drop if solarpatent == 1
save firmpatent_final, replace
restore

	* keep only solarpatents & save in seperate dta file
drop if solarpatent == 0
save firmpatentsolar, replace

	* import solarpatents data incl. ipc groups from Shubbak 2020
preserve
import delimited "${lcr_raw}/solar_patents_addinfo.csv", clear varn(1)
rename solarpatentx solarpatent
gen len=length(abstract)
recast str2045 abstract, force 
save solar_patents_addinfo, replace
restore

	* merge with firmsolarpatents
merge 1:1 applicantname abstract using solar_patents_addinfo, keepusing(company_name groups subgroups subsubgroups)
drop _merge
rename company_name companyname_correct
save firmpatentsolar, replace

	* merge firmsolarpatents to firmpatent_final
use firmpatent_final, clear
append using firmpatentsolar

save "firmpatent_final", replace

***********************************************************************
* 	PART 5: create a dummy for cell/module patents only (rather than solar patents)					
***********************************************************************
	* re-name some of the elements for better understanding
replace subgroups = "cells or panels" if subgroups == "Combinations of the groups above"
replace subgroups = "H02N6/00" if ipc == "H02N6/00"
replace subgroups = "common cell elements" if subgroups == "Common Elements"
replace group= "cells or panels" if subgroups == "cells or panels"
replace group = "H02N6/00" if subgroups == "H02N6/00"
replace subgroups = "Thin film technologies" if subgroups == "Thin-<U+FB01>lm Technologies"

	* eye-ball the data to get better understanding of patents in different IPC subgroups
format abstract %70s
*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Crystalline Silicon Cells"
	/* only Bharat, Bosch & Sunedision filed in crystalline silicon cells 
		Bharat filed already before 2013/start of LCR policy ; Sunedison patented exclusively in ingots
		The solar ingot is a raw material used for manufacturing solar cells. 
		The ingots form the first step in the manufacturing of the solar wafers which are used as a base for the manufacturing of solar panels.*/

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Roof Covering and Supporting Structures"
		
		
*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Testing after manufacturing"
	/* all 5 testing after manufacturing patents come from larsen and toubro */

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "cells or panels"
	/* Tata filed all its patents in this group; T */

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "common cell elements"

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Thin film technologies"
	/* almost all filed before LCR policy */

	
/* general impressio
apart from Bharat & Bosch, none of the patents relate to cell manufacturing but rather are
news way of installing/using solar PV cells or moodules to max. efficiency or adapt to 
a specific situation; there are also some patents that use solar PV in other applications, such as
electrical vehicles or  */
	
gen modcell_patent = .
	replace modcell_patent = 0 if solarpatent == 1
	replace modcell_patent = 1 if subgroups == "Crystalline Silicon Cells"
	replace modcell_patent = 1 if subgroups == "Multi-junction Cells"
	replace modcell_patent = 1 if subgroups == "Roof Covering and Supporting Structures"
	replace modcell_patent = 1 if subgroups == "cells or panels"
	replace modcell_patent = 1 if subgroups == "common cell elements"



***********************************************************************
* 	PART 6: over time evolution of patents 	  						
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
* 	PART 7: collapse the data on company-year-level						
***********************************************************************
	* check missing values for company/year
codebook company_name
codebook year_* /* 122 missing year values for both year of publication or application */
tab solarpatent if year_publication == . /* no solar patent are concerned */


	* collapse data to company-year panel
collapse (sum) solarpatent not_solar_patent onepatent modcell_patent, by(company_name year_application)

***********************************************************************
* 	PART 8: create pre-post period dummy					
***********************************************************************
	* collapse into pre-treatment period (1982-2012) or post-treatment period (2013-2020)
		* option 1: take whole pre-period == 30 years
gen post = (year_application > 2010 & year_application < .)
		* option 2: take same pre as post policy period == 8 years 
			* --> pre-historic period = 1982-2000; pre-period = 2001-2010; post-period = 2011-2020
gen post2 = .
	replace post2 = 1 if year_application <= 2000
	replace post2 = 2 if year_application > 2000 & year_application <= 2010
	replace post2 = 3 if year_application >=2011
	
	* check whether time periods are correctly divided
tab year_application if post == 1 /* 224 patents before treatment */
tab year_application if post == 0 /* 262 patents after after treatment */

***********************************************************************
* 	PART 9: create/collapse into pre-post solar patents	  						
***********************************************************************

collapse (sum) solarpatent not_solar_patent onepatent modcell_patent, by(company_name post2)
reshape wide solarpatent not_solar_patent onepatent modcell_patent, i(company_name) j(post2)
forvalues z = 1(1)3 {
	foreach x in solarpatent`z' not_solar_patent`z' onepatent`z' modcell_patent`z' {
		replace `x' = 0 if `x' == .
	}
}	
rename solarpatent1 historic_solar_patent
rename solarpatent2 pre_solar_patent
rename solarpatent3 post_solar_patent

rename not_solar_patent1 historic_not_solar_patent
rename not_solar_patent2 pre_not_solar_patent
rename not_solar_patent3 post_not_solar_patent

rename onepatent1 historic_total_patent
rename onepatent2 pre_total_patent
rename onepatent3 post_total_patent

rename modcell_patent1 historic_modcell_patent
rename modcell_patent2 pre_modcell_patent
rename modcell_patent3 post_modcell_patent

lab var historic_solar_patent "solar patents 1982-2000"
lab var pre_solar_patent "solar patents 2001-2010"
lab var post_solar_patent "solar patents 2011-2020"

lab var historic_not_solar_patent "non-solar patents 1982-2000"
lab var pre_not_solar_patent "non-solar patents 2005-2010"
lab var post_not_solar_patent "non-solar patents 2011-2020"

lab var historic_total_patent "total patents 1982-2000"
lab var pre_total_patent "total patents 2005-2010"
lab var post_total_patent "total patents 2011-2020"

lab var historic_modcell_patent "module & cell patents 1982-2000"
lab var pre_modcell_patent "module & cell patents 2005-2010"
lab var post_modcell_patent "module & cell patents 2011-2020"


***********************************************************************
* 	PART 10: save file of pre-post treatment in raw folder		  						
***********************************************************************
* change directory to raw
cd "$lcr_raw"
save "patents_pre_post", replace


**********************************************************************
* 	PART 11: merge cross-section lcr_raw.dta file with patents			  						
***********************************************************************
	* companyname_correct is the common unique identifier
	* import lcr_raw.dta
use "${lcr_raw}/lcr_raw", clear
merge m:1 company_name using patents_pre_post /* results should indicate 27 firms merged */
drop _merge

replace 

save "lcr_raw", replace

***********************************************************************
* 	PART 12: create descriptive statistics about patents in LCR vs. no LCR 						
***********************************************************************
	* import solar patents with information about IPC class of patent
use "solar_components_updated_HS", clear

	* merge information about firms auction participation
		* define common identifier
rename companyname_correct company_name
		* sort by identifier to facilitate merging
sort company_name
		* merge
merge m:1 company_name using lcr_raw, keepusing(won_no_lcr won_lcr quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr total_auctions_no_lcr total_auctions_lcr)
drop _merge

/*	* merge information about year of patent application
		* firmpatent: ipc, applicationnumber, applicationdatedv
rename company_name companyname_correct
rename ipcx ipc
merge 1:m companyname_correct ipc using firmpatent, keepusing(year_application fieldofinvention title abstract)
*/
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

			* gen LCR dummy
gen lcr = 0
replace lcr = 1 if total_auctions_lcr > 0 & total_auctions_lcr < .
lab def lcr_p 1 "firm participated in LCR" 0 "firm did not participate in LCR"
lab val lcr lcr_p

		* solar patents by LCR & ipc group
gr hbar (count) , over(ipcgroups, sort(1)) over(lcr) ///
	blabel(total) ///
	title("{bf:Solar patents by LCR participation & IPC group category}", size(small)) ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("number of patents") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipcgroup_lcr, replace)
gr export solarpatents_ipcgroup_lcr.png, replace

		* solar patents by ipc component
gr hbar (count) , over(ipcsubgroupscomponents, sort(1)) ///
	blabel(total) ///
	title("{bf:Solar patents by IPC component category}",size(small)) ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("number of patents") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipccomponent, replace)
gr export solarpatents_ipccomponent.png, replace

		* solar patents by LCR & by ipc component
gr hbar (count) , over(ipcsubgroupscomponents, sort(1) lab(labs(vsmall))) over(lcr, lab(labs(vsmall))) ///
	blabel(total) ///
	title("{bf:Solar patents by LCR participation & IPC component category}",size(small)) ///
	subtitle("filed by firms participating in SECI auctions", size(small)) ///
	ytitle("number of patents") ///
	note("Author's own calculation based on Indian patent office data.", size(vsmall)) ///
	name(solarpatents_ipccomponent_lcr, replace)
gr export solarpatents_ipccomponent_lcr.png, replace

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

***********************************************************************
* 	PART 13: merge with firm characteristics + avg, min, max patent level complexity for each firm		  						
***********************************************************************
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
* 	PART 14: 			* merge lob complexity		  						
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
* 	PART 15: replace the existing lcr_raw.dta file		  						
***********************************************************************
set graphics off
save "lcr_raw", replace


