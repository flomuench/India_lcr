***********************************************************************
* 		India LCR: event or dynamic Did estimates		
***********************************************************************
*																	   
*	PURPOSE: examine effect of LCR on firm innovation		  								  
*				  
*																	  
*	OUTLINE:														  
*	1) prepare the ground
*	2) unmatched event study
*	3) matched event study
*
*	Author: Florian Münch, Fabian Scheifele
*	ID variable: company_name, year		  									  
*	Requires:	event_study_final
*
***********************************************************************
* 	PART 1: import the collapsed dataset & declara as panel data	  						
***********************************************************************
use "${lcr_final}/event_study_final", clear	

rename year_application year

xtset company_name2 year

cd "$final_figures"	

set graphics on


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

