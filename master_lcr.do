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
version 15
clear all
graph drop _all
scalar drop _all
set more off
set graphics off /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c

	* install packages
/*
ssc install ietoolkit /* for iebaltab */
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
*/


	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global lcr_gdrive_data = "C:/Users/`c(username)'/Google Drive/Research_Solar India TU-IASS-PTB/Paper effect of LCR on innovation/data"
	global lcr_gdrive_analysis = "C:/Users/`c(username)'/Google Drive/Research_Solar India TU-IASS-PTB/Paper effect of LCR on innovation/output"
	global lcr_github = "C:/Users/`c(username)'/Documents/GitHub/India_lcr"
	global lcr_backup = "C:/Users/`c(username)'/Documents/India_lcr"
	
}
else if c(os) == "MacOSX" {
	global lcr_gdrive_data = "/Volumes/GoogleDrive/My Drive/Research_Solar India TU-IASS-PTB/Paper effect of LCR on innovation/data"
	global lcr_gdrive_analysis = "/Volumes/GoogleDrive//My Drive/Research_Solar India TU-IASS-PTB/Paper effect of LCR on innovation/output"
	global lcr_github = "/Users/`c(username)'/Documents/GitHub/India_lcr"
	global lcr_backup = "/Users/`c(username)'/Documents/India_lcr"
}

		* paths within gdrive
			* data
global lcr_raw = "${lcr_gdrive_data}/raw"
global lcr_intermediate "${lcr_gdrive_data}/intermediate"
global lcr_final = "${lcr_gdrive_data}/final"
global lcr_checks = "${lcr_gdrive}/checks"


			* output (regression tables, figures)
global lcr_rt = "${lcr_gdrive_analysis}/regression-tables"
global lcr_descriptives = "${lcr_gdrive_analysis}/descriptive-statistics-figures"
global lcr_psm = "${lcr_gdrive_analysis}/propensity-score-matching"
global final_figures = "${lcr_gdrive_analysis}/final_figures"
			
		* set seeds for replication
set seed 8413195
set sortseed 8413195
		
***********************************************************************
* 	PART 3: 	Run do-files for bid-level cleaning + analysis
***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/lcr_heck_import.do"	
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_heck_clean.do"
/* --------------------------------------------------------------------
	PART 3.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_heck_correct.do"
/* --------------------------------------------------------------------
	PART 3.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_heck_generate.do"
/* --------------------------------------------------------------------
	PART 3.5: Merge with Ben Probst et al. 2020 for firm controls
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_heck_merge.do"
/* --------------------------------------------------------------------
	PART 3.6: Descriptive statistics
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_heck_descriptives.do"
/* --------------------------------------------------------------------
	PART 3.6: Heckman regression - replication of Probst
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_heck_regresssion.do"
/* --------------------------------------------------------------------
	PART 3.7: collapse + aggregate cross-section
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_heck_collapse.do"

		
***********************************************************************
* 	PART 4: 	Run do-files for cross-section data cleaning
***********************************************************************
/* --------------------------------------------------------------------
	PART 4.0: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/lcr_import.do"
/* --------------------------------------------------------------------
	PART 4.1: Import & merge patent data & Ben Probst
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/lcr_import_merge_patents.do"
/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_clean.do"
/* --------------------------------------------------------------------
	PART 4.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_correct.do"
/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_generate.do"

***********************************************************************
* 	PART 5: 	Run do-files for data analysis
***********************************************************************
/* --------------------------------------------------------------------
	PART 5.0: descriptive statitics
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_descriptives.do"
/* --------------------------------------------------------------------
	PART 5.1: select variables to include into matching model
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_model_choice.do"
/* --------------------------------------------------------------------
	PART 5.2.: select model for estimation of propensity score
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_variable_choice.do"
/* --------------------------------------------------------------------
	PART 5.3.: estimate the propensity score
----------------------------------------------------------------------*/	
if (1) do "${lcr_github}/lcr_ps_estimation.do"
/* --------------------------------------------------------------------
	PART 5.4.: evaluate common support
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_common_support.do"
/* --------------------------------------------------------------------
	PART 5.5.: PSM estimation
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/lcr_main_regression.do"
/* --------------------------------------------------------------------
	PART 5.6.: power size calculations
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/power.do"
/* --------------------------------------------------------------------
	PART 5.7.: Assess quality of match in terms of reduction in bias
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_match_quality.do"
/* --------------------------------------------------------------------
	PART 5.8.: DiD combined with matching
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_did_matching.do"
/* --------------------------------------------------------------------
	PART 5.9.: Robust 1: use "teffects psmatch" command
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_teffects_psmatch.do"


***********************************************************************
* 	PART 6: 	Interpretation & explanation of results
***********************************************************************
if (1) do "${lcr_github}/post_power.do"

/* --------------------------------------------------------------------
	PART 6.2: Check which type of solar patents were filed
----------------------------------------------------------------------*/
if (1) do "${lcr_github}/patent_analysis.do"
