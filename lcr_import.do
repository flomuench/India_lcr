***********************************************************************
* 			import auction data - the effect of LCR on innovation						
***********************************************************************
*																	   
*	PURPOSE: Import the data from SECI online archives about firms' 					  								  
*	participation in LCR & no LCR auctions
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Florian Muench, Fabian Scheifele														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import SECI online archives data set
***********************************************************************
	* set directory to raw folder
cd "$lcr_raw"

	* old code
use "${lcr_raw}/cross_section", clear

	* excel
import excel "${lcr_raw}/combined_results.xlsx", firstrow clear


***********************************************************************
* 	PART 2: prepare for merger with firm-patent data set
***********************************************************************
	* drop variables that are not useful
drop A ID year year_dummy

	* rename variables
rename auction_date_from_title auction_year
destring auction_year, replace
lab var auction_year "auction date based on title"

	* format variables
		* 
format bidder companyname_correct %25s

	* order
order quantity_allocated_mw, a(quantity_wanted_mw)


	* create new variables
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

		* LCR dummy
rename lcr LCR
gen lcr = .
replace lcr = 1 if LCR == "TRUE" /* note: we observe only 52 LCR bids in 11 different auctions but argue a proxy */
codebook auction if lcr == 1
replace lcr = 0 if LCR == "FALSE" /* note: we observe 222 non LCR bids in 30 different auctions */
codebook auction if lcr == 0
drop LCR 

		* won auction dummy
tab has_won, gen(won)
tab won2
drop won1
rename won2 won

		*


	* label variables 
lab var lcr "local content requirement"
	
	* label variable values
lab def local_content_auction 1 "LCR auction" 0 "auction without LCR"
lab val lcr local_content_auction

* notes


***********************************************************************
* 	PART 3: over time evolution of bidding price  						
***********************************************************************
twoway scatter final_price_after_era auction_year

graph twoway (scatter final_price_after_era auction_date if lcr==1) (scatter final_price_after_era auction_date if lcr==0), ///
  legend(label(1 "lcr") label(2 "no lcr")) 

***********************************************************************
* 	PART 3: over time evolution of auctions  						
***********************************************************************
	* requires collapse to create statistics on auction level?

	* change directory to output folder for descriptive stats
cd "$lcr_descriptives"
set graphics on

egen auction_count = group(auction) 

	* number of LCR & no LCR auctions 
		* total

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
collapse (sum) one won quantity* total_plant_price total_plant_price_lifetime  lcr* ///
	(firstnm) bidder (mean) final_price_after_era, by(companyname_correct) 

rename one total_auctions
rename won total_won
rename lcr total_lcr
label var total_won "total times firm won SECI auction 2013-2019"
label var total_auctions "times firm participated in SECI auction 2013-2019" 
label var total_lcr "times firm participated in lcr auction 2013-2019"

save "cross_section_firms_auctions", replace


***********************************************************************
* 	PART 4: save list of lcrtered firms in lcrtration raw 			  						
***********************************************************************
save "lcr_raw", replace
