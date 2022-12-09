***********************************************************************
* 			LCR India: visualize variables in patent data sets
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
* 	1: merge with solar patents/ipc groups from Shubbak 2020
*
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: format changes for merger in two separate frames	  						
***********************************************************************
	* use firmpatents
use "${lcr_final}/firmpatent_final", clear


***********************************************************************
* 	PART 2: over time evolution of patents 	  						
***********************************************************************
	* change directory to output folder for descriptive stats
cd "$lcr_descriptives"

set graphics on
sort year_application
graph bar (sum) solarpatent not_solar_patent, over(year_application, label(labs(tiny))) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Annual solar patent applications in India: 1982-2020}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "Solar patents") label(2 "All other patents") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(patent_evolution, replace)
gr export patent_evolution.png, replace


graph bar (sum) solarpatent, over(year_application, label(labs(tiny))) over(lcr_participation) ///
	blabel(total, size(vsmall)) ///
	title("{bf:Annual solar patent applications in India: 1982-2020}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "Solar patents") label(2 "All other patents") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(patent_evolution_lcr, replace)

frame copy default solar_patent_time_series, replace
frame change solar_patent_time_series

collapse (sum) solarpatent, by (year_application lcr_participation)
reshape wide solarpatent, i(year) j(lcr_participation)
drop if year_application == .
replace solarpatent0 = 0 if solarpatent0 == .
replace solarpatent1 = 0 if solarpatent1 == .

tsset year
tsline solarpatent1 solarpatent0  if year_application >= 2005, ///
	legend(ring(0) pos(9) row(2) order(1 "LCR participants" 2 "No LCR")) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(5)25, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	name(spatents_ts_lcr, replace)
gr export "${lcr_descriptives}/spatents_ts_lcr.png", replace

frame change default
frame drop solar_patent_time_series


***********************************************************************
* 	PART 7: Qualitative analysis - eyeballing patents post LCR
***********************************************************************

format title abstract %-150s
format abstract %-300s
sort company_name year_application
br if solarpatent == 1 & lcr == 1 & year_application > 2013

/*
Note, only 5 companies in the LCR group have filed a patent after LCR. 
Azure
1: mounting assemble of solar module
2: solar module cleaning

Bosch (11)
1: method for producing thin film modules
2: multilayer electrode for thin film modules
3: method for producing thin film modules
4: method for producing thin film modules
5: DC building system
6: rest focuses on storage system

Bharat (10)
1: Wedge press system during solar cell integration process
2: Chemical process for CZTS poweders for solar PV applications
3: Jig for plating of silicon solar cells
4: light source for solar IV tester
5: process for thining C-SI wafers
6: reduced sized solar panel
7: method for detecting breaks in solar cells
8: structure for solar module on roofs
9: automatically re-orienting axis for solar PV arrays


Tata (7)
1: System aiding PV installation
2: Solar tracking system
3: Cable & solar power generation system
4: Computer vision system for PV installation & maintenance
5: Intelligent inline sensor
6: Solar energy driven vehicle with light weight solar panels

Vikram (1)
1: Design for floating solar platform

*/

br if solarpatent == 1 & lcr == 0 & year_application > 2013

/* 
Mahindra (6)



*/