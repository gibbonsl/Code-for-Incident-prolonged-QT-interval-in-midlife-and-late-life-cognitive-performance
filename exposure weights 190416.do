* adapted from Evan's code

use forwts$tdate, clear
qui foreach x in diabetes cvd_rx diabetes_rx {
	bys hhp (exam):gen `x'_prior=`x'[_n-1]
	}
qui forvalues i=1/5 {
	foreach x in diabetes cvd_rx diabetes_rx {
		bys hhp (exam):gen _`i'_`x'_prior=_`i'_`x'[_n-1]
		}
	}	
keep if inlist(exam,2,3)

* denomin - stripped down a bit from his model
logit incqtadj75 months monthssq age_2 ///
	  i.ikn alcohol_1 pai_1   ///
      chfhhdhx bmi sbp dbp  ///
	  hyp_treat cvd_rx_prior diabetes_rx occup_1  height_2 ///
		hyp_dx_2  chest_1  		

lroc, nograph	 
predict p_denom if e(sample)
* varies by exposure:
gen weight_us = 1 /      p_denom  if incqtadj75 == 1
replace weight_us = 1 / (1 - p_denom) if incqtadj75 == 0

gen eun=weight_us
la var eun "Unstabilized exposure weight, not multiplied through"

bys hhp (exam): replace weight_us=weight_us*weight_us[_n-1] if exam==3 
	// calculating cumulative probabilities

forvalues i=1/5 {
	logit incqtadj75 months monthssq age_2 ///
		  i.ikn _`i'_alcohol_1 _`i'_pai_1 ///
		  _`i'_chfhhdhx _`i'_bmi _`i'_sbp _`i'_dbp   ///
		  _`i'_hyp_treat _`i'_cvd_rx_prior _`i'_diabetes_rx
	lroc, nograph	 
	predict _`i'_p_denom  if e(sample)
	gen _`i'_weight_us = 1 /      _`i'_p_denom  if incqtadj75 == 1
	replace _`i'_weight_us = 1 / (1 - _`i'_p_denom) if incqtadj75 == 0
	bys hhp (exam): replace _`i'_weight_us=_`i'_weight_us*_`i'_weight_us[_n-1] if exam==3 
	gen _`i'_eun=_`i'_weight_us
	la var _`i'_eun "Unstabilized exposure weight, not multiplied through"
	}

* NUMERATOR MODEL --> stabilized weights for incident exposure (INCQTADJ75)
logit incqtadj75 months age_2 i.ikn pai_1 educ_exam1 alcohol_1 occup_1  height_2 ///
		hyp_dx_2  chest_1  		
	// took out monthssq so final model is tractable
lroc, nograph	 
predict p_num  if e(sample)
gen weight_stab =      p_num  /      p_denom  if incqtadj75 == 1
replace weight_stab = (1 - p_num) / (1 - p_denom) if incqtadj75 == 0

gen es=weight_st
la var es "Stabilized exposure weight, not multiplied through"

bys hhp (exam): replace weight_stab=weight_stab*weight_stab[_n-1] if exam==3 
	// calculating cumulative probabilities

forvalues i=1/5 {
	logit incqtadj75 months age_2 ///
		  i.ikn _`i'_educ_exam1 _`i'_pai_1 
	lroc, nograph	 
	predict _`i'_p_num if e(sample)
	gen _`i'_weight_stab =      _`i'_p_num  /      _`i'_p_denom  if incqtadj75 == 1
	replace _`i'_weight_stab = (1 - _`i'_p_num) / (1 - _`i'_p_denom) if incqtadj75 == 0
	bys hhp (exam): replace _`i'_weight_stab=_`i'_weight_stab*_`i'_weight_stab[_n-1] if exam==3 
	gen _`i'_es=_`i'_weight_st
	la var _`i'_es "Stabilized exposure weight, not multiplied through"
	}

bys hhp (exam):gen eun2=eun[_n-1] if exam==3
bys hhp (exam):gen es2=es[_n-1] if exam==3
la var eun2 "Unstabilized exposure weight exam 2"
la var es2 "Stabilized exposure weight exam 2"
forvalues i=1/5 {
	bys hhp (exam):gen _`i'_eun2=_`i'_eun[_n-1] if exam==3
	bys hhp (exam):gen _`i'_es2=_`i'_es[_n-1] if exam==3
	la var _`i'_eun2 "Unstabilized exposure weight exam 2"
	la var _`i'_es2 "Stabilized exposure weight exam 2"
		}

*********************	
keep if exam==3
*********************

keep hhp *weight_stab *weight_us *eun* *es2 *es qtadj75_2
drop *diabetes*

**** exposure weight is 1 at exam 3 if exposed at exam 2. 
* does not affect es2, es3, eun2, eun3
foreach x of varlist *weight_stab *weight_us *es *eun {
	replace `x'=1 if qtadj75_2==1
	}
order *eun*, after(_5_weight_stab)
order *es, after(_5_eun2) 
rename *es *es3
rename *eun *eun3
rename _*_es _*_es3 // why needed?
rename _*_eun _*_eun3

save exposurewts_$tdate, replace

* ROC work around
di (.5823+.5823+.5820+.5822+.5820)/5 // denom 0.582
di (.5598+.5597+.5597+.5599+.5599)/5 // num 0.560
