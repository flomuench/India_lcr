***********************************************************************
* 			common support assessment - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: evaluate whether there is common support or positive 				  							  
*	density along the propensity score distribution  
*																	  
*	OUTLINE:														  

*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_intermediate}/lcr_final", clear

* psgraph
* MODEL ALCOHOL CONSUMPTION
logistic mbsmoke alcohol deadkids foreign rcs_* mhisp i.medu2 mmarried mrace i.prenatal

* LOG ODDS OF SMOKING
predict logodds, xb

* GET A SENSE OF .25 SD OF LINEAR PROPENSITY SCORE
summarize logodds
