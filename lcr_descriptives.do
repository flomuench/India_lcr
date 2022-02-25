***********************************************************************
* 			variable choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: visualise firms participation in auctions (explanatory side)			  							  
*	& innovation performance (outcome side), plus firm characteristics
*																	  
*	OUTLINE:														  
*	1) 
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

	* set the directory to descriptive statistics
cd "$lcr_descriptives"
set graphics on
	
***********************************************************************
* 	PART 1: descriptive statistics about pre-post (solar) patents 	  						
***********************************************************************
	* sample level statistics
	
	* define local for pre-post comparisons
local prepostsolar pre_solar_patent post_solar_patent
local prepostother pre_not_solar_patent post_not_solar_patent
local preposttotal pre_total_patents post_total_patents

	* pre-post solar and non solar patents
graph bar (sum)  `prepostsolar' `prepostother', ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar and non-solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") ///
	label(3 "non-solar patents 1982-2011") label(4 "non-solar patents 2012-2021") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_all, replace)
gr export prepost_all.png, replace

	* pre-post solar only
graph bar (sum)  `prepostsolar', ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_solar, replace)
gr export prepost_solar.png, replace

	* pre-post solar and non solar patents without outliers
graph bar (sum)  `prepostsolar' `prepostother' if patent_outliers == 0, ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar and non-solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") ///
	label(3 "non-solar patents 1982-2011") label(4 "non-solar patents 2012-2021") rows(2) pos(6)) ///
	note("Excludes 3 firms that are outliers in in terms of total patents & have only participated in 1 auctions." "Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_no_outlier, replace)
gr export prepost_no_outlier.png, replace

	* pre-post solar only without outliers
graph bar (sum)  `prepostsolar' if patent_outliers == 0, ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_no_outlier, replace)
gr export prepost_no_outlier.png, replace

	* firm level statistics


***********************************************************************
* 	PART 2: auction participation 	  						
***********************************************************************






set graphics off
