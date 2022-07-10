***********************************************************************
* 			main regression - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: estimation of effect of LCR on solar patents based
*	on matching
*	  
*	OUTLINE:														  
*
*
*																	  															      
*	Author:  	Florian Muench 							  
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*
*	information about automatically exporting att from psmatch2: https://stackoverflow.com/questions/59950622/export-att-result-after-psmatch2-command										  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
*cd "$lcr_rt"
cd "$lcr_final"

***********************************************************************
* 	PART 2:  Nearest neighbor matching
***********************************************************************
* C1: Simple post-difference
_eststo post_nn, r:reg post_solar_patent i.lcr

* C2: DiD
_eststo did_nn, r:reg dif_solar_patents i.lcr, vce(hc3)
	
* 1: 1nn with replacement
		* sample = all
psmatch2 lcr, neighbor(1) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_all
_eststo all_nn_ate, r: reg post_solar_patent i.lcr
_eststo all_nn_att, r: reg post_solar_patent i.lcr [iweight= weight_nn_all]

		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(1) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_won
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(1) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outlier_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_outlier
	
	* export results in a table
cd "$final_figures"	
esttab *_nn using did_robust_nn.tex, replace ///
	title("Difference-in-difference combined with PSM: Nearest Neighbor"\label{nn_robust}) ///
	mtitles("DiD" "All firms" "Winner firms" "All w/o outliers") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	booktabs ///
	addnotes("All estimates based on nearest neighbor matching." "DiD based on solar patents 2011-2020 minus 2001-2010." "Common support imposed in all specifications." "Robust standard errors in parentheses.")


***********************************************************************
* 	PART 3:  Radius/caliper matching
***********************************************************************

* C1: Simple post-difference
_eststo post_caliper, r:reg post_solar_patent i.lcr

* C2: DiD
_eststo did_caliper, r:reg dif_solar_patents i.lcr, vce(hc3)
	* counterfactual = participated LCR vs. did not participate LCR
		* outcome 1: solar patents
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_caliper01, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_all01
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_caliper05, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_all05
	
	psmatch2 lcr, radius caliper(0.2) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_caliper02, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_all02

			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_caliper01, r: reg dif_solar_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_won01
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_caliper05, r: reg dif_solar_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper01, r: reg dif_solar_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_outliers01
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper05, r: reg dif_solar_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_outliers05

	
	* export results in a table
cd "$final_figures"	
esttab *caliper* using did.tex, replace ///
	title("Difference-in-difference combined with matching"\label{main_regressions}) ///
	mgroups("All firms" "Winner firms" "All w/o outliers", ///
		pattern(1 0 1 0 1 0 1 0)) ///
	mtitles("Post difference" "DiD" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	booktabs ///
	addnotes("DiD based on solar patents 2011-2020 minus 2001-2010." "Common support imposed in all specifications." "Robust standard errors in parentheses.")

	
		* outcome 2: cell & module patents
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_cell_all01
psmatch2 lcr, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_cell_all05

			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_cell_won01
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_cell_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_cell_outliers01
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_cell_outliers05

/*	Eststo command says "too many specified?"
	* outcome 3: Binary post-patent indicator (1 if at least one patent post-2010)
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_all)
_eststo all_caliper01_bin r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_binary_all01
	
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_all)
_eststo all_caliper05_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_binary_all05

			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_won)
_eststo won_caliper01_bin, r: reg post_solar_patentor i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_binary_won01
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_won)
_eststo won_caliper05_bin, r: reg post_solar_patentor i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight weight_binary_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo outliers_caliper01_bin, r: reg post_solar_patentor i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_binary_outlier01
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo outliers_caliper05_bin, r: reg post_solar_patentor i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight weight_cell_outliers05
	*/
	
* export results in a table
cd "$final_figures"	
local cell_models all_caliper01_cell all_caliper05_cell won_caliper01_cell won_caliper05_cell outliers_caliper01_cell outliers_caliper05_cell
esttab `cell_models' using did_modcell.tex, replace ///
	title("Difference-in-difference combined with matching"\label{main_regressions}) ///
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
	addnotes("DiD based on solar patents 2011-2020 minus 2001-2010." "Common support imposed in all specifications." "Robust standard errors in parentheses.")
	
	
	* counterfactual = won LCR vs. did not win LCR


		
		
***********************************************************************
* 	PART 4:  Kernel matching
***********************************************************************
	* counterfactual = participated
		* sample = all
cd "$lcr_rt"
psmatch2 lcr, kernel outcome(post_solar_patent) pscore(pscore_all) k(epan) bw(0.1)
psmatch2 lcr, kernel outcome(post_solar_patent) pscore(pscore_all) k(epan) bw(0.05)
		* sample = only winners
		
		* sample = without patent_outliers
psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore_all) k(epan) bw(0.1)
scalar t = r(att)/ r(seatt)
mat kbw01 = ( r(att) \ t )

psmatch2 lcr if patent_outliers == 0, kernel outcome(post_solar_patent) pscore(pscore_all) k(epan) bw(0.05)
scalar t = r(att)/ r(seatt)
mat kbw005 = ( r(att) \ t )

mat kernel = kbw01, kbw005
mat colnames kernel = "BW = 0.1" "BW = 0.05"
mat rownames kernel = att t

esttab matrix(kernel, fmt(%9.2fc)) using kernelmatching.csv, replace ///
	title("Results for kernel matching") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")

***********************************************************************
* 	PART 5:  Mahalanobis matching
***********************************************************************
	* counterfactual = participated
		* sample = all
psmatch2 lcr, mahalanobis(patentor soe_india manufacturer_solar) outcome(post_solar_patent)
_eststo mahalanobis01, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)

		* sample = without patent outliers
psmatch2 lcr if patent_outliers == 0 , mahalanobis(patentor soe_india manufacturer_solar) outcome(post_solar_patent)
_eststo mahalanobis02, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)	


	* counterfactual = won
		* sample = all
psmatch2 lcr if won_total>0, mahalanobis(patentor soe_india manufacturer_solar) outcome(post_solar_patent)
_eststo mahalanobis01, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	
	
***********************************************************************
* 	PART 5:  Put it all into one table
***********************************************************************

/*
mat matching_all = nn, kernel

esttab matrix(matching_all, fmt(%-9.2fc)) using matching_all.csv, replace ///
	title("Overview results with different matching algorithms") ///
	mtitles("NN" "Kernel") ///
	width(0.8\hsize) ///
	addnotes("All estimtes are based on a Logit model with robust standard errors in parentheses.")
*/
		
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace

