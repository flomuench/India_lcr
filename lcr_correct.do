***********************************************************************
* 			corrections for India LCR effect on innovation project									  	  
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		correct unique identifier - matricule fiscal
*	3)   	Replace string with numeric values						  
*	4)  	Convert string to numerical varialcres	  				  
*	5)  	Convert prolcrematic values for open-ended questions		  
*	6)  	Traduction reponses en arabe au francais				  
*   7)      Rename and homogenize the observed values                   
*	8)		Import categorisation for opend ended QI questions
*	9)		Remove duplicates
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${lcr_intermediate}/lcr_inter", clear



***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************
	* make sales numeric
		* remove dollar sign from sales
split sales, parse($) gen(sales)
drop sales1 sales
rename sales2 sales
		* remove the commas
replace sales = ustrregexra(sales,",","")
		* destring sales
destring sales, replace
format sales %-20.3fc
order sales, a(bidder)


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************


***********************************************************************
* 	PART 4:  Convert string to numerical varialcres	  			
***********************************************************************

***********************************************************************
* 	PART 5:  miscallaneous corrections
***********************************************************************

replace international = 0 if international == .

***********************************************************************
* 	PART 6:  replace all MV = 0 for firms that did never patent
***********************************************************************
foreach x in pre_solar_patent pre_not_solar_patent pre_total_patent post_solar_patent post_not_solar_patent post_total_patent{
	replace `x' = 0 if `x' == .
}

***********************************************************************
* 	PART 7:  check for missing values
***********************************************************************
misstable sum, all

***********************************************************************
* 	PART 9:  Identify duplicates
***********************************************************************

	* email
duplicates report company_name
duplicates tag company_name, gen(dup_company)

***********************************************************************
* 	PART 10: Drop firms that were in Ben's base only
***********************************************************************
*br solarpatents if benonly == 1
drop if benonly == 1 /* 11 firms with no single solar patent */


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$lcr_intermediate"
save "lcr_inter", replace
