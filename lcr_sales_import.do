***********************************************************************
* 	import sales + employes data - the effect of LCR on innovation						
***********************************************************************
*																	   
*	PURPOSE: Import sales + employes data of firms that 
*	participated in LCR & no LCR auctions
*																	  
*	OUTLINE:														  
*	1)	import as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Florian Muench, Fabian Scheifele														  
*	ID variable: companyname		  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import SECI online archives data set
***********************************************************************
	* set directory to raw folder
cd "$lcr_raw"

	* excel
import excel "${lcr_raw}/firm_sales_employees.xlsx", firstrow sheet(firm_year_panel) clear

***********************************************************************
* 	PART 2: save as dta file
***********************************************************************
cd "$lcr_raw"
save "lcr_sales_raw", replace