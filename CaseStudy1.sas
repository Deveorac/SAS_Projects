proc import datafile = "/home/u49123731/ECRB94/data/TSAClaims2002_2017.csv"
		dbms = csv
		out = Claims
		replace;
	guessingrows = max;
run;


/*Data Exploration*/

proc contents data=Claims varnum;
run;

proc freq data=Claims;
	tables Claim_site
		Disposition
		Claim_Type
		Date_Received
		Incident_Date / nocum nopercent;
	format incident_date date_received year4.;
run;

proc print data=Claims;
	where date_received < incident_date;
	format date_received incident_date date9.;
run;

/*Remove duplicates*/

proc sort data=Claims
	out = Claims_nodups noduprecs;
	by _all_;
run;

/*Sort ascending incident date*/

proc sort data=Claims_nodups;
	by Incident_date; run;

/*Clean data*/

data Claims_clean;
	set claims_nodups;
	if Claim_site in ("-", "") then Claim_site = "Unknown";
	if Disposition in ("-", "") then Disposition = "Unknown";
		else if Disposition = "losed: Contractor Claim"
			then Disposition = "Closed:Contractor Claim";
		else if Disposition = "Closed: Canceled"
			then Disposition = "Closed:Canceled";
	if Claim_type in ("-", "") then Claim_Type = "Unknown";
		else if Claim_Type= "Passenger Property Loss/Personal Injur"
			then Claim_Type = "Passenger Property Loss";
		else if Claim_Type = "Passenger Property Loss/Personal Injury"
			then Claim_Type = "Passenger Property Loss";
		else if Claim_Type = "Property Damage/Personal Injury"
			then Claim_Type = "Property Damage";
	State = upcase(state);
	StateName = propcase(StateName);
	if (Incident_Date > Date_Received or 
		Date_Received = . or
		Incident_Date = . or 
		Year(Incident_Date) < 2002 or
		Year(Incident_Date) > 2017 or
		Year(Date_Received) < 2002 or 
		Year(Date_Received) > 2017) then Date_Issues = "Needs Review";
	format Incident_Date Date_Received date9. Close_Amount Dollar20.2;
	Inc_year = Year(Incident_Date);
run;	




proc freq data=Claims_clean order=freq;
	tables Claim_site
		Disposition
		Claim_Type
		Inc_year
		Date_Issues / nocum nopercent;
run;


/*Analysis*/

/*How many date issues are there?*/

/*Do incidents increase or decrease from 2004 to 2017?*/
ods graphics on;
proc freq data=Claims_clean;
	table Incident_Date / nocum nopercent plots=freqplot;
	format Incident_Date year4.;
	where date_issues is null;
run;
/*What was the first year were frequency fell below 10,000*/

/*In Hawaii, how many property damage claims were there*/

%let state = HI;

data State_all;
	set Claims_clean;
	where State = 'HI';
run;

data State;
	set State_all;
	where date_issues is null;
run;

proc freq data=State order=freq;
	tables Claim_Type
	Claim_Site
	Disposition / nocum nopercent;
run;

proc means data=State mean;
	var Close_Amount;
run;


/*In Hawaii, how many incidents occurred at the checkpoint*/

/*In Hawaii, how many claims were approved in full*/

/*In Hawaii, what is the average Close amount*/






