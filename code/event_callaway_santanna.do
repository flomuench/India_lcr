***********************************************************************
* 		India LCR: staggered Did, Callaway & Sant'Anna				
***********************************************************************
*	
*	PURPOSE: allow for different timing in treatment		  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import dataset
*	2)		sample: NSM 2, with covariates
*	3)		sample: NSM 1+2, with covariates
*	4)		sample: NSM 1+2, binary outcome
*	5)		sample: NSM 2, revenues as DV (IHS-transformed)
*
*	Author: Florian Münch, Fabian Scheifele
*	ID variable: company_name, year		  									  
*	Requires:	event_study_final

***********************************************************************
* 	PART 1: import dataset	  						
***********************************************************************
use "${lcr_final}/event_study_final", clear	

set graphics on

***********************************************************************
* 	PART 2: sample: NSM 2, with covariates
***********************************************************************
/* Specification decisions:
1: restrict to lcr and open auction winners --> if d_winner != .
2: include not yet treated in control group --> add option "notyet"
3: take calendar year of first treatment to define cohorts --> gvar(first_treat1)
4: use default standard errors
5: use 95% CI
*/ 

		* main specification
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(95) dripw
*estat pretrend
*estat simple, post replace
estat all
estat event, replace
csdid_plot,  legend(pos(6) row(1)) ytitle(solar patents) ylabel(-1.5(1)1.5, nogrid) xtitle(Years to Treatment) ///
	text(1.5 0 "ATT = -.23, CI = [-.53; .07], z = -1.48", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5))
gr export "${final_figures}/spatents_staggered_event_nsm2.png", replace


		* change specification decision 2: do not include not yet treated in control group
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) level(95) dripw
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm2_cov2_nevertreated.png", replace


		* change specification decision 3: use bootstrap with 999 reps (default)
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls'  if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet wboot level(95) dripw
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm2_cov2_boot.png", replace

		* change specification decision 4: use bootstrap with 999 reps + 90CI
local controls "indian manufacturer pre_solar_patent_2010 revenue_2010"
csdid solarpatent `controls'  if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet wboot level(90) dripw
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm2_cov2_boot90.png", replace

***********************************************************************
* 	PART 3: sample: NSM 1+2, with covariates
***********************************************************************
/* Specification decisions:
1: restrict to lcr and open auction winners --> if d_winner != .
2: include not yet treated in control group --> add option "notyet"
3: take calendar year of first treatment to define cohorts --> gvar(first_treat1)
4: use default standard errors
5: use 95% CI
*/ 

		* main specification
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(95) dripw
estat all
estat event, estore(nsm2_cov) 
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-2(1)5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event_nsm1_cov.png", replace


		* change specification decision 2: do not include not yet treated in control group
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) level(95) dripw
estat all
estat event
csdid_plot


		* change specification decision 3: take early, middle, and late treated as cohorts
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner != ., ivar(company_name2) time(year) gvar(first_treat2) rseed(21112022) notyet level(95) dripw
estat all
estat event
csdid_plot

		* change specification decision 4: use bootstrap with 999 reps (default)
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls'  if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet wboot level(95) dripw
estat all
estat event
csdid_plot

***********************************************************************
* 	PART 4: sample: NSM 1+2, binary outcome
***********************************************************************
		* 1: Incl. NSM batch 1 and covariates (annual cohorts)
local controls "indian manufacturer revenue_2010"

		* 2: Only NSM batch 2+ and covariates (third cohort variable)
csdid solarpatent_bin `controls' if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(95) dripw
estat all
estat event, estore(nsm2_cov_bin) replace
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-1.5(1)1.5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/solarpatent_bin_staggered_event_nsm2.png", replace

***********************************************************************
* 	PART 5: sample: NSM 2, revenues as DV (IHS-transformed)
***********************************************************************
		* 4: Only NSM batch 2+ and covariates (third cohort variable), as there is an equal trend among LCR and non
		* LCR auction winners, no covariates are chosen in the estimation of revenue treatment effects
csdid total_revenue_billion if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(95) 
estat all
estat event, estore(nsm2_cov_rev) replace
csdid_plot, legend(pos(6) row(1)) ytitle(Revenues in Bn. INR) ylabel(, nogrid) xtitle(Years to Treatment) ///
		text(100 0 "ATT = -.16, CI = [-36.03; 4.03], z = -1.57", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5))
gr export "${final_figures}/revenue_staggered_event_nsm2.png", replace


***********************************************************************
* 	PART 6: Put coefficients from event study into one table
***********************************************************************
local controls "indian manufacturer revenue_2010"
csdid solarpatent `controls' if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(95) dripw
estat event, estore(spatents_nsm2_all) replace

local regressions spatents_nsm2_all nsm2_cov_bin nsm2_cov_rev
esttab `regressions' using "${lcr_rt}/csdid_table.tex", replace ///
	mtitles("Solar patents" "Solar patents binary" "Revenue") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("Column (1) and (2) include Indian origin dummy, Manufacturer dummy and pre-LCR revenues as matching covariates." "Column (3) does not include any covariates." "All estimations include not-yet treated observations as controls." )