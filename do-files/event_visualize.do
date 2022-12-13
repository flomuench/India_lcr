***********************************************************************
* 			lcr India paper: visualize staggered Did, outcomes
***********************************************************************														  
*	PURPOSE: visualize t			  								  
*				  
*																	  
*	OUTLINE:														  
*	Author: Florian, Fabian  														  
*	ID variable: company_name, year	  									  
*	Requires:	event_study_final

***********************************************************************
* 	PART 1: import panel data set					
***********************************************************************
use "${lcr_final}/event_study_final", clear

set graphics on

xtset company_name year
***********************************************************************
* 	PART 2: visualize solar patents
***********************************************************************
* xtline

xtline solarpatent, overlay legend(off) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(1)6, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	name(spatents_ts_lcr, replace)
	
	
	* separate for LCR and non-LCR group
xtline solarpatent, overlay legend(off) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(1)6, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5))

* panelview
panelview solarpatent d_winner, i(company_name) t(year) type(outcome) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xtitle("Year") ytitle("Solar Patents") title("") ///
	xline(2011 2013 2017) ///
	ylabel(0(1)6, nogrid) ///
	ytitle("solar patents") ///
	text(6 2010 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2014 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	legend(all pos(6) row(1)) ///
	name(panelview_patents_winner_b2, replace)
gr export "${lcr_descriptives}/panelview_patents_winner_b2.png", replace

	
***********************************************************************
* 	PART 3: visualize revenue
***********************************************************************
* panelview
panelview ihs_total_revenue d_winner, i(company_name) t(year) type(outcome) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xtitle("Year") ytitle("ihs. total revenue") title("") ///
	xline(2011 2013 2017) ///
	ylabel(0(1)10, nogrid) ///
	ytitle("solar patents") ///
	text(15 2010 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2014 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	legend(all pos(6) row(1)) ///
	name(panelview_revenue_winner_b2, replace)
gr export "${lcr_descriptives}/panelview_revenue_winner_b2.png", replace

*Visualise revenue by LCR winners and open winners over time
frame put ihs_total_revenue total_revenue year lcr_winner, into(revenue_frame)
frame change revenue_frame
collapse ihs_total_revenue total_revenue, by(year lcr_winner)

twoway ///
	(line  ihs_total_revenue year if lcr_winner == 1) ///
	(line  ihs_total_revenue year if lcr_winner == 0), legend(pos(6))

twoway ///
	(line  total_revenue year if lcr_winner == 1 & year>2009) ///
	(line  total_revenue year if lcr_winner == 0 & year>2009), legend(order(1 "LCR" 0 "Open"))
frame change default
frame drop revenue_frame
***********************************************************************
* 	PART 4: visualize timing in LCR/treatment participation
***********************************************************************
decode company_name, gen(company_name_str)
	
*** excluding nsm first batch
		* times auctions won
panelview won_lcr, i(company_name) t(year) type(treat) bytiming mycolor(lean) ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch II (times won)") ///
	legend(order (1 "never won" 2 "one auction won" 3 "two auctions won" 4 "three auctions won") pos(6) row(2)) ///
	name(panel_auctions_won_b2, replace)
gr export "${lcr_descriptives}/panel_auctions_won_b2.png", replace
	
		* quantity won
			* for some reason, the command does not show some leves of outcome, e.g. 2 and 5 MW (is allocated to zero group?) I double checked that variable does not have missing values for 2014 and 2015. Command states "too many levels"
panelview quantity_allocated_mw_lcr, i(company_name_str) t(year) type(treat)  mycolor(lean) continuoustreat /// discreteoutcome, displayall
	xtitle("Year") ytitle("Company") subtitle("NSM Batch II (mw won)") ///
legend(pos(6) row(2)) ///
	ylabdist(3) ///
	name(panel_mw_won_b2, replace)
gr export "${lcr_descriptives}/panel_mw_won_b2.png", replace


		* lcr vs. open auction winner
panelview d_winner, i(company_name_str) t(year) type(treat) prepost bytiming ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch II (mw)") ///
	legend(pos(6) row(1)) ///
	ylabdist(1) ///
	name(panel_dwon_b2, replace)
	
*** include nsm first batch
		* times auction won
panelview d_lcrwon_nsm_panel, i(company_name_str) t(year) type(treat) prepost bytiming ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch I + II") ///
	legend(pos(6) row(1)) ///
	ylabdist(1) ///
	name(panel_auctions_won_b1, replace)
gr export "${lcr_descriptives}/panel_auctions_won_b1.png", replace
	
	
	
/*
firmyear_auction.dta
tab year if won_lcr > 0
    year of |
    auction |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |         16       61.54       61.54
       2014 |          1        3.85       65.38
       2015 |          2        7.69       73.08
       2016 |          6       23.08       96.15
       2017 |          1        3.85      100.00
------------+-----------------------------------
      Total |         26      100.00



*/



drop company_name_str

set graphics off