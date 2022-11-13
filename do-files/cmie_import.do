***********************************************************************
* 			cmieling email experiment import						
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
* 	PART 1: import + save all the raw data in one folder			  										  *
***********************************************************************
cd "$cmie_raw"

forvalues x = 1(1)5 {
	foreach z in dat map {
	* text txt.
		import delimited "${cmie_raw`x'}/`x'_`z'.txt", varn(1) delimiters("|") case(lower) clear
		save "cmie_raw`x'_`z'", replace
	}
}

***********************************************************************
* 	PART 2:  			  						
***********************************************************************
