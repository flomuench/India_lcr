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
* 	PART 2: factor variable sector & subsector 			  										  
***********************************************************************
/*
label define sector_name 1 "Agriculture & Peche" ///
	2 "Artisanat" ///
	3 "Commerce international" ///
	4 "Industrie" ///
	5 "Services" ///
	6 "TIC" 

label define subsector_name 1 "agriculture" ///
	2 "architecture" ///
	3 "artisanat" ///
	4 "assistance" ///
	5 "audit" ///
	6 "autres" ///
	7 "centre d'appel" ///
	8 "commerce international" ///
	9 "développement informatique" ///
	10 "enseignement" ///
	11 "environnement et formation" ///
	12 "industries diverses" ///
	13 "industries mécaniques et électriques" ///
	14 "industries agro-alimentaires" ///
	15 "industries chimiques" ///
	16 "industries des matériaux de construction, de la céramique et du verre" ///
	17 "industries du cuir et de la chaussure" ///
	18 "industries du textile et de l'habillement" ///
	19 "pêche" ///
	20 "réseaux et télécommunication" ///
	21 "services et études dans le domaine de batîment"

*/

***********************************************************************
* 	PART 3: encode factor variables			  										  
***********************************************************************
foreach x in city state subsidiary lob {
	encode `x', gen(`x'1)
	drop `x'
	rename `x'1 `x' 
}
order city state subsidiary lob, a(employees)

***********************************************************************
* 	PART 3: create dummy for firm having participated in LCR auction		  										  
***********************************************************************
gen lcr = (total_lcr > 0 & total_lcr <.), b(total_lcr)

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
replace hq_indian_state = 1 if state != .
local not_indian 5 11 19 9 6 16 15
foreach x of local not_indian  {
	replace hq_indian_state = 0 if state == `x'
}

	* dummy for delhi
gen capital = (city == 21)

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
