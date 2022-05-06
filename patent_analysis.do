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
use "${lcr_raw}/solar_components_updated_HS.dta", clear
set scheme plotplain	
*rename company_name for merge
rename companyname_correct company_name

	* set the directory to propensity matching folder
cd "$lcr_final"


*Merge via company name
merge m:1 company_name using lcr_final
drop if _merge==2

***********************************************************************
* 	PART 2:  re-name some of the elements for better understanding			
***********************************************************************
replace ipcsubgroupscomponents = "combined PV technology" if ipcsubgroupscomponents == "Combinations of the groups above"
replace ipcsubgroupscomponents = "common cell elements" if ipcsubgroupscomponents == "Common Elements"


************************************************************************
* 	PART 3:  descriptives		
*************************************************************************
graph pie solarpatent, over(ipcsubgroupscomponents) plabel(_all sum)
graph pie solarpatent, over(ipcgroup) plabel(_all sum)
graph pie solarpatent if lcr==1, over(ipcgroup) plabel(_all sum)
graph pie solarpatent if lcr==0, over(ipcgroup) plabel(_all sum)
tab2 ipcgroup lcr, column
return list
*Export to latex
estpost tab lcr ipcgroup
*esttab, cell("b pct(fmt(a))")  collab("Freq." "Percent")  noobs nonumb nomtitle tex
cd "$final_figures"
graph hbar (sum) solarpatent, over(lcr) over (ipcgroup) blabel(bar)
gr export patent_bar.png, replace 

