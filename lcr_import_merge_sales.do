***********************************************************************
* 	lcr India paper: import and merge with firm sales + employees data						
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import pre-treatment firm sales and employees data										  
*	2)		merge
*
*	Author: Florian Münch, Fabian Scheifele			  
*	ID variable: company_name
*	Requires:	firmpatent.dta, lcr_sales_final
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import cross-section dta 	  						
***********************************************************************
use "${lcr_raw}/lcr_raw", clear

	* change folder direction to lcr_final to get sales_final & employees_final
cd "$lcr_final"

***********************************************************************
* 	PART 2: merge pre-treatment sales to firms				
***********************************************************************
merge 1:1 company_name using "firm_sales"


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
merge 1:1 company_name using "firm_employees"

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
* 	PART 3: save as new main lcr.dta
***********************************************************************
cd "$lcr_raw"
save "lcr_raw", replace
