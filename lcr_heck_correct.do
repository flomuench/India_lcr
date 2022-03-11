***********************************************************************
* 	data corrections - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent observations		  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		
* 	2) 		
*	3)   	
*	4)  	
*	5)  	
*	6)  	
*   7)      
*	8)		
*	9)		
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear



***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************



***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************


***********************************************************************
* 	PART 4:  Convert string to numerical varialcres	  			
***********************************************************************

***********************************************************************
* 	PART 5:  miscallaneous corrections
***********************************************************************

replace international = 0 if international == .

***********************************************************************
* 	PART 6:  replace all MV = 0 for firms that did never patent
***********************************************************************


***********************************************************************
* 	PART 7:  check for missing values
***********************************************************************
misstable sum, all

***********************************************************************
* 	PART 9:  Create id + identify duplicates
***********************************************************************
egen bid = group(auction company_name)
order bid, first

	* duplicates in terms of bid: company-auction pairs
duplicates report bid
duplicates tag bid, gen(dup_bid)

* --> duplicates report to firm bidding under same auction for different parts of the auction,e.g. one with dcr one w/o
	* or from several plants/parcels getting auctioned under the same scheme


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$lcr_intermediate"
save "lcr_bid_inter", replace
