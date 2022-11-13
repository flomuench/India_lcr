***********************************************************************
* 			model choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: decide whether to apply a logit or a probit model			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) logit
* 	2) probit
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

	* useful links
* https://thomasgstewart.github.io/propensity-score-matching-in-stata/
* http://kaichen.work/?p=1522
*https://www.ssc.wisc.edu/sscc/pubs/stata_psmatch.htm
* https://www.stata.com/manuals/teteffectspsmatch.pdf
* https://blogs.worldbank.org/impactevaluations/what-do-you-need-do-make-matching-estimator-convincing-rhetorical-vs-statistical

***********************************************************************
* 	PART 1: visualise the distribution of the DV solar patents  			
***********************************************************************
	* OLS possible or better to use count model?
		* Visualise distribution
kdensity solarpatents
kdensity solarpatents if lcr == 1, addplot(kdensity solarpatents if lcr == 0)
kdensity post_solar_patent

		* Check the (unconditional) variance
sum post_solar_patent
scalar patent_variance = r(sd)^2
	
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
