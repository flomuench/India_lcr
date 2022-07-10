***********************************************************************
* 			power size calculations - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: calculate how big an effect on patents it would have 		  							  
*	needed
*																	  
*	OUTLINE:														  

*
*																	  															      
*	Author:  	Florian Münch & Fabian Scheifele					  
*	ID variable: 	company_name			  					  
*	Requires: solar_components_updated_HS.dta							  
*	Creates:                       
*																	  
***********************************************************************
* 	PART 1:  set the scene & merge			
***********************************************************************
set scheme s1color
import delimited "${lcr_raw}/solar_patents_addinfo.csv", clear varn(1)
rename id company_name
drop sales manufacturer

	* set the directory to propensity matching folder
cd "$lcr_final"

	* graphics output window
set graphics on

	*Merge via company name
merge m:1 company_name using lcr_final
drop if _merge==2

***********************************************************************
* 	PART 2:  re-name some of the elements for better understanding			
***********************************************************************
replace subgroups = "cells or panels" if subgroups == "Combinations of the groups above"
replace subgroups = "H02N6/00" if ipc == "H02N6/00"
replace subgroups = "common cell elements" if subgroups == "Common Elements"
replace groups = "cells or panels" if subgroups == "cells or panels"
replace groups = "H02N6/00" if subgroups == "H02N6/00"
*rename some of the variables
rename solarpatentx solarpatent
lab var solarpatent "solar patents"

*************************************************************************
* 	PART 3:  IPC category of solar patents	
*************************************************************************
cd "$final_figures"

		* count of solar patents by LCR and IPC groupd; no time dimension
graph hbar (sum) solarpatent, over(lcr) over(groups) blabel(bar)

gen post = (app_year > 2012)

		* count of solar patents by LCR and IPC groupd; 
graph hbar (sum) solarpatent, over(post) over(lcr, lab(labs(small))) over(groups) ///
	blabel(bar) ///
	legend(lab(1 "pre LCR") lab(2 "post LCR")) ///
	name(solarpatents_ipcc_lcr_post, replace)
gr export solarpatents_ipcc_lcr_post.png, replace


	


gr export patent_bar.png, replace 


graph pie solarpatent, over(subgroups) plabel(_all sum)
graph pie solarpatent, over(groups) plabel(_all sum)
graph pie solarpatent if lcr==1, over(groups) plabel(_all sum)
graph pie solarpatent if lcr==0, over(groups) plabel(_all sum)

tab2 groups lcr, column
return list


graph hbar (sum) solarpatents, over(lcr) over(groups) blabel(bar)
gr export patent_bar.png, replace 



graph hbar (sum) solarpatents if app_year<=2012, over(lcr) over(groups) blabel(bar)

graph hbar (sum) solarpatent if app_year>2012, over(lcr,lab(labs(vsmall))) over(subgroups,lab(labs(vsmall))) blabel(bar)

*************************************************************************
* 	PART 4:  (un-) conditional pre-and post trend in solar patents by lcr
*************************************************************************
set graphics on
	
	* 1: visualisation of solar patents over time - UNCONDITIONAL ON MATCHING
preserve

	* contract to create data set of frequencies of solar patents per year and lcr participation
contract app_year lcr, zero
rename _freq solarpatents
lab var app_yea "year of application"
lab var solarpatents "solar patents"

			* unsmoothed plot
graph twoway (line solarpatent app_year if lcr==1, lcolor(red)) ///
(line solarpatent app_year if lcr==0, lcolor(blue)), legend (lab(1 "LCR firms") lab(2 "non-LCR firms")) xline(2012)

			* smoothed plot
				* pre-post
					* single graph
graph twoway ///
	(scatter solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title({bf:"Solar patents before and after LCR policy"}) ///
	subtitle("unadjusted to propensity score", size(small)) ///
	name(solarpatents_trend, replace)
gr export solarpatents_trend.png, replace

					* for graph combine w/o title
graph twoway ///
	(scatter solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title("unadjusted to propensity score", size(small)) ///
	name(spatents_trend, replace)


				* pre
graph twoway ///
	(scatter solarpatents app_year if lcr == 1 & app_year <= 2012, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0 & app_year <= 2012, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1 & app_year <= 2012, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0 & app_year <= 2012, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	title("patent count unadjusted to propensity score", size(small)) ///
	xline(2012) ///
	name(spatents_pretrend, replace)
gr export spatents_pretrend.png, replace

restore

	* 2: visualisation of solar patents over time - CONDITIONAL ON MATCHING
*preserve
gen one = 1
collapse (count) one [iweight = weight_all05], by(app_year lcr)
rename one solarpatents
lab var app_yea "year of application"
lab var solarpatents "solar patents"
fillin app_year lcr
replace solarpatents = 0 if solarpatents == .

 
			* unsmoothed
graph twoway (line solarpatent app_year if lcr==1, lcolor(maroon)) ///
	(line solarpatent app_year if lcr==0, lcolor(navy)), ///
	legend (lab(1 "LCR firm") lab(2 "non-LCR firm")) ///
	xline(2012)
			* smoothed
				* pre-post
					* single figure
graph twoway ///
	(scatter solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title({bf:"Solar patents before and after LCR policy"}) ///
	subtitle("adjusted to propensity score", size(small)) ///
	name(solarpatents_trend_adj, replace)
gr export solarpatents_trend_adj.png, replace

					* for graph combine w/o title
graph twoway ///
	(scatter solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title("adjusted to propensity score", size(small)) ///
	name(spatents_trend_adj, replace)
	
graph combine spatents_trend spatents_trend_adj, ///
	title({bf:"Solar patents before and after LCR policy"}) ///
	ycommon ///
	name(spatents_bothtrends, replace)
gr export spatents_bothtrends.png, replace
					
				* pre
graph twoway ///
	(scatter solarpatents app_year if lcr == 1 & app_year <= 2012, lcolor(maroon)) ///
	(scatter solarpatents app_year if lcr == 0 & app_year <= 2012, lcolor(navy)) ///
	(lowess solarpatents app_year if lcr == 1 & app_year <= 2012, lcolor(maroon)) ///
	(lowess solarpatent app_year if lcr == 0 & app_year <= 2012, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	title("patent count adjusted to propensity score", size(small)) ///
	xline(2012) ///
	name(spatents_pretrend_adj, replace)
gr export spatents_pretrend_adj.png, replace

graph combine spatents_pretrend spatents_pretrend_adj, ///
	title({bf:"Solar patents before LCR policy"}) ///
	ycommon ///
	name(spatents_pretrend, replace)
gr export spatents_pretrend.png, replace


restore
*************************************************************************
* 	PART 5:  (un-) conditional pre-and post trend in PATENTS by lcr
*************************************************************************
use "${lcr_raw}/firmpatent", clear
set graphics on
	* create common identifier
rename companyname_correct company_name

	* merge with combined_results to get lcr participation information
cd "$lcr_final"
merge m:1 company_name using lcr_final, keepusing(lcr weight_outliers05)
drop if _merge == 1

	* mark bosch as outlier
gen outlier = 0
replace outlier = 1 if company_name == "bosch"
drop if outlier == 1

	* gen one for summing
gen one = 1

	* visualisation of total patents over time - unconditional
preserve
collapse (sum) one, by(year_application lcr)
rename one total_patents
lab var year_application "year of application"
lab var total_patents "total patents"
cd "$final_figures"
graph twoway ///
	(scatter total_patents year_application if lcr == 1, lcolor(maroon)) ///
	(scatter total_patents year_application if lcr == 0, lcolor(navy)) ///
	(lowess total_patents year_application if lcr == 1, lcolor(maroon)) ///
	(lowess total_patents year_application if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title("Total patents before and after LCR policy") ///
	subtitle("patent count unadjusted for PSM") ///
	name(total_patents_trend, replace)
gr export total_patents_trend.png, replace
restore

	* visualisation of total patents over time - conditional on matching
preserve
collapse (sum) one [iweight = weight_outliers05], by(year_application lcr)
rename one total_patents
lab var year_application "year of application"
lab var total_patents "total patents"
cd "$final_figures"
graph twoway ///
	(scatter total_patents year_application if lcr == 1, lcolor(maroon)) ///
	(scatter total_patents year_application if lcr == 0, lcolor(navy)) ///
	(lowess total_patents year_application if lcr == 1, lcolor(maroon)) ///
	(lowess total_patents year_application if lcr == 0, lcolor(navy)), ///
	legend (lab(1 "LCR group") lab(2 "non-LCR group") lab(3 "LWR LCR") lab(4 "LWR non-LCR")) ///
	xline(2012) ///
	title("Total patents before and after LCR policy") ///
	subtitle("Patent count adjusted for PSM") ///
	name(total_patents_trend_adj, replace)
gr export total_patents_trend_adj.png, replace
restore


