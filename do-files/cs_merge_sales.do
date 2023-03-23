***********************************************************************
* 	Lcr India - import and merge with firm sales + employees data						
***********************************************************************
*																	   
*	PURPOSE: 	add firm sales & employees to cross-section			  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import pre-treatment firm sales and employees data										  
*	2)		merge firm sales and employees
*	3)		save as lcr_raw
*
*	Author: Florian Münch, Fabian Scheifele			  
*	ID variable: company_name
*	Requires:	firmpatent.dta, lcr_sales_final
*	Creates:	lcr_raw.dta					  
*																	  
***********************************************************************
* 	PART 1: import cross-section dta 	  						
***********************************************************************
use "${lcr_raw}/lcr_raw", clear

***********************************************************************
* 	PART 2: merge pre-treatment sales to firms				
***********************************************************************
merge 1:1 company_name using "${lcr_final}/firm_sales"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                            14
        from master                        14  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               113  (_merge==3)
    -----------------------------------------

*/
* all 14 firms stem from Ben Probst et al.; all firms from original raw Excel with sales and employees data are matched.
drop _merge

***********************************************************************
* 	PART 3: merge pre-treatment employees to firms				
***********************************************************************
merge 1:1 company_name using "${lcr_final}/firm_employees"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            14
        from master                        14  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               113  (_merge==3)
    -----------------------------------------
*/
drop _merge


***********************************************************************
* 	PART 4: save as lcr_raw.dta
***********************************************************************
save "${lcr_raw}/lcr_raw", replace
