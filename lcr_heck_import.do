***********************************************************************
* 	import bid data from auctions - the effect of LCR on innovation						
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
* 	PART 1: import SECI online archives data set
***********************************************************************
	* excel
import excel "${lcr_raw}/combined_results.xlsx", firstrow clear


***********************************************************************
* 	PART 2: save list of lcrtered firms in lcrtration raw 			  						
***********************************************************************
	* save 
save "${lcr_raw}/lcr_bid_raw", replace
