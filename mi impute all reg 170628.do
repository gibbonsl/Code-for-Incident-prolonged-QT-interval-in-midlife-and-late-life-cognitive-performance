* all regression, no 
use mi$tdate, clear // first time
*use mi_$tdate, clear // when adding

* fixed history vars
mi impute chained 	/// 7
	(regress) any_apoe4 bmi7 cesd7 diabetes7 stroke_hx7 gnhlth7  ///
	/// 6
	(regress, omit(liveff7 gnhlth7 cesd7 diabetes7 ///
		stroke_hx7 bmi7 age7 casi_irt7 cdrsum7)) bmi6 dyn_r6 dyn_l6 sbp6 dbp6 thetad106 ///
		diabetes6 mi_hx6 stroke_hx6 married6  liveff6 casi_irt6 ///
	///	5
	(regress, omit(liveff7 gnhlth7 diabetes7 cesd7  ///
		stroke_hx7 bmi7 age7 casi_irt7 cdrsum7 ///
		liveff6 smoke_now6 mi_hx6 married6 sbp6 dbp6 ///
		thetad106 diabetes6 dyn_r6 dyn_l6 age6 casi_irt6 cdrsum6 ///
		stroke_hx6 bmi6 ///
		)) bmi5 pai5 dyn_r5 dyn_l5 sbp5 dbp5 thetad105 ///
		liveff5  diabetes5 mi_hx5 stroke_hx5 ex_reg5 casi_irt5 ///
	///	4
	(regress, omit(liveff7 gnhlth7 cesd7 diabetes7 stroke_hx7 bmi7 ///
		liveff6 smoke_now6 mi_hx6 married6 sbp6 dbp6 thetad106 diabetes6 dyn_r6 dyn_l6 ///
		stroke_hx6 bmi6 ///
		liveff5 smoke_now5 mi_hx5 ex_reg5 pai5 sbp5 dbp5 ///
		thetad105 diabetes5 dyn_r5 dyn_l5 stroke_hx5 bmi5 ///
		age5 casi_irt5 cdrsum5 age6 casi_irt6 cdrsum6 age7 casi_irt7 cdrsum7 ///
		)) bmi4 pai4 dyn_r4 dyn_l4 sbp4 dbp4 cesd4 thetad104 alcohol_4  ///
		liveff4 smoke_now4 diabetes4 mi_hx4 stroke_hx4 ex_reg4 ///
		married4 hyp_dx_4 hc_rx_4 angina_dx_4 ///
		cbs_4 pvdpp_4 pulmdspp_4 prtgrp10_4 dementpp_4 gnhlth4 quallf08_4  ///
		casi_irt4 ///
	/// 1
	(regress, omit(sbp4 dbp4 thetad104 cbs_4 stroke_hx4 hc_rx_4 ///
		 angina_dx_4 mi_hx4 dyn_r4 hyp_dx_4 dyn_l4 height_4 bmi4 diabetes4 married4 ///
		 ex_reg4 smoke_now4 pai4 liveff4 prtgrp10_4 alcohol_4 gnhlth4 quallf08_4 cesd4 dementpp_4 ///
		 pvdpp_4 pulmdspp_4 ///
		 smoke_now5 ex_reg5 pai5 thetad105 liveff5 ///
		 sbp5 dbp5 diabetes5 stroke_hx5 mi_hx5 dyn_r5 dyn_l5 bmi5 ///
		 thetad106 married6 diabetes6 sbp6 dbp6 mi_hx6 ///
		 stroke_hx6 bmi6 dyn_r6 dyn_l6 ///
		 liveff7 diabetes7 gnhlth7 cesd7 stroke_hx7 bmi7 ///
		 age4 casi_irt4 cdrsum4 age5 casi_irt5 cdrsum5 age6 casi_irt6 cdrsum6 ///
		 age7 casi_irt7 cdrsum7 ///
		)) alcohol_1 pai_1 qtadj75_1 qtadj75_2 qtadj75_3 educ_exam1 height_2 /// 
	= 				///
		age4  cdrsum4 ///
		age5  cdrsum5 ///
		age6  cdrsum6 ///
		age7  cdrsum7 ///
		height_1 occup_1 hyp_dx_1 ///
		age_2 educ height_4 casi_irt7 liveff7 smoke_now5 smoke_now6 ///
	, add(5) rseed(2452777) force
*	, add(1) rseed(1347801) force // change seed if add more
mi describe 	
mi varying	
save mi_r$tdate, replace	

/*

**********************		stroke_hx4 mi_hx4 /// empty cells.
