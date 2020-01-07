
capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

* start at least with just the possible variables in the model as imputation source.
* may add other variables.

use ekg_for_mi$tdate, clear 
keep if exam<=3


su cvdhx cadhx chfhhdhx stroke_hx diabetes bmi sbp dbp smoke_now cig_day hc_rx hyp_treat ///
	cvd_rx thy_rx diabetes_rx alcohol pai chest_depth 
bys exam:su cvdhx cadhx chfhhdhx stroke_hx diabetes bmi sbp dbp smoke_now cig_day hc_rx hyp_treat ///
	cvd_rx thy_rx diabetes_rx alcohol pai chest_depth 
	
************************************************************	
* very few have diabetes_rx at exam 2 - may be a problem.
* missing by design: 
* cvd_rx3 thy_rx3 diabetes_rx3 
* also chest_depth alcohol pai after 1
************************************************************
	
*bys exam: su married smoke_now bmi pai dyn_r dyn_l sbp dbp diabetes mi_hx stroke_hx 
** get exam 1 educ?
gen chest_1=chest_depth 
bys hhp (exam):replace chest_1=chest_1[_n-1] if chest_1==.

keep hhp exam age qtadj75_2 qtadj75_3 qtadj75_1 ///
	educ any_apoe4 *_1 married smoke_now bmi pai dyn_r ///
	dyn_l sbp dbp diabetes stroke_hx ///
	cadhx chfhhdhx stroke_hx diabetes bmi sbp dbp smoke_now cig_day hc_rx hyp_treat ///
	cvd_rx thy_rx diabetes_rx pai *_2 educ_exam1 cvdhx
drop hc_rx_1 pai 

* weird but needed
gsort hhp -exam
foreach x of varlist *_2 {
	by hhp:replace `x'=`x'[_n-1] if `x'==.
	}
	
* just convenient
order educ* diabetes_rx sbp dbp  hyp_dx_1 alcohol_1 height_1-occup_1 chest_1 /// 
	*_2 cig_day bmi hc_rx  cvd_rx thy_rx hyp_treat ///
	smoke_now bmi dyn_r dyn_l  ///
	diabetes stroke_hx   married cadhx chf chest stroke_hx cvdhx  ///
	, after(exam)
order qtadj75_1, before(qtadj75_2)	
reshape wide  diabetes_rx sbp dbp cig_day-age  ///
	, i(hhp) j(exam)
drop cvd_rx3 diabetes_rx3 dyn_r3 dyn_l3 diabetes3 // missing by design
* too rare -> empty cells?
tab1 hc_rx* thy_rx* cadhx* chf* stroke_hx*
drop thy_rx* cadhx* // may add others

* it's by attended, not graduated
replace educ_exam1=1 if educ==4 & educ_exam1==.
replace educ_exam1=2 if inlist(educ,8,9) & educ_exam1==.
replace educ_exam1=3 if inlist(educ,10,11,12) & educ_exam1==.

drop educ // exam 4
save mi1_3_$tdate, replace


********** include qtadj, per Melinda ****************************

mi set wide 
su
*mi misstable summarize

* These are the variables with no missing data, in long from
mi register regular hhp age1 age2 age3 age_1 age_2  /// 
	 diabetes_rx1 sbp1 dbp1 hyp_dx_1 height_2 height_1 
	
* The variables with missing data 
mi register imputed educ_exam1 cig_day1-stroke_hx1 diabetes_rx2-hc_rx2 any_apoe4 ///
	hyp_treat2-stroke_hx2 sbp3-stroke_hx3 ///
	alcohol_1 pai_1-angina_dx_1 occup_1 chest_1 hyp_dx_2  angina_dx_2 ///
	married1 chfhhdhx1 married2  chfhhdhx2 married3 chfhhdhx3 stroke_hx_2 cvd_rx2 ///
	 qtadj75_1 qtadj75_2 qtadj75_3 cvdhx1 cvdhx2 cvdhx3
	 
mi describe
save mi1_3_$tdate, replace
	
