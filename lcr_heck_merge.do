***********************************************************************
* 		merge with Probst replication data - the effect of lcr on innovation								  	  
***********************************************************************
*																	    
*	PURPOSE: import Probst replication data to get firm level control				  							  
*	variables 
*	OUTLINE:														  
*	1) 
* 	2) 
*
*																	  															      
*	Author:  	Florian Muench, Fabian Scheifele							  
*	ID varialcre: 			  					  
*	Requires: lcr_bid_inter.dta 	  								  
*	Creates:  lcr_bid_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1: import Probst et al. replication data set  										  
***********************************************************************
import excel "${lcr_raw}/Ben India Data.xlsx", firstrow clear
	
	* do necessary data cleaning to preapre for merger
		* make all variables names lower case
rename *, lower

		* format all string & numerical variables
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
		
	* collapse on company-level to keep
collapse (firstnm) indian soe_india empl manufacturer founded years_since_found energy_focus, by(bidder)

	* check if there are duplicates
duplicates report bidder

	* rename id for merger
rename bidder company_name

	* save
cd "$lcr_raw"
save "probst2020", replace

***********************************************************************
* 	PART 2: merge lcr_bid_inter with Probst replication data set 										  
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear

merge m:1 company_name using "${lcr_raw}/probst2020"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_bid_final", replace
