#!/bin/bash

# $1 = Satellite Name
# $2 = Frequency
# $3 = FileName base
# $4 = TLE File
# $5 = EPOC start time
# $6 = Time to capture

source SOSARconfig.cfg

# Update GPS location
python3 /home/pi/weather/predict/GPS.py

echo NEW PASS >> METEOR.log 
echo time to capture = $6 >> METEOR.log 
# RECORDING : 
if [ "$1" == "METEOR-M 2" ];
then
    echo before recording >> METEOR.log 
    timeout $6 rtl_fm -M raw -f ${2}M -s 120k -g 48 -p 0.0 | sox -t raw -r 120k -c 2 -b 16 -e s - -t wav $3.wav rate 96k
    echo after recording >> METEOR.log  	
else
    echo before recording >> METEOR.log 
    timeout $6 rtl_fm -f ${2}M -s 60k -g 45 -p 55 -E wav -E deemp -F 9 - | sox -t wav - $3.wav rate 11025
    echo after recording >> METEOR.log  	
fi



PassStart=`expr $5 + 90`

# DECODING/DEMODULATING
if [ -e $3.wav ]
  then
  if [ "$1" == "METEOR-M 2" ];
        then	
	meteor_demod -B -o $3.qpsk $3.wav >> METEOR.log
	/home/pi/weather/meteor_decoder/medet $3.qpsk $3 -cd -q >> METEOR.log
	/home/pi/weather/meteor_decoder/medet $3.dec $3 -S -r 65 -g 65 -b 64 -d -q >> METEOR.log
  else
	if [ $NOAA_decode == "wxtoimg" ];
	  then
	  /usr/local/bin/wxmap -T "${1}" -H $4 -p 0 -l 1 -o $PassStart ${3}-map.png >> logNOAA.txt
	  sleep 1m
	  /usr/local/bin/wxtoimg -m ${3}-map.png -e "$Enhancement" $3.wav $3.png >> logNOAA.txt
	else
	  ~/Downloads/NOGUI/noaa-apt -o NOAAfirstTESt.png $3.wav >> logNOAA.txt
	fi

# PUT LOGS IN A LOG FILE FOR THE TCP CONNECTION WITH THE APP
	if [ "$1" == "METEOR-M 2" ];
	then
	    echo METEOR >> /home/pi/Downloads/app/log
	else
	    echo "${1//[[:blank:]]/}" >> /home/pi/Downloads/app/log

	fi
	
	date +%H%M%S >> /home/pi/Downloads/app/log      
	date +%Y%m%d | tail -c 7 >> /home/pi/Downloads/app/log

  fi
  
  
fi
