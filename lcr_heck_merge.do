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
collapse (lastnm) indian soe_india empl manufacturer founded years_since_found energy_focus, by(bidder)

	* check if there are duplicates
duplicates report bidder

	* rename id for merger
rename bidder company_name

	* correct spelling to enable 1:1 merge
replace company_name = "4g" if company_name == "4g identity"
replace company_name = "canadian" if company_name == "canadian solar"
replace company_name = "green" if company_name == "green infra"
replace company_name = "gujarat" if company_name == "gujarat power"
replace company_name = "hero" if company_name == "hero solar"
replace company_name = "jk" if company_name == "j k petroenergy"
replace company_name = "karnataka" if company_name == "karnataka power"
replace company_name = "krishna" if company_name == "krishna windfarm"
replace company_name = "madhav" if company_name == "madhav infra"
replace company_name = "maheswari" if company_name == "maheshwari"
replace company_name = "patil" if company_name == "patil construction"
replace company_name = "softbank" if company_name == "sbg cleantech"
replace company_name = "sunil" if company_name == "sunil hitech"


	* save
cd "$lcr_raw"
save "probst2020", replace

***********************************************************************
* 	PART 2: merge lcr_bid_inter with Probst replication data set 										  
***********************************************************************
use "${lcr_intermediate}/lcr_bid_inter", clear

drop indian

merge m:1 company_name using "${lcr_raw}/probst2020"
drop if _merge == 2
gen missing_probst = 0
replace missing_probst = 1 if _merge == 1
drop _merge

lab var indian "indian firm = 1"


***********************************************************************
* 	PART 2: manually replace mv for firms not included in Probst et al. 2020
***********************************************************************
	* energy focus
format lob %-40.0g
format indian city %-15.0g
*br company_name lob energy_focus webaddress

* watch out. follow lob should not changed for all at once because contain single firms with energy focus: 
	*heavy construction =  14
	*semiconductors = 36

			* = 1
replace energy_focus = 1 if company_name == "acb"
replace energy_focus = 1 if lob == 8 /* electric services, nsk */
replace energy_focus = 1 if lob == 9 /* electrical apparatus & equipment, nsk */
replace energy_focus = 1 if lob == 10 /* electrical apparatus & equipment, nsk */
replace energy_focus = 1 if lob == 37 /* storage batteries */
replace energy_focus = 1 if lob == 40 /* water supply */
replace energy_focus = 1 if lob == 12 /* gas production and/or distribution */


replace energy_focus = 1 if company_name == "vikram"
replace energy_focus = 1 if company_name == "acb"


* tbd: 1) water supply, 2) gas production and/or distribution,
			
			* = 0
replace energy_focus = 0 if lob == 22 /* management consulting services */
replace energy_focus = 0 if lob == 30 /* plumbing, heating, airconditioning */
replace energy_focus = 0 if lob == 25 /* motor vehicle parts */
replace energy_focus = 0 if lob == 18 /* hh furniture */
replace energy_focus = 0 if lob == 4 /* business services */
replace energy_focus = 0 if lob == 17 /* hotels */
replace energy_focus = 0 if lob == 32 /* residential construction */
replace energy_focus = 0 if lob == 19 /* investors */
replace energy_focus = 0 if lob == 35 /* security brokers & dealers */
replace energy_focus = 0 if lob == 27 /* nonclassifiable establishments */
replace energy_focus = 0 if lob == 15 /* road construction */
replace energy_focus = 0 if lob == 13 /* heating equipment except electric */
replace energy_focus = 0 if lob == 33 /* rice milling */
replace energy_focus = 0 if lob == 1 /* apartment building operators */
replace energy_focus = 0 if lob == 24 /* miscallaneous nonmetallic minerals */
replace energy_focus = 0 if lob == 7 /* commercial nonphysical research */
replace energy_focus = 0 if lob == 31 /* real estate agents & managers */
replace energy_focus = 0 if lob == 26 /* newspapers */
replace energy_focus = 0 if lob == 3 /* bridge, tunnel, highway */


replace energy_focus = 0 if company_name == "development corporation odisha"
replace energy_focus = 0 if company_name == "grt jewellers"
replace energy_focus = 0 if company_name == "lanco"
replace energy_focus = 0 if company_name == "navayuga"
replace energy_focus = 0 if company_name == "spectrum"
replace energy_focus = 0 if company_name == "surana"


	* soe_india
*br company_name indian city soe_india lob energy_focus webaddress
		* replace as default all not indian soe
replace soe_india = 0 if soe_india == .
		* replace = 1 for indian soes
replace soe_india = 1 if company_name == "bharat"
replace soe_india = 1 if company_name == "development corporation odisha"
replace soe_india = 1 if company_name == "karnataka"
replace soe_india = 1 if company_name == "ntpc"

	* indian
*br company_name indian city soe_india lob energy_focus webaddress
		* replace first as default all indian
replace indian = 1 if indian == .
		* correct if firm is not indian
replace indian = 0 if company_name == "alfanar"
replace indian = 0 if company_name == "bosch"
replace indian = 0 if company_name == "alfanar"
replace indian = 0 if company_name == "cambronne"
replace indian = 0 if company_name == "devona"
replace indian = 0 if company_name == "duroc"
replace indian = 0 if company_name == "eden"
replace indian = 0 if company_name == "fortum"
replace indian = 0 if company_name == "ibc"
replace indian = 0 if company_name == "lightsource"
replace indian = 0 if company_name == "softbank"
replace indian = 0 if company_name == "rosepetal"

		* correct if pre-coding is not indian but seems 
replace indian = 1 if company_name == "azure"


	* manufacturer
		* corrections
replace manufacturer = 0 if company_name == "softbank"
		* desktop research
replace manufacturer = 1 if company_name == "photon" /* http://www.photonsolar.in/pv-modules.php*/
replace manufacturer = 1 if company_name == "surana" /* http://suranasolar.com/downloads.html */



	* solar module manufacturer
		* classification based on: 
			*https://solarquarter.com/wp-content/uploads/2021/03/file_f-1615380939218.pdf
			* https://www.iitk.ac.in/solarlighting/files/Indian_Solar_Industry.pdf
gen manufacturer_solar = 0
			* indian solar module manufacturers
replace manufacturer_solar = 1 if company_name == "vikram"
replace manufacturer_solar = 1 if company_name == "tata"
replace manufacturer_solar = 1 if company_name == "bharat"
replace manufacturer_solar = 1 if company_name == "adani"
replace manufacturer_solar = 1 if company_name == "swelect"
replace manufacturer_solar = 1 if company_name == "renew"
replace manufacturer_solar = 1 if company_name == "waree"
*replace manufacturer_solar = 1 if company_name == "lanco" /* after background check not clear */
replace manufacturer_solar = 1 if company_name == "photon" /* http://www.photonsolar.in/pv-modules.php*/
replace manufacturer_solar = 1 if company_name == "surana" /* http://suranasolar.com/downloads.html */

			* 


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_bid_final", replace
