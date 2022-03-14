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
cd "$lcr_rt"

***********************************************************************
* 	PART 2:  Radius matching to define sample of firms
***********************************************************************
	* caliper = 0.25
	* common support = 0.2 - 0.95
psmatch2 lcr if patent_outliers == 0, radius caliper(0.25) outcome(post_solar_patent) pscore(pscore)

***********************************************************************
* 	PART 3:  DiD estimation
***********************************************************************
	* without controls
_eststo did_no_controls, r: reg dif_solar_patents i.lcr [iweight=_weight], vce(robust)

	* controls for variables that were still imbalanced after matching
_eststo did_controls, r: reg dif_solar_patents i.lcr c.won_total c.pre_not_solar_patent [iweight=_weight], vce(robust)

	* export results in a table
esttab did_no_controls did_controls using did.csv, replace ///
	title("Difference-in-difference combined with matching") ///
	mtitles("no controls" "imbalance controls") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	addnotes("DiD based on sum of solar patents 2012-2021 minus 1982-2011." "Radius matching with caliper = .25. & common support 0.2-0.95." "Robust standard errors in parentheses.", size(small))



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
