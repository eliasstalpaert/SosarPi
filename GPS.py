import serial
import pynmea2
import os
import fileinput

port = "/dev/serial0"

def parseGPS(str):
    if str.find("GGA") > 0:
        msg = pynmea2.parse(str)
        if msg.latitude != 0.0:
            print("gps connection")
            print(msg.latitude)
            print ("Timestamp: %s -- Lat: %s %s -- Lon: %s %s -- Altitude: %s %s -- Satellites: %s" % (msg.timestamp,msg.lat,msg.lat_dir,msg.lon,msg.lon_dir,msg.altitude,msg.altitude_units,msg.num_sats))
            f= open("/home/pi/.predict/predict.qth","w+")
            f.write("OH\n")
            f.write(" %s\n" %(msg.latitude))
            f.write(" -%s\n" %(msg.longitude,))
            f.write(" %s\n" %(msg.altitude))
            f.close()
            
            old_lat = "Latitude:"   # if any line contains this text, I want to modify the whole line.
            new_lat = "Latitude: {}\n".format(msg.latitude)
            old_long = "Longitude:"   # if any line contains this text, I want to modify the whole line.
            new_long = "Longitude: {}\n".format(msg.longitude)
            old_alt = "Altitude:"   # if any line contains this text, I want to modify the whole line.
            new_alt = "Altitude: {}\n".format(msg.altitude)
            x = fileinput.input(files="/home/pi/.wxtoimgrc", inplace=1)
            for line in x:
                if old_lat in line:
                    if "Reference" in line:
                        line =line
                    else:
                        line = new_lat
                if old_long in line:
                    if "Reference" in line:
                        line =line
                    else:
                        line = new_long
                if old_alt in line:
                    if "Reference" in line:
                        line = line
                    else:
                        line = new_alt
                print (line, end='')
            x.close()
        else:
            print("no gps connection")
serialPort = serial.Serial(port, baudrate = 9600, timeout = 0.5)

for y in range (0,20):
    str1 = serialPort.readline().decode("utf-8")
    print(str1)
    parseGPS(str1)  
    
    