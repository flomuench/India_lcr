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

*in case weight variables were saved from previous version, they are dropped here now

***********************************************************************
* 	PART 2:  Nearest neighbor matching
***********************************************************************
* 1: 1nn with replacement
		* sample = all
psmatch2 lcr, neighbor(1) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_all
	
*_eststo all_nn_ate, r: reg post_solar_patent i.lcr
*_eststo all_nn_att, r: reg post_solar_patent i.lcr [iweight= weight_nn_all]

		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(1) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_won
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(1) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outlier_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_outlier

* 2: 2nn with replacement (selects the two nearest neighbors instead of just one)
		* sample = all
psmatch2 lcr, neighbor(2) outcome(post_solar_patent) pscore(pscore_all)
_eststo all2_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_all
	
		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(2) outcome(post_solar_patent) pscore(pscore_won)
_eststo won2_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_won
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(2) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outlier2_nn, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_outlie	
	
*PART 2.2. NN with cell patents

* 1: 1nn with replacement
		* sample = all
psmatch2 lcr, neighbor(1) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_all_cell
	
*_eststo all_nn_ate, r: reg post_modcell_patent i.lcr
*_eststo all_nn_att, r: reg post_modcell_patent i.lcr [iweight= weight_nn_all]

		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(1) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_won_cell
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(1) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outlier_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_outlier_cell

* 2: 2nn with replacement (selects the two nearest neighbors instead of just one)
		* sample = all
psmatch2 lcr, neighbor(2) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all2_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_all_cell
	
		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(2) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won2_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_won_cell
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(2) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outlier2_nn_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_outlier_cell	

	
*****Part 2.3 BINARY POST SOLAR OUTCOME*****
* 1: 1nn with replacement post_solar_patentor
		* sample = all
psmatch2 lcr, neighbor(1) outcome(post_solar_patentor) pscore(pscore_all)
_eststo all_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_all_bin
	
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(1) outcome(post_solar_patentor) pscore(pscore_won)
_eststo won_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_won_bin
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(1) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo outlier_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_outlier_bin

* 2: 2nn with replacement (selects the two nearest neighbors instead of just one)
		* sample = all
psmatch2 lcr, neighbor(2) outcome(post_solar_patentor) pscore(pscore_all)
_eststo all2_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_all_bin
	
		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(2) outcome(post_solar_patentor) pscore(pscore_won)
_eststo won2_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_won_bin
	
		* sample = no outliers
psmatch2 lcr if patent_outliers == 0, neighbor(2) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo outlier2_nn_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_outlier_bin	

**** Part. 2.4. NN with Sales**
* 1: 1nn with replacement
		* sample = all
psmatch2 lcr, neighbor(1) outcome(post_revenue) pscore(pscore_all)
_eststo all_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_all_sales

		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(1) outcome(post_revenue) pscore(pscore_won)
_eststo won_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn_won_sales
	
		* sample = no outliers
psmatch2 lcr if sales_outliers == 0, neighbor(1) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo outlier_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
	rename _weight weight_nn_outlier_sales

* 2: 2nn with replacement (selects the two nearest neighbors instead of just one)
		* sample = all
psmatch2 lcr, neighbor(2) outcome(post_revenue) pscore(pscore_all)
_eststo all2_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight] , vce(hc3)
	rename _weight weight_nn2_all_sales
	
		
		* sample = won
psmatch2 lcr if won_total > 0, neighbor(2) outcome(post_revenue) pscore(pscore_won)
_eststo won2_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight], vce(hc3)
	rename _weight weight_nn2_won_sales
	
		* sample = no outliers
psmatch2 lcr if sales_outliers == 0, neighbor(2) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo outlier2_nn_sales, r: reg diff_revenue i.lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
	rename _weight weight_nn2_outlie_sales	
	
	
	/* export results C1 C2 1 and 2 in a table
cd "$final_figures"	
esttab *_nn using did_robust_nn.tex, replace ///
	title("Difference-in-difference combined with PSM: Nearest Neighbor"\label{nn_robust}) ///
	mgroups("" "1 nearest neighbor" "2 nearest neighbors", ///
		pattern(1 0 1 0 0 1 0 0)) ///
	mtitles("Simple mean diff." "DiD" "All firms" "Winner firms" "All w/o outliers" "All firms" "Winner firms" "All w/o outliers") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	booktabs ///
	addnotes("Estimates (3)-(5) based on nearest neighbor matching." "DiD based on solar patents 2011-2020 minus 2001-2010." "Common support imposed in all specifications." "Robust standard errors in parentheses.")
*/

	*Same four panel table like for caliper 
cd "$final_figures"		
	//top panel
esttab  all_nn won_nn outlier_nn all2_nn won2_nn outlier2_nn using did_robust_nn.tex, replace ///
		nobaselevels ///
		prehead("\begin{table}[htbp]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{Robustness: Results with Neareast Neighbour Matching} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
		posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel A: Solar PV Patents}} \\\\[-1ex]") ///
		fragment ///
		mgroups("1 nearest neighbor" "2 nearest neighbors", ///
		pattern(1 0 1 0 1 0)) ///
		mtitles("All firms" "Winner firms" "All w/o outliers" "All firms" "Winner firms" "All w/o outliers") ///
		label /// 
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) 

//middle panel 
esttab  all_nn_cell won_nn_cell outlier_nn_cell all2_nn_cell won2_nn_cell outlier2_nn_cell using did_robust_nn.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel B: PV Module \& PV Cell Patents only}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 

//second middle panel 
esttab  all_nn_bin won_nn_bin outlier_nn_bin all2_nn_bin won2_nn_bin outlier2_nn_bin using did_robust_nn.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel C: Post-LCR solar patent (binary)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 
	
//bottom panel 
esttab all_nn_sales won_nn_sales outlier_nn_sales all2_nn_sales won2_nn_sales outlier2_nn_sales using did_robust_nn.tex, ///
   	nobaselevels ///
	posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel D: Revenues (in INR)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers  ///
	prefoot("\hline") ///
	postfoot("\hline\hline\hline \multicolumn{5}{l}{\footnotesize Robust Standard errors in parentheses}\\\multicolumn{2}{l}{\footnotesize \sym{**} \(p<0.05\), \sym{*} \(p<0.1\)}\\ \end{tabular} \\ \end{table}")

		

***********************************************************************
* 	PART 3:  Radius/caliper matching
***********************************************************************

***********************************************************************
*Outcome 1.1: All Solar patents with binary treatment
***********************************************************************
	* create matrix to collect SE for ex post power calculation
matrix def lcr_se = J(2,8,16)
matrix rownames lcr_se = solar_patents, cell_patents
matrix colnames lcr_se  = post_difference, DiD, all01, all05, winners01, winners05, nooutliers_01, nooutliers_05

* C1: Simple post-difference
_eststo post_patcaliper, r:reg post_solar_patent i.lcr
*est store post_patcaliper
	matrix lcr_se[1,1] = _se[1.lcr]

* C2: DiD
_eststo did_patcaliper, r:reg dif_solar_patents i.lcr, vce(hc3)
*est store did_patcaliper
	matrix lcr_se[1,2] = _se[1.lcr]


	* counterfactual = participated LCR vs. did not participate LCR
		* C3: outcome 1: solar patents
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_patcaliper01, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
*est store all_patcaliper01
	rename _weight weight_lcrbinary_all01
	matrix lcr_se[1,3] = _se[1.lcr]

		* C4: as C3 but caliper 0.05
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_all)
_eststo all_patcaliper05, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(hc3)
*est store all_patcaliper05
	rename _weight weight_lcrbinary_all05
	matrix lcr_se[1,4] = _se[1.lcr]

			* C5: sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_patcaliper01, r: reg dif_solar_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_patcaliper01
	rename _weight weight_lcrbinary_won01
	matrix lcr_se[1,5] = _se[1.lcr]

			* C6:
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_won)
_eststo won_patcaliper05, r: reg dif_solar_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_patcaliper05
	rename _weight weight_lcrbinary_won05
	matrix lcr_se[1,6] = _se[1.lcr]

			* C7: sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outliers_patcaliper01, r: reg dif_solar_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_patcaliper01
	rename _weight weight_lcrbinary_outliers01
	matrix lcr_se[1,7] = _se[1.lcr]

			* C8:
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo outliers_patcaliper05, r: reg dif_solar_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_patcaliper05
	rename _weight weight_lcrbinary_outliers05
	matrix lcr_se[1,8] = _se[1.lcr]

***********************************************************************
*Outcome 1.2: All Solar patents with continous treatment
***********************************************************************
* C1: Simple post-difference
_eststo cpost_patcaliper, r:reg post_solar_patent total_auctions_lcr
*est store post_patcaliper

* C2: DiD
_eststo cdid_patcaliper, r:reg dif_solar_patents total_auctions_lcr, vce(hc3)
*est store did_patcaliper

	* counterfactual = participated LCR vs. did not participate LCR
		* outcome 1: solar patents
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_all)
_eststo call_patcaliper01, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight], vce(hc3)
*est store all_patcaliper01
	rename _weight cweight_all01

	
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_all)
_eststo call_patcaliper05, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight], vce(hc3)
*est store all_patcaliper05

	rename _weight cweight_all05
	
			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_won)
_eststo cwon_patcaliper01, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_patcaliper01

	rename _weight cweight_won01
	
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_won)
_eststo cwon_patcaliper05, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_patcaliper05

	rename _weight cweight_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo coutliers_patcaliper01, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_patcaliper01

	rename _weight cweight_outliers01
	
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_nooutliers)
_eststo coutliers_patcaliper05, r: reg dif_solar_patents total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_patcaliper05
	rename _weight cweight_outliers05
	
***********************************************************************	
		* outcome 2.1: cell & module patents with binary treatment
***********************************************************************
		* Simple post-difference
_eststo post_cell, r:reg post_modcell_patent i.lcr
*est store post_cell
	matrix lcr_se[2,1] = _se[1.lcr]

		
		* DiD
_eststo did_cell, r:reg dif_modcell_patents i.lcr, vce(hc3)
*est store did_cell
	matrix lcr_se[2,2] = _se[1.lcr]

			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
*est store all_caliper01_cell
	rename _weight weight_cell_all01
	matrix lcr_se[2,3] = _se[1.lcr]


psmatch2 lcr, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_all)
_eststo all_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight], vce(hc3)
*est store all_caliper05_cell
	rename _weight weight_cell_all05
	matrix lcr_se[2,4] = _se[1.lcr]


			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_caliper01_cell
	rename _weight weight_cell_won01
	matrix lcr_se[2,5] = _se[1.lcr]

psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_won)
_eststo won_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_caliper05_cell
	rename _weight weight_cell_won05
	matrix lcr_se[2,6] = _se[1.lcr]

			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper01_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_caliper01_cell
	rename _weight weight_cell_outliers01
	matrix lcr_se[2,7] = _se[1.lcr]

	
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo outliers_caliper05_cell, r: reg dif_modcell_patents i.lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_caliper05_cell
	rename _weight weight_cell_outliers05
	matrix lcr_se[2,8] = _se[1.lcr]

***********************************************************************	
		* outcome 2.2: cell & module patents with continous treatment
***********************************************************************
		* Simple post-difference
_eststo cpost_cell, r:reg post_modcell_patent total_auctions_lcr
*est store post_cell

* DiD
_eststo cdid_cell, r:reg dif_modcell_patents total_auctions_lcr, vce(hc3)
*est store did_cell

			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_all)
_eststo call_caliper01_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight], vce(hc3)
*est store all_caliper01_cell
	rename _weight cweight_cell_all01


psmatch2 lcr, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_all)
_eststo call_caliper05_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight], vce(hc3)
*est store all_caliper05_cell

	rename _weight cweight_cell_all05

			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_won)
_eststo cwon_caliper01_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_caliper01_cell
	rename _weight cweight_cell_won01
	
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_won)
_eststo cwon_caliper05_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store won_caliper05_cell
	rename _weight cweight_cell_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo coutliers_caliper01_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_caliper01_cell
	rename _weight cweight_cell_outliers01
	
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_modcell_patent) pscore(pscore_nooutliers)
_eststo coutliers_caliper05_cell, r: reg dif_modcell_patents total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
*est store outliers_caliper05_cell
	rename _weight cweight_cell_outliers05
	
***********************************************************************
*outcome 3.1: Binary post-patent indicator (1 if at least one patent post-2010)
***********************************************************************
		* Simple post-difference
_eststo post_binary, r:reg post_solar_patentor i.lcr
*est store post_cell

* DiD (Would relate to change in solar patentor status, could also be negative in case company was patentor before but not after)
_eststo did_binary, r:reg diff_solar_patentor i.lcr, vce(hc3)
			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_all)
_eststo all_caliper01_bin, r: reg post_solar_patentor i.lcr [iweight=_weight], vce(hc3)
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
	rename _weight weight_binary_outliers05

***********************************************************************
*outcome 3.2: Binary post-patent indicator (1 if at least one patent post-2010) with continous treatment
***********************************************************************
		* Simple post-difference
_eststo cpost_binary, r:reg post_solar_patentor total_auctions_lcr
*est store post_cell

* DiD
_eststo cdid_binary, r:reg diff_solar_patentor total_auctions_lcr, vce(hc3)

			* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_all)
_eststo call_caliper01_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight], vce(hc3)
	rename _weight cweight_binary_all01
	
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_all)
_eststo call_caliper05_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight], vce(hc3)
	rename _weight cweight_binary_all05

			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_won)
_eststo cwon_caliper01_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight cweight_binary_won01
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_won)
_eststo cwon_caliper05_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
	rename _weight cweight_binary_won05
	
			* sample = no outliers (bosch & sunedision dropped - high patents, only once participated)
psmatch2 lcr if patent_outliers == 0, radius caliper(0.1) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo coutliers_caliper01_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight cweight_binary_outlier01
psmatch2 lcr if patent_outliers == 0, radius caliper(0.05) outcome(post_solar_patentor) pscore(pscore_nooutliers)
_eststo coutliers_caliper05_bin, r: reg post_solar_patentor total_auctions_lcr [iweight=_weight] if patent_outliers == 0, vce(hc3)
	rename _weight cweight_binary_outliers05	

/*		
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
	
	*/
***********************************************************************
* 	PART 6.1:  Alternative outcome variable: sales with binary treatment
***********************************************************************
* C1: Simple post-difference
_eststo sales_post, r:reg diff_revenue i.lcr

* C2: DiD
_eststo sales_did, r:reg diff_revenue i.lcr, vce(hc3)

* 1 Caliper radius matching

	* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_revenue) pscore(pscore_all)
_eststo sales_all_caliper01, r: reg diff_revenue i.lcr [iweight=_weight], vce(hc3)
*est store sales_all_caliper01
	rename _weight weight_didsales_all01

psmatch2 lcr, radius caliper(0.05) outcome(post_revenue) pscore(pscore_all)
_eststo sales_all_caliper05, r: reg diff_revenue i.lcr [iweight=_weight], vce(hc3)
*est store sales_all_caliper05
	rename _weight weight_didsales_all05


	*/
			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_revenue) pscore(pscore_won)
_eststo sales_won_caliper01, r: reg diff_revenue i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store sales_won_caliper01
	rename _weight weight_sales_won01
	
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_revenue) pscore(pscore_won)
_eststo sales_won_caliper05, r: reg diff_revenue i.lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store sales_won_caliper05
	rename _weight weight_sales_won05
	
			* sample = no outliers (bharat,ntpc larsen dropped high sales and differences)
psmatch2 lcr if sales_outliers == 0, radius caliper(0.1) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo sales_outliers_caliper01, r: reg diff_revenue i.lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
*est store sales_outliers_caliper01
	rename _weight weight_sales_outliers01

psmatch2 lcr if sales_outliers == 0, radius caliper(0.05) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo sales_outliers_caliper05, r: reg diff_revenue i.lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
*est store sales_outliers_caliper05
	rename _weight weight_sales_outliers05

***********************************************************************
* 	PART 6.2:  Alternative outcome variable: sales with continous treatment
***********************************************************************
* C1: Simple post-difference
_eststo csales_post, r:reg diff_revenue total_auctions_lcr

* C2: DiD
_eststo csales_did, r:reg diff_revenue total_auctions_lcr, vce(hc3)

* 1 Caliper radius matching

	* sample = all
psmatch2 lcr, radius caliper(0.1) outcome(post_revenue) pscore(pscore_all)
_eststo csales_all_caliper01, r: reg diff_revenue total_auctions_lcr [iweight=_weight], vce(hc3)
*est store sales_all_caliper01
	rename _weight cweight_didsales_all01

psmatch2 lcr, radius caliper(0.05) outcome(post_revenue) pscore(pscore_all)
_eststo csales_all_caliper05, r: reg diff_revenue total_auctions_lcr [iweight=_weight], vce(hc3)
*est store sales_all_caliper05
	rename _weight cweight_didsales_all05


	*/
			* sample = won
psmatch2 lcr if won_total > 0, radius caliper(0.1) outcome(post_revenue) pscore(pscore_won)
_eststo csales_won_caliper01, r: reg diff_revenue total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store sales_won_caliper01
	rename _weight cweight_sales_won01
	
psmatch2 lcr if won_total > 0, radius caliper(0.05) outcome(post_revenue) pscore(pscore_won)
_eststo csales_won_caliper05, r: reg diff_revenue total_auctions_lcr [iweight=_weight] if won_total > 0, vce(hc3)
*est store sales_won_caliper05
	rename _weight cweight_sales_won05
	
			* sample = no outliers (bharat,ntpc larsen dropped high sales and differences)
psmatch2 lcr if sales_outliers == 0, radius caliper(0.1) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo csales_outliers_caliper01, r: reg diff_revenue total_auctions_lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
*est store sales_outliers_caliper01
	rename _weight cweight_sales_outliers01

psmatch2 lcr if sales_outliers == 0, radius caliper(0.05) outcome(post_revenue) pscore(pscore_nosalesoutliers)
_eststo csales_outliers_caliper05, r: reg diff_revenue total_auctions_lcr [iweight=_weight] if sales_outliers == 0, vce(hc3)
*est store sales_outliers_caliper05
	rename _weight cweight_sales_outliers05

***********************************************************************
* Part 7.1 Make nice three panel table with Solar patents, cell patents and Sales for binary treatment variable		  			
***********************************************************************
	//top panel
esttab  post_patcaliper did_patcaliper all_patcaliper01 all_patcaliper05 won_patcaliper01 /// 
		won_patcaliper05 outliers_patcaliper01 outliers_patcaliper05 using three_panel.tex, replace  ///
		nobaselevels ///
		prehead("\begin{table}[htbp]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{Results of Matching combined with Difference in Differences} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
		posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel A: Solar PV Patents}} \\\\[-1ex]") ///
		fragment ///
		mgroups("" "All firms" "Winner firms" "All w/o outliers", ///
		pattern(1 0 1 0 1 0 1 0)) ///
		mtitles("Simple post difference" "DiD" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05") ///
		label /// 
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) 

//middle panel 
esttab  post_cell did_cell all_caliper01_cell all_caliper05_cell won_caliper01_cell won_caliper05_cell outliers_caliper01_cell ///
	outliers_caliper05_cell using three_panel.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel B: PV Module \& PV Cell Patents only}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 

//second middle panel 
esttab  post_binary did_binary all_caliper01_bin all_caliper05_bin won_caliper01_bin won_caliper05_bin /// 
	outliers_caliper01_bin outliers_caliper05_bin using three_panel.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel C: Post-LCR solar patent (binary)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 
	
//bottom panel 
esttab sales_post sales_did sales_all_caliper01 sales_all_caliper05 sales_won_caliper01 ///
	sales_won_caliper05 sales_outliers_caliper01 sales_outliers_caliper05 using three_panel.tex, ///
   	nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel D: Revenues (in INR)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers  ///
	prefoot("\hline") ///
	postfoot("\hline\hline\hline \multicolumn{8}{l}{\footnotesize Results in columns (1) \& (2) use unmatched counterfactuals and columns (3)-(8) use matched counterfactuals based on the specified parameters. }\\\multicolumn{5}{l}{\footnotesize Robust Standard errors in parentheses}\\\multicolumn{2}{l}{\footnotesize \sym{**} \(p<0.05\), \sym{*} \(p<0.1\)}\\ \end{tabular} \\ \end{table}")

***********************************************************************
* Part 7.2 Make nice three panel table with Solar patents, cell patents and Sales for continous treatment		  			
***********************************************************************
	//top panel
esttab  cpost_patcaliper cdid_patcaliper call_patcaliper01 call_patcaliper05 cwon_patcaliper01 /// 
		cwon_patcaliper05 coutliers_patcaliper01 coutliers_patcaliper05 using three_panel_continous.tex, replace ///
		nobaselevels ///
		prehead("\begin{table}[htbp]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{Adjusted for Treatment Intensity: Results of Matching combined with Difference in Differences} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
		posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel A: Solar PV Patents}} \\\\[-1ex]") ///
		fragment ///
		mgroups("" "All firms" "Winner firms" "All w/o outliers", ///
		pattern(1 0 1 0 1 0 1 0)) ///
		mtitles("Simple post difference" "DiD" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05") ///
		label /// 
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) 

//middle panel 
esttab  cpost_cell cdid_cell call_caliper01_cell call_caliper05_cell cwon_caliper01_cell cwon_caliper05_cell coutliers_caliper01_cell ///
	coutliers_caliper05_cell using three_panel_continous.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel B: PV Module \& PV Cell Patents only}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 

//second middle panel 
esttab  cpost_binary cdid_binary call_caliper01_bin call_caliper05_bin cwon_caliper01_bin cwon_caliper05_bin /// 
	coutliers_caliper01_bin coutliers_caliper05_bin using three_panel_continous.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel C: Post-LCR solar patent (binary)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 
	
//bottom panel 
esttab csales_post csales_did csales_all_caliper01 csales_all_caliper05 csales_won_caliper01 ///
	csales_won_caliper05 csales_outliers_caliper01 csales_outliers_caliper05 using three_panel_continous.tex, ///
   	nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel D: Revenues (in INR)}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers  ///
	prefoot("\hline") ///
	postfoot("\hline\hline\hline \multicolumn{8}{l}{\footnotesize Results in columns (1) \& (2) use unmatched counterfactuals and columns (3)-(8) use matched counterfactuals based on the specified parameters. }\\\multicolumn{5}{l}{\footnotesize Robust Standard errors in parentheses}\\\multicolumn{2}{l}{\footnotesize \sym{**} \(p<0.05\), \sym{*} \(p<0.1\)}\\ \end{tabular} \\ \end{table}")

	
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace

