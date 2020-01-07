*capture cd "C:\Users\Laura\Documents\HAAS"
capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

use temp, clear
keep if exam>=4 & qtadj75_2<. & qtadj75_3<. & casi_irt<.
gen qti=qtadj75_2
replace qti=2 if qtadj75_3==1
replace qti=3 if qtadj75_2==1 & qtadj75_3==1
la def qti 1 "Exam 2 only" 2 "Exam 3 only" 3 "Both"
la val qti qti

notes:keep if exam>=4 & qtadj75_2<. & qtadj75_3<. & casi_irt<.
notes _dta

*unweighted modeling 
de casi_irt qtadj75_2 qtadj75_3 everqtadj75 yrs age_2 ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1

mixed casi_irt qtadj75_2#qtadj75_3##c.yrs age_2 i.ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1 || hhp:exam, mle cov(un)
	
mixed casi_irt qtadj75_2or3##c.yrs age_2 i.ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1 || hhp:exam, mle cov(un)
	
mixed casi_irt qtadj75_2##c.yrs age_2 i.ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1 || hhp:exam, mle cov(un)

mixed casi_irt qtadj75_3##c.yrs age_2 i.ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1 || hhp:exam, mle cov(un)
	
mixed casi_irt i.qti##c.yrs age_2 i.ikn height_2 educ any_apoe4 ///
	stroke_hx_2 pai_1 || hhp:exam, mle cov(un)
