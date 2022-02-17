***********************************************************************
* 			variable choice - the effect of LCR on innovation									  	  
***********************************************************************
*																	    
*	PURPOSE: generate lcrtration variables				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) sector
* 	2) gender
* 	3) onshore / offshore  							  
*	4) produit exportable  
*	5) intention d'exporter 			  
*	6) une opération d'export				  
*   7) export status  
*	8) age
*	9) eligibility	
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID varialcre: 	id (example: f101)			  					  
*	Requires: lcr_inter.dta 	  								  
*	Creates:  lcr_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  set the scene  			
***********************************************************************
use "${lcr_intermediate}/lcr_final", clear

***********************************************************************
* 	PART 1: run  			
***********************************************************************
	* include variables that simultaneously
		*1: influence LCR participation choice
			* Indian company, Indian city or state as HQ
			* total auction participation
		*2: propensity to file solar patent (outcome)
			* ever patented other patent
			* other, non solar patents
			* size of company: sales & employees
			* level of economic complexity of company lob
			* lob
	* significance method:
		* (1-3) indian
eststo indian, r: logit lcr i.indian /* seems like this */
eststo indian_state, r: logit lcr i.hq_indian_state
eststo dehli, r: logit lcr i.capital

		* (4) total auction participation
eststo auctions, r: logit lcr total_auctions

		* (5) ever patented non solar patents
eststo patentor, r: logit lcr total_auctions patentor
		
		* (6) amount of other patents
eststo otherpatents, r: logit lcr total_auctions otherpatents

		* (7) size
eststo size, r: logit lcr total_auctions sales employees

		* (8) complexity
eststo size, r: logit lcr total_auctions lob_pc_avg
	
		* (9) lob
eststo size, r: logit lcr total_auctions lob_pc_avg lob



local regressions indian



eststo exp2, r: logit exporter qii employees age i.genre_ceo i.pdg_educ, vce(robust)

local regressions expi1 exp2 markets3 xsales4
esttab `regressions' using reg_exp1.tex, replace ///
	title("Export and QI index") ///
	mtitles("Exp. index" "Export" "Exp. markets" "Exp. sales") ///
	label ///
	b(2) ///
	se(2) ///
	width(0.8\hsize) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.gouvernorat *.sector) ///
	nobaselevels ///
	scalars("gouvernorat Region controls" "sector Sector controls") ///
	addnotes("Export performance index is a z-score of export dummy, export markets and export sales."  "Estimates in column (2) are based on a logit" "Estimates in column (3) are based on a Poisson model.")
	

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$lcr_final"

	* save dta file
save "lcr_final", replace
