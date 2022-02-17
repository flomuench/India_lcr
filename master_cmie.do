***********************************************************************
* 			master file importing + cleaning + preparation India CMIE prowess data
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
*	Creates:  master-data-ecommerce; emailexperiment_population_cmiele.dta		                                  
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
*/


	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global cmie_gdrive = "C:/Users/`c(username)'/Google Drive/Research_Solar India TU-IASS-PTB/Data/Firm data/CMIE Prowess/CMIE/Flo - CMIE"
	global cmie_github = "C:/Users/`c(username)'/Documents/GitHub/India_lcr_rd"
	global cmie_backup = "C:/Users/`c(username)'/Documents/India_cmie"

}
else if c(os) == "MacOSX" {
	global cmie_gdrive = "/Volumes/GoogleDrive/My Drive/Research_Solar India TU-IASS-PTB/Data/Firm data/CMIE Prowess/CMIE/Flo - CMIE"
	global cmie_github = "/Users/`c(username)'/Documents/GitHub/India_lcr_rd"
	global cmie_backup = "/Users/`c(username)'/Documents/India_cmie"
}

		* paths within gdrive
			* data
global cmie_raw = "${cmie_gdrive}/raw"
global cmie_raw1 = "${cmie_gdrive}/raw/prowdx_1_trial"
global cmie_raw2 = "${cmie_gdrive}/raw/prowdx_2_trial"
global cmie_raw3 = "${cmie_gdrive}/raw/prowdx_3_trial"
global cmie_raw4 = "${cmie_gdrive}/raw/prowdx_4_trial"
global cmie_raw5 = "${cmie_gdrive}/raw/prowdx_5_trial"


global cmie_intermediate "${cmie_gdrive}/intermediate"
global cmie_final = "${cmie_gdrive}/final"
global cmie_checks = "${cmie_gdrive}/checks"


			* output (regression tables, figures)
global cmie_output = "${cmie_gdrive}/output"
global cmie_figures = "${cmie_output}/descriptive-statistics-figures"
global cmie_progress = "${cmie_output}/progress-eligibility-characteristics"

			
		* set seeds for replication
set seed 8413195
set sortseed 8413195
		

***********************************************************************
* 	PART 4: 	Run do-files for data cleaning & cmietration progress
***********************************************************************
/* --------------------------------------------------------------------
	PART 4.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${cmie_github}/cmie_import.do"
/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (0) do "${cmie_github}/cmie_clean.do"
/* --------------------------------------------------------------------
	PART 4.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (0) do "${cmie_github}/cmie_correct.do"
/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (0) do "${cmie_github}/cmie_generate.do"
/* --------------------------------------------------------------------
	PART 4.6: export open text or number variables for RA check
----------------------------------------------------------------------*/	
if (0) do "${cmie_github}/cmie_open_question_checks.do"
/* --------------------------------------------------------------------
	PART 4.7: Export pdf with number, characteristics & eligibility of cmietered firms
----------------------------------------------------------------------*/	
if (0) do "${cmie_github}/cmie_progress_eligibility_characteristics.do"
/* --------------------------------------------------------------------
	PART 4.8: De-identify and save as final for analysis
----------------------------------------------------------------------*/
if (0) do "${cmie_github}/cmie_deidentify.do"

