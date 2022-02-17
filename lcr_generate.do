* generate: company_id
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
* 	PART 1:  Define non-response categories  			
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
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_intermediate"

	* save dta file
save "lcr_inter", replace
