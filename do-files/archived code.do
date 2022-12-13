* 1: main specification
csdid solarpatent if d_winner != . & year>2007 , ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) notyet level(95)
estat all // look at aggregated results
estat event // run aggregated event study for visualisation
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-1.5(0.5)1.5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event_nsm1.png", replace


* 2: do not include not yet treated in control group
csdid solarpatent if d_winner != ., ivar(company_name2) time(year) gvar(first_treat1) rseed(21112022) level(95)
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm1.png", replace

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
* 	PART 4: sample: NSM 2, without covariates
***********************************************************************
/* Specification decisions:
1: restrict to lcr and open auction winners --> if d_winner != .
2: include not yet treated in control group --> add option "notyet"
3: take calendar year of first treatment to define cohorts --> gvar(first_treat1)
4: use bootstrap to calculate se
5: use 95% CI
*/ 
* 1: main specification
csdid solarpatent if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(95)
estat all // look at aggregated results
estat event // run aggregated event study for visualisation
csdid_plot, legend(pos(6) row(1)) ytitle(solar patents) ylabel(-1.5(1)1.5, nogrid) xtitle(Years to Treatment)
gr export "${final_figures}/staggered_event_nsm2.png", replace


* 2: do not include not yet treated in control group
csdid solarpatent if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) level(95)
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm2_nevertreated.png", replace


* 3: use bootstrap with 999 reps (default)
csdid solarpatent if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet wboot level(95)
estat all
estat event
csdid_plot
gr export "${final_figures}/staggered_event_nsm2_boot.png", replace


* 4: use 90% CI
csdid solarpatent if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(90)
estat all
estat event
csdid_plot

* 5: use 90% CI plus bootstrap
csdid solarpatent if d_winner2 != ., ivar(company_name2) time(year) gvar(first_treat3) rseed(21112022) notyet level(90) wboot
estat all
estat event
csdid_plot
