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
*	Author: Florian Münch, Fabian Scheifele  														  
*	ID variable: company_name		  									  
*	Requires:	eventstudy_final
*	Creates:	

***********************************************************************
* 	PART 1: import the collapsed dataset & declara as panel data	  						
***********************************************************************
use "${lcr_final}/event_study", clear	

rename year_application year

xtset company_name2 year

cd "$final_figures"	

set graphics on

***********************************************************************
* 	PART 2:   revenue 
***********************************************************************
/*
	* winsorize variable
winsor2 total_revenue, cuts(0 95)
ihstrans total_revenue_w


preserve

panelview ihs_total_revenue_w lcr, i(company_name) t(year_application) type(outcome) prepost

preserve 
collapse , by(year)

tsline total_revenue

twoway ///
	(line total_revenue year_application if lcr == 1) ///
	(line total_revenue year_application if lcr == 0)

tsline solarpatent if year >= 2005, ///
	legend(pos(6) row(1)) ///
	xlabel(2005 2006 2007 2008 2009 2010 2011 "{bf:2011}" 2012 2013 "{bf:2013}" 2014 2015 2016 2017 "{bf:2017}" 2018 2019 2020, labs(small) nogrid) ///
	xline(2011 2013 2017) ///
	ylabel(0(5)25, nogrid) ///
	ytitle("solar patents") ///
	text(20 2011 "Auction scheme" "announced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(15 2013 "LCR introduced", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	text(5 2017 "LCR ended", box lcolor(black) bcolor(white) margin(l+.5 t+.5 b+.5 r+.5)) ///
	name(spatents_ts, replace)
gr export "${lcr_descriptives}/spatents_ts.png", replace

*/

***********************************************************************
* 	PART 2: unmatched event study	  						
***********************************************************************
foreach model in reg poisson {
		* regression estimate: OLS & Poisson
	`model' solarpatent i.lcr##ib2013.year, vce(robust)

		* visualisation of the treatment effect (LCR-year dummy)
			* store coefficients + SE results in variables
	gen coef_`model' = . 
	gen se_low_`model' = . 
	gen se_high_`model' = .

			* replace variables with coeff + SE for each year
	forvalues year = 2004(1)2020 {
		replace coef_`model' = _b[1.lcr#`year'.year] if year == `year'
		replace se_low_`model' = _se[1.lcr#`year'.year] if year == `year'
		replace se_high_`model' = _se[1.lcr#`year'.year] if year == `year'
	}

			* create confidence intervals
	gen ci_top_`model' = coef_`model' + se_high_`model' * 1.96
	gen ci_bottom_`model' =  coef_`model' - se_low_`model' * 1.96

			* keep only variables for visualisation
	preserve 
	keep year coef_* ci_* se_*

			* visualize in scatter plot with overlaid ci
		twoway (sc coef_`model' year) ///
			(rcap ci_top_`model' ci_bottom_`model' year, vertical),	///
				xtitle("year") ///
				xline(2013, lpattern(dash)) ///
				xlabel(2004(1)2020, labsize(tiny)) ///
				yline(0, lcolor(black)) ///
				caption("95% Confidence Intervals Shown", size(vsmall)) ///
				subtitle("{it:Unmatched}") ///
				ytitle("filed solar patents") ///
				legend(off) ///
				name(event_unmatched_`model', replace)
		graph export event_unmatched_`model'.png, replace
			
	restore
}	

***********************************************************************
* 	PART 3: event study conditional on matching 						
***********************************************************************
	* estimate weighted DiD regressions
foreach weight in weight_all01 weight_all05 weight_won01 weight_won05 weight_outliers01 weight_outliers05 {
			* OLS
	_eststo `weight'_reg: reg solarpatent i.lcr##ib2013.year [iweight=`weight'], vce(hc3)
	
			* Poisson
	*_eststo `weight'_poi: poisson solarpatent i.lcr##ib2013.year [iweight=`weight'], vce(robust)
}

	* export results in a table
foreach model in reg /*poi*/ {
	esttab *_`model' using event_did_psm_`model'.tex, replace ///
		keep(1.lcr#*.year) ///
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
		addnotes("Event window before-after 2013, with 2013 as baselevel for year dummmies." "Robust standard errors in parentheses.")
}

	* visualise the results after matching
		* choice of model
reg solarpatent i.lcr##ib2013.year [iweight=weight_all01], vce(hc3)
		* code for visualisation
gen coef_all01 = . 
gen se_low_all01 = . 
gen se_high_all01 = .

		* replace variables with coeff + SE for each year
forvalues year = 2004(1)2020 {
	replace coef_all01 = _b[1.lcr#`year'.year] if year == `year'
	replace se_low_all01 = _se[1.lcr#`year'.year] if year == `year'
	replace se_high_all01 = _se[1.lcr#`year'.year] if year == `year'
}

		* create confidence intervals
gen ci_top_all01 = coef_all01 + se_high_all01 * 1.96
gen ci_bottom_all01 =  coef_all01 - se_low_all01 * 1.96

		* keep only variables for visualisation
preserve 
keep year coef_* ci_* se_*

		* visualize in scatter plot with overlaid ci
	twoway (sc coef_all01 year) ///
		(rcap ci_top_all01 ci_bottom_all01 year, vertical),	///
			xtitle("year") ///
			xline(2013, lpattern(dash)) ///
			xlabel(2004(1)2020, labsize(tiny)) ///
			yline(0, lcolor(black)) ///
			caption("95% Confidence Intervals Shown", size(vsmall)) ///
			subtitle("{it:Matched}") ///
			ytitle("filed solar patents") ///
			legend(off) ///
			name(event_matched_all01, replace)
	graph export event_matched_all01.png, replace
		
restore

***********************************************************************
* 	PART 4: combine matched and unmatched into one graph						
***********************************************************************
gr combine event_unmatched_reg event_matched_all01, ycommon ///
		name(event_combined, replace)
gr export event_combined.png, replace


* combine matched and unmatched coefficient in one graph (TBC)
gen year_offset = year+0.3
	twoway ///
	(sc coef_all01 year, mfcolor(gs0)) (rcap ci_top_all01 ci_bottom_all01 year, vertical lcolor(gs0)) ///
	(sc coef_reg year_offset, mfcolor(gs13)) (rcap ci_top_reg ci_bottom_reg year_offset, vertical lcolor(gs13)),	///
			xtitle("Year") ///
			xline(2013, lpattern(dash)) ///
			xlabel(2004(1)2020, labsize(vsmall)) ///
			yline(0, lcolor(black)) ///
			ytitle("Solar patent applications") ///
			legend(order(2 "Matched (caliper = 0.1)" 4 "Unmatched") rows(1) pos(6)) ///
			name(matched_unmatched_combined, replace)
	graph export matched_unmatched_combined.png, replace
	
/* archived:
/*	
	
	* firm fixed effects
xtreg solarpatent i.lcr##ib2010.year, fe vce(robust)

	*FE poisson model
xtpoisson solarpatent i.lcr##ib2010.year, fe vce(robust)

	*zero-inflated model (does not converge
		*solarpatent is zero for 1911/1955 firm-year instances (97%) so zero inflated model needed
zinb solarpatent i.lcr##ib2010.year, inflate(i.year##lcr)
*/

		levelsof year, local(levels)
foreach l of local levels {
    local mylist "`mylist' `l'.year"
}
coefplot, xline (0) drop(_cons lcr `mylist' ) rename(^1.lcr#([0-9]+)year$ = \1, regex)
*with firm-fixed effects (treatment alone is omitted now, but interaction terms still there)
xtreg solarpatent i.year##lcr, fe
coefplot, vertical drop(_cons 1.t_2004 1.t_2005 1.t_2006 1.t_2007 1.t_2008 1.t_2009 1.t_2010 1.t_2011 1.t_2012 1.t_2013 1.t_2014 1.t_2015 1.t_2016 1.t_2017 1.t_2018 1.t_2019 1.t_2020 1.lcr) yline(0) plotlabel(2004(1)2020)

*/

