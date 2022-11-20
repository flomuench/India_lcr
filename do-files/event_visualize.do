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

xtset company_name year
***********************************************************************
* 	PART 2: visualize solar patents
***********************************************************************
xtline solarpatent, overlay legend(off) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(5)25, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5))
	name(spatents_ts_lcr, replace)
	
	
	* separate for LCR and non-LCR group
xtline solarpatent, overlay legend(off) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(5)25, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5))

***********************************************************************
* 	PART 3: visualize revenue
***********************************************************************


***********************************************************************
* 	PART 4: visualize timing in LCR/treatment participation
***********************************************************************
	* excluding nsm first batch
		* times auctions won
panelview quantity_allocated_mw_lcr, i(company_name) t(year) type(treat) ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch II") ///
	legend(pos(6) row(1))
	
		* quantity won
panelview won_lcr, i(company_name) t(year) type(treat) ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch II") ///
	legend(pos(6) row(1))

	* include nsm first batch
panelview d_lcrwon_nsm_panel, i(company_name) t(year) type(treat) ///
	xtitle("Year") ytitle("Company") subtitle("NSM Batch I + II")



