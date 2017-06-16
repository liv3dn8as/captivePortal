-- Put together by liv3dn8as, Created April 2017 for ESP-Mesh Project
-- Needed Modules: crypto, enduser_setup, file, GPIO
-- HTTP, mDNS, MQTT, net, node, SNTP, timer, UART, WiFi,

-- Define some variables
theSSID="theNODE_PrivNet" -- set SSID to same as Router to form Mesh
thePWD="thisisONLYatest" -- passphrase
theAUTH=wifi.WPA_WPA2_PSK -- set authentication mode
theChan=5 -- Main router is 11

print("---------------------")
print("Setting up WiFi AP...")

-- Configuration area for forming Mesh
wifi.setmode(wifi.STATIONAP)
cfg={}
   cfg.ssid=theSSID
   cfg.pwd=thePWD
   cfg.auth=theAUTH
   cfg.channel=theChan
   cfg.hidden=0 --1 if true
wifi.ap.config(cfg)

print("Done.")
print("---------------------")

--use enduser_setup instead of hardcoding in credentials
enduser_setup.manual(true)
enduser_setup.start(
   function()
      print("Connected to wifi as:" .. wifi.sta.getip())
   end,
   function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
   end

);

majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
print("Flash size is "..flashsize.." kBytes.")

remaining, used, total=file.fsinfo()
    print("File system:\n Total : "..(total/1024).." kBytes\n Used  : "..(used/1024).." kBytes\n Remain: "..(remaining/1024).." kBytes")

function startup()
    uart.on("data")
    if abort == true then
        print('startup aborted')
        return
        end
    end

 -- prepare abort procedure
    abort = false
    print('Send some xxxx Keystrokes now to abort startup.')
    -- if <CR> is pressed, abort
      uart.on("data", "x", 
      function(data)
        print("receive from uart:", data)
        if data=="x" then
          abort = true 
          uart.on("data") 
        end        
    end, 0)


print ('Will launch servers in 5 seconds...')
tmr.alarm(0,5000,0,startup)

-- End WiFi configuration


-- Compile server code and remove original .lua files.
-- This only happens the first time after server .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local serverFiles = {
   'httpserver.lua',
   'httpserver-b64decode.lua',
   'httpserver-basicauth.lua',
   'httpserver-conf.lua',
   'httpserver-connection.lua',
   'httpserver-error.lua',
   'httpserver-header.lua',
   'httpserver-request.lua',
   'httpserver-static.lua',
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
collectgarbage()


-- Function for starting the server.
-- If you compiled the mdns module, then it will register the server with that name.
local startServer = function(ip, hostname)
   local serverPort = 80
   if (dofile("httpserver.lc")(serverPort)) then
      print("nodemcu-httpserver running at:")
      print("   http://" .. ip .. ":" ..  serverPort)
      if (mdns) then
         mdns.register(hostname, { description="A tiny server", service="http", port=serverPort, location='Earth' })
         print ('   http://' .. hostname .. '.local.:' .. serverPort)
      end
   end
end


if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then

   -- Connect to the WiFi access point and start server once connected.
   -- If the server loses connectivity, server will restart.
   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
      print("Connected to WiFi Access Point. Got IP: " .. args["IP"])
      startServer(args["IP"], "nodemcu")
      wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(args)
         print("Lost connectivity! Restarting...")
         node.restart()
      end)
   end)

   -- What if after a while (30 seconds) we didn't connect? Restart and keep trying.
   local watchdogTimer = tmr.create()
   watchdogTimer:register(30000, tmr.ALARM_SINGLE, function (watchdogTimer)
      local ip = wifi.sta.getip()
      if (not ip) then ip = wifi.ap.getip() end
      if ip == nil then
         print("No IP after a while. Restarting...")
         node.restart()
      else
         --print("Successfully got IP. Good, no need to restart.")
         watchdogTimer:unregister()
      end
   end)
   watchdogTimer:start()


else

   startServer(wifi.ap.getip(), "nodemcu")

end
