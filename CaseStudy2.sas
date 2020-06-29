
libname case "/home/u49123731/ECRB94/data";


data clean_tourism;
	length Country_Name $300 Tourism_Type $20;
	retain Country_Name "" Tourism_Type"";
	
	set Case.Tourism(Drop=_1995-_2013);
	
	if A ne . then Country_Name=Country;
	if lowcase(Country) = "inbound tourism" 
			then Tourism_Type = "Inbound tourism";
		else if lowcase(Country) = "outbound tourism"
			then Tourism_Type = "Outbound tourism";
	if Country_Name ne Country and Country ne Tourism_Type;
	
	series = upcase(series);
	if series = ".." then Series="";
	
	ConversionType = scan(country, -1, " ");
	
	if _2014 = ".." then _2014 = ".";
	
	if ConversionType = "Mn" then do;
		if _2014 ne "." then Y2014 = input(_2014, 16.) * 1000000;
			else Y2014 = .;
		Category = cat(scan(Country, 1, "-","r"), " - US$");
		end;
	
	else if ConversionType = "Thousands" then do;
		if _2014 ne "." then Y2014 = input(_2014, 16.) * 1000;
			else Y2014 = .;
		Category = scan(Country, 1, "-","r");
		end;	
		
	format y2014 comma25.;
	drop A ConversionType Country _2014;
run;
	

proc freq data=clean_tourism;
	tables category tourism_type series;
run;

proc means data=clean_tourism min mean max n maxdec=0
	var Y2014;
run;


proc format;
	value contID
		1 = "North America"
		2 = "South America"
		3 = "Europe"
		4 = "Africa"
		5 = "Asia"
		6 = "Oceania"
		7 = "Antarctica";
run;

proc sort data=Case.country_info(rename=(Country=Country_Name))
	out=country_sorted;
	by country_name;
run;

data final nocountry;
	merge clean_tourism(in=t) country_sorted(in=c);
	by country_name;
	if t=1 and c=1 then output final;
	if (t=1 and c=0) and first.country_name = 1 then output nocountry;
	format continent contid.;
run;


proc freq data=final nlevels;
	tables country_name /nocum nopercent;
run;

proc means data=final mean maxdec=0 order=freq;
	var Y2014;
	class Continent;
	where category = "Arrivals";
run;

proc means data=final mean maxdec=0;
	var Y2014;
	where lowcase(Category) contains "tourism expenditure in other countries";
run;













