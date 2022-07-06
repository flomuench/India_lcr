***********************************************************************
* 	visualise sales + employees - the effect of LCR on innovation									  		  
***********************************************************************
*																	  
*	PURPOSE: visualise sales + employees across firms and over time				  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		missing values & availability
*	2)   	extreme values					  									 
*																	  													      
*	Author:  	Florian Muench, Fabian Scheifele					    
*	ID varialcre: 	company_name			  					  
*	Requires: lcr_raw.dta 	  										  
*	Creates:  lcr_inter.dta			                                  
***********************************************************************
* 	PART 0: set the scene 		  					  			
***********************************************************************
use "${lcr_final}/lcr_sales_final", clear


***********************************************************************
* 	PART 1: year of incorporations
***********************************************************************
preserve 
collapse (firstnm) founded, by(company_name)
histogram founded if founded >= 2000, frequency addl ///
	xlabel(2000(1)2020, labs(vsmall)) width(1)
restore
	/* only 24 firms were founded after lcr or 31 if one includes 2013 */

***********************************************************************
* 	PART 1: investigate missing values for sales
***********************************************************************
	*
misstable sum total_revenue

	* 
gen one = 1
graph bar (sum) one, over(year, label(labs(small))) ///
	blabel(total)
	

	* generate dummy for firms with founding year >= 2013
gen founded_after_lcr = (founded >= 2013 & founded != .)


	* create 
egen minyear = min(year), by(company_name)
		* show firms created before 2013 but with revenue data only after 2013
br company_name year minyear founded total_revenue total_employees if minyear > 2013 & founded_after_lcr == 0
codebook company_name if minyear > 2013 & founded_after_lcr == 0
export excel company_name year minyear founded total_revenue total_employees using created_before_2013_but_no_revenue if minyear > 2013 & founded_after_lcr == 0, replace firstrow(var)
			/* shows 27 firms 
manual control: 
ACME --> created solar holdings company in 2015 while ACME already existed since 2003
ADANI --> created solar energy arm in ? although already existed since 1988
Amplus --> 
				
				*/
	
	* what is the earliest available year of employee data per company?
preserve 
collapse (min) year (firstnm) total_revenue, by(company_name)
histogram year, frequency addl width(1) ///
	xlabel(2000(1)2021, labsize(vsmall)) ///
	xline(2014)

		/* for 75 companies we have data before or in 2013
			for 38 companies we have data from 2014 onwards
				2015 --> 11 companies
				2016 --> 15 companies
		
																	*/
restore

																	
***********************************************************************
* 	PART 2: investigate extreme values for sales
***********************************************************************
	* get a feeling for the distribution
sum total_revenue, d
		/* firms with highest values have trillions or several hundred billions in sales */

	* visualise the distribution
histogram total_revenue, xlabel(,labsize(vsmall)) frequency addl
histogram total_revenue if total_revenue < 1000000000, xlabel(,labsize(vsmall)) frequency addl


	* what are outliers
graph box total_revenue if total_revenue > 0, marker(1, mlabel(company_name))
		/* suggests that Bharat, L&T, Indiabulls & NTPC are outliers */
	
graph box total_revenue if total_revenue > 0 & total_revenue < 500000000, marker(1, mlabel(company_name))


***********************************************************************
* 	PART 3: employees
***********************************************************************
sum total_employees
	* max: 54 579, SD: ~ 7000, min: 1
kdensity total_employees





