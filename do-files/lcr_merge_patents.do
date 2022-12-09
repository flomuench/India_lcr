***********************************************************************
* 			LCR India: merge cross-section with patents
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
* 	PART 1: merge cross-section main file with cross-section patent data					
***********************************************************************
	* use cross-section file
use "${lcr_raw}/lcr_raw", clear

	* merge
merge m:1 company_name using "${lcr_final}/patent_cross_section.dta"
drop if _merge == 2 
drop _merge

	* save
save "${lcr_raw}/lcr_raw", replace