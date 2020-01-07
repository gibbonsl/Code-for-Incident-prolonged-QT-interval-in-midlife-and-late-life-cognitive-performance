capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

use mi1_3_r$tdate, clear

unab stuff:  diabetes_rx1-age1
local stuff "`stuff' " 
local stubs : subinstr local stuff "1 " " ", all 
di "`stubs'"

***** need to fake this out, these really aren't imputed *****
mi unregister diabetes_rx1 sbp1 dbp1 hyp_dx_1 
mi register imputed diabetes_rx1 sbp1 dbp1 hyp_dx_1 

mi reshape long `stubs' , i(hhp) j(exam)
* need to take out non-real visits
drop if age==.

* still missingness but minor

* missing by design	- have to carry forward (or get really really complicated)

qui foreach x of varlist *diabetes_rx *cvd_rx *dyn_r *dyn_l *diabetes {
	bys hhp (exam):replace `x'=`x'[_n-1] if `x'==.
	}

* still missingness... but better with all reg
bys exam:su hhp _1*

save mi1_3_rlong$tdate, replace

