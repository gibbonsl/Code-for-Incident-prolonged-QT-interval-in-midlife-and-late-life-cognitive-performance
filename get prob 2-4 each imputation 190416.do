capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

* get probablilities for death and dropout exams 2 -> 4

use forwts$tdate, clear
keep if inlist(exam,2,3)

*** note that since nodie refers to the next visit, 
*** this is predicting with time invariant and previous visit.

* denominator, death (nodeath) *** would incl exposure and outcome if we could
logistic nodie incqt months monthssq i.ikn ///
		educ_exam1 age_2 occup_1 height_2 ///
		hyp_dx_2 alcohol_1  pai_1  chest_1 ///   
		sbp dbp cig_day bmi hc_rx hyp_treat smoke_now ///
		stroke_hx married chfhhdhx
lroc, nograph		
capture drop pud
predict pud if e(sample)
gen wdun23=1/pud if exam==2
gen wdun34=1/pud if exam==3
la var wdun23 "Unstabilized no die weight exam 2 (nodie exam 3), not multiplied through"
la var wdun34 "Unstabilized no die weight exam 3 (nodie exam 4), not multiplied through"
bys hhp (exam): replace pud=pud*pud[_n-1] if exam==3 // calculating cumulative probabilities

forvalues i=1/5 {
	logistic nodie incqt months monthssq i.ikn ///
		_`i'_educ_exam1 age_2 _`i'_occup_1 height_2 ///
		_`i'_hyp_dx_2 _`i'_alcohol_1  _`i'_pai_1  _`i'_chest_1 ///   
		_`i'_sbp _`i'_dbp _`i'_cig_day _`i'_bmi _`i'_hc_rx _`i'_hyp_treat _`i'_smoke_now ///
		_`i'_stroke_hx _`i'_married _`i'_chfhhdhx
	lroc, nograph		
	capture drop _`i'_pud
	predict _`i'_pud if e(sample)
	gen _`i'_wdun23=1/_`i'_pud if exam==2
	gen _`i'_wdun34=1/_`i'_pud if exam==3
	la var _`i'_wdun23 "Unstabilized no die weight exam 2 (nodie exam 3), not multiplied through"
	la var _`i'_wdun34 "Unstabilized no die weight exam 3 (nodie exam 4), not multiplied through"
	bys hhp (exam): replace _`i'_pud=_`i'_pud*_`i'_pud[_n-1] if exam==3 // calculating cumulative probabilities
	}

bys hhp (exam): replace pud=pud*pud[_n-1] if exam==3 // calculating cumulative probabilities
su pud, de 

* simple numerator, no death ****NO outcome
* can include time-invariant covariates
logistic nodie incqt age_2 months  i.ikn ///
		educ_exam1 occup_1 height_2 ///
		hyp_dx_2 alcohol_1 pai_1 chest_1  
lroc, nograph		
capture drop pud0
predict pud0 if e(sample)

gen wds23=pud0*wdun23 if exam==2
gen wds34=pud0*wdun34 if exam==3
la var wds23 "Stabilized no die weight exam 2 (nodie exam 3), not multiplied through"
la var wds34 "Stabilized no die weight exam 3 (nodie exam 4), not multiplied through"

bys hhp (exam): replace pud0=pud0*pud0[_n-1] if exam==3 // calculating cumulative probabilities
la var pud0 "pr(nodie), numerator"
su pud0, de

forvalues i=1/5 {
	logistic nodie incqt months monthssq i.ikn ///
		_`i'_educ_exam1 age_2 _`i'_occup_1  ///
		_`i'_hyp_dx_2 _`i'_alcohol_1  _`i'_pai_1  _`i'_chest_1 
	lroc, nograph		
	capture drop _`i'_pud0
	predict _`i'_pud0 if e(sample)
gen _`i'_wds23=_`i'_pud0*_`i'_wdun23 if exam==2
gen _`i'_wds34=_`i'_pud0*_`i'_wdun34 if exam==3
la var _`i'_wds23 "Stabilized no die weight exam 2 (nodie exam 3), not multiplied through"
la var _`i'_wds34 "Stabilized no die weight exam 3 (nodie exam 4), not multiplied through"
	bys hhp (exam): replace _`i'_pud0=_`i'_pud0*_`i'_pud0[_n-1] if exam==3 // calculating cumulative probabilities
	}


* dropout ***************************************************
* denominator, dropout (nodrop) *** incl exposure and would do outcome if could
logistic nodrop incqt months monthssq age_2 i.ikn ///
		educ_exam1 occup_1 height_2 chest_1 ///   
		sbp  cig_day bmi hc_rx hyp_treat    ///
		hyp_dx_2 alcohol_1 pai_1  
lroc, nograph		
capture drop puc
predict puc if e(sample)
gen wcun23=1/puc if exam==2
gen wcun34=1/puc if exam==3
la var wcun23 "Unstabilized no drop weight exam 2 (nodrop exam 3), not multiplied through"
la var wcun34 "Unstabilized no drop weight exam 3 (nodrop exam 4), not multiplied through"
bys hhp (exam): replace puc=puc*puc[_n-1] if exam==3 // calculating cumulative probabilities

forvalues i=1/5 {
	logistic nodrop incqt months monthssq i.ikn ///
		_`i'_educ_exam1 age_2 _`i'_occup_1 height_2 _`i'_chest_1 ///
		_`i'_sbp  _`i'_cig_day _`i'_bmi _`i'_hc_rx _`i'_hyp_treat  ///
		_`i'_hyp_dx_2 _`i'_alcohol_1 _`i'_pai_1  
	capture drop _`i'_puc
	predict _`i'_puc if e(sample)
lroc, nograph		
gen _`i'_wcun23=1/_`i'_puc if exam==2
gen _`i'_wcun34=1/_`i'_puc if exam==3
la var _`i'_wcun23 "Unstabilized no die weight exam 2 (nodie exam 3), not multiplied through"
la var _`i'_wcun34 "Unstabilized no die weight exam 3 (nodie exam 4), not multiplied through"
	bys hhp (exam): replace _`i'_pud0=_`i'_pud0*_`i'_pud0[_n-1] if exam==3 // calculating cumulative probabilities
	}

* simple numerator, no drop ****NO outcome
logistic nodrop incqt age_2 months i.ikn  ///
		educ_exam1 occup_1 height_2   ///
		hyp_dx_2 alcohol_1 pai_1 chest_1  
lroc, nograph		
capture drop puc0
predict puc0 if e(sample)
gen wcs23=puc0*wcun23 if exam==2
gen wcs34=puc0*wcun34 if exam==3
la var wcs23 "Stabilized no drop weight exam 2 (nodrop exam 3), not multiplied through"
la var wcs34 "Stabilized no drop weight exam 3 (nodrop exam 4), not multiplied through"

bys hhp (exam): replace puc0=puc0*puc0[_n-1] if exam==3 // calculating cumulative probabilities

replace puc=1 if nodie==0
replace puc0=1 if nodie==0
la var puc "pr(uncensored), denom (set to 1 if died by then)"
la var puc0 "pr(uncensored), numerator (set to 1 if died by then)"
su puc*, de

forvalues i=1/5 {
	logistic nodrop incqt months monthssq  ///
		_`i'_educ_exam1 age_2 _`i'_occup_1  ///
		_`i'_hyp_dx_2 _`i'_alcohol_1 height_2 _`i'_pai_1  _`i'_chest_1  
	capture drop _`i'_puc0
lroc, nograph		
	predict _`i'_puc0 if e(sample)
gen _`i'_wcs23=_`i'_puc0*_`i'_wcun23 if exam==2
gen _`i'_wcs34=_`i'_puc0*_`i'_wcun34 if exam==3
la var _`i'_wcs23 "Stabilized no drop weight exam 2 (nodrop exam 3), not multiplied through"
la var _`i'_wcs34 "Stabilized no drop weight exam 3 (nodrop exam 4), not multiplied through"
	bys hhp (exam): replace _`i'_puc0=_`i'_puc0*_`i'_puc0[_n-1] if exam==3 // calculating cumulative probabilities
	replace _`i'_puc=1 if nodie==0
	replace _`i'_puc0=1 if nodie==0
	}

****************************************************************************
* these are ONLY for death and dropout for selection into HAAS
capture drop wdc* swdc* wdn* swdn*
gen wdc24= 1/(pud*puc) // calculating weights 
gen swdc24 = (pud0*puc0)/(pud*puc) // calculating stabilized weights
su *wdc*, de
*list hhp exam *wdc nodie nodrop in 1/10, sepby(hhp)

* do separately for Melinda
gen wc24=1/puc
gen wd24=1/pud
la var wc24 "weight dropout exam 2 -> 4"
la var wd24 "weight death exam 2 -> 4"

* combine weights, put at exam 3
replace wc24=wc24*wc24[_n-1] if exam==3
replace wd24=wd24*wd24[_n-1] if exam==3
gen wdn24=wdc*wdc[_n-1] if exam==3
gen swdn24=swdc*swdc[_n-1] if exam==3
la var wdn24 "weight for death and dropout exam 2 -> 4"
la var swdn24 "Stabilized weight for death and dropout exam 2 -> 4"

forvalues i=1/5 {
	gen _`i'_wc24= 1/(_`i'_puc) // calculating weights 
	gen _`i'_wd24= 1/(_`i'_pud) // calculating weights 
	gen _`i'_wdc24= 1/(_`i'_pud*_`i'_puc) // calculating weights 
	gen _`i'_swdc24 = (_`i'_pud0*_`i'_puc0)/(_`i'_pud*_`i'_puc) // calculating stabilized weights

	* combine
	replace _`i'_wc24=_`i'_wc24*_`i'_wc24[_n-1] if exam==3
	replace _`i'_wd24=_`i'_wd24*_`i'_wd24[_n-1] if exam==3
	gen _`i'_wdn24=_`i'_wdc*_`i'_wdc[_n-1] if exam==3
	gen _`i'_swdn24=_`i'_swdc*_`i'_swdc[_n-1] if exam==3
	}
	
format *wdc* *wdn* %7.3f
*list hhp exam *wdc* *wdn* nodie nodrop in 1/30, sepby(hhp) noobs

foreach x of varlist *23 {
	bys hhp (exam):replace `x'=`x'[_n-1] if `x'==.
	}

keep if exam==3
keep hhp *24 ///
	age_2 *educ_exam1 *hyp_dx_2 *height_2 *chest_1 *angina_dx_2 *23 *34
save weights24i_mi$tdate, replace
su wdn swdn, de
su wc24 wd24

* nodie denom 
di (.8887+.8887+.8890+.8887+.8887)/5 // .8888
* num 
di (.8758+.8758+.8760+.8758+.8758)/5 // .8758
* nodrop denom
di (.7887+.7884+.7891+.7886+.7883)/5 //.7886
* no drop num
di (.7797+.7796+.7798+.7799+.7797)/5 //.7797
