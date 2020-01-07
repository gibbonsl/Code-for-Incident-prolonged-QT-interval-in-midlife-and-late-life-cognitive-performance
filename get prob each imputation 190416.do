capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"


use forwts$tdate, clear
foreach x in age_2 educ_exam1 height_2 hyp_dx_2 chest_1 {
	bys hhp (exam): replace `x'=`x'[_n-2] if `x'==.
	}
forvalues i=1/5 {
	foreach x in hyp_dx_2 educ_exam1 chest_1 {
		bys hhp (exam): replace _`i'_`x'=_`i'_`x'[_n-2] if _`i'_`x'==.
		}
	}
keep if exam>=4
drop cig_day hc_rx hyp_treat chfhhdhx cvdhx angina_dx_1 ///
	stroke_hx_2 age_1 diabetes_rx cvd_rx // not defined at these visits
*** note that since nodie refers to the next visit, 
*** this is predicting with time invariant and previous visit.

* denominator, death (nodeath) *** incl exposure and outcome
logistic nodie incqt##c.casi_irt months monthssq i.ikn ///
	age_2 occup_1 educ_exam1 any_apoe4 ///
	alcohol_4 hyp_dx_4 hc_rx_4 height_2 cbs_4 ///
	dementpp_4 pvdpp_4 pulmdspp_4 quallf08_4 ///
	liveff bmi diabetes stroke_hx gnhlth cesd /// 
	smoke_now pai dyn_r dyn_l dbp mi_hx ex_reg  thetad10  ///
		hyp_dx_2 alcohol_1 pai_1  chest_1 
	
lroc, nograph		
capture drop pud
predict pud if e(sample)
gen wdun=1/pud 
la var wdun "Unstabilized no die next exam weight, not multiplied through"


bys hhp (exam): replace pud=pud*pud[_n-1] if exam>4 // calculating cumulative probabilities

forvalues i=1/5 {
	logistic nodie incqt##c.casi_irt months monthssq i.ikn ///
		age_2 occup_1 _`i'_educ_exam1 _`i'_any_apoe4 ///
		_`i'_alcohol_4 _`i'_hyp_dx_4 _`i'_hc_rx_4 height_2 _`i'_cbs_4 ///
		_`i'_dementpp_4 _`i'_pvdpp_4 _`i'_pulmdspp_4 _`i'_quallf08_4 ///
		_`i'_liveff _`i'_bmi _`i'_diabetes _`i'_stroke_hx _`i'_gnhlth _`i'_cesd  /// 
		_`i'_smoke_now _`i'_pai _`i'_dyn_r _`i'_dyn_l _`i'_dbp _`i'_mi_hx _`i'_ex_reg ///
		_`i'_thetad10  _`i'_hyp_dx_2 _`i'_alcohol_1  _`i'_pai_1  _`i'_chest_1  
lroc, nograph		

	capture drop _`i'_pud
	predict _`i'_pud if e(sample)
gen _`i'_wdun=1/_`i'_pud 
la var _`i'_wdun "Unstabilized no die  next exam weight, not multiplied through"
	bys hhp (exam): replace _`i'_pud=_`i'_pud*_`i'_pud[_n-1] if exam>4 // calculating cumulative probabilities
	}

* simple numerator, no death ****NO outcome. drop monthssq so don't have a mess later. doesn't matter.
* can include time-invariant covariates

logistic nodie incqt months age_2 i.ikn ///
		educ_exam1 occup_1 any_apoe4 height_2 ///
		hyp_dx_2 alcohol_1 pai_1 chest_1  
lroc, nograph
capture drop pud0
predict pud0 if e(sample)
gen wds=pud0*wdun
la var wds "Stabilized no die next exam weight, not multiplied through"
bys hhp (exam): replace pud0=pud0*pud0[_n-1] if exam>4 // calculating cumulative probabilities
la var pud0 "pr(nodie), numerator"
su pud0, de

forvalues i=1/5 {
	qui logistic nodie incqt months i.ikn ///
		age_2 occup_1 _`i'_educ_exam1 _`i'_any_apoe4 height_2 ///
		_`i'_hyp_dx_2 _`i'_alcohol_1 _`i'_pai_1  _`i'_chest_1  
	capture drop _`i'_pud0
	predict _`i'_pud0 if e(sample)
lroc, nograph		
gen _`i'_wds=_`i'_pud0*_`i'_wdun
la var _`i'_wds "Stabilized no die next exam weight, not multiplied through"
	bys hhp (exam): replace _`i'_pud0=_`i'_pud0*_`i'_pud0[_n-1] if exam>4 // calculating cumulative probabilities
	}

* dropout ***************************************************
* denominator, dropout (nodrop) *** incl exposure and outcome
logistic nodrop incqt##c.casi_irt months monthssq i.ikn ///
		age_2 educ_exam1 occup_1 any_apoe4 height_2  ///
		hyp_dx_2 alcohol_1 pai_1  chest_1 ///
		dementpp_4  prtgrp10_4  ///
		liveff bmi stroke_hx gnhlth cesd cdrsum /// 
		smoke_now pai sbp dbp married thetad10
lroc, nograph
capture drop puc
predict puc if e(sample)
gen wcun=1/puc 
la var wcun "Unstabilized no drop next exam weight, not multiplied through"
bys hhp (exam): replace puc=puc*puc[_n-1] if exam>4 // calculating cumulative probabilities
forvalues i=1/5 {
	qui logistic nodrop incqt##c.casi_irt months monthssq i.ikn ///
		age_2  _`i'_educ_exam1 occup_1 _`i'_any_apoe4 height_2   ///
		_`i'_dementpp_4 _`i'_prtgrp10_4  ///
		_`i'_liveff _`i'_bmi _`i'_stroke_hx _`i'_gnhlth _`i'_cesd  cdrsum /// 
		_`i'_smoke_now _`i'_pai _`i'_sbp _`i'_dbp  _`i'_married _`i'_thetad10 /// 
		_`i'_hyp_dx_2 _`i'_alcohol_1 _`i'_pai_1  _`i'_chest_1  
lroc, nograph		
	capture drop _`i'_puc
	predict _`i'_puc if e(sample)
gen _`i'_wcun=1/_`i'_puc 
la var _`i'_wcun "Unstabilized no drop next exam weight, not multiplied through"
	bys hhp (exam): replace _`i'_puc=_`i'_puc*_`i'_puc[_n-1] if exam>4 // calculating cumulative probabilities
	}

* simple numerator, no drop ****NO outcome. drop monthssq so don't have a mess later. doesn't matter.
logistic nodrop incqt months age_2 i.ikn ///
		educ_exam1 occup_1 any_apoe4 height_2 ///
		hyp_dx_2 alcohol_1 pai_1 chest_1  

lroc, nograph
capture drop puc0
predict puc0 if e(sample)
gen wcs=puc0*wdun
la var wcs "Stabilized no drop next exam weight , not multiplied through"
bys hhp (exam): replace puc0=puc0*puc0[_n-1] if exam>4 // calculating cumulative probabilities
replace puc=1 if nodie==0
replace puc0=1 if nodie==0
la var puc "pr(uncensored), denom (set to 1 if died by then)"
la var puc0 "pr(uncensored), numerator (set to 1 if died by then)"
su puc*, de

forvalues i=1/5 {
	qui logistic nodrop incqt months i.ikn ///
		age_2 occup_1 _`i'_educ_exam1 _`i'_any_apoe4  ///
		_`i'_hyp_dx_2 _`i'_alcohol_1 height_2 _`i'_pai_1  _`i'_chest_1  
lroc, nograph		
	capture drop _`i'_puc0
	predict _`i'_puc0 if e(sample)
gen _`i'_wcs=_`i'_puc0*_`i'_wdun
la var _`i'_wcs "Stabilized no drop next exam weight , not multiplied through"
	bys hhp (exam): replace _`i'_puc0=_`i'_puc0*_`i'_puc0[_n-1] if exam>4 // calculating cumulative probabilities
	}

****************************************************************************
* these are ONLY for death and dropout, do not yet include selection into HAAS
capture drop wdc swdc wdn swdn
gen wdc= 1/(pud*puc) // calculating weights 
gen swdc = (pud0*puc0)/(pud*puc) // calculating stabilized weights
forvalues i=1/5 {
	gen _`i'_wdc= 1/(_`i'_pud*_`i'_puc) // calculating weights 
	***** change this if numerators inclu time dependents vars ******
	gen _`i'_swdc = (_`i'_pud0*_`i'_puc0)/(_`i'_pud*_`i'_puc) // calculating stabilized weights
	}
su *wdc, de
*list hhp exam *wdc nodie nodrop in 1/10, sepby(hhp)

* OK, move to next visit if they exist
gen wdn=1 if exam==4
bys hhp (exam):replace wdn=wdc[_n-1] if exam>4
gen swdn=1 if exam==4
bys hhp (exam):replace swdn=swdc[_n-1] if exam>4
la var wdn "weight for death and dropout exam 4 -> 7"
la var swdn "Stabilized weight for death and dropout exam 4 -> 7"

forvalues i=1/5 {
	gen _`i'_wdn=1 if exam==4
	bys hhp (exam):replace _`i'_wdn=_`i'_wdc[_n-1] if exam>4
	gen _`i'_swdn=1 if exam==4
	bys hhp (exam):replace _`i'_swdn=_`i'_swdc[_n-1] if exam>4
	la var _`i'_wdn "weight for death and dropout exam 4 -> 7"
	la var _`i'_swdn "Stabilized weight for death and dropout exam 4 -> 7"
	}

su *wdn, de
format *wdc *wdn %7.3f
*list hhp exam *swdn nodie nodrop in 1/30, sepby(hhp) noobs

su *wdun *wds *wcun *wcs, sep(6)
save weights_i$tdate, replace

di (.7856+.7855+.7853+.7855+.7858)/5 // nodie denom .7855
// nodie num all .668
di (.6634+.6628+.6640+.6633+.6642)/5 // .66354 no drop denom
di (.5984+.5979+.5983+.5984+.5985)/5 // no drop num .5983
