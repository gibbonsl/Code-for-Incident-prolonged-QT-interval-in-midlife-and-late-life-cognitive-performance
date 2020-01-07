capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"
global tdate "170608"

use forwts$tdate, clear
la var chest_1 "exam 1: chest depth(cm)"
la def ed1 1 "None/primary" 2 "Intermediate" 3 HS 4 "Technical school" ///
	5 "University"
	la val educ_exam1 ed1  // note 0 educ was recoded as one
la var incqt "QT in upper quartile at exam 2 or 3"
foreach x in age_2 educ_exam1 height_2 hyp_dx_2 chest_1 {
	bys hhp (exam): replace `x'=`x'[_n-2] if `x'==.
	}
gen htcm_2=height_2*2.54
gen htcm_4=height_4*2.54	
keep if inlist(exam,2,4)

de incqt age_2 ikn pai_1 educ_exam1 hyp_dx_2 alcohol_1 height_2 ///
chest_1 occup_1 any_apoe4 

tab incqt if exam==4
su casi_irt if exam==4
foreach x in ikn educ_exam1 hyp_dx_2 occup_1 any_apoe4 {
	tab `x' exam, col
	}

bys exam:su age_* pai_1  alcohol_1 htcm_* chest_1   

/*
foreach x in hc_rx diabetes_rx cvd_rx thy_rx {
	tab exam `x' 
	}
	*/

merge 1:1 hhp exam using honoexmall_170217, nogen update replace ///
	keepusing(vent_rate qt_int) 	keep(1 3 4 5) // rest are exams 8-12
* from Evan's "ExposureWeights181204.do"	
gen     rr_int = 60 / vent_rate
replace qt_int = qt_int / 100	
gen     qtadj = qt_int + 0.158*(1 - rr_int)
*looks like .4065
su qtadj if exam==2

bys hhp (exam):gen N=_N 
su qtadj if exam==2 & N==2 // have exam 4
tab incqt if exam==4


* heart disease
keep if exam==4
save temp, replace

use honoexmall_170217, clear
keep hhp exam hyp_dx hyp_treat hyp_hx hhd_dx cvd_other_dx hypbp1 hypbp2 ///
	my_isch mi_dx mi_hx cbs blloon stroke_hx angina_dx chf_dx pvd13
merge m:1 hhp using temp, keep(3) 
keep if inrange(exam,4,7)
de hyp_dx hyp_treat hyp_hx hhd_dx cvd_other_dx hypbp1 hypbp2 ///
	my_isch mi_dx mi_hx cbs blloon stroke_hx angina_dx chf_dx pvd13
	
* not hypertension unless HHD
de hhd_dx my_isch mi_dx mi_hx cbs blloon stroke_hx angina_dx chf_dx pvd13
bys exam: su hhd_dx my_isch mi_dx mi_hx cbs blloon stroke_hx angina_dx chf_dx pvd13
* this is based on full data at exam4, and then fewer and fewer variables so 
* that by exam 7 it's ONLY stroke_hx
gen c=0
foreach x in  hhd_dx my_isch mi_dx mi_hx cbs blloon stroke_hx angina_dx chf_dx pvd13 {
	replace c=1 if `x'==1 // leave out "doubtful"
	}
tab exam c, row
bys exam:tab incqt c, row exact

keep if exam==4
foreach x in ikn educ_exam1 occup_1 hyp_dx_4 c any_apoe4 {
	tab `x' incqt, col
	}

bys incqt:su age_4 alcohol_4 htcm_4 chest_1 pai_1
su age_4 alcohol_4 htcm_4 chest_1 pai_1

* hc_rx_4 angina_dx_4 cbs_4 pvdpp_4 pulmdspp_4

*MI weights
use combined170608, clear
keep if exam==4
mi estimate: mean swtcomb // only does 2453, why?

*** weighted back swtcomb tswtcomb
use forsas181204, clear
keep if _Imputation_==0 & exam==4
gen htcm_4=height_4*2.54	
gen htcm_2=height_2*2.54	

* truncated wts are the same as untruncated here
tab1 ikn educ_exam1 hyp_dx_2 occup_1 
tab1 ikn educ_exam1 hyp_dx_2 occup_1 [aweight=swtcomb]
tab1 ikn educ_exam1 hyp_dx_2 occup_1 [aweight=unswtcomb]

su age_2 alcohol_1 htcm_2 chest_1 pai_1
su age_2 alcohol_1 htcm_2 chest_1 pai_1 [aweight=swtcomb]
su age_2 alcohol_1 htcm_2 chest_1 pai_1 [aweight=unswtcomb]

*** p-values for table 1 ***********************************************
foreach x in ikn educ_exam1 hyp_dx_2 occup_1 any_apoe4 {
	tab `x' incqt , col chi2
	}

bys incqt:su age_2 alcohol_1 htcm_2 chest_1 pai_1

foreach x in  age_2 alcohol_1 htcm_2 chest_1 pai_1 {
	ttest `x',by(incqt)
	}
ranksum educ_exam1, by(incqt)

* do on exam 2 or 4?
use forsas181204, clear
keep if _Imputation_==0 & exam==4
keep hhp swtcomb unswtcomb
merge 1:m hhp using honoexmall_170217, 
keep if exam==2
replace diabetes_rx=0 if diabetes==0
su bmi  hyp_treat cvd_rx diabetes_rx hc_rx smoke_now  
su bmi  hyp_treat cvd_rx diabetes_rx hc_rx smoke_now if swtcomb<. 
su bmi  hyp_treat cvd_rx diabetes_rx hc_rx smoke_now  [aweight=swtcomb]
su bmi  hyp_treat cvd_rx diabetes_rx hc_rx smoke_now  [aweight=unswtcomb]

* hyp treat
use forwts$tdate, clear
keep hyp_treat hhp exam
keep if inlist(exam,2,4)
bys hhp (exam):keep if _N==2 // difficult to reshape because of mi set
drop if exam==4
tab hyp_treat

/*
chfhhdhx
bys exam: su chfhhdhx hyp_treat cvd_rx diabetes_rx hc_rx smoke_now 
Systolic blood pressure
Diastolic blood pressure
Current smoker
Cigarettes/day
Stroke history
Myocardial infarction history
Married
