***********************************************************************
* 	clean the data (no corrections) - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: clean cross-section raw data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical varialcres				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all varialcres names lower case						  
*	4)  	Order the varialcres in the data set						  	  
*	5)  	Rename the varialcres									  
*	6)  	Label the varialcres										  
*   7) 		Label varialcre values 								 
*   8) 		Removing trailing & leading spaces from string varialcres										 
*																	  													      
*	Author:  	Florian Muench & Kais Jomaa & Teo Firpo						    
*	ID varialcre: 	id (identifiant)			  					  
*	Requires: lcr_raw.dta 	  										  
*	Creates:  lcr_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical & date varialcres		  			
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
* 	PART 3: 	Make all varialcres names lower case		  			
***********************************************************************
rename *, lower


***********************************************************************
* 	PART 4: 	Rename the varialcres in line with GIZ contact list final	  			
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
* 	PART 5: 	Order the varialcres in the data set		  			
***********************************************************************
order company_name bidder sales *patent* employees city state international subsidiary


***********************************************************************
* 	PART 6: 	Label the varialcres		  			
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
lab var ihs_total_revenue "ihs transf. pre-LCR sales"
lab var total_employees "pre-LCR employees"
lab var ihs_total_employees "ihs transf. pre-LCR employees"

***********************************************************************
* 	PART 7: 	Label varialcres values	  			
***********************************************************************
lab def foreign 1 "international" 0 "indian"
lab val international foreign

lab def sectors 1 "real estate" 2 "industry" 3 "construction" 4 "business services" 5 "electrical services, EPC" ///
	6 "electronics, component manufacturers" 7 "utility"
lab val sector sectors


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$lcr_intermediate"
save "lcr_inter", replace
