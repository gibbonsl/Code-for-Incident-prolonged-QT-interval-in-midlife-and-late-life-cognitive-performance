capture cd "G:\Laura\FH2016\HAAS"
capture cd "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS"

global tdate "170608"
global d `c(pwd)'
run "$d\EKG paper\do and sas files\ekg data $tdate.do"
	// makes the full dataset, ekg_for_mi$tdate
	
**** MI exams 4-7 **** 	
run "$d\EKG paper\do and sas files\start mi 170628.do" 
	// sets up mi for exams 4-7. makes mi$tdate
run "$d\EKG paper\do and sas files\mi impute all reg 170628.do" 
	// imputes (currently 5 imputations). makds mi_r$tdate
run "$d\EKG paper\do and sas files\mi reshape all reg 170608.do" 
	// reshapes, end up with mi_rlong$tdate
	
**** MI exams 1-3 ****
run "$d\EKG paper\do and sas files\start 1-4 mi 170619.do" 
	// sets up mi for exams 1-3. makes mi1_3_$tdate.
run "$d\EKG paper\do and sas files\mi impute 1-4 all reg 170608.do" 
	// imputes (currently 5). makes mi1_3_r$tdate.
run "$d\EKG paper\do and sas files\mi reshape1-4 reg 170608.do" 
	// reshapes, end up with mi1_3_rlong$tdate
	
* now take out after first missing, create nodrop nodie, etc
* currently has no one with qti~=0 at exam 1
* but still has imputed at exams 2 & 3 so c.
run "$d\EKG paper\do and sas files\after mi 170620.do" 
	// makes forwts$tdate; n=4737, final sample

**** make weights ****
run "$d\EKG paper\do and sas files\exposure weights 190416.do" 
	//exposure weights. makes exposurewts_$tdate 
run "$d\EKG paper\do and sas files\get prob 2-4 each imputation 190416.do"
	//  2->4 wts. weights24i_mi$tdate
run "$d\EKG paper\do and sas files\get prob each imputation 190416.do" 
	// 4->7 weights_i$tdate
run "$d\EKG paper\do and sas files\combine weights 170628.do" 
	// makes combined$tdate
	
**** structured so SAS can use MI ****
run "$d\EKG paper\do and sas files\for SAS 170628.do" 
	// makes forsas181204
tab exam _I, mi	
* the SAS file is "genmod with imputed data"	
 
 
	