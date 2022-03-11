***********************************************************************
* 		bid-level regressions - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: replicate Probst et al. 2020 heckman regression				  							  
*																	  
*	OUTLINE:														  
*	1) 
* 	2) 
* 	3) 
*	4) 
*	5) 
*	6) 
*   7) 
*	8) 
*	9) 
*
*																	  															      
*	Author:  	Florian Muench, Fabian Scheifele							  
*	ID varialcre: 			  					  
*	Requires: lcr_bid_final.dta 	  								  
*	Creates:  lcr_bid_final.dta			                          
*																	  
***********************************************************************
* 	PART 0:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_bid_final", clear

	* change directory to output folder for descriptive stats
cd "$lcr_rt"

/* to do
create cumulativ experience
create "competition" capacity bid in auctioned capacity

*/
***********************************************************************
* 	PART 1:    			
***********************************************************************
	* see Probst et al. 2020 p. 4 table 1 for first stage & table 2 p. 5 for second stage
	* 1st stage variables, LDR = DV: employees, soe, manufacturer, indian, indian * manufacturer, energy focus, part 1 JNNSM,
	* 2nd stage variables: price = DV: LCR, cumulative experience (MW), offtaker (SECI vs NTPC), log(competition), solar park, solar radiation state, time effects
heckman final_price_after_era solarpark flh_single_axis i.auction_year, select(lcr = ) twostep
	