***********************************************************************
* 			LCR India: collapse patent data into cross-section & panel
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
* 	1: merge with solar patents/ipc groups from Shubbak 2020
*
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: format changes for merger in two separate frames	  						
***********************************************************************
	* use firmpatents
use "${lcr_final}/firmpatent_final", clear


***********************************************************************
* 	PART 2: cross-section --> firm-level
***********************************************************************
	* create & change to new frame
frame copy default patent_cross_section, replace
frame change patent_cross_section


	* collapse patents on firm-level & time (historic, pre, post LCR)
collapse (sum) solarpatent not_solar_patent onepatent modcell_patent, by(company_name post2) // modcell_patent
reshape wide solarpatent not_solar_patent onepatent modcell_patent, i(company_name) j(post2) // modcell_patent
forvalues z = 1(1)3 {
	foreach x in solarpatent`z' not_solar_patent`z' onepatent`z'  modcell_patent`z' {  // modcell_patent`z'
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

save "${lcr_final}/patent_cross_section.dta", replace
frame change default

***********************************************************************
* 	PART 3: panel --> firm-year-level
***********************************************************************
frame copy default firmyear_patents, replace
frame change firmyear_patents

	* check missing values for company/year
codebook company_name
codebook year_* /* 122 missing year values for both year of publication or application */
tab solarpatent if year_publication == . /* no solar patent are concerned */


	* collapse data to company-year panel
collapse (sum) solarpatent not_solar_patent onepatent modcell_patent, by(company_name year_application) // modcell_patent
rename year_application year

	*Cut off all years before 2004
				* only 2 patents before 2005 (1982 and 2000)
drop if year<2004 // --> 99 solar patents remain

	* declare panel data
encode company_name, gen (company_name2)
order company_name2, first
sort company_name2 year, stable
xtset company_name2 year
tsfill, full

	* panel id string: expand company name string identifier into added years
		* carryforward
sort company_name2 year
bys company_name2 (year): carryforward company_name, gen(company_name3)
		* carryforward (backward)
gsort company_name2 -year
carryforward company_name3, gen(company_name4)
order company_name3 company_name4, a(company_name2)
drop company_name company_name3
rename company_name4 company_name

	*replace missing values of newly created firm-year instances with zero
*tsfill, full
local patents solarpatent not_solar_patent onepatent modcell_patent // modcell_patent
foreach var of local patents {
		replace `var' = 0 if `var' == .
	}
	
*drop and rename encoded variable for merging*
*decode company_name2, gen(company_name)


	* drop numerical panel id to avoid mismatch when merging
drop company_name2
	

save "$lcr_final/firmyear_patents", replace



