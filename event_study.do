***********************************************************************
* 			lcr India paper: create a balanced firm-year panel and test-pre trends					
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
*	1)		import the collapsed firm-year dataset
*	2) 		transform to panel dataset and use tsfill to have balanced time periods
*	3)		merge company specific data
*	4) 		create event study dummies
*	5) 		Do event study regression without controls
*	6)		Do event study regression with controls
*																	 																      *
*	Author: Fabian  														  
*	ID variable: company_name		  									  
*	Requires:	eventstudy_final
*	Creates:	

***********************************************************************
* 	PART 1: import the collapsed dataset		  						
***********************************************************************
cd "$lcr_final"

use "${lcr_final}/event_study", clear	

***********************************************************************
* 	PART 2: event study without controls	  						
***********************************************************************
*simple OLS with interaction term of event study and treatment dummy without controls and fixed effects
reg solarpatent t_20*##lcr

*with firm-fixed effects (treatment alone is omitted now, but interaction terms still there)
xtreg solarpatent t_20*##lcr, fe

*poisson model does somehow not converge
xtpoisson solarpatent t_20*##lcr

*normal poisson without fixed effects
poisson solarpatent t_20*##lcr

*zero-inflated model (does not converge
*solarpatent is zero for 1911/1955 firm-year instances (97%) so zero inflated model needed
zinb solarpatent t_20*, inflate (t_20*)
