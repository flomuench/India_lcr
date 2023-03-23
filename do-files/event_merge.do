***********************************************************************
* 			lcr India paper: create a balanced firm-year panel and test-pre trends					
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1) import auction panel
*	2) merge with patent panel
*	3) merge with sales & employees panel
*
*	Author: Florian, Fabian  														  
*	ID variable: company_name, year		  									  
*	Requires:	firmyear_patents, firmyear_auction, firm_sales, firm_employees
*	Creates:	event_study

***********************************************************************
* 	PART 1: import the auction panel data set		  						
* 	113 firms, 2013-2019, annual observations
***********************************************************************
use "${lcr_final}/firmyear_auction", clear


***********************************************************************
* 	PART 2: merge with patent panel data set
* 	27 firms, 2004-2020, annual observations
*	2 new variables (apart from ids)						
***********************************************************************
merge 1:1 company_name year using "${lcr_final}/firmyear_patents", keepusing(solarpatent not_solar_patent)
/* Results for confirmation for replication.
    Result                      Number of obs
    -----------------------------------------
    Not matched                           900
        from master                       616  (_merge==1)
        from using                        284  (_merge==2)

    Matched                               175  (_merge==3)
    -----------------------------------------

*/

drop _merge
***********************************************************************
* 	PART 3: merge with sales		
***********************************************************************
merge 1:1 company_name year using "${lcr_final}/lcr_sales_final"
drop _merge

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                           482
        from master                       341  (_merge==1)
        from using                        141  (_merge==2)

    Matched                               734  (_merge==3)
    -----------------------------------------

*/


***********************************************************************
* 	PART 4: merge with sales		
***********************************************************************
sort company_name year, stable
encode company_name, gen(company_name2)
xtset company_name2 year
tsfill, full
order company_name company_name2, first

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

***********************************************************************
* 	PART 5: save event study dataset	  						
***********************************************************************
save "${lcr_final}/event_study_raw", replace
