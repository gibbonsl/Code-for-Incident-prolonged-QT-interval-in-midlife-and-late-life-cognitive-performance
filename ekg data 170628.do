*capture cd "C:\Users\Laura\Documents\HAAS"
capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"
capture cd "D:\Laura\FH2016\HAAS"

insheet using qtadj75_170210.csv, clear names comma
keep if qta<.
keep hhp
duplicates drop
tempfile keep
save `keep'

insheet using qtadj75_170210.csv, clear names comma
unique hhp // 8006
unique hhp if qta<. // 7757
merge 1:1 hhp exam using haas_EKGpaper_160810, nogen
* somehow dyn_l was set to R at exam 5 in haas_EKGpaper_160810
merge 1:1 hhp exam using honoexmall_170217, nogen update replace ///
	keepusing(dyn_l) 	keep(1 3 4 5) // rest are exams 8-12
merge m:1 hhp using `keep', nogen // 6/8 now has all visits even if missing qti
	// just exams 1-7
unique hhp //  8006
* first round of cleanup
replace pai=pai/10 if exam==1 // Laura verified, not corrected in 160810
replace dyn_l=. if dyn_l==0 // judging by when one only is missing
replace dyn_r=. if dyn_r==0 
** per ES
replace mi_hx=. if exam==7
** this variable is messed up
replace any_apoe4=1 if apoe_geno==34
replace any_apoe4=. if apoe_geno==.


* for this
replace cdr=0 if cdr==. & exam >=4
notes cdr: set to zero if missing
	
recode hc_rx (8=.)
recode thy_dx (2=0) (3=1), gen(thy_hx)
la var thy_hx "Thyroid disease current or past"
recode pulmds13 (2=1), gen(pulmdspp)
la var pulmdspp "Yes or possible pulmonary disease"	
recode pvd13 (2=1), gen(pvdpp)
la var pvdpp "Yes or possible peripheral vascular disease"	
recode live_alone (2 3=1) (4/6=0), gen(liveff)
la var liveff "Live with family/friends vs alone, NH, paid help"
recode hyp_dx (2=0)
notes hyp_dx: doubtful recoded to "no"	
recode angina_dx (8=0)
notes angina_dx: doubtful recoded to "no"	
*list hhp exam in 1/30, sepby(hhp) // hhp 10
recode stroke_hx (8=.)

* everyone starts at 1
foreach x of varlist age alcohol hyp_dx hc_rx height pai angina_dx {
	bys hhp (exam):gen `x'_1=`x'[1] 
	bys hhp (exam):gen `x'_4=`x' if exam==4
	label variable `x'_1 "`:variable label `x'', exam 1" 
	label variable `x'_4 "`:variable label `x'', exam 4" 
	bys hhp (exam): replace `x'_1=`x'_1[_n-1] if `x'_1==.
	bys hhp (exam): replace `x'_4=`x'_4[_n-1] if `x'_4==.
	}
* 4 only
foreach x of varlist thy_hx my_isch cbs blloon dement13 pvdpp ///
	pulmdspp prtgrp quallf08  {
	bys hhp (exam):gen `x'_4=`x' if exam==4
	label variable `x'_4 "`:variable label `x'', exam 4" 
	bys hhp (exam): replace `x'_4=`x'_4[_n-1] if `x'_4==.
	}
* 1 only	
foreach x of varlist occup_curr occup_usu qtadj75 {
	bys hhp (exam):gen `x'_1=`x' if exam==1
	label variable `x'_1 "`:variable label `x'', exam 1" 
	bys hhp (exam): replace `x'_1=`x'_1[_n-1] if `x'_1==.
	} 
gen occup_1=occup_curr_1
replace occup_1=occup_usual_1 if occup_1==0	| occup_1==8	
recode occup_1 (1/3 5 7 8=0) (4 6=1)
la var occup_1 "Clerical/sales/prof/manage, exam 1"
recode dement13_4 (2=1), gen(dementpp_4)
la var dementpp_4 "Dementia yes or possible at exam 4"
drop occup_curr occup_usual occup_curr_1 occup_usual_1 dement13*
* visit 2 for main model
recode stroke_hx (2=0)
foreach x of varlist stroke_hx hyp_dx angina_dx age height {
	bys hhp (exam):gen `x'_2=`x' if exam==2
	label variable `x'_2 "`:variable label `x'', exam 2" 
	bys hhp (exam): replace `x'_2=`x'_2[_n-1] if `x'_2==.
	}
preserve
keep hhp exam 
gen x=1
reshape wide x,  i(hhp) j(exam)
rename x* exam*
tempfile temp
save `temp'
restore
merge m:1 hhp using `temp', nogen
forvalues i=1/7 {
	la var exam`i' "Had exam `i'"
	}
bys hhp (exam):gen examdatel=examdate[_N]
la var examdatel "Last exam date"
gen enddate=max(mdy(2,11,2010),examdatel)
replace enddate=deathdt if deathdt<.
format enddate %td
la var enddate "Last exam or 2/11/2010"
bys hhp (exam):gen lastexam=exam[_N]
bys hhp (exam):gen examdate1=examdate[1]
la var examdate1 "Exam 1 date"
gen examdate2=examdate if exam==2
bys hhp (exam):replace examdate2=examdate2[_n-1] if exam>2
gen months=mofd(examdate)-mofd(examdate2) 
la var months "Months in study (from exam 2)"
gen monthssq=months^2
gen yrs=months/12
gen yrssq=yrs^2
la var yrs "Years in study (to the nearest month)"
gen married=marital==1 if marital<.
la var married "Married (none at ex 5,7)"
merge 1:1 hhp exam using d10, keepusing(theta) keep(1 3)

gen qtadj75_2=qtadj75 if exam==2
gen qtadj75_3=qtadj75 if exam==3
bys hhp (exam): replace qtadj75_2=qtadj75_2[_n-1] if qtadj75_2==.
bys hhp (exam): replace qtadj75_3=qtadj75_3[_n-1] if qtadj75_3==.
gsort hhp -exam
by hhp: replace qtadj75_2=qtadj75_2[_n-1] if qtadj75_2==.
by hhp: replace qtadj75_3=qtadj75_3[_n-1] if qtadj75_3==.
la var qtadj75_2 "qtadj75, exam 2"
la var qtadj75_3 "qtadj75, exam 3"

* some missing height_2 or 4
bys hhp (exam):replace height=height[_n-1] if height==. 
replace height_2=height if height_2==. & exam==2
bys hhp (exam):replace height_2=height_2[_n-1] if height_2==.
replace height_4=height if height_4==. & exam>3
gsort hhp -exam
bys hhp:replace height_2=height_2[_n-1] if height_2==.
replace height_2=height_1 if height_2==.
replace height_1=height_2 if height_1==.
drop height // messed with

*adapted From Evan
* cvdhx: history of coronary artery disease or other cardiovascular disease -- cumulatively updated at each exam
bysort hhp (exam): gen     cvdhx = 0           if exam == 1
bysort hhp (exam): replace cvdhx = 1           if exam == 1 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1 | angina_dx == 1 | angina_hx == 1 | cvd_other_dx == 1)
bysort hhp (exam): replace cvdhx = .           if exam == 1 & cvdhx != 1 & (mi_dx == . | mi_hx == . | my_isch == . | angina_dx == . | angina_hx == . | cvd_other_dx == .)
bysort hhp (exam): replace cvdhx = cvdhx[_n-1] if exam == 2
bysort hhp (exam): replace cvdhx = 1           if exam == 2 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1 | angina_dx == 1 | angina_hx == 1 | cvd_other_dx == 1)
bysort hhp (exam): replace cvdhx = .           if exam == 2 & cvdhx != 1 & (mi_dx == . | mi_hx == . | my_isch == . | angina_dx == . | angina_hx == . | cvd_other_dx == .)
bysort hhp (exam): replace cvdhx = cvdhx[_n-1] if exam == 3
bysort hhp (exam): replace cvdhx = 1           if exam == 3 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1                  | angina_hx == 1 | cvd_other_dx == 1) /* no angina_dx var at exam 3 */
bysort hhp (exam): replace cvdhx = .           if exam == 3 & cvdhx != 1 & (mi_dx == . | mi_hx == . | my_isch == .                  | angina_hx == . | cvd_other_dx == .) /* no angina_dx var at exam 3 */
bysort hhp (exam): gen     cadhx = 0           if exam == 1
bysort hhp (exam): replace cadhx = 1           if exam == 1 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1 | angina_dx == 1 | angina_hx == 1)
bysort hhp (exam): replace cadhx = .           if exam == 1 & cadhx != 1 & (mi_dx == . | mi_hx == . | my_isch == . | angina_dx == . | angina_hx == .)
bysort hhp (exam): replace cadhx = cadhx[_n-1] if exam == 2
bysort hhp (exam): replace cadhx = 1           if exam == 2 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1 | angina_dx == 1 | angina_hx == 1)
bysort hhp (exam): replace cadhx = .           if exam == 2 & cadhx != 1 & (mi_dx == . | mi_hx == . | my_isch == . | angina_dx == . | angina_hx == .)
bysort hhp (exam): replace cadhx = cadhx[_n-1] if exam == 3
bysort hhp (exam): replace cadhx = 1           if exam == 3 &              (mi_dx == 1 | mi_hx == 1 | my_isch == 1                  | angina_hx == 1) /* no angina_dx var at exam 3 */
bysort hhp (exam): replace cadhx = .           if exam == 3 & cadhx != 1 & (mi_dx == . | mi_hx == . | my_isch == .                  | angina_hx == .) /* no angina_dx var at exam 3 */
bysort hhp (exam): gen     chfhhdhx = 0              if exam == 1
bysort hhp (exam): replace chfhhdhx = 1              if exam == 1 &                 (chf_dx == 1 | hhd_dx == 1)
bysort hhp (exam): replace chfhhdhx = .              if exam == 1 & chfhhdhx != 1 & (chf_dx == . | hhd_dx == .)
bysort hhp (exam): replace chfhhdhx = chfhhdhx[_n-1] if exam == 2
bysort hhp (exam): replace chfhhdhx = 1              if exam == 2 &                 (chf_dx == 1 | hhd_dx == 1)
bysort hhp (exam): replace chfhhdhx = .              if exam == 2 & chfhhdhx != 1 & (chf_dx == . | hhd_dx == .)
bysort hhp (exam): replace chfhhdhx = chfhhdhx[_n-1] if exam == 3
bysort hhp (exam): replace chfhhdhx = 1              if exam == 3 &                 (chf_dx == 1 | hhd_dx == 1)
bysort hhp (exam): replace chfhhdhx = .              if exam == 3 & chfhhdhx != 1 & (chf_dx == . | hhd_dx == .)

* here the inc is missing for exam 3 if already at exam 2
gen     incqtadj75 = qtadj75 if exam==2
replace incqtadj75= qtadj75 if exam==3 & qtadj75_2==0

* Calculate cumulatively updated incident long QTadj, which is defined at Exam 2 and then updated at Exam 3
* INCQTADJ75_EVER is the binary cumulatively updated incident long QTadj variable
gen     incqtadj75_ever = qtadj75_2 if exam>1
replace incqtadj75_ever = 1 if qtadj75_3==1 & exam>2

clonevar incqt=incqtadj75_ever
save ekg_for_mi$tdate, replace

