***********************************************************************
* 	clean the data (no corrections) - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: clean bid-level raw data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all unnecessary variables					  
*	3)  	Make all variables names lower case						  
*	4)  	Rename the variables
*	5)  	Order the variables										  
*	6)  	Label the variables											  
*   7) 		Label variable values 								 
*		      
*	Author:  	Florian Muench, Fabian Scheifele					    
*	ID variable:
*		auction-level = auction
*		company-level = companyname_correct
*		bid-level	  = id
*	Requires: lcr_raw.dta 	  										  
*	Creates:  lcr_inter.dta		
	                                  
***********************************************************************
* 	PART 1: 	Format string & numerical & date variables			  			
***********************************************************************
use "${lcr_raw}/lcr_bid_raw", clear

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
* 	PART 2: 	Drop all unnecessary variables		  			
***********************************************************************
drop A ID year year_dummy auction_date n database std_count_nov19 std_count_old
drop bidsubmission eligibilitycriteria evaluationcriteria notes mstdct companyname_group msaname formername
drop dunsno immediateparent immediateparentduns domesticduns ultimateparentduns primaryaddress? primaryzip primarymainphone primarytollfree primarymainfax
drop mailing* minorityowned foreigntrade manufacturer tradestyle companytype facilitysizesqft ownsrent womenowned ownershiptype accountant
drop yearoffounding locationtype exchange symbol latitude longitude salesyear1 prescreenscore prescreenranking primaryhooversindustry
drop primaryussiccode primaryusnaicscode bd region sales_bio_inr
drop employeestotalyear1 total_employees_tsd

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Rename the variables  			
***********************************************************************
rename companyname_correct company_name
format company_name bidder %-30s
rename employeesatthislocation employees
rename primarycity city
rename primarystateprovince state
rename primarycountryregion country
rename foreign0trulyindian international
rename issubsidiary subsidiary
rename lineofbusiness lob
rename auction_date_from_title auction_year
destring auction_year, replace
lab var auction_year "auction date based on title"

rename capacityin quantity_total
rename localdomesticcontentrequireme lcr_content
rename localtestingrequirement local_test
rename companyname company_name_long

rename sales_inr sales
lab var sales "sales in INR"

***********************************************************************
* 	PART 5: 	Order the variables	 in the data set		  			
***********************************************************************
order quantity_allocated_mw, a(quantity_wanted_mw)


***********************************************************************
* 	PART 6: 	Label the variables			  			
***********************************************************************
label var employees "employees at HQ"
label var city "primary city"
label var state "primary state"
label var international "foreign vs. indian company"
label var lob "primary line of business"
lab var country "primary country of origin of business"

lab var lcr "local content requirement"

lab var quantity_total "total mw quantity auctioned per auction"

lab var lcr_content "components to which lcr applied"

lab var final_vgf_after_era "inr per mw of vgf"

lab var auction_year "year of auction"
	
***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
lab def foreign 1 "international" 0 "indian"
lab val international foreign


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${lcr_intermediate}/lcr_bid_inter", replace
