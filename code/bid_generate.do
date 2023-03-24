***********************************************************************
* 		generate variables - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: generate relevant variables for analysis & visualisation				  							  
*																	  
*	OUTLINE:														  
*	1) import data
* 	2) create dummy for successful bid
* 	3) encode factor variables
*	4) create dummy for firm having participated in LCR auction
*	5) aggregate price variables (not only price per kwh)
*	6) dummy for bid related to a solar park
*   7) create dummy for Indian companies
*	8) create dummy for company HQ main city in India
*	9) create dummy for subsidiary
*	10) create dummy for subsidy (VGF)
*	11) generate cumulative mw won as measure of experience
*	12) competition as defined in Probst et al. 2020
*	13) create dummy for subsidiary
*	14) ihs-transformed sales
*	15) total MW won
*		      
*	Author:  	Florian Muench, Fabian Scheifele							  
*	ID variable: 
*		auction-level = auction
*		company-level = companyname_correct
*		bid-level	  = id			  					  
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  import the data  			
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear


***********************************************************************
* 	PART 2: create dummy for successful bid	  										  
***********************************************************************
tab has_won, gen(won)
tab won2
drop won1
drop has_won
rename won2 won

lab var won "firm's bid was successful"
lab def win 1 "bid won" 0 "bid lost"
lab val won win


***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
local vars city state subsidiary lob auction_type location lcr_content climate_zone scope technology plant_type plant_type_details grid_connected contractual_arrangement subsidy_level
foreach x of local vars  {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}
order city state subsidiary lob, a(employees)

***********************************************************************
*  PART 4: create dummy for firm having participated in LCR auction		  										  
***********************************************************************
rename lcr LCR
gen lcr = .
replace lcr = 1 if LCR == "true" /* note: we observe only 52 LCR bids in 11 different auctions but argue a proxy */
codebook auction if lcr == 1
replace lcr = 0 if LCR == "false" /* note: we observe 222 non LCR bids in 30 different auctions */
codebook auction if lcr == 0
drop LCR 

lab def local_content_auction 1 "LCR auction" 0 "auction without LCR"
lab val lcr local_content_auction

***********************************************************************
* 	PART 5: aggregate price variables (not only price per kwh)
***********************************************************************
		* price per mwh
gen price_mwh = 1000*final_price_after_era
label var price_mwh "price per mw hour"
order price_mwh, a(quantity_allocated_mw)

		* total plant price
gen total_plant_price = price_mwh * quantity_allocated_mw
label var total_plant_price "total plant price = price * peak performance in mwh"
order total_plant_price, a(price_mwh)

		* total plant price over contract length
gen total_plant_price_lifetime = total_plant_price*contractlength
label var total_plant_price_lifetime "total lifetime plant price for peak mwh"
order total_plant_price_lifetime, a(contractlength)

***********************************************************************
* 	PART 6: dummy for bid related to a solar park
***********************************************************************
gen solar_park = (solarpark != "")
drop solarpark
rename solar_park solarpark
lab var solarpark "bid related to a solar park"

***********************************************************************
* 	PART 7: create dummy for Indian companies
***********************************************************************
gen indian = (international < 1)
lab def national 1 "indian" 0 "international"
lab val indian national

***********************************************************************
* 	PART 8: create dummy for company HQ main city in India
***********************************************************************

gen hq_indian_state = .
replace hq_indian_state = 1 if state != .
local not_indian 5 11 19 9 6 16 15
foreach x of local not_indian  {
	replace hq_indian_state = 0 if state == `x'
}

	* dummy for delhi
gen capital = (city == 21)


***********************************************************************
* 	PART 9: create dummy for subsidiary 
***********************************************************************
gen sub = .
replace sub = 0 if subsidiary == 1
replace sub = 1 if subsidiary == 2

lab def subsi 1 "subsidiary" 0 "no subsidiary"
lab val sub subsi

drop subsidiary
rename sub subsidiary


***********************************************************************
* 	PART 10: create subsidy dummy (viability gap funding)
***********************************************************************
gen sub = .
replace sub = 0 if subsidy == "no specifications"
replace sub = 1 if subsidy == "vgf"

lab def subdy 1 "subsidy" 0 "no subsidy"
lab val sub subdy

drop subsidy
rename sub subsidy

***********************************************************************
* 	PART 11: generate cumulative mw won as measure of experience
***********************************************************************
bysort company_name (auction) : gen cum_mw = sum(quantity_allocated_mw)
ihstrans cum_mw
lab var cum_mw "ihs transformed cumulative mw won"
 
 
***********************************************************************
* 	PART 12: competition as defined in Probst et al. 2020
*********************************************************************** 
gen competition = quantity_allocated_mw / quantity_total
replace competition = log(competition) if competition != 0
lab var competition "Probst quantity competition"


***********************************************************************
* 	PART 13: expected revenue
***********************************************************************
gen expected_revenue = .
replace expected_revenue = final_epc_after_era + final_vgf_after_era if won == 1 & contractual_arrangement == 2
replace expected_revenue = final_price_after_era * 1000 * quantity_allocated_mw * contractlength * flh_single_axis + final_vgf_after_era if won == 1 & contractual_arrangement == 1
replace expected_revenue = 0 if won == 0

format expected_revenue %-20.2fc
lab var expected_revenue "expected total lifetime revenue for plant"

gen expected_annual_revenue = .
replace expected_annual_revenue = (final_epc_after_era + final_vgf_after_era)/contractlength if won == 1 & contractual_arrangement == 2
replace expected_annual_revenue = final_price_after_era * 1000 * quantity_allocated_mw * flh_single_axis + final_vgf_after_era if won == 1 & contractual_arrangement == 1
replace expected_annual_revenue = 0 if won == 0

format expected_annual_revenue %-20.2fc
lab var expected_annual_revenue "expected total lifetime revenue for plant"
 
***********************************************************************
* 	PART 14: inverse hyperbolic sine transformation of sales
***********************************************************************
ihstrans sales
 
***********************************************************************
* 	PART 15: total MW auctioned in all observed auctions
***********************************************************************
egen total_mw_all = sum(quantity_allocated_mw)
 
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* save dta file
save "${lcr_intermediate}/lcr_bid_inter", replace
