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
*	4 new variables (apart from ids)						
***********************************************************************
merge 1:1 company_name2 year using "${lcr_final}/firmyear_patents"
/* Results for confirmation for replication.
Result                      Number of obs
    -----------------------------------------
    Not matched                           872
        from master                       602  (_merge==1)
        from using                        270  (_merge==2)

    Matched                               189  (_merge==3)
    -----------------------------------------
*/

drop _merge
***********************************************************************
* 	PART 3: merge with sales		
***********************************************************************
merge 1:1 company_name2 year using "${lcr_final}/lcr_sales_final"
drop _merge

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           518
        from master                       352  (_merge==1)
        from using                        166  (_merge==2)

    Matched                               709  (_merge==3)
    -----------------------------------------
*/

sort company_name2 year, stable
xtset company_name2 year

***********************************************************************
* 	PART 4: save event study dataset	  						
***********************************************************************
save "${lcr_final}/event_study_raw", replace
