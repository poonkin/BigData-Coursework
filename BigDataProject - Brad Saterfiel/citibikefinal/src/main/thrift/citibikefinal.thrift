namespace java edu.uchicago.mpcs53013.citibikefinal

struct CitiBikeData {
	1: required i32 unique_id;
	2: required i32 tripduration;
	3: required string starttime;
	4: required string stoptime;
	5: required i32 startstation;
	6: required string startstationname;
	7: required double startstationlat;
	8: required double startstationlong;
	9: required i32 endstation;
	10: required string endstationname;
	11: required double endstationlat;
	12: required double endstationlong;
	13: required i32 bikeid;
	14: required string usertype;
	15: required i32 birthyear;
	16: required i32 gender;
}
	