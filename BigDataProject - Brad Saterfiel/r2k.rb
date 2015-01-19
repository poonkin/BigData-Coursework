
$:.push('./gen-rb')

require 'poseidon'
require 'csv'
require 'thrift'
require 'citibikefinal_types'
require 'citibikefinal_constants'

producer = Poseidon::Producer.new(["localhost:9092"], "bikedata")

row_ctr = 0

File.open('/Users/bsaterfiel/Desktop/CitiBikeData/2.csv').each do |row|
    data = CitiBikeData.new
    
    row_split = row.split(",")
    
    data.unique_id = row_ctr
    data.tripduration = row_split[0].to_i
    data.starttime = row_split[1].to_s
    data.stoptime = row_split[2].to_s
    data.startstation = row_split[3].to_i
    data.startstationname = row_split[4].to_s
    data.startstationlat = row_split[5].to_f
    data.startstationlong = row_split[6].to_f
    data.endstation = row_split[7].to_i
    data.endstationname = row_split[8].to_s
    data.endstationlat = row_split[9].to_f
    data.endstationlong = row_split[10].to_f
    data.bikeid = row_split[11].to_i
    data.usertype = row_split[12].to_s
    data.birthyear = row_split[13].to_i
    data.gender = row_split[14].to_i
    
    row_ctr += 1
    
    my_ser = Thrift::Serializer.new(Thrift::JsonProtocolFactory.new)
    ser2json = my_ser.serialize(data)
    
    
    puts ser2json
    
 	producer.send_messages([Poseidon::MessageToSend.new("bikedata", ser2json)])

 	sleep 3
end
