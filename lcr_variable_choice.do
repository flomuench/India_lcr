***********************************************************************
* 			variable choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: identify the variables 			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) sector
*
*																	  															      
*	Author:  	Florian Muench							  
*	ID varialcre: 	company_name		  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_psm"

***********************************************************************
* 	PART 1: run  			
***********************************************************************
	* include variables that simultaneously
		*1: influence LCR participation choice
			* Indian company, Indian city or state as HQ
			* total auction participation
		*2: propensity to file solar patent (outcome)
			* ever patented other patent
			* other, non solar patents
			* size of company: sales & employees
			* level of economic complexity of company lob
			* lob
			* subsidiary
	* significance method:
		* (1-3) indian
_eststo indian, r: logit lcr i.indian if patent_outlier == 0, vce(robust)
_eststo india_state, r: logit lcr i.hq_indian_state if patent_outlier == 0, vce(robust)
_eststo india_capital, r: logit lcr i.capital if patent_outlier == 0, vce(robust)

		* (4) total auction participation
*_eststo auctions, r: logit lcr total_auctions if patent_outlier == 0, vce(robust)

		* (4) total won
_eststo auctions, r: logit lcr total_won if patent_outlier == 0, vce(robust)

/* note: total auctions participated & total_won are highly correlated 0.85 */

		* (5) ever patented non solar patents
_eststo patentor, r: logit lcr total_won i.patentor if patent_outlier == 0, vce(robust)
		
		* (6) amount of other patents
_eststo otherprepatents, r: logit lcr total_won pre_not_solar_patent if patent_outlier == 0, vce(robust)

		* (7) size
_eststo size, r: logit lcr total_won sales employees if patent_outlier == 0, vce(robust)

		* (8) plant price
_eststo size, r: logit lcr total_won total_plant_price_lifetime if patent_outlier == 0, vce(robust)

		* (9) complexity
_eststo complexity, r: logit lcr total_won  total_plant_price_lifetime lob_pc_avg if patent_outlier == 0, vce(robust)
	
		* (10) lob
_eststo lob, r: logit lcr total_won total_plant_price_lifetime lob_pc_avg lob1 if patent_outlier == 0, vce(robust)

		* (11) all
_eststo all, r: logit lcr i.capital total_won total_plant_price_lifetime i.patentor pre_not_solar_patent employees sales lob_pc_avg lob1 if patent_outlier == 0, vce(robust)


local regressions indian india_state india_capital auctions patentor otherprepatents size complexity lob all
esttab `regressions' using variable_choice.csv, replace ///
	title("Selection of variables used for PSM") ///
	mtitles("Indian" "HQ Indian state" "HQ in Delhi" "Auction won" "Patentor" "Pre-patents" "Size" "Plant price" "Complexity" "Main business" "All") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
	

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
