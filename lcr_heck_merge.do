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
collapse (lastnm) indian soe_india part_jnnsm_1 empl manufacturer founded years_since_found energy_focus, by(bidder)

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
* 	PART 3: manually replace mv for firms not included in Probst et al. 2020
***********************************************************************
	* participated/in JNNSM phase 1 batch 1 or batch 2
br company_name bidder part_jnnsm_1 missing_probst if part_jnnsm_1 == .
	* manually search and all firms with missing have not participated in the first phase
replace part_jnnsm_1 = 0 if part_jnnsm_1 == .



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

		* replace exception by company name
replace energy_focus = 0 if company_name == "development corporation odisha"
replace energy_focus = 0 if company_name == "grt jewellers"
replace energy_focus = 0 if company_name == "lanco"
replace energy_focus = 0 if company_name == "navayuga"
replace energy_focus = 0 if company_name == "spectrum"

replace energy_focus = 1 if company_name == "hiranandani"
replace energy_focus = 1 if company_name == "vikram"
replace energy_focus = 1 if company_name == "acb"
replace energy_focus = 1 if company_name == "surana"
replace energy_focus = 1 if company_name == "swelect"
replace energy_focus = 1 if company_name == "sunedison"
replace energy_focus = 1 if company_name == "photon"


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
replace indian = 0 if company_name == "bastille"
replace indian = 0 if company_name == "alfanar"
replace indian = 0 if company_name == "cambronne"
replace indian = 0 if company_name == "devona"
replace indian = 0 if company_name == "duroc"
replace indian = 0 if company_name == "segur"
replace indian = 0 if company_name == "eden"
replace indian = 0 if company_name == "fortum"
replace indian = 0 if company_name == "mira"
replace indian = 0 if company_name == "ibc"
replace indian = 0 if company_name == "lightsource"
replace indian = 0 if company_name == "softbank"
replace indian = 0 if company_name == "rosepetal"
replace indian = 0 if company_name == "renew"
replace indian = 0 if company_name == "solar"
replace indian = 0 if company_name == "terraform"


		* correct if pre-coding is not indian but seems 
replace indian = 1 if company_name == "azure"


	* manufacturer
		* corrections
replace manufacturer = 0 if company_name == "softbank"
		* desktop research
replace manufacturer = 1 if company_name == "photon" /* http://www.photonsolar.in/pv-modules.php*/
replace manufacturer = 1 if company_name == "surana" /* http://suranasolar.com/downloads.html */
replace manufacturer = 1 if company_name == "suzlon"
replace manufacturer = 1 if company_name == "waaree"
replace manufacturer = 1 if company_name == "mahindra" /* https://www.mahindrasusten.com/products/module-mounting-structure/, https://www.mahindra.com/news-room/press-release/susten-and-mitsui-to-co-invest-in-distributed-solar-power-projects */
replace manufacturer = 1 if company_name == "exide" /* https://www.exideindustries.com/products/solar-solutions/solar-pv-modules.aspx */
replace manufacturer = 1 if company_name == "solar" /* https://www.exideindustries.com/products/solar-solutions/solar-pv-modules.aspx */



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
*replace manufacturer_solar = 1 if company_name == "renew" /* rechecked on april 6th, seem EPC */
replace manufacturer_solar = 1 if company_name == "waaree"
*replace manufacturer_solar = 1 if company_name == "lanco" /* after background check not clear */
replace manufacturer_solar = 1 if company_name == "photon" /* http://www.photonsolar.in/pv-modules.php*/
replace manufacturer_solar = 1 if company_name == "surana" /* http://suranasolar.com/downloads.html */
replace manufacturer_solar = 1 if company_name == "canadian" /*https://www.canadiansolar.com/  */
replace manufacturer_solar = 1 if company_name == "mahindra"
replace manufacturer_solar = 1 if company_name == "exide" 
replace manufacturer_solar = 1 if company_name == "sunedison" 
replace manufacturer_solar = 1 if company_name == "alfanar" 
replace manufacturer_solar = 1 if company_name == "solar" 


***********************************************************************
* 	PART 4: create sector dummy
***********************************************************************
lab def sectors 1 "real estate" 2 "industry" 3 "construction" 4 "business services" 5 "electrical services EPC" ///
	6 "electronics manufacturer" 7 "utility"
	
gen sector = .
replace sector = 1 if lob == 1 | lob == 31 
replace sector = 2 if lob == 2 | lob == 5 | lob == 13 | lob == 20 | lob == 25 | lob == 28
replace sector = 3 if lob == 3 | lob == 14 | lob == 15 | lob == 24 | lob == 29 | lob == 32
replace sector = 4 if lob == 4 | lob == 7 | lob == 6 | lob == 15 | lob == 17 | lob == 19 | lob == 21 | lob == 22 | lob == 23 | lob == 26 | lob == 34
replace sector = 5 if lob == 10 | lob == 8 | lob == 16 | lob == 17 | lob == 18 | lob == 11 | lob == 22 | lob == 24 | lob == 27 | lob == 35 | lob == 38 | lob == 30
replace sector = 6 if lob == 9  | lob == 37 | lob == 39 | lob == 36
replace sector = 7 if lob == 12 | lob == 40

replace sector = 6 if company_name == "swelect"  | company_name == "sunedision" | company_name == "adani" | company_name == "tata" | company_name == "waaree" | company_name == "photon" | company_name == "canadian"
replace sector = 5 if company_name == "maheswari" | company_name == "talettutayi" | company_name == "sukhbir"
replace sector = 7 if company_name == "hiranandani"
replace sector = 4 if company_name == "softbank" | company_name == "sun"
replace sector = 3 if company_name == "scc" | company_name == "r s food processes"

lab val sector sectors
lab var sector "sector"

***********************************************************************
* 	PART 5:  import missing values for manufacturer + year founded from desktop research	  			
***********************************************************************
preserve
import excel "$lcr_raw/manufacturer_year_data_researched01042022.xlsx", firstrow clear
save "manufacturer_year", replace
restore
merge m:1 company_name using "manufacturer_year", update replace
erase "manufacturer_year.dta"

drop if company_name == "rutherford" /* company renamed in lcr_heck_correct as subsidiary of canadian solar */

format founded %9.0g
drop years_since_found
gen age = 2022 - founded
format age %9.0g



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_bid_final", replace
