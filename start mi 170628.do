capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

* start at least with just the possible variables in the model as imputation source.
* may add other variables.

use ekg_for_mi$tdate, clear
keep if exam>=4 
*& qtadj75_2<. & qtadj75_3<. & casi_irt<.
*notes:keep if exam>=4 & qtadj75_2<. & qtadj75_3<. & casi_irt<.

keep hhp exam age casi_irt qtadj75_2 qtadj75_3 qtadj75_1 ///
	educ any_apoe4 *_1 *_4 married smoke_now bmi pai thetad10 dyn_r ///
	dyn_l sbp dbp diabetes mi_hx stroke_hx parkinson liveff depr cesd ///
	cdrsum ex_reg gnhlth age_2 height_2 educ_exam1 	
* get all the ones missing together (just convenient)
order liveff smoke_now bmi pai dyn_r dyn_l ///
	sbp dbp diabetes mi_hx stroke_hx parkinson depr gnhlth ///
	ex_reg cesd alcohol_1 alcohol_4 hyp_dx_4 hc_rx_4 ///
	height_4 pai_1 pai_4 angina_dx_4 thy_hx_4 my_isch_4 cbs_4 ///
	blloon_4 pvdpp_4 pulmdspp_4 prtgrp10_4 quallf08_4 married thetad10 ///
	, after(exam)
reshape wide liveff- cesd married-age casi cdrsum, i(hhp) j(exam)
drop age_4 pai_4 age_1 /// duplicates
	gnhlth5 cesd5 married5 pai6 gnhlth6 ex_reg6 cesd6 /// missing by design
  smoke_now7 pai7 dyn_r7  dyn_l7    sbp7    dbp7  mi_hx7 ex_reg7  married7 thetad107 
		//missing by design
* too rare -> empty cells
drop angina_dx_1 hc_rx_1 /*also 2*/ my_isch_4 depr* thy_hx	bll park*
save mi$tdate, replace

********** include CASI and qtadj, per Melinda ****************************

mi set wide 
su
*mi misstable summarize

* These are the variables with no missing data, in long from
mi register regular hhp age_2 age4 age5 age6 age7 educ  /// 
	 cdrsum4 cdrsum5 cdrsum6 cdrsum7 hyp_dx_1 height_1 height_4  ///
	 occup_1* casi_irt7 liveff7 smoke_now5 smoke_now6
	
* The variables with missing data 
mi register imputed liveff4 - thetad104 liveff5 bmi5 - thetad105 ///
	liveff6 bmi6 - thetad106 bmi7 - cesd7 ///
	alcohol_4 hyp_dx_4  hc_rx_4  angina_dx_4 ///
	cbs_4  pvdpp_4  pulmdspp_4 	prtgrp10_4  quallf08_4 dementpp_4 ///
	alcohol_1 pai_1 qtadj75_1 any_apoe4	///
	qtadj75_2 qtadj75_3 casi_irt4 casi_irt5 casi_irt6 height_2 educ_exam1 // careful with the _1 variables

mi describe
save mi$tdate, replace
