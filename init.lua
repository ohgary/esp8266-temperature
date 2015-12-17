--Temperature display
--Gary Sanders, N8EMR
--
--Defined ESP8266 I/O Pin to use.  4=gpio2,
DHTpin=4
--Defined the location of the device. This is just a 
--description that is displayed with the temp. Can be blank
LOCATION="TEST_NODE"
--set to 1 for Fahrenheit, 0 for Celsius
fahrenheit=1

--Value to offset the temperature to compensate for 
--enclosed module with no airflow.
offset=10

--setup the wifi SSID and password.
SSID="YOURSSID"

WIFIPWD="YOURPASSWORD"

function get_temp() 
   --layout top of web page
   outbuf = ""
   outbuf = outbuf.."<!doctype html>"
   outbuf = outbuf.."<html>"
   outbuf = outbuf.."<head>"
   outbuf = outbuf.."<title>Temperature and Humidty </title>"
   outbuf = outbuf.."<META HTTP-EQUIV=\"refresh\" CONTENT=\"15\">"
   outbuf = outbuf.."</head>"
   outbuf = outbuf.."<body>"
    outbuf = outbuf.."<h1>"..LOCATION..": "
   --get temperature and humity and layout web data
   status,temp,humi,temp_decimial,humi_decimial = dht.read11(DHTpin)
   if( status == dht.OK ) then
       if (fahrenheit == 1 ) then
       --convert to Fahrenheit
       temp=(temp*9/5+32)-offset 

       outbuf= outbuf.."Temperature: "..temp.." F"
       else
       --temp in Celsius
       outbuf= outbuf.."Temperature: "..temp.." C"
       end
       outbuf= outbuf.." , "
       outbuf= outbuf.."Humidity:    "..humi.." %"
   else
       
       outbuf= outbuf.."Unable to read DHT sensor"
   end -- end if status

   -- layout end of web page.
   outbuf = outbuf.."</h1>"
   outbuf = outbuf.."</body>"
   outbuf = outbuf.."</html>"  
   
return outbuf   --return the formated page to caller.

end  --end get_temp

function setup_wifi()
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config(SSID,WIFIPWD)
wifi.sta.setip({ip="192.168.1.241",netmask="255.255.255.0",gateway="192.168.1.1"})
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function() 
if wifi.sta.getip()== nil then 
print("IP unavaiable, Waiting...") 
else 
tmr.stop(1)
print("Config done, IP is "..wifi.sta.getip())
--dofile("ds1820.lua")
--dofile("listap.lua")
end 
end)
end


setup_wifi()

  -- A simple http server
    srv=net.createServer(net.TCP) 
    srv:listen(80,function(conn) 
      conn:on("receive",function(conn,payload) 
        --print(payload) 

        tempout=get_temp()  -- get tempature and humidty
        conn:send(tempout)
        
      end) 
      conn:on("sent",function(conn) conn:close() end)
    end)
