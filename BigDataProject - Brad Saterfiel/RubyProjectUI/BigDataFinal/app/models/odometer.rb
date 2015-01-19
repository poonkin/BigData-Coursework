class Odometer

  include Cequel::Record

  key :bikeid, :bigint
  column :time_ridden, :bigint

end