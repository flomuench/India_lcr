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
	
	* outcome variable: mean & SD
		* patents
			* Howell 2017: 
				* descriptive statistics, table 1 p. 5
					* pre: mean =  1.9, SD = 7.5 
					* post: mean =  2, SD = 11
				* treatment effect (p. 9): 
					*"phase 1 award increased cite-weighted patents 2.5 times" (nbreg)
					*"phas 1 award increased cite-weighted patents 30%" (OLS)
	
	
	* measures:
		* sample size
		* MDE
			* what could we expect?
				* how much more did the Indian government pay?
				* how high are sales per patent for sample companies?
		* 
/* 
Given we currently only dispose the number of patent filed per company
as outcome data, we focus power size calculations on patents. Existing
research about LCR is exclusively qualitative in nature and draws conclusions
about LCR effectiveness based on expert interviews rather than firm-level data,
which is why we cannot use results from previous literature for power calculations.
Instead, we use a recent, quasi-experimental evaluation of the US Department
of Energy Small Business Innovation Research program that consists of
mostly of R&D grants for proof-of-concept frontier innovation in emerging 
energy technologies, such as notably solar (Howell, 2017). While the US context
is certainly not comparable to low-income countries, comparing LCR to what
would have possible through a popular, alternative policy, namely R&D support
*/
	* Calculate hypothetical power
		* scenario 1: take sample mean without 1 outlier
			* m = .71, SD = 3.65
sum solarpatents if patent_outlier == 0
local m = r(mean)
local sd = r(sd)
power twomeans `m', diff(0.5 1.5 2.5 3.5 4.5) sd(1 2 3 4 5) n1(30 35 40) n2(54) ///
	table
matrix power1 = r(pss_table)

			* export to Excel
putexcel set power, replace
putexcel A1 = matrix(power1), colnames
putexcel close

		* scenario 2: matching reduces SD
	
/* coding for export of visualisation
	graph(name(power_hypothetical, replace))
gr export power_hypothetical.png, replace
*/
egen tsales = sum(sales) if solarpatents > 0 & solarpatents < .
sum tsales 
local sales = r(min)
egen tpatents = sum(solarpatents) if solarpatents > 0 & solarpatents < .
sum tpatents
local patents = r(min)

scalar sales_patent = `sales'/`patents'
drop tsales tpatents
		* suggests: 20,000,000,000 sales per patent
		* how much additional sales did LCR generate?
		

	* Calculate pre-matching power
		* get mean and standard deviation in post solar patents
sum post_solar_patent if patent_outlier == 0 & lcr == 0
local nc = r(N)
local pcm = r(mean)
local pcsd = r(sd)
sum post_solar_patent if patent_outlier == 0 & lcr == 1
local nt = r(N)
local ptm = r(mean)
local ptsd = r(sd)

matrix patents = (`nc', `nt' \ `pcm', `ptm' \ `pcsd', `ptsd')
matrix colnames patents = no_LCR LCR
matrix rownames patents = observations mean SD

		* actual data: simple difference btw LCR vs. no LCR before matching
power twomeans `pcm' `ptm', sd1(`pcsd') sd2(`ptsd') n1(`nc') n2(`nt') 
	
	
	* Calculate post matching power
sum post_solar_patent if _support == 1 & lcr == 0
local nc = r(N)
local pcm = r(mean)
local pcsd = r(sd)
sum post_solar_patent if _support == 1 & lcr == 1
local nt = r(N)
local ptm = r(mean)
local ptsd = r(sd)

matrix patents2 = (`nc', `nt' \ `pcm', `ptm' \ `pcsd', `ptsd')
matrix colnames patents2 = no_LCR LCR
matrix rownames patents2 = observations mean SD

		* actual data: simple difference btw LCR vs. no LCR before matching
power twomeans `pcm' `ptm', sd1(`pcsd') sd2(`ptsd') n1(`nc') n2(`nt') 

	
	
	
	
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
