***********************************************************************
* collapse bid data to firm-year panel - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: collapse bid-auction-firm data to a firm-year panel for
*	staggered Did implementation
*
*	OUTLINE:														  
* 	1) collapse + reshape the data for firm-level characteristics
* 	2) conduct some data cleaning
*	3) add firm characteristics
*	4) fill the panel with the years in which firms did not participate in auctions
*		      
*	Author:  	Florian Münch, Fabian Scheifele							  
*	ID variable:
*		auction-level = auction
*		company-level = companyname_correct
*		bid-level	  = id 					  					  
*	Requires: lcr_bid_final.dta 	  								  
*	Creates:  firmyear_auction.dta, firm_characteristics.dta		                          
***********************************************************************
* 	PART 0:  import the data  			
***********************************************************************
use "${lcr_final}/lcr_bid_final", clear
sort auction company_name, stable 

***********************************************************************
* 	PART 1:  collapse + reshape the data for firm-level characteristics  			
***********************************************************************
collapse (sum) one won quantity* total_plant_price total_plant_price_lifetime final_vgf_after_era expected_*revenue ///
	 (mean) n_competitors final_price_after_era, by(auction_year lcr company_name)
	 
order company_name auction_year
sort company_name auction_year, stable
	 
rename total_plant_price_lifetime total_plant_price_life
local allvar expected_annual_revenue expected_revenue final_price_after_era final_vgf_after_era n_competitors one quantity_allocated_mw quantity_total quantity_wanted_mw total_plant_price total_plant_price_life won	

reshape wide `allvar', i(company_name auction_year) j(lcr)

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

label var won_total "total SECI auctions firm won"
label var total_auctions "times firm participated in SECI auction" 
label var total_auctions_lcr "No. of times participated in an LCR auction" 

local allvar expected_annual_revenue expected_revenue final_price_after_era final_vgf_after_era n_competitors total_auctions quantity_allocated_mw quantity_total quantity_wanted_mw total_plant_price total_plant_price_life won	
foreach var of local allvar {
	order `var'*, a(auction_year)
}

***********************************************************************
* 	PART 3:  add firm characteristics
***********************************************************************
merge m:1 company_name using "${lcr_final}/firm_characteristics"
drop _merge


***********************************************************************
* 	PART 4: fill the panel with the years in which firms did not participate in auctions
***********************************************************************
	* declare panel data (to be able to use tsfill)
encode company_name, gen(company_name2)
order company_name2, b(company_name)
xtset company_name2 auction_year

	*expand panel structure by filling in addtional year, where gaps
tsfill, full

	* expand company name string identifier into added years
		* carryforward
sort company_name2 auction_year, stable
bys company_name2 (auction_year): carryforward company_name, gen(company_name3)
		* carryforward (backward)
gsort company_name2 -auction_year
carryforward company_name3, gen(company_name4)
order company_name3 company_name4, a(company_name2)
drop company_name company_name3
rename company_name4 company_name

	
	
	*replace missing values with zeros for auction participation data
local auctions "won_no_lcr won_lcr won_total quantity_wanted_mw_no_lcr quantity_wanted_mw_lcr quantity_wanted_mw_total quantity_total_no_lcr quantity_total_lcr quantity_total_total quantity_allocated_mw_no_lcr quantity_allocated_mw_lcr quantity_allocated_mw_total total_auctions_no_lcr total_auctions_lcr total_auctions"
foreach var of local auctions {
		replace `var' = 0 if `var' == .
	}

	* replace missing values with stable, firm characteristics
		* first, turn all string variables into factor variables
local stable_strvars "webaddress city state lob ultimateparent subsidiary"
foreach var of local stable_strvars {
	encode `var', gen(`var'1)
	drop `var'
	rename `var'1 `var'
}


gen firm_operation_india = (dummy_firm_operation_india == "true"), a(dummy_firm_operation_india)
drop dummy_firm_operation_india
local stable_vars "lob ultimateparent subsidiary indian international soe_india manufacturer manufacturer_solar energy_focus part_jnnsm_1 webaddress city subsidiary state founded"
foreach var of local stable_vars {
	egen `var'1 = min(`var'), by(company_name2)
	drop `var'
	rename `var'1 `var'
}


* remove variables, which will be matched via employees & sales data
drop ihs_sales sales totalemployees empl totalemployees age


* create age_at_bid variable
gen age_at_bid = auction_year - founded, a(founded)
order founded age_at_bid, a(auction_year)
*br if age_at_bid < 0
codebook company_name2 if age_at_bid < 0 /* 24 firms participated in auctions before they were founded...obviously erroneous. requires correction. */


	* panel time id
rename auction_year year

	* panel unit id: drop numerical version to avoid mismatches when merging
drop company_name2

***********************************************************************
* 	PART 5: save firm-year panel data set
***********************************************************************
save "${lcr_final}/firmyear_auction", replace