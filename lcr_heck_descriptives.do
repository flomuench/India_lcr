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
set scheme plotplain	
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
cd "$final_figures"
gr bar, over(won)  ///
	blabel(total, format(%9.1fc) pos(center) size(large)) ///
	by(lcr , ///
	note("Lost bids N = 178, won bids N = 146", size(small))) ///
	name(bid_results_lcr, replace)
gr export bid_results_lcr.png, replace


***********************************************************************
* 	PART 3: price in lcr vs price outside lcr					
***********************************************************************
	* 
cd "$lcr_descriptives"
gr bar final_price_after_era if contractual_arrangement == 1 & won == 1, over(lcr)

	* restrict sample to firms that bid in both LCR & non LCR
		* gen dummy for firms that participated in both LCR & non LCR auctions
egen lcr_min = min(lcr), by(company_name)
egen lcr_max = max(lcr), by(company_name)
bysort company_name: gen lcr_only = (lcr_min == 1 & lcr_max == 1)
bysort company_name: gen lcr_never = (lcr_min == 0 & lcr_max == 0)
bysort company_name: gen lcr_both = (lcr_min == 0 & lcr_max == 1)

codebook company_name if lcr_both == 1 /* 17 companies participated in both */

gr bar (mean) final_price_after_era if contractual_arrangement == 1 & lcr_both == 1 & final_price_after_era > 0, ///
	over(lcr, lab(labs(half_tiny))) over(auction_year) ///
	blabel(total, format(%9.2fc)) ///
	ytitle("average bid price, INR per kw/h") ///
	title("{bf:How did LCR participants bid in non-LCR auctions?}") ///
	subtitle("Sample = 17 firms that participated both in LCR & non-LCR auctions", size(small)) ///
	note("In total, the 17 firms participated in 39 LCR or non-LCR Built-Own-Operate auctions.", size(vsmall)) ///
	name(bid_price_lcr_nolcr, replace)
gr export bid_price_lcr_nolcr.png, replace

gr bar (mean) final_price_after_era if contractual_arrangement == 1 & lcr_both == 1 & won == 1, ///
	over(lcr, lab(labs(half_tiny))) over(auction_year) ///
	blabel(total, format(%9.2fc)) ///
	ytitle("average bid price, INR per kw/h") ///
	title("{bf:How did LCR participants bid in non-LCR auctions?}") ///
	subtitle("Sample = 17 firms that participated both in LCR & non-LCR auctions", size(small)) ///
	note("In total, the 17 firms participated in 39 LCR or non-LCR Built-Own-Operate auctions.", size(vsmall)) ///
	name(bid_price_lcr_nolcr, replace)
gr export bid_price_lcr_nolcr.png, replace	
	

*gr bar final_price_after_era if won == 1 & lcr_both == 1, over(lcr)
***********************************************************************
* 	PART 4: vgf in lcr vs price outside lcr					
***********************************************************************
gr bar (mean) final_vgf_after_era if contractual_arrangement == 1 & lcr_both == 1 & final_price_after_era > 0, ///
	over(lcr, lab(labs(half_tiny))) over(auction_year) ///
	blabel(total, format(%9.2fc)) ///
	ytitle("average bid price, INR per kw/h") ///
	title("{bf:How much Viability-Gap-Funding required LCR participants in non-LCR auctions?}") ///
	subtitle("Sample = 17 firms that participated both in LCR & non-LCR auctions", size(small)) ///
	note("In total, the 17 firms participated in 39 LCR or non-LCR Built-Own-Operate auctions.", size(vsmall)) ///
	name(vgf_lcr_nolcr, replace)
gr export vgf_lcr_nolcr.png, replace





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
local auction_characteristics n_competitors contractual_arrangement quantity_total scope solarpark location climate_zone technology plant_type maxprojectsize final_bid_after_era contractlength std_count_feb20 final_vgf_after_era
cd "$final_figures"
iebaltab `auction_characteristics', grpvar(lcr) save(baltab_auctions) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
			 
iebaltab `auction_characteristics', grpvar(lcr) savetex(baltab_auctions) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

***********************************************************************
* 	PART 3: evolution auctions over time						
***********************************************************************
cd "$lcr_descriptives"
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

	* auctions + MW allocated during treatment period by LCR

cd "$final_figures"
collapse one quantity_total , by(auction_year lcr)
reshape wide one quantity_total, i(auction_year) j(lcr)
rename auction_year year
lab var year "auction year"
rename one0 no_lcr_auction
lab var no_lcr_auction "number of no-LCR auctions"
rename one1 lcr_auction
lab var lcr_auction "number of LCR auctions"
rename quantity_total0 gw_no_lcr
lab var gw_no_lcr "GW auctioned no-LCR auctions"
rename quantity_total1 gw_lcr
lab var gw_lcr "GW auctioned LCR auctions"

foreach var in no_lcr_auction lcr_auction gw_no_lcr gw_lcr {
	replace `var' = 0 if `var' == .
	egen sum_`var' = sum(`var') if year < 2018
}

gr bar (asis) no_lcr_auction lcr_auction if year < 2018, over(year) ///
		blabel(total, format(%9.0g) size(vsmall)) ///
		subtitle("{bf:number of auctions}") ///
		legend(label(1 "no-LCR") label(2 "LCR")) ///
	name(tperiod_auctions, replace)
	
gr bar (asis) gw_no_lcr gw_lcr if year < 2018, over(year) ///
		blabel(total, format(%9.0g) size(vsmall)) ///
		legend(off) ///
		subtitle("{bf:GW auctioned}") ///
	name(tperiod_gw, replace)
	
/*gr c1leg tperiod_auctions tperiod_gw, ///
	title("Treatment period 2013-2017: LCR & no-LCR auctions") ///
	legendfrom(tperiod_auctions) ///
	rows(1) ycommon xcommon ///
	note("Note: In 11 LCR auctions 547 MW were auctioned, while 5.05 GW were auctioned in 17 no-LCR auctions.") ///
	name(treatmentperiod, replace)
gr export treatmentperiod.png, replace
*/


restore

cd "$lcr_descriptives"
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
/*gr bar (sum) auction_count quantity_allocated_mw, over(lcr, label(labs(small))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Number of bids & MW allocated}") ///
	subtitle("Solar auctions 2013-2020", size(small)) ///
	legend(label(1 "number of auctions") label(2 "MW allocated") rows(2) pos(6)) ///
	note("Authors own calculations based on data from SECI online archives.", size(vsmall)) ///
	name(auctions_mw_lcr, replace)
gr export auctions_mw_lcr.png, replace
	*/	
		* per year
gr bar (sum) lcr, over(auction_year, label(labs(small))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Annual solar patent applications in India: 1982-2021}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "Solar patents") label(2 "All other patents") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(patent_evolution, replace)
gr export patent_evolution.png, replace


***********************************************************************
* 	PART 4: create year-level dataset for auctions and patents					
***********************************************************************
gen no_bids = 1
lab var no_bids "# of bids per year"

*Somehow errors in collapse command when running from the start, but not when individually ran
collapse (sum) no_bids won quantity* total_plant_price  lcr ///
	(mean) final_price_after_era n_competitors, by(auction_year) 

rename auction_year year
cd "$lcr_final"	
save "year_level_data.dta", replace
	
*import firmpatent.dta, filter solar  and collapse on year-level
use "${lcr_raw}/firmpatent", clear
gen no_patents=1
lab var no_patents "# of patents per year"
collapse (sum) no_patents solarpatent , by (year_application)
drop if year_application ==.
rename year_application year
save "patents_annual", replace

*merge auction and patent year-level datasets
use "${lcr_final}/year_level_data", clear
merge 1:1 year using patents_annual 

gen quantity_allocated_gw = quantity_allocated_mw/1000
lab var quantity_allocated_gw "Quantity allocated in GW"

cd "$final_figures"
graph twoway (bar quantity_allocated_gw year if year >=2011 & year<=2019, color(gs0%30)) (bar solarpatent year if year >=2011 & year<=2019, color(gs11%50)) ///
	|| (line final_price_after_era year if year >=2011 & year<=2019, ///
	yaxis(2) ytitle("Average bid price in INR/MWh",axis(2)) lc(black)) (scatter final_price_after_era year if year >=2011 & year<=2019, mlabel(final_price_after_era) mlabpos(1) mcolor(black) mlabcolor(black) yaxis(2)), ///
	legend (pos(6) lab(1 "Auctioned-off capacity in GW") lab(2 "Solar patents") lab(3 "Average bid price")) ///
	ytitle("GW/ Patent applications",axis(1)) xtitle("")
gr export patent_auction_evolution.png, replace


*save year-level merged
set graphics off
cd "$lcr_final"
save "year_level_data.dta", replace

