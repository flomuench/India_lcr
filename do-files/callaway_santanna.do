***********************************************************************
* 			lcr India paper: staggered Did, Callaway & Sant'Anna				
***********************************************************************
*	
*	PURPOSE: allow for different timing in treatment		  								  
*				  
*																	  
*	OUTLINE:														  
*																	 																      *
*	Author: Florian Münch
*	ID variable: company_name, year		  									  
*	Requires:	eventstudy_final

***********************************************************************
* 	PART 1: import the collapsed dataset & declara as panel data	  						
***********************************************************************
use "${lcr_final}/eventstudy_final", clear	

set graphics on

***********************************************************************
* 	PART 2: without covariates
***********************************************************************
/* Specification decisions:
1: restrict to lcr and open auction winners --> if d_winner != .
2: include not yet treated in control group --> add option "notyet"
3: take calendar year of first treatment to define cohorts --> gvar(first_treat1)
4: use bootstrap to calculate se
5: use 95% CI
*/ 
* 1: main specification
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(95)
estat all // look at aggregated results
estat event // run aggregated event study for visualisation
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-2(1)5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event.png", replace


* 2: do not include not yet treated in control group
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) level(95)
estat all
estat event
csdid_plot


* 3: take early, middle, and late treated as cohorts
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat2) rseed(21112022) notyet level(95)
estat all
estat event
csdid_plot

* 4: use bootstrap with 999 reps (default)
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet wboot level(95)
estat all
estat event
csdid_plot


* 5: use 90% CI
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(90)
estat all
estat event
csdid_plot

* 6: use 90% CI plus bootstrap
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(90) wboot
estat all
estat event
csdid_plot


***********************************************************************
* 	PART 3: with covariates
***********************************************************************
/* Specification decisions:
1: restrict to lcr and open auction winners --> if d_winner != .
2: include not yet treated in control group --> add option "notyet"
3: take calendar year of first treatment to define cohorts --> gvar(first_treat1)
4: use default standard errors
5: use 95% CI
*/ 

* 3.1: only time invariant covariates

* main specification
local controls "indian manufacturer"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(95) dripw
estat all
estat event 
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-2(1)5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event_cov.png", replace


* change specification decision 2: do not include not yet treated in control group
local controls "indian manufacturer"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) level(95) dripw
estat all
estat event
csdid_plot


* change specification decision 3: take early, middle, and late treated as cohorts
local controls "indian manufacturer"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat2) rseed(21112022) notyet level(95) dripw
estat all
estat event
csdid_plot

* change specification decision 4: use bootstrap with 999 reps (default)
local controls "indian manufacturer"
csdid solarpatent `controls'  if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet wboot level(95) dripw
estat all
estat event
csdid_plot



* 3.2.: time invariant & pre-policy covariates
* main specification
local controls "indian manufacturer pre_solar_patent_2010 revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(95) dripw
estat all
estat event 
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-2(1)5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event_cov.png", replace


* change specification decision 2: do not include not yet treated in control group
local controls "indian manufacturer pre_solar_patent_2010 revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) level(95) dripw
estat all
estat event
csdid_plot


* change specification decision 3: take early, middle, and late treated as cohorts
local controls "indian manufacturer pre_solar_patent_2010 revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat2) rseed(21112022) notyet level(95) dripw
estat all
estat event
csdid_plot

* change specification decision 4: use bootstrap with 999 reps (default)
local controls "indian manufacturer pre_solar_patent_2010 revenue_2010"
csdid solarpatent `controls'  if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet wboot level(95) dripw
estat all
estat event
csdid_plot










