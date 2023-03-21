***********************************************************************
* 	collapse sales + employees - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: collapse sales + employees on pre-treatment firm-level				  	  			
*
*																	  
*	OUTLINE:														  
*	1)		collapse pre-treatment sales
*	2)   	collapse pre-treatment employees					  									 
*																	  													      
*	Author:  	Florian Muench, Fabian Scheifele					    
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_sales_final.dta 	  										  
*	Creates:  firm_sales.dta, firm_employees.dta			                                  
***********************************************************************
* 	PART 0: set the scene 		  					  			
***********************************************************************
use "${lcr_final}/lcr_sales_final", clear


***********************************************************************
* 	PART 1: collapse + save sales
***********************************************************************
* approach: take pre-treatment period average, or, the earliest available year
sort company_name year, stable

preserve
		* create a post revenue variable taking the latest available year as a reference
egen max_year = max(year), by(company_name)
bysort company_name: gen post_revenue = total_revenue if year == max_year
histogram max_year, addl frequency width(1)

		* take the average revenue for firms with observed sales before policy start
egen pre_revenue = mean(total_revenue) if year < 2013, by(company_name)
		* take the first non-missing year for firms with observed sales after policy started
collapse (firstnm) year post_revenue pre_revenue ihs_total_revenue total_revenue, by(company_name)
rename year source_year_revenu
replace total_revenue = pre_revenue if pre_revenue != .
drop pre_revenue
drop ihs_total_revenue


save "${lcr_final}/firm_sales", replace
restore

***********************************************************************
* 	PART 2: collapse + save employees
***********************************************************************
* same approach as for sales
preserve
egen pre_employees = mean(total_employees) if year < 2013, by(company_name)
collapse (firstnm) year pre_employees log_total_employees total_employees, by(company_name)
replace total_employees = pre_employees if pre_employees != .
drop pre_employees
drop log_total_employees
rename year source_year_employees

save "${lcr_final}/firm_employees", replace
restore
