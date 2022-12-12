***********************************************************************
* 			Cross section heterogeneity analysis									  	  
***********************************************************************
*																	    
*	PURPOSE: analysing which type of firms eventually filed solar patents
*	  
*	OUTLINE:														  
*
*
*																	  															      
*	Author:  	Fabian Scheifele							  
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*
*										  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
*cd "$lcr_rt"
cd "$lcr_rt"

***********************************************************************
* 	PART 2:  Which companies patent at all? 			
***********************************************************************
eststo logit_sector, r:logit solar_patentor lcr indian ihs_total_revenue ib4.sector , vce(robust)   
eststo logit_manuf, r:logit solar_patentor lcr  indian ihs_total_revenue manufacturer, vce(robust)  
eststo plogit_sector, r:logit post_solar_patentor lcr indian ihs_total_revenue ib4.sector, vce(robust)   
eststo plogit_manuf, r:logit post_solar_patentor lcr indian ihs_total_revenue manufacturer, vce(robust)  

local regressions logit_sector logit_manuf plogit_sector plogit_manuf
esttab `regressions' using "logit_patent_hetero.tex", replace ///
	mgroups("Solar patent (binary)" "Solar patent (binary, only post-2013)", ///
		pattern(1 0 1 0)) ///
	label ///
	b(3) ///
	se(3) ///
	drop(_cons) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	addnotes("Robust standard errors in parentheses." "Business services are baselevel of sector variable.") 
	
cd "$final_figures"	
graph hbar (sum) solarpatents, over (lcr, label(labs(vsmall))) over(sector, label(labs(vsmall))) blabel (bar) ///
	ytitle("Number of solar patents")
graph export solarpatents_sector.png, replace

graph hbar (count), over(lcr, label(labs(small))) over(sector, label(labs(small))) blabel(bar) ///
	ytitle("Number of firms")
graph export firms_frequency_sector.png, replace
	
	