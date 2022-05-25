***********************************************************************
* 			lcr India paper: create a balanced firm-year panel and test-pre trends					
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import the collapsed firm-year dataset
*	2) 		transform to panel dataset and use tsfill to have balanced time periods
*	3)		merge company specific data
*	4) 		create event study dummies
*	5) 		Do event study regression without controls
*	6)		Do event study regression with controls
*																	 																      *
*	Author: Fabian  														  
*	ID variable: company_name		  									  
*	Requires:	firmyear_patents
*	Creates:	eventstudy_final

***********************************************************************
* 	PART 1: import the collapsed dataset		  						
***********************************************************************
cd "$lcr_final"

use "${lcr_final}/firmyear_patents", clear	

***********************************************************************
* 	PART 3: merging company data	  						
***********************************************************************
merge m:1 company_name using lcr_final, keepusing (company_name)
drop _merge
*replace application_year with 2004 for companies with zero patents
*to have at least one year so that tsfill works
replace year_application = 2004 if year_application==.
***********************************************************************
* 	PART 2: expand to have balanced panel		  						
***********************************************************************
*Cut off all years before 2004, as there are only 2 patents before 2005 (1982 and 2000)
drop if year_application<2004

encode company_name, gen (company_name2)
xtset company_name2 year_application
*expand panel structure by filling in addtional year, where gaps
tsfill, full

*replace missing values of newly created firm-year instances with zero
local patents solarpatent not_solar_patent onepatent modcell_patent
foreach var of local patents {
		replace `var' = 0 if `var' == .
	}
	
*drop and rename encoded variable for merging*
drop company_name
decode company_name2, gen (company_name)



***********************************************************************
* 	PART 4: creating event study dummies	  						
***********************************************************************
forvalues t = 2004 (1) 2020 {
gen t_`t' = 0
replace t_`t' = 1 if year_application == `t'
}


***********************************************************************
* 	PART 4: merge company information again, now to fully expanded dataset				
***********************************************************************
merge m:1 company_name using lcr_final


***********************************************************************
* 	PART 5: save event study dataset	  						
**********************************************************************
save event_study, replace
