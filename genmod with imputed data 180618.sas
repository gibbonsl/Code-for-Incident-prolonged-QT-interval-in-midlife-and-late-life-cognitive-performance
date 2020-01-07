*libname fun "C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS";
libname fun "G:\Laura\FH2016\HAAS";

*proc import out=temp datafile="C:\Users\Laura Gibbons\Documents\Laura\FH2016\HAAS\forsas181204.dta" replace;
proc import out=temp datafile="G:\Laura\FH2016\HAAS\forsas181204.dta" replace;

*proc contents;run;
data temp;set temp;
yrs=months/12;
incqt_yrs=incqt*yrs; *interaction term was causing trouble in mianalyze;
* covariance matrix and parameter matrix are not matching for ikn;
if ikn=1 then ikni=1;else ikni=0;
if ikn=2 then iknk=1;else iknk=0;
* center some variables;
agec=age_2-55;
agec75=age_2-75;
paic=pai_1-33;
htc=height_2*2.54 - 164;
chestc=chest_1-19;
*	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4;
* reference person is 55 at exam 2, Nisei, pai 33, primary education or less, 
no hypertension dx at exam 2, no alcohol, 164 cm tall at exam 2, 19 cm chest depth, 
Clerical, sales, professional or managerial job, no APOE-4 alleles;
run;
* raw model, no MI;** model 5;
title "unweighted, no MI, same covariates, model 5";
proc genmod data=temp ;
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4;
    repeated subject=hhp / type=ind; 
	where _Imputation_=0;*********************;run;

* now take out the unimputed data;
data temp;set temp;
if _Imputation_=0 then delete;run;* unimputed data;

* mean weights via mi;
proc means data=temp noprint;where exam=4;var swtcomb;by _Imputation_;
      output out=outs mean=swtcomb stderr=stderr_swtcomb;
proc mianalyze data=outs edf=2510;modeleffects swtcomb;stderr stderr_swtcomb;run;

* unweighted mi model;* model 4;
* still used all the numerator vars;
proc genmod data=temp ;
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4/covb;
    repeated subject=hhp / type=ind; 
    by _Imputation_;
    ods output GEEEmpPEst=gmparms
               ParmInfo=gmpinfo
               CovB=gmcovb;run;
proc mianalyze parms=gmparms parminfo=gmpinfo covb=gmcovb;
   modeleffects Intercept incqt yrs incqt_yrs;
   title "Unweighted, MI, model 4";
run;title;

* Weighted model MI;
* must include all numerator variables from all the weight models;
proc genmod data=temp ;
   title "weighted model, MI, covariates";
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4/covb;
	weight swtcomb;
    repeated subject=hhp / type=ind; 
	by _Imputation_;
    ods output GEEEmpPEst=gmparms
               ParmInfo=gmpinfo
               CovB=gmcovb;
run;

*proc print data=gmparms;run;
*proc print data=gmpinfo;run;
*proc print data=gmparms;run;

*uses n=6756;
proc mianalyze parms=gmparms parminfo=gmpinfo covb=gmcovb;
   modeleffects Intercept incqt yrs incqt_yrs;
   title "weighted model, MI, covariates, model ";
run;title;

* model just using exposure weights;
* must include all numerator variables from all the weight models;
proc genmod data=temp ;
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4;
	weight weight_stab;
    repeated subject=hhp / type=ind; 
    by _Imputation_;
    ods output GEEEmpPEst=gmparms
               ParmInfo=gmpinfo
               CovB=gmcovb;
proc mianalyze parms=gmparms parminfo=gmpinfo covb=gmcovb;
   modeleffects Intercept incqt yrs incqt_yrs;
   title "Only exposure weights, MI, model 3";
run;title;


* recode top and bottom 1%, model 1;
proc genmod data=temp ;
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4;
	weight tswtcomb;
    repeated subject=hhp / type=ind; 
    by _Imputation_;
    ods output GEEEmpPEst=gmparms
               ParmInfo=gmpinfo
               CovB=gmcovb;
proc mianalyze parms=gmparms parminfo=gmpinfo covb=gmcovb;
   modeleffects Intercept incqt yrs incqt_yrs;
   title "full weights, but recoded top and bottom 1% weighted people. MI. Model 1";
run;title;

proc genmod data=temp ;
   title "Unstabilized MI?";
	class hhp;
	model casi_irt = incqt yrs incqt_yrs agec ikni iknk paic educ_exam1 
		hyp_dx_2 alcohol_1 htc chestc occup_1 any_apoe4;
	weight unswtcomb;
    repeated subject=hhp / type=ind; 
	by _Imputation_;
    ods output GEEEmpPEst=gmparms
               ParmInfo=gmpinfo
               CovB=gmcovb;
run;
proc mianalyze parms=gmparms parminfo=gmpinfo covb=gmcovb;
   modeleffects Intercept incqt yrs incqt_yrs;
   title "Unstabilized MI";
run;title;

*proc contents;run;
