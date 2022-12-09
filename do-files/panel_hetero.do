***********************************************************************
* 			Panel data heterogeneity			
***********************************************************************
*	
*	PURPOSE: Analysing which firms patented controlling for time-fixed effects		  								  
*				  
*																	  
*	OUTLINE:														  
*																	 																      *
*	Author: Florian Münch
*	ID variable: company_name, year		  									  
*	Requires:	eventstudy_final

***********************************************************************
* 	PART 1: import panel data	  						
***********************************************************************
use "${lcr_final}/event_study_final", clear	
xtset company_name year
***********************************************************************
* 	PART 2:  Which companies patent at all? 			
***********************************************************************
eststo logit_sector, r:xtlogit solarpatent lcr_participant ib4.sector indian total_revenue i.year, fe
