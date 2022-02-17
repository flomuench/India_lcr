***********************************************************************
* 			variable choice - the effect of LCR on innovation									  	  
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
use "${lcr_intermediate}/lcr_final", clear

***********************************************************************
* 	PART 1: run  			
***********************************************************************
	* include variables that simultaneously
		*1: influence LCR participation choice
			* Indian company
			* total auction participation
		*2: propensity to file solar patent (outcome)
			* other, non solar patents
			* level of economic complexity of company lob
			* size of company: sales & employees
			* lob


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
