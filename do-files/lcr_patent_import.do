***********************************************************************
* 			LCR India: import patent data sets
***********************************************************************
*																	   
*	PURPOSE: 				  								  
*				  
*																	  
*	OUTLINE:														  
		
*																	 								
*
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the list of patents		  						
***********************************************************************
use "${lcr_raw}/firmpatent", clear

save "${lcr_intermediate}/firmpatent_inter", replace


***********************************************************************
* 	PART 2: import solar patents file with IPC groups	  						
***********************************************************************
import delimited "${lcr_raw}/solar_patents_addinfo.csv", clear varn(1)

save "${lcr_intermediate}/solarpatents", replace

***********************************************************************
* 	PART 3: import solar patents file with HS codes & complexity
***********************************************************************
use "${lcr_raw}/solar_components_updated_HS", clear
