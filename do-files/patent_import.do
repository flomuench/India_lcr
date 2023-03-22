***********************************************************************
* 			LCR India: import patent data sets
***********************************************************************
*																	   
*	PURPOSE: Import + identify solar patents filed by auction participants	  								  
*																	  
*	OUTLINE: 	
*	1) import patents filed by companies participating in auctions
*	2) import patents identified as solar patents based on Shubbak
*
*	Author: Florian Münch, Fabian Scheifele
*	ID variables:
* 	company = companyname_correct
*	patent  = applicationnumber (contains duplicates)	  									  
*	Requires: firmpatent.dta, solar_patents_addinfo.csv
*	Creates: firmpatent_inter.dta, solar_patents.dta						  
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