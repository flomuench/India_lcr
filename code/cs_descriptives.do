***********************************************************************
* 			India LCR: descriptive statistics				  	  
***********************************************************************
*
*	PURPOSE: generate descriptive statistics
*																	  
*	OUTLINE:														  
*	1) 		set the scene
*	2) 		balance table
*	3)		table 1
*	4)		Figure 5
*	5)		Figure 12 Share of LCR auction wins among LCR firms
*	6)		Figure 14
*	7)		Figure 11 Auction participants by main sector
*	8)		Figure 15 Solar patents by manufacturing status and auction type				
*											      
*	Author:  	Florian Münch, Fabian Scheifele
*	ID variable: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
	* import data
use "${lcr_final}/lcr_final", clear

	* adjust graphical settings
set scheme plotplain	
set graphics on

	*Shorten name of Development corporation odisha for visual reasons
replace company_name = "odisha" if company_name == "development corporation odisha"

	*set working directory to final figures
cd "$final_figures"

************************************************************************
* 	PART 2: balance table			
************************************************************************
	* sample level statistics
local firm_characteristics indian patentor pre_not_solar_patent pre_solar_patent post_solar_patent post_not_solar_patent soe_india age energy_focus manufacturer manufacturer_solar subsidiary 
iebaltab `firm_characteristics', grpvar(lcr) save(baltab_firmlevel) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)	
			 
	* export firm-balance table to latex
iebaltab `firm_characteristics', grpvar(lcr) savetex(baltab_firmlevel) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

************************************************************************
* 	PART 3: Table 1			
************************************************************************

local table1 post_solar_patent pre_solar_patent lcr indian manufacturer ihs_total_revenue ihs_post_revenue log_total_employees part_jnnsm_1
codebook `table1'
estpost tabstat `table1', listwise ///
        statistics(mean sd min max) columns(statistics)
esttab . using table1.tex, cells("mean(fmt(a3)) sd(fmt(a3)) min(fmt(a3)) max(fmt(a3))") replace /// 
	title("Descriptive Statistics"\label{table1}) ///
	label
	

************************************************************************
* 	PART 4: Figure 5		
************************************************************************
local prepostsolar pre_solar_patent post_solar_patent
graph bar (sum)  `prepostsolar', over(lcr, label(labs(large))) ///
	blabel(total, size(medium)) ///
	legend(label(1 "solar patents 2001-2010") label(2 "solar patents 2011-2020") rows(1) pos(6)) ///
	name(prepost_solar_LCR, replace)
gr export prepost_solar_LCR.png, replace
	
************************************************************************
* 	PART 5: Figure 12 Share of LCR auction wins among LCR firms
************************************************************************
graph hbar share_lcr_won if won_lcr==1, over(company_name, sort(share_lcr_won) descending) ///
	ytitle("Share of LCR auction wins (of total wins) among firms that won at least 1 LCR auction", size(small)) yline(0.5)
gr export treatment_intensity.png, replace

************************************************************************
* 	PART 6: Figure 11 Auction participants by main sector
************************************************************************
graph hbar (count), over(sector) by(lcr, note("") iscale(0.8)) blabel(bar) ///
	ytitle("Number of firms")
graph export firms_frequency_sector.png, replace

************************************************************************
* 	PART 7: Figure 14
************************************************************************
graph hbar (sum) solarpatents, over (sector) by(lcr, note("") iscale(0.8)) ///
 ytitle("Number of solar patents") blabel (bar) 
graph export solarpatents_sector.png, replace


***********************************************************************
* 	PART 8: Figure 15 Solar patents by manufacturing status and auction type				
************************************************************************
graph bar (sum) pre_solar_patent post_solar_patent if won_total>0 ,  by(winner_types, note("") iscale(0.8) ) ///
	over(manufacturer, lab(labs(small))) blabel(bar, pos(center)) legend(pos(6)  ///
	label (1 "No. of solar patents prior to announcement of LCR policy (pre-2011)") label(2 "No of solar patents after announcement of LCR policy (2011-2020)"))
gr export manufacturer_LCR_solarpatents.png, replace



set graphics off
