class Latest_Bike_Trip

  include Cequel::Record

  key :unique_id, :int
  column :tripduration, :int
  column :starttime, :text
  column :stoptime, :text
  column :startstation, :int
  column :startstationname, :text
  column :startstationlat, :double
  column :startstationlong, :double
  column :endstation, :int
  column :endstationname, :text
  column :endstationlat, :double
  column :endstationlong, :double
  column :bikeid, :int
  column :usertype, :text
  column :birthyear, :int
  column :gender, :int

end