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
create SOE
*/
***********************************************************************
* 	PART 1:    			
***********************************************************************
	* see Probst et al. 2020 p. 4 table 1 for first stage & table 2 p. 5 for second stage
	* 1st stage variables, LDR = DV: employees, soe, manufacturer, indian, indian * manufacturer, energy focus, part 1 JNNSM,
	* 2nd stage variables: price = DV: LCR, cumulative experience (MW), offtaker (SECI vs NTPC), log(competition), solar park, solar radiation state, time effects
gen log_comp = log(competition)
heckman final_price_after_era cum_mw competition i.solarpark i.flh_single_axis i.auction_year, select(lcr = totalemployees soe_india i.indian##i.manufacturer energy_focus) twostep
	
	
	* add additional explanatory variables & see whether price gap remains
		* module_price_inr_per_w
		* competition as number of bidders (unobserved given newspaper articles only report winners)
		* climate_zone
		* scope of the auction: domestic vs. global
		* subsidy/VGF
		
	* sample: restrict to ground-mounted plants &/or boo
