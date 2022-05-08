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
import delimited "${lcr_raw}/solar_patents_addinfo.csv"	

	* set the directory to propensity matching folder
cd "$lcr_final"


*Merge via company name
merge m:1 company_name using lcr_final
drop if _merge==2

***********************************************************************
* 	PART 2:  re-name some of the elements for better understanding			
***********************************************************************
replace subgroups = "cells or panels" if subgroups == "Combinations of the groups above"
replace subgroups = "H02N6/00" if ipc == "H02N6/00"
replace subgroups = "common cell elements" if subgroups == "Common Elements"
replace group= "cells or panels" if subgroups == "cells or panels"
replace group = "H02N6/00" if subgroups == "H02N6/00"
*rename some of the variables
rename solarpatentx solarpatent

************************************************************************
* 	PART 3:  descriptives		
*************************************************************************
graph pie solarpatent, over(subgroups) plabel(_all sum)
graph pie solarpatent, over(group) plabel(_all sum)
graph pie solarpatent if lcr==1, over(group) plabel(_all sum)
graph pie solarpatent if lcr==0, over(group) plabel(_all sum)

tab2 group lcr, column
return list


*Export to latex
*estpost tab lcr ipcgroup
*esttab, cell("b pct(fmt(a))")  collab("Freq." "Percent")  noobs nonumb nomtitle tex
cd "$final_figures"
graph hbar (sum) solarpatent, over(lcr) over (group) blabel(bar)
gr export patent_bar.png, replace 

graph hbar (sum) solarpatent if app_year>2012, over(lcr) over (group) blabel(bar)
graph hbar (sum) solarpatent if app_year>2012, over(lcr,lab(labs(vsmall))) over(subgroups,lab(labs(vsmall))) blabel(bar)

collapse (sum) solarpatent, by(app_year lcr)
graph twoway (line solarpatent app_year if lcr==1, lcolor(red)) ///
(line solarpatent app_year if lcr==0, lcolor(blue)), legend (lab(1 "LCR firm") lab(2 "non-LCR firm")) xline(2013)



