capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

use mi_r$tdate, clear

unab stuff:  liveff4 -cdrsum4
local stuff "`stuff' " 
local stubs : subinstr local stuff "4 " " ", all 
*mac li 

***** need to fake this out, these really aren't imputed  *****
mi unregister liveff7 casi_irt7 smoke_now5 smoke_now6
mi register imputed liveff7 casi_irt7 smoke_now5 smoke_now6


mi reshape long `stubs' , i(hhp) j(exam)
* need to take out non-real visits
drop if age==.

* still missingness...
*bys exam:su hhp _1_liveff-_1_theta

* missing by design	- have to carry forward (or get really really complicated)
qui foreach x of varlist *married *cesd *gnhlth *pai *ex_reg ///
	*thetad10 *dyn_r *dyn_l *smoke_now *sbp *dbp *mi_hx {
	bys hhp (exam):replace `x'=`x'[_n-1] if `x'==.
	}

* still missingness... but better with all reg
bys exam:su hhp _1_liveff-_1_theta
save mi_rlong$tdate, replace


