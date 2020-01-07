capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

use ekg_for_mi170608, clear
unique hhp //8006
unique hhp if exam==4 // 3734
. tab qtadj75_1 if exam==1, mi
keep if qtadj75_1==0 // prevalent qt
unique hhp // 5592
di 8006-5592
unique hhp if exam==4 // 2743
forvalues i=1/7 {
	bys hhp (exam):drop if exam~=exam[_n-1]+1 & exam>1
	}
unique hhp // 5592
unique hhp if exam==4 // 2624
*notes: dropped exams after first missed visit, per MP
drop if exam==1 // no data to use
di 5592-5275
unique hhp // 5275
unique hhp if exam==4 // 2624
* drop if missing qt at exam 2
drop if qtadj75_2==.
********* drop if missing exam 3 and exam 2 was zero
drop if qtadj75_3==. & qtadj75_2==0
drop if inlist(hhp,1475,7371) // no exam 4 (not in chart)
unique hhp // 4737 
di 5275-4737
unique hhp if exam==4 // 2529
di 4737-2529
unique hhp // 4737
unique hhp if exam==4 // 2527
drop if casi_irt==. & exam>=4
unique hhp // 4737
unique hhp if exam==4 // 2511
di 2529-2511

tab exam
*notes: includes only those with qtadj75_1~=0. Also drops if qtadj75_3==. ///
	& qtadj75_2==0 (don't know status), or if qt_adj75_2==.
*notes: dropped 1475, 7371 since no exam 4

*notes: dropped if casi missing (and exam>=4)


