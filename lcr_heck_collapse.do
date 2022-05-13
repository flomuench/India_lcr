***********************************************************************
* collapse bid data to firm cross-section - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: collapse bid-auction-firm data to firm cross sectin data				  							  
*	with aggregated values for participation in auctions 
*
*	OUTLINE:														  
*	1) 
* 	2) 
* 	3) 
*	4) 
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

	* change directory to final folder to save files resulting from collapse for merger
cd "$lcr_final"


***********************************************************************
* 	PART 1:  collapse + reshape the data  			
***********************************************************************
* variables to created on firms level
preserve 
	* decode factor variables to prevent deletion of value labels
foreach x in city state subsidiary lob  {
	decode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}
collapse (sum) final_vgf_after_era (max) empl totalemployees *sales founded age  (firstnm) sector bidder international dummy_firm_operation_india webaddress city state lob ultimateparent subsidiary indian soe_india manufacturer* energy_focus part_jnnsm_1, by(company_name)
save "firm_characteristics", replace
restore

* variables to be created by LCR vs. no LCR auctions
	* number of times bid, won total, in lcr, in non lcr
	* mw applied for & mw won in all auctions, in lcr auctions, in non lcr auctions
	* price: average bid price, average total life time,
	* expected revenue from plant: mw * contract length * flh
	* firm characteristics from mergent intellect
	* VGF
	* average competitors
collapse (sum) one won quantity* total_plant_price total_plant_price_lifetime final_vgf_after_era expected_*revenue ///
	 (mean) n_competitors final_price_after_era, by(company_name lcr) 

	* bring from long format with two obs per firms (one in LCR & one in no LCR) to wide
rename total_plant_price_lifetime total_plant_price_life
local allvar expected_annual_revenue expected_revenue final_price_after_era final_vgf_after_era n_competitors one quantity_allocated_mw quantity_total quantity_wanted_mw total_plant_price total_plant_price_life won	
reshape wide `allvar', i(company_name) j(lcr)

foreach var of local allvar {
	rename `var'0 `var'_no_lcr
	rename `var'1 `var'_lcr
	replace `var'_lcr = 0 if `var'_lcr == .
	replace `var'_no_lcr = 0 if `var'_no_lcr == .
	gen `var'_total = `var'_lcr + `var'_no_lcr 

}
	
***********************************************************************
* 	PART 2:  conduct some data cleaning
***********************************************************************

rename one_total total_auctions
rename one_lcr total_auctions_lcr
rename one_no_lcr total_auctions_no_lcr

label var won_total "total SECI auctions firm won 2013-2019"
label var total_auctions "times firm participated in SECI auction 2013-2019" 

local allvar expected_annual_revenue expected_revenue final_price_after_era final_vgf_after_era n_competitors total_auctions quantity_allocated_mw quantity_total quantity_wanted_mw total_plant_price total_plant_price_life won	
foreach var of local allvar {
	order `var'*, a(company_name)
}

***********************************************************************
* 	PART 3:  add firm characteristics
***********************************************************************
merge 1:1 company_name using firm_characteristics
drop _merge


***********************************************************************
* 	PART 4: Export Excel with variables for manual search to reduce missing values
***********************************************************************
/*
cd "$lcr_intermediate"
export excel company_name bidder ultimateparent city state lob webaddress founded manufacturer totalemployees subsidiary using missing.xlsx if founded == . | manufacturer == . | totalemployees == . , firstrow(var) replace
*/

***********************************************************************
* 	PART 5: save cross-section data as raw
***********************************************************************
	* set directory to raw folder
cd "$lcr_raw"
	* save as cross_section_new to allow comparison with first cross-section file
save "cross_section_new", replace
