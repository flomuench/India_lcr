***********************************************************************
* 			power size calculations - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: 				  							  
*	
*																	  
*	OUTLINE:														  

*
*																	  															      
*	Author:  	Florian Münch & Fabian Scheifele					  
*	ID variable: 	company_name			  					  
*	Requires: lcr_final.dta 	  								  
*	Creates:  lcr_final.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_final}/lcr_final", clear

	* set the directory to propensity matching folder
cd "$lcr_psm"


***********************************************************************
* 	PART 2:  Power size calculations  			
***********************************************************************
	* useful ressource: David Mckenzie blog post: https://blogs.worldbank.org/impactevaluations/power-calculations-for-propensity-score-matching
	* influence on power
		* common support --> N in TG & CG
			* assumption: 90% in TG, 66% in CG
		* matching result --> SD in TG & CG
			* assumption: matching should remove firms without patent
				* and thus increase SD in CG close to SD in TG
	* measures:
		* sample size
		* MDE
			* what could we expect?
				* how much more did the Indian government pay?
				* how high are sales per patent for sample companies?
		* 
	* get mean and standard deviation in post solar patents
sum post_solar_patent if patent_outlier == 0 & lcr == 0
local nc = r(N)
local pcm = r(mean)
local pcsd = r(sd)
sum post_solar_patent if patent_outlier == 0 & lcr == 1
local nt = r(N)
local ptm = r(mean)
local ptsd = r(sd)

	* calculate first pre-matching power
		* treatment effect: 1 to 5 patents
power twomeans 1, diff(1) sd1(`pcsd') sd2(`ptsd') n1(33) n2(81) 
power twomeans 1, diff(1) sd1(`pcsd') sd2(`ptsd') n1(33) n2(52) 



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off

	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
