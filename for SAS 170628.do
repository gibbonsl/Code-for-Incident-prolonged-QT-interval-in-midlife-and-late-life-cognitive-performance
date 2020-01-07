use combined170608, clear
bys hhp (exam):gen last=exam[_N]

order _1* _2* _3* _4* _5*, after(swtcomb) 
order ikn age* casi educ* cdr height* occup_1 qtadj75_2 hyp_dx_2 ///
		months-nodrop, after(exam) // so I can think
drop _mi_miss
drop _*educ_exam1 _*qtadj75_2 _*casi* _*hyp_dx_2 ///
	_*occup* // complete here
gen _Imputation_=0
* I think this will be easier than a reshape

forvalues i=1/5 {
	tempfile t`i'
	preserve 
	replace _Imputation_=`i'
	keep hhp-nodrop _Imputation_ _`i'* last
	drop height_2 
	rename _`i'_* *
	save `t`i''
	restore
	}
keep hhp-swtcomb unswtcomb _Imputation_ last
append using `t1'
append using `t2'
append using `t3'
append using `t4'
append using `t5'

recode swtcomb (.01/.5417439=.5417439) (1.764579/max=1.764579), gen(tswtcomb)
la var tswtcomb "swtcomb, > top and < bottom 1% recoded to 1%"

saveold forsas181204, version(12) replace
