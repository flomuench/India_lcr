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
*																	 																      *
*	Author: Florian Muench, Fabian Scheifele														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import collapsed bid data from SECI online archives
***********************************************************************
	* set directory to raw folder
cd "$lcr_raw"

	* old code
use "${lcr_raw}/cross_section_new", clear
sort company_name

***********************************************************************
* 	PART 2: save cross-section data as raw
***********************************************************************
save "lcr_raw", replace
