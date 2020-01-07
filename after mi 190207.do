
use ekg_for_mi$tdate, clear

********* we don't care about anyone without qtadj75=0 at exam 1, they don't exist
drop if qtadj75_1~=0
* drop if missing qt at exam 2
drop if qtadj75_2==.
********* drop if missing exam 3 and exam 2 was zero
drop if qtadj75_3==. & qtadj75_2==0
notes: includes only those with qtadj75_1~=0. Also drops if qtadj75_3==. ///
	& qtadj75_2==0 (don't know status), or if qt_adj75_2==.

drop if inlist(hhp,1475,7371) 
notes: dropped 1475, 7371 since no exam 4

drop if casi_irt==. & exam>=4
notes: dropped if casi missing (and exam>=4)
* drop exams after first missed visit, per MP
qui forvalues i=1/7 {
	bys hhp (exam):drop if exam~=exam[_n-1]+1 & exam>1
	}
notes: dropped exams after first missed visit, per MP

**** now died before maximum observed gap between exams. 
**** Also nodie and nodrop missing at exam 7
gen nodie=1 if exam<7
replace nodie=0 if exam==lastexam & lastexam==6 & deathdt< examdatel+1001 
replace nodie=0 if exam==lastexam & lastexam==5 & deathdt< examdatel+1643
replace nodie=0 if exam==lastexam & lastexam==4 & deathdt< examdatel+1569
replace nodie=0 if exam==lastexam & lastexam==3 & deathdt< examdatel+7974
replace nodie=0 if exam==lastexam & lastexam==2 & deathdt< examdatel+2622
replace nodie=0 if exam==lastexam & lastexam==1 & deathdt< examdatel+1756

*list hhp exam nodie examdate deathdt in 1/50, sepby(hhp)

* only do dropout models if eligble to drop out because not dead
* up to the visit before they die.

* updated 6/20/17 to reflect addl "dropouts"
bys hhp (exam):gen last2=exam[_N]

gen nodrop=1 if nodie==1 & exam<7
replace nodrop=0 if exam==last2  & nodie==1 & exam<7

keep hhp exam nodrop nodie ikn months monthssq ///
	age_2 height_2 stroke_hx_2 age_4 incqt*
tempfile x
save `x'
* have to start w mi
use mi_rlong$tdate, clear
mi append using mi1_3_rlong$tdate

mi merge 1:1 hhp exam using `x', keep(3)
unique hhp // 4737
unique hhp if exam>=4 //2511
save forwts$tdate, replace
