***********************************************************************
* 			lcr India paper: visualize staggered Did, outcomes
***********************************************************************														  
*	PURPOSE: clean panel dataset			  								  
*				  
*																	  
*	OUTLINE:														  
*	Author: Florian, Fabian  														  
*	ID variable: company_name, year	  									  
*	Requires:	event_study_raw
*	Creates:	event_study_final

***********************************************************************
* 	PART 1: import panel data set					
***********************************************************************
use "${lcr_final}/event_study_raw", clear


***********************************************************************
* 	PART 2: visualize staggered Did
***********************************************************************

