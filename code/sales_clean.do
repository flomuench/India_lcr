***********************************************************************
* 	clean the data (no corrections) - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: clean firm-level sales and employee data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Keep only important variables and actual observations				          
*	2)   	Format string & numerical & date variables					  
*	3)  	Make all variables names lower case						  
*	4)  	Rename the variables						  	  
*	5)  	Adapt founding year based on improved information									  
*	6)  	Order the variables										  
*   7) 		Label variables 								 
*   8) 		Declare as panel data set										 
*																	  													      
*	Author:  	Florian Muench, Fabian Scheifele					    
*	ID variable: 	company_name			  					  
*	Requires: lcr_sales_raw.dta 	  										  
*	Creates:  lcr_sales_inter.dta			                                  
***********************************************************************
* 	PART 1: Keep only important variables and actual observations		  					  			
***********************************************************************
use "${lcr_raw}/lcr_sales_raw", clear

		* keep only important variables
keep company_name year total_employees total_revenueinINR founded

		* keep only actual observations
sum year
keep in 1/`r(N)'
sort company_name year, stable

	
***********************************************************************
* 	PART 3: 	Format string & numerical & date variables
***********************************************************************
	* destring numerical variables + correct missing values
foreach var in /* total_revenueinINR */ total_employees {
	replace `var' = "" if `var' == "-"
	destring `var', replace
}

	* string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-30s `strvars'
	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

	* make all string obs lower case
foreach x of local strvars {
	replace `x' = lower(stritrim(strtrim(`x')))
	}
	
format %9.0g founded total_employees

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower


***********************************************************************
* 	PART 4: 	Rename the variables
***********************************************************************
rename total_revenueininr total_revenue

***********************************************************************
* 	PART 5: 	Adapt founding year based on improved information 
***********************************************************************
replace founded=2006 if company_name=="alfanar"
replace founded=2015 if company_name=="bastille"
replace founded=2015 if company_name=="cambronne"
replace founded=2015 if company_name=="duroc"
replace founded=2011 if company_name=="natems"
replace founded=2005 if company_name=="rishabh"
replace founded=2015 if company_name=="segur"
replace founded=2013 if company_name=="terraform"

***********************************************************************
* 	PART 6: 	Order the variables in the data set		  			
***********************************************************************
order company_name year total_revenue
sort company_name year

***********************************************************************
* 	PART 7: 	Label the variables		  			
***********************************************************************
lab var total_employees "number of employees"


***********************************************************************
* 	PART 8: 	Declare as panel data set
***********************************************************************
	* make sure company_name year are unique identifiers
duplicates report company_name year
duplicates list company_name year

	* make company_name a numerical variable
encode company_name, gen(companyname)
xtset companyname year, y
sort company_name year, stable

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_intermediate}/lcr_sales_inter", replace
