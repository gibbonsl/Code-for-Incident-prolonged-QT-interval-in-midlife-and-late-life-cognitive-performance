* this was written 6/19 but I'm keeping it all the same date for now

use weights_i$tdate, clear
merge m:1 hhp using exposurewts_$tdate, keep(3) nogen 
merge m:1 hhp using weights24i_mi$tdate, keep(3 4 5) nogen update replace
drop *incqtadj75 // not defined here
drop *angina_dx_2 *qtadj75_1 // all zero

*bys exam:su swdn swdn24 weight_stab hhp
* pass weights thru exams 4 to 7
gen swtcomb=swdn*swdn24*weight_stab 
la var swtcomb "Stabilized wt for exposure, death & dropout pre and post exam 4"

gen unswtcomb=wdn*wdn24*weight_us
la var unswtcomb "Unstabilized wt for exposure, death & dropout pre and post exam 4"

forvalues i=1/5 {
	gen _`i'_swtcomb=_`i'_swdn*_`i'_swdn24*_`i'_weight_stab 
	gen _`i'_unswtcomb=_`i'_wdn*_`i'_wdn24*_`i'_weight_us
	}

su *swtcomb, de // a few outliers
	
la var weight_us "Unstabilized exposure wt"
la var weight_stab "Stabilized exposure wt"

save combined$tdate, replace	
