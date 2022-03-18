***********************************************************************
* 		descriptive statistics - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: visualisize key variables for analysis				  							  
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
cd "$lcr_descriptives"

set graphics on
******************* bid-level statistics ******************************

***********************************************************************
* 	PART 1: over time evolution of bidding price  						
***********************************************************************
twoway scatter final_price_after_era auction_year

	* distribution of bid prices by year & lcr
graph twoway (scatter final_price_after_era auction_year if lcr==1) (scatter final_price_after_era auction_year if lcr==0), ///
  legend(label(1 "lcr") label(2 "no lcr")) ///
  xlabel(2012(1)2020) ///
  ylabel(0(1)15) ///
  ytitle("final price, INR/kwh") ///
  name(price_lcr_year, replace)
gr export price_lcr_year.png, replace

	* average bid price by year & lcr
gr bar (mean) final_price_after_era if auction != "2017bdl09", over(lcr, lab(labs(half_tiny))) over(auction_year) ///
	blabel(total, format(%9.2fc)) ///
	title("{bf:Evolution of mean bid price in LCR vs. no LCR auctions}") ///
	ytitle(" mean final price, INR/kwh") ///
	name(mean_price_lcr_year, replace)
gr export mean_price_lcr_year.png, replace
  
***********************************************************************
* 	PART 2: auctions won over total auctions					
***********************************************************************
	* winning vs. loosing bids pooled 
gr bar, over(won)  ///
	blabel(total, format(%9.1fc)) ///
	title("{bf:Overview of results from firm bids}") ///
	note("Lost bids N = 178, won bids N = 146", size(small)) ///
	name(bid_results, replace)
gr export bid_results.png, replace

	* winning vs. loosing bids lcr vs. no lcr
gr bar, over(won)  ///
	blabel(total, format(%9.1fc)) ///
	by(lcr , title("{bf:Overview of results from firm bids}") ///
	subtitle("LCR vs. no LCR bids") ///
	note("Lost bids N = 178, won bids N = 146", size(small))) ///
	name(bid_results_lcr, replace)
gr export bid_results_lcr.png, replace


***********************************************************************
* 	PART 3: price in lcr vs price outside lcr					
***********************************************************************
gr bar final_price_after_era if won == 1, over(lcr)

gr bar final_price_after_era if won == 1 & lcr_both == 1, over(lcr)



******************* auction-level statistics **************************
preserve
collapse (firstnm) n_competitors auction_year lcr contractual_arrangement quantity_total scope solarpark location climate_zone technology plant_type (min) maxprojectsize final_bid_after_era (mean) contractlength std_count_feb20 (sum) final_vgf_after_era, by(auction)
	* do some data cleaning for visualisation
lab var n_competitors "number of bidders"
lab var auction_year "year"
lab var contractual_arrangement "BOO+PPA vs. EPC+O&M"
lab var quantity_total "total MW auctioned"
lab var scope "international bidders invited"
lab var solarpark "projects in solar park"
lab var location "location in India"
lab var climate_zone "climate zone of plant location"
lab var technology "technology neutral"
lab var plant_type "ground-mounted, rooftop or floating plant"
lab var maxprojectsize "max. plant size"
lab var final_bid_after_era "final bid price, INR/kwh"
lab var contractlength "length of contract"
lab var std_count_feb20 "international quality standards"
lab var final_vgf_after_era "viability-gap-funding, INR"

lab val lcr local_content_auction

***********************************************************************
* 	PART 2: lcr vs. no lcr auction characteristics balance table						
***********************************************************************
local auction_characteristics n_competitors auction_year contractual_arrangement quantity_total scope solarpark location climate_zone technology plant_type maxprojectsize final_bid_after_era contractlength std_count_feb20 final_vgf_after_era
iebaltab `auction_characteristics', grpvar(lcr) save(baltab_auctions) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

***********************************************************************
* 	PART 3: evolution auctions over time						
***********************************************************************
gen one = 1
replace quantity_total = quantity_total / 1000
lab var quantity_total "total GB auctioned"
lab var one "number of auctions"
gr bar (sum) one quantity_total, over(auction_year) ///
	blabel(total, format(%9.0g) size(vsmall)) ///
	legend(rows(1) pos(6) label(1 "number of auctions") label(2 "GB auctioned")) ///
	title("{bf:Over time evolution of India's National Solar Mission}") ///
	subtitle("Number of auctions & total GB auctioned") ///
	note("Authors own calculations based on documents SECI online archives.", size(small)) ///
	name(auctions_evolution, replace)
gr export auctions_evolution.png, replace

gr bar (sum) one quantity_total, over(auction_year) over(lcr) ///
	blabel(total, format(%9.0g) size(vsmall)) ///
	legend(rows(1) pos(6) label(1 "number of auctions") label(2 "GB auctioned")) ///
	title("{bf:Over time evolution of India's National Solar Mission}") ///
	subtitle("Number of auctions & total GB auctioned LCR vs. no LCR auctions") ///
	note("Authors own calculations based on documents SECI online archives.", size(small)) ///
	name(auctions_evolution_lcr, replace)
gr export auctions_evolution_lcr.png, replace

gr bar (sum) one quantity_total n_competitors final_bid_after_era, over(auction_year)

gr bar (sum) one quantity_total n_competitors final_bid_after_era final_vgf_after_era, over(auction_year)

***********************************************************************
* 	PART 4: lcr & contractual arrangement 						
***********************************************************************
graph bar (count), over(lcr) over(contractual_arrangement) ///
		blabel(total)



***********************************************************************
* 	PART 3: over time evolution of auctions  						
***********************************************************************
gr bar (sum) auction_count quantity_allocated_mw, over(lcr, label(labs(small))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Number of bids & MW allocated}") ///
	subtitle("Solar auctions 2013-2020", size(small)) ///
	legend(label(1 "number of auctions") label(2 "MW allocated") rows(2) pos(6)) ///
	note("Authors own calculations based on data from SECI online archives.", size(vsmall)) ///
	name(auctions_mw_lcr, replace)
gr export auctions_mw_lcr.png, replace
		
		* per year
gr bar (sum) lcr, over(year, label(labs(small))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Annual solar patent applications in India: 1982-2021}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "Solar patents") label(2 "All other patents") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(patent_evolution, replace)
gr export patent_evolution.png, replace


***********************************************************************
* 	PART 4: collapse on firm level to create a cross-section 						
***********************************************************************
restore
collapse (sum) one won quantity* total_plant_price total_plant_price_lifetime  lcr* ///
	(firstnm) bidder (mean) final_price_after_era, by(companyname_correct) 

rename one total_auctions
rename won total_won
rename lcr total_lcr
label var total_won "total times firm won SECI auction 2013-2019"
label var total_auctions "times firm participated in SECI auction 2013-2019" 
label var total_lcr "times firm participated in lcr auction 2013-2019"

save "cross_section_firms_auctions", replace