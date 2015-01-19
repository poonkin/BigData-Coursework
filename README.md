# BigData-Coursework
Final Project Code for MPCS 53013

YouTube video link: https://www.youtube.com/watch?v=SWcae4DjZhU

Brad Saterfiel - MPCS 53013 - Big Data - Final Project ReadMe

All Files are included in the Project Directory

CitiBike Data can be found here.  http://www.citibikenyc.com/system-data

I have cleaned up and retested all of the scripts and whole project.  Please let me know if there are any problems.  You will need to install the Poseidon gem for the Ruby script.

Step By Step

1) December data was put into Hadoop via csv in the final directory … on my machine /final/1.csv

2) Copy and pasted into Cassandra the keyspace and tables from the .cql file.

3) Pig script for Map Reduce job to Cassandra table odometers.

4) Java citbikefinal for handling Thrift deserialization and writing into Cassandra from Spark reading form the Kafka queue.

* don’t forget to use the jar you created from the Maven Install to get spark going

the topic is bikedata

5) Use the r2k.rb and gen-rb Ruby scripts to move Thrift serialized data into Cassandra.

6) The Rails folder has the whole Rails projects there to combine views in the UI.


