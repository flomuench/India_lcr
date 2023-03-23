***********************************************************************
* 	LCR India - clean cross-section								  		  
***********************************************************************
*																	  
*	PURPOSE: clean cross-section data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Rename the variables
*	5)  	Order the variables in the data set
*	6)  	Label the variables					  
*   7) 		Label variables values
*    
*	Author:  	Florian Münch, Fabian Scheifele
*	ID variable: 	company_name
*	Requires: lcr_raw.dta 	  										  
*	Creates:  lcr_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical & date variables		  			
***********************************************************************
use "${lcr_raw}/lcr_raw", clear

{
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
}
	
***********************************************************************
* 	PART 2: 	Drop all text windows from the survey		  			
***********************************************************************
*drop id domesticduns dunsno rough_estimation_foreign0indian1 primarycountryregion

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Rename the variables
***********************************************************************
* rename
rename totalemployees employees
*rename primarycity city
*rename primarystateprovince state
*rename foreign0trulyindian international
*rename issubsidiary subsidiary
*rename lineofbusiness lob
*rename solarpatent solarpatents
*rename otherpatent otherpatents
rename final_vgf_after_era vgf_total

***********************************************************************
* 	PART 5: 	Order the variables in the data set		  			
***********************************************************************
order company_name bidder sales *patent* employees city state international subsidiary

***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
label var employees "employees at HQ"
label var city "primary city"
label var state "primary state"
label var international "foreign vs. indian company"
label var lob "primary line of business"
lab var indian "indian company"
lab var energy_focus "main business is energy"
lab var age "age"
lab var soe_india "Indian SOE"
lab var empl "employees"
lab var manufacturer "manufacturing company"
lab var manufacturer_solar "solar manufacturing"
lab var sales "total sales in INR"
lab var subsidiary "subsidiary of mother company"
lab var sector "sector"
lab var part_jnnsm_1 "part 1 NSM"
lab var vgf_total " total VGF in INR"
lab var ihs_sales "sales, ihs transformed"
lab var total_revenue "pre-LCR sales"
lab var total_employees "pre-LCR employees"

***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
lab def foreign 1 "international" 0 "indian"
lab val international foreign

lab def sectors 1 "real estate" 2 "industry" 3 "construction" 4 "business services" 5 "electrical services, EPC" ///
	6 "electronics, component manufacturers" 7 "utility"
lab val sector sectors

lab def manufacturers 1 "manufacturer" 0 "no manufacturer"
lab val manufacturer manufacturers 

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_intermediate}/lcr_inter", replace
