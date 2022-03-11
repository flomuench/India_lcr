***********************************************************************
* 		generate variables - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: generate relevant variables for analysis & visualisation				  							  
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
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear


***********************************************************************
* 	PART 2: dummy for successful bid	  										  
***********************************************************************
tab has_won, gen(won)
tab won2
drop won1
rename won2 won

lab var won "firm's bid was successful"
lab def win 1 "bid won" 0 "bid lost"
lab val won win


***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
local vars city state subsidiary lob auction_type location lcr_content scope technology plant_type plant_type_details grid_connected contractual_arrangement subsidy_level
foreach x of local vars  {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x'
}
order city state subsidiary lob, a(employees)

/*
problem: implies having to relabel all the variables; can also be maintained as 1,2?
	* replace dummies with 0,1 instead of 1,2
foreach var in list contractual_arrangement {
	replace `var' = 0 if `var' == 1
	replace `var' = 1 if `var' == 2
}
*/

***********************************************************************
* 	PART 3: create dummy for firm having participated in LCR auction		  										  
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


/*
		* dummy for at least 1x LCR
gen lcr = (total_lcr > 0 & total_lcr <.), b(total_lcr)
label var lcr "participated (or not) in LCR auction"
lab def local_content 1 "participated in LCR" 0 "did not participate in LCR"
lab val lcr local_content

		* dummy for only LCR
gen lcr_only = (total_lcr == total_auctions) if total_auctions != . , a(total_lcr)
lab def just_lcr 1 "only participated in LCR" 0 "LCR & no LCR"
lab val lcr_only just_lcr
*/

***********************************************************************
* 	PART 4: aggregate price variables (not only price per kwh)
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
* 	PART 5: dummy for bid related to a solar park
***********************************************************************
gen solar_park = (solarpark != "")
drop solarpark
rename solar_park solarpark
lab var solarpark "bid related to a solar park"


***********************************************************************
* 	PART 6: create dummy for Indian companies
***********************************************************************
gen indian = (international < 1)
lab def national 1 "indian" 0 "international"
lab val indian national

***********************************************************************
* 	PART 7: create dummy for company HQ main city in India
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
* 	PART 8: subsidiary 
***********************************************************************
gen sub = .
replace sub = 0 if subsidiary == 1
replace sub = 1 if subsidiary == 2

lab def subsi 1 "subsidiary" 0 "no subsidiary"
lab val sub subsi

drop subsidiary
rename sub subsidiary

/*
to do in terms of data cleaning:
create a subsidy dummy
*/

***********************************************************************
* 	PART 9: subsidy dummy
***********************************************************************
gen sub = .
replace sub = 0 if subsidy == "no specifications"
replace sub = 1 if subsidy == "vgf"

lab def subdy 1 "subsidy" 0 "no subsidy"
lab val sub subdy

drop subsidy
rename sub subsidy

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_bid_final", replace
