***********************************************************************
* 			Master do-file: Nurturing National Champions?
*			Local Content in Solar Auctions and Firm Innovation
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings	  
*				PART 2: Set folder paths		  
*				PART 3: Run all do-files                          
*																	  
*																	  
*	Author:  	Florian Münch, Fabian Scheifele 
*	Requires:  	  										  
*	Creates:  		                                  
***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************
 	* set standard settings
version 17
clear all
graph drop _all
scalar drop _all
set more off
set varabbrev off // stops stata from referring to variables if only one part is the same
set graphics off /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c

	*IF you dont have the following packages installed, please first install them: 
	*ssc install blindschemes
	*ssc install estout

	* define graph scheme for visual outputs
*set scheme burd
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************
{
		* user specific part - USER LOCATION NEEDS TO BE ADJUSTED MANUALLY AND DEPENDS ON WHERE YOU DECIDE TO SAVE REPLICATION PACKAGE
if c(os) == "Windows" {
	global user_location = "C:/Users/`c(username)'/Documents/GitHub"
}
		
		* code
global code = "${user_location}/India_lcr/code"
		
		* ado-files
global ado_files = "${user_location}/India_lcr/ado_files"
sysdir set PLUS "${ado_files}"	// set system directory for ado-files to make sure all packages are available locally

		* data
global data = "${user_location}/India_lcr/data"
global lcr_raw = "${data}/raw"
global lcr_intermediate = "${data}/intermediate"
global lcr_final = "${data}/final"

		* output
global output = "${user_location}/India_lcr/output"
global lcr_rt = "${output}/regression-tables"
global lcr_descriptives = "${output}/descriptive-statistics-figures"
global lcr_psm = "${output}/propensity-score-matching"
global final_figures = "${output}/final-figures"

/*
		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global lcr_gdrive = "G:"
	global lcr_github = "C:/Users/`c(username)'/Documents/GitHub/India_lcr/do-files"
	
}

		* user specific
if "`c(username)'" == "ASUS" {
		global lcr_gdrive_user = "${lcr_gdrive}/Meine Ablage"
}
else{
	
		global lcr_gdrive_user = "${lcr_gdrive}/.shortcut-targets-by-id\1t09p3JqyHkjvrE8TEqosOpHm-GiD94Q3"
}

		* path to gdrive
global lcr_project_folder =  "${lcr_gdrive_user}/Research_Solar India TU-IASS-PTB/Paper effect of LCR on innovation"

		* paths within gdrive
global lcr_gdrive_data = "${lcr_project_folder}/data"
global lcr_gdrive_output = "${lcr_project_folder}/output"

			* within data
global lcr_raw = "${lcr_gdrive_data}/raw"
global lcr_intermediate "${lcr_gdrive_data}/intermediate"
global lcr_final = "${lcr_gdrive_data}/final"


			* within output (regression tables, figures)
global lcr_rt = "${lcr_gdrive_output}/regression-tables"
global lcr_descriptives = "${lcr_gdrive_output}/descriptive-statistics-figures"
global lcr_psm = "${lcr_gdrive_output}/propensity-score-matching"
global final_figures = "${lcr_gdrive_output}/final-figures"
*/		
		* set seeds for replication
set seed 8413195
set sortseed 8413195
	
}	
***********************************************************************
* 	PART 3: 	Run do-files for employees + sales data 
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data
	Requires: firm_sales_employees.xlsx. Creates: lcr_sales_raw.dta
----------------------------------------------------------------------*/		
if (1) do "${code}/sales_import.do"	
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data
	Requires: lcr_sales_raw.dta. Creates: lcr_sales_inter.dta
----------------------------------------------------------------------*/		
if (1) do "${code}/sales_clean.do"	
/* --------------------------------------------------------------------
	PART 3.3: Correct, generate, transform intermediate data
	Requires: lcr_sales_inter.dta. Creates: lcr_sales_final.dta.
----------------------------------------------------------------------*/		
if (1) do "${code}/sales_transform.do"	
/* --------------------------------------------------------------------
	PART 3.4: Creates cross-sectional firm-level employees/sales data
	Requires: lcr_sales_final.dta. Creates: firm_sales, firm_employees
----------------------------------------------------------------------*/		
if (1) do "${code}/sales_collapse.do"
	
}
	
***********************************************************************
* 	PART 4: 	Run do-files for bid-level cleaning + analysis
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 4.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${code}/bid_import.do"	
/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_clean.do"
/* --------------------------------------------------------------------
	PART 4.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_correct.do"
/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_generate.do"
/* --------------------------------------------------------------------
	PART 4.5: Merge with Ben Probst et al. 2020 for firm controls
	Creates: lcr_bid_final + several variables (solar_manufacture, energy_company)
----------------------------------------------------------------------*/
if (1) do "${code}/bid_merge.do"
/* --------------------------------------------------------------------
	PART 4.6: Descriptive statistics
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_descriptives.do"
/* --------------------------------------------------------------------
	PART 4.7: collapse + aggregate cross-section
	Creates: lcr_final
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_collapse_csection.do"
/* --------------------------------------------------------------------
	PART 4.8: collapse + aggregate firm-year panel
	Creates: firmyear_auction.dta
----------------------------------------------------------------------*/	
if (1) do "${code}/bid_collapse_panel.do"

}

***********************************************************************
* 	PART 5: 	Run do-files for patent data
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 5.1: Import patent datasets and put into frames
	Requires: firmpatent.dta, solar_patents_addinfo.csv
	Creates:  firmpatent_inter.dta, solarpatents.dta
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_import.do"
/* --------------------------------------------------------------------
	PART 5.2: Patent datasets clean
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_clean.do"
/* --------------------------------------------------------------------
	PART 5.3: Patent datasets merge
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_merge.do"
/* --------------------------------------------------------------------
	PART 5.4: Patent datasets generate
	Creates: firmpatent_final
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_generate.do"
/* --------------------------------------------------------------------
	PART 5.5: Patent datasets visualize
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_visualize.do"
/* --------------------------------------------------------------------
	PART 5.6: Patent datasets collpase
	Creates: patent_cross_section.dta, firmyear_patents.dta
----------------------------------------------------------------------*/		
if (1) do "${code}/patent_collapse.do"
}
		
***********************************************************************
* 	PART 6: 	Run do-files for cross-section (cs) data cleaning
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 6.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${code}/cs_import.do"
/* --------------------------------------------------------------------
	PART 6.2: Import & merge patent data
	Creates: firmyear_patents.dta
----------------------------------------------------------------------*/		
if (1) do "${code}/cs_merge_patents.do"
/* --------------------------------------------------------------------
	PART 6.3: Import & merge sales and employees data
----------------------------------------------------------------------*/		
if (1) do "${code}/cs_merge_sales.do"
/* --------------------------------------------------------------------
	PART 6.4: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_clean.do"
/* --------------------------------------------------------------------
	PART 6.5: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_correct.do"
/* --------------------------------------------------------------------
	PART 6.6: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_generate.do"

}

***********************************************************************
* 	PART 7: 	Run do-files for cross-section (cs) analysis (DiD + PSM)
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 7.0: descriptive statitics
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_descriptives.do"
/* --------------------------------------------------------------------
	PART 7.1.: select model for estimation of propensity score
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_variable_choice.do"
/* --------------------------------------------------------------------
	PART 7.2.: estimate the propensity score
----------------------------------------------------------------------*/	
if (1) do "${code}/cs_ps_estimation.do"
/* --------------------------------------------------------------------
	PART 7.3.: evaluate common support
----------------------------------------------------------------------*/
if (1) do "${code}/cs_common_support.do"
/* --------------------------------------------------------------------
	PART 7.4.: PSM regressions - get weights
----------------------------------------------------------------------*/
if (1) do "${code}/cs_regression.do"
/* --------------------------------------------------------------------
	PART 7.5.: Assess quality of match in terms of reduction in bias
----------------------------------------------------------------------*/
if (1) do "${code}/cs_match_quality.do"
/* --------------------------------------------------------------------
	PART 7.6.: Cross-section heterogeneity: Who patented?
----------------------------------------------------------------------*/
if (1) do "${code}/cs_hetero.do"
}

***********************************************************************
* 	PART 8: 	Run do-files for firm-year panel, event study
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 8.1: Merge auction panel, patent panel, employees/sales panel
	Creates: event_study_raw.dta
----------------------------------------------------------------------*/
if (1) do "${code}/event_merge.do"
/* --------------------------------------------------------------------
	PART 8.2: Clean and correct to put into panel format
	Creates: event_study_inter.dta
----------------------------------------------------------------------*/
if (1) do "${code}/event_clean.do"
/* --------------------------------------------------------------------
	PART 8.3: Generate panel-level variables for analysis
	Creates: event_study_final.dta
----------------------------------------------------------------------*/
if (1) do "${code}/event_generate.do"
/* --------------------------------------------------------------------
	PART 8.4: Visualize
----------------------------------------------------------------------*/
if (0) do "${code}/event_visualize.do"
/* --------------------------------------------------------------------
	PART 8.5: Event study/dynamic DiD (KANN raus oder???)
----------------------------------------------------------------------*/
if (0) do "${code}/event_study.do"
/* --------------------------------------------------------------------
	PART 8.6: Staggered Did à la Callaway-Sant'Anna
----------------------------------------------------------------------*/
if (1) do "${code}/event_callaway_santanna.do"

}

***********************************************************************
* 	PART 9: 	Run do-files for Interpretation & explanation of results
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 9.1: Calculate (ex-post) power
----------------------------------------------------------------------*/
if (1) do "${code}/mechanism_post_power.do"
/* --------------------------------------------------------------------
	PART 9.2: Check which type of solar patents were filed
----------------------------------------------------------------------*/
if (0) do "${code}/mechanism_patents.do"
/* --------------------------------------------------------------------
	PART 9.3: demand shock from LCRs in MW & financial value of modules
----------------------------------------------------------------------*/
if (1) do "${code}/mechanism_demand_shock.do"

}



