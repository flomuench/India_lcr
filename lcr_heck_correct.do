***********************************************************************
* 	data corrections - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent observations		  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)	set the stage	
* 	2) 	associate subsidiaries with mother firm for conglomerates	
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
* 	PART 1:  set the stage			
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear


***********************************************************************
* 	PART 2: associate subsidiaries with mother firm for conglomerates	  			
***********************************************************************
* avaada & welspun
replace company_name = "welspun" if company_name == "avaada"
replace company_name = "tata" if company_name == "welspun" /* https://www.crunchbase.com/organization/welspun-renewables-energy */
replace company_name = "acb" if company_name == "spectrum"
* https://eden-re.com/ --> JF EDF + Total
replace company_name = "canadian" if company_name == "rutherford"
*https://www.zaubacorp.com/company/RUTHERFORD-SOLARFARMS-PRIVATE-LIMITED/U74999DL2016FTC308971

***********************************************************************
* 	PART 3:  miscallaneous corrections
***********************************************************************
replace international = 0 if international == .

***********************************************************************
* 	PART 4:  replace all MV = 0 for firms that did never patent
***********************************************************************


***********************************************************************
* 	PART 5:  check for missing values
***********************************************************************
misstable sum, all

***********************************************************************
* 	PART 6:  Create id + identify duplicates
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
