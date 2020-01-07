* all regression, no logistic
use mi1_3_$tdate, clear // 
*use mi1_3_r$tdate, clear // when adding

* diabetes_rx1 sbp1 dbp1 hyp_dx_1 cvd_rx2

* fixed history vars
mi impute chained 	/// 3
	(regress) sbp3-chfhhdhx3 any_apoe4 qtadj75_3 cvdhx3 ///
	/// 2
	(regress, omit(sbp3-chfhhdhx3 age3 qtadj75_3 cvdhx3)) sbp2-chfhhdhx2 diabetes_rx2 ///
		hyp_dx_2-angina_dx_2 qtadj75_2 cvdhx2 ///
	///	1
	(regress, omit(sbp3-chfhhdhx3 age3 sbp2-chfhhdhx2 diabetes_rx2 ///
		height_2 hyp_dx_2-angina_dx_2 qtadj75_2 cvdhx3 cvdhx2)) ///
		cig_day1-chfhhdhx1 alcohol_1 pai_1-chest_1 educ_exam1 qtadj75_1 cvdhx1 ///
	= 		  		///
		age1 age2 age3 age_1 diabetes_rx1 sbp1 dbp1 hyp_dx_1  ///
		height_2 height_1 ///
	, add(5) rseed(2466755) force
*	, add(1) rseed(8378713) force
mi describe 	
mi varying	
save mi1_3_r$tdate, replace	


/* easiest just to leave this way for reshape
imputed nonvarying:   angina_dx_2 chfhhdhx1 chfhhdhx2 cvd_rx2 ///
			  stroke_hx_2


