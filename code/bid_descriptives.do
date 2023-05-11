***********************************************************************
* 		LCR India: auction-level descriptive figures 
***********************************************************************
*																	    
*	PURPOSE: visualisize descriptives figures from paper
*																	  
*	OUTLINE:														  
*	1)		Collapse on auction level
* 	2) 		Table 1: Auction balance table lcr vs. no lcr
* 	3) 		Merge patents to auctions
*	4) 		Figure 10: Quantity allocated, patents, and price
*	5)		Figure 2: Evolution of solar patents over time
*
*	Author:  	Florian Muench, Fabian Scheifele							  
*	ID variables:
*		auction-level = auction
*		company-level = companyname_correct
*		bid-level	  = id 			  					  
*	Requires: lcr_bid_final.dta 	  								  
*	Creates:  lcr_bid_final.dta			                          
*																	  
***********************************************************************
* 	PART 0:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_bid_final", clear

	* change directory to output folder for descriptive stats
cd "$lcr_descriptives"

	* set scheme
set scheme plotplain	
set graphics on


***********************************************************************
* 	PART 1:  Collapse on auction level
***********************************************************************
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
* 	PART 2: Table 1: auction balance table lcr vs. no lcr
***********************************************************************
local auction_characteristics n_competitors /* contractual_arrangement */ quantity_total scope solarpark location climate_zone technology plant_type maxprojectsize final_bid_after_era contractlength std_count_feb20 final_vgf_after_era
cd "$final_figures"
		* Excel
iebaltab `auction_characteristics', grpvar(lcr) save(baltab_auctions) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
		* Tex
iebaltab `auction_characteristics', grpvar(lcr) savetex(baltab_auctions) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
restore


***********************************************************************
* 	PART 3: merge patents to auctions					
***********************************************************************
gen no_bids = 1
lab var no_bids "# of bids per year"

gen final_bid_price_lcr = final_bid_after_era if lcr == 1
lab var final_bid_price_lcr "bid price LCR"
gen final_bid_price_open = final_bid_after_era if lcr == 0
lab var final_bid_price_open "bid price open auctions"


*Somehow errors in collapse command when running from the start, but not when individually ran
collapse (sum) no_bids won quantity* total_plant_price  lcr ///
	(mean) n_competitors ///
	final_bid_after_era final_bid_price_lcr final_bid_price_open, by(auction_year) 

rename auction_year year
save "${lcr_final}/year_level_data.dta", replace
	
*import firmpatent.dta, filter solar  and collapse on year-level
use "${lcr_raw}/firmpatent", clear
gen no_patents=1
lab var no_patents "# of patents per year"
collapse (sum) no_patents solarpatent , by (year_application)
drop if year_application ==.
rename year_application year
save "${lcr_final}/patents_annual", replace

*merge auction and patent year-level datasets
use "${lcr_final}/year_level_data", clear
merge 1:1 year using "${lcr_final}/patents_annual"

gen quantity_allocated_gw = quantity_allocated_mw/1000
lab var quantity_allocated_gw "Quantity allocated in GW"

tsset year
set scheme cleanplots
lab var final_bid_after_era "Mean annual bid price INR/MWh"
lab var solarpatent "Sum annual solar patents"
lab var year "Year"

***********************************************************************
* 	PART 4: Figure 2: Evolution of solar patents over time
***********************************************************************
tsline solarpatent if year >= 2005, ///
	legend(pos(6) row(1)) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(5)25, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	name(spatents_ts, replace)
gr export "${final_figures}/spatents_ts.png", replace


***********************************************************************
* 	PART 5:  Figure 10: Quantity allocated, patents, and price
***********************************************************************
graph twoway (bar quantity_allocated_gw year if year >=2011 & year<=2019, color(gs0%30)) (bar solarpatent year if year >=2011 & year<=2019, color(gs11%50)) ///
	|| (line final_bid_after_era year if year >=2011 & year<=2019, ///
	yaxis(2) ytitle("Average bid price in INR/MWh",axis(2)) lc(black)) (scatter final_bid_after_era year if year >=2011 & year<=2019, mlabel(final_bid_after_era) mlabpos(1) mcolor(black) mlabcolor(black) yaxis(2)), ///
	legend (pos(6) lab(1 "Auctioned-off capacity in GW") lab(2 "Solar patents") lab(3 "Average bid price")) ///
	ytitle("GW/ Patent applications",axis(1)) xtitle("")
gr export "${final_figures}/patent_auction_evolution.png", replace

