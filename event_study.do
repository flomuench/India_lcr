***********************************************************************
* 			lcr India paper: create a balanced firm-year panel and test-pre trends					
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import the collapsed firm-year dataset
*	2) 		transform to panel dataset and use tsfill to have balanced time periods
*	3)		merge company specific data
*	4) 		create event study dummies
*	5) 		Do event study regression without controls
*	6)		Do event study regression with controls
*																	 																      *
*	Author: Fabian  														  
*	ID variable: company_name		  									  
*	Requires:	eventstudy_final
*	Creates:	

***********************************************************************
* 	PART 1: import the collapsed dataset & declara as panel data	  						
***********************************************************************
cd "$lcr_final"

use "${lcr_final}/event_study", clear	

xtset company_name2 year_application

***********************************************************************
* 	PART 2: estimation with xtevent package (DOES NOT WORK)		  						
***********************************************************************
*xtevent solarpatent, pol(event) w(8)

***********************************************************************
* 	PART 2: unmatched event study	  						
***********************************************************************
*simple OLS with interaction term of event study and treatment dummy without controls and fixed effects
	* OLS
reg solarpatent i.lcr##ib2010.year_application, vce(hc3)

	*normal poisson without fixed effects
poisson solarpatent i.lcr##ib2010.year_application, vce(robust)
	
	* firm fixed effects
*xtreg solarpatent i.lcr##ib2010.year_application, fe vce(robust)

	*FE poisson model
*xtpoisson solarpatent i.lcr##ib2010.year_application, fe vce(robust)

	*zero-inflated model (does not converge
		*solarpatent is zero for 1911/1955 firm-year instances (97%) so zero inflated model needed
*zinb solarpatent i.lcr##ib2010.year_application, inflate(i.year_application##lcr)


	* visualisation of the treatment effect (LCR-year dummy)
		* store coefficients + SE results in variables
gen coef = . 
gen se_low = . 
gen se_high = .

		* replace variables with coeff + SE for each year
forvalues year = 2004(1)2020 {
	replace coef = _b[1.lcr#`year'.year_application] if year_application == `year'
	replace se_low = _se[1.lcr#`year'.year_application] if year_application == `year'
	replace se_high = _se[1.lcr#`year'.year_application] if year_application == `year'
}

		* create confidence intervals
gen ci_top = coef + se_high * 1.96
gen ci_bottom =  coef - se_low * 1.96

cd "$final_figures"	
set graphics on
		* keep only variables for visualisation
preserve 
keep year_application coef ci_* se_*

		* visualize in scatter plot with overlaid ci
	twoway (sc coef year_application) ///
		(rcap ci_top ci_bottom year_application, vertical),	///
			xtitle("year") ///
			xline(2010, lpattern(dash)) ///
			xlabel(2004(1)2020, labsize(vsmall)) ///
			yline(0, lcolor(black)) ///
			caption("95% Confidence Intervals Shown", size(vsmall)) ///
			title("{bf: Event study difference-in-difference}") ///
			subtitle("{it:Unmatched}") ///
			ytitle("filed patents") ///
			legend(off) ///
			name(event_unmatched, replace)
	graph export event_unmatched.png, replace
		
restore
		

/* archived:
		levelsof year_application, local(levels)
foreach l of local levels {
    local mylist "`mylist' `l'.year_application"
}
coefplot, xline (0) drop(_cons lcr `mylist' ) rename(^1.lcr#([0-9]+)year_application$ = \1, regex)
*with firm-fixed effects (treatment alone is omitted now, but interaction terms still there)
xtreg solarpatent i.year##lcr, fe
coefplot, vertical drop(_cons 1.t_2004 1.t_2005 1.t_2006 1.t_2007 1.t_2008 1.t_2009 1.t_2010 1.t_2011 1.t_2012 1.t_2013 1.t_2014 1.t_2015 1.t_2016 1.t_2017 1.t_2018 1.t_2019 1.t_2020 1.lcr) yline(0) plotlabel(2004(1)2020)

*/


***********************************************************************
* 	PART 3: event study conditional on matching 						
***********************************************************************
	* estimate weighted DiD regressions
foreach weight in weight_all01 weight_all05 weight_won01 weight_won05 weight_outliers01 weight_outliers05 {
			* OLS
	_eststo `weight'_reg: reg solarpatent i.lcr##ib2010.year_application [iweight=`weight'], vce(hc3)
	
			* Poisson
	*_eststo `weight'_poi: poisson solarpatent i.lcr##ib2010.year_application [iweight=`weight'], vce(robust) technique(bfgs)
}

	* export results in a table

foreach model in reg /*poi*/ {
	esttab *_`model' using event_did_psm_`model'.tex, replace ///
		keep(1.lcr#*.year_application) ///
		title("Difference-in-difference combined with PSM"\label{event_regressions_`model'}) ///
		mgroups("All firms" "Winner firms" "All w/o outliers", ///
			pattern(1 0 1 0 1 0)) ///
		mtitles("caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05") ///
		label ///
		b(2) ///
		se(2) ///
		width(0.8\hsize) ///
		star(* 0.1 ** 0.05 *** 0.01) ///
		nobaselevels ///
		booktabs ///
		addnotes("DiD estimates based on X model." "DiD based on solar patents 2011-2020 minus 2001-2010." "Common support imposed in all specifications through caliper." "Robust standard errors in parentheses.")
}

	* visualise the results of matched regression (here with caliper =0.1)
	
reg solarpatent i.lcr##ib2010.year_application [iweight=weight_all01], vce(hc3)	

		* create confidence intervals
gen coef_m = . 
gen se_low_m = . 
gen se_high_m = .

		* replace variables with coeff + SE for each year
forvalues year = 2004(1)2020 {
	replace coef_m = _b[1.lcr#`year'.year_application] if year_application == `year'
	replace se_low_m = _se[1.lcr#`year'.year_application] if year_application == `year'
	replace se_high_m = _se[1.lcr#`year'.year_application] if year_application == `year'
}

gen ci2__up_m = coef_m + se_high_m * 1.96
gen ci2_low_m =  coef_m - se_low_m * 1.96


		* keep only variables for visualisation
preserve 
keep year_application coef_m ci2_* se_low_m se_high_m

		* visualize in scatter plot with overlaid ci
	twoway (sc coef_m year_application) ///
		(rcap ci2__up_m ci2_low_m year_application, vertical),	///
			xtitle("year") ///
			xline(2010, lpattern(dash)) ///
			xlabel(2004(1)2020, labsize(vsmall)) ///
			yline(0, lcolor(black)) ///
			caption("95% Confidence Intervals Shown", size(vsmall)) ///
			title("{bf: Event study difference-in-difference}") ///
			subtitle("{it:Matched (OLS Model)}") ///
			ytitle("filed patents") ///
			legend(off) ///
			name(event_matched, replace)
	graph export event_matched.png, replace
		
restore
		

