***********************************************************************
* 	import bid data from auctions - the effect of LCR on innovation						
***********************************************************************
*																	   
*	PURPOSE: Import the data from SECI online archives about
*	firms' participation in auctions
*																	  
*	OUTLINE:														  
*	1)	import SECI online auction archives data set
*	2)	save in dta format
*				
*
*	Author: Florian Muench, Fabian Scheifele
*	ID variables: 
*		auction-level = auction
*		company-level = companyname_correct
*		bid-level	  = id			  									  
*	Requires: combined_results.xlsx
*	Creates: lcr_bid_raw.dta	  
*																	  
***********************************************************************
* 	PART 1: import SECI online auction archives data set
***********************************************************************
	* excel
import excel "${lcr_raw}/combined_results.xlsx", firstrow clear


***********************************************************************
* 	PART 2: save in dta format			  						
***********************************************************************
	* save 
save "${lcr_raw}/lcr_bid_raw", replace
