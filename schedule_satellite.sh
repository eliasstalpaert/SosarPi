#!/bin/bash

# $1 = Satellite Name
# $2 = Frequency
# var2 = prediction end in epoch
# var1 = prediction start in epoch
# MAXELEV = maximum elevation of a pass
# TIMER = end time - start time ->> time to capture
# OUTDATE = the date to start a capture in year-month-day-hour-min-sec
source SOSARconfig.cfg

#Predict starting and ending pass time and max elevation of the first next pass of the given sattelite name ( in $1 )
PREDICTION_START=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}" | head -1`
PREDICTION_END=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}" | tail -1`

var2=`echo $PREDICTION_END | cut -d " " -f 1`

MAXELEV=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}" | awk -v max=0 '{if($5>max){max=$5}}END{print max}'`

# This while loop predicts satellite passes for one day
while [ `date --date="TZ=\"UTC\" @${var2}" +%D` == `date +%D` ]; do

START_TIME=`echo $PREDICTION_START | cut -d " " -f 3-4`
var1=`echo $PREDICTION_START | cut -d " " -f 1`

TIMER=`expr $var2 - $var1`

OUTDATE=`date --date="TZ=\"UTC\" $START_TIME" +%Y%m%d-%H%M%S`

# If the pass elevates above the elevation we want and have specified in the config file
if [ "$MAXELEV" -gt "$MAX_elevation" ];
  then
    echo ${1//" "}${OUTDATE} $MAXELEV
    # put a job in the at queue
    echo "/home/pi/weather/predict/receive_and_process_satellite.sh \"${1}\" $2 /home/pi/weather/${1//" "}${OUTDATE} /home/pi/weather/predict/weather.tle $var1 $TIMER" | at `date --date="TZ=\"UTC\" $START_TIME" +"%H:%M %D"` 

fi

nextpredict=`expr $var2 + 60`

# Predict parameters for the next satellite
PREDICTION_START=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}" $nextpredict | head -1`
PREDICTION_END=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}"  $nextpredict | tail -1`

MAXELEV=`/usr/bin/predict -t /home/pi/weather/predict/weather.tle -p "${1}" $nextpredict | awk -v max=0 '{if($5>max){max=$5}}END{print max}'`

var2=`echo $PREDICTION_END | cut -d " " -f 1`

done
