***********************************************************************
* 		import cross_section data - the effect of LCR on innovation						
***********************************************************************
*																	   
*	PURPOSE: Import the data from SECI online archives about firms'
*	participation in LCR & no LCR auctions
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV										  
*	2)	save the contact list as dta file in intermediate folder
*																	 			
*
*	Author: Florian Muench, Fabian Scheifele
*	ID variable: company_name		  									  
*	Requires:	cross_section_new
*	Creates:	lcr_raw		  
*																	  
***********************************************************************
* 	PART 1: import collapsed bid data from SECI online archives
***********************************************************************
use "${lcr_raw}/cross_section_new", clear
sort company_name

***********************************************************************
* 	PART 2: save cross-section data as raw
***********************************************************************
save "${lcr_raw}/lcr_raw", replace
