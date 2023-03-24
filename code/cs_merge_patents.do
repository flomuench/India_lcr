***********************************************************************
* 			LCR India: merge cross-section with patents
***********************************************************************
*																	   
*	PURPOSE: add (solar) patents to cross-section data set	  								  
*				  
*																	  
*	OUTLINE:														  
* 	1: merge with solar patents/ipc groups from Shubbak 2020
*	2: save as lcr raw
*
*	Author: Florian Münch, Fabian Scheifele													  
*	ID variable: company_name			  									  
*	Requires:	lcr_raw.dta, patent_cross_section.dta
*	Creates:	lcr_raw.dta					  
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

***********************************************************************
* 	PART 2: save as lcr raw
***********************************************************************
save "${lcr_raw}/lcr_raw", replace