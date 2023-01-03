/*
 * @author :  Yaseen Alli
 * *SID    :  ALLMOH024
 * @email  :  ALLMOH024@myuct.ac.za
 * @Title  :  Research long paper
 * @Course :  ECO4021W
 * @Date   :  19 October 2022
 * @College: University of Cape Town
 
 DATA       : The NIDS-CRAM WAVE 1 and WAVE 2
 
 TOPIC      : Assessing the effect of the Child Support Grant in reducing child hunger 
               [see, Bhorat & Kohler (2020)]
			   
This Do file is structured as follows. Section 0 performs Wave Merges and Reshape;
Section 1 performs Data Cleaning; Section 2 computes Descriptive Statistics and Graphing;
Section 3 conducts Regression analysis
*/
***  clear the screen
cls
*** Clear the current workspace of all variable Data
clear all
***Force any open logfiles to close or absorb output stream error interrupt & proceed
cap log close
***set working directory
cd "D:\YaseenAssign1"
*** Log the commands and outputs
log using Assign1logfileYaseen, replace text 

*-----------------------------------------------------------------------------------------------------------
*                 SECTION 0: WAVE MERGE AND RESHAPE 
*-----------------------------------------------------------------------------------------------------------
*********************************************************************************************
* START: WAVE MERGE AND RESHAPE 
*********************************************************************************************
/*
 * MERGE THE FILES
 NIDS-CRAM has 3 files per wave
	
	- Link file
	- derived file
	- individual anon file
	
	This Section creates a wide data set with all people in the study
	and all of their wave 1 and wave 2 data
	
*/

***** WAVE 1
*** Check that all relevant files can be opened OR exist in the directory
use "Link_File_NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear
use "derived_NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear
use "NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear

***** WAVE 2
*** Check that all relevant files can be opened OR exist in the directory
use "Link_File_NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear
use "derived_NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear
use "NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear

*-------------------------------------------------------------------------------
    * Since they are available I can do the following:
	* Investigate each file in each wave
	* how many observations - count
	* which variables are there and what are their descriptions/means - su, des
	* what does the data look like - br - short for browse
	* how many people are in the dataset - is the pid variable a unique identifier - codebook

*-------------------------------------------------------------------------------
* WAVE 1
* Link

use "Link_File_NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear
count
su
des
*** pid- Person identifier (Unique)
*** nids_sample -From which NIDS sample did this respondent originate?
*** cluster - NIDS Original wave 1 sample cluster
*** stratum-   NIDS Original wave 1 stratum
*** nids_w5_ind_outcome-NIDS Wave 5 individual outcome
*** w1_nc_outcome-Wave 1 NIDS-CRAM outcome
tab nids_w5_ind_outcome
tab w1_nc_outcome
sort pid
browse 
codebook pid

* WAVE 1
* derived

use "derived_NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear
count
su
des
br
codebook pid

* WAVE 1
* Anon

use "NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear
count
su
des
***w1_nc_incchld --da2 - Does anyone in the household receive a child support grant?
tab w1_nc_incchld
br
codebook pid

*-------------------------------------------------------------------------------
* WAVE 2
* Link

use "Link_File_NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear
count
su
des
*** pid- Person identifier (Unique)
*** nids_sample -From which NIDS sample did this respondent originate?
*** cluster - NIDS Original wave 1 sample cluster
*** stratum-   NIDS Original wave 1 stratum
*** nids_w5_ind_outcome-NIDS Wave 5 individual outcome
*** w2_nc_outcome-Wave 2 NIDS-CRAM outcome
tab nids_w5_ind_outcome
tab w2_nc_outcome  //80.25%
sort pid
browse 
codebook pid

* WAVE 2
* derived

use "derived_NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear
count
su
des
br
codebook pid

* WAVE 2
* anon

use "NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear
count
su
des
***w2_nc_incchld --da2 - Does anyone in the household receive a child support grant?
tab w2_nc_incchld
br
codebook pid

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

  *MERGE the WAVE 1 files
  *Create the "Data" folder in current working directory 
	
*-------------------------------------------------------------------------------

* Merging together files for cross-section - Wave 1, Wave 2

* start with anon file, link in derived variable data

* I want the variables from both files in the same file

* Start with wave 1

use "NIDS-CRAM_Wave1_Anon_V3.0.0.dta", clear

count 

codebook pid
sort pid
merge 1:1 pid using "derived_NIDS-CRAM_Wave1_Anon_V3.0.0.dta"

count

* everyone matches
tab _merge

codebook pid

* drop the _merge variable because it will be created later again, every time I merge
drop _merge
*Save on the data folder in current working directory
save "./data/Wave1.dta", replace

*-------------------------------------------------------------------------------
* Merge together Wave 2 files

* start with anon file, link in derived variable data

* I want the variables from both files in the same file

use "NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear

count
codebook pid
sort pid
*merge with one to one mapping 
merge 1:1 pid using "derived_NIDS-CRAM_Wave2_Anon_V3.0.0.dta"
// 1,375 not matched
count
* everyone matches
tab _merge
codebook pid

* drop the _merge variable because it will be created later again, every time I merge
drop _merge
*save in data folder
save "./data/Wave2.dta", replace

*-------------------------------------------------------------------------------

**REMARK: Wave1.dta and Wave2.dta can be found in the data forlder

*-------------------------------------------------------------------------------
* Create one file, with all variables - wave 1 and wave 2. Start with link file

* Link file in wave 2 - has all people in study

* link everyone's data from both wave 1 and wave 2 into one file

use "Link_File_NIDS-CRAM_Wave2_Anon_V3.0.0.dta", clear

count
codebook pid
sort pid
* merge in wave 1 data - creates wide dataset with all wave 1 variables
merge 1:1 pid using  "./data/Wave1.dta"

* everyone matches
tab _merge
count
codebook pid
* drop the _merge variable because it will be created later again, every time I merge
drop _merge

sort pid
* then merge in wave 2 data set - data set becomes even wider with all wave 2 variables as well
merge 1:1 pid using  "./data/Wave2.dta", 


* 22 from this data set didn't match when we merged in the Wave 2 data
* that's ok - clearly people from Wave 1 who we didn't find in wave 2. Check
tab _merge
tab w2_nc_outcome, m

* all of the people who didn't match - _merge == 1 - didn't because of the reasons below

tab w2_nc_outcome if _merge == 1, m

count
codebook pid
br

* drop the _merge variable because it will be created later again, every time I merge
drop _merge
*** Save the Combined Wave 1 and Wave 2 data in Wide format
save "./data/WideDataW1W2.dta", replace

* This is my wide data
* RESHAPE FROM WIDE TO LONG
* right now there is one observation per person
* when you reshape, there will be 2 observations per person

* FOR NOW - you can begin to clean, and think about your descriptive stats and figures

*-------------------------------------------------------------------------------

/*
	Reshape Procedure
	Variables:
	DEPENDENT VARIABLE: Hunger denotes the binary dummy equal to 1 if child went hungry the night before and 0 otherwise
	     *w*_nc_fdcyn- In last 7 days, any kids (<18) in your HH gone hungry due to lack of food?
		 *w*_nc_fdcskp- db2 - In last 7 days, how often did children go hungry? 
	INDEPENDENT VARIABLES (POTENTIAL):
	(1)  CSG denotes whether or not a child is a child support grant beneficiary: 
			*w1_nc_hhincchld:  da1 - How many child support grants does this household receive?
			*w1_nc_incchld:    da2 - Does anyone in the household receive a child support grant?
    (2)  age (w*_nc_best_age_yrs)
	(3)  Gender (w*_nc_best_gen)
	(4)  education (w*_nc_edschgrd)
	(5)  mother's education 
	(6)  Race (w*_nc_best_race)
	(7)  Employment (w*_nc_emreturn)
	(8)  Health (w1_nc_hlser or w1_nc_hl4vis)
	(9)  Household income (w*_nc_hhinc)
	(10) Household size (w*_nc_nopres & w*_nc_nopres_conf)
	 (11) Number of adults who can work-18-60: w*_nc_nocld 
	 (12) Number of biological or legally adopted children younger than 18- w2_nc_chldn
	  (13) Geographic location (w*_nc_geo2011)
	  (14) Province (w*_nc_prov2011)
	  
	  Auxilliary:
	  i) Weights:            w1_nc_wgt  and w2_nc_pweight 
      ii) Interview Outcome: w*_nc_outcome
*/

*-------------------------------------------------------------------------------

use  "./data/WideDataW1W2.dta", clear


su pid w1_nc_outcome w2_nc_outcome w1_nc_best_age_yrs w2_nc_best_age_yrs ///
w1_nc_best_gen  w2_nc_best_gen w1_nc_best_race w2_nc_best_race ///
w1_nc_emreturn w2_nc_emreturn

* if I don't do this, then things might be a mess - I'll have lots of extra variables which won't be reshaped
* it is optional though - you don't have to do this keep statement

/*keep pid w1_nc_outcome w2_nc_outcome w1_nc_best_age_yrs w2_nc_best_age_yrs ///
w1_nc_best_gen  w2_nc_best_gen w1_nc_best_race ///
w2_nc_best_race w1_nc_emreturn w2_nc_emreturn
*/

des
* 7073 people - observations

count
* 7073 unique pids
codebook pid

*-------------------------------------------------------------------------------

* put @ in where there is going to be a 1 or a 2
* pid is the identifier
* wave is the variable name I decided to use to identify people in each wave
* any other variables besides these ones will be left as is
* look at the reshape output to understand what has happened

reshape long w@_nc_fdcyn w@_nc_fdcskp ///
w@_nc_hhincchld w@_nc_incchld w@_nc_hhincchld_june w@_nc_incchld_june ///
w@_nc_outcome w@_nc_best_age_yrs w@_nc_best_gen w@_nc_best_race w@_nc_emreturn w@_nc_hhincchnged ///
w@_nc_hlser w@_nc_hl4vis w@_nc_chldn ///
w@_nc_hhinc w@_nc_nopres  w@_nc_nopres_conf w@_nc_edschgrd w@_nc_nocld ///
w@_nc_geo2011 w@_nc_prov2011 ///
w@_nc_incgov w@_nc_incgovpen w@_nc_incgov_june w@_nc_incgovpen_june w@_nc_incgovbhf_june ///
  w@_nc_wgt w@_nc_pweight w@_nc_pweight_s ///
  w@_nc_em_apr w@_nc_em_june w@_nc_emany_apr w@_nc_emany_june w@_nc_ems_apr w@_nc_ems_june w@_nc_emwnt ///
  w@_nc_unems w@_nc_unems_june w@_nc_em_feb ///
  w@_nc_no60res w@_nc_nou18res w@_nc_nou7res w@_nc_hhcsch w@_nc_ecdatt_mar ///
  w@_nc_eduatt_mar w@_nc_mar w@_nc_chldcr w@_nc_chldcr_v w@_nc_chldcar_lev5 ///
  w@_nc_eminc_ters w@_nc_unemincuifany_june w@_nc_emsteers_june ///
  w@_nc_incvgrt w@_nc_incgovtyp1 w@_nc_incgovtyp2 w@_nc_incgovtyp3 w@_nc_incgovtyp4 ///
  w@_nc_edter , i(pid) j(wave)

* optional step - the automatic labels on wave are annoying me

tab wave
label define wavelabel 1 "Wave 1" 2 "Wave 2"
label values wave wavelabel
tab wave

*-------------------------------------------------------------------------------------
*** WAVE 1 and WAVE 2 coded
tab wave, gen(wave)

*For ease of deriving employment status
replace w_nc_em_apr=w_nc_em_june if wave2==1
replace w_nc_em_june=w_nc_em_apr if wave1==1

replace w_nc_emany_apr=w_nc_emany_june if wave2==1
replace w_nc_emany_june=w_nc_emany_apr if wave1==1

replace w_nc_ems_apr=w_nc_ems_june if wave2==1
replace w_nc_ems_june=w_nc_ems_apr if wave1==1

replace w_nc_unems=w_nc_unems_june if wave2==1
replace w_nc_unems_june=w_nc_unems if wave1==1

*-------------------------------------------------------------------------------------

/*
 NB: Not that for a variable to have missing values for the whole wave
     implies that it was either not collected or had a different name in that wave
	 
	 For instance, wgt is weights in WAVE 1 and pweight is probability WEIGHTS in Wave 2
*/

*---------------------------------------------------------------------------------------
*LABELS to help track the variable origination & relevance
*---------------------------------------------------------------------------------------
* Interview Outcomes
label var w_nc_outcome "Outcomes of Interviews"
* Education
label var w_nc_edschgrd "Highest school grade completed"
* WAVE 2: Number of biological or legally adopted children
label var w_nc_chldn "W2 only-Number of biological or legally adopted children younger than 18"
* Household size
label var w_nc_nopres "Number of people resident, including yourself (don't forget babies)"
*--------------------------------------------------------------------------------
* CAUTION: This variable has different labels in Wave 1 and Wave 2 
* WAVE 1:  b14 - More/less/same number kids in house now compared to before the lockdown?
* WAVE 2:  bc5 - Number of household residents between the age of 18 and 60?
label var w_nc_nocld "Number of household residents between the age of 18 and 60"
*REMARK: Check for result robustness if selected in the final covariates
*---------------------------------------------------------------------------------
label var w_nc_nopres_conf "W2 only- Please confirm total number of residents"
* Employment status indicator 
label var w_nc_emreturn " Do you have any paid activity/job that you will return to in next 4 weeks?"
*---------------------------------------------------------------------------------------------------------
* CHILD SUPPORT GRANT proxies for WAVE 2
label var w_nc_hhincchld_june "W2 only- How many child support grants did this household receive in June?"
label var w_nc_incchld_june "W2 only -  Did anyone in this household receive a child support grants in June?"
*-------------------------------------------------------------------------------------------------------------------
* Government Grant receipt tracking: WAVE 2
label var w_nc_incgovpen_june "W2 only-  Did anyone in this household receive an old old age pension grant in June?"
label var w_nc_incgov_june "W2 only- Did you personally receive any kind of government grant in June?"
label var w_nc_incgovbhf_june "W2 only- Did you receive any government grant on behalf of someone else in June?"
*---------------------------------------------------------------------------------------------------------------------
***** Household income
* WAVE 2 
label var w_nc_hhincchnged "W2 only- In the past 4 weeks, has this main income source changed?"
* both waves (wave 1 and wave 2 coded similaerly)
label var w_nc_hhinc " How much was the total household income"
*-------------------------------------------------------------------------------------------------------------------------
*Indicators of child hunger:
label var w_nc_fdcyn "In last 7 days, any kids (<18) in your HH gone hungry due to lack of food?"
label var w_nc_fdcskp "In last 7 days, how often did children go hungry?"
*------------------------------------------------------------------------------------------------------------------
*Panel weights NIDS-CRAM w1 to NIDS-CRAM w2: Adjusted for attrition and trimmed: WAVE 2 (Only)
label var w_nc_pweight "pweights: Wave 2"
*------------------------------------------------------------------------------------------------------------------
*Weights scaled for pop representativity
label var w_nc_pweight_s  "pweights: scaled"
*------------------------------------------------------------------------------------------------------------------
*Age in Years
label var w_nc_best_age_yrs "Age"
*RACE or population group
label var w_nc_best_race "Race"
*Gender
label var w_nc_best_gen "Gender"
*Province (2011 Census)
label var w_nc_prov2011 "Province"
*---------------------------------------------------------------------------------------------------------------------
* Child Support Grant: WAVE 1
label var w_nc_hhincchld "Wave 1 only- How many child support grants does this household receive?"
label var w_nc_incchld "Wave 1 only-  Did anyone in this household receive a child support grants in June?"
*----------------------------------------------------------------------------------------------------------------------
* HEALTH: WAVE 1
label var w_nc_hlser "Wave 1 only- Any chronic conditions: HIV/TB/lung condition/heart condition/diabetes?"
label var w_nc_hl4vis "Wave 1 only-  Last 4 weeks, needed to see a health worker about a chronic condition?"
*----------------------------------------------------------------------------------------------------------------------
*GeoType (2011 Census)
label var w_nc_geo2011 "Geo location"
*-----------------------------------------------------------------------------------------------------------------------
* Government Grants: WAVE 1
label var w_nc_incgov "Wave 1 only-  Do you receive any kind of government grant?"
label var w_nc_incgovpen "Wave 1 only- Does anyone in the household receive an old age pension grant?"
*------------------------------------------------------------------------------------------------------------------------
* Design weights adjusted for non-response
label var w_nc_wgt "weights: Wave 1"
*pid: Person identifier
*---------------------------------------------------------------------------------------


*** KEEP the variables for the Assignment 1 Presentation
keep pid wave stratum cluster w_nc_outcome w_nc_edschgrd w_nc_chldn w_nc_nopres w_nc_nocld ///
w_nc_nopres_conf w_nc_emreturn w_nc_hhincchld_june w_nc_incchld_june ///
w_nc_incgovpen_june w_nc_incgov_june w_nc_incgovbhf_june w_nc_hhincchnged ///
 w_nc_hhinc w_nc_fdcyn w_nc_fdcskp w_nc_pweight w_nc_pweight_s w_nc_best_age_yrs ///
 w_nc_best_race w_nc_best_gen w_nc_prov2011 w_nc_hhincchld w_nc_incchld ///
 w_nc_hlser w_nc_hl4vis w_nc_geo201 w_nc_incgov w_nc_incgovpen w_nc_wgt ///
 w_nc_em_apr w_nc_emany_apr w_nc_ems_apr w_nc_emwnt w_nc_unems w_nc_em_feb ///
 w_nc_no60res w_nc_nou18res w_nc_nou7res w_nc_hhcsch w_nc_ecdatt_mar ///
 w_nc_eduatt_mar w_nc_mar w_nc_chldcr w_nc_chldcr_v w_nc_chldcar_lev5 ///
 w_nc_eminc_ters w_nc_unemincuifany_june w_nc_emsteers_june ///
 w_nc_incvgrt w_nc_incgovtyp1 w_nc_incgovtyp2 w_nc_incgovtyp3 w_nc_incgovtyp4 ///
 w_nc_edter

*Summarize
su
* 14146 - I now have double the records

count
* still 7073 unique pids

codebook pid
* optional step to make things tidier
* this strips off the w_nc_ part from the front of the variables which begin with that
rename w_nc_* *

*-------------------------------------------------------------------------------
* Create the Employment
* Controlling for non-response
foreach x in em_apr emany_apr ems_apr emwnt emreturn {
replace `x' = . if `x' <0
}

gen Employed=0
replace Employed=1 if (em_apr==1| emany_apr==1| ems_apr==1| ems_apr==2| emreturn==1)
replace Employed=. if em_apr==. & emany_apr==. & ems_apr==. & emwnt==. & emreturn==. 

* Not employed and not available or willing to be employed in the next 7 days
gen Not_economically_active= (Employed==0 & emwnt==2)

* Not employed, is available and willing (emwnt = 1 [Yes]), actively searched (unems = 2 [No])
gen Unemployed_discouraged= (Employed==0 & emwnt==1 & unems == 2)

* Not employed, is available and willing (emwnt = 1 [Yes]), actively searched (unems = 1 [Yes])
gen Unemployed_strict= (Employed==0 & emwnt==1 & unems == 1)

gen state=.
replace state=0 if Not_economically_active==1
replace state=1 if Unemployed_discouraged==1
replace state=2 if Unemployed_strict==1
replace state=3 if Employed==1
replace state=-8 if state == . & outcome == 1
replace state=. if outcome != 1

la def state 0"Not Economically Active" 1"Unemployed_Discouraged" 2"Unemployed_Strict" 3"Employed" -8"Refused"
la val state state

ren state state_fine_a

recode state_fine_a (0=0)(1/2 = 1)(3=2)(-8=-8), gen(state2)
la def state2 0"Not Economically Active" 1"Unemployed" 2"Employed" -8"Refused"
la val state2 state2

rename state2 state_coarse_a

ren state_coarse_a empl_stat_broad
ren state_fine_a   empl_stat_narrow

lab var empl_stat_broad "Employment status: April 2020 - Broad definition"
lab var empl_stat_narrow "Employment status: April 2020 - Narrow definition"

tab empl_stat_narrow empl_stat_broad

drop empl_stat_broad
rename empl_stat_narrow empl_stat

* Now replace those who said they "retired" in Feb to NEA in April
replace empl_stat=0 if em_feb==3            //this reduces # refusals & increases NEA.

lab var empl_stat "Employment status: "
recode empl_stat (-9/-1=.)
tab empl_stat
tab empl_stat wave
// ideally for wave 2 we would have to match the employ in April to those in June (ala Feb to April)
* End the Employment

*-------------------------------------------------------------------------------
*Pensioners 

//i.ROBUSTNESS CHECKS
// Note: Set zeroes to 1 rather than missing in cases where people answered 0 to hhsize even though the question specified 'including yourself'. 
// Number of pensioners (>60)

	gen hhsizeW = nopres
	replace hhsizeW=. if nopres==-8 | nopres==-9
	replace hhsizeW=1 if nopres==0
	gen npensionersW = no60res
	replace npensionersW =. if no60res==-9 | no60res==-8 | no60res==-3
	replace npensionersW = 0 if hhsizeW == 1 //**Replacing to 0 those who said there was only one person in their hh (incl. themselves) 
	replace npensionersW = 1 if hhsizeW == 1 & best_age_yrs>60 & best_age_yrs~=. //**Replacing to 1 those who said there was only one person in their hh (incl. themselves) and they are older than 60
	gen pensionersW = 0
	replace pensionersW =1 if npensionersW ~=0
	replace pensionersW =. if npensionersW ==.
    


//Number of pensioners excluding respondents

	gen npensexclW = npensionersW - 1 if best_age_yrs>=60 & best_age_yrs!=.
	replace npensexclW = 0 if npensexclW <0
	replace npensexclW = npensionersW if best_age_yrs<60
	label var npensexclW "number of pensioners excluding respondent"

*Number of kids under 18
gen nkids17W = nou18res
replace nkids17W = . if nou18res == -9 | nou18res == -8 | nou18res == -3
replace nkids17W = 0 if nkids17W == . & hhsizeW == 1 //**Replacing to 0 those who said there was only one person in their hh (incl. themselves) as it seems they might not have answered the question on kids
replace nkids17W = 0 if nkids17W == . & nocld == 4 //**Replacing to 0 those who said 'were no children, still no children' in later question 

* kids under 7 years
gen nkids6W = nou7res
replace nkids6W = . if nou7res==-9 | nou7res==-8 | nou7res==-3
replace nkids6W = 0 if nou18res==0 //**Replacing to 0 those who said no kids under 18 in B12 as they skipped this question
replace nkids6W = 0 if nkids6W==. & hhsizeW==1 //**Replacing to 0 those who said there was only one person in their hh (incl. themselves) as it seems they might not have answered the question on kids
replace nkids6W = 0 if nkids6W==. & nocld==4 //**Replacing to 0 those who said 'were no children, still no children' in later question

* /*Living with biological children*/
//not asked in W1

	gen biokidsW = 0
	replace biokidsW = 1 if chldn > 0 & chldn ~= .
	replace biokidsW = . if chldn == -8 | chldn == -9 | chldn == .
*------------------------------------------------------------------------------------------------
*--
*Number of adults 18-60
*ISSUE IN WAVE2 (see documentation)

//Whether living with kids who were enrolled and number enrolled. 
//There are some people reporting 'none' to the question who are recorded as 0 kids
//48 respondents in W1 reported no children under 18 in hhold, but report children attending school in March
//Similarly, 39 respondents in W2, and 1 respondent in W3*/


gen nschoolkidsW1 = hhcsch
replace nschoolkidsW1 = . if hhcsch == -9 | hhcsch == -8 | hhcsch == -3

	gen nschoolkidsW2 = eduatt_mar
	replace nschoolkidsW2  = . if  eduatt_mar < 0

gen necdkidsW2 = .
replace necdkidsW2 = 1 if ecdatt_mar == 1
replace necdkidsW2 = 0 if ecdatt_mar == 2

				
gen schoolkidsW1 = 0
replace schoolkidsW1 = 1 if nschoolkidsW1 ~= 0
replace schoolkidsW1 = . if nschoolkidsW1 == .

gen schoolkidsW2 = 0
replace schoolkidsW2 = 1 if nschoolkidsW2 ~= 0
replace schoolkidsW2 = . if nschoolkidsW2 == .

*number of school kids
gen nschoolkidsW=.
replace nschoolkidsW=nschoolkidsW1 if wave==1
replace nschoolkidsW=nschoolkidsW2 if wave==2
   *binary
       gen schoolkidsW=.
	   replace schoolkidsW=schoolkidsW1 if wave==1
       replace schoolkidsW=schoolkidsW2 if wave==2


//number of children of school-going age

	gen nkids7to17W = nkids17W - nkids6W
	
*------------------------------
* marital status for only wave 2
//marital status (not asked in WAVE 1)*/
gen marriedW2 = 0
replace marriedW2 = 1 if mar == 1
replace marriedW2 = . if mar <0 | mar == .

label define marriedW2 1 "Yes" 0 "No",replace
label val marriedW2 marriedW2
clonevar married =marriedW2

*----------------------------------------------------------------------------------
* Time Spent on Child Care

/*Variables for more time spent on childcare and number of EXTRA hours (WAVE 1) */
gen morechildcareW1 = chldcr == 1 if chldcr ~= . & chldcr ~= -9 & chldcr ~= -8 //** Note: those without children (i.e nou18res==0) coded as missing 
gen hrchildcareW1 = chldcr_v
replace hrchildcareW1 = . if chldcr_v == -9 | chldcr_v == -8
gen fourplushrs = hrchildcareW1 == 4 if hrchildcareW1 ~= . //** Note: those without children coded as missing
/*Combining the childcare variables into one*/
gen childcare = chldcr_v
replace childcare = . if chldcr_v == -8 | chldcr_v == -9
replace childcare = 0 if chldcr == 2 

/*Time spent on childcare during April level 5 lockdown (WAVE 2)
//Note: 24 respondents who are coded as having no children present in the home reported positive hours
//Note: 1034 respondents with children living in household reported 24 hours (around the clock) childcare
//825 (79.8%) of these reported having biological children, 792 (76.6%) report living with their biological children*/
/*Question piping did not ask about time spent in childcare of respondents whose children are not attending schools or whose children are in home school*/
gen hrchildcarel5 = chldcar_lev5 
replace hrchildcarel5 = . if chldcar_lev5 == -9 | chldcar_lev5 == -8

/*Pegging 17-24 hours at 16 hours  (WAVE 2)*/
gen hrchildcarel5_peg = chldcar_lev5 
replace hrchildcarel5_peg = . if chldcar_lev5 == -9 | chldcar_lev5 == -8
replace hrchildcarel5_peg = 16 if chldcar_lev5>16 & chldcar_lev5~=.

*------------------------------------------------------------------------------------------------------
* Household well being

/*Household wellbeing - hunger*/
gen hh_nfoodW = fdcyn
replace hh_nfoodW = 0 if fdcyn == 2
replace hh_nfoodW = 0 if fdcyn == -8 | fdcyn == -9 | fdcyn==-3 

gen hh_hngeverdayW = .
replace hh_hngeverdayW = 1 if fdcskp == 4 | fdcskp == 5
replace hh_hngeverdayW =0 if fdcskp > 0 & fdcskp < 4

*--------------------------------------------

*adding deflator

scalar base=115.2 						//Set scalar to base month, currently Feb 2020

cap drop deflator
gen  deflator=.	
replace deflator=base/115.6 	if wave==1	// April 2020
replace deflator=base/116.4     if wave==2 // July 2020
lab var deflator "NIDS-CRAM  deflator"

*------------------------------------------------------
*_nc_eminc_ters nc_unemincuifany_june
/* recipient of UIF/UIF-TERS amongst employed, self-employed and unemployed*/
gen uif_tersW = .
replace uif_tersW = 0 if eminc_ters == 2| eminc_ters == 3
replace uif_tersW = 1 if eminc_ters == 1
replace uif_tersW = 0 if emsteers_june >1 & emsteers_june!=.
replace uif_tersW = 1 if emsteers_june == 1
gen uif_W2 = .
replace uif_W2 = 0 if unemincuifany_june == 2
replace uif_W2 = 1 if unemincuifany_june == 1

*--------------------------------------------------------------------------------
* w2_nc_incvgrt w2_nc_incgovtyp1 w2_nc_incgovtyp2 w2_nc_incgovtyp3 w2_nc_incgovtyp4 
/* recipient of Covid SRDG (R350) */
gen covid_srdg_successW2 = .
replace covid_srdg_successW2 = 1 if incvgrt == 1
replace covid_srdg_successW2 = 0 if incvgrt == 2
replace covid_srdg_successW2 = 0 if incvgrt == 3

gen covid_srg_receiveW2 = .
replace covid_srg_receiveW2 = 1 if incgovtyp1 == 8|incgovtyp2 == 8|incgovtyp3 == 8|incgovtyp4 == 8
replace covid_srg_receiveW2 = 0 if incvgrt >1 & incvgrt<=3

*-------------------------------------------------------------------
* rural (Combining informal and farms)

	gen geotypeW = geo2011
	replace geotypeW =. if geo2011==-8 | geo2011==-3 | geo2011==-9
	gen urbanw = geotypeW==2 if geotypeW~=.
	gen ruralW=[geotypeW==1 | geotypeW==3] if geotypeW~=.

*------------------------------------------------------------------------------
*
// best education data now available for "Don't know" responses from earlier waves //
gen educ = edschgrd if edschgrd ~=-9 | edschgrd ~=-8 | edschgrd ~=-3| edschgrd ~= .
replace educ = . if educ ==-9 | educ ==-8 | educ ==-3

**Note: Post-matric is defined as those with a certificate/diploma/degree AND a matric 
gen educcat=0
replace educcat=. if educ ==. 
replace educcat=0 if educ==0 | educ==19
replace educcat = 1 if educ>=1 & educ<=7
replace educcat = 2 if (educ>=8 & educ<=11) | educ==13 | educ==14 | educ==16 | educ==17
replace educcat = 3 if educ==12 | educ==15 | educ==18
replace educcat = 4 if educcat == 3 & edter==1 	//Note that post-matric/tertiary here requires that individuals passed matric too
replace educcat = 4 if educcat == 3 & edter==1

label define educcat 0 "No schooling" 1 "Gr1-7" 2 "Gr8-11"  3 "Matric" 4 "Post-matric"
label values educcat educcat
tab educcat

gen matricorless = (educcat>=0 & educcat<=3) if educcat~=.
gen matricormore = (educcat>=3 & educcat<=4) if educcat~=.
gen postmatric = educcat==4 if educcat~=.

// Education: collapse no schooling into the same category as primary schooling
gen educcat2 = educcat
replace educcat2 = 1 if educcat2 == 0

// age categories
gen agecat = cond(best_age_yrs<25, 1, cond(best_age_yrs>=25 & best_age_yrs<35, 2, cond(best_age_yrs>=35 & best_age_yrs<45, 3, cond(best_age_yrs>=45 & best_age_yrs<55, 4, 5)))) if best_age_yrs!=.
label define agecat 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55plus"
label value agecat agecat

*-------------------------------------------------------------------------------------------------------------------------------
* Child hunger proxy 2 (turn missing to zero to minimize loss of data)
gen hh_chhungerW = fdcyn
replace hh_chhungerW = 0 if fdcyn == 2
replace hh_chhungerW = 0 if fdcyn == -8 | fdcyn == -9 | fdcyn == -3

*-----------------------
    gen kids17W = 0
	replace kids17W = 1 if nkids17W ~= 0
	replace kids17W = . if nkids17W == .
	
	gen kids6W = 0
	replace kids6W = 1 if nkids6W ~= 0
	replace kids6W = . if nkids6W == .

*-----------------------------------------------------------------------------------------------------------------------------
	label var hhsizeW  "The size of household"
	label var npensionersW "Number of Pensioners in HH"
	label var pensionersW "has Pensioner: 1 Yes 0 No"
	label var nkids17W   "Number of Kids less than 18 years"
    label var nkids6W   "Number of Kids less than 7 years"
	label var biokidsW "w2-only-Living with biological children"
	label var nkids7to17W "number of child of school going age"
	label var nschoolkidsW "number of school kids"
	label var schoolkidsW "has school kids"
	label var marriedW2 "w2-only Married or Not"
	label var agecat "Age categories"
	label var educcat "education categories"
	label var educcat2 "education categories (prim+nosch)"
	label var hh_chhungerW "Child hunger 2"
/*
  Variables for Robustness Checks:
  
  Summary:
  
  Continuous:
                 hhsizeW npensionersW  npensexclW nkids17W 	nkids6W nkids7to17W nschoolkidsW ///
				 hh_hngeverdayW hh_nfoodW deflator agecat educ educcat educcat2
				 
	WAVE 1: childcare  morechildcareW1 fourplushrs hrchildcareW1
	
	WAVE 2: hrchildcarel5 hrchildcarel5_peg  uif_tersW  uif_W2  covid_srdg_successW2 covid_srg_receiveW2
				 
  Binary:
			  pensionersW	biokidsW necdkidsW2 schoolkidsW  marriedW2  urbanw ruralW ///
			  matricorless matricormore postmatric married
*/
*-----------------------------------------------------------------------------------------------



*-------------------------------------------------------------------------------
* SUMMARIZE: check everything
su
* note the variable descriptions have gone - so check them before the reshape
des
*Sort panel
sort pid wave
br
*Save the Assign Data File
save  "./data/WideDataW1W2panel_small.dta", replace
* Save as my name
save  "./data/YaseenDataW1W2panel_Assign1.dta", replace

*-------------------------------------------------------------------------------

*********************************************************************************************
* END: WAVE MERGE AND RESHAPE 
*********************************************************************************************

/*
  SUMMARY
  A. WAVE 1 only variables: 
            1) hhincchld-How many child support grants does this household receive?
			2) incchld  -Did anyone in this household receive a child support grants in Jun
			3) hlser    -Any chronic conditions: HIV/TB/lung condition/heart condition/diabe
			4) hl4vis   - Last 4 weeks, needed to see a health worker about a chronic condition
			5) incgov   -Do you receive any kind of government grant?
			6) incgovpen - Does anyone in the household receive an old age pension grant?
			7) wgt       - Design weights adjusted for non-response
			
  B. WAVE 2 only variables: 
            1) chldn-Number of biological or legally adopted children younger than 18
			2) nopres_conf- Please confirm total number of residents
			3) hhincchld_june- How many child support grants did this household receive in June?
			4) incchld_june - Did anyone in this household receive a child support grants in June?
			5) incgovpen_june- Did anyone in this household receive an old old age pension grant in J
			6) incgov_june - Did you personally receive any kind of government grant in June?
			7) incgovbhf_june - Did you receive any government grant on behalf of someone else in June?
			8) hhincchnged  -  In the past 4 weeks, has this main income source changed?
			9) pweight -  Panel weights NIDS-CRAM w1 to NIDS-CRAM w2: Adjusted for attrition and trimmed:
			
			
  C. WAVE 1 and WAVE 2 variables: 
           pid wave outcome fdcyn fdcskp edschgrd  ///
		   best_age_yrs best_race best_gen prov2011 geo2011 ///
		   nopres nocld emreturn hhinc
		   
				
*/
*-----------------------------------------------------------------------------------------------------------
*                 SECTION 1: DATA CLEANING
*-----------------------------------------------------------------------------------------------------------
use  "./data/YaseenDataW1W2panel_Assign1.dta", clear
*********************************************************************************************
* START:   CLEAN
*********************************************************************************************
*------------------------------------------
***** Dependent Variable: Child Hunger Proxies
*** (i) In last 7 days, any kids (<18) in your HH gone hungry due to lack of food?
codebook fdcyn, tab(100)
recode fdcyn (-9 -8 -3=.) (1= 1 "Yes") (2=0 "No"), gen(Hungryless18)
tab fdcyn Hungryless18
*NB: I use Hungryless18

*** (ii) In last 7 days, how often did children go hungry? {Limited readings}
codebook fdcskp, tab(100)
clonevar Hungryfreq= fdcskp
replace  Hungryfreq=. if Hungryfreq==-9 | Hungryfreq==-8
codebook Hungryfreq, tab(100)

*------------------------------------------
***** INDEPENDENT VARIABLES
*** WAVE 1 and WAVE 2 coded
tab wave, gen(wave)
*Version 3 has matched weight coding

* 1. Education  (Must match the coding systems)
codebook edschgrd, tab(100)
/*
abulation:  Freq.   Numeric  Label
                            49        -9  Don't Know
                             6        -8  Refused
                           206         0  Grade R/0
                            72         1  Grade 1 (previously Sub A/ class
                                          1)
                           135         2  Grade 2 (previously Sub B/ class
                                          2)
                           151         3  Grade 3 (Std. 1)
                           229         4  Grade 4 (Std. 2)
                           283         5  Grade 5 (Std. 3)
                           323         6  Grade 6 (Std. 4)
                           603         7  Grade 7 (Std. 5)
                           603         8  Grade 8 (Std. 6/ Form 1)
                           691         9  Grade 9 (Std. 7/ Form 2)
                         1,265        10  Grade 10 (Std. 8/ Form 3)
                         2,095        11  Grade 11 (Std. 9/ Form 4)
                         5,522        12  Grade 12 (Std10 / Matric /
                                          Senior Certificate / Form 5)
                            13        13  National Certificate Vocational
                                          2 (NCV 2)
                             9        14  National Certificate Vocational
                                          3 (NCV 3)
                            57        15  National Certificate Vocational
                                          4 (NCV 4)
                             9        16  N1 (NATED)/ NTC 1
                            10        17  N2 (NATED)/ NTC 2
                            31        18  N3 (NATED)/ NTC 3
                           386        19  No Schooling
                             1        21  ABET Level 2
                         1,397         .  
 
*/
recode edschgrd (-9/-3= .) (19 0=0) (21 5=5)  (9 16=9) ///
 (11 13 17=11)(12 14 18=12) (15 =13) , gen(yrseduc)
 
 tab edschgrd yrseduc
 
 *----------------------------------------------------------------------------------------
 *2.  AGE
 
 codebook best_age_yrs, tab(10)
 recode best_age_yrs (-9/-1=.), gen (age)
 gen agesq=age*age
 label var agesq "Age Squared"
 
 *----------------------------------------------------------------------------------------
 *3. RACE
 codebook best_race, tab(10)
 recode best_race(1=0 "African") (2=1 "Coloured") (3=2 "Asian") (4=3 "White"), gen(race)
 tab race, gen(race)
 rename race1 African
 rename race2 Coloured
 rename race3 Asian
 rename race4 White
 
 *----------------------------------------------------------------------------------------
 *4. Gender
 codebook best_gen, tab(10)
 recode best_gen(2=1 "Yes") (1=0 "No") , gen(female)
 
 *----------------------------------------------------------------------------------------
 *4. Province
 clonevar province=prov2011
 codebook province, tab(100)
 recode province (-9/-2=.)
 /*
     tabulation:  Freq.   Numeric  Label
                           953         1  Western Cape
                         1,239         2  Eastern Cape
                           759         3  Northern Cape
                           811         4  Free State
                         3,662         5  KwaZulu-Natal
                           798         6  North West
                         1,919         7  Gauteng
                         1,143         8  Mpumalanga
                         1,302         9  Limpopo
                         1,560         .  


 */
 
 *create province dummies
  tab province, gen(prov)
  rename prov1 WC
  rename  prov2 EC
  rename prov3 NC
  rename prov4 FS
  rename prov5 KZN
  rename prov6 NW
  rename prov7 GP
  rename prov8 MP
  rename prov9 LMP
 *----------------------------------------------------------------------------------------
 *5. Geo Type
 clonevar geo=geo2011
 codebook geo, tab(10)
 recode geo (-9/-2=.)
 *create dummies
 tab geo, gen(geo)
 rename geo1 Traditional
 rename geo2 Urban
 rename geo3 Farms 
 *----------------------------------------------------------------------------------------
 *5. Household size
 
 de nopres
 clonevar hhsize=nopres
 recode hhsize (-9/-2=.)
  tab hhsize
  
  ** Number of household residents between the age of 18 and 60
  clonevar nhhsize18to60=  nocld
  recode nhhsize18to60 (-9/-1=.)
  tab nhhsize18to60
  
 *----------------------------------------------------------------------------------------
 *5. Household Income
 de hhinc
 clonevar hhincome=hhinc
 recode hhincome (-9/-1=.)
 
    ***Hh income squared
	gen hhincomesq=hhincome*hhincome
	label var hhincomesq "Household Income Squared"
	
*----------------------------------------------------------------------------------------
 *6. Employment opportunity
 de emreturn
 clonevar employret= emreturn
 codebook employret, tab(100)
recode employret (-9/-1=.)
recode employret (98/99=.) //total of 352
recode employret (1=1) (2=0)
label define employret 1 "Yes" 0 "No", replace
label val employret employret

*----------------------------------------------------------------------------------------
 *7. CHILD SUPPORT GRANT (CSG)
 
 *** WAVE 1
    *Number of CSG household receives
	clonevar numOfhhCSGw1=hhincchld
	codebook numOfhhCSGw1, tab (30)
	recode  numOfhhCSGw1 (-9/-1=.)
	
	*Does Anyone Receive CSG
	clonevar hasCSGrecw1=incchld
	codebook hasCSGrecw1, tab(30)
	recode hasCSGrecw1 (-9/-1=.) (1= 1) (2=0)
	label define hasCSGrecw1 1 "Yes" 0 "No",replace
	label val hasCSGrecw1 hasCSGrecw1 
	tab hasCSGrecw1
	
    
 *** WAVE 2
    *Number of CSG household receives
	clonevar numOfhhCSGw2=hhincchld_june
	codebook numOfhhCSGw2, tab (30)
	recode  numOfhhCSGw2 (-9/-1=.)
	
	*Does Anyone Receive CSG
	clonevar hasCSGrecw2=incchld_june
	codebook hasCSGrecw2, tab(30)
	recode hasCSGrecw2 (-9/-1=.) (1= 1) (2=0)
	label define hasCSGrecw2 1 "Yes" 0 "No",replace
	label val hasCSGrecw2 hasCSGrecw2
	tab hasCSGrecw2
	
   *** Combine
     *i) CSG continuous proxy
   gen numOfhhCSG=.
   replace numOfhhCSG=numOfhhCSGw1 if wave2==0
   replace numOfhhCSG=numOfhhCSGw2 if wave2==1
   
   * ii) CSG dummy proxy
    gen hasCSGrec=.
	replace hasCSGrec=0 if numOfhhCSG==0
	replace hasCSGrec=1 if numOfhhCSG>0 &  numOfhhCSG!=.
	tab  hasCSGrec numOfhhCSG
 *----------------------------------------------------------------------------------------
  *----------------------------------------------------------------------------------------
  *EXTRAS
  *WAVE 1
   *i)
   clonevar chronicHC=hlser
   recode  chronicHC (-9/-1=.) (1=1) (2=0)
   label define  chronicHC 1 "Yes" 0 "No"
   label val  chronicHC  chronicHC
   
   *ii) see 
     clonevar seeHC=hl4vis 
	recode  seeHC (-9/-1=.) (1=1) (2=0)
   label define  seeHC 1 "Yes" 0 "No"
   label val  seeHC  seeHC
   
   *iii) Any Gov Grant
   clonevar anyGovgrantw1=incgov 
   codebook anyGovgrantw1, tab(10)
    recode  anyGovgrantw1 (-9/-1=.) (1=1) (2=0)
   label define  anyGovgrantw1 1 "Yes" 0 "No"
   label val  anyGovgrantw1 anyGovgrantw1
   
   *iv) Old age pension receipt
   
    clonevar anyOAPrecw1=incgovpen
   codebook anyOAPrecw1, tab(10)
    recode  anyOAPrecw1 (-9/-1=.) (1=1) (2=0)
   label define  anyOAPrecw1 1 "Yes" 0 "No"
   label val anyOAPrecw1 anyOAPrecw1
   
  *WAVE 2
  
  
  *iii) Any Gov Grant 
   clonevar anyGovgrantw2= incgov_june 
   codebook anyGovgrantw2, tab(10)
    recode  anyGovgrantw2 (-9/-1=.) (1=1) (2=0)
   label define  anyGovgrantw2 1 "Yes" 0 "No"
   label val  anyGovgrantw2 anyGovgrantw2
   
   *iv) Old age pension receipt
     clonevar anyOAPrecw2=incgovpen_june
   codebook anyOAPrecw2, tab(10)
    recode  anyOAPrecw2 (-9/-1=.) (1=1) (2=0)
   label define  anyOAPrecw2 1 "Yes" 0 "No"
   label val anyOAPrecw2 anyOAPrecw2
   
   ***combine
    gen anyGovgrant=.
	replace anyGovgrant=anyGovgrantw1 if wave2==0
	replace anyGovgrant=anyGovgrantw2 if wave2==1
	
  *----------------------------------------------------------------------------------------
 

/*
  SUMMARY: 
  DV:  Hungryless18
  IVs: 
     yrseduc age agesq Coloured Asian White female ///
	 hhsize hhincome numOfhhCSG employret EC NC FS KZN NW GP MP LMP Traditional Farms
	 
  *BASE: African, Male, WC, Urban, No Employ to return
  
  ROBUSTNESS: nhhsize18to60 hhincomesq anyGovgrant
  WAVE 1 only: chronicHC seeHC anyGovgrantw1
   
*/

*Create weight variable
clonevar pwght=pweight_s



*********************************************************************************************
* END:     CLEAN
*********************************************************************************************



*-----------------------------------------------------------------------------------------------------------
*                 SECTION 2: DESCRIPTIVE STATISTICS AND GRAPHSsu
*****************************************************************************************************************
* create binary variable for wave 2 - for columns 1 2 3

tab wave

gen 	binarywave2 = 1 if wave == 2
replace binarywave2 = 0 if wave == 1

tab wave binarywave2

* First see what this does, then create or use your own binary as per the assignment instructions
* create binary variable for columns 4 5 6 

*Main independent variable is continuous
su numOfhhCSG

gen 	aboveavgCSG = 1 if numOfhhCSG >= 1.551521 &  numOfhhCSG!= .
replace aboveavgCSG = 0 if numOfhhCSG<  1.551521 

tab aboveavgCSG

*-------------------------------------------------------------------------------

* Fill with your own variables here
* The testvariable is for columns 4, 5, 6 - read the assignment description
tab empl_stat, gen(emplstat)
rename emplstat1 NEADum
rename emplstat2 DiscouragedDum
rename emplstat3 UnemployedDum
rename emplstat4 EmployedDum

*Save the data
save "./data/YasFinalDataReg", replace
**BASE ON TABLE 2 (included those that appear in both waves

sum Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms ///
if wave==1

sum Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms ///
if wave==2

global variablelist "Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms"
global testvariable	"aboveavgCSG"

*-------------------------------------------------------------------------------

* you are not expected to understand the next section of code
* do not alter it
* run the file all in one go
* always run from top to bottom

foreach var in $variablelist {
	
	di ""
	di "T test"
	di "ttest `var', by(binarywave2)"
	di ""
	
	ttest `var', by(binarywave2)
	
	global mean`var'W1 		= r(mu_1)
	global mean`var'W2 		= r(mu_2)
	global `var'pvalueW1W2 	= r(p)
	
	su `var' if binarywave2 == 0
	su `var' if binarywave2 == 1

	di ""
	di "mean`var'W1 ${mean`var'W1}"
	di "mean`var'W2 ${mean`var'W2}"
	di "`var'pvalueW1W2 ${`var'pvalueW1W2}"
	di ""
	
	di ""
	di "T test"
	di "ttest `var', by($testvariable)"
	di ""
	ttest `var', by($testvariable)
	
	global mean`var'0 		= r(mu_1)
	global mean`var'1 		= r(mu_2)
	global `var'pvalue 		= r(p)
	
	su `var' if $testvariable == 0
	su `var' if $testvariable == 1

	di ""
	di "mean`var'0 ${mean`var'0}"
	di "mean`var'1 ${mean`var'1}"
	di "`var'pvalue ${`var'pvalue}"
	di ""

}

*-------------------------------------------------------------------------------
*postfile- Post results in Stata dataset
*List all open postfiles
postutil clear

postfile meansfileW1W2 str20(variablename) wave1mean wave2mean pvalueW1W2 testvarmean0 testvarmean1 pvalue using meansfileW1W2.dta, replace

foreach var in $variablelist {

	post meansfileW1W2 ("`var'") (${mean`var'W1}) (${mean`var'W2}) (${`var'pvalueW1W2}) (${mean`var'0}) (${mean`var'1}) (${`var'pvalue})

}

*Declare end to posting of observations
postclose meansfileW1W2  

*-------------------------------------------------------------------------------

use meansfileW1W2.dta, clear

br

*-------------------------------------------------------------------------------

* put in your own directories here
* open up the excel file

save "./data/YaseendescripttatsW1W2.dta", replace

export excel using "./data/YaseendescriptivestatsW1W2.xlsx", replace firstrow(variables) 

*********************************************************************************************************************************
use "./data/YasFinalDataReg", clear

*---------------------------------------------------------------------------------------------------------------------------------
* Descriptive and  Visualization

*-------------------------------------------------------------------------------

*---
gen x = 1

//TABLES WITH EMPLOYMENT AND LABOUR MARKET OUTCOMES, BY WAVE

//total population sizes
*Wave 1
quietly svyset cluster [weight = pwght], strata(stratum)
svy, subpop(if age>=18 & EmployedDum!=. & wave==1): total x, level(90)
matrix rtable=r(table)  
matrix Feb = [rtable[1,1] , rtable[2,1]]
svy, over(female) subpop(if age>=18 & EmployedDum!=. &wave==1): total x, level(90)
mat eb=e(b)  
mat eV=e(V)
matrix Feb = [eb[1,2] , sqrt(eV[2,2]) , eb[1,1] , sqrt(eV[1,1]) , Feb]
matrix colnames Feb = Women_est Women_se Men_est Men_se All_est All_se

*Wave 2
svy, subpop(if age>=18 & EmployedDum!=. & wave==2): total x, level(90) 
mat rtable=r(table)
matrix Apr = [rtable[1,1] , rtable[2,1]]
svy, over(female) subpop(if age>=18 & EmployedDum!=. & wave==2): total x, level(90)
mat eb=e(b)  
mat eV=e(V)  
matrix Apr = [eb[1,2] , sqrt(eV[2,2]) , eb[1,1] , sqrt(eV[1,1]), Apr]
matrix colnames Apr = Women_est Women_se Men_est Men_se All_est All_se

*------------------------------
//Household hunger
*wave 1
quietly svyset cluster [weight =  pwght], strata(stratum)
svy: tab hh_nfoodW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==1): tab hh_nfoodW female, col percent se ci level(90)format(%12.1f)
svy: tab hh_chhungerW female, col percent se ci level(90) format(%12.1f)
svy, subpop(if kids17W == 1 & wave==1): tab hh_chhungerW female, col percent se ci level(90)format(%12.1f)
svy: tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==1): tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==1): tab hh_chhungerW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==1): tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)

*wave 2
quietly svyset cluster [weight =  pwght], strata(stratum)
svy: tab hh_nfoodW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==2): tab hh_nfoodW female, col percent se ci level(90)format(%12.1f)
svy: tab hh_chhungerW female, col percent se ci level(90) format(%12.1f)
svy, subpop(if kids17W == 1 & wave==2): tab hh_chhungerW female, col percent se ci level(90)format(%12.1f)
svy: tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==2): tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==2): tab hh_chhungerW female, col percent se ci level(90)format(%12.1f)
svy, subpop(if kids17W == 1 & wave==2): tab hh_hngeverdayW female, col percent se ci level(90)format(%12.1f)


//employment rate
//age>=18 & age<=64
*wave 1
quietly svyset cluster [weight = pwght], strata(stratum)
svy, over(female) subpop(if age>=18 & age<=64 & wave==1): mean EmployedDum, level(90)
mat rtable=r(table)
matrix temp = [rtable[1,2] , rtable[2,2] , rtable[1,1] , rtable[2,1]]
svy, subpop(if age>=18 & wave==1): mean EmployedDum, level(90)
matrix Feb = [Feb \ temp ,  rtable[1,1] , rtable[2,1]]

svy, subpop(if age>=18 & EmployedDum==1 & wave==1): total x, level(90) 
mat rtable = r(table) 
matrix temp = [rtable[1,1] , rtable[2,1]]
svy, subpop(if age>=18 & wave==1): tab EmployedDum female, count se format(%10.0f) 
mat eb=e(b)  
mat eV=e(V)
matrix Feb = [Feb \ eb[1,4] , sqrt(eV[4,4]) , eb[1,3] , sqrt(eV[3,3]), temp]



*wave 2
svy, over(female) subpop(if age>=18 & age<=64 & wave==2): mean EmployedDum, level(90)
mat rtable=r(table)
matrix temp = [rtable[1,2] , rtable[2,2] , rtable[1,1] , rtable[2,1]]
svy, subpop(if age>=18 & wave==2): mean EmployedDum, level(90)
mat rtable=r(table)
matrix Apr = [Apr \ temp , rtable[1,1] , rtable[2,1]]

svy, subpop(if age>=18 & EmployedDum==1 & wave==2): total x, level(90) 
mat rtable = r(table) 
matrix temp = [rtable[1,1] , rtable[2,1]]
svy, subpop(if age>=18 & wave==2): tab EmployedDum female, count se format(%10.0f) 
mat eb=e(b)  
mat eV=e(V)
matrix Apr = [Apr \ eb[1,4] , sqrt(eV[4,4]) , eb[1,3] , sqrt(eV[3,3]), temp]
*==============================================================================================================================================

************************************************************************************
*SAMPLE DESIGN WEIGHTED MEANS
* -----------------------------------------
* Hunger 
*All 
sum Hungryless18 [aw=pwght] if outcome==1 & kids17W==1
*Wave 1
sum  Hungryless18 [aw=pwght] if wave==1 & outcome==1 & kids17W==1
*Wave 2
sum  Hungryless18 [aw=pwght] if wave==2 & outcome==1 & kids17W==1

* has CSG
sum hasCSGrec [aw=pwght] if outcome==1 & kids17W==1
*Wave 1
sum  hasCSGrec [aw=pwght] if wave==1 & outcome==1 & kids17W==1
*Wave 2
sum  hasCSGrec [aw=pwght] if wave==2 & outcome==1 & kids17W==1

* number of CSG
sum numOfhhCSG [aw=pwght] if outcome==1 & kids17W==1
*Wave 1
sum  numOfhhCSG [aw=pwght] if wave==1 & outcome==1 & kids17W==1
*Wave 2
sum  numOfhhCSG [aw=pwght] if wave==2 & outcome==1 & kids17W==1


***23. lpoly

*plot 1
 lpoly Hungryless18 age [aw=pwght] if outcome == 1 , ///
noscatter ytitle("Kids gone hungy in last 7 days") xtitle("Age in Years") ///
note("Source: Author's own plot using NIDS-CRAM") ///
title("")

gr_edit .plotregion1.plot1.style.editstyle line(color(dkgreen)) editcopy
// plot1 color
gr_edit .plotregion1.plot1.style.editstyle line(width(thick)) editcopy
// plot1 width
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
// Graph color

*Save
graph save Figure1.gph, replace
graph export Figure1.png, replace
*----------------------------------------------------------------------------------------------------------
twoway (lpoly Hungryless18 age if outcome == 1 & wave == 1,  lpattern(dash solid) yaxis(1) ytitle("Child Hunger:W1")) ///
(lpoly Hungryless18 age if outcome == 1 & wave == 2, yaxis(2) ytitle("Child Hunger:W2")), ///
xtitle("Age in Years") ///
note("Source: Author's own plot using NIDS-CRAM") ///
title("")
gr_edit .legend.plotregion1.label[1].DragBy 0 -3.202429042428681
// label[1] reposition
gr_edit .legend.plotregion1.label[1].text = {}
gr_edit .legend.plotregion1.label[1].text.Arrpush Wave 1
// label[1] edits
gr_edit .legend.plotregion1.label[2].DragBy 0 -29.46520650198892
// label[2] reposition
gr_edit .legend.plotregion1.label[2].text = {}
gr_edit .legend.plotregion1.label[2].text.Arrpush Wave 2
// label[2] edits
gr_edit .legend.plotregion1.label[2].DragBy 0 29.26476292034269
// label[2] reposition
gr_edit .legend.plotregion1.label[1].DragBy 0 3.607984469631274
// label[1] reposition
gr_edit .plotregion2.plot2.style.editstyle line(width(thick)) editcopy
// plot2 width
gr_edit .plotregion2.plot2.style.editstyle line(color(dkgreen)) editcopy
// plot2 color
gr_edit .plotregion1.plot1.style.editstyle line(width(thick)) editcopy
// plot1 width
gr_edit .plotregion1.plot1.style.editstyle line(color(edkblue)) editcopy
// plot1 color
gr_edit .yaxis2.title.DragBy -20.44524532791065 0
// title reposition
gr_edit .yaxis2.title.text = {}
gr_edit .yaxis2.title.text.Arrpush Child Hunger:Wave 1
// title edits
gr_edit .title.style.editstyle size(medlarge) editcopy
// title size
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy

*Save graph
graph save Figure2.gph, replace
graph export Figure2.png, replace

*--------------------------------------------------------------------------------------------------------

twoway (lpoly  Hungryless18 age if outcome == 1 & hasCSGrec == 1,lpattern(dash solid) yaxis(1) ytitle("Child Hunger:hasCSG")) ///
(lpoly  Hungryless18 age if outcome == 1 & hasCSGrec == 0,yaxis(2) ytitle("Child Hunger:NoCSG"))

gr_edit .legend.plotregion1.label[1].DragBy 0 -3.202429042428681
// label[1] reposition
gr_edit .legend.plotregion1.label[1].text = {}
gr_edit .legend.plotregion1.label[1].text.Arrpush Has CSG benef..
// label[1] edits
gr_edit .legend.plotregion1.label[2].DragBy 0 -35.67895753302058
// label[2] reposition
gr_edit .legend.plotregion1.label[2].text = {}
gr_edit .legend.plotregion1.label[2].text.Arrpush No CSG benef..
// label[2] edits
gr_edit .legend.plotregion1.label[2].DragBy .2004435816461849 34.67673962478967
// label[2] reposition
gr_edit .plotregion2.plot2.style.editstyle line(color(gold)) editcopy
// plot2 color
gr_edit .plotregion2.plot2.style.editstyle line(width(thick)) editcopy
// plot2 width
gr_edit .legend.plotregion1.key[1].view.style.editstyle line(width(thick)) editcopy
// view width
gr_edit .legend.plotregion1.key[1].view.style.editstyle line(color(dkgreen)) editcopy
// view color
gr_edit .yaxis1.title.text = {}
gr_edit .yaxis1.title.text.Arrpush Child Hunger:hasCSG ben
gr_edit .yaxis2.title.text = {}
gr_edit .yaxis2.title.text.Arrpush Child Hunger:hasNOCSG ben
// title edits
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
// Graph color
gr_edit .title.style.editstyle size(medlarge) editcopy
// title size
*Save graph
graph save Figure3.gph, replace
graph export Figure3.png, replace
*----------------------------------------------------------------------------------

twoway (lpolyci  Hungryless18 age if outcome == 1 & hasCSGrec == 1 & kids17W==1,lpattern(dash solid) yaxis(1) ytitle("Child Hunger:hasCSG")) ///
(lpolyci  Hungryless18 age if outcome == 1 & hasCSGrec == 0 & kids17W==1,yaxis(2) ), ///
title("")
gr_edit .legend.plotregion1.label[2].text = {}
gr_edit .legend.plotregion1.label[2].text.Arrpush Has CSG beneficiary
// label[2] edits
gr_edit .legend.plotregion1.label[4].DragBy 0 -29.66565008363506
// label[4] reposition
gr_edit .legend.plotregion1.label[4].text = {}
gr_edit .legend.plotregion1.label[4].text.Arrpush No CSG beneficiary
// label[4] edits
gr_edit .legend.plotregion1.label[4].DragBy -.2004435816461838 30.06653724692746
// label[4] reposition
gr_edit .legend.plotregion1.key[4].view.style.editstyle line(color(dkgreen)) editcopy
// view color
gr_edit .legend.plotregion1.key[4].view.style.editstyle line(width(thick)) editcopy
// view width
gr_edit .legend.plotregion1.key[2].view.style.editstyle line(color(mint)) editcopy
// view color
gr_edit .legend.plotregion1.key[2].view.style.editstyle line(color(teal)) editcopy
// view color
gr_edit .plotregion1.plot2.style.editstyle line(color(orange_red)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(color(dknavy)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(color(gold)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(width(thick)) editcopy
// plot2 width
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
// Graph color
gr_edit .yaxis1.title.text = {}
gr_edit .yaxis1.title.text.Arrpush Child Hunger:hasCSG ben

gr_edit .yaxis2.title.text = {}
gr_edit .yaxis2.title.text.Arrpush Child Hunger:hasNOCSG ben
// title edits


*Save graph
graph save Figlpoly4.gph, replace
graph export Figlpoly4.png, replace
*---------------------------------------------------------------------------------------------------------------------------------

twoway (lpolyci  Hungryless18 age if outcome == 1 & aboveavgCSG== 1,lpattern(dash solid) yaxis(1) ytitle("Child Hunger:AboveAverCSG")) ///
(lpolyci  Hungryless18 age if outcome == 1 & aboveavgCSG == 0,yaxis(2) ytitle("Child Hunger:belowAverCSG")), ///
title("")
gr_edit .legend.plotregion1.label[2].text = {}
gr_edit .legend.plotregion1.label[2].text.Arrpush AboveAverCSG
// label[2] edits
gr_edit .legend.plotregion1.label[4].DragBy 0 -29.66565008363506
// label[4] reposition
gr_edit .legend.plotregion1.label[4].text = {}
gr_edit .legend.plotregion1.label[4].text.Arrpush belowAverCSG
// label[4] edits
gr_edit .legend.plotregion1.label[4].DragBy -.2004435816461838 30.06653724692746
// label[4] reposition
gr_edit .legend.plotregion1.key[4].view.style.editstyle line(color(dkgreen)) editcopy
// view color
gr_edit .legend.plotregion1.key[4].view.style.editstyle line(width(thick)) editcopy
// view width
gr_edit .legend.plotregion1.key[2].view.style.editstyle line(color(mint)) editcopy
// view color
gr_edit .legend.plotregion1.key[2].view.style.editstyle line(color(teal)) editcopy
// view color
gr_edit .plotregion1.plot2.style.editstyle line(color(orange_red)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(color(dknavy)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(color(gold)) editcopy
// plot2 color
gr_edit .plotregion1.plot2.style.editstyle line(width(thick)) editcopy
// plot2 width
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
// Graph color
gr_edit .yaxis1.title.text = {}
gr_edit .yaxis1.title.text.Arrpush Child Hunger:AboveAverCSG ben

gr_edit .yaxis2.title.text = {}
gr_edit .yaxis2.title.text.Arrpush Child Hunger:BelowAverCSG ben
// title edits



*Save graph
graph save Figure3B.gph, replace
graph export Figure3B.png, replace
*---------------------------------------------------------------------------------------------------------------------------------
*twoway (lpolyci  Hungryless18 age if  wave==2 & outcome == 1 & aboveavgCSG== 1 & kids17W==1,lpattern(dash solid) ytitle("")) ///
*(lpolyci  Hungryless18 age if wave==2 & outcome == 1 & aboveavgCSG == 0 & kids17W==1,), ///
*title("")

  reg Hungryless18 c.age##i.aboveavgCSG if  wave==2 & outcome == 1 & kids17W
   reg Hungryless18 c.age##i.hasCSGrec if  wave==2 & outcome == 1 & kids17W==1
   
*---------------------------------------------------------------------------------------------------------
*                 SECTION 3: REGRESSION ANALYSIS
*-----------------------------------------------------------------------------------------------------------

***********************************************************************************************************
* START regressions
***********************************************************************************************************



*-----------------------------------------------------------------------------------------------------------
/* ROBUSTNESS
Variables for Robustness Checks:
  
  Summary:
  
  Continuous:
                 hhsizeW npensionersW  npensexclW nkids17W 	nkids6W nkids7to17W nschoolkidsW ///
				 hh_hngeverdayW hh_chhungerW hh_nfoodW deflator agecat educ educcat educcat2
				 
	WAVE 1: childcare  morechildcareW1 fourplushrs hrchildcareW1
	
	WAVE 2: hrchildcarel5 hrchildcarel5_peg  uif_tersW  uif_W2  covid_srdg_successW2 covid_srg_receiveW2
				 
  Binary:
			  pensionersW	biokidsW necdkidsW2 schoolkidsW  marriedW2  urbanw ruralW ///
			  matricorless matricormore postmatric married
	
*/

*

*LPM and PROBIT
*reg Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
*hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms if kids17W==1 & outcome==1
*outreg2 using Table2robust, excel replace ct(LPM)
*--------------------------------------------------------------------------------------------------------------------------
*25
* PART A: TABLE 2
*wave 1 *With child care (1)
 reg Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms childcare chronicHC if wave==1 & kids17W==1 & outcome==1, robust
outreg2 using Table2, excel replace ct((1) LPM: WAVE 1)

*wave 2 *  (2)
 reg Hungryless18 numOfhhCSG yrseduc age agesq  Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms married if wave==2 & kids17W==1 & outcome==1, robust
outreg2 using Table2, excel append ct((2) LPM: WAVE 2)

*Pooled OLS (POLS)* (3)
reg Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms if kids17W==1 & outcome==1, robust
outreg2 using Table2, excel append ct((3) LPM: POLS)

*Fixed Effects Model (FE)* (4)
xtset pid wave
xtreg Hungryless18 numOfhhCSG age agesq ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms if kids17W==1 & outcome==1, fe robust
outreg2 using Table2, excel append ct((4) FE:)

*Probit Model: Wave 1 (5)
 probit Hungryless18 numOfhhCSG yrseduc age agesq Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms childcare chronicHC if wave==1 & kids17W==1 & outcome==1, robust
margins, dydx(*) post
outreg2 using Table2, excel append ct((5) Probit: WAVE 1)

*Probit Model: Wave 1 (6)
probit Hungryless18 numOfhhCSG yrseduc age agesq  Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms married if wave==2 & kids17W==1 & outcome==1, robust
margins, dydx(*) post
outreg2 using Table2, excel append ct((6) Probit: WAVE 2)

*Random Effects:  (7)
xtreg Hungryless18 numOfhhCSG yrseduc age agesq  Coloured Asian White female ///
hhsize hhincome EmployedDum npensexclW  EC NC FS KZN NW GP MP LMP Traditional Farms if kids17W==1 & outcome==1, re robust
outreg2 using Table2, excel append ct((7) RE:)


*----------------------------------------------------------------------------------------------------------------------
*** PART B: ROBUSTNESS SPECIFICATIONS
* LPM: WAVE 1
reg hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW   ///
 WC urbanw  childcare chronicHC  if wave==1 & kids17W==1 & outcome==1, robust 
outreg2 using Table2robustB, excel replace ct((1)LPM: WAVE 1)

*----------------------------------------------------------------------------------------------------------
*LPM: Wave 2
reg hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW ///
WC urbanw  married if wave==2 & kids17W==1 & outcome==1 , robust
outreg2 using Table2robustB, excel append ct((2)LPM: WAVE 2)

*-----------------------------------------------------------------------------------------------------------
*Pooled OLS (POLS)* (3)
reg hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW ///
WC urbanw  if kids17W==1 & outcome==1 , robust
outreg2 using Table2robustB, excel append ct((3)LPM: POLS)

*------------------------------------------------------------------------------------------------------------
*Fixed Effects (4)
xtreg hh_chhungerW numOfhhCSG i.agecat  hhsizeW hhincome EmployedDum npensexclW   ///
 WC urbanw if kids17W==1 & outcome==1, fe robust
outreg2 using Table2robustB, excel append ct((4) FE:)

xtreg hh_chhungerW numOfhhCSG  hhsizeW    ///
 if kids17W==1 & outcome==1, fe robust
 
*-----------------------------------------------------------------------------------------------------------

*Probit Model: Wave 1 (5)
 probit hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW   ///
 WC urbanw  childcare chronicHC  if wave==1 & kids17W==1 & outcome==1, robust
margins, dydx(*) post
outreg2 using Table2robustB, excel append ct((5) Probit: WAVE 1)

*-------------------------------------------------------------------------------------------------------------
*Probit Model : Wave 2 (6)
probit hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW ///
WC urbanw  married if wave==2 & kids17W==1 & outcome==1, robust
margins, dydx(*) post
outreg2 using Table2robustB, excel append ct((6) Probit: WAVE 2)

*-------------------------------------------------------------------------------------------------------------
*Random Effects:  (7)
xtreg hh_chhungerW numOfhhCSG  i.educcat i.agecat African female  hhsizeW hhincome EmployedDum npensexclW   ///
 WC urbanw if kids17W==1 & outcome==1, re robust
outreg2 using Table2robustB, excel append ct((7) RE:)


*------------------------------------------------------------------------------------------------------------


***************************************************************************************************************
*END REGRESSION
***************************************************************************************************************










*---------------------------------------------------------------------------------------------------------------
* EXTRA SPECIFICATION TESTED


*----------------------------------
*GET a sense of the current Variables

***26. LPM
*wave 1
reg Hungryless18 yrseduc age agesq numOfhhCSG  [pw=pwght] if outcome==1 & wave2==0
outreg2 using Table2C, excel replace ct("LPM: WAVE 1")

reg Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
  [pw=pwght] if outcome==1 & wave2==0
outreg2 using Table2C, excel append ct("(1) LPM: WAVE 1")
*Wave 2
reg Hungryless18 yrseduc age agesq numOfhhCSG  [pw=pwght] if outcome==1 & wave2==1
outreg2 using Table2, excel append ct("LPM: WAVE 2")
reg Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
 [pw=pwght] if outcome==1 & wave2==1
outreg2 using Table2C, excel append ct("(2) LPM: WAVE 2")

xtset pid wave 
*** Pooled OLS LPM
reg Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
 wave2 [aw=pwght] if outcome==1
outreg2 using Table2C, excel append ct("(3) LPM: POLS")

*** Fixed Effects model
xtreg Hungryless18 yrseduc age agesq numOfhhCSG  if outcome==1, fe
outreg2 using Table2C, excel append ct("LPM: FE")

xtreg Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
 wave2 if outcome==1, fe
outreg2 using Table2C, excel append ct("(4) LPM: FE")


*-----------------------------------------------------------------------
***Probit
probit Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
  [pw=pwght] if outcome==1 & wave2==0,robust
 margins, dydx(*) post 
outreg2 using Table2C, excel append ct("(5) Probit: WAVE 1")

probit Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
  [pw=pwght] if outcome==1 & wave2==1,robust
 margins, dydx(*) post 
outreg2 using Table2C, excel append ct("(5) Probit: WAVE 2")


***Logit
logit Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
  [pw=pwght] if outcome==1 & wave2==0,robust
 margins, dydx(*) post 
outreg2 using Table2C, excel append ct("(6) Logit: WAVE 1")
logit Hungryless18 yrseduc age agesq numOfhhCSG Coloured Asian White female ///
hhsize hhincome EmployedDum EC NC FS KZN NW GP MP LMP Traditional Farms ///
  [pw=pwght] if outcome==1 & wave2==1,robust
 margins, dydx(*) post 
outreg2 using Table2C, excel append ct("(6) Logit: WAVE 2")

*-----------------------------------------------------------------------------------------------------------------
***Close the window GUIS
window manage close graph _all

*** Save the Variables in STATA format (.Dat)
save YaseenData, replace

***Close the log file
log close
