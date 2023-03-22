***********************************************************************
* 			master file importing + cleaning + preparation India lcr prowess data
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          
*																	  
*																	  
*	Author:  	Florian Münch, Fabian Scheifele						    
*	ID variable: cross-section = company_name ; combined_results = bid ; 	  
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

	* install packages
/*
ssc install ietoolkit, replace /* for iebaltab */
ssc install randtreat, replace /* for randtreat --> random allocation */
ssc install blindschemes, replace /* for plotplain --> scheme for graphical visualisations */
net install http://www.stata.com/users/kcrow/tab2docx
ssc install betterbar
ssc install mdesc 
ssc install reclink
ssc install matchit
ssc install strgroup
ssc install stripplot
net install http://www.stata.com/users/kcrow/tab2docx
ssc install labutil
ssc install xtgraph
ssc install psmatch2, replace
ssc install table1
ssc install estout
ssc install ihstrans, replace
net install http://www.stata.com/users/kcrow/tab2xl
net describe grc1leg, from(http://www.stata.com/users/vwiggins)
net install grc1leg.pkg
net install grc1leg, from(http://www.stata.com/users/vwiggins) replace
net install gr0075, from(http://www.stata-journal.com/software/sj18-4) replace
ssc install labutil, replace
ssc install sencode, replace
ssc install panelview, all replace
ssc install drdid, all replace
ssc install csdid, all replace
ssc install carryforward, all replace
*/

	* define graph scheme for visual outputs
*set scheme burd
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************
{
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
global lcr_checks = "${lcr_gdrive}/checks"


			* within output (regression tables, figures)
global lcr_rt = "${lcr_gdrive_output}/regression-tables"
global lcr_descriptives = "${lcr_gdrive_output}/descriptive-statistics-figures"
global lcr_psm = "${lcr_gdrive_output}/propensity-score-matching"
global final_figures = "${lcr_gdrive_output}/final_figures"
			
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
if (1) do "${lcr_github}/sales_import.do"	
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data
	Requires: lcr_sales_raw.dta. Creates: lcr_sales_inter.dta
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/sales_clean.do"	
/* --------------------------------------------------------------------
	PART 3.3: Correct, generate, transform intermediate data
	Requires: lcr_sales_inter.dta. Creates: lcr_sales_final.dta.
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/sales_transform.do"	
/* --------------------------------------------------------------------
	PART 3.4: Creates cross-sectional firm-level employees/sales data
	Requires: lcr_sales_final.dta. Creates: firm_sales, firm_employees
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/sales_collapse.do"
	
}
	
***********************************************************************
* 	PART 4: 	Run do-files for bid-level cleaning + analysis
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 4.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/bid_import.do"	
/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_clean.do"
/* --------------------------------------------------------------------
	PART 4.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_correct.do"
/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_generate.do"
/* --------------------------------------------------------------------
	PART 4.5: Merge with Ben Probst et al. 2020 for firm controls
	Creates: lcr_bid_final + several variables (solar_manufacture, energy_company)
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/bid_merge.do"
/* --------------------------------------------------------------------
	PART 4.6: Descriptive statistics
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_descriptives.do"
/* --------------------------------------------------------------------
	PART 4.7: collapse + aggregate cross-section
	Creates: lcr_final
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_collapse_csection.do"
/* --------------------------------------------------------------------
	PART 4.8: collapse + aggregate firm-year panel
	Creates: firmyear_auction.dta
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/bid_collapse_panel.do"

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
if (1) do "${lcr_github}/patent_import.do"
/* --------------------------------------------------------------------
	PART 5.2: Patent datasets clean
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/patent_clean.do"
/* --------------------------------------------------------------------
	PART 5.3: Patent datasets merge
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/patent_merge.do"
/* --------------------------------------------------------------------
	PART 5.4: Patent datasets generate
	Creates: firmpatent_final
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/patent_generate.do"
/* --------------------------------------------------------------------
	PART 5.5: Patent datasets visualize
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/patent_visualize.do"
/* --------------------------------------------------------------------
	PART 5.6: Patent datasets collpase
	Creates: patent_cross_section.dta, firmyear_patents.dta
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/patent_collapse.do"
}
		
***********************************************************************
* 	PART 6: 	Run do-files for cross-section (cs) data cleaning
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 6.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/cs_import.do"
/* --------------------------------------------------------------------
	PART 6.2: Import & merge patent data
	Creates: firmyear_patents.dta
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/cs_merge_patents.do"
/* --------------------------------------------------------------------
	PART 6.3: Import & merge sales and employees data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/cs_merge_sales.do"
/* --------------------------------------------------------------------
	PART 6.4: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/cs_clean.do"
/* --------------------------------------------------------------------
	PART 6.5: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/cs_correct.do"
/* --------------------------------------------------------------------
	PART 6.6: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/cs_generate.do"

}

***********************************************************************
* 	PART 7: 	Run do-files for cross-section (cs) analysis (DiD + PSM)
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 7.0: descriptive statitics
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_descriptives.do"
/* --------------------------------------------------------------------
	PART 7.1: select variables to include into matching model
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_model_choice.do"
/* --------------------------------------------------------------------
	PART 7.2.: select model for estimation of propensity score
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_variable_choice.do"
/* --------------------------------------------------------------------
	PART 7.3.: estimate the propensity score
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_ps_estimation.do"
/* --------------------------------------------------------------------
	PART 7.4.: evaluate common support
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_common_support.do"
/* --------------------------------------------------------------------
	PART 7.5.: PSM estimation
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_main_regression.do"
/* --------------------------------------------------------------------
	PART 7.6.: power size calculations
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/power.do"
/* --------------------------------------------------------------------
	PART 7.7.: Assess quality of match in terms of reduction in bias
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_match_quality.do"
/* --------------------------------------------------------------------
	PART 7.8.: DiD combined with matching
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_did_matching.do"
/* --------------------------------------------------------------------
	PART 7.9.: Robust 1: use "teffects psmatch" command
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_teffects_psmatch.do"
/* --------------------------------------------------------------------
	PART 7.10.: Cross-section heterogeneity: Who patented?
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_crosssection_hetero.do"
}


***********************************************************************
* 	PART 8: 	Run do-files for firm-year panel, event study PSM DiD
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 8.1: Merge auction panel, patent panel, employees/sales panel
	Creates: event_study_raw.dta
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/merge_firmyeardata.do"
/* --------------------------------------------------------------------
	PART 8.2: Prepare data set
	Creates: event_study_final.dta
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/event_clean.do"
/* --------------------------------------------------------------------
	PART 8.3: Visualize
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/event_visualize.do"
/* --------------------------------------------------------------------
	PART 8.4: Event study/dynamic DiD
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/event_study.do"
/* --------------------------------------------------------------------
	PART 8.5: Run staggered Did
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/callaway_santanna.do"
/* --------------------------------------------------------------------
	PART 8.6: Panel heterogeneity
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/panel_hetero.do"

}


}
***********************************************************************
* 	PART 9: 	Run do-files for Interpretation & explanation of results
***********************************************************************
{
/* --------------------------------------------------------------------
	PART 9.1: Calculate (ex-post) power
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_post_power.do"
/* --------------------------------------------------------------------
	PART 9.2: Check which type of solar patents were filed
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/patent_analysis.do"
/* --------------------------------------------------------------------
	PART 9.3: demand shock from LCRs in MW & financial value of modules
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_demand_shock.do"

}



