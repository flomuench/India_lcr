***********************************************************************
* 		size of the LCR demand shock - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: visualisize key variables for analysis				  							  
*																	  
*	OUTLINE:														  
*	1) size of demand shock in MW
* 	2) 
* 	3) 

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

*Change name of one firm for visualisation purposes
replace company_name = "odisha" if company_name == "development corporation odisha"
 
	* create additional variables needed for visualisation
	* quantity firm won in LCR
egen lcr_total_quantity_allocated = sum(quantity_allocated_mw) if lcr==1, by(company_name)
lab var lcr_total_quantity_allocated "mw per company in lcr"
	
	* quantity firm won in non-LCR
egen total_quantity_allocated = sum(quantity_allocated_mw) if lcr==0, by(company_name)
lab var total_quantity_allocated "mw per company in non-lcr"

egen lcr_min = min(lcr), by(company_name)
egen lcr_max = max(lcr), by(company_name)
bysort company_name: gen lcr_only = (lcr_min == 1 & lcr_max == 1)
bysort company_name: gen lcr_never = (lcr_min == 0 & lcr_max == 0)
bysort company_name: gen lcr_both = (lcr_min == 0 & lcr_max == 1)


***********************************************************************
* 	PART 1: size of demand shock in MW		
***********************************************************************
cd "$final_figures"

	* visualisation MW in LCR vs no LCR auctions
gr bar (sum) quantity_allocated_mw if auction_year < 2018, over(lcr)  ///
	blabel(total) ///
	ytitle("MW won") ///
	title("{bf:Size of demand shock LCR vs. no LCR auctions (2013-2017)}", size(small)) ///
	subtitle("MW allocated in LCR vs. no LCR auctions (2013-2017)", size(vsmall)) ///
	name(mw_lcr_nolcr, replace)
gr export mw_lcr_nolcr.png, replace

	* visualisation MW won per company in LCR
gr hbar (sum) quantity_allocated_mw if lcr == 1,  ///
	over(company_name, sort(company_name) descending lab(labs(vsmall))) ///
	blabel(total) ///
	ytitle("MW won") ///
	ylabel(0 100 200 300 400 500) ///
	title("LCR auctions (2013-2017)") ///
	name(mw_won_lcr, replace)

	* visualisation MW won per company in non-LCR
		* until 2017
gr hbar (sum) quantity_allocated_mw if lcr == 0 & auction_year < 2018 & lcr_both == 1 | lcr_only == 1, ///
	over(company_name, sort(company_name) descending lab(labs(vsmall))) ///
	blabel(total) ///
	ytitle("MW won") ///
	ylabel(0 100 200 300 400 500) ///
	title("Non-LCR auctions (2013-2017)") ///
	name(mw_won_nolcr17, replace)		
		* until 2019
gr hbar (sum) quantity_allocated_mw if lcr == 0 & lcr_both == 1 | lcr_only == 1, ///
	over(company_name, sort(lcr_total_quantity_allocated) descending lab(labs(vsmall))) ///
	blabel(total) ///
	ytitle("MW won") ///
	ylabel(0 100 200 300 400 500) ///
	title("Non-LCR auctions (2013-2019)") ///
	name(mw_won_nolcr19, replace)

	* combined graph
gr combine mw_won_lcr mw_won_nolcr17, ///
	title("{bf:Size of demand shock LCR vs. no LCR auctions}") ///
	subtitle("sample = firms that participated at least in one LCR auction",  size(vsmall)) ///
	name(mw_lcr_vs_no_lcr, replace)
gr export mw_lcr_vs_no_lcr.png, replace

*stacked bar chart

g lcr_quantity_allocated = quantity_allocated_mw if lcr == 1
g open_quantity_allocated = quantity_allocated_mw if lcr == 0 & /// 
	auction_year < 2018 & lcr_both == 1 | lcr_only == 1
*drop zeros by making them missing*
replace lcr_quantity_allocated =. if lcr_quantity_allocated == 0
replace open_quantity_allocated =. if open_quantity_allocated == 0

gr hbar (sum) lcr_quantity_allocated (sum) open_quantity_allocated if (open_quantity_allocated<. ) | (lcr_quantity_allocated<. ) , ///
	over(company_name, sort(2) descending lab(labs(small))) stack ///
	ytitle("MW won") ///
	ylabel(0 100 200 300 400 500) ///
	title("Share of LCR allocated vs. share of open auction among LCR participants") ///
	legend(order(1 "MW allocated via LCR auctions 2013 - 2017" 2 "MW allocated in open auctions 2013 - 2017") pos(6)) ///
	name(mw_won_stacked, replace)	
gr export mw_won_stacked.png, replace
			
***********************************************************************
* 	PART 2: size of demand shock in INR (USD)		
***********************************************************************
/*
- estimate the size of the demand shock that each company received
	- Option1: MW * intl. module price + 0.06 * intl module price
	- Option2: share of module price * bid price * MW
	
* note: in data there is final_price_after_era & final_bid_after_era; the former contains
	transformation for epc auctions while the latter sets them = 0
*/
gen bprice_mw = final_price_after_era * 1000 /* unit: INR per MW/h */
gen mprice_mw = bprice_mw * 0.42  
gen mdemand_shock = mprice_mw * quantity_allocated_mw /* total INR demand for modules */

	* visualisation worth INR of modules in LCR vs no LCR auctions
gr bar (sum) mdemand_shock if auction_year < 2018, over(lcr)  ///
	blabel(total) ///
	ytitle("INR") ///
	title("{bf:Size of demand shock LCR vs. no LCR auctions (2013-2017)}", size(small)) ///
	subtitle("Financial worth of modules demandeded in LCR vs. no LCR auctions (2013-2017)", size(vsmall)) ///
	name(inr_lcr_nolcr, replace)
gr export inr_lcr_nolcr.png, replace

	* visualisation worth INR of modules won won per company in LCR
gr hbar (sum) mdemand_shock if lcr == 1 & auction_year < 2018,  ///
	over(company_name, sort(company_name) descending lab(labs(vsmall))) ///
	blabel(total, format(%9.2fc)) ///
	ytitle("INR") ///
	ylabel(0(100000)100000) ///
	title("LCR auctions (2013-2017)") ///
	name(inr_won_lcr, replace)
	
	* visualisation worth INR of modules won per company in non LCR
		* until 2017
gr hbar (sum) mdemand_shock if lcr == 0 & auction_year < 2018 & lcr_both == 1 | lcr_only == 1, ///
	over(company_name, sort(company_name) descending lab(labs(vsmall))) ///
	blabel(total, format(%9.2fc)) ///
	ytitle("INR") ///
	ylabel(0(100000)100000) ///
	title("Non-LCR auctions (2013-2017)") ///
	name(inr_won_nolcr17, replace)
	
	* combined graph
gr combine inr_won_lcr inr_won_nolcr17, ///
	title("{bf:Size of demand shock LCR vs. no LCR auctions}") ///
	subtitle("Financial worth of modules demandeded in LCR vs. no LCR auctions (2013-2017)", size(vsmall)) ///	
	note("sample = firms that participated at least in one LCR auction",  size(vsmall)) ///
	name(inr_lcr_vs_no_lcr, replace)
gr export inr_lcr_vs_no_lcr.png, replace
