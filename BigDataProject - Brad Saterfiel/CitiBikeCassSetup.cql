CREATE KEYSPACE citibike WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

USE citibike;

CREATE TABLE odometers ( bikeid bigint,  time_ridden bigint, PRIMARY KEY (bikeid) );

CREATE TABLE latest_bike_trips ( 
	unique_id int,
	tripduration int,
	starttime varchar,
	stoptime varchar,
	startstation int,
	startstationname varchar,
	startstationlat double,
	startstationlong double,
	endstation int,
	endstationname varchar,
	endstationlat double,
	endstationlong double,
	bikeid int,
	usertype varchar,
	birthyear int,
	gender int,
	PRIMARY KEY(unique_id));