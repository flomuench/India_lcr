***********************************************************************
* 			lcrling email experiment import						
***********************************************************************
*																	   
*	PURPOSE: import the GIZ-API contact list as prepared					  								  
*	by Teo			  
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the list of lcrtered firms as Excel				  										  *
***********************************************************************
cd "$lcr_raw"

use "${lcr_raw}/cross_section", clear

***********************************************************************
* 	PART 2: save list of lcrtered firms in lcrtration raw 			  						
***********************************************************************
save "lcr_raw", replace
