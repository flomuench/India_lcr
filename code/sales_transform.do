***********************************************************************
* 	transform sales + employees - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: generate ihs-transformed sales & log-transformed employees				  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		ihs-transform sales
*	2)   	log-transform employees					  									 
*																	  													      
*	Author:  	Florian Muench, Fabian Scheifele					    
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_sales_inter.dta 	  										  
*	Creates:  lcr_sales_final.dta			                                  
***********************************************************************
* 	PART 0: set the scene 		  					  			
***********************************************************************
use "${lcr_intermediate}/lcr_sales_inter", clear

***********************************************************************
* 	PART 1: ihs-transform sales
***********************************************************************
	* ihs transformation used given both zeros and extreme values
ihstrans total_revenue
kdensity total_revenue
kdensity ihs_total_revenue
kdensity ihs_total_revenue if year == 2019


***********************************************************************
* 	PART 2: log-transform employees variable		  					  			
***********************************************************************
gen log_total_employees = log(total_employees)
kdensity log_total_employees



***********************************************************************
* 	PART 2: save as final	  					  			
***********************************************************************
save "${lcr_final}/lcr_sales_final", replace