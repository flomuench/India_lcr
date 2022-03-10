***********************************************************************
* 			lcrtration generate									  	  
***********************************************************************
*																	    
*	PURPOSE: generate lcrtration variables				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) sector
* 	2) gender
* 	3) onshore / offshore  							  
*	4) produit exportable  
*	5) intention d'exporter 			  
*	6) une opération d'export				  
*   7) export status  
*	8) age
*	9) eligibility	
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_intermediate}/lcr_inter", clear


***********************************************************************
* 	PART 2: outcome variable for DiD		  										  
***********************************************************************
gen dif_solar_patents = post_solar_patent-pre_solar_patent
*br company_name dif_solar_patents post_solar_patent pre_solar_patent

***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
foreach x in city state subsidiary lob {
	encode `x', gen(`x'1)
}
order city state subsidiary lob, a(employees)

***********************************************************************
* 	PART 3: create dummy for firm having participated in LCR auction		  										  
***********************************************************************
		* dummy for at least 1x LCR
gen lcr = (total_lcr > 0 & total_lcr <.), b(total_lcr)
label var lcr "participated (or not) in LCR auction"
lab def local_content 1 "participated in LCR" 0 "did not participate in LCR"
lab val lcr local_content

		* dummy for only LCR
gen lcr_only = (total_lcr == total_auctions) if total_auctions != . , a(total_lcr)
lab def just_lcr 1 "only participated in LCR" 0 "LCR & no LCR"
lab val lcr_only just_lcr

***********************************************************************
* 	PART 4: create dummy for firm having filed a solar patent
***********************************************************************
gen solar_patentor = (solarpatents > 0 & solarpatents <.), b(solarpatents)

***********************************************************************
* 	PART 5: create dummy for firm having filed a patent
***********************************************************************
gen patentor = (otherpatents > 0 & otherpatents <.), b(otherpatents)

***********************************************************************
* 	PART 6: create dummy for Indian companies
***********************************************************************
gen indian = (international < 1)
lab def national 1 "indian" 0 "international"
lab val indian national

***********************************************************************
* 	PART 7: create dummy for company HQ main city in India
***********************************************************************

gen hq_indian_state = .
replace hq_indian_state = 1 if state1 != .
local not_indian 5 11 19 9 6 16 15
foreach x of local not_indian  {
	replace hq_indian_state = 0 if state1 == `x'
}

	* dummy for delhi
gen capital = (city1 == 21)


***********************************************************************
* 	PART 8: create dummy patent outliers
***********************************************************************
cd "$lcr_descriptives"
set graphics on

	* graph 
graph box totalpatents, mark(1, mlab(company_name)) ///
	title("Identification of outliers in terms of total patents") ///
	name(outlier_patents, replace)
gr export outlier_patents.png, replace

graph box solarpatents, mark(1, mlab(company_name)) ///
	title("Identification of outliers in terms of solar patents") ///
	name(outlier_solarpatents, replace)
gr export outlier_solarpatents.png, replace
	
	* define dummy for outliers
gen patent_outliers = 0
replace patent_outliers = 1 if company_name == "bosch" | company_name == "bharat" | company_name == "larsen"


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
set graphics off 

	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
