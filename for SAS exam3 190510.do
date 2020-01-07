use exposurewts_170608, clear

gen _Imputation_=0
* I think this will be easier than a reshape

forvalues i=1/5 {
	tempfile t`i'
	preserve 
	drop weight_us weight_stab eun3 eun2 es3 es2
	replace _Imputation_=`i'
	rename _`i'_* *
	save `t`i''
	restore
	}
append using `t1'
append using `t2'
append using `t3'
append using `t4'
append using `t5'

keep hhp _Imputation_ weight_us weight_stab eun3 eun2 es3 es2

saveold forsasexam3, version(12) replace



use weights24i_mi$tdate, clear
gen _Imputation_=0
* I think this will be easier than a reshape

forvalues i=1/5 {
	tempfile t`i'
	preserve 
	keep _`i'_wdun34 _`i'_wds34 _`i'_wcun34 _`i'_wcs34 _Imputation_ hhp ///
		_`i'_wdun23 _`i'_wds23 _`i'_wcun23 _`i'_wcs23
	replace _Imputation_=`i'
	rename _`i'_* *
	save `t`i''
	restore
	}
append using `t1'
append using `t2'
append using `t3'
append using `t4'
append using `t5'

keep hhp _Imputation_ wdun34 wds34 wcun34 wcs34 wdun23 wds23 wcun23 wcs23

saveold forsasexam3dd, version(12) replace
