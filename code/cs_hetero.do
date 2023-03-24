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
cd "$lcr_rt"

***********************************************************************
* 	PART 2:  Which companies patent at all? 			
***********************************************************************
eststo logit_sector, r:logit solar_patentor lcr indian ihs_total_revenue age total_employees ib4.sector , vce(robust)   
eststo logit_manuf, r:logit solar_patentor lcr  indian ihs_total_revenue age total_employees manufacturer, vce(robust)  
eststo plogit_sector, r:logit post_solar_patentor lcr indian ihs_total_revenue age total_employees ib4.sector, vce(robust)   
eststo plogit_manuf, r:logit post_solar_patentor lcr indian ihs_total_revenue age total_employees manufacturer, vce(robust)  

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

***********************************************************************
* 	PART 3:  Probability of winning open vs closed LCR			
***********************************************************************	
	use "${lcr_final}/lcr_bid_final", clear

	* set the directory to regressions table folder
cd "$lcr_rt"

lab var n_competitors "No. of bidders"
lab var quantity_wanted_mw "Desired quantity in MW"
lab var lcr "LCR auction"
lab var indian "Firm of Indian origin"
label define auction_types 1 "Build-own-operate" 2 "Engineering, Procurement, Construction"
label value auction_type auction_types

eststo lpm_winning1, r: reg won lcr, vce(robust)
eststo lpm_winning2, r: reg won lcr n_competitors quantity_wanted_mw  solarpark age indian ///
		 i.auction_type, vce(robust)
eststo logit_winning, r: logit won lcr n_competitors quantity_wanted_mw solarpark age indian ///
		 i.auction_type, vce(robust)
margins, dydx(*) post
eststo logit_winning2		 
eststo probit_winning, r: probit won lcr n_competitors quantity_wanted_mw solarpark age indian ///
		 i.auction_type, vce(robust)
margins, dydx(*) post 		 
eststo probit_winning2

esttab lpm_winning1 lpm_winning2 logit_winning2 probit_winning2  using "logit_bid_winning.tex", replace ///
	mtitles("LPM" "LPM" "Logit" "Probit") ///
	label ///
	b(3) ///
	se(3) ///
	drop(_cons) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	addnotes("Robust standard errors in parentheses." ///
	"For Model (3) and (4) coefficients denote the marginal effects.") 
	
