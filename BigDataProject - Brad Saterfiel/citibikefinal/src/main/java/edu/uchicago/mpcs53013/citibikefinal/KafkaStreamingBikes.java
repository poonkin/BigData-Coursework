package edu.uchicago.mpcs53013.citibikefinal;

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import scala.Tuple2;

//import com.google.common.collect.Lists;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.Function2;
import org.apache.spark.api.java.function.PairFunction;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.StorageLevels;
import org.apache.spark.streaming.Duration;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaPairDStream;
import org.apache.spark.streaming.api.java.JavaPairReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;
import org.apache.spark.streaming.kafka.KafkaInputDStream;
import org.apache.spark.streaming.kafka.KafkaUtils;

import edu.uchicago.mpcs53013.citibikefinal.CitiBikeData;

import java.util.HashMap;
import java.util.regex.Pattern;

import static com.datastax.spark.connector.japi.CassandraJavaUtil.javaFunctions;
import static com.datastax.spark.connector.japi.CassandraJavaUtil.mapToRow;

import org.apache.spark.Logging;
import org.apache.thrift.TDeserializer;
import org.apache.thrift.TException;
import org.apache.thrift.protocol.TJSONProtocol;
import org.apache.log4j.*;

import com.datastax.spark.connector.cql.CassandraConnector;
/**
 * Reads real-time thrift encoded WeatherSummaries from a Kafka topic, 
 * and stores the results in Cassandra.
 *
 * Program arguments are Spark master and cassandra address and optionally
 * the Kafka server to connect with (defaults to "localhost:2181")
 */

public class KafkaStreamingBikes {
	
	private static final Pattern SPACE = Pattern.compile(" ");
	static TDeserializer deserializer = new TDeserializer(new TJSONProtocol.Factory());
	
	public static void main(String[] args) {
		// Args
		if (args.length < 2) {
			System.err.println("Usage: JavaStreamingWeather <master> <Cassandra Host> <Optional: Kafka server>");
			System.exit(1);
		}
		
		// Logger
		boolean log4jInitialized = Logger.getLogger("spark").getAllAppenders().hasMoreElements();
		if (!log4jInitialized) {
			// We first log something to initialize Spark's default logging, then we override the
			// logging level.
			Logger.getLogger("spark").info("Setting log level to [WARN] for streaming example." +
			" To override add a custom log4j.properties to the classpath.");
			Logger.getLogger("spark").setLevel(Level.WARN);
			Logger.getRootLogger().setLevel(Level.WARN);
		}
		 
		// Config Spark -- may need to change to citibikedata
		// Create the context with a 1 second batch size
		SparkConf sparkConf = new SparkConf().setAppName("citibikedata");
		sparkConf.setMaster(args[0]);
		sparkConf.set("spark.cassandra.connection.host", args[1]);
		JavaStreamingContext ssc = new JavaStreamingContext(sparkConf, new Duration(1000));
		
		JavaSparkContext sc = new JavaSparkContext(sparkConf);
			
		// Kafka K,V receiver
		JavaPairReceiverInputDStream<String, String> kafkaMessages 
			= KafkaUtils.createStream(ssc, 
									args.length > 2 ? args[2] : "localhost:2181",
									"1", 
									new HashMap<String, Integer>() {
										{ 
											put("bikedata", 1); 
										}
			});
		
		// Extract only the value from the key value pairs
		JavaDStream<String> lines = kafkaMessages.map(new Function<Tuple2<String, String>, String>() {
			@Override
			public String call(Tuple2<String, String> tuple2) {
				return tuple2._2();
			}
		});
		
		JavaDStream<CitiBikeData> cassandraBikeSummaries 
		   = lines.map(new Function<String, CitiBikeData>() {
			@Override
			public CitiBikeData call(String x) {
				CitiBikeData bikeSummary = new CitiBikeData();
				try {
					deserializer.fromString(bikeSummary, x);
				} catch (TException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				return new CitiBikeData(bikeSummary);
			}
		});        
		
		final CassandraConnector cassandraConnector = CassandraConnector.apply(sparkConf);
		
		javaFunctions(cassandraBikeSummaries)
     .writerBuilder("citibike", "latest_bike_trips", mapToRow(CitiBikeData.class))
     .saveToCassandra();

		ssc.start();
		ssc.awaitTermination();

	}

}
