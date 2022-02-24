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
*	Author:  	Florian Münch							    
*	ID variable: id_email		  					  
*	Requires:  	  										  
*	Creates:  master-data-ecommerce; emailexperiment_population_lcrle.dta		                                  
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
*/
ssc install psmatch2, replace



	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global lcr_gdrive_data = "C:/Users/`c(username)'/Google Drive/Research_Solar India TU-IASS-PTB/Data/Firm data"
	global lcr_gdrive_analysis = "C:/Users/`c(username)'/Google Drive/Research_Solar India TU-IASS-PTB/Analysis"
	global lcr_github = "C:/Users/`c(username)'/Documents/GitHub/India_lcr"
	global lcr_backup = "C:/Users/`c(username)'/Documents/India_lcr"
	
}
else if c(os) == "MacOSX" {
	global lcr_gdrive_data = "/Volumes/GoogleDrive/My Drive/Research_Solar India TU-IASS-PTB/Data/Firm data"
	global lcr_gdrive_analysis = "/Volumes/GoogleDrive//My Drive/Research_Solar India TU-IASS-PTB/Analysis"
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
global lcr_descriptives = "${lcr_output_analysis}/descriptive-statistics-figures"
global lcr_psm = "${lcr_output_analysis}/propensity-score-matching"

			
		* set seeds for replication
set seed 8413195
set sortseed 8413195
		

***********************************************************************
* 	PART 4: 	Run do-files for data cleaning
***********************************************************************
/* --------------------------------------------------------------------
	PART 4.0: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${lcr_github}/lcr_import.do"
/* --------------------------------------------------------------------
	PART 4.1: Import & merge patent data
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
	PART 5.1: select variables to include into matching model
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_model_choice.do"
/* --------------------------------------------------------------------
	PART 5.2.: select model for estimation of propensity score
----------------------------------------------------------------------*/	
if (0) do "${lcr_github}/lcr_variable_choice.do"
/* --------------------------------------------------------------------
	PART 5.3.: De-identify and save as final for analysis
----------------------------------------------------------------------*/
if (0) do "${lcr_github}/lcr_.do"
