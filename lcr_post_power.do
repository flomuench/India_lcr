***********************************************************************
* 			power size calculations - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: calculate how big an effect on patents it would have 		  							  
*	needed
*																	  
*	OUTLINE:														  

*
*																	  															      
*	Author:  	Florian Münch & Fabian Scheifele					  
*	ID variable: 	company_name			  					  
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
* 	PART 2:  recall main matching specification to get mean & SD		
***********************************************************************
psmatch2 lcr_won if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore)
bysort lcr: sum post_solar_patent
sum post_solar_patent [iweight=_weight] if lcr == 1
local ntreat = r(N)
local sdtreat = r(sd)
sum post_solar_patent [iweight=_weight] if lcr == 0
local ncontrol = r(N)
local meancontrol = r(mean)
local sdcontrol = r(sd)

power twomeans `meancontrol', n1(`ncontrol') n2(`ntreat') alpha(0.05) sd1(`sdcontrol') sd2(`sdtreat') power(0.8)
	* MDE = 1.89 ~ 2

	
	
***********************************************************************
* 	PART 3:  conditional on patenting, how much MW for one patent?		
***********************************************************************
gen mw_patent = quantity_allocated_mw_total/post_solar_patent
sum mw_patent
	* suggest 190 MW on average
br company_name mw_patent quantity_allocated_mw_lcr quantity_allocated_mw_total post_solar_patent


***********************************************************************
* 	PART 4:  how much MW did LCR firms win?		
***********************************************************************
sum quantity_allocated_mw_lcr if lcr == 1
	* suggest 16.5 MW on average, max. 67
sort quantity_allocated_mw_lcr
br company_name mw_patent quantity_allocated_mw_lcr quantity_allocated_mw_total post_solar_patent if lcr == 1


***********************************************************************
* 	PART 5:  what were the total additional costs to the government?		
***********************************************************************
* calculate either based on Ben or own calculations
	* requires also: 1000x for kwh to MW transformation
