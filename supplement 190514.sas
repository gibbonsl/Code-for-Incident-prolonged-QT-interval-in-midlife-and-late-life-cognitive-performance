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
label weight_us  =  "exposure weight, unstab";
label weight_stab = "exposure weight, stabilized";
label unswtcomb    =" combined weight, unstabilized";
mult34=eun3*wdun34*wcun34;
mult34s=es3*wds34*wcs34;
if exam=7 then do;	wdun=1;wcun=1;wds=1;wcs=1;end;
mult=eun3*wdun*wcun;
mults=es3*wds*wcs;
run;

*proc contents;run;
* now take out the unimputed data;
data temp;set temp;
if _Imputation_=0 then delete;run;* unimputed data;

* mean weights via mi;
proc means data=temp noprint;where exam=4;var swtcomb;by _Imputation_;
      output out=outs mean=swtcomb stderr=stderr_swtcomb;
proc mianalyze data=outs edf=2510;modeleffects swtcomb;stderr stderr_swtcomb;run;

** 190325 component weights;
* mean weights via mi;
proc means data=temp noprint;where exam=4;
	var es3 eun3 wds34 wdun34 wcs34 wcun34 mult34s mult34;by _Imputation_;
      output out=outs mean=es3 eun3 wds34 wdun34 wcs34 wcun34 mult34s mult34
	stderr=ses3 seun3 swds34 swdun34 swcs34 swcun34 smult34s smult34;
proc mianalyze data=outs edf=2510;
	modeleffects es3 eun3 wds34 wdun34 wcs34 wcun34 mult34s mult34;
	stderr ses3 seun3 swds34 swdun34 swcs34 swcun34 smult34s smult34;run;

proc means data=temp noprint;where exam=5;
	var es3 eun3   wds wdun wcs wcun mult mults;by _Imputation_;
      output out=outs mean=es3 eun3 wds wdun wcs wcun mult mults
	stderr=sses3 seun3  swds swdun swcs swcun smult  smults;
proc mianalyze data=outs edf=1876;
	modeleffects es3 eun3   wds wdun wcs wcun mult mults;
	stderr sses3 seun3 swds swdun swcs swcun smult  smults;run;

proc means data=temp noprint;where exam=6;
	var es3 eun3  wds wdun wcs wcun mult mults;by _Imputation_;
      output out=outs mean=es3 eun3  wds wdun wcs wcun mult mults
	stderr=sses3 seun3 swds swdun swcs swcun smult  smults;
proc mianalyze data=outs edf=1396;
	modeleffects es3 eun3  wds wdun wcs wcun mult mults;
	stderr sses3 seun3 swds swdun swcs swcun smult  smults;run;

proc means data=temp noprint;where exam=7;
	var es3 eun3  wds wdun wcs wcun mult mults;by _Imputation_;
      output out=outs mean=es3 eun3  wds wdun wcs wcun mult mults
	stderr=sses3 seun3 swds swdun swcs swcun smult  smults;
proc mianalyze data=outs edf=1059;
	modeleffects es3 eun3  wds wdun wcs wcun mult mults;
	stderr sses3 seun3  swds swdun swcs swcun smult  smults;run;


*** earlier
* Can we get the summary stats (min, max, mean, sd) for the various 
weights overall and by visit and their final combination at V4? based on MI;

* to get labels;
proc means data=temp;var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb;run;

* exams 4-7;
proc means data=temp;
var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb  
	stderr=sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb ;run;
proc mianalyze data=outs edf=6844;
	modeleffects weight_us weight_stab wdn24 swdn24 ;
	stderr sweight_us sweight_stab swdn24 sswdn24 ;run;
proc mianalyze data=outs edf=6831;
	modeleffects wdn swdn unswtcomb swtcomb tswtcomb;
	stderr swdn sswdn sunswtcomb sswtcomb stswtcombb;run;

* just combined wts;
proc mianalyze data=outs edf=6831;
	modeleffects unswtcomb swtcomb tswtcomb;
	stderr sunswtcomb sswtcomb stswtcombb;run;

* just final for exam 4;
proc means data=temp;where exam=4;var weight_us weight_stab  ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab stderr=sweight_us sweight_stab  ;run;
proc mianalyze data=outs edf=2510;* all 2511;
	modeleffects weight_us weight_stab;stderr sweight_us sweight_stab;run;



* by exam;
proc means data=temp;where exam=4;
var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb  
	stderr=sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb ;run;
proc mianalyze data=outs edf=2510;* all 2511;
	modeleffects weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb;
	stderr sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb;run;

proc means data=temp;where exam=5;
var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb  
	stderr=sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb ;run;
proc mianalyze data=outs edf=1876;
	modeleffects weight_us weight_stab wdn24 swdn24 ;
	stderr sweight_us sweight_stab swdn24 sswdn24 ;run;
proc mianalyze data=outs edf=1865;
	modeleffects wdn swdn unswtcomb swtcomb tswtcomb;
	stderr swdn sswdn sunswtcomb sswtcomb stswtcombb;run;

proc means data=temp;where exam=6;
var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb  
	stderr=sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb ;run;
proc mianalyze data=outs edf=1396;
	modeleffects weight_us weight_stab wdn24 swdn24 ;
	stderr sweight_us sweight_stab swdn24 sswdn24 ;run;
proc mianalyze data=outs edf=1394;
	modeleffects wdn swdn unswtcomb swtcomb tswtcomb;
	stderr swdn sswdn sunswtcomb sswtcomb stswtcombb;run;

proc means data=temp;where exam=7;
var weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb ;
by _Imputation_;      output out=outs 
	mean=weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb  
	stderr=sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb ;run;
proc mianalyze data=outs edf=1059;* all;
	modeleffects weight_us weight_stab wdn24 swdn24 wdn swdn unswtcomb swtcomb tswtcomb;
	stderr sweight_us sweight_stab swdn24 sswdn24 swdn sswdn sunswtcomb sswtcomb stswtcombb;run;


* 190221 death and dropout=censor separately;
proc means data=temp;var wnd swnd wnc swnc ;
	by _Imputation_;output out=outs mean=wnd swnd wnc swnc stderr=swnd sswnd swnc sswnc;run;
proc mianalyze data=outs edf=6831;
	modeleffects wnd swnd wnc swnc;stderr swnd sswnd swnc sswnc;run;
proc means data=temp;var wnd swnd wnc swnc ;where exam=4;
	by _Imputation_;output out=outs mean=wnd swnd wnc swnc stderr=swnd sswnd swnc sswnc;run;
proc mianalyze data=outs edf=2510;
	modeleffects wnd swnd wnc swnc;stderr swnd sswnd swnc sswnc;run;
proc means data=temp;var wnd swnd wnc swnc ;where exam=5;
	by _Imputation_;output out=outs mean=wnd swnd wnc swnc stderr=swnd sswnd swnc sswnc;run;
proc mianalyze data=outs edf=1876;
	modeleffects wnd swnd wnc swnc;stderr swnd sswnd swnc sswnc;run;
proc means data=temp;var wnd swnd wnc swnc ;where exam=6;
	by _Imputation_;output out=outs mean=wnd swnd wnc swnc stderr=swnd sswnd swnc sswnc;run;
proc mianalyze data=outs edf=1394;
	modeleffects wnd swnd wnc swnc;stderr swnd sswnd swnc sswnc;run;
proc means data=temp;var wnd swnd wnc swnc ;where exam=7;
	by _Imputation_;output out=outs mean=wnd swnd wnc swnc stderr=swnd sswnd swnc sswnc;run;
proc mianalyze data=outs edf=1059;
	modeleffects wnd swnd wnc swnc;stderr swnd sswnd swnc sswnc;run;

** incl 2-4;
proc means data=temp;var dwt  cwt  ;where exam=4;
	by _Imputation_;output out=outs mean=dwt  cwt  stderr= sdwt  scwt ;run;
proc mianalyze data=outs edf=2510;
	modeleffects dwt  cwt ;stderr sdwt  scwt ;run;
proc means data=temp;var dwt  cwt  ;where exam=5;
	by _Imputation_;output out=outs mean=dwt  cwt  stderr=sdwt  scwt ;run;
proc mianalyze data=outs edf=1876;
	modeleffects dwt  cwt ;stderr  sdwt  scwt;run;
proc means data=temp;var dwt  cwt  ;where exam=6;
	by _Imputation_;output out=outs mean=dwt  cwt  stderr= sdwt  scwt;run;
proc mianalyze data=outs edf=1394;
	modeleffects dwt  cwt ;stderr sdwt  scwt ;run;
proc means data=temp;var dwt  cwt  ;where exam=7;
	by _Imputation_;output out=outs mean=dwt  cwt  stderr= sdwt  scwt;run;
proc mianalyze data=outs edf=1059;
	modeleffects dwt  cwt ;stderr sdwt  scwt ;run;


********** THIS DIDN'T WORK. JUST LOOKED AT AUC FOR THE 5 MODELS IN Stata ***********;

/* Can we get the c-stats for the models Again, these will have to be based on the post-MI summary stats.;


* have to do this on the visit 2-3 data;

proc means data=temp;var months monthssq age_2 ikni iknk alcohol_1 pai_1   
      chfhhdhx bmi sbp dbp  hyp_treat  diabetes_rx occup_1  height_2 hyp_dx_2  chest_1;run;

*incqtadj75 cvd_rx_prior;

exposurewts_$tdate
hhp *weight_stab *weight_us

* exposure, denom;

proc logistic data=temp; 
	model incqtadj75 = months monthssq age_2 ikni iknk alcohol_1 pai_1   
      chfhhdhx bmi sbp dbp  hyp_treat cvd_rx_prior diabetes_rx occup_1  height_2 hyp_dx_2  chest_1;
    by _Imputation_;
    roc;ods output ROCAssociation=roc;run;
               
proc mianalyze ROCAssociation=roc;
   title "exposure, denom";
run;title;

** sham example to work this out;
proc logistic data=temp; 
	model ikni = months monthssq age_2  alcohol_1 pai_1  chest_1;
    by _Imputation_;
    roc;ods output ROCAssociation=roc;run;
          
proc print data=roc;run; 

/* Fisher gives 0.73 so this can't be right;
data roc;set roc;
ZVal=0.5*log((1+Area)/(1-Area));
StdZ=1/sqrt(6833-3); *update that 6833 as needed;
proc print;run;

proc mianalyze data=roc;
	ods output ParameterEstimates=parms;
	modeleffects ZVal;
	stderr StdZ;
	title "exposure, denom";run;title;
proc print data=parms;
data area;set parms;r=tanh(Estimate);proc print;run;
  
* this gives 0.68, even worse;
proc mianalyze data=roc;
	ods output ParameterEstimates=parms;
	modeleffects Area;
	stderr StdErr;
	title "exposure, denom";run;title;
