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
* 	PART 2: estimation with xtevent package (DOES NOT WORK)		  						
***********************************************************************
xtset company_name2 year_application
*xtevent solarpatent, pol(event) w(8)
***********************************************************************
* 	PART 2: event study without controls	  						
***********************************************************************
*simple OLS with interaction term of event study and treatment dummy without controls and fixed effects
reg solarpatent t_20*##lcr, vce(hc3)
coefplot, vertical drop(_cons 1.t_2004 1.t_2005 1.t_2006 1.t_2007 1.t_2008 1.t_2009 1.t_2010 1.t_2011 1.t_2012 1.t_2013 1.t_2014 1.t_2015 1.t_2016 1.t_2017 1.t_2018 1.t_2019 1.t_2020 1.lcr) yline(0) plotlabel(2004(1)2020)
*with firm-fixed effects (treatment alone is omitted now, but interaction terms still there)
xtreg solarpatent t_20*##lcr, fe
coefplot, vertical drop(_cons 1.t_2004 1.t_2005 1.t_2006 1.t_2007 1.t_2008 1.t_2009 1.t_2010 1.t_2011 1.t_2012 1.t_2013 1.t_2014 1.t_2015 1.t_2016 1.t_2017 1.t_2018 1.t_2019 1.t_2020 1.lcr) yline(0) plotlabel(2004(1)2020)

*FE poisson model
xtpoisson solarpatent t_20*##lcr, fe

*normal poisson without fixed effects
poisson solarpatent t_20*##lcr

*zero-inflated model (does not converge
*solarpatent is zero for 1911/1955 firm-year instances (97%) so zero inflated model needed
*zinb solarpatent t_20*, inflate (t_20*)

***********************************************************************
* 	PART 3: event study conditional on matching 						
***********************************************************************
*caliper =0.1
psmatch2 lcr, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_all)
reg solarpatent t_20*##lcr [iweight=_weight], vce(hc3)

*caliper =0.05
psmatch2 lcr, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_all)
reg solarpatent t_20*##lcr [iweight=_weight], vce(hc3)

*caliper =0.1, nooutliers
psmatch2 lcr if patent_outliers ==0, radius caliper(0.1) outcome(post_solar_patent) pscore(pscore_nooutliers)
reg solarpatent t_20*##lcr [iweight=_weight], vce(hc3)

*caliper =0.05, nooutliers
psmatch2 lcr if patent_outliers ==0, radius caliper(0.05) outcome(post_solar_patent) pscore(pscore_nooutliers)
reg solarpatent t_20*##lcr [iweight=_weight], vce(hc3)
