***********************************************************************
* 			variable choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: visualise firms participation in auctions (explanatory side)			  							  
*	& innovation performance (outcome side), plus firm characteristics
*																	  
*	OUTLINE:														  
*	1) 
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear
set scheme plotplain	
set graphics on

*Shorten name of Development corporation odisha for visual reasons
replace company_name = "odisha" if company_name == "development corporation odisha"

***********************************************************************
* 	PART 2: descriptive statistics for final paper 	  						
************************************************************************
*set working directory to final figures
cd "$final_figures"
* sample level statistics
local firm_characteristics indian patentor pre_not_solar_patent pre_solar_patent post_solar_patent post_not_solar_patent soe age energy_focus manufacturer manufacturer_solar subsidiary 
iebaltab `firm_characteristics', grpvar(lcr) save(baltab_firmlevel) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)	
			 
*export firm-balance table to latex
iebaltab `firm_characteristics', grpvar(lcr) savetex(baltab_firmlevel) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)	
	
graph hbar (count), over(sector, sort(1) lab(labs(small))) ///
	blabel(total, format(%9.0g) pos(center)) ///
	ytitle("number of firms") ///
	name(firms_pie_sectors, replace)
gr export firms_pie_sectors.png, replace

	
graph pie, over(sector) plabel (_all sum)  descending ///
	legend(pos(6) rows(2)) ///
	intensity(*0.5)


*Table 1 descriptive statistics

local table1 post_solar_patent pre_solar_patent lcr indian manufacturer ihs_total_revenue ihs_post_revenue log_total_employees part_jnnsm_1
codebook `table1'
estpost tabstat `table1', listwise ///
        statistics(mean sd min max) columns(statistics)
esttab . using table1.tex, cells("mean(fmt(a3)) sd(fmt(a3)) min(fmt(a3)) max(fmt(a3))") replace /// 
	title("Descriptive Statistics"\label{table1}) ///
	label
	
	
*Shaded Bar chart with treatment intensity
graph hbar share_lcr_part if lcr==1, over(company_name, sort(share_lcr_part) descending) ///
	ytitle("Share of auction participations that had LCR") yline(0.5)
gr export treatment_intensity.png, replace


graph hbar (sum) solarpatents, over (sector) by(lcr, note("") iscale(0.8)) ///
 ytitle("Number of solar patents") blabel (bar) 
graph export solarpatents_sector.png, replace

graph hbar (count), over(sector) by(lcr, note("") iscale(0.8)) blabel(bar) ///
	ytitle("Number of firms")
graph export firms_frequency_sector.png, replace

***********************************************************************
* 	PART 3: Other descriptive statistics  	  						
************************************************************************	
	* define local for pre-post comparisons
cd "$lcr_descriptives"
local prepostsolar pre_solar_patent post_solar_patent
local prepostother pre_not_solar_patent post_not_solar_patent
local preposttotal pre_total_patents post_total_patents

	* pre-post solar and non solar patents
graph bar (sum)  `prepostsolar' `prepostother', ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar and non-solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") ///
	label(3 "non-solar patents 1982-2011") label(4 "non-solar patents 2012-2021") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_all, replace)
gr export prepost_all.png, replace

	* pre-post solar only
graph bar (sum)  `prepostsolar', ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") rows(2) pos(6)) ///
	name(prepost_solar, replace)
gr export prepost_solar.png, replace


	* pre-post solar and non solar patents without outliers
graph bar (sum)  `prepostsolar' `prepostother' if patent_outliers == 0, ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar and non-solar patents pre-and post auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") ///
	label(3 "non-solar patents 1982-2011") label(4 "non-solar patents 2012-2021") rows(2) pos(6)) ///
	note("Excludes 3 firms that are outliers in in terms of total patents & have only participated in 1 auctions." "Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_no_outlier, replace)
gr export prepost_no_outlier.png, replace

	* pre-post solar only without outliers
graph bar (sum)  `prepostsolar' if patent_outliers == 0, ///
	blabel(total, size(vsmall)) ///
	title("{bf: Solar patents pre-and post LCR auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2013-2020", size(small)) ///
	legend(label(1 "solar patents 1982-2011") label(2 "solar patents 2012-2021") rows(2) pos(6)) ///
	note("Authors own calculations based on patent applications at the Indian patent office.", size(vsmall)) ///
	name(prepost_no_outlier, replace)
gr export prepost_no_outlier.png, replace


	* pre-post solar LCR vs. no LCR only without outliers
graph bar (sum)  `prepostsolar' if patent_outliers == 0, over(lcr) ///
	blabel(total, size(medium)) ///
	title("{bf: Solar patents pre-and post LCR auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2011-2020", size(small)) ///
	legend(label(1 "solar patents 2001-2010") label(2 "solar patents 2011-2020") rows(1) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_solar_LCR_no_outlier, replace)
gr export prepost_solar_LCR_no_outlier.png, replace

cd "$final_figures"
*pre-post LCR vs. no LCR incl. outliers
graph bar (sum)  `prepostsolar', over(lcr, label(labs(large))) ///
	blabel(total, size(medium)) ///
	legend(label(1 "solar patents 2001-2010") label(2 "solar patents 2011-2020") rows(1) pos(6)) ///
	name(prepost_solar_LCR, replace)
gr export prepost_solar_LCR.png, replace

	/* pre-post module/cell patents by LCR
graph bar (sum) pre_modcell_patent post_modcell_patent if patent_outliers == 0, over(lcr) ///
	blabel(total, size(vsmall)) ///
	title("{bf: Module & cell patents pre & post LCR auctions in India}") ///
	subtitle("Firms that participated in SECI solar auctions between 2011-2020", size(small)) ///
	legend(label(1 "cell/module patents 2001-2010") label(2 "cell/module  patents 2011-2020") rows(2) pos(6)) ///
	note("Authors own calculations based on patent application at Indian patent office.", size(vsmall)) ///
	name(prepost_cellpatents_no_outlier, replace)
gr export prepost_cellpatents_no_outlier.png, replace
*/
cd "$lcr_descriptives"



	* firm level statistics
cd "$final_figures"
gr hbar (sum) post_solar_patent if post_solar_patent > 0 & patent_outliers == 0, over(company_name) ///
	by(lcr) ///
	blabel(total) ///
	ytitle("Number of filed solar patents 2013-2020") ///
	name(firms_LCR_solarpatents, replace)
gr export firms_LCR_solarpatents.png, replace
cd "$lcr_descriptives"


	* difference in solar patents
gr hbar (sum) dif_solar_patents if solarpatents > 0 & solarpatents != ., over(company_name) ///
	by(lcr, title("{bf:Difference in firms' solar patents & their participation in LCR auctions}") note("Authors own calculations based on patent application at Indian patent office & SECI auction archives.", size(vsmall))) ///
	blabel(total) ///
	ytitle("Only 14 out of 116 (12%) participating firms ever filed a solar patented." "Difference solar patents 1982-2011 vs. 2012-2021") ///
	name(firms_LCR_solarpatents, replace)
gr export firms_LCR_dif_solarpatents.png, replace

	*LOOK AT PATENTING AMONG MANUFACTURERS & NON-manufacturers (NEED VALUE LABELS TO LOOK NICE)

graph bar (sum) pre_solar_patentor post_solar_patentor if won_total>0, ///
 over(lcr_won) over(manufacturer) blabel(bar)


***********************************************************************	

***********************************************************************
* 	PART 2: auction participation 	  						
***********************************************************************

	* participation in LCR auctions
		* only LCR
		* LCR & no LCR
		* only no LCR auctions
		
		
	* price / bid price
	
gr bar final_price_after_era_lcr final_price_after_era_no_lcr, blabel(total)


gr bar final_price_after_era_lcr final_price_after_era_no_lcr if lcr_both == 1, blabel(total)






set graphics off
