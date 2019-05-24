#!/bin/bash


# Update GPS location
python3 /home/pi/weather/predict/GPS.py

# Check if we have internet & Update Satellite Information
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online"
    wget -qr https://www.celestrak.com/NORAD/elements/weather.txt -O /home/pi/weather/predict/weather.txt
	grep "NOAA 15" /home/pi/weather/predict/weather.txt -A 2 > /home/pi/weather/predict/weather.tle
	grep "NOAA 18" /home/pi/weather/predict/weather.txt -A 2 >> /home/pi/weather/predict/weather.tle
	grep "NOAA 19" /home/pi/weather/predict/weather.txt -A 2 >> /home/pi/weather/predict/weather.tle
	grep "METEOR-M 2" /home/pi/weather/predict/weather.txt -A 2 >> /home/pi/weather/predict/weather.tle
else
    echo "Offline"
fi




#Remove all AT jobs

for i in `atq | awk '{print $1}'`;do atrm $i;done


#Schedule Satellite Passes:

/home/pi/weather/predict/schedule_satellite.sh "NOAA 19" 137.1000
/home/pi/weather/predict/schedule_satellite.sh "NOAA 18" 137.9125
/home/pi/weather/predict/schedule_satellite.sh "NOAA 15" 137.6200
/home/pi/weather/predict/schedule_satellite.sh "METEOR-M 2" 137.9000

