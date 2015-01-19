-- Import the CSVLoader plugin (available from the 3rd party piggybank modules collection)
REGISTER ./contrib/piggybank/java/piggybank.jar;
REGISTER /Users/bsaterfiel/cassandra/lib/apache-cassandra-2.0.11.jar
REGISTER /Users/bsaterfiel/cassandra/lib/apache-cassandra-thrift-2.0.11.jar
REGISTER /Users/bsaterfiel/cassandra/lib/jamm-0.2.5.jar
REGISTER /Users/bsaterfiel/cassandra/lib/libthrift-0.9.1.jar
REGISTER ./cassandra-driver-core-2.0.5.jar;


RAW_CITIBIKE_DATA = LOAD '/final/1.csv' 
					USING org.apache.pig.piggybank.storage.CSVExcelStorage 
					(',', 'NO_MULTILINE', 'NOCHANGE', 'SKIP_INPUT_HEADER')
					AS (tripduration:long, starttime:chararray, stoptime:chararray, startstation:int, startstationname:chararray,
						startstationlat:double, startstationlong:double, endstation:int, endstationname:chararray, endstationlat:double,
						endstationlong:double, bikeid:long, usertype:chararray, birthyear:int, gender:int) ;


BY_BIKES = GROUP RAW_CITIBIKE_DATA BY bikeid;
BY_BIKE_TOAL_MIN = FOREACH BY_BIKES GENERATE SUM(RAW_CITIBIKE_DATA.tripduration) as time_ridden, group as bikeid;
OLDEST_BIKES = ORDER BY_BIKE_TOAL_MIN BY time_ridden DESC;


CASSANDRA_STRUCTURED2 = FOREACH OLDEST_BIKES GENERATE
	TOTUPLE( TOTUPLE('bikeid', bikeid)), 
	TOTUPLE(time_ridden);

STORE CASSANDRA_STRUCTURED2 INTO
  'cql://citibike/odometers?output_query=update odometers set time_ridden%3D%3F'
  USING org.apache.cassandra.hadoop.pig.CqlStorage();



