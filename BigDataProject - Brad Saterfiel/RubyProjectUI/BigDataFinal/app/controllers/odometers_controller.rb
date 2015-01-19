
class OdometersController < ApplicationController

  def index

  end

  def show_mph

    @trip_duration = []
    @start_lat = []
    @start_long = []
    @end_lat = []
    @end_long = []
    @genders = []
    @years = []

    @num_trips = Latest_Bike_Trip::Latest_Bike_Trip.all

    @num_trips.each do |key|
      @genders << key[:gender]
      @years << key[:birthyear]
      @trip_duration << key[:tripduration]
      @start_lat << key[:startstationlat]
      @start_long << key[:startstationlong]
      @end_lat << key[:endstationlat]
      @end_long << key[:endstationlong]
    end

    @phi1 = []
    @phi2 = []
    @deltaPhi = []
    @deltaGamma = []

    const_r = 6371
    @a = []
    @b = []
    @dist = []

    for i in 0..@trip_duration.length-1
      @phi1 << @start_lat[i] * Math::PI / 180
      @phi2 << @end_lat[i] * Math::PI / 180
      @deltaPhi << (@end_lat[i] - @start_lat[i]) * Math::PI / 180
      @deltaGamma << (@end_long[i] - @start_long[i]) * Math::PI / 180
    end

    for i in 0..@trip_duration.length-1
      @a << (Math::sin(@deltaPhi[i]/2) * Math::sin(@deltaPhi[i]/2)) +
          (Math::cos(@phi1[i]) * Math::cos(@phi2[i]) *
              Math::sin(@deltaGamma[i]/2) * Math::sin(@deltaGamma[i]/2))
    end

    for i in 0..@trip_duration.length-1
      @dist << 2 * Math::atan2(Math::sqrt(@a[i]), Math::sqrt(1-@a[i])) * const_r
    end

    miles_2_kms = 1.60934
    @mph = []

    for i in 0..@trip_duration.length-1
      @mph << (@dist[i]/miles_2_kms * 3600) / @trip_duration[i]
    end

    @young_men = []
    @mid_men = []
    @old_men = []

    @young_women = []
    @mid_women = []
    @old_women = []

    for i in 0..@trip_duration.length-1
      if @years[i] != 0 && @mph[i] > 1.0 && @mph[i] < 25.0
        if @years[i] < 1955
          if @genders[i] == 1
            @old_men << @mph[i]
          else
            @old_women << @mph[i]
          end
        elsif @years[i] >= 1955 && @years[i] < 1990
          if @genders[i] == 1
            @mid_men << @mph[i]
          else
            @mid_women << @mph[i]
          end
        else
          if @genders[i] == 1
            @young_men << @mph[i]
          else
            @young_women << @mph[i]
          end
        end
      end
    end

    @last_trip = Latest_Bike_Trip::Latest_Bike_Trip.find(@trip_duration.length-1)

    if @last_trip[:gender] == 1
      @last_gender = 'Male'
    else
      @last_gender = 'Female'
    end

    if @last_trip[:birthyear] != 0
      @last_birthday = @last_trip[:birthyear]
    else
      @last_birthday = 'Unknown'
    end

    @last_start_station = @last_trip[:startstationname]
    @last_end_station = @last_trip[:endstationname]

    @last_trip_length = (@last_trip[:tripduration] / 60).to_s + ' min ' + (@last_trip[:tripduration] % 60).to_s + ' seconds'

    @oms = @old_men.length
    @mms = @mid_men.length
    @yms = @young_men.length

    @yws = @young_women.length
    @mws = @mid_women.length
    @ows = @old_women.length

    if @oms > 0
      @old_men_avg = @old_men.reduce(:+)/@old_men.size
    else
      @old_men_avg = 'Unknown'
    end

    if @mms > 0
      @mid_men_avg = @mid_men.reduce(:+)/@mid_men.size
    else
      @mid_men_avg = 'Unknown'
    end

    if @yms > 0
      @young_men_avg = @young_men.reduce(:+)/@young_men.size
    else
      @young_men_avg = 'Unknown'
    end

    if @ows > 0
      @old_women_avg = @old_women.reduce(:+)/@old_women.size
    else
      @old_women_avg = 'Unknown'
    end

    if @mws > 0
      @mid_women_avg = @mid_women.reduce(:+)/@mid_women.size
    else
      @mid_women_avg = 'Unknown'
    end

    if @yws > 0
      @young_women_avg = @young_women.reduce(:+)/@young_women.size
    else
      @young_women_avg = 'Unknown'
    end

    @mph = Hash[:old_men_avg => @old_men_avg, :mid_men_avg => @mid_men_avg, :young_men_avg => @young_men_avg,
                 :old_women_avg => @old_women_avg, :mid_women_avg => @mid_women_avg, :young_women_avg => @young_women_avg]

    @counts = Hash[:oms => @oms, :mms => @mms, :yms => @yms, :ows => @ows, :mws => @mws, :yws => @yws]

    respond_to do |format|
      format.js
    end


  end


  def show_ride
    @num_trips = Latest_Bike_Trip::Latest_Bike_Trip.all

    @years = []
    @trip_duration = []

    @num_trips.each do |key|
      @years << key[:birthyear]
      @trip_duration << key[:tripduration]
    end

    @last_trip = Latest_Bike_Trip::Latest_Bike_Trip.find(@trip_duration.length-1)

    if @last_trip[:gender] == 1
      @last_gender = 'Male'
    else
      @last_gender = 'Female'
    end

    if @last_trip[:birthyear] != 0
      @last_birthday = @last_trip[:birthyear]
    else
      @last_birthday = 'Unknown'
    end

    @last_start_station = @last_trip[:startstationname]
    @last_end_station = @last_trip[:endstationname]

    @last_trip_length = (@last_trip[:tripduration] / 60).to_s + ' min ' + (@last_trip[:tripduration] % 60).to_s + ' seconds'

    @ride = Hash[:gender => @last_gender, :birthday => @last_birthday, :start_station => @last_start_station,
                 :end_station => @last_end_station, :trip_length => @last_trip_length]

    respond_to do |format|
      format.js
    end

  end

  @@old_bikes_records = 0

  def set_old_bikes

    if @@old_bikes_records == 0

      @odometers = Odometer.all

      @@old_bikes = []
      @@old_times = []

      @@min_time = 1000000000000
      @@max_time = 0

      @@batch_time_sum = 0
      @@speed_time_sum = 0

      @odometers.each do |key|
        @@old_bikes << key[:bikeid]
        @@old_times << key[:time_ridden]
      end

      @@old_cols = [@@old_bikes, @@old_times]

      for i in 0..@@old_bikes.length-1
        @@batch_time_sum += @@old_cols[1][i]
        if @@old_cols[1][i] < @@min_time
          @@min_time = @@old_cols[1][i]
          # puts 'MIN TIME IS NOW ' + @@min_time.to_s
        end
        if @@old_bikes[1][i] > @@max_time
          @@max_time = @@old_cols[1][i]
          # puts 'MAX TIME IS NOW ' + @@max_time.to_s
        end
      end

      @@old_bikes_records = 1
    end
  end

  def show_age

    puts 'OLD BIKES IS ' + @@old_bikes_records.to_s

    if @@old_bikes_records == 0
      set_old_bikes
    end

    puts 'OLD BIKES IS ' + @@old_bikes_records.to_s

    puts 'BEG OF SHOW_AGE MIN TIME IS : ' + @@min_time.to_s + ' AND MAX TIME IS : ' + @@max_time.to_s

    @new_bikes = []
    @new_times = []

    @new_odometers = Latest_Bike_Trip::Latest_Bike_Trip.all

    @new_odometers.each do |key|
      @new_bikes << key[:bikeid]
      @new_times << key[:tripduration]
    end

    @last_trip = Latest_Bike_Trip::Latest_Bike_Trip.find(@new_bikes.length-1)

    @@speed_time_sum += @last_trip[:tripduration]

    time_sum = @@batch_time_sum + @@speed_time_sum

    puts 'LAST TRIP TIME WAS ' + @last_trip[:tripduration].to_s + ' BATCH SUM IS ' + @@batch_time_sum.to_s + ' SPEED SUM IS ' + @@speed_time_sum.to_s + ' AND TOTAL TIME IS ' + time_sum.to_s
    puts 'AVERAGE DENOMINATOR IS ' + @@old_bikes.length.to_s

    @avg_bike = (time_sum / @@old_bikes.length)
    @avg_hrs = (@avg_bike / 3600)
    @avg_mins = (@avg_bike % 3600) / 60
    @avg_secs = (@avg_bike % 60)

    @avg_time = @avg_hrs.to_s + ' hrs ' + @avg_mins.to_s + ' mins ' + @avg_secs.to_s + ' secs'

    @young_time = (@@min_time / 3600).to_s + 'hrs ' + ((@@min_time % 3600) / 60).to_s + ' mins'
    @old_time = (@@max_time / 3600).to_s + 'hrs ' + ((@@max_time % 3600) / 60).to_s + ' mins'
    puts 'AVERAGE TIME IS : ' + @avg_time.to_s
    puts 'MIN TIME IS : ' + @young_time.to_s
    puts 'MAX TIME IS : ' + @old_time.to_s

    respond_to do |format|
      format.js
    end

  end

end