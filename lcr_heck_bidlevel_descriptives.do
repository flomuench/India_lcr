***********************************************************************
* 			Bid-level descriptives - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: visualise statistics on bid-level or year-level
*																	  
*	OUTLINE:														  
*	1) 
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_bid_final.dta 	  								  
*	Creates:  lcr_bid_final.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_bid_final", clear

	* set the directory to descriptive statistics
cd "$lcr_descriptives"
set graphics on
		
		
		*solar patents over year over time and number of auctions per year*
gr bar (sum) solarpatents, over (auction_year)	
