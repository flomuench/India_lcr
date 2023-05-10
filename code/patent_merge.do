***********************************************************************
* 			LCR India: merge patent data sets
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
use "${lcr_intermediate}/firmpatent_inter", clear


	* merge with solarpatents ipc groups
merge m:1 applicationnumber using "${lcr_intermediate}/solarpatents", keepusing(groups subgroups subsubgroups)

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         8,345
        from master                     8,345  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               100  (_merge==3)
    -----------------------------------------
*/

drop _merge

***********************************************************************
* 	PART 2: save in inter
***********************************************************************
save "${lcr_intermediate}/firmpatent_inter", replace
