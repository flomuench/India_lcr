***********************************************************************
* 			model choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: decide whether to apply a logit or a probit model			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) sector
* 	2) gender
* 	3) onshore / offshore  							  
*	4) produit exportable  
*	5) intention d'exporter 			  
*	6) une opération d'export				  
*   7) export status  
*	8) age
*	9) eligibility	
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
use "${lcr_intermediate}/lcr_final", clear

	* useful links
* https://thomasgstewart.github.io/propensity-score-matching-in-stata/
* http://kaichen.work/?p=1522
*https://www.ssc.wisc.edu/sscc/pubs/stata_psmatch.htm
* https://www.stata.com/manuals/teteffectspsmatch.pdf
* https://blogs.worldbank.org/impactevaluations/what-do-you-need-do-make-matching-estimator-convincing-rhetorical-vs-statistical

***********************************************************************
* 	PART 1: visualise the distribution of the DV solar patents  			
***********************************************************************
	* possible or better to use count model?

kdensity solarpatents

probit solarpatents
margins, predict(xb)

logit solarpatents
margins, predict(l_solarpatents)

br solarpatents*

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
