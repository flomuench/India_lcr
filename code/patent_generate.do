***********************************************************************
* 			LCR India: generate variables in patent data sets
***********************************************************************
*																	   
*	PURPOSE: merge with solar patents/ipc groups from Shubbak 2020			  								  
*				  
*																	  
*	OUTLINE:														  
* 	1: 		format changes for merger in two separate frames
*	2:		create pre-post-LCR dummy	
*	3:		create a LCR dummy
*	4:		create a dummy for cell/module patents only (rather than solar patents)
*
*	Author: Florian Münch, Fabian Scheifele 														  
*	ID variable: no id variable defined			  									  
*	Requires:	firmpatent_inter
*	Creates:	firmpatent_final					  
*																	  
***********************************************************************
* 	PART 1: format changes for merger in two separate frames	  						
***********************************************************************
	* use firmpatents
use "${lcr_intermediate}/firmpatent_inter", clear


***********************************************************************
* 	PART 2: create pre-post-LCR dummy
***********************************************************************
		* create pre-post period dummy
		* option 1: take whole pre-period == 30 years
gen post = (year_application > 2010 & year_application < .)
		* option 2: take same pre as post policy period == 8 years 
			* --> pre-historic period = 1982-2000; pre-period = 2001-2010; post-period = 2011-2020
gen post2 = .
	replace post2 = 1 if year_application <= 2000
	replace post2 = 2 if year_application > 2000 & year_application <= 2010
	replace post2 = 3 if year_application >=2011
	
		* create a dummy for not a solar patent
gen not_solar_patent = (solarpatent < 1)

	* create a one to count each patent
gen onepatent = 1
	
	* check whether time periods are correctly divided
tab year_application if post == 1 /* 224 patents before treatment */
tab year_application if post == 0 /* 262 patents after after treatment */


***********************************************************************
* 	PART 3: create a LCR dummy
***********************************************************************
	* put all LCR participants into a local
local lcr_participants `" adani amplus azure bharat bosch "development corporation odisha" greenko harsha hero "il&fs" jakson janardan kalthia karnataka laxmi madhav palimarwar photon rda shalaka sharda solairedirect sterling sun surana swelect tata terraform today vikram waaree welspun yarrow "'

	* create dummy if firms participated in LCR
gen lcr_participation = 0
foreach company of local lcr_participants {
	replace lcr_participation = 1 if company_name == "`company'"
}


***********************************************************************
* 	PART 4: create a dummy for cell/module patents only (rather than solar patents)					
***********************************************************************

	* re-name some of the elements for better understanding
replace subgroups = "cells or panels" if subgroups == "Combinations of the groups above"
replace subgroups = "H02N6/00" if ipc == "H02N6/00"
replace subgroups = "common cell elements" if subgroups == "Common Elements"
replace groups= "cells or panels" if subgroups == "cells or panels"
replace groups = "H02N6/00" if subgroups == "H02N6/00"
replace subgroups = "Thin film technologies" if subgroups == "Thin-<U+FB01>lm Technologies"

	* eye-ball the data to get better understanding of patents in different IPC subgroups
format abstract %70s
*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Crystalline Silicon Cells"
	/* only Bharat, Bosch & Sunedision filed in crystalline silicon cells 
		Bharat filed already before 2013/start of LCR policy ; Sunedison patented exclusively in ingots
		The solar ingot is a raw material used for manufacturing solar cells. 
		The ingots form the first step in the manufacturing of the solar wafers which are used as a base for the manufacturing of solar panels.*/

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Roof Covering and Supporting Structures"
		
		
*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Testing after manufacturing"
	/* all 5 testing after manufacturing patents come from larsen and toubro */

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "cells or panels"
	/* Tata filed all its patents in this group; T */

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "common cell elements"

*br applicantname year_application title abstract groups subgroups subsubgroups if subgroups == "Thin film technologies"
	/* almost all filed before LCR policy */

	
/* general impressio
apart from Bharat & Bosch, none of the patents relate to cell manufacturing but rather are
news way of installing/using solar PV cells or moodules to max. efficiency or adapt to 
a specific situation; there are also some patents that use solar PV in other applications, such as
electrical vehicles or  */
	
gen modcell_patent = 0
	replace modcell_patent = 1 if subgroups == "Crystalline Silicon Cells"
	replace modcell_patent = 1 if subgroups == "Multi-junction Cells"
	replace modcell_patent = 1 if subgroups == "Roof Covering and Supporting Structures"
	replace modcell_patent = 1 if subgroups == "cells or panels"
	replace modcell_patent = 1 if subgroups == "common cell elements"



***********************************************************************
* 	PART: save in final
***********************************************************************
save "${lcr_final}/firmpatent_final", replace