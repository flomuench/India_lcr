***********************************************************************
* 	India LCR  - correct cross-section data set
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses	  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		import data
* 	2) 		miscallaneous corrections
*	3)   	replace all MV = 0 for firms that did never patent
*	4)  	check for missing values
*	5)  	Identify duplicates
*	6)  	Drop firms that were in Ben's base only
*	7)		Save the changes made to the data
*
*				      
*	Author:  	Florian Münch, Fabian Scheifele
*	ID variable: 	company_name
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  import data  			
***********************************************************************
use "${lcr_intermediate}/lcr_inter", clear

***********************************************************************
* 	PART 2:  miscallaneous corrections
***********************************************************************
replace international = 0 if international == .

***********************************************************************
* 	PART 3:  replace all MV = 0 for firms that did never patent
***********************************************************************
foreach x in pre_solar_patent pre_not_solar_patent pre_total_patent post_solar_patent post_not_solar_patent post_total_patent historic_solar_patent historic_not_solar_patent historic_modcell_patent pre_modcell_patent post_modcell_patent {
	replace `x' = 0 if `x' == .
}

//historic_modcell_patent pre_modcell_patent post_modcell_patent
***********************************************************************
* 	PART 4:  check for missing values
***********************************************************************
misstable sum, all

***********************************************************************
* 	PART 5:  Identify duplicates
***********************************************************************
duplicates report company_name
duplicates tag company_name, gen(dup_company)

***********************************************************************
* 	PART 6: Drop firms that were in Ben's base only
***********************************************************************
*br solarpatents if benonly == 1
*drop if benonly == 1 /* 11 firms with no single solar patent */

drop if total_auctions_lcr == . & total_auctions_no_lcr == .

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_intermediate}/lcr_inter", replace
